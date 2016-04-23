{
(The Procedure Mouse_Check can be done shorter, but this one "remembers" a
mouseclick, so you can click the mouse, and at a later time call this
procedure and it will tell you the mouse-information!)

>-----------------------------            }

PROGRAM Mouse_on_the_screen;

USES DOS,Graph;

TYPE
     MouseType = RECORD
                   x, y, Button     : Word;
                   RButton, LButton : Boolean;
                 END;
VAR
     Reg                              : Registers;
     Mouse                            : Mousetype;

PROCEDURE Show_Mouse;
BEGIN
  Reg.AX := 1;
  Intr($33,Reg);
END;

PROCEDURE Hide_Mouse;
BEGIN
  Reg.AX := 2;
  Intr($33,Reg);
END;

PROCEDURE SetMouseArea(XMin,YMin,XMax,YMax :Word);
BEGIN
  Reg.AX := 7;
  Reg.CX := XMin;
  Reg.DX := XMax;
  Intr($33,Reg);
  Reg.AX := 8;
  Reg.CX := YMin;
  Reg.DX := YMax;
  Intr($33,Reg);
END;

PROCEDURE Init_Mouse;
BEGIN
  Reg.AX := 0;
  Intr($33,Reg);
  SetMouseArea(0,0,GetMaxX,GetMaxY);
  Reg.AX := 4;
  Reg.CX := 100;
  Reg.DX := 100;
  Intr($33,Reg);
END;

PROCEDURE Mouse_Check;
BEGIN
  Reg.AX := 5;
  Reg.BX := 1;
  Intr($33,Reg);
  Mouse.RButton := Reg.BX > 0;
  Mouse.Button := Reg.AX;
  IF Mouse.RButton THEN Mouse.Button := 2;
  Mouse.X := Reg.CX;
  Mouse.Y := Reg.DX;

  IF NOT Mouse.RButton
    THEN Begin
           Reg.AX := 5;
           Reg.BX := 0;
           Intr($33,Reg);
           Mouse.LButton := Reg.BX > 0;
           Mouse.Button := Reg.AX;
           IF Mouse.LButton THEN Mouse.Button := 1;
           Mouse.X := Reg.CX;
           Mouse.Y := Reg.DX;
         End;
END;

BEGIN
  {Init graphics screen here!}

  Init_Mouse;
  Show_Mouse;
  .                     {You have to finish this part yourself}
  .                     { ___     }
  .                     { |-lorian}
  Hide_Mouse;
 {CloseGraph};
END.
