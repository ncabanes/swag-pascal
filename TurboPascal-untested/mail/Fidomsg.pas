(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0019.PAS
  Description: Fidomsg.pas
  Author: WAYNE BOYD
  Date: 08-24-94  13:37
*)

{
Someone once posted a message with the header formats for Fido-style *.MSGs. I
took that original message and added to it to get the following program. This
program reads *.MSG files sequentially in your *.MSG directory. You can alter
the program to do whatever you want.
}
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
ignore any #13 and reformat the text for your own program, also any lines
starting with ^A (#1) should not be imported into the BBS, they are control
lines... the contents of these lines varies so you'll have to find out that on
your own }

var
  header : fidoheader;
  headerf: file of fidoheader;
  MsgTxt : FidoMsg;
  MsgTxtf: file of FidoMsg;
  DirInfo: SearchRec;
  ch : char;
  cr,count : shortint;
  l : string;
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
    Writeln('═══════════════════════════════════════════════════
════════════════════════');
    window(1,wherey,80,25);
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
      (*
      if wherey > 15 then
      begin
        textcolor(12);
        writeln;
        {
        write('Press enter: ');
        readln;
        }
        clrscr;
        textcolor(cyan);
      end;
      *)
    until eof(MsgTxtF) or (ioresult > 0);
    if l > '' then
    begin
      writeln(l);
      l := '';
    end;
    textcolor(11);
    write('End of Msg: ');
    textcolor(7);
    readln;
    clrscr;
    FindNext(DirInfo);
  end;
  textcolor(7);
end.

end.


