{   In the following message is a Complete Program I just wrote
(including 3 routines from TeeCee's hints) which solves a particular
problem I was having, but also demonstrates some things I see queried
here.  So, there are a number of useful routines in it, as well as a
whole Program which may help.
   This Program dumps a Dos File to Hex and (modified) BCD.  It is
patterned after Vernon Buerg's LIST display (using Alt-H), which I find
useful to look at binary Files.  The problem is (was) I couldn't PrtSc
the screens, due to numerous special Characters which often hung my
Printer.  So, I wrote this Program to "dump" such Files to either the
Printer or a Printer File.  It substitutes an underscore For most
special Characters (you can change this, of course).
   note, too, that it demonstates the use of a C-like Character stream
i/o, which is a Variation of the "stream i/o" which is discussed here.
This allows fast i/o of any Type of File, and could be modified to
provide perFormant i/o For Text Files.
   A number of the internal routines are a bit clumsy, since I had to
(107 min left), (H)elp, More? make them "generic" For this post, rather than make use of after-market
libraries that I use (TTT, in my Case).
   Enjoy!...
}

Program Hex_Dump;        { Dump a File in Hex and BCD   930107 }
Uses Crt, Dos, Printer;
{$M 8192,0,8192}
   {  Public Domain, by Mike Copeland and Trevor Carlsen  1993 }
Const VERSION = '1.1';
      BSize   = 32768;                           { Buffer Size }
      ifLinE  = 4;                          { InFormation Line }
      PRLinE  = 24;                              { Prompt Line }
      ERLinE  = 25;                               { Error Line }
      DSLinE  = 22;                             { Display Line }
      PL      = 1;                          { partial line o/p }
      WL      = 2;                            { whole line o/p }
      B40     = '                                        ';
Var   CP      : Word;                      { Character Pointer }
      BLKNO   : Word;                                { Block # }
      L,N     : Word;
      RES     : Word;
      LONG    : LongInt;
      NCP     : LongInt;              { # Characters Processed }
      FSize   : LongInt;                  { Computed File Size }
      BV      : Byte;                  { generic Byte Variable }
      PRtoK   : Boolean;
      PFP     : Boolean;
      REGS    : Registers;
      PRTFile : String;
      F1      : String;
      MSTR,S1 : String;
      PFV1    : Text;
      F       : File;
      B       : Array[0..BSize-1] of Byte;
      CH      : Char;

Procedure WPROM (S : String);             { generalized Prompt }
begin
  GotoXY (1,PRLinE); Write (S); ClrEol; GotoXY (Length(S)+1,PRLinE);
end;  { WPROM }

Procedure CLEARBOT;                   { clear bottom of screen }
begin
  GotoXY (1,PRLinE); ClrEol; GotoXY (1,ERLinE); ClrEol
end;  { CLEARBOT }

Function GETYN : Char;               { get Single-key response }
Var CH : Char;
begin
  CH := UpCase(ReadKey); if CH = #0 then CH := ReadKey;
  CLEARBOT; GETYN := CH;
end;  { GETYN }

Procedure PAUSE;              { Generalized Pause processing }
Var CH : Char;
begin
  WPROM ('Press any key to continue...'); CH := GETYN
end;  { PAUSE }

Procedure ERRor1 (S : String);       { General Error process }
Var CH : Char;
begin
  GotoXY (1,ERLinE); Write (^G,S); ClrEol; PAUSE
end;  { ERRor1 }

Procedure FATAL (S : String);      { Fatal error - Terminate }
begin
  ERRor1 (S); Halt
end;  { FATAL }

Function TEStoNLinE : Byte;      { Tests For Printer On Line }
Var  REGS : Registers;
begin
  With REGS do
    begin
      AH := 2; DX := 0;
      Intr($17, Dos.Registers(REGS));
      TEStoNLinE := AH;
    end
end;  { TEStoNLinE }

Function SYS_DATE : String;   { Format System Date as YY/MM/DD }
Var S1, S2, S3 : String[2];
begin
  REGS.AX := $2A00;                                 { Function }
  MsDos (Dos.Registers(REGS));             { fetch System Date }
  With REGS do
    begin
      Str((CX mod 100):2,S1); Str(Hi(DX):2,S2); Str(Lo(DX):2,S3);
    end;
  if S2[1] = ' ' then S2[1] := '0';           { fill in blanks }
  if S3[1] = ' ' then S3[1] := '0';
  SYS_DATE := S1+'/'+S2+'/'+S3
end;  { SYS_DATE }

Function SYS_TIME : String;               { Format System Time }
Var S1, S2, S3 : String[2];
begin
  REGS.AX := $2C00;                                 { Function }
  MsDos (Dos.Registers(REGS));             { fetch System Time }
  With REGS do
    begin
      Str(Hi(CX):2,S1); Str(Lo(CX):2,S2); Str(Hi(DX):2,S3);
    end;
  if S2[1] = ' ' then S2[1] := '0';           { fill in blanks }
  if S3[1] = ' ' then S3[1] := '0';
  if S1[1] = ' ' then S1[1] := '0';
  SYS_TIME := S1+':'+S2+':'+S3
end;  { SYS_TIME }

Function EXISTS ( FN : String): Boolean;  { test File existance }
Var F : SearchRec;
begin
  FindFirst (FN,AnyFile,F); EXISTS := DosError = 0
end;  { EXISTS }

Function UPPER (S : String) : String;
Var I : Integer;
begin
  For I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
  UPPER := S;
end;  { UPPER }

Procedure SET_File (FN : String);      { File Output For PRinT }
begin
  PRTFile := FN; PFP := False; PRtoK := False;
end;  { SET_File }

Procedure PRinT_inIT (S : String);  { Initialize Printer/File Output }
Var X,Y : Word;
begin
  PRtoK := TestOnLine = 144; PFP := False; X := WhereX; Y := WhereY;
  if PRtoK then
    begin
      WPROM ('Printer is Online - do you wish Printer or File? (P/f) ');

      if GETYN = 'F' then SET_File (S)
      else
        begin
          WPROM ('Please align Printer'); PAUSE
        end
    end
  else SET_File (S);
  GotoXY (X,Y)                            { restore cursor }
end;  { PRinT_inIT }

Function OPENF (Var FV : Text; FN : String; MODE : Char) : Boolean;
Var FLAG  : Boolean;
begin
  FLAG := True;                             { set default }
  Assign (FV, FN);                        { allocate File }
  Case UpCase(MODE) of                        { open mode }
    'W' : begin                                  { output }
            {$I-} ReWrite (FV); {$I+}
          end;
    'R' : begin                                   { input }
            {$I-} Reset (FV); {$I+}
          end;
    'A' : begin                            { input/extend }
            {$I-} Append (FV); {$I+}
          end;
    else
  end; { of Case }
  if Ioresult <> 0 then          { test For error on OPEN }
    begin
      FLAG := False;           { set Function result flag }
      ERRor1 ('*** Unable to OPEN '+FN);
    end;
  OPENF := FLAG                        { set return value }
end;  { OPENF }

Procedure PRinT (inD : Integer; X : String); { Print Report Line }
Var AF : Char;                              { Append Flag }
    XX,Y : Word;
begin
  if PRtoK then                         { Printer online? }
    begin
      Case inD of              { what Type of print line? }
        PL  : Write (LST, X);              { partial line }
        WL  : Writeln (LST, X);              { whole line }
      end
    end  { Printer o/p }
  else                                     { use o/p File }
    begin
      XX := WhereX; Y := WhereY;
      if not PFP then                   { File not opened }
        begin
          AF := 'W';                            { default }
          if EXISTS (PRTFile) then
            begin
              WPROM ('** Print File '+PRTFile+' exists - Append to it? (Y/n) ');
              if GETYN <> 'N' then AF := 'A';
            end;
          if OPENF (PFV1, PRTFile, AF) then PFP := True { set flag }
          else FATAL ('*** Cannot Open Printer O/P File - Terminating');

        end;  { of if }
      GotoXY (XX,Y);                      { restore cursor }
      Case inD of
        PL  : Write (PFV1, X);                   { partial }
        WL  : Writeln (PFV1, X);                   { whole }
      end;
    end;  { else }
end;  { PRinT }

Function FSI (N : LongInt; W : Byte) : String; { LongInt->String }
Var S : String;
begin
  if W > 0 then Str (N:W,S)
  else          Str (N,S);
  FSI := S;
end;  { FSI }

Procedure CLOSEF (Var FYL : Text);  { Close a File - open or not }
begin
{$I-} Close (FYL); {$I+} if Ioresult <> 0 then;
end;  { CLOSEF }

Function CENTER (S : String; N : Byte): String;  { center N Char line }
begin
  CENTER := Copy(B40+B40,1,(N-Length(S)) Shr 1)+S
end;  { CENTER }

Procedure SSL;                              { System Status Line }
{  This routine is just For "flash"; it can be omitted... }
Const DLM = #32#179#32;
begin
  GotoXY (1,1); Write (F1+DLM+'Fsz: '+FSI(FSize,1)+DLM+
                             'Blk: '+FSI(BLKNO,1)+DLM+
                             'C# '+FSI(CP,1));
end;  { SSL }

           {  The following 3 routines are by Trevor Carlsen }
Function Byte2Hex(numb : Byte): String; { Byte to hex String }
Const HexChars : Array[0..15] of Char = '0123456789ABCDEF';
begin
  Byte2Hex[0] := #2; Byte2Hex[1] := HexChars[numb shr 4];
  Byte2Hex[2] := HexChars[numb and 15];
end; { Byte2Hex }

Function Numb2Hex(numb: Word): String;  { Word to hex String.}
begin
  Numb2Hex := Byte2Hex(hi(numb))+Byte2Hex(lo(numb));
end; { Numb2Hex }

Function Long2Hex(L: LongInt): String; { LongInt to hex String }
begin
  Long2Hex := Numb2Hex(L shr 16) + Numb2Hex(L);
end; { Long2Hex }

Function GET_Byte: Byte;         { fetch Byte from buffer data }
begin
  GET_Byte := Byte(B[CP]); Inc (CP); Inc (NCP)
end;  { GET_Byte }

Function EOS (Var FV : File): Boolean; { Eof on String File Function }
begin
  if CP >= RES then                    { data still in buffer? }
    if NCP < FSize then
      begin                               { no - get new block }
        BLKNO := (NCP div BSize);
        FillChar(B,BSize,#0);                  { block to read }
        Seek (F,BLKNO*BSize); BlockRead (F,B,BSize,RES); CP := 0;
      end
    else RES := 0;
  EOS := RES = 0;
end;  { EOS }

begin
  ClrScr; GotoXY (1,2);
  Write (CENTER('--- Hex Dump - Version '+VERSION+' ---',80));
  if ParamCount > 0 then F1 := ParamStr(1)
  else
    begin
      WPROM ('Filename to be dumped: '); readln (F1); CLEARBOT
    end;
  if not EXISTS (F1) then FATAL ('*** '+F1+' File not present - Terminating! ***');
  PRinT_inIT ('HEXDUMP.TXT'); F1 := UPPER(F1);
  PRinT (WL,CENTER('Hex Dump of '+F1+'  '+SYS_DATE+' '+SYS_TIME,80));
  Assign (F,F1); GotoXY (1,ifLinE); Write ('Processing ',F1);
  Reset (F,1); FSize := FileSize(F); CP := BSize; NCP := 0; RES :=
BSize;
  PRinT (WL,'offset  Addr  1  2  3  4  5  6  7  8  9 10  A  B  C  D  E  F  1234567890abcdef');
  While not EOS (F) do
    begin
      if (NCP mod 16) = 0 then
        begin
          if NCP > 0 then
            begin
              PRinT (WL,MSTR+S1); SSL
            end;
          MSTR := FSI(NCP,6)+'  '+Numb2Hex(NCP); { offset & Address }
          S1 := '  ';
        end;
      BV := GET_Byte;                 { fetch next Byte from buffer }
      MSTR := MSTR+' '+Byte2Hex(BV);                     { Hex info }
      if BV in [32..126] then S1 := S1+Chr(BV)           { BCD info }
      else                    S1 := S1+'_';
    end;
  Close (F);
  While (NCP mod 16) > 0 do
    begin
      MSTR := MSTR+'   '; Inc (NCP);           { fill out last line }
    end;
  PRinT (WL,MSTR+S1); SSL; MSTR := 'Printer';
  if PFP then
    begin
      CLOSEF (PFV1); MSTR := PRTFile
    end;
  GotoXY (1,ifLinE+1); Write ('Formatted output is on ',MSTR);
  GotoXY (1,ERLinE); Write (CENTER('Finis...',80))
end.
