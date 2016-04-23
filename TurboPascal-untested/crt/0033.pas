{
 AW> Does anybody know how one might make a color chart in Pascal where
 AW> you can move the cursor around and select a new color, like some BBS
 AW> programs do when you change text colors? Such as...
 AW> XXXXXXXXXXXXXXX
 AW> XXXXXXXXXXXXXXX
 AW> XXXXXXXXXXXXXXX
 AW> XXXXXXXXXXXXXXX

 AW> Just like that ^^ ... have 15 across by 7 down, and you can use the
 AW> cursors to select them. I am having a hell of a time...
 AW> Thank you in advance...

Yes, this one knows, but I'm feeling a tad lazy, so I'll hand you a unit
+ example program. Only snag is you should have access to Turbo (or Object)
Professional. Sorry, them's the breaks !


{ -- TPCOLOR.PAS Copyright (C) 1988, by TurboPower Software.
  -- May be distributed and used freely, with the aid of the
  -- commercial product Turbo Professional 4.0 or 5.0. }

{$R-,S-,F-,B-}

UNIT TpColor;

{ -- Color selection routines. }

INTERFACE

CONST ColorFrameColor: byte    = $0E; { -- Color of frame of selection window
}      ColorBoxColor  : byte    = $0F; { -- Color of moving box }
      NewColorProc   : pointer = NIL; { -- User defined procedure }

FUNCTION InitColorBox(CONST BoxXL, BoxYL: byte;
                      VAR   BoxXH, BoxYH: byte) : boolean;
{ -- Initialize the color box. }

PROCEDURE SelectNewColor(VAR Attr : byte);
{ -- Choose one color; ESC exits immediately. }

PROCEDURE EraseColorBox;
{ -- Erase and dispose of the color box. }

{ ---------------------------------------------------------------- }

IMPLEMENTATION

USES OPkey, OPcrt;

CONST BoxCharArray: ARRAY[-1..1, -2..2] OF char
      = ('┌───┐',
         '│ * │',
         '└───┘');
      Choice : STRING[3] = ' * ';

VAR YL       : byte; { -- Coordinates of color window. }
    XL       : byte;
    YH       : byte;
    XH       : byte;
    W        : pointer; { -- Points to screen buffer for overall window. }
    B        : pointer; { -- Points to screen buffer for moving box window. }
    ScanLines: word; { -- Saves cursor shape. }
    XY       : word; { -- Saves cursor position. }

    { -- Holds attributes  row    col}
    BoxColorArray : ARRAY[0..17, 0..25] OF byte;

PROCEDURE CalcRowCol(CONST Attr: byte; VAR Row, Col: byte);
{ -- -Calculate the row and column for an attribute}
BEGIN Row:=YL+1+(Attr AND $0F);
      Col:=XL+1+3*(Attr SHR 4);
END;

PROCEDURE DrawChart;
{ -- Draw the color chart and initialize BoxColorArray. }
VAR C                :integer;
    Row, Col, Attr, A: byte;
BEGIN fillchar(BoxColorArray, sizeof(BoxColorArray), ColorBoxColor);
      FOR Attr:=0 TO 127
      DO BEGIN CalcRowCol(Attr, Row, Col);
               FastWrite(Choice, Row, Col, Attr);
               A:=(Attr AND $F0) OR (ColorBoxColor AND $F);
               FOR C:=Col TO Col+2 DO BoxColorArray[Row-YL, C-XL]:=A
         END
END;

PROCEDURE DrawAttributeBox(CONST Attr, Row, Col: byte);
{ -- Draw box around current selection. }
VAR I, J, RowDelta, ColDelta: integer;
    A                       : byte;
BEGIN FOR RowDelta:=-1 TO 1
      DO BEGIN I:=Row+RowDelta;
               FOR ColDelta:=-2 TO 2
               DO BEGIN J:=Col+ColDelta;
                        A:=BoxColorArray[I-YL, J-XL];
                        { -- Leave the attribute of ' * ' alone}
                        CASE ColDelta
                        OF -1..1 : IF RowDelta = 0 THEN A:=Attr
                        END;
                        FastWrite(BoxCharArray[RowDelta, ColDelta], I, J, A)
                  END
         END
END;

PROCEDURE SaveBox(CONST Row, Col: byte);
{ -- Save screen under the moving box. }
BEGIN SaveWindow(Col-1, Row-1, Col+3, Row+1, FALSE, B) END;

PROCEDURE RestoreBox(CONST Row, Col : byte);
{ -- Restore screen under the moving box. }
BEGIN RestoreWindow(Col-1, Row-1, Col+3, Row+1, FALSE, B) END;

FUNCTION InitColorBox(CONST BoxXL, BoxYL: byte;
                      VAR   BoxXH, BoxYH: byte): boolean;
BEGIN InitColorBox:=FALSE;

      { -- Check if window already active: }
      IF W <> NIL THEN exit;

      { -- Compute coordinates of surrounding window. }
      YL:=BoxYL;
      XL:=BoxXL;
      CalcRowCol(127, YH, XH);
      inc(XH, 3);
      inc(YH, 1);
      BoxXH:=XH;
      BoxYH:=YH;
      IF (XH > ScreenWidth) OR (YH > ScreenHeight) THEN exit;

      { -- Allocate screen buffers. }
      IF NOT SaveWindow(XL, YL, XH, YH, TRUE, W) THEN exit;
      IF NOT SaveWindow(XL, YL, XL+4, YL+2, TRUE, B) THEN exit;

      { -- Initialize the box. }
      GetCursorState(XY, ScanLines);
      HiddenCursor;
      FrameWindow(XL, YL, XH, YH, ColorFrameColor, 0, '');
      DrawChart;
      InitColorBox:=TRUE
END;

PROCEDURE CallNewColorProc(CONST Attr : byte);
  { -- -Call user routine when a new color is selected. }
INLINE($FF/$1E/>NewColorProc); { -- call dword ptr [>NewColorProc] }

PROCEDURE SelectNewColor(VAR Attr : byte);
VAR KW                : word;
    A, PrevA, Row, Col: byte;
    Done              : boolean;
BEGIN Done:=FALSE;
      A:=Attr;
      PrevA:=NOT A;

      REPEAT { -- Update current color. }
             IF A <> PrevA
             THEN BEGIN CalcRowCol(A, Row, Col);
                        SaveBox(Row, Col);
                        DrawAttributeBox(A, Row, Col+1);
                        IF NewColorProc <> NIL THEN CallNewColorProc(A);
                        PrevA:=A;
                  END;

             { -- Evaluate command: }
             KW:=ReadKeyWord;
             CASE KW
             OF Enter: BEGIN Attr:=A;
                             Done:=TRUE;
                             BoxCharArray[0, 0]:='';
                             DrawAttributeBox(A + Blink, Row, Col+1);
                             delay(1500)
                       END;
                Up   : IF (A AND $F) = 0 THEN inc(A, 15) ELSE dec(A);
                Down : IF (A AND $F) = $F THEN dec(A, 15) ELSE inc(A);
                Left : IF A <= 15 THEN inc(A, 112) ELSE dec(A, 16);
                Right: IF A >= 112 THEN dec(A, 112) ELSE inc(A, 16);
                ESC  : Done:=TRUE
             END;

             { -- Restore previous color: }
             IF Done OR (A <> PrevA) THEN RestoreBox(Row, Col)
      UNTIL Done
END;

PROCEDURE EraseColorBox;
BEGIN IF W <> NIL
      THEN BEGIN RestoreWindow(XL, YL, XL+4, YL+2, TRUE, B);
                 RestoreWindow(XL, YL, XH, YH, TRUE, W);
                 W:=NIL;
                 RestoreCursorState(XY, ScanLines)
           END
END;

BEGIN { -- Initialisatie: }
      W:=NIL
END (* TPcolor *).

{ -------- Test with the following program: -------- }

PROGRAM ColorboxTest;

USES TPcolor;

CONST XLB = 5;
      YLB = 5;

VAR xh, yh, attr: byte;

BEGIN IF NOT InitColorBox(XLB, YLB, xh, yh)
      THEN BEGIN write(#7'Colorbox too big for screen !'); halt END;

      attr:=$00;  { -- Do not omit. }
      SelectNewColor(attr);
      EraseColorBox
END.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following unit is public domain:

UNIT OpKey;

{ -- Keystroke definitions. }

{*********************************************************}
{*                    OPKEY.PAS 1.03                     *}
{*               TurboPower Software 1990.               *}
{*             Released to the public domain.            *}
{*********************************************************}

INTERFACE

{Notes:
  * keys returned only with OPCRT or OPENHKBD enhanced keyboard support
  # keys returned only with OPENHKBD extra key support }

CONST

{ -- Function keys: }
    F1 = $3B00;       ShF1 = $5400;      CtrlF1 = $5E00;      AltF1 = $6800;
    F2 = $3C00;       ShF2 = $5500;      CtrlF2 = $5F00;      AltF2 = $6900;
    F3 = $3D00;       ShF3 = $5600;      CtrlF3 = $6000;      AltF3 = $6A00;
    F4 = $3E00;       ShF4 = $5700;      CtrlF4 = $6100;      AltF4 = $6B00;
    F5 = $3F00;       ShF5 = $5800;      CtrlF5 = $6200;      AltF5 = $6C00;
    F6 = $4000;       ShF6 = $5900;      CtrlF6 = $6300;      AltF6 = $6D00;
    F7 = $4100;       ShF7 = $5A00;      CtrlF7 = $6400;      AltF7 = $6E00;
    F8 = $4200;       ShF8 = $5B00;      CtrlF8 = $6500;      AltF8 = $6F00;
    F9 = $4300;       ShF9 = $5C00;      CtrlF9 = $6600;      AltF9 = $7000;
   F10 = $4400;      ShF10 = $5D00;     CtrlF10 = $6700;     AltF10 = $7100;
   F11 = $8500;{*}   ShF11 = $8700;{*}  CtrlF11 = $8900;{*}  AltF11 =
$8B00;{*}   F12 = $8600;{*}   ShF12 = $8800;{*}  CtrlF12 = $8A00;{*}  AltF12 =
$8C00;{*}
{ -- Numeric keypad: }
{ -- Note that ShUp is an "8", ShPad5 is a "5", and so on. }
    Up = $4800;       ShUp = $4838;      CtrlUp = $8D00;{*}   AltUp =
$9800;{#}  Down = $5000;     ShDown = $5032;    CtrlDown = $9100;{*} AltDown =
$A000;{#}  Left = $4B00;     ShLeft = $4B34;    CtrlLeft = $7300;    AltLeft =
$9B00;{#} Right = $4D00;    ShRight = $4D36;   CtrlRight = $7400;   AltRight =
$9D00;{#}  Home = $4700;     ShHome = $4737;    CtrlHome = $7700;    AltHome =
$9700;{#}EndKey = $4F00;      ShEnd = $4F31;     CtrlEnd = $7500;     AltEnd =
$9F00;{#}  PgUp = $4900;     ShPgUp = $4939;    CtrlPgUp = $8400;    AltPgUp =
$9900;{#}  PgDn = $5100;     ShPgDn = $5133;    CtrlPgDn = $7600;    AltPgDn =
$A100;{#}   Ins = $5200;      ShIns = $5230;     CtrlIns = $9200;{*}  AltIns =
$A200;{#}   Del = $5300;      ShDel = $532E;     CtrlDel = $9300;{*}  AltDel =
$A300;{#}  Pad5 = $4C00;{*}  ShPad5 = $4C35;    CtrlPad5 = $8F00;{*} AltPad5 =
$9C00;{#}
{ -- Alphabetic keys: }
  LowA = $1E61;        UpA = $1E41;       CtrlA = $1E01;       AltA = $1E00;
  LowB = $3062;        UpB = $3042;       CtrlB = $3002;       AltB = $3000;
  LowC = $2E63;        UpC = $2E43;       CtrlC = $2E03;       AltC = $2E00;
  LowD = $2064;        UpD = $2044;       CtrlD = $2004;       AltD = $2000;
  LowE = $1265;        UpE = $1245;       CtrlE = $1205;       AltE = $1200;
  LowF = $2166;        UpF = $2146;       CtrlF = $2106;       AltF = $2100;
  LowG = $2267;        UpG = $2247;       CtrlG = $2207;       AltG = $2200;
  LowH = $2368;        UpH = $2348;       CtrlH = $2308;       AltH = $2300;
  LowI = $1769;        UpI = $1749;       CtrlI = $1709;       AltI = $1700;
  LowJ = $246A;        UpJ = $244A;       CtrlJ = $240A;       AltJ = $2400;
  LowK = $256B;        UpK = $254B;       CtrlK = $250B;       AltK = $2500;
  LowL = $266C;        UpL = $264C;       CtrlL = $260C;       AltL = $2600;
  LowM = $326D;        UpM = $324D;       CtrlM = $320D;       AltM = $3200;
  LowN = $316E;        UpN = $314E;       CtrlN = $310E;       AltN = $3100;
  LowO = $186F;        UpO = $184F;       CtrlO = $180F;       AltO = $1800;
  LowP = $1970;        UpP = $1950;       CtrlP = $1910;       AltP = $1900;
  LowQ = $1071;        UpQ = $1051;       CtrlQ = $1011;       AltQ = $1000;
  LowR = $1372;        UpR = $1352;       CtrlR = $1312;       AltR = $1300;
  LowS = $1F73;        UpS = $1F53;       CtrlS = $1F13;       AltS = $1F00;
  LowT = $1474;        UpT = $1454;       CtrlT = $1414;       AltT = $1400;
  LowU = $1675;        UpU = $1655;       CtrlU = $1615;       AltU = $1600;
  LowV = $2F76;        UpV = $2F56;       CtrlV = $2F16;       AltV = $2F00;
  LowW = $1177;        UpW = $1157;       CtrlW = $1117;       AltW = $1100;
  LowX = $2D78;        UpX = $2D58;       CtrlX = $2D18;       AltX = $2D00;
  LowY = $1579;        UpY = $1559;       CtrlY = $1519;       AltY = $1500;
  LowZ = $2C7A;        UpZ = $2C5A;       CtrlZ = $2C1A;       AltZ = $2C00;

{ -- Number keys, on top row of keyboard: }
  Num1 = $0231;                                                Alt1 = $7800;
  Num2 = $0332;                           Ctrl2 = $0300;       Alt2 = $7900;
  Num3 = $0433;                                                Alt3 = $7A00;
  Num4 = $0534;                                                Alt4 = $7B00;
  Num5 = $0635;                                                Alt5 = $7C00;
  Num6 = $0736;                           Ctrl6 = $071E;       Alt6 = $7D00;
  Num7 = $0837;                                                Alt7 = $7E00;
  Num8 = $0938;                                                Alt8 = $7F00;
  Num9 = $0A39;                                                Alt9 = $8000;
  Num0 = $0B30;                                                Alt0 = $8100;

{ -- Miscellaneous: }
   Space = $3920;   {!!.03}
    BkSp = $0E08;                   CtrlBkSp = $0E7F;       AltBkSp =
$0E00;{*}     Tab = $0F09;   ShTab = $0F00;  CtrlTab  = $9400;{*}     AltTab =
$A500;{*}   Enter = $1C0D;                   CtrlEnter= $1C0A;      AltEnter =
$1C00;{*}     Esc = $011B;                                            AltEsc =
$0100;{*}
   Minus = $0C2D;                  CtrlMinus = $0C1F;      AltMinus = $8200;
                     Plus = $0D2B;                          AltPlus = $8300;
PadMinus = $4A2D;               CtrlPadMinus = $8E00;{*} AltPadMinus=
$4A00;{#} PadPlus = $4E2B;                CtrlPadPlus = $9000;{*} AltPadPlus =
$4E00;{#}                     Star = $092A;
 PadStar = $372A;                                        AltPadStar =
$3700;{#}
 CtrlBreak  = $0000;

{ -- The following are the standard hardware scan codes (in hex) generated
  -- by the keyboard. This table is especially useful for calculating
  -- TSR hotkeys: }

CONST hsc_Esc      = $01;
      hsc_1        = $02;
      hsc_2        = $03;
      hsc_3        = $04;
      hsc_4        = $05;
      hsc_5        = $06;
      hsc_6        = $07;
      hsc_7        = $08;
      hsc_8        = $09;
      hsc_9        = $0A;
      hsc_0        = $0B;
      hsc_Minus    = $0C;  { -- '-'. }
      hsc_Equals   = $0D;  { -- '='. }
      hsc_Bksp     = $0E;
      hsc_Tab      = $0F;

      hsc_Q        = $10;
      hsc_W        = $11;
      hsc_E        = $12;
      hsc_R        = $13;
      hsc_T        = $14;
      hsc_Y        = $15;
      hsc_U        = $16;
      hsc_I        = $17;
      hsc_O        = $18;
      hsc_P        = $19;
      hsc_LtBrack  = $1A;  { -- '['. }
      hsc_RtBrack  = $1B;  { -- ']'. }
      hsc_Enter    = $1C;
      hsc_Ctrl     = $1D;
      hsc_A        = $1E;
      hsc_S        = $1F;

      hsc_D        = $20;
      hsc_F        = $21;
      hsc_G        = $22;
      hsc_H        = $23;
      hsc_J        = $24;
      hsc_K        = $25;
      hsc_L        = $26;
      hsc_SemiCol  = $27;  { -- ';'. }
      hsc_Quote    = $28;  { -- ''', onder het aanhalingsteken. }
      hsc_Tilde    = $29;  { -- '`', onder de tilde (linksboven). }
      hsc_LtShift  = $2A;
      hsc_BkSlash  = $2B;  { -- '\'. }
      hsc_Z        = $2C;
      hsc_X        = $2D;
      hsc_C        = $2E;
      hsc_V        = $2F;

      hsc_B        = $30;
      hsc_N        = $31;
      hsc_M        = $32;
      hsc_Comma    = $33;  { -- ','. }
      hsc_Period   = $34;  { -- '.' }
      hsc_Slash    = $35;  { -- '/'. }
      hsc_RtShift  = $36;
      hsc_PrtSc    = $37;
      hsc_Alt      = $38;
      hsc_Space    = $39;
      hsc_CapsLock = $3A;
      hsc_F1       = $3B;
      hsc_F2       = $3C;
      hsc_F3       = $3D;
      hsc_F4       = $3E;
      hsc_F5       = $3F;

      hsc_F6       = $40;
      hsc_F7       = $41;
      hsc_F8       = $42;
      hsc_F9       = $43;
      hsc_F10      = $44;
      hsc_NumLock  = $45;
      hsc_ScrLock  = $46;
      hsc_Home     = $47;
      hsc_Up       = $48;
      hsc_PgUp     = $49;
      hsc_PadMinus = $4A;
      hsc_Left     = $4B;
      hsc_Center   = $4C;
      hsc_Right    = $4D;
      hsc_Plus     = $4E;
      hsc_End      = $4F;

      hsc_Down     = $50;
      hsc_PgDn     = $51;
      hsc_Ins      = $52;
      hsc_Del      = $53;
      hsc_SysReq   = $54;
      hsc_F11      = $57;
      hsc_F12      = $58;

      { -- Range of "hsc"-constants: }

      hsc_minimum  = hsc_Esc;
      hsc_maximum  = hsc_F12;

{ ------------------------------------------------------------------ }

IMPLEMENTATION

END (* OPkey *).

If you do not own unit TPcrt (or OPcrt), this is the "interface" of

procedure OpCrt.FastWrite(St : string; Row, Col : Word; Attr : Byte);
Write St at Row,Col in Attr (video attributes) without snow.
