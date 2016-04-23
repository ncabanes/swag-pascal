Program Chge;

{ Copyright 1990 Trevor J Carlsen Version 1.06  24-07-90                    }
{ This Program may be used and distributed as if it was in the Public Domain}
{ With the following exceptions:                                            }
{    1.  If you alter it in any way, the copyright notice must not be       }
{        changed.                                                           }
{    2.  If you use code excerpts in your own Programs, due credit must be  }
{        given, along With a copyright notice -                             }
{        "Parts Copyright 1990 Trevor J Carlsen"                            }
{    3.  No Charge may be made For any Program using code from this Program.}

{ Changes (or deletes) a String in any File. If an .EXE or .COM File then  }
{ the change must be of a similar length inorder to retain the executable  }
{ integrity.                                                               }

{ If you find this Program useful here is the author's contact address -   }

{      Trevor J Carlsen                                                    }
{      PO Box 568                                                          }
{      Port Hedland Western Australia 6721                                 }
{      Voice 61 [0]91 72 2026                                              }
{      Data  61 [0]91 72 2569                                              }

Uses
  BmSrch,
  Dos;

Const
  space       = #32;
  quote       = #34;
  comma       = #44;
  copyright1  = 'CHGE - version 1.06 Copyright 1989,1990 Trevor Carlsen';
  copyright2  = 'All rights reserved.';

Var
  dirinfo     : SearchRec; { Dos }
  f           : File;
  FDir        : DirStr;    { Dos }
  mask,
  fname,
  oldstr,
  newstr      : String;
  oldlen      : Byte Absolute oldstr;
  newlen      : Byte Absolute newstr;
  changes     : Word;
  time        : LongInt Absolute $0000:$046C;
  start       : LongInt;

Function ElapsedTime(start : LongInt): Real;
  begin
    ElapsedTime := (time - start) / 18.2;
  end; { ElapsedTime }

Procedure ReportError(e : Byte);
begin
  Writeln('CHGE [path]Filename searchstr replacementstr|NUL');
  Writeln(' eg:  CHGE c:\autoexec.bat "color" "colour"');
  Writeln('      CHGE c:\autoexec.bat 12 13,10,13,10,13,10,13,10');
  Writeln('      CHGE c:\wp\test.txt "Trevor" NUL');
  Writeln;
  Writeln('The first example will change every occurrence of the Word "color" to "colour"');
  Writeln('The second will replace every formfeed Character (ascii 12) With 4 sets of');
  Writeln('carriage return/linefeed combinations and the third will delete every');
  Writeln('occurrence of "Trevor"');
  Writeln('The prime requirements are:');
  Writeln('  There MUST always be exactly three space delimiters on the command line -');
  Writeln('  one between the Program name and the Filename, one between the Filename and');
  Writeln('  the search String and another between the search String and the replacement');
  Writeln('  String. Any other spaces may ONLY occur between quote Characters.');
  Writeln('  The Program will not permit you to change the length of an .EXE or .COM File,');
  Writeln('  therefore the replacement String MUST be the same length as the String');
  Writeln('  that it is replacing in these cases.');
  Writeln;
  Writeln('  If using ascii codes, each ascii Character must be separated from another');
  Writeln('  by a comma. The same rule applies to spaces as above - three required - no');
  Writeln('  more - no less. If just deleting the NUL must not be in quotes.');
  halt(e);
end; { ReportError }

Function StUpCase(Str : String) : String;
Var
  Count : Integer;
begin
  For Count := 1 to Length(Str) do
    Str[Count] := UpCase(Str[Count]);
  StUpCase := Str;
end;

Procedure ParseCommandLine;
Var
  parstr,                                      { contains the command line }
  temp      : String;
  len       : Byte Absolute parstr;           { the length Byte For parstr }
  tlen      : Byte Absolute temp;               { the length Byte For temp }
  CommaPos,
  QuotePos,
  SpacePos,
  chval     : Byte;
  error     : Integer;
  DName     : NameStr;
  DExt      : ExtStr;

  Function right(Var s; n : Byte): String;{ Returns the n right portion of s }
  Var
    st : String Absolute s;
    len: Byte Absolute s;
  begin
    if n >= len then
      right := st
    else
      right := copy(st,succ(len)-n,n);
  end; { right }

begin
  parstr        := String(ptr(PrefixSeg,$80)^);     { Get the command line }
  if parstr[1]   = space then
    delete(parstr,1,1);               { First Character is usually a space }
  SpacePos      := pos(space,parstr);
  if SpacePos    = 0 then                                      { No spaces }
    ReportError(1);
  mask          := StUpCase(copy(parstr,1,pred(SpacePos)));
  FSplit(mask,Fdir,DName,DExt);       { To enable the directory to be kept }
  delete(parstr,1,SpacePos);
  QuotePos      := pos(quote,parstr);
  if QuotePos   <> 0 then begin          { quotes - so must be quoted Text }
    if parstr[1] <> quote then               { so first Char must be quote }
      ReportError(2);
    delete(parstr,1,1);                       { get rid of the first quote }
    QuotePos    := pos(quote,parstr);            { and find the next quote }

    if QuotePos  = 0 then                    { no more - so it is an error }
      ReportError(3);
    oldstr    := copy(parstr,1,pred(QuotePos));{ search String now defined }
    if parstr[QuotePos+1] <> space then            { must be space between }
      ReportError(1);
    delete(parstr,1,succ(QuotePos));             { the quotes - else error }
    if parstr[1] <> quote then begin                     { may be a delete }
      tlen      := 3;
      move(parstr[1],temp[1],3);
      if temp <> 'NUL' then                              { is not a delete }
        ReportError(4)                  { must be quote after space or NUL }
      else
        newlen  := 0;               { is a delete - so nul the replacement }
    end
    else begin
      delete(parstr,1,1);                           { get rid of the quote }
      QuotePos   := pos(quote,parstr); { find next quote For end of String }
      if QuotePos = 0 then                            { None? - then error }
        ReportError(5);
      newstr := copy(parstr,1,pred(QuotePos));{ Replacement String defined }
    end;
  end
  else begin                                   { must be using ascii codes }
    oldlen       := 0;
    SpacePos     := pos(space,parstr);     { Find end of search Characters }
    if SpacePos   = 0 then                           { No space - so error }
      ReportError(6);
    temp         := copy(parstr,1,SpacePos-1);
    delete(parstr,1,SpacePos);          { get rid of the search Characters }
    CommaPos     := pos(comma,temp);                    { find first comma }
    if CommaPos   = 0 then             { No comma - so only one ascii code }
      CommaPos   := succ(tlen);
    Repeat                                      { create the search String }
      val(copy(temp,1,CommaPos-1),chval,error); { convert to a numeral and }
      if error <> 0 then                   { if there is an error bomb out }
        ReportError(7);
      inc(oldlen);
      oldstr[oldlen] := Char(chval);{ add latest Char to the search String }
      delete(temp,1,CommaPos);
      CommaPos   := pos(comma,temp);
      if CommaPos = 0 then
        CommaPos := succ(tlen);
    Until tlen = 0;
    newlen       := 0;
    CommaPos     := pos(comma,parstr);
    if CommaPos   = 0 then
      CommaPos   := succ(len);
    Repeat                                 { create the replacement String }
      val(copy(parstr,1,pred(CommaPos)),chval,error);
      if error <> 0 then                              { must be ascii code }
        ReportError(8);
      inc(newlen);
      newstr[newlen] := Char(chval);
      delete(parstr,1,CommaPos);
      CommaPos   := pos(comma,parstr);
      if CommaPos = 0 then CommaPos := len+1;
    Until len = 0;
  end; { else }
  if ((right(mask,3) = 'COM') or (right(mask,3) = 'EXE')) and
    (newlen <> oldlen) then
    ReportError(16);
end; { ParseCommandLine }

Function OpenFile(fn : String): Boolean;
  begin
    assign(f,fn);
    {$I-} reset(f,1); {$I+}
    OpenFile := IOResult = 0;
  end; { OpenFile }

Procedure CloseFile;
  begin
    {$I-}
    truncate(f);
    Close(f);
    if IOResult <> 0 then;                          { dummy call to IOResult }
    {$I+}
  end; { CloseFile }

Procedure ChangeFile(Var chge : Word);
  Const
    bufflen     = 65000;                    { This is the limit For BMSearch }
    searchlen   = bufflen - 1000;      { Allow space For extra Characters in }
  Type                                              { the replacement String }
    buffer      = Array[0..pred(bufflen)] of Byte;
    buffptr     = ^buffer;
  Var
    table       : BTable;                         { Boyer-Moore search table }
    old,                                             { Pointer to old buffer }
    nu          : buffptr;                           { Pointer to new buffer }
    count,
    result,
    oldpos,
    newpos      : Word;
    oldfpos,
    newfpos     : LongInt;
    finished    : Boolean;

  Procedure AllocateMemory(Var p; size : Word);
    Var
      buff : Pointer Absolute p;
    begin
      if MaxAvail >= size then
        GetMem(buff,size)
      else begin
        Writeln('Insufficient memory available.');
        halt(10);
      end;
    end; { AllocateMemory }

  begin
    oldfpos := 0; newfpos := 0;
    chge := 0;
    AllocateMemory(old,searchlen);
    AllocateMemory(nu,bufflen);      { make room on the heap For the buffers }
    BMMakeTable(oldstr,table);           { Create a Boyer-Moore search table }
    {$I-}
    BlockRead(f,old^,searchlen,result);                    { Fill old buffer }
    oldfpos := FilePos(f);
    {$I+}
    if IOResult <> 0 then begin
      CloseFile; ReportError(11);
    end;
    Repeat
      oldpos := 0; newpos := 0; count := 0;
      finished := (result < searchlen); { if buffer<>full then no more reads }
      Repeat                              { Do a BM search For search String }
        count := BMSearch(old^[oldpos],result-oldpos,table,oldstr);
        if count = $FFFF then begin   { search String not found so copy rest }
          move(old^[oldpos],nu^[newpos],result-oldpos);   { of buffer to new }
          inc(newpos,result-oldpos);  { buffer and update the buffer markers }
          inc(oldpos,result-oldpos);
        end
        else begin                                     { search String found }
          if count <> 0 then begin       { not at position one in the buffer }
            move(old^[oldpos],nu^[newpos],count);{ transfer everything prior }
            inc(oldpos,count);          { to the search String to new buffer }
            inc(newpos,count);               { and update the buffer markers }
          end;
          move(newstr[1],nu^[newpos],newlen);  { copy the replacement String }
          inc(oldpos,oldlen);        { to the new buffer and update the buffer }
          inc(newpos,newlen);                                      { markers }
          inc(chge);
        end;
      Until oldpos >= result;               { keep going Until end of buffer }
      if not finished then begin       { Fill 'er up again For another round }
        {$I-}
        seek(f,oldfpos);
        BlockRead(f,old^,searchlen,result);
        oldfpos := FilePos(f);
        {$I+}
        if IOResult <> 0 then begin
          CloseFile; ReportError(13);
        end; { if IOResult }
      end; { if not finished }
      {$I-}
      seek(f,newfpos);
      BlockWrite(f,nu^,newpos);                   { Write new buffer to File }
      newfpos := FilePos(f);
      {$I+}
      if IOResult <> 0 then begin
        CloseFile; ReportError(12);
      end;
    Until finished;
    FreeMem(old, searchlen); FreeMem(nu,bufflen);
  end;  { ChangeFiles }

Procedure Find_and_change_all_Files;
  Var
    Filefound : Boolean;

  Function padstr(ch : Char; len : Byte): String;
  
    Var
      temp : String;
    
    begin
      FillChar(temp[1],len,ch);
      temp[0] := chr(len);
      padstr  := temp;
    end; { padstr }

  begin
    Filefound := False;
    FindFirst(mask,AnyFile,dirinfo);
    While DosError = 0 do begin
      Filefound := True;
      start := time;
      fname := FDir + dirinfo.name;
      if OpenFile(fname) then begin
        Write(fname,PadStr(space,30-length(fname)),FileSize(f):7,'  ');
        ChangeFile(changes);
        CloseFile;
        if changes = 0 then
          Writeln
        else
          Writeln('Made ',changes,' changes in ',ElapsedTime(start):4:2,' seconds.')
      end
      else
        Writeln('Unable to process ',fname);
      FindNext(dirinfo);
    end; { While DosError = 0 }
    if not Filefound then
      Writeln('No Files found.');
  end; { Find_and_change_all_Files }

begin { main }
  Writeln(copyright1);
  Writeln(copyright2);
  ParseCommandLine;
  Find_and_change_all_Files;
end.

