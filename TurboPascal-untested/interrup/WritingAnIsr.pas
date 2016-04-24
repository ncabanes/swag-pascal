(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0013.PAS
  Description: Writing an ISR
  Author: JON JASIUNAS
  Date: 11-02-93  05:57
*)

{
JON JASIUNAS

Write you're own ISR, and perform whatever action you want whenever the
user presses the desired key(s).
}

Var
  OldInt9 : Pointer;  {- To save original int $09 address }
  OldExit : Pointer;  {- To save original Exit proc }

Procedure TempInt9;  INTERRUPT;
begin
  { Check For keypress }
  { if pressed process and Exit }
  { else call original int $09 to process keystroke }
end; { TempInt9 }

Procedure CustomExit;  Far;
begin
{-Restore original Exit proc }
  ExitProc := OldExit;

{-Restore original int $09 }
  SetIntVec($09, OldInt9);
end;    { CustomExit }

begin
{-Save original Exit proc and install yours }
  OldExit  := ExitProc;
  ExitProc := @CustomExit;

{-Save original int $09 and install yours }
  GetIntVec($09, OldInt9);
  SetIntVec($09, @TempInt9);
end.


