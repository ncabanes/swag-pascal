PROGRAM HighBack;

USES Dos,Crt;

TYPE
  AttrType = (Blinking,HighInt);

PROCEDURE SelectAttribute(Attribute: AttrType);
VAR
  Reg  :Registers;
BEGIN
  Reg.ah := $10;
  Reg.al := 3;
  CASE Attribute OF
    HighInt  : Reg.bl := 0;
    Blinking : Reg.bl := 1
    END;
  Intr($10,Reg)
  END;

PROCEDURE SetBackground(BG: Byte);
BEGIN
  BG := (BG AND $F) SHL 4; {Limit to range 0 - 15, then shift up}
  Crt.TextAttr := (Crt.TextAttr MOD 16) + BG;
  END;

PROCEDURE SetForeground(FG: Byte);
BEGIN
  FG := (FG AND $F);                      {Limit to range 0 - 15}
  Crt.TextAttr := (Crt.TextAttr AND $F0) + FG;
  END;

FUNCTION GetBackground: Byte;
BEGIN
  GetBackground := Crt.TextAttr DIV 16;
  END;

FUNCTION GetForeground: Byte;
BEGIN
  GetForeground := Crt.TextAttr MOD 16;
  END;

CONST
  Flip : Integer = 0;
  BGM : Byte = Black;
  FGM : Byte = White;
VAR
  BG, FG : Byte;
  A : Char;

BEGIN

{Initialize screen}
  TextMode(CO80);
  TextBackGround(BGM);
  TextColor(FGM);
  ClrScr;

{Display demo color combinations}
  GotoXY(35,1);WriteLn('Foreground');
  Write('Background   ');
  FOR FG := 0 TO $F DO Write(FG:3,' ');
  WriteLn;WriteLn;

  FOR BG:= 0 TO $F DO BEGIN                {Cycle through colors}
    SetBackground(BGM);
    Write(BG:5,'       ');
    SetBackground(BG);
    FOR FG := 0 TO $F DO BEGIN
      SetForeground(FG);                {Adjust FG for visibilty}
      Write(Crt.TextAttr:4);
      END;
    WriteLn;
    END;

  GotoXY(18,25);                                  {Create prompt}
  SetBackground(LightCyan);
  SetForeground(Black);
  Write('Press <Esc> to quit, any other key to swap attributes');

  A := ' ';                             {Loop to swap attributes}
  WHILE Ord(A) <> 27 DO BEGIN
    CASE Flip OF
       0 : SelectAttribute(HighInt);
      -1 : SelectAttribute(Blinking);
      END;
    Flip := NOT Flip;
    A := ReadKey;
    END;
  TextMode(CO80);
  ClrScr
  END.
