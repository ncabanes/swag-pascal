{
>  Can anyone help me figure out how I can move a Text File position
>  Pointer backwards instead of forwards?
}

{$R-,S-,I-}

{
 Turbo Pascal 4.0 Unit to read Text Files backwards.

 See TESTRB.PAS For a test and demonstration Program. Routines here
 are used in a manner very similar to normal Text File read routines
 except that the "reset" positions to the end of the File, and each
 subsequent "readln" returns the prior line in the File Until the
 beginning of the File is reached.

 Each String returned by ReadLnBack is in normal forward order.

 One quirk will occur if an attempt is made to read from Files With
 lines longer than 255 Characters. In this Case ReadLnBack will return
 the _last_ 255 Characters of each such line rather than the first. This
 is in keeping With the backwards nature of the Unit, however.

 Hope someone finds a use For this!

 Written 6/7/88, Kim Kokkonen, TurboPower Software.
 Released to the public domain.
}

Unit RB;
  {-Read Text Files backwards}

Interface

Type
  BackText = File;                {We use the UserData area in the unTyped File

Procedure AssignBack(Var F : BackText; Fname : String);
  {-Assign a backwards File to a File Variable}

Procedure ResetBack(Var F : BackText; BufSize : Word);
  {-Reset a backwards File, allocating buffer space (128 Bytes or greater)}

Procedure ReadLnBack(Var F : BackText; Var S : String);
  {-Read next line from end of backwards File}

Procedure CloseBack(Var F : BackText);
  {-Close backwards File, releasing buffer}

Function BoF(Var F : BackText) : Boolean;
  {-Return True when F is positioned at beginning of File}

Function BackResult : Word;
  {-Return I/O status code from operation}

  {======================================================================}

Implementation

Const
  LF = #10;

Type
  BufferArray = Array[1..65521] of Char;
  BackRec =                       {Same as Dos.FileRec, With UserData filled in
    Record
      Handle : Word;
      Mode : Word;
      RecSize : Word;
      Private : Array[1..26] of Byte;
      Fpos : LongInt;             {Current File position}
      BufP : ^BufferArray;        {Pointer to Text buffer}
      Bpos : Word;                {Current position Within buffer}
      Bcnt : Word;                {Count of Characters in buffer}
      Bsize : Word;               {Size of Text buffer, 0 if none}
      UserData : Array[15..16] of Byte; {Remaining UserData}
      Name : Array[0..79] of Char;
    end;

Var
  BResult : Word;                 {Internal IoResult}

  Procedure AssignBack(Var F : BackText; Fname : String);
    {-Assign a backwards File to a File Variable}
  begin
    if BResult = 0 then begin
      Assign(File(F), Fname);
      BResult := IoResult;
    end;
  end;

  Procedure ResetBack(Var F : BackText; BufSize : Word);
    {-Reset a backwards File, allocating buffer}
  Var
    BR : BackRec Absolute F;
  begin
    if BResult = 0 then
      With BR do begin
        {Open File}
        Reset(File(F), 1);
        BResult := IoResult;
        if BResult <> 0 then
          Exit;

        {Seek to end}
        Fpos := FileSize(File(F));
        Seek(File(F), Fpos);
        BResult := IoResult;
        if BResult <> 0 then
          Exit;

        {Allocate buffer}
        if BufSize < 128 then
          BufSize := 128;
        if MaxAvail < BufSize then begin
          BResult := 203;
          Exit;
        end;
        GetMem(BufP, BufSize);
        Bsize := BufSize;
        Bcnt := 0;
        Bpos := 0;
      end;
  end;

  Function BoF(Var F : BackText) : Boolean;
    {-Return True when F is at beginning of File}
  Var
    BR : BackRec Absolute F;
  begin
    With BR do
      BoF := (Fpos = 0) and (Bpos = 0);
  end;

  Function GetCh(Var F : BackText) : Char;
    {-Return next Character from end of File}
  Var
    BR : BackRec Absolute F;
    Bread : Word;
  begin
    With BR do begin
      if Bpos = 0 then
        {Buffer used up}
        if Fpos > 0 then begin
          {Unread File remains, first reposition File Pointer}
          Bread := Bsize;
          Dec(Fpos, Bread);
          if Fpos < 0 then begin
            {Reduce the number of Characters to read}
            Inc(Bread, Fpos);
            Fpos := 0;
          end;
          Seek(File(F), Fpos);
          BResult := IoResult;
          if BResult <> 0 then
            Exit;

          {Refill buffer}
          BlockRead(File(F), BufP^, Bread, Bcnt);
          BResult := IoResult;
          if BResult <> 0 then
            Exit;

          {Remove ^Z's from end of buffer}
          While (Bcnt > 0) and (BufP^[Bcnt] = ^Z) do
            Dec(Bcnt);
          Bpos := Bcnt;
          if Bpos = 0 then begin
            {At beginning of File}
            GetCh := LF;
            Exit;
          end;

        end else begin
          {At beginning of File}
          GetCh := LF;
          Exit;
        end;

      {Return next Character}
      GetCh := BufP^[Bpos];
      Dec(Bpos);
    end;
  end;

  Procedure ReadLnBack(Var F : BackText; Var S : String);
    {-Read next line from end of backwards File}
  Var
    Slen : Byte Absolute S;
    Tpos : Word;
    Tch : Char;
    T : String;
  begin
    Slen := 0;
    if (BResult = 0) and not BoF(F) then begin
      {Build String from end backwards}
      Tpos := 256;
      Repeat
        Tch := GetCh(F);
        if BResult <> 0 then
          Exit;
        if Tpos > 1 then begin
          Dec(Tpos);
          T[Tpos] := Tch;
        end;
        {Note that GetCh arranges to return LF at beginning of File}
      Until Tch = LF;
      {Transfer to result String}
      Slen := 255-Tpos;
      if Slen > 0 then
        Move(T[Tpos+1], S[1], Slen);
      {Skip over (presumed) CR}
      Tch := GetCh(F);
    end;
  end;

  Procedure CloseBack(Var F : BackText);
    {-Close backwards File, releasing buffer}
  Var
    BR : BackRec Absolute F;
  begin
    if BResult = 0 then
      With BR do begin
        Close(File(F));
        BResult := IoResult;
        if BResult <> 0 then
          Exit;
        FreeMem(BufP, Bsize);
      end;
  end;

  Function BackResult : Word;
    {-Return I/O status code from operation}
  begin
    BackResult := BResult;
    BResult := 0;
  end;

begin
  BResult := 0;
end.


And now, the little test Program TESTRB.PAS that demonstrates how to use the
 Unit:

{
 Demonstration Program For RB.PAS.
 Takes one command line parameter, the name of a Text File to read backwards.
 Reads File one line at a time backwards and Writes the result to StdOut.

 See RB.PAS For further details.

 Written 6/7/88, Kim Kokkonen, TurboPower Software.
 Released to the public domain.
}

Program Test;
  {-Demonstrate RB Unit}

Uses
  RB;

Var
  F : BackText;
  S : String;

  Procedure CheckError(Result : Word);
  begin
    if Result <> 0 then begin
      WriteLn('RB error ', Result);
      Halt;
    end;
  end;

begin
  if ParamCount = 0 then
    AssignBack(F, 'RB.PAS')
  else
    AssignBack(F, ParamStr(1));
  CheckError(BackResult);
  ResetBack(F, 1024);
  CheckError(BackResult);
  While not BoF(F) do begin
    ReadLnBack(F, S);
    CheckError(BackResult);
    WriteLn(S);
  end;
  CloseBack(F);
  CheckError(BackResult);
end.
