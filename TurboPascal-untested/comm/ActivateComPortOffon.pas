(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0101.PAS
  Description: Activate COM Port Off/On
  Author: BRIAN LEITHER
  Date: 05-31-96  09:17
*)

{BFCOM (C) 1995 Brian Leiter, All Rights Reserved}
{12-07-95}  {No Error Checking}

Program BFCOM;

Uses CRT,Cursor2;

Var CH        : Char;
    L,I       : Integer;
    Param,Num : String;

Const Version='v1.2';

Procedure Error;
Begin
  Textcolor(7);Textbackground(0);
  Clrscr;
  Writeln('BFCOM ',Version,' (C) 1995 Brian Leiter, All Rights Reserved');
  Writeln('');
  Writeln('Usage:   BFCOM [Comport] [ON or OFF]');
  Writeln('');
  Writeln('Example: BFCOM 2 OFF     <-- Takes modem off-hook');
  Writeln('         BFCOM 2 ON      <-- Puts modem on-hook');
  Writeln('');
  Writeln('         BFCOM 2 OFF /S  <-- Silent Mode, No BELLS');
  CursorSmall;
  Halt(0);
  Exit;
End;

Function Dial(NB:String; ComPort:Byte):Char;
Const  DialCmd = 'AT';
       OnHook  = 'ATH';
       CR      =  #13;
       Status  =  5;
Var    UserKey : Char;
       PortAdr : Word;

Procedure Com_Write(S: String);
Var I : Byte;

Function OutputOk : Boolean;
Begin
  OutPutOk:=(Port[PortAdr+Status] and $20) > 0;
End;

Procedure ComWriteCh(Var CH: Char);
Begin
  Repeat Until OutPutOk;
  Port[PortAdr]:=Byte(CH);
End;

Begin
  For I:=1 To Length(S) Do ComWriteCh(S[I]);
End;

Procedure Com_Writeln(S: String);
Begin
  Com_Write(S+CR)
End;

{DIAL}
Begin
  If (ComPort<1) or (ComPort>4) Then Error;
  PortAdr:=MemW[$40:(ComPort-1)*2];
  If PortAdr=0 Then Error;
  Com_Writeln(OnHook);
  Delay(500);
  Com_Write(DialCmd);
  Com_Writeln(NB);
End;

Begin {THE PROGRAM}
  ClrScr;
  CursorOff;
  If (ParamStr(1)>'4') or (ParamStr(1)<'1') Then Error;
  Param:=Paramstr(2);
  L:=Length(Param);
  For I:=1 To L Do Param[I]:=Upcase(Param[I]);
  If Param='OFF' Then
  Begin
    Num:='H1M0';
    Clrscr;
    Gotoxy(20,8);
    Textcolor(9);Textbackground(1);Write('█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█');
    Textcolor(1);Textbackground(0);Writeln('▄');
    Gotoxy(20,9);
    Textcolor(9);Textbackground(1);Write('█ ');
    Textcolor(14);Textbackground(0);Write(' BFCOM - (C) 1995 Brian Leiter ');
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Writeln('█ ');
    Gotoxy(20,10);
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Write('█ ');
    Textcolor(9);Textbackground(0);Write('                              █');
    Textcolor(1);Textbackground(0);Writeln('█ ');
    Gotoxy(20,11);
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Write('█ ');
    Textcolor(15);Textbackground(0);Write('Taking Modem Off-Hook:        ');
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Writeln('█');
    Gotoxy(20,12);
    Textcolor(9);Textbackground(0);Write('▀');
    Textcolor(9);Textbackground(1);Write('▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀');
    Textcolor(1);Textbackground(0);Writeln('█');
  End;
  If Param='ON' Then
  Begin
    Num:='H0M1';
    Clrscr;
    Gotoxy(20,8);
    Textcolor(9);Textbackground(1);Write('█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█');
    Textcolor(1);Textbackground(0);Writeln('▄');
    Gotoxy(20,9);
    Textcolor(9);Textbackground(1);Write('█ ');
    Textcolor(14);Textbackground(0);Write(' BFCOM - (C) 1995 Brian Leiter ');
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Writeln('█ ');
    Gotoxy(20,10);
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Write('█ ');
    Textcolor(9);Textbackground(0);Write('                              █');
    Textcolor(1);Textbackground(0);Writeln('█ ');
    Gotoxy(20,11);
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Write('█ ');
    Textcolor(15);Textbackground(0);Write('Putting Modem On-Hook:        ');
    Textcolor(9);Textbackground(0);Write('█');
    Textcolor(1);Textbackground(0);Writeln('█');
    Gotoxy(20,12);
    Textcolor(9);Textbackground(0);Write('▀');
    Textcolor(9);Textbackground(1);Write('▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀');
    Textcolor(1);Textbackground(0);Writeln('█');
  End;
  {ACTUAL PROGRAM}
  If ParamStr(1)='1' Then CH:=Dial(Num,1);
  If ParamStr(1)='2' Then CH:=Dial(Num,2);
  If ParamStr(1)='3' Then CH:=Dial(Num,3);
  If ParamStr(1)='4' Then CH:=Dial(Num,4);
  Delay(2000);
  If (ParamStr(3)<>'/S') and (ParamStr(3)<>'/s') Then
  Begin
    Sound(900);Delay(150);
    Sound(700);Delay(50);
    Sound(900);Delay(150);
    Sound(700);Delay(50);
    Sound(900);Delay(150);
    Sound(700);Delay(50);
    NoSound;
  End;
  If Param='OFF' Then Textcolor(12);
  If Param='ON' Then Textcolor(10);
  Gotoxy(48,11);
  Writeln('DONE');
  Delay(1500);
  CursorSmall;
  Clrscr;
End.

