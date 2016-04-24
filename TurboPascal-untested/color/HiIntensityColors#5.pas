(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0011.PAS
  Description: Hi Intensity Colors #5
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
> How would I implement the high intensity colors For the TextBACKGROUND
> Procedure in the Crt Unit?
}

Procedure LightEGAVGA(TurnOn : Boolean);
Var Regs : Registers;
begin
  Regs.AH := $10;
  Regs.AL := $03;
  Regs.BL := Byte(TurnOn);
  Int($10,Regs);
end;

Procedure LightHGC(TurnOn : Boolean);
begin
  if TurnOn then Port[$3b8] := $29
  else           Port[$3b8] := $09;
end;

Procedure LightCGA(TurnOn : Boolean);
begin
  if TurnOn then Port[$3d8] := $29
  else           Port[$3d8] := $09;
end;


