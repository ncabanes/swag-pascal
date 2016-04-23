Program VERBOSITY_INDEX;
{
JUSTIN MARQUEZ

  Reads a FidoNet *.MSG File areas and logs info about authorship and
  "verbosity" found in the messages.

  Requires Turbo Pascal 7.xx or Borland Pascal 7.xx (for the StringS Unit)

  OutPut is redirectable.  Can be quickly sorted With Dos's SORT.COM
  Here is a batch File you may find useful:

rem YAK.BAT
verbose %1 > zap.txt
sort < zap.txt > yak.txt /+37 /R
del zap.txt

   This Program is written by Justin Marquez, FidoNet 106/100
   It is being donated to all as a PUBLIC DOMAIN Program, which may be
   freely used, copied and modified as you please.

   "if you improve on it, I'd like a copy of the modifications For my
   own edification!"
}

Uses
  Strings,
  Dos;

Type
  FidoMessageHeader = Record
    FromUser  : Array[0..35] of Char ;
    ToUser    : Array[0..35] of Char ;
    Subject   : Array[0..71] of Char ;
    DateTime  : Array[0..19] of Char ;
    TimesRead : Word ;
    DestNode  : Word ;
    OrigNode  : Word ;
    Cost      : Word ;
    OrigNet   : Word ;
    DestNet   : Word ;
    Filler    : Array[0..7] of Byte ;
    Replyto   : Word ;
    Attribute : Word ;
    NextReply : Word ;
  end;

  Entry = Record
    Author : String[36];
    Count  : Integer;
    Bytes  : LongInt;
  end;

Var
  MsgDir,
  fn       : String;
  SR       : SearchRec;
  tmp      : FidoMessageHeader;
  Who_From : String[36];
  n,
  i        : Integer;
  HiNum    : Integer;
  rec      : Array [1..512] of Entry;
  TotBytes : LongInt;

Procedure GetMsgInfo (fname : String; Var Hdr : FidoMessageHeader);
Var
  HFile : File of FidoMessageHeader;
  MFile : Text;
begin
  FillChar(Hdr, SizeOf(Hdr), #0);  { clear it out initially }
  { get msg hdr only }
  Assign(HFile,fname);
  Reset(HFile);
  Seek(HFile, 0);
  Read(HFile, Hdr);
  Close(HFile);
end;

Procedure Pad_Path(Var s : String);
begin
  if s[length(s)] <> '\' then
    s := s + '\';
end;

Procedure Process_Name;
Var
  k : Integer;
  Found : Boolean;
begin
  Found := False;
  if n > 0 then
    For k := 1 to n do
      if Who_From = rec[k].author then
      begin
        inc(rec[k].count);
        rec[k].Bytes := rec[k].Bytes + SR.Size;
        Found := True;
      end
  else
  begin
    rec[1].author := Who_From;
    rec[1].count  := 1;
    rec[1].Bytes := rec[1].Bytes + SR.Size
  end;
  if not Found then
  begin
    inc(n);
    Rec[n].Author := Who_From;
    Rec[n].Count  := 1;
    rec[n].Bytes  := rec[n].Bytes + SR.Size;
  end;
end;

Procedure Intro_And_Init;
begin
  FillChar(rec,SizeOf(rec),#0);  { clear it out initially }
  HiNum    := 0;
  TotBytes := 0;
  n        := 0;
  if ParamCount > 0 then
    MsgDir := ParamStr(1)
  else
  begin
    WriteLn(' VERBOSE <path> >');
    WriteLn('EXAMPLE:');
    WriteLn;
    WriteLn('VERBOSE C:\OPUS\HOUSYSOP\ ');
    WriteLn(' reads all msg Files in the area and reports findings.');
    WriteLn;
    WriteLn(' Note: can be redirected to a File or device.');
    WriteLn;
    WriteLn('Public Domain from 106/100. Request as VERBOSE.ZIP.');
    Halt(2);
  end;
end;

Procedure Process_Files;
begin
  Pad_Path(MsgDir);
  fn := MsgDir + '*.MSG';
  FindFirst(fn, AnyFile, SR);
  While DosError = 0 do
  begin
    fn := MsgDir + SR.Name;
    GetMsgInfo (fn, tmp);
    Who_From := '';
    Who_From := StrPas(StrUpper(tmp.FromUser));
    Inc(HiNum);
    TotBytes := TotBytes + SR.Size;
    Process_Name;
    FindNext(SR);
  end;
end;

Procedure Report_Results;
begin
  For i := 1 to n do
    WriteLn(rec[i].Author : 36, Rec[i].Count : 4,
           (100 * Rec[i].Count / HiNum) : 6 : 1, '% ',
            Rec[i].Bytes : 6, ' Bytes or',
           (100 * Rec[i].Bytes / TotBytes) : 5 : 1, '% by size' );
  WriteLn(' Total messages found: ' : 36, HiNum : 4);
  WriteLn(' Total Bytes found   : ' : 36, TotBytes : 18);
  WriteLn(n, ' different Writers found in ', MsgDir, '.');
end;

begin
  Intro_And_Init;
  Process_Files;
  Report_Results;
end.
