{
12 Jan 96 17:12, Mark Tassin wrote to All:
 MT> Can anybody help me find a Documented JAM message base unit for
 MT> TP 7.0? The one in JAMAPI would suffice except that all of the
 MT> functions that you can perform with it are undocumented, thus I
 MT> have to hunt through a slew function calls guessing what values I
 MT> should pass to them... RADU comes with the ability to post to
 MT> Hudson Message bases, but does not claim to support JAM, can
 MT> anybody point me to something that will let me post messages to
 MT> the JAM message base or am I screwed?


MKSM106.LZH    226200  12-22-94  MK Source for Msg Access v1.06 - Mark May's
                                 Pascal OOP source code to access Squish,
                                 Jam, Hudson, *.Msg, and Ezycom message
                                 bases. Great for developing BBS utilities.
                                 (FW)

Get the above archive,and here is
a generic reader that I put together using Mark's units/source...


(*   Generic Message Reader by Martin Woods 1:351/233.1      *)
(* To use this you need MKSM106.LZH , Mark May's OOP library *)
(* which should be availible just about anywhere             *)
(* This program will read the following:                     *)
(*          HUDSON,SQUISH,*.MSG,EZY and JAM                  *)
(*    thanks to Mark May for writing a great Library!        *)

Program Reader;
{$M 16384, 0, 655360}
{$I MKB.Def}

{$X+}

  Uses Crt,MKMsgAbs, MKOpen, MKDos, MKstring;

Var
  MsgOut: AbsMsgPtr;
  TmpStr: String;
  AreaId: String;
  ch:char;
  a,b: integer;
Const
  StLen = 78;

Begin
If (ParamCount < 1) or (ParamStr(1) = '/?') Then
  Begin
  textattr:=$07;
  clrscr;
  writeln;
  textcolor(10);
  writeln('         Generic  READER version 01.0 by Martin Woods,June 1995');
  writeln;
  textcolor(11);
  WriteLn('           Proper syntax is:');
  WriteLn('           READER MsgAreaId');
  WriteLn;
  WriteLn('           Squish MsgAreaId Example = SC:\Max\Msg\Muffin');
  WriteLn('           Hudson MsgAreaId Example = H042C:\RA\MsgBase');
  WriteLn('           *.Msg  MsgAreaId Example = FC:\Mail');
  WriteLn('           Ezy    MsgAreaId Example = E0001C:\Ezy\MsgBase');
  WriteLn('           Jam    MsgAreaId Example = JC:\Msg\General');
  Halt(1);
  End;
AreaId := Upper(ParamStr(1));

If Not OpenMsgArea(MsgOut, AreaId) Then
  Begin
    WriteLn('Unable to open message base');
    Halt(4);
 End;
  textattr:=$07;
  clrscr;
  gotoxy(10,8);
  textcolor(10);
  write('Generic READER version 01.0 by Martin Woods,June 1995 '+#13);
  textcolor(7);
  Delay(1500); {opening screen here}

  MsgOut^.SeekFirst(1);
 While MsgOut^.SeekFound Do
   Begin
     window(1,1,80,25);
     textbackground(0);
     clrscr;
     textcolor(15);
       for a:=1 to 80 do write('─');  { header starts here }
         textcolor(2);
         MsgOut^.MsgStartUp;
         WriteLn(MsgOut^.GetMsgNum);
         Write('Message Number: ' + Long2Str(MsgOut^.GetMsgNum));
           If MsgOut^.IsPriv Then
             Write('  (Priv)');
               If MsgOut^.IsRcvd Then
                 Write(' (Rcvd)');
                 WriteLn;
                 Write('From: ' + PadRight(MsgOut^.GetFrom,' ',45));
                 Write('Date: ');
                 WriteLn(ReformatDate(MsgOut^.GetDate, 'MM/DD/YY')
                 + ' ' + MsgOut^.GetTime);
                 WriteLn('To: ' + MsgOut^.GetTo);
                 Write('Subj: ');
                 WriteLn(MsgOut^.GetSubj);
                 textcolor(15);
                   for a:=1 to 80 do write('─'); { header ends here }
                     window(1,wherey,80,25); {make a window to scroll message}
                     textcolor(7);
                     textbackground(0);
                     clrscr;
                     WriteLn;
                     MsgOut^.MsgTxtStartUp;
              repeat

    TmpStr := MsgOut^.GetString(StLen);
    WriteLn(TmpStr);
    TmpStr := MsgOut^.GetString(StLen);
       if keypressed then
         begin
           ch := readkey;
             if ch = #27 then halt;
          end;
             if ch = #13 then
               begin
                 WriteLn(TmpStr);
              End;
      if wherey > 15 then
        begin
          textcolor(14);
          textbackground(1);
          writeln;
          writeln;
          write(' Esc to Quit  -   Press enter to Continue: '); {status line}
          clreol;
          textattr:=$07;
          ch := readkey;
            if ch = #27 then halt;
              clrscr;
              textcolor(7);
            end;
  until MsgOut^.EOM or (ioresult > 0);
    textcolor(14);
    textbackground(1);
    gotoxy(1,18);  {this is funky,any ideas how to optimize?}
    write(' Esc to Quit  -   Press enter to Continue:                     End
ofMsg: ');clreol; {got word wrapped here}
    ch := readkey;
      if ch = #27 then halt;
        clrscr;
          If Length(TmpStr) > 0 Then
             WriteLn(TmpStr);
               If IoResult <> 0 Then;
                  MsgOut^.SeekNext;
              End;
                 If Not CloseMsgArea(MsgOut) Then;
             End.

