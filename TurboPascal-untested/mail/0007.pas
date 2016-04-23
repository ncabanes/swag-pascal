{ MARK LEWIS }

Uses
  Dos;

Type
  ti = Record
    Var1 : Word;
    Var2 : Word;
  end;

  MsgInfo = Record
    From_Name : Array[1..36] of Char;
    To_Name   : Array[1..36] of Char;
    Subject   : Array[1..72] of Char;
    DateTime  : Array[1..20] of Char;
    timesread : Word;
    destnode  : Word;
    orignode  : Word;
    cost      : Word;
    orignet   : Word;
    destnet   : Word;
    field1    : ti;    { these two have at least two seperate }
    field2    : ti;    { Uses. time sent/rcvd or zone/point info }
    replyto   : Word;
    attribute : Word;
    nextmsg   : Word;
  end;

{
ahhh... what the heck... the following will read the MSG header and display
it... i'll leave the processing of the messagebody as an exercise For the
reader(s)... it's a lot of fun... make sure you get/have the FTSC documents
handy... there is one that talks about hints to follow when processing messages
(in .PKT's and in .MSG's) like filtering out all CR's, LF's and softcarriage
returns -=B-)
}

Var
  MInfo    : MsgInfo;
  MSGName  : PathStr;
  MSGFile  : File;
  i        : Byte;
  t1,t2    : datetime;
  notdate  : Boolean;
  numread  : Word;

{-------------------------------------------------------------------------}
begin  { Main Body }
  assign(output, '');
  reWrite(output);
  Filemode := 64;
  MSGName  := ParamStr(1); { Get message Filename from command line }
  if (MSGName = '') Then
  begin
    WriteLn('Name of *.MSG must be specified on command line.');
    Halt;
  end;
  FillChar(Minfo,SizeOf(Minfo),#0);
  Assign(MSGFile,MSGName);
  {$I-} Reset(MSGFile,1); {$I+}
  if IOResult <> 0 Then
  begin
    Writeln('Unable to open the *.MSG!');
    halt;
  end;
  { Read in header... }
  BlockRead(MSGFile,Minfo,SizeOf(Minfo),NumRead);
  { decode time/date fields For FrontDoor/OPUS }
  { i think this is a UNIX time/date format but not sure }
  t1.min   := (minfo.field1.Var2 and $07e0) shr 5;
  t1.hour  := (minfo.field1.Var2 and 63488) shr 11;
  t1.sec   := 0;
  t1.year  := 1980 + (minfo.field1.Var1 and $fe00) shr 9;
  t1.month := (minfo.field1.Var1 and $01e0) shr 5;
  t1.day   := (minfo.field1.Var1 and $001f);
  t2.min   := (minfo.field2.Var2 and $07e0) shr 5;
  t2.hour  := (minfo.field2.Var2 and 63488) shr 11;
  t2.sec   := 0;
  t2.year  := 1980 + (minfo.field2.Var1 and $fe00) shr 9;
  t2.month := (minfo.field2.Var1 and $01e0) shr 5;
  t2.day   := (minfo.field2.Var1 and $001f);
  if (t1.year < 1990) and (t2.year < 1990) then
    notdate := True
  else
    notdate := False;
    { if the years are over three years ago, then we are probably }
    { processing a message that is using these fields For their }
    { other documented use. }
  Write('From: ');
  For i := 1 to 36 do
    Write(minfo.from_name[i]);
  Writeln;
  Write('To  : ');
  For i := 1 to 36 do
    Write(minfo.to_name[i]);
  Writeln;
  Write('Subj: ');
  For i := 1 to 72 do
    Write(minfo.subject[i]);
  Writeln;
  Write('Date: ');
  For i := 1 to 20 do
    Write(minfo.datetime[i]);
  Writeln;
  Writeln('timesread : ',minfo.timesread);
  Writeln(' destnode : ',minfo.destnode );
  Writeln(' orignode : ',minfo.orignode );
  Writeln('     cost : ',minfo.cost     );
  Writeln('  orignet : ',minfo.orignet  );
  Writeln('  destnet : ',minfo.destnet  );
  if notdate then
  begin
    Writeln(' destzone : ',minfo.field1.Var1);
    Writeln(' origzone : ',minfo.field1.Var2);
    Writeln('destpoint : ',minfo.field2.Var1);
    Writeln('origpoint : ',minfo.field2.Var2);
  end
  else
  begin
    Writeln('    time1 : ',t1.month,'/',t1.day,'/',t1.year,'   ',
                           t1.hour,':',t1.min,':',t1.sec);
    Writeln('    time2 : ',t2.month,'/',t2.day,'/',t2.year,'   ',
                           t2.hour,':',t2.min,':',t2.sec);
  end;
  Writeln('  replyto : ',minfo.replyto  );
  Writeln('attribute : ',minfo.attribute);
  Writeln('  nextmsg : ',minfo.nextmsg  );
  Close(MSGFile);
end.

