{Here is a unit I wrote for a text game I'm working on... I'd like to know what
everybody thinks about it... All of the drawing routines use a small virtual
page, and some of them don't draw it to the real screen.  You can do that
yourself using DisplayScreen.  I'm gonna squash out a bunch of blank lines to
save space...
{ *********************************************************** }
{ ************************ Text Unit ************************ }
{ *********************************************************** }
{ ***************** Written by: Rick Haines ***************** }
{ ******************Snail-Mail: 1004 N. Alabama Ave. ******** }
{ ***************************** DeLand, FL 32724 ************ }
{ ***************** E-Mail: Keiichi@Dynasty.doi.com ********* }
{ *********************************************************** }
{ ****************** Last Revised 10/03/95 ****************** }
{ *********************************************************** }
{ ************** Copyright (C) 1995 Rick Haines ************* }
{ *********************************************************** }
{ ******** You may use this code in any way you wish ******** }
{ * I only "request" that you give me credit for writing it * }
{ *********************************************************** }

{$IfDef Debug }
 {$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$Else}
 {$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y-}
{$EndIf}

Unit Text;

Interface

Const
 ScrlL = 1;
 NumL  = 2;
 CapsL = 4;
Const
 Black   = 0;
 Blue    = 1;
 Green   = 2;
 Cyan    = 3;
 Red     = 4;
 Violet  = 5;
 Orange  = 6;
 Gray    = 8;
 LGray   = 7;
 LBlue   = 9;
 LGreen  = 10;
 LCyan   = 11;
 LRed    = 12;
 LViolet = 13;
 Yellow  = 14;
 White   = 15;
 Blink   = 128;
Type
 TBoxDef = Record
   VLine, HLine,
   X1Y1, X1Y2,
   X2Y1, X2Y2: Char;
  End;
Const
 SingleLine: TBoxDef =
  (VLine:#179; HLine:#196;
   X1Y1:#218; X1Y2:#192;
   X2Y1:#191; X2Y2:#217);
 DoubleLine: TBoxDef =
  (VLine:#186; HLine:#205;
   X1Y1:#201; X1Y2:#200;
   X2Y1:#187; X2Y2:#188);
 SingleTop: TBoxDef =
  (VLine:#186; HLine:#196;
   X1Y1:#214; X1Y2:#211;
   X2Y1:#183; X2Y2:#189);
 DoubleTop: TBoxDef =
  (VLine:#179; HLine:#205;
   X1Y1:#213; X1Y2:#212;
   X2Y1:#184; X2Y2:#190);
Procedure KeyBReset;
Procedure KeyBEnable;
Procedure KeyBDisable;
Procedure SetLeds(Leds: Byte);
Procedure SetLocks(Locks: Byte);
Procedure ClearLocks(Locks: Byte);
Procedure ToggleLocks(Locks: Byte);
Procedure ClearKeyBuf;
Function  GetKey: Char;
Function  ReadKey: Char;
Procedure PutKey(Key: Char);
Function  GetScanCode: Byte;
Function  ReadScanCode: Byte;
Function  KeyPressed: Boolean;

Procedure HideCursor;
Procedure ShowCursor;
Procedure DisplayScreen;
Procedure ClearScreen;
Procedure ClearArea(X1, Y1, X2, Y2: Byte);

Procedure SetColor(Color: Byte);
Procedure SetBGColor(Color: Byte);

Procedure WriteCharXY(X, Y: Byte; AChar: Char);
Procedure WriteStrXY(X, Y: Byte; TextStr: String);
Procedure TWrite(AString: String);
Procedure TWriteln(AString: String);
Procedure SDown(NumOfLines: Byte);

Function GetX: Byte;
Function GetY: Byte;
Procedure CursorXY(X, Y: Byte);

Procedure DrawHLine(X, Y, Length: Byte; AChar: Char);
Procedure DrawVLine(X, Y, Length: Byte; AChar: Char);
Procedure DrawBox(X1, Y1, X2, Y2: Byte; Border: TBoxDef);
Procedure OpenBox(X1, Y1, X2, Y2: Byte; Border: TBoxDef);
Procedure CloseBox(X1, Y1, X2, Y2: Byte; Border: TBoxDef);

Procedure SaveScreen(Name: String);
Procedure LoadScreen(Name: String);

Implementation

Var
 ExitSave,
 Screen: Pointer;
 TextSeg: Word;
 CursorX,
 CursorY: Byte;
 TextColor,
 LastMode: Byte;
Const
 VRTPort = $03DA;
Procedure ScrollUp; Assembler;
 Asm
  ClD
  Push ds
  Les di, Screen
  Lds si, Screen
  Add si, 160
  Mov cx, 2000-80
  Rep MovSW
  Mov ax, 0
  Mov cx, 80
  Rep StoSW
  Pop ds
 End;
Procedure ScrollDown; Assembler;
 Asm
  StD
  Push ds
  Les di, Screen
  Lds si, Screen
  Add di, 4000
  Add si, 4000-160
  Mov cx, 2000-79
  Rep MovSW
  Mov ax, 0
  Mov cx, 80
  Rep StoSW
  Pop ds
  ClD
 End;
Procedure H_CursorXY(X, Y: Byte); Assembler;
 Asm
  Mov dh, Y
  Mov dl, X
  Mov ah, 02h
  Xor bh, bh
  Int 10h
 End;
Procedure KeyBReset; Assembler;
 Asm
  Mov dx, 60h
  Mov al, 0FFh
  Out dx, al
  Jmp @@Delay
 @@Delay:
 End;
Procedure KeyBEnable; Assembler;
 Asm
  Mov dx, 60h
  Mov al, 0F4h
  Out dx, al
  Jmp @@Delay
 @@Delay:
 End;
Procedure KeyBDisable; Assembler;
 Asm
  Mov dx, 60h
  Mov al, 0F5h
  Out dx, al
  Jmp @@Delay
 @@Delay:
 End;
Procedure SetLeds(Leds: Byte); Assembler;
 Asm
  Mov dx, 60h
  Mov al, 0EDh
  Out dx, al
  Jmp @@LightLeds
 @@LightLeds:
  Mov al, Leds
  Out dx, al
 End;
Procedure SetLocks(Locks: Byte); Assembler;
 Asm
  Mov ax, 40h
  Mov es, ax
  Mov bx, 17h
  Mov ah, es:[bx]
  Mov al, Locks
  Mov cl, 4
  ShL al, cl
  Or ah, al
  Mov es:[bx], ah
 End;
Procedure ClearLocks(Locks: Byte); Assembler;
 Asm
  Mov ax, 40h
  Mov es, ax
  Mov bx, 17h
  Mov ah, es:[bx]
  Mov al, Locks
  Mov cl, 4
  ShL al, cl
  Not al
  And ah, al
  Mov es:[bx], ah
 End;
Procedure ToggleLocks(Locks: Byte); Assembler;
 Asm
  Mov ax, 40h
  Mov es, ax
  Mov bx, 17h
  Mov ah, es:[bx]
  Mov al, Locks
  Mov cl, 4
  ShL al, cl
  Xor ah, al
  Mov es:[bx], ah
 End;
Procedure ClearKeyBuf; Assembler;
 Asm
  Mov ax, 0C02h
  Int 21h
 End;
Function GetKey: Char; Assembler;
 Asm
  Mov ah, 1
  Int 16h
 End;
Function ReadKey: Char; Assembler;
 Asm
  Mov ax, 0
  Int 16h
 End;
Procedure PutKey(Key: Char); Assembler;
 Asm
  Mov ah, 05h
  Mov cl, Key
  Xor ch, ch
  Int 16h
 End;
Function GetScanCode: Byte; Assembler;
 Asm
  Mov ah, 1
  Int 16h
  Mov al, ah
 End;
Function ReadScanCode: Byte; Assembler;
 Asm
  Mov ax, 0
  Int 16h
  Mov al, ah
 End;
Function KeyPressed: Boolean; Assembler;
 Asm
  Mov ah, 01
  Int 16h
  JNZ @@Key
  Xor ax, ax
  Jmp @@Done
 @@Key:
  Mov ax, 01h
 @@Done:
 End;
Procedure HideCursor; Assembler;
 Asm
  Mov ah, 01h
  Mov cx, 2000h
  Int 10h
 End;
Procedure ShowCursor; Assembler;
 Asm
  Mov ah, 01h
  Mov cx, 0607h
  Int 10h
 End;
Procedure DisplayScreen; Assembler;
 Asm
  ClD
  Push ds
  Mov di, TextSeg
  Mov es, di
  Xor di, di
  Lds si, Screen
  Mov cx, 2000
{ Wait for Vertical Retrace (So we don't shear) }
  Mov  dx, VRTPort
 @@VRT:
  In al, dx
  Test al, 8
  JNZ @@VRT   { If VRT in progress, wait for it to stop }
 @@NoVRT:
  In al, dx
  Test al, 8
  JZ @@NoVRT  { Wait for next VRT }
{ Copy the Screen }
  Rep MovSW
  Pop ds
 End;
Procedure ClearScreen; Assembler;
 Asm
  ClD
  Les di, Screen
  Xor ax, ax
  Mov ah, TextColor
  Mov cx, 2000
  Rep StoSW
 End;
Procedure ClearArea(X1, Y1, X2, Y2: Byte); Assembler;
 Asm
  ClD
  Les di, Screen
{ Get Offset in Video Mem }
  Xor ax, ax   { Offset = (Y * 180) + (X * 2) }
  Mov al, Y1
  Mov cl, 7
  ShL ax, cl   { = (Y * 128) }
  Mov bx, ax
  ShR ax, 1    { + (Y *  32) }
  ShR ax, 1
  Add ax, bx
  Xor bx, bx
  Mov bl, X1
  ShL bx, 1    { + (X * 2) }
  Add ax, bx
  Add di, ax
{ Get X and Y Lengths }
  Mov bl, X2
  Sub bl, X1
  Mov bh, Y2
  Sub bh, Y1
  Add bx, 0101h
{ Get # to add for next line }
  Xor dx, dx
  Mov dl, 80
  Sub dl, bl
  ShL dl, 1
{ Clear Area }
  Xor cx, cx
  Xor ax, ax
  Mov ah, TextColor
 @@YLoop:
  Mov cl, bl
  Rep StoSW
  Add di, dx
  Dec bh
  JNZ @@YLoop
 End;
Procedure SetColor(Color: Byte);
 Begin
  TextColor := (TextColor And $70) Or Color;
 End;
Procedure SetBGColor(Color: Byte);
 Begin
  If Color > 8 Then Exit;
  TextColor := (TextColor And $8F) Or (Color ShL 4);
 End;
Procedure WriteCharXY(X, Y: Byte; AChar: Char); Assembler;
 Asm
  Les di, Screen
{ Get Offset in Video Mem }
  Xor ax, ax   { Offset = (Y * 180) + (X * 2) }
  Mov al, Y
  Mov cl, 7
  ShL ax, cl   { = (Y * 128) }
  Mov bx, ax
  ShR ax, 1    { + (Y *  32) }
  ShR ax, 1
  Add ax, bx
  Xor bx, bx
  Mov bl, X
  ShL bx, 1    { + (X * 2) }
  Add ax, bx
  Add di, ax
{ Write String }
  Mov ah, TextColor     { ah = TextColor, al = Char }
  Mov al, AChar
  Mov es:[di], ax
 End;
Procedure WriteStrXY(X, Y: Byte; TextStr: String); Assembler;
 Asm
  Les di, Screen
{ Get Offset in Video Mem }
  Xor ax, ax   { Offset = (Y * 180) + (X * 2) }
  Mov al, Y
  Mov cl, 7
  ShL ax, cl   { = (Y * 128) }
  Mov bx, ax
  ShR ax, 1    { + (Y *  32) }
  ShR ax, 1
  Add ax, bx
  Xor bx, bx
  Mov bl, X
  ShL bx, 1    { + (X * 2) }
  Add ax, bx
  Add di, ax
{ Write String }
  Push ds
  Mov ah, TextColor     { ah = TextColor, al = Char }
  Lds si, TextStr       { will be reversed when written to mem }
  Xor cx, cx
  Mov cl, [si]
  Inc si
 @@Repeat:
  Mov al, [si]
  Mov es:[di], ax
  Add di, 2
  Inc si
  Dec cl
  JNZ @@Repeat
  Mov al, 32
  Mov es:[di], ax
  Pop ds
 End;
Procedure TWrite(AString: String);
 Begin
  If CursorY > 24 Then
   Begin
    ScrollUp;
    Dec(CursorY);
   End;
  If Length(AString) <> 0 Then WriteStrXY(CursorX, CursorY, AString);
  Inc(CursorX, Length(AString));
  While CursorX > 79 Do
   Begin
    Dec(CursorX, 80);
    Inc(CursorY);
    If CursorY > 24 Then
     Begin
      ScrollUp;
      Dec(CursorY);
     End;
   End;
  H_CursorXY(CursorX, CursorY);
  DisplayScreen;
 End;
Procedure TWriteln(AString: String);
 Begin
  If CursorY > 24 Then
   Begin
    ScrollUp;
    Dec(CursorY);
   End;
  If Length(AString) <> 0 Then WriteStrXY(CursorX, CursorY, AString);
  Inc(CursorX, Length(AString));
  While CursorX > 79 Do
   Begin
    Dec(CursorX, 80);
    Inc(CursorY);
    If CursorY > 24 Then
     Begin
      ScrollUp;
      Dec(CursorY);
     End;
   End;
  Inc(CursorY);
  CursorX := 0;
  H_CursorXY(CursorX, CursorY);
  DisplayScreen;
 End;
Procedure SDown(NumOfLines: Byte);
 Var
  I: Byte;
 Begin
  For I := 1 To NumOfLines Do
   Begin
    Inc(CursorY);
    If CursorY > 24 Then
     Begin
      ScrollUp;
      Dec(CursorY);
     End;
    H_CursorXY(CursorX, CursorY);
    DisplayScreen;
   End;
 End;
Function GetX: Byte;
 Begin
  GetX := CursorX;
 End;
Function GetY: Byte;
 Begin
  GetY := CursorY;
 End;
Procedure CursorXY(X, Y: Byte);
 Begin
  CursorX := X; CursorY := Y;
  H_CursorXY(CursorX, CursorY);
 End;
Procedure DrawHLine(X, Y, Length: Byte; AChar: Char); Assembler;
 Asm
  ClD
  Les di, Screen
{ Get Offset in Video Mem }
  Xor ax, ax   { Offset = (Y * 180) + (X * 2) }
  Mov al, Y
  Mov cl, 7
  ShL ax, cl   { = (Y * 128) }
  Mov bx, ax
  ShR ax, 1    { + (Y *  32) }
  ShR ax, 1
  Add ax, bx
  Xor bx, bx
  Mov bl, X
  ShL bx, 1    { + (X * 2) }
  Add ax, bx
  Add di, ax
{ Draw Line }
  Mov ah, TextColor
  Mov al, AChar
  Xor cx, cx
  Mov cl, Length
  Rep StoSW
 End;
Procedure DrawVLine(X, Y, Length: Byte; AChar: Char); Assembler;
 Asm
{ Get Offset in Video Mem }
  Xor ax, ax   { Offset = (Y * 180) + (X * 2) }
  Mov al, Y
  Mov cl, 7
  ShL ax, cl   { = (Y * 128) }
  Mov bx, ax
  ShR ax, 1    { + (Y *  32) }
  ShR ax, 1
  Add ax, bx
  Xor bx, bx
  Mov bl, X
  ShL bx, 1    { + (X * 2) }
  Add bx, ax
{ Draw Line }
  Mov ah, TextColor
  Mov al, AChar
  Mov cl, Length
  Push ds
  Lds di, Screen
  Add di, bx
 @@YLoop:
  Mov [di], ax
  Add di, 160    { Bytes per Text Line }
  Dec cl
  JNZ @@YLoop
  Pop ds
 End;
Procedure DrawBox(X1, Y1, X2, Y2: Byte; Border: TBoxDef);
 Var
  XLen, YLen: Byte;
 Begin
  XLen := X2 - X1; YLen := Y2 - Y1;
  With Border Do
   Begin
    ClearArea(X1, Y1, X2, Y2);
    DrawHLine(X1, Y1, XLen, HLine);
    DrawHLine(X1, Y2, XLen, HLine);
    DrawVLine(X1, Y1, YLen, VLine);
    DrawVLine(X2, Y1, YLen, VLine);
    WriteCharXY(X1, Y1, X1Y1);
    WriteCharXY(X1, Y2, X1Y2);
    WriteCharXY(X2, Y1, X2Y1);
    WriteCharXY(X2, Y2, X2Y2);
   End;
 End;
Procedure OpenBox(X1, Y1, X2, Y2: Byte; Border: TBoxDef);
 Var
  XLen, YLen: Byte;
  I: Byte;
 Begin
  XLen := X2 - X1; YLen := Y2 - Y1;
  For I := (XLen-1) DownTo 0 Do
   Begin
    DrawBox(X1, Y1, X2-I, Y1+1, Border);
    DisplayScreen;
   End;
  For I := (YLen-1) DownTo 0 Do
   Begin
    DrawBox(X1, Y1, X2, Y2-I, Border);
    DisplayScreen;
   End;
 End;
Procedure CloseBox(X1, Y1, X2, Y2: Byte; Border: TBoxDef);
 Var
  XLen, YLen: Byte;
  I, Temp: Byte;
 Begin
  XLen := X2 - X1; YLen := Y2 - Y1;
  For I := 0 To (XLen-1) Do
   Begin
    Temp := TextColor;
    SetBGColor(Black);
    ClearArea(X1, Y1, X2, Y2);
    TextColor := Temp;
    DrawBox(X1+I, Y1, X2, Y2, Border);
    DisplayScreen;
   End;
  For I := 0 To (YLen-1) Do
   Begin
    Temp := TextColor;
    SetBGColor(Black);
    ClearArea(X2-1, Y1, X2, Y2);
    TextColor := Temp;
    DrawBox(X2-1, Y1+I, X2, Y2, Border);
    DisplayScreen;
   End;
  Temp := TextColor;
  SetBGColor(Black);
  ClearArea(X2-1, Y2-1, X2, Y2);
  TextColor := Temp;
  DisplayScreen
 End;
Procedure SaveScreen(Name: String);
 Var
  FileN: File;
 Begin
  If Pos('.', Name) = 0 Then Assign(FileN, Name + '.SCR');
  Rewrite(FileN);               { 128 * 32 = 4096 }
  BlockWrite(FileN, Mem[Seg(Screen):Ofs(Screen)], 32);
  Close(FileN);
 End;
Procedure LoadScreen(Name: String);
 Var
  FileN: File;
 Begin
  If Pos('.', Name) = 0 Then Assign(FileN, Name + '.SCR');
  Reset(FileN);                 { 128 * 32 = 4096 }
  BlockRead(FileN, Mem[Seg(Screen):Ofs(Screen)], 32);
  Close(FileN);
 End;
Function SetMode(Mode: Word): Byte; Assembler;
 Asm
  Mov ax, 0F00h
  Int 10h
  Push ax
  Mov ax, Mode
  Int 10h
  Pop ax
 End;
Procedure TextExit; Far;
 Begin
  ExitProc := ExitSave;
  FreeMem(Screen, 4096);
  SetMode(LastMode);
 End;

Begin
 KeyBReset;
 GetMem(Screen, 4096);
 ExitSave := ExitProc;
 ExitProc := @TextExit;
 LastMode := SetMode(3);
 TextSeg := $B800;
 CursorX := 0;
 CursorY := 0;
 SetBGColor(Black);
 SetColor(LGray);
 ClearScreen;
 DisplayScreen;
End.
