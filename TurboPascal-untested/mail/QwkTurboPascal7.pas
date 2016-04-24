(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0034.PAS
  Description: Re: QWK & Turbo Pascal 7
  Author: PAUL M. GOORSKIS
  Date: 02-21-96  21:04
*)

{P
 MM> QWK:
 MM> Can anybody write for me or send me a unit that reads QWK packets???

I've wrote my one:
NOTE: Here some bugs can be found.Report me as soon as you check that.

---8<--- Begin QWKUSE.PAS ---8<--- }

Unit QWKUse;

Interface

USES DOS,CRT;

Type QWKHead=Record
     NOM :ARRAY [0..6] Of Char;
     Date:ARRAY [7..$e] Of Char;
     Time:ARRAY [$f..$13] Of Char;
     to_:ARRAY [$14..$2c] Of Char;
     From:ARRAY [$2d..$45] Of Char;
     Subj:ARRAY [$46..$6a] Of Char;
     NOR :ARRAY [$6b..$72] Of Char;
     NOMB:ARRAY [$73..$78] Of Char;
     Res :ARRAY [$79..$7e] Of Char;
     End;
     MessageBlock=Array[1..128] Of CHAR;

CONST CrLf=#13#10;

Function GetMessageLength(msg:QWKHead):BYte;
Procedure GetMessageTime(msg:QWKHead;Var Hour,Minute:Byte);
Procedure GetMessageDate(msg:QWKHead;Var DD,MM,YY:Word);
Function MessageNumber(msg:QWKHead):Word;
Function  NumberOfReplay(msg:QWKHead):WORd;
Function  Replay(msg:QWKHead):Boolean;
Procedure NormalCrLf(Var s:String);
Procedure DelChr(c:Char;S:String);

Implementation

Procedure DelChr;
Var a:Byte;
Begin
For a:=1 To Length(s) Do If s[a]=c Then Begin Delete(s,a,1);Dec(a);End;
End;

Function GetMessageLength;
Var s:String;
    c:Integer;
    len:Byte;
Begin
s:='';
s:=s+msg.nomb;
DelChr(' ',s);
Val(s,len,c);
Dec(Len);
GetMessageLength:=len;
End;

Procedure GetMessageTime(msg:QWKHead;Var Hour,Minute:Byte);
Var s,s1:String;
    c:INteger;
Begin
s1:='';s1:=s1+msg.time;
s:=Copy(s1,1,2);
Delete(s1,1,3);
Val(s,hour,c);
Val(s1,Minute,c);
End;

Procedure GetMessageDate(msg:QWKHead;Var DD,MM,YY:Word);
VAR s,s1:String;
    c:INteger;
Begin
s1:='';s1:=s1+msg.date;
s:=Copy(s1,1,2);
Delete(s1,1,3);
Val(s,mm,c);
s:=Copy(s1,1,2);
Delete(s1,1,3);
Val(s,dd,c);
Val(s1,yy,c);
End;

Function  MessageNumber(msg:QWKHead):Word;
Var s:String;
    w:Word;
    c:Integer;
Begin
s:=msg.nom;
DelChr(' ',s);
Val(s,w,c);
MessageNumber:=w;
End;

Function  NumberOfReplay(msg:QWKHead):WORd;
Var s:String;
    w:Word;
    c:Integer;
Begin
s:=msg.nor;
DelChr(' ',s);
Val(s,w,c);
NumberOfReplay:=w;
End;

Function  Replay(msg:QWKHead):Boolean;
Begin
Replay:=NumberOfReplay(msg)<>0;
End;

Procedure NormalCrLf(Var s:String);
Var b,a:Byte;
BEgin
b:=Pos('',s);
While b<>0 Do Begin Delete(s,b,1);Insert(crlf,s,b);b:=Pos('',s);End;
End;

End. ---8<---  End QWKUSE.PAS  ---8<---

And here is example of usage:

---8<--- Begin QWKPMG.PAS ---8<---
Program QWK_PMG;
Uses CRT,Objects,PMG_Str1,QWKuse;

Const box:Array [1..5] Of String=(
      'From:',
      'To  :',
      'Subj:',
      'Date:',
      'Time:');

VAR Mes:Array [1..700] OF PString;
    MsgPtr:Array [1..100,1..2] Of LongINT;
    f2,f1:File;
    current,Total:Word;
    Header:QWKHEAD;
    a:Integer;
    c:Char;

Function FillStr(c:Char;a:Byte);
Var S:String;
    b:Byte;
Begin
s:='';
For b:=1 To a s:=s+c;
FillStr:=s;
End;

Procedure Draw;
Var fields:Array [1..5] Of String;
    a:Byte;
Begin
Fields[1]:=''+Header.from;
Fields[2]:=''+Header.To_;
Fields[3]:=''+Header.Subj;
Fields[4]:=''+Header.Date;
Fields[5]:=''+Header.Time;
TextColor(Cyan);
For a:=1 To 5 Do WriteLn(box[a]);
TextColor(Red);GotoXY(40,1);Write('Message ');
TextColor(White);Write(Current);TextColor(red);
Write(' of ');TextColor(White);Write(TOtal);
TextBackGround(White);TextColor(Black);GotoXy(1,25);
Write('"+" - next message  "-" - previouse message.',FillStr(' ',35));
TextBackGround(Black);
TextColor(LightGreen);
For a:=1 To 5 Do
    Begin
    GotoXY(6,a);Write(fields[a]);
    End;
TextColor(White);WriteLn(Crlf,FillSTR('─',79),CrLf);
End;

Procedure ReadMsg(n:LongInt);
Var b,a:Byte;
    CurMsgPtr:LongInt;
    MsgBuf:MESsageBlock;
    s:String;
Begin
Current:=n;
Seek(f1,MSgPtr[n,2]);
BlockRead(f1,Header,SizeOf(Header));
ClrScr;
Draw;
b:=0;
FOR a:=1 To GetMessageLength(Header) Do
    BEGin
    BlockRead(f1,MsgBuf,128);
    s:='';s:=s+MsgBuf;
    NormalCrLf(s);
    While (Pos(CrLf,s)<>0) Or (s<>'') Do
          BEGin
               Inc(b);
               DisposeStr(MES[b]);
               While Pos(CrLf,s)=1 Do Delete(s,1,2);
               If Length(s)=0 Then s:=' ';
               If Pos(CrLf,s)<>0 Then Mes[b]:=NewStr( Copy(s,1,Pos(CrLf,s)-1)
)               Else Mes[b]:=NewStr(s);
               If pos('>',Mes[b]^)<>0 Then TextColor(LightGray) Else
TextColor(Cyan);               IF Pos(CrLf,s)<>0 Then WriteLn(Mes[b]^) Else
Write(Mes[b]^) ;               If WhereY>22 Then
                  Begin
                       GotoXY(1,WhereY+1);
                       Write('Press any key to continue ...');
                       ReadKEY;
                       ClrScr;
                       Draw;
                  End;
               If Pos(CrLf,s)<>0 Then Delete(s,1,Pos(CrLf,s)+1) Else s:='';

          End;

    End;
End;

Procedure InitPStrings;
Var a:Word;
    s:String;
Begin
s:=FillSTR(' ',128);
For a:=1 To 700 DO Mes[a]:=NewStr(s);
End;

Procedure InitMsgBase;
Var a:word;
Begin
Seek(f1,$81);
a:=1;
While Not Eof(f1) Do
      Begin
           MsgPtr[a,2]:=FilePos(f1);
           BlockRead(f1,Header,SizeOf(Header));
           MsgPTR[a,1]:=MessageNumber(Header);
           Seek(f1,Filepos(f1)+128*GetMessageLength(Header)+1);
           Inc(a);
      End;
Total:=a-1;
END;

Begin
Assign(f1,'messages.dat');
Reset(f1,1);
InitMsgBase;
a:=1;
REpeat
ReadMsg(a);
c:=ReadKey;
If c='+' Then Inc(A);
If c='-' Then Dec(A);
If a<1 Then a:=Total;

if a>Total Then a:=1;

UNTIL c=#27;
End. ---8<---  End QWKPMG.PAS  ---8<---

