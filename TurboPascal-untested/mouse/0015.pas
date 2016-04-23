{
From: BERNIE PALLEK
Subj: Mouse routines
---------------------------------------------------------------------------
>I'm after a good mouse unit for Turbo Pascal 7.

OK, here it is:
}
{$R-,S-}

UNIT BMouse;  { basic mouse routines }


INTERFACE


TYPE
  CustomMouseCursor = ARRAY[0..31] OF Word;

CONST
  { button masks }
  Left_B    = $0001;
  Right_B   = $0002;
  Center_B  = $0004;
  { text pointer selectors }
  Software_Pointer = 0;
  Hardware_Pointer = 1;

FUNCTION  Ms_Init(VAR numOfButtons : Word) : Boolean;
PROCEDURE Ms_SetHLimits(xmin, xmax : Word);
PROCEDURE Ms_SetVLimits(ymin, ymax : Word);
PROCEDURE Ms_Show;
PROCEDURE Ms_Hide;
PROCEDURE Ms_Read(VAR x, y, b_mask : Word);
PROCEDURE Ms_SetPos(x, y : Word);
PROCEDURE Ms_SetGraphPointer(newShape : CustomMouseCursor; hot_x, hot_y :
Word);
PROCEDURE Ms_SetTextPointer(select : Word; scr_char : Char; scr_attr : Byte;
                            ptr_char : Char; ptr_attr : Byte);
PROCEDURE Ms_SetMPP(hMPP, vMPP : Word);
PROCEDURE Ms_ReadPosFromLast(VAR hCount, vCount : Word);


IMPLEMENTATION


USES Dos;

VAR
  mouse_detected : Boolean;
  r              : Registers; { scratch Registers variable }
  mi             : Pointer;   { mouse interrupt vector for initial test }


FUNCTION Ms_Init(VAR numOfButtons : Word) : Boolean;
BEGIN
  IF mouse_detected THEN BEGIN
    r.AX := 0;
    Intr($33, r);
    IF (r.AX = 0) THEN BEGIN
      numOfButtons := 0;
      Ms_Init := False;
    END ELSE BEGIN
       numOfButtons := r.BX;
       Ms_Init := True;
    END;
  END ELSE BEGIN
    numOfButtons := 0;
    Ms_Init := False;
  END;
END;

PROCEDURE Ms_SetHLimits(xmin, xmax : Word);
BEGIN
  r.AX := 7;  { set horizontal limits }
  r.CX := xmin;
  r.DX := xmax;
  Intr($33, r);
END;

PROCEDURE Ms_SetVLimits(ymin, ymax : Word);
BEGIN
  r.AX := 8;  { set vertical limits }
  r.CX := ymin;
  r.DX := ymax;
  Intr($33, r);
END;

PROCEDURE Ms_Show;
BEGIN
  r.AX := 1;
  Intr($33, r);
END;

PROCEDURE Ms_Hide;
BEGIN
  r.AX := 2;
  Intr($33, r);
END;

PROCEDURE Ms_Read(VAR x, y, b_mask : Word);
BEGIN
  r.AX := 3;
  Intr($33, r);
  x := r.CX;
  y := r.DX;
  b_mask := r.BX;
END;

PROCEDURE Ms_SetPos(x, y : Word);
BEGIN
  r.AX := 4;
  r.CX := x;
  r.DX := y;
  Intr($33, r);
END;

PROCEDURE Ms_SetGraphPointer(newShape : CustomMouseCursor; hot_x, hot_y :
Word);
BEGIN
  r.AX := 9;
  r.BX := hot_x;
  r.CX := hot_y;
  r.DX := Ofs(newShape);
  r.ES := Seg(newShape);
  Intr($33, r);
END;

PROCEDURE Ms_SetTextPointer(select : Word; scr_char : Char; scr_attr : Byte;
                            ptr_char : Char; ptr_attr : Byte);
BEGIN
  r.AX := 10;
  r.BX := select;  { determines which pointer: software or hardware }
  r.CL := Byte(scr_char);
  r.CH := scr_attr;
  r.DL := Byte(ptr_char);
  r.DH := ptr_attr;
  Intr($33, r);
END;

PROCEDURE Ms_SetMPP(hMPP, vMPP : Word);  { Set [M]ickeys [P]er [P]ixel }
{  set horizontal and vertical mouse motion rates }
{  MPP (1 <= MPP <= 32767) = Mickeys / 8 pixels   }
{  default hMPP is 8:8                            }
{  default vMPP is 16:8                           }
BEGIN
  IF (hMPP >= 1) AND (hMPP <= 32767) AND (vMPP >= 1) AND (vMPP <= 32767) THEN
BEGIN
    r.AX := 15;
    r.CX := hMPP;
    r.DX := vMPP;
    Intr($33, r);
  END;
END;

PROCEDURE Ms_ReadPosFromLast(VAR hCount, vCount : Word);
{ Return the number of Mickeys the mouse has moved since the }
{ last call to this function.                                }
{ A positive number is right/down.                           }
BEGIN
  r.AX := 11;
  Intr($33, r);
  hCount := r.CX;
  vCount := r.DX;
END;


{=== UNIT INITIALIZATION ========================================}
BEGIN
  GetIntVec($33, mi);
  IF (mi = NIL) THEN
    mouse_detected := False
  ELSE
    IF (Byte(mi^) = $CF) THEN mouse_detected := False
  ELSE
    mouse_detected := True;
END.

