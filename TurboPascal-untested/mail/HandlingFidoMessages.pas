(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0028.PAS
  Description: Handling FIDO Messages
  Author: MARTIN WOODS
  Date: 02-21-96  21:03
*)

{
 WK> I was wondering if anyone has either the layout for a *.MSG
 WK> packet or knows of a unit to generate and process *.MSG packets.
}

unit fidomsg;  { See 2 demo programs attached below !! }
Interface
uses dos;
const
  MsgSize = 32768;
type
AddressType = record
                Zone  : Byte;
                Net   : Word;
                Node  : Word;
                Point : Word;
                Domain: String[15];
              end;

TxtPtrType = ^TxtRecType;
TxtRecType = array[1..MsgSize] of char;

String36    = string[36];
String72    = string[72];
String20    = string[20];
FMsgType =    record
                FromUserName : String36;
                ToUserName   : String36;
                Subject      : String72;
                DateTime     : String20;
                Origin       : AddressType;
                Destination  : AddressType;
                NextReply    : word;
                MsgTxtPtr    : TxtPtrType;
              end;

procedure LoadMsg(var Msg: FMsgType; MsgFilePath : PathStr; var Result: byte);
procedure GetMsgHeap    (var Msg: FMsgType);
procedure DisposeMsgHeap(var Msg: FMsgType);

 Implementation

procedure GetMsgHeap(var Msg: FMsgType);
begin
  New(Msg.MsgTxtPtr);
end;

procedure DisposeMsgHeap(var Msg: FMsgType);
begin
  Dispose(Msg.MsgTxtPtr);
end;

procedure LoadMsg(var Msg: FMsgType; MsgFilePath : PathStr; var Result: byte);

type
  MsgHeaderType =    record
                       HFromUserName : array[1..36] of char;
                       HToUserName   : array[1..36] of char;
                       HSubject      : array[1..72] of char;
                       HDateTime     : array[1..20] of char;
                       HTimesRead    : word;
                       HDestNode     : word;
                       HOrigNode     : word;
                       HCost         : word;
                       HOrigNet      : word;
                       HDestNet      : word;
                       HFiller       : array[1..8] of char;
                       HReplyto      : word;
                       HAttribute    : word;
                       HNextReply    : word;
                      end;
var
  i : word;
  ReadResult : word;
  MsgFile : file;
  MsgHead : MsgHeaderType;
begin
  assign(MsgFile,MsgFilePath);
  {$I-}
  reset(MsgFile,1);
  {$I+}
  Result := IoResult;
  if result>0 then exit;
  fillchar(MsgHead,SizeOf(MsgHead),#00);
  fillchar(Msg.MsgTxtPtr^,MsgSize,#00);
  BlockRead(MsgFile,MsgHead,Sizeof(MsgHead));           {Read Header Info}
  BlockRead(MsgFile,Msg.MsgTxtPtr^,MsgSize,ReadResult); {Read Msg Text}
  If ReadResult = MsgSize then
  begin
    result := 255; {Msg > MsgSize}
    exit;
  end;
  with Msg, MsgHead do
  begin
    for i := 1 to 36 do
    begin
      if HFromUserName[i] = #00 then
      begin;
        FromUserName[0] := chr(i-1);
        i := 36;
      end;
      FromUserName[i] := HFromUserName[i];
    end;
    for i := 1 to 36 do
    begin
      if HToUserName[i]   = #00 then
      begin
        ToUserName[0] := chr(i-1);
        i := 36;
      end;
      ToUserName[i] := HToUserName[i];
    end;
    for i := 1 to 72 do
    begin
      if HSubject[i] = #00 then
      begin
        Subject[0] := chr(i-1);
        i := 72;
      end;
      Subject[i] := HSubject[i];
    end;
    for i := 1 to 20 do
    begin
      if HDateTime[i] = #00 then
      begin
        DateTime[0] := chr(i-1);
        i := 20;
      end;
      DateTime[i] := HDateTime[i];
    end;
    Destination.Zone := 1;
    Destination.Node := HDestNode;
    Destination.Net  := HDestNet;
    Destination.Point := 0;
    Origin.Zone := 1;
    Origin.Node      := HOrigNode;
    Origin.Net       := HOrigNet;
    Origin.Point := 0;
    NextReply        := HNextReply;
  end;
  close(MsgFile);
end;
end.

{ --------------------   DEMO PROGRAM --------------------- }

program DELMSGBY; { A program to kill all FIDOnet messages by a
                    certain person }

{$M 16384,0,65536}

uses dos,fidomsg;

var foo      :byte;
    nametodel:string;
    msg      :FMsgType;
    s        :searchrec;

function upstr(st:string):string;                { string processor that   }
var a:string;                                    { makes all uppercase and }
begin                                            { removes spaces          }
   a:='';
   for foo:=1 to length(st) do
   begin
      If st[foo]<>#32 then a:=a+upcase(st[foo]);
   end;
   upstr:=a;
end;

begin
   if paramcount<1 then          { If they don't know how to use this, then }
   begin
      writeln;
      writeln(' Usage: DELMSGBY [firstname] [lastname]');   { Tell them     }
      writeln;
   end
   else                       { Otherwise, they DO know how to use this, so }
   begin
      nametodel:='';
      for foo:=1 to paramcount do          { Get the name they don't like}         nametodel:=nametodel+' '+paramstr(foo);
      findfirst('*.MSG',Anyfile,s);        { And search all .MSG files for it}      while (DosError=0) do                { If a file is found then}      begin
         GetMsgHeap(msg);                     { Make space on the heap for it}         loadmsg(msg,fexpand(s.name),foo);    { Load it }
         If (upstr(msg.FromUserName)=upstr(nametodel)) then
         begin                           { If the message if from the bad guy}            swapvectors;                 {     then delete it. I used EXEC so}            exec(getenv('COMSPEC'),' /C '+'Del '+fexpand(s.name)); { you can}            swapvectors;                 { easily move, or rename it.}            writeln('Deleting '+fexpand(s.name)+'. It''s Contaminated!');
         end;
         DisposeMsgHeap(msg);            { Done w/ that message, so take back}         findnext(s);                    { the heap space. Then find another}      end;                               { Message to check. }
   end;
end.

{ ---------------------------   DEMO PROGRAM ----------------------------}

{this is a stand alone *.msg reader}
uses dos,crt;
Type FidoHeader=record {structure of the Message Header}
        WhoTheMessageIsFrom,
        WhoTheMessageItTo   : Array[1..36] of Char; {ASCIIZ Strings}
        MessageSubject      : Array[1..72] of Char;
        MessageDate         : Array[1..20] of Char;
                {The Message Date is an ASCIIZ string following this
                format: DD MMM YY  HH:MM:SS<Null>-20 Characters Total
                Example: 01 Jun 94 20:00:00 is June 1st 1994 at 8:00PM
                But SeaDog uses a slightly different version and you
                might want to account for that, unfortunately I can't
                remember the exact format, also SLMAIL for SearchLight
                BBS only puts one space between the year and the hour
                even though it's supposed to be 2, I'm surprised this
                hasn't thrown mailers of other BBS programs}
        TimesTheMessageWasRead,
        DestinationNode,
        OriginalNode,
        CostofTheMessage,
        OriginalNet,
        DestinationNet      : Integer;
                {Note: TimesTheMessageWasRead & CostofTheMessage are
                usually ignored when being exported from the BBS and can
                be ignored when importing into a BBS}
        DateWritten,
        DateArrived         : LongInt;
                {I'm not sure how the dates are stored in here, but
                they're usually ignored}
        MessageToWhichThisRepliesTo: Integer;{Irrevelant over a network}
        Arrtibutes          : Word;
                {Bit Field:
                    Bit 0 Private Message
                        1 Crashmail
                        2 Message Was Read
                        3 Message Was Sent
                        4 File Attatched, Filename in subject
                        5 Forwarded Message
                        6 Orphan Message ???
                        7 Kill After Its Sent (I think)
                        8 Message Originated Here (local)
                        9 Hold
                        10 Reserved
                        11 File Request, Filenames in Subject
                        12 Return Receipt Requested
                        13 This message is a Return Receipt
                        14 Audit Trail Requested
                        15 Update Request }
        UnReply             : Integer; {I have No Idea}
End;

Type FidoMsg=record
   msgchar : char;
end;

{The Message Text follows terminated by either a Null (#0) or to Cr's #13#13.
Also all paragraphs are supposed to end with a Hard CR (#141) and you can
ignoreany #13 and reformat the text for your own program, also any lines
starting with^A (#1) should not be imported into the BBS, they are control
lines... thecontents of these lines varies so you'll have to find out that on
your own }
var
  header : fidoheader;
  headerf: file of fidoheader;
  MsgTxt : FidoMsg;
  MsgTxtf: file of FidoMsg;
  DirInfo: SearchRec;
  ch,cx : char;
  cr,count : shortint;
  i:byte;
  l : string;
  s : string;
  howlong : byte;
begin
  FindFirst('*.MSG', Archive, DirInfo);
  while DosError = 0 do
  begin
    window(1,1,80,25);
    clrscr;
    textcolor(lightgreen);
    WriteLn(DirInfo.Name);
    textcolor(green);
    assign(headerf,DirInfo.Name);
    reset(headerf);
    read(headerf,header);
    with header do
    begin
        Writeln('From:  ',WhoTheMessageIsFrom);
        Writeln('To  :  ',WhoTheMessageItTo);
        Writeln('Subj:  ',MessageSubject);
        Writeln('Date:  ',MessageDate);
    end;
    textcolor(white);
Writeln('═════════════════════════════════════════════════════════════════════
═ ══════');    window(1,wherey,80,25);
    textcolor(cyan);
    close(headerf);
    assign(MsgTxtF,DirInfo.Name);
    reset(MsgTxtF);
    seek(MsgTxtF,sizeof(header));
    cr := 0;
    count := 0;
    l := '';
    repeat
      read(MsgTxtF,MsgTxt);
      ch := MsgTxt.msgchar;
      if not (ch in [#10,#13]) then
      begin
        l := l + ch;
        howlong := length(l);
      end;
      if keypressed then
      begin
        cx := readkey;
        if cx = #27 then halt;
      end;
      if length(l) > 78 then
      begin
        count := length(l);
        while (count > 60) and (l[count] <> ' ') do dec(count);
        writeln(l,copy(l,1,count));
        delete(l,count,length(l));
      end;
      if ch = #13 then
      begin
        writeln(l);
        l := '';
        howlong := 0;
      end;
      if pos('these things?',l) > 0 then
      begin
        write
      end;
      if wherey > 15 then
      begin
        textcolor(12);
        writeln;

        write('Press enter: ');
        readln;

        clrscr;
        textcolor(cyan);
      end;

    until eof(MsgTxtF) or (ioresult > 0);
    if l > '' then
    begin
      writeln(l);
      l := '';
    end;
    textcolor(11);
    write('End of Msg: ');
    textcolor(7);
    cx := readkey;
    if cx = #27 then halt;
    clrscr;
    FindNext(DirInfo);
  end;
  textcolor(7);
end.

end.

