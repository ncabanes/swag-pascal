
Unit Mouse;
{ Copyright (c) 1991, Crazy Systems Software, Inc. }

{$G+}

{
 *************************************************
 *                                               *
 *       Mouse in Text Mode Interface Unit       *
 *            for Borland Pascal 7.0             *
 *                                               *
 *      Completely written by  Andrew Eigus      *
 *************************************************
}

interface

type
  TMouseWinRect = record
    X1, Y1, X2, Y2 : word
  end;

  TMouseParamTable = record
    BaudRate,  { Baud rate / 100 }
    Emulation,
    ReportRate, { Report rate }
    FirmRev,
    ZeroWord,  { Should be zero }
    Port,  { Com Port used }
    PhysButtons, { Physical buttons }
    LogButtons : word { Logical buttons }
  end;

  TMouseRec = record
    Keys,
    Hzints,
    Page,
    XCoord,
    YCoord,
    HSpeed,
    VSpeed,
    DSpeed : word;
    Column,
    Row : byte;
    W : TMouseWinRect;
    ButtonClicked : byte;
    ParamTable : TMouseParamTable
  end;

const
  LeftButton  = 1;
  MidButton   = 4;
  RightButton = 2;

  mNoInts    = 0;
  m30HzInts  = 1;
  m50HzInts  = 2;
  m100HzInts = 3;
  m200HzInts = 4;

var
  M : TMouseRec;
  MouseInstalled : boolean;

function InstallMouse : boolean;
function GetMouseInfo(var M : TMouseRec) : byte;
function ButtonReleased : boolean;
procedure SetMouseCursor(CursorOn : boolean);
procedure SetMouseCursorType(HotSpotX, HotSpotY : word; var CursorImage);
procedure MoveMouseTo(XCoord, YCoord : integer);
procedure SetMouseWindow(X1, Y1, X2, Y2 : word);
procedure GetMouseSpeed;
procedure SetMouseSpeed(HorSpeed, VrtSpeed, DblSpeed : integer);
procedure SetMouseInts(Hz : word);
function GetMousePage : word;
procedure SetMousePage(Page : word);
procedure UninstallMouse;

implementation

Function InstallMouse; assembler;
Asm
  XOR AX,AX  { zero function }
  INT 33h
  CMP AL,0
  JE  @@1
  MOV MouseInstalled,True
  LEA DI,M
  MOV [ES:DI](TMouseRec).Keys,0
  MOV [ES:DI](TMouseRec).Keys,BX
  PUSH ES
  PUSH DI
  CALL GetMouseInfo
  CALL GetMousePage
  CALL GetMouseSpeed
  MOV [ES:DI](TMouseRec).W.X1,1
  MOV [ES:DI](TMouseRec).W.Y1,1
  MOV [ES:DI](TMouseRec).W.X2,639
  MOV [ES:DI](TMouseRec).W.Y2,199
  MOV AX,246Ch
  LEA DX,M.ParamTable
  INT 33h
  MOV AL,True
@@1:
End; { InstallMouse }

Function GetMouseInfo; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,0003h
  INT 33h
  LES DI,M
  MOV [ES:DI](TMouseRec).XCoord,CX
  SHR CX,3
  INC CL
  MOV [ES:DI](TMouseRec).Column,CL
  MOV [ES:DI](TMouseRec).YCoord,DX
  SHR DX,3
  INC DL
  MOV [ES:DI](TMouseRec).Row,DL
  MOV [ES:DI](TMouseRec).ButtonClicked,BL
  MOV AL,BL   { LeftButton, MidButton or RightButton }
@@1:
End; { GetMouseInfo }

Function ButtonReleased; assembler;
Asm
  LEA DI,M
  PUSH ES
  PUSH DI
  CALL GetMouseInfo
  MOV AL,True
  CMP BL,0
  JE  @@1
  MOV AL,False
@@1:
End; { ButtonReleased }

Procedure SetMouseCursor; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@2
  MOV AX,0001h
  CMP CursorOn,True
  JE  @@1
  MOV AX,0002h
@@1:
  INT 33h
@@2:
End; { SetMouseCursor }

Procedure SetMouseCursorType; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,000Ah
  MOV BX,HotSpotX
  MOV CX,HotSpotY
  LES DX,CursorImage
  INT 33h
@@1:
End; { SetMouseCursorType }

Procedure MoveMouseTo; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,0004h
  MOV CX,XCoord
  MOV DX,YCoord
  INT 33h
@@1:
End; { MoveMouseTo }

Procedure SetMouseWindow; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  LEA DI,M
  MOV AX,0007h
  MOV CX,X1
  MOV [ES:DI](TMouseRec).W.X1,CX
  MOV DX,X2
  MOV [ES:DI](TMouseRec).W.X2,DX
  INT 33h
  MOV AX,0008h
  MOV CX,Y1
  MOV [ES:DI](TMouseRec).W.Y1,CX
  MOV DX,Y2
  MOV [ES:DI](TMouseRec).W.Y2,DX
  INT 33h
@@1:
End; { SetMouseWindow }

Procedure GetMouseSpeed; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,001Bh
  INT 33h
  LEA DI,M
  MOV [ES:DI](TMouseRec).HSpeed,BX
  MOV [ES:DI](TMouseRec).VSpeed,CX
  MOV [ES:DI](TMouseRec).DSpeed,DX
@@1:
End; { GetMouseSpeed }

Procedure SetMouseSpeed; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,001Ah
  MOV BX,HorSpeed
  MOV CX,VrtSpeed
  MOV DX,DblSpeed
  INT 33h
  CALL GetMouseSpeed
@@1:
End; { SetMouseSpeed }

Procedure SetMouseInts; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,001Ch
  MOV BX,Hz
  INT 33h
@@1:
End; { SetMouseInts }

Function GetMousePage; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,001Eh
  INT 33h
  LEA DI,M
  MOV [ES:DI](TMouseRec).Page,BX
  MOV AX,BX
@@1:
End; { GetMousePage }

Procedure SetMousePage; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,001D
  MOV BX,Page
  INT 33h
  CALL GetMousePage
@@1:
End; { SetMousePage }

Procedure UninstallMouse; assembler;
Asm
  CMP MouseInstalled,True
  JNE @@1
  MOV AX,0020h
  INT 33h
@@1:
End; { UninstallMouse }

Begin
  MouseInstalled := False;
  FillChar(M, SizeOf(TMouseRec), 0)
End. { Mouse }

{---now the demo program---}

Program MouDemo;

uses Crt, Mouse;

Begin
  if InstallMouse then
  begin
    ClrScr;
    SetMouseCursor(True);
    WriteLn('Mouse is installed.');
    WriteLn('Click left mouse button in the upper left corner of your ' +
      'screen to quit.');
    repeat
      GetMouseInfo(M);
    until (M.ButtonClicked = LeftButton) and (M.Column = 1) and (M.Row = 1);
    Write('Waiting to release left button...');
    repeat until ButtonReleased;
    Write(#13);
    ClrEol;
    SetMouseCursor(False);
    UninstallMouse
  end else WriteLn('Mouse is NOT installed.')
End.

