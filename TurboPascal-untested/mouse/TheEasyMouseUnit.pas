(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0006.PAS
  Description: The easy Mouse unit
  Author: MIKE BURNS
  Date: 08-27-93  21:38
*)

{
MIKE BURNS

> How did you get a mouse Pointer into your Program?
}


Procedure Clear_Regs;
begin
  FillChar(Regs, SizeOf(Regs), 0);
end;


Function InitMouse : Boolean;
begin
  Clear_Regs;

  Regs.AX := 00;
  Intr ($33, Regs);
  if Regs.AX <> 0 then            { if not 0 then YES THERE IS A MOUSE }
  begin
    InitMouse := True;
    MbutS     := BX;              { Number of buttons on the mouse }
  end
  else
  begin
    InitMouse := False;
    Mbuts     := 0;
  end;
end;


Procedure ShowMouse;
 begin
  Clear_Regs;
  Regs.AX := 01;
  Intr ($33, Regs);
end;

Procedure HideMouse;
 begin
  Clear_Regs;
  Regs.AX := 02;
  Intr ($33, Regs);
end;

