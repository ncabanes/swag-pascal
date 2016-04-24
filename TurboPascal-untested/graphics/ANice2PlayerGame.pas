(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0268.PAS
  Description: A nice 2 player game
  Author: BOSTJAN GABROVSEK
  Date: 08-30-97  10:08
*)

{If you have any questions please send me mail at OleRom@hotmail.com}
{player 1 keys:
  up, down, right, left (down=fire)
 player 2 keys:
 A,S,D,W (S=fire)}
{$M 2000,2000,20000}
{$R-,S-,I-,D-,F+,V-,B-,N-,L+}
Program BalMan;
Uses DOS, Graph, Crt;
Label NewGame, Konec;
Const Time = 0; {Delay}
      HurtDelay = 100;
      HurtTimeOff = 1000;
VAr      S : String[10];
Var Old_Keyb:Pointer;
    Keyz:Set Of 0..127;
Procedure STI;
 Inline($FB);

Procedure CLI;
 Inline($FA);

Procedure CallOld(Sub:Pointer);
 Begin
  Inline($9C/$FF/$5E/$06);
 End;
Procedure OutText(X,Y,Color,BkColor:Byte;S:OpenString);{By OleRom}
Var Chr : Char;
    fo : Byte;
Begin
 For fo := 1 to Ord(S[0]) do
 Begin
  Chr := S[fo];
  asm
    mov ah,02h
    xor bh,bh
    mov dh,[y]
    mov dl,[x]
    int 10h
    mov ah,09h
    mov al,[Chr]
    mov bh,[BkColor]
    mov bl,[Color]
    mov cx,01h
    int 10h
    inc [x]
  end;
 End;
End; {OutText}

Procedure My_Keyb;
 Interrupt;
Var B:Byte;
Begin
 CallOld(Old_Keyb);
 B:=Port[$60];
 If B>=$80 Then
  Keyz:=Keyz-[B And $7F]
 Else
  Keyz:=Keyz+[B];
 STI;
End;
Procedure SetGraph;
{$F+} Function DETECTSvga : Integer; assembler; {$F-} asm mov ax,0000h end;
Var GDr : Integer;
Begin
 GDr := InstallUserDriver('SVGA256',@DETECTSvga);
 GDr := DETECT;
 InitGraph(GDr,GDr,'');
End;
Procedure CleanKeyBuffer; assembler;
asm
 xor ax,ax; mov es,ax
 mov ax,es:[041Ah]; mov es:[041Ch],ax
end;
Var X, Y : Integer;
    Smer : Boolean;
    xx,yy : Integer;
    Ss : Boolean;
    H, Hh : Byte;
    T, Tt : Word;
Begin
 Keyz:=[];
 GetIntVec($09,Old_Keyb);
 SetIntVec($09,@My_Keyb);
NewGame:
 Keyz:=[];
 SetGraph;
 SetViewPort(0,0,geTmAXx,190,False);
 X := 106;
 Y := 170;
 Xx := 213;
 Yy := 170;
 Smer := False;
 Ss := False;
 H := 0;
 hh := 0;
 Tt := 0;
 T := 0;
 SetFillStyle(1,Blue);
 Bar(0,0,GetMAxX,GetMaxY);
 SetFillStyle(1,12);
 Bar(10,192,100-T*10+10,198);
 SetFillStyle(1,14);
 Bar(GetMaxX-10,192,GetMaxX-(100-tT*10+10),198);
Repeat
 If 77 In Keyz Then If X < GetMaxX-20 then Inc(X,2);
 If 75 In Keyz Then If X > 20 then Dec(X,2);
 If 72 In Keyz Then Smer := True;
 If 30 In Keyz Then If Xx > 20 then Dec(xX,2);
 If 32 In Keyz Then If Xx < GetMaxX-20 then Inc(Xx,2);
 If 17 In Keyz Then Ss := True;
 If 80 in Keyz Then If H = 0 then H := 1;
 If 31 in Keyz Then If Hh = 0 then Hh := 1;
 If Hh > 0 then Inc(Hh);
 If H > 0 then Inc(H);
 If H >= HurtTimeOff then H := 0;
 If Hh >= HurtTimeOff then Hh := 0;
 If Smer or (Y <> 170)then
   If Smer then Dec(Y,2) else Inc(Y,2);
 If Ss or (Yy <> 170)then
   If Ss then Dec(Yy,2) else Inc(Yy,2);
 While Y < 20 do Inc(Y);
 While Yy < 20 do Inc(Yy);
  Smer := False;
  ss := False;
 ClearViewPOrt;
 If (H = 0) or (H > HurtDelay) then SetColor(4) else SetColor(15);
 SetFillStyle(1,12);
 FillEllipse(X,Y,20,Round(20/1.20));
 If (Hh = 0) or (Hh > HurtDelay) then  SetColor(6) else SetColor(15);
 SetFillStyle(1,14);
 FillEllipse(Xx,Yy,20,Round(20/1.20));
 CleanKeyBuffer;
If (Abs(X-Xx) < 30) and (Abs(Y-Yy) < 30) and
   (HH <= HurtDelay) and (HH > 0) AND
   ( (H > HurtDelay) or (H = 0))THEN
 Begin
 For xX := 1 to 100 do
  Begin
  SetColor(4);
   If ODD(xX) then SetFillStyle(1,12) else SetFillStyle(1,15);
  FillEllipse(X,Y,20,Round(20/1.20));
  Sound(Random(100));
  Delay(10);
  End;
 X := 106;
 Y := 170;
 Xx := 213;
 Yy := 170;
 Smer := False;
 Ss := False;
 H := 0;
 hh := 0;
 Inc(T);
 SetFillStyle(1,Red);
 Bar(10,192,110,198);
 SetFillStyle(1,12);
 Bar(10,192,100-T*10+10,198);
End;
CleanKeyBuffer;
If (Abs(X-Xx) < 30) and (Abs(Y-Yy) < 30) and
   (H <= HurtDelay) and (H > 0) AND
   ( (hH > HurtDelay) or (hH = 0))THEN
 Begin
 For X := 1 to 100 do
  Begin
  SetColor(6);
   If ODD(X) then SetFillStyle(1,14) else SetFillStyle(1,15);
  FillEllipse(Xx,Yy,20,Round(20/1.20));
  Sound(Random(100));
  Delay(10);
  End;
 X := 106;
 Y := 170;
 Xx := 213;
 Yy := 170;
 Smer := False;
 Ss := False;
 H := 0;
 hh := 0;
 Inc(Tt);
 SetFillStyle(1,Brown);
 Bar(GetMaxX-10,192,GetMaxX-110,198);
 SetFillStyle(1,14);
 Bar(GetMaxX-10,192,GetMaxX-(100-tT*10+10),198);
 End;
 nOsoUND;
Until (Port[$60] = 1) or (T >= 10) or (Tt >= 10);
ClearDevice;
If Port[$60] =  1 then Goto Konec;
If Tt >= 10 then OutText(7,12,LightRed,0,' Red ball is the winner!');
If t >= 10 then OutText(7,12,Yellow,0,   'Yellow ball is the winner!');
Repeat
 CleanKeyBuffer;
Until Port[$60] = 28;
Goto NewGame;
Konec:
asm
 mov ax,3
 int 10h
end;
SetIntVec($09,@Old_Keyb);
WriteLn('Game by Bostjan Gabrovsek.');
End.
