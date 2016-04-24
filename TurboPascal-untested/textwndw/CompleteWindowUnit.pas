(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0014.PAS
  Description: Complete WINDOW unit
  Author: GRANT BEATTIE
  Date: 08-24-94  17:54
*)

UNIT Win; { Win.Pas }

{$S-}{$I-}{$R-}

INTERFACE

USES Crt, Cursor, FadeUnit;

TYPE
  PTitleStr = ^TitleStr;
  TitleStr = STRING [63];

  PFrame = ^TFrame;
  TFrame = ARRAY [1..8] OF CHAR;

  TVertFrameChars = ARRAY [1..3] OF CHAR;

  { Text color attr type }

  PTextAttr = ^TTextAttr;
  TTextAttr = BYTE;

  { Window rectangle type }

  PRect = ^TRect;
  TRect = RECORD
    Left, Top, Right, Bottom : BYTE
  END;

  PWinState = ^TWinState;
  TWinState = RECORD
    WindMin,
    WindMax : WORD;
    WHEREX,
    WHEREY : BYTE;
    TextAttr : TTextAttr
  END;

  PWinRec = ^TWinRec;
  TWinRec = RECORD
    Next : PWinRec;
    State : TWinState;
    Title : PTitleStr;
    TitleColor,
    FrameColor : TTextAttr;
    Size : WORD;
    Buffer : POINTER
  END;

  PWindowStruct = ^TWindowStruct;
  TWindowStruct = RECORD
    Rect : TRect;
    TitleColor,
    FrameColor : TTextAttr;
    Title : TitleStr
  END;

CONST
  None = '';

  VertFrame   : TVertFrameChars = '│║█';

  { Display combination codes returned by the GetDisplay function }

  gdNoDisplay = $00; { No display }
  gdMono      = $01; { Monochrome adapter w/ monochrome display }
  gdCGA       = $02; { CGA w/ color display }
  gdEGA       = $04; { EGA w/ color display }
  gdEGAMono   = $05; { EGA w/ monochrome display }
  gdPGA       = $06; { PGA w/ color display }
  gdVGAMono   = $07; { VGA w/ monochrome analog display }
  gdVGA       = $08; { VGA w/ color analog display }
  gdMCGADig   = $0A; { MCGA w/ digital color display }
  gdMCGAMono  = $0B; { MCGA w/ monochrome analog display }
  gdMCGA      = $0C; { MCGA w/ color analog display }
  gdUnknown   = $FF; { Unknown display type }

  { Window frame classes }

  SingleFrame : TFrame       = '┌─┐││└─┘';
  DoubleFrame : TFrame       = '╔═╗║║╚═╝';
  SingleDoubleFrame : TFrame = '╓─╖║║╙─╜';
  DoubleSingleFrame : TFrame = '╒═╕││╘═╛';
  BarFrame : TFrame          = '█▀████▄█';

  { Window frame constants }

  frNone         = 0;  { Window has no frame }
  frSingle       = 1;  { Window has single frame }
  frSingleDouble = 2;  { Window has single (horiz) and double (vert) frames }
  frDouble       = 3;  { Window has double frame }
  frDoubleSingle = 4;  { Window has double (horiz) and single (vert) frames }
  frBar          = 5;  { Window has a rectangular bar frame }

  { Shadow color attributes }

  winShadowAttr : TTextAttr = $07;

  FontOpenReg : ARRAY [1..10] OF BYTE =
    ($02, $04, $04, $07, $05, $00, $06, $04, $04, $02);
  FontCloseReg : ARRAY [1..10] OF BYTE =
    ($02, $03, $04, $03, $05, $10, $06, $0E, $04, $00);

  FadeDelay = 10; { Fade screen delay time for
    SaveDosScreen and RestoreDosScreen functions }

VAR
  WinShadow : BOOLEAN;
  WinCount : INTEGER;
  TopWindow : PWinRec;
  WinExplodeDelay, ScreenHeight, WinFrame : BYTE;
  ScreenWidth : WORD;
  Screen : POINTER;

FUNCTION  GetDisplay : BYTE;
PROCEDURE SetTextFont (VAR Font; StartChar, BytePerChar, CharCount : BYTE);
FUNCTION  GetTextFont (FontCode : BYTE) : POINTER;
PROCEDURE WriteStr (X, Y : BYTE; S : STRING; Color : TTextAttr);
PROCEDURE WriteStrV (X, Y : BYTE; S : STRING; Color : TTextAttr);
PROCEDURE WriteChar (X, Y, Count : BYTE; Ch : CHAR; Color : TTextAttr);
PROCEDURE FillWin (Ch : CHAR; Color : TTextAttr);
PROCEDURE ReadWin (VAR Buf);
PROCEDURE WriteWin (VAR Buf);
FUNCTION  WinSize : WORD;
PROCEDURE SaveWin (VAR W : TWinState);
PROCEDURE RestoreWin (VAR W : TWinState);
PROCEDURE GetFrame (FrameNum : BYTE; VAR Frame : TFrame);
PROCEDURE FrameWin (Title : TitleStr;
                    Frame : TFrame; TitleColor, FrameColor : TTextAttr);
PROCEDURE UnFrameWin;
FUNCTION  ScrReadChar (X, Y : BYTE) : CHAR;
PROCEDURE ScrWriteChar (X, Y : BYTE; Ch : CHAR);
FUNCTION  ScrReadAttr (X, Y : BYTE) : TTextAttr;
PROCEDURE ScrWriteAttr (X, Y : BYTE; Color : TTextAttr);
PROCEDURE WindowIndirect (Rect : TRect);
FUNCTION  PtInRect (X, Y : BYTE; Rect : TRect) : BOOLEAN;
PROCEDURE GetWindowRect (VAR Rect : TRect);
PROCEDURE GetWindowRectExt (X1, Y1, X2, Y2 : BYTE; VAR Rect : TRect);
PROCEDURE ClearWin (X1, Y1, X2, Y2 : BYTE; Color : TTextAttr);
PROCEDURE ShadowWin (X1, Y1, X2, Y2 : BYTE);
PROCEDURE CreateWin (X1, Y1, X2, Y2 : BYTE;
                    TitleColor, FrameColor : TTextAttr; Title : TitleStr);
PROCEDURE CreateWinIndirect (WS : TWindowStruct);
FUNCTION  OpenWin (X1, Y1, X2, Y2 : BYTE;
                  TitleColor, FrameColor : TTextAttr; Title : TitleStr) : BOOLEAN;
FUNCTION  OpenWinIndirect (WS : TWindowStruct) : BOOLEAN;
FUNCTION  CloseWin : BOOLEAN;
FUNCTION  MoveWin (Left, Top : BYTE) : BOOLEAN;
FUNCTION  SaveDOSScreen (UseFade, RestoreScreen : BOOLEAN) : BOOLEAN;
FUNCTION  RestoreDOSScreen (UseFade : BOOLEAN) : BOOLEAN;
PROCEDURE SetBlink (BlinkOn : BOOLEAN);

IMPLEMENTATION

{$L win.obj}

VAR OldCursor : WORD;

FUNCTION MakeWord (HI, LO : BYTE) : WORD; assembler;
Asm
  MOV AH, HI
  MOV AL, LO
END; { MakeWord }

FUNCTION GetDisplay; assembler;
Asm
MOV AX, 1A00h
  INT 10h
  MOV AL, BL
END; { GetDisplay }

PROCEDURE SetRegisters; near; assembler;
asm
  MOV AX, SEG @Data
  MOV DS, AX
  MOV CX, 0002h
  MOV DX, 03C4h
  CALL @@1
  MOV CX, 0003h
  MOV DL, 0CEh
@@1 :
  LODSB
  OUT DX, AL
INC DX
  LODSB
OUT DX, AL
  DEC DX
  LOOP @@1
END; { SetRegisters }

PROCEDURE SetTextFont; assembler;
Asm
  MOV BX, SegA000
  PUSH DS
  MOV AX, WORD PTR [Font + 2]
  MOV DS, AX
  XOR AX, AX
  MOV AL, StartChar
  MOV DI, AX
  MOV SI, WORD PTR [Font]
  MOV AX, BX
  MOV BL, BytePerChar
XOR BH, BH
  PUSH ES
MOV ES, AX
  MOV CL, 5
  SHL DI, CL
  PUSH SI
  PUSH DS
  CLI
  MOV SI, OFFSET FontOpenReg
  CALL SetRegisters
  POP DS
  POP SI
  MOV AX, DI
@@1 :
  MOV DI, AX
  MOV CX, BX
  REP MOVSB
  ADD AX, 0020h
  DEC CharCount
JNE @@1
  MOV SI, OFFSET FontCloseReg
CALL SetRegisters
  STI
  POP ES
  POP DS
END; { SetTextFont }

FUNCTION GetTextFont; assembler;
Asm
  MOV AX, 1130h
  MOV BH, FontCode
  INT 10h
  MOV AX, BP
  MOV DX, ES
END; { GetTextFont }

PROCEDURE WriteStr (X, Y : BYTE; S : STRING; Color : TTextAttr); EXTERNAL;

PROCEDURE WriteStrV (X, Y : BYTE; S : STRING; Color : TTextAttr);
VAR Index : INTEGER;
BEGIN
  FOR Index := 1 TO LENGTH (S) DO
    WriteChar (X, PRED (Y + Index), 1, S [Index], Color)
END; { WriteStrV }

PROCEDURE WriteChar (X, Y, Count : BYTE; Ch : CHAR; Color : TTextAttr);
EXTERNAL;

PROCEDURE FillWin (Ch : CHAR; Color : TTextAttr); EXTERNAL;
PROCEDURE WriteWin (VAR Buf); EXTERNAL;
PROCEDURE ReadWin (VAR Buf); EXTERNAL;
FUNCTION  WinSize : WORD; EXTERNAL;

PROCEDURE SaveWin (VAR W : TWinState);
BEGIN
  W.WindMin := WindMin;
  W.WindMax := WindMax;
W.WHEREX := WHEREX;
  W.WHEREY := WHEREY;
W.TextAttr := TextAttr
END; { SaveWin }

PROCEDURE RestoreWin (VAR W : TWinState);
BEGIN
  WindMin := W.WindMin;
  WindMax := W.WindMax;
  GOTOXY (W.WHEREX, W.WHEREY);
  TextAttr := W.TextAttr
END; { RestoreWin }

PROCEDURE GetFrame (FrameNum : BYTE; VAR Frame : TFrame);
BEGIN
  CASE FrameNum OF
    frSingle : Frame := SingleFrame;
    frDouble : Frame := DoubleFrame;
    frSingleDouble : Frame := SingleDoubleFrame;
frDoubleSingle : Frame := DoubleSingleFrame;
    frBar : Frame := BarFrame;
ELSE FILLCHAR (Frame, SIZEOF (Frame), BYTE ( - 1) )
  END
END; { GetFrame }

PROCEDURE FrameWin (Title : TitleStr;
  Frame : TFrame; TitleColor, FrameColor : TTextAttr);

VAR W, H, Y : WORD;

BEGIN
W := LO (WindMax) - LO (WindMin) + 1;
H := HI (WindMax) - HI (WindMin) + 1;
WriteChar (1, 1, 1, Frame [1], FrameColor);
WriteChar (2, 1, W - 2, Frame [2], FrameColor);
WriteChar (W, 1, 1, Frame [3], FrameColor);
IF LENGTH (Title) > W - 2 THEN Title [0] := CHR (W - 2);
WriteStr ( (W - LENGTH (Title) ), 1, Title, TitleColor);

FOR Y := 2 TO H - 1 DO
BEGIN
WriteChar (1, Y, 1, Frame [4], FrameColor);
    WriteChar (W, Y, 1, Frame [5], FrameColor)
END;
  WriteChar (1, H, 1, Frame [6], FrameColor);
  WriteChar (2, H, W - 2, Frame [7], FrameColor);
  WriteChar (W, H, 1, Frame [8], FrameColor);
  INC (WindMin, $0101);
  DEC (WindMax, $0101)
END; { FrameWin }

PROCEDURE UnFrameWin;
BEGIN
  DEC (WindMin, $0101);
  INC (WindMax, $0101)
END; { UnFrameWin }

FUNCTION ScrReadChar; assembler;
Asm
  LES DI, Screen
  XOR AH, AH
  MOV AL, Y
DEC AX
  MUL ScreenWidth
  SHL AX, 1
  XOR DH, DH
  MOV DL, X
  SHL DX, 1
  DEC DX
  DEC DX
  ADD AX, DX
  MOV DI, AX
  MOV AL, BYTE PTR [ES : DI]
  {ScrReadChar := Char(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 2)^)}
END; { ScrReadChar }

PROCEDURE ScrWriteChar; assembler;
Asm
  LES DI, Screen
  XOR AH, AH
MOV AL, Y
  DEC AX
  MUL ScreenWidth
  SHL AX, 1
  XOR DH, DH
  MOV DL, X
  SHL DX, 1
  DEC DX
  DEC DX
  ADD AX, DX
  MOV DI, AX
  MOV AL, Ch
  MOV BYTE PTR [ES : DI], AL
  {Char(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 2)^) := Ch}
END; { ScrWriteChar }

FUNCTION ScrReadAttr; assembler;
Asm
LES DI, Screen
  XOR AH, AH
  MOV AL, Y
  DEC AX
  MUL ScreenWidth
  SHL AX, 1
  XOR DH, DH
  MOV DL, X
  SHL DX, 1
  DEC DX
  ADD AX, DX
  MOV DI, AX
  MOV AL, BYTE PTR [ES : DI]
  {ScrReadAttr := TTextAttr(Ptr(Seg(Screen^),
    (Y - 1) * ScreenWidth * 2 + (X * 2) - 1)^)}
END; { ScrReadAttr }

PROCEDURE ScrWriteAttr; assembler;
Asm
LES DI, Screen
  XOR AH, AH
  MOV AL, Y
  DEC AX
  MUL ScreenWidth
  SHL AX, 1
  XOR DH, DH
  MOV DL, X
  SHL DX, 1
  DEC DX
  ADD AX, DX
  MOV DI, AX
  MOV AL, Color
  MOV BYTE PTR [ES : DI], AL
  {TTextAttr(Ptr(Seg(Screen^),
(Y - 1) * ScreenWidth * 2 + (X * 2) - 1)^) := Color}
END; { ScrWriteAttr }

PROCEDURE WindowIndirect (Rect : TRect);
BEGIN
  WITH Rect DO WINDOW (Left, Top, Right, Bottom)
END; { WindowIndirect }

FUNCTION PtInRect (X, Y : BYTE; Rect : TRect) : BOOLEAN;
BEGIN
  WITH Rect DO
    PtInRect := (X IN [Left..Right]) AND (Y IN [Top..Bottom])
END; { PtInRect }

PROCEDURE GetWindowRect (VAR Rect : TRect); assembler;
Asm
  LES DI, Rect
  MOV AX, WindMin
  MOV BX, WindMax
INC AL
  INC AH
  INC BL
  INC BH
MOV [ES : DI] (TRect) .Left, AL
  MOV [ES : DI] (TRect) .Top, AH
  MOV [ES : DI] (TRect) .Right, BL
  MOV [ES : DI] (TRect) .Bottom, BH
END; { GetWindowRect }

PROCEDURE GetWindowRectExt (X1, Y1, X2, Y2 : BYTE; VAR Rect : TRect); assembler;
Asm
  LES DI, Rect
  MOV AL, X1
  MOV AH, Y1
  MOV BL, X2
  MOV BH, Y2
  MOV [ES : DI] (TRect) .Left, AL
  MOV [ES : DI] (TRect) .Right, BL
MOV [ES : DI] (TRect) .Top, AH
  MOV [ES : DI] (TRect) .Bottom, BH
END; { GetWindowRectExt }

PROCEDURE ClearWin (X1, Y1, X2, Y2 : BYTE; Color : TTextAttr); assembler;
Asm
  MOV AX, 0600h
  MOV BH, Color
  MOV CL, X1
  DEC CL
  MOV CH, Y1
  DEC CH
  MOV DL, X2
  DEC DL
  MOV DH, Y2
  DEC DH
  INT 10h
END; { ClearWin }

PROCEDURE ShadowWin;
VAR P, I : BYTE;
BEGIN
  I := Y2 + 1;
FOR P := X1 + 2 TO X2 + 2 DO
    ScrWriteAttr (P, I, ScrReadAttr (P, I) AND WinShadowAttr);
  I := X2 + 1;
  FOR P := Y1 + 1 TO Y2 + 1 DO
  BEGIN
    ScrWriteAttr (I, P, ScrReadAttr (I, P) AND WinShadowAttr);
    ScrWriteAttr (I + 1, P, ScrReadAttr (I + 1, P) AND WinShadowAttr)
  END
END; { ShadowWin }

PROCEDURE CreateWin (X1, Y1, X2, Y2 : BYTE;
  TitleColor, FrameColor : TTextAttr; Title : TitleStr);
VAR
W, H : WORD;
DX, DY : BYTE;
F : TFrame;
BEGIN
IF WinFrame <> frNone THEN
BEGIN
GetFrame (WinFrame, F);
IF WinExplodeDelay <> 0 THEN
BEGIN
DX := X1 + 2;
DY := Y1 + 2;
REPEAT
IF WinShadow = TRUE THEN
ShadowWin (X1, Y1, DX, DY);
WINDOW (X1, Y1, DX, DY);
FrameWin (Title, F, TitleColor, FrameColor);
ClearWin (X1 + 1, Y1 + 1, DX - 1, DY - 1, FrameColor);
 IF DX < X2 THEN INC (DX, 2);
 IF DX > X2 THEN DX := X2;
IF DY < Y2 THEN INC (DY);
DELAY (WinExplodeDelay)
UNTIL (DX = X2) AND (DY = Y2)
END;
IF WinShadow = TRUE THEN ShadowWin (X1, Y1, X2, Y2);
WINDOW (X1, Y1, X2, Y2);
FrameWin (Title, F, TitleColor, FrameColor);
ClearWin (SUCC (X1), SUCC (Y1), PRED (X2), PRED (Y2), FrameColor)
  END;
  WINDOW (X1, Y1, X2, Y2);
  IF WinShadow THEN INC (WindMax, $0102)
END; { CreateWin }

PROCEDURE CreateWinIndirect;
BEGIN
  WITH WS, WS.Rect DO
    CreateWin (Left, Top, Right, Bottom, TitleColor, FrameColor, Title)
END; { CreateWinIndirect }

FUNCTION OpenWin (X1, Y1, X2, Y2 : BYTE;
  TitleColor, FrameColor : TTextAttr; Title : TitleStr) : BOOLEAN;
VAR W : PWinRec;
BEGIN
  OpenWin := FALSE;
  IF MAXAVAIL > SIZEOF (TWinRec) THEN
BEGIN
    NEW (W);
    W^.Next := TopWindow;
    SaveWin (W^.State);
    IF MAXAVAIL > LENGTH (Title) + 1 THEN
    BEGIN
      GETMEM (W^.Title, LENGTH (Title) + 1);
      W^.Title^ := Title;
      W^.TitleColor := TitleColor;
      W^.FrameColor := FrameColor;
      WINDOW (X1, Y1, X2, Y2);
      IF WinShadow = TRUE THEN INC (WindMax, $0102);
      IF MAXAVAIL > WinSize THEN
      BEGIN
W^.Size := WinSize;
GETMEM (W^.Buffer, W^.Size);
ReadWin (W^.Buffer^);
CreateWin (X1, Y1, X2, Y2, TitleColor, FrameColor, Title);
 TopWindow := W;
INC (WinCount);
OpenWin := TRUE
      END
    END
  END
END; { OpenWin }

FUNCTION OpenWinIndirect;
BEGIN
  WITH WS, WS.Rect DO OpenWinIndirect := OpenWin (Left,
    Top, Right, Bottom, TitleColor, FrameColor, Title)
END; { OpenWinIndirect }

FUNCTION CloseWin : BOOLEAN;
VAR W : PWinRec;
BEGIN
  CloseWin := FALSE;
  IF Assigned (TopWindow) AND (WinCount > 0) THEN
  BEGIN
W := TopWindow;
    WITH W^ DO
    BEGIN
      WriteWin (Buffer^);
      FREEMEM (Buffer, W^.Size);
      FREEMEM (Title, LENGTH (Title^) + 1);
      RestoreWin (State);
      TopWindow := Next
    END;
    DISPOSE (W);
    DEC (WinCount);
    CloseWin := TRUE
  END
END; { CloseWin }

FUNCTION MoveWin;
VAR W : PWinRec;
BEGIN
  MoveWin := FALSE;
IF (MAXAVAIL > SIZEOF (TWinRec) ) AND Assigned (TopWindow) THEN
  BEGIN
    NEW (W);
    IF MAXAVAIL > WinSize THEN
    BEGIN
      SaveWin (W^.State);
      W^.State.WindMin := MakeWord (Top, Left) - $0101;
      W^.State.WindMax := W^.State.WindMin + WindMax - WindMin;

      IF WinShadow THEN DEC (WindMax, $0102);
      W^.Size := WinSize;

      GETMEM (W^.Buffer, W^.Size);
      ReadWin (W^.Buffer^);

IF WinShadow THEN INC (WindMax, $0102);
      WriteWin (TopWindow^.Buffer^);

      RestoreWin (W^.State);
ReadWin (TopWindow^.Buffer^);

      IF WinShadow THEN DEC (WindMax, $0102);
      WriteWin (W^.Buffer^);
      IF WinShadow THEN
      BEGIN
ShadowWin (Left, Top, SUCC (LO (WindMax) ), SUCC (HI (WindMax) ) );
INC (WindMax, $0102)
      END;
      FREEMEM (W^.Buffer, W^.Size);
      MoveWin := TRUE
    END;
    DISPOSE (W)
  END
END; { MoveWin }

FUNCTION SaveDOSScreen;
BEGIN
  IF NOT GetDisplay IN [gdEGA..gdMCGA] THEN UseFade := FALSE;

  OldCursor := GetCursorType;
  SetCursor (CursorOff);

  IF UseFade THEN FadeOut (FadeDelay);

  asm
    PUSH WORD PTR [WinShadow]
    MOV WinShadow, FALSE
  END;

  SaveDOSScreen := OpenWin (1, 1,
    ScreenWidth, ScreenHeight, Black, Black, None);

  asm
POP WORD PTR [WinShadow]
  END;

  IF RestoreScreen THEN WriteWin (TopWindow^.Buffer^);

  IF UseFade THEN FadeIn (0)

END; { SaveDOSScreen }

FUNCTION RestoreDOSScreen;
BEGIN
  IF NOT GetDisplay IN [gdEGA..gdMCGA] THEN UseFade := FALSE;

  WINDOW (1, 1, ScreenWidth, ScreenHeight);
  asm
    MOV WinShadow, FALSE
  END;
  IF UseFade THEN SetBrightness (0);
  RestoreDOSScreen := CloseWin;

  IF UseFade THEN FadeIn (FadeDelay);

  SetCursorType (OldCursor);
SetCursor (CursorOn)
END; { RestoreDOSScreen }

PROCEDURE SetBlink (BlinkOn : BOOLEAN);
CONST PortVal : ARRAY [0..4] OF BYTE = ($0C, $08, $0D, $09, $09);
VAR
  PortNum : WORD;
  Index, PVal : BYTE;
BEGIN
  IF LastMode = Mono THEN
  BEGIN
    PortNum := $3B8;
    Index := 4
  END ELSE
    IF GetDisplay IN [gdEGA..gdMCGA] THEN
BEGIN
      INLINE (
$8A / $5E / < BlinkOn /     { MOV BL, [BP+<BlinkOn] }
$B8 / $03 / $10 /          { MOV AX, $1003 }
$CD / $10);             { MOV $10 }
      EXIT
    END ELSE
      BEGIN
PortNum := $3D8;
CASE LastMode OF
  0..3 : Index := LastMode;
  ELSE EXIT
END
      END;
   PVal := PortVal [Index];
   IF BlinkOn THEN
   PVal := PVal OR $20;
   Port [PortNum] := PVal
END; { SetBlink }

FUNCTION HeapFunc (Size : WORD) : INTEGER; far; assembler;
Asm
  MOV AX, 1
END; { HeapFunc }

BEGIN
  HeapError := @HeapFunc;
  WinCount := 0;
  WinShadow := TRUE;
  WinFrame := frSingle;
  WinExplodeDelay := 10; { set no explode }
  TopWindow := NIL;
  IF LastMode = Mono THEN
    Screen := PTR (SegB000, 0) ELSE
  BEGIN
    Screen := PTR (SegB800, 0);
    IF (LastMode AND Font8x8) <> 0 THEN
ScreenHeight := Mem [Seg0040 : $0084] ELSE ScreenHeight := 25
END;
ScreenWidth := MemW [Seg0040 : $004A];
InitCol;       { Save original palette }
SetBlink (TRUE) { Set blinking }
END. { Win.Pas }

{--------------------------------  XX3402 CODE ---------------------}
{ CUT OUT THE FOLLOWING AND USE XX3402 TO DECODE TO OBTAIN WIN.OBJ  }

* XX3402 - 000678 - 090894 - - 72 - - 85 - 53801 - - - - - - - - - WIN.OBJ - - 1 - OF - - 1
U + Y + - rRdPWt - IooHW0 + + + + + QJ5JmMawUELBnNKpWP4Jm60 - KNL7nOKxi61AiAda61k - + uTBN
0Fo5RqZi9Y3HHKe6 + k - + uImK + U + + O6U1 + 20VZ7M4 + + F2EJF - FdU5 + 2U + + + 6 - + FKK - U + 2Eox2
FIKM - k + cEE21 + E5mX - s + 0IB6FIB9IotDJk + 5JoZCF2p7HU + 5JoZCF2p - K + - gY + w + + + 66Jp77
J2JLGIsh + + 0lY + s + + + 65FYZAH3R7HWA + + 04E2 + + + + UZLIYZIFIB6EJ6H + + 0NY + w + + + 66Jp77
J2JHJ36 + + + 1HY + s + + + 65JoZCIoZOFH6 - + DqE1U + + + URGFI32JoZC8 + + + 7sU2 + 20W + N4UFE20
+ + - JWyn2LUUaWUyyJE1ckE - RmUc + JMjgWYs8jbg + u92 + LQc8 + 9tv + Cg6jdc + ukCyeU - JWykn
mMgK + + 081U + + 8gd - IJ7Ku9o + LZdNzgMuBU2 + RixRmUE + 5cda - gJq02Nm3em9qCmc + LLvyimc
+ LHvWwCfyy9g5wCgey9w5wC8FUW8NUNm36jMv8U - RTjuv8U - RDi9kujvsiz1wuj15UMTWzT2
TUPc2E07TUMTklv3RUPc - E07RUMTkr6JfMjMv8U - RTjuv8U - RDi9kujvsin1wuL1WZMCzgc0
3U + + QZMu3U + + Rp08RUnynU6q + E - mFHcq + E - rDn9hsniU + + + ekjv + CgVm + cf6i2 + + Xg08lWPq
7Yc + AjM1kh5UWzWs + 9UaU1t7 + + Rp + fGkXg0uqUDwU1s + + + 5ztgCV + + + f - U + + - E2 - xiHFsAja
b2k + l + dI + gEOJ + 9273E0l0ZI + gEiJ + 92BkM - + gEv - U21l2o4 + ED2pkM - + gHR - U21lCU4 + E92
vUM - + wHr - U21lGk4 + E53AkM - + wIr - U20Gcc0 + + - o
* * * * * END OF BLOCK 1 * * * * *


{--------------------------------   ASSEMBLY CODE ---------------------}
{ COMPILE THE FOLLOWING WITH TASM                                      }

; {*** WIN.ASM ***}

        TITLE   WIN

        LOCALS  @@
 P286

; Coordinate RECORD

X               EQU     (BYTE PTR 0)
Y               EQU     (BYTE PTR 1)

; BIOS workspace equates

CrtMode         EQU     (BYTE PTR 49H)
CrtWidth        EQU     (BYTE PTR 4AH)

DATA    SEGMENT WORD PUBLIC

; Externals from CRT UNIT

        EXTRN   CheckSnow : BYTE, WindMin : WORD, WindMax : WORD

DATA    ENDS

CODE    SEGMENT BYTE PUBLIC

        ASSUME  CS : CODE, DS : DATA

; PROCEDURE WriteStr (X, Y : BYTE; S : STRING; Attr : BYTE);

        PUBLIC  WriteStr

WriteStr :

        PUSH    BP
MOV     BP, SP
        LES     BX, [BP + 8]
        MOV     CL, ES : [BX]
        MOV     SI, OFFSET CS : CrtWriteStr
        CALL    CrtWrite
        POP     BP
        RETF    10

; PROCEDURE WriteChar (X, Y, Count : BYTE; Ch : CHAR; Attr : BYTE);

        PUBLIC  WriteChar

WriteChar :

        PUSH    BP
        MOV     BP, SP
        MOV     CL, [BP + 10]
        MOV     SI, OFFSET CS : CrtWriteChar
CALL    CrtWrite
        POP     BP
        RETF    10

; PROCEDURE FillWin (Ch : CHAR; Attr : BYTE);

        PUBLIC  FillWin

FillWin :

        MOV     SI, OFFSET CS : CrtWriteChar
        JMP     SHORT CommonWin

; PROCEDURE ReadWin (VAR Buf);

        PUBLIC  ReadWin

ReadWin :

        MOV     SI, OFFSET CS : CrtReadWin
        JMP     SHORT CommonWin

; PROCEDURE WriteWin (VAR Buf);

        PUBLIC  WriteWin

WriteWin :

        MOV     SI, OFFSET CS : CrtWriteWin

; Common FillWin / ReadWin / WriteWin routine

CommonWin :

        PUSH    BP
        MOV     BP, SP
XOR     CX, CX
        MOV     DX, WindMin
        MOV     CL, WindMax.X
        SUB     CL, DL
        INC     CX
@@1 :    PUSH    CX
        PUSH    DX
        PUSH    SI
        CALL    CrtBlock
        POP     SI
        POP     DX
        POP     CX
        INC     DH
        CMP     DH, WindMax.Y
        JBE     @@1
        POP     BP
        RETF    4

; WRITE STRING TO screen

CrtWriteStr :

        PUSH    DS
        MOV     AH, [BP + 6]
        LDS     SI, [BP + 8]
        INC     SI
        JC      @@4
@@1 :    LODSB
        MOV     BX, AX
@@2 :    IN      AL, DX
        TEST    AL, 1
        JNE     @@2
        CLI
@@3 :    IN      AL, DX
        TEST    AL, 1
        JE      @@3
MOV     AX, BX
        STOSW
        STI
        LOOP    @@1
        POP     DS
        RET
@@4 :    LODSB
        STOSW
        LOOP    @@4
        POP     DS
        RET

; WRITE characters TO screen

CrtWriteChar :

        MOV     AL, [BP + 8]
        MOV     AH, [BP + 6]
JC      @@4
        MOV     BX, AX
@@1 :    IN      AL, DX
        TEST    AL, 1
        JNE     @@1
        CLI
@@2 :    IN      AL, DX
        TEST    AL, 1
        JE      @@2
        MOV     AX, BX
        STOSW
        STI
        LOOP    @@1
        RET
@@4 :    REP     STOSW
        RET

; READ WINDOW buffer from screen

CrtReadWin :

        PUSH    DS
        PUSH    ES
        POP     DS
        MOV     SI, DI
        LES     DI, [BP + 6]
        CALL    CrtCopyWin
        MOV     [BP + 6], DI
        POP     DS
        RET

; WRITE WINDOW buffer TO screen

CrtWriteWin :

        PUSH    DS
LDS     SI, [BP + 6]
        CALL    CrtCopyWin
        MOV     [BP + 6], SI
        POP     DS
        RET

; WINDOW buffer COPY routine

CrtCopyWin :

        JC      @@4
@@1 :    LODSW
        MOV     BX, AX
@@2 :    IN      AL, DX
        TEST    AL, 1
        JNE     @@2
        CLI
@@3 :    IN      AL, DX
TEST    AL, 1
        JE      @@3
        MOV     AX, BX
        STOSW
        STI
        LOOP    @@1
        RET
@@4 :    REP     MOVSW
        RET

; DO screen operation
; IN    CL = Buffer LENGTH
;       SI = WRITE PROCEDURE POINTER
;       BP = Stack frame POINTER

CrtWrite :

        MOV     DL, [BP + 14]
DEC     DL
        ADD     DL, WindMin.X
        JC      CrtExit
        CMP     DL, WindMax.X
        JA      CrtExit
        MOV     DH, [BP + 12]
        DEC     DH
        ADD     DH, WindMin.Y
        JC      CrtExit
        CMP     DH, WindMax.Y
        JA      CrtExit
        XOR     CH, CH
        JCXZ    CrtExit
        MOV     AL, WindMax.X
        SUB     AL, DL
        INC     AL
        CMP     CL, AL
        JB      CrtBlock
MOV     CL, AL

; DO screen operation
; IN    CL = Buffer LENGTH
;       DX = CRT coordinates
;       SI = PROCEDURE POINTER

CrtBlock :

        MOV     AX, 40H
        MOV     ES, AX
        MOV     AL, DH
        MUL     ES : CrtWidth
        XOR     DH, DH
        ADD     AX, DX
        SHL     AX, 1
        MOV     DI, AX
        MOV     AX, 0B800H
CMP     ES : CrtMode, 7
        JNE     @@1
        MOV     AH, 0B0H
@@1 :    MOV     ES, AX
        MOV     DX, 03DAH
        CLD
        CMP     CheckSnow, 1
        JMP     SI

; EXIT from screen operation

CrtExit :

        RET

; FUNCTION WinSize : WORD;

        PUBLIC  WinSize

WinSize :

MOV     AX, WindMax
SUB     AX, WindMin
ADD     AX, 101H
MUL     AH
SHL     AX, 1
RETF

CODE    ENDS

END



