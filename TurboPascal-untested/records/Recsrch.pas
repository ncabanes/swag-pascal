(*
  Category: SWAG Title: RECORD RELATED ROUTINES
  Original name: 0006.PAS
  Description: RECSRCH.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{
HAGEN LEHMANN
> Can someone help me make a search Procedure that will read
> from a Record format, from the disk!!!

The easiest way to search a Record in a File is to read the Records from File
and compare them With the Record that is to be searched.

if you simply want to search For a String then I've got something For you. ;-)
Look at this Function:
}
Function Search(SearchFor : String; FileName  : String) : LongInt;
Var
  F               : File;
  Pos,Dummy       : LongInt;
  BufSize,ReadNum : Word;
  Buffer          : ^Byte;
  Found           : Boolean;

  Function SearchString(Var Data; Size : Word; Str  : String) : LongInt;
  Var
    S     : String;
    Loop  : LongInt;
    Found : Boolean;
    L     : Byte Absolute Str;
  begin
    Loop  := -1;
    Found := False;
    if L > 0 Then   { I don't search For empty Strings, I'm not crazy }
    Repeat
      Inc(Loop);
      { convert buffer into String }
      Move(Mem[Seg(Data) : Loop], Mem[Seg(S) : Ofs(S) + 1], L + 1);
      S[0] := Char(L);
      if S = Str Then
        Found := True;             { search For String }
    Until Found Or (Loop = Size - L);
    if Found Then
      SearchString := Loop   { that's the File position }
    else
      SearchString := -1;    { I couldn't find anything }
  end;

begin
  Search := -1;
  if MaxAvail > 65535 Then
    BufSize := 65535   { check available heap }
  else
    BufSize := MaxAvail;
  if (BufSize > 0) And (BufSize > Length(SearchFor)) Then
  begin
    GetMem(Buffer, BufSize);               { reserve heap For buffer }
    Assign(F, FileName);
    Reset(F, 1);                                         { open File }
    if IOResult = 0 Then
    begin
      Pos   := 0;
      Found := False;
      Repeat
        BlockRead(F, Buffer^, BufSize, ReadNum);          { read buffer }
        if ReadNum > 0 Then                             { anything ok? }
        begin
          Dummy := SearchString(Buffer^, ReadNum, SearchFor);
          if Dummy <> -1 Then                   { String has been found }
          begin
            Found := True;                            { set found flag }
            Inc(Pos, Dummy);
          end
          else
          begin
            Inc(Pos, ReadNum - Length(SearchFor));
            Seek(F, Pos);                       { set new File position }
          end;
        end;
      Until Found Or (ReadNum <> BufSize);
      if Found Then
        Search := Pos            { String has been found }
      else
        Search := -1;         { String hasn't been found }
      Close(F);
    end;
    Release(Buffer);                        { release reserved heap }
  end;
end;


