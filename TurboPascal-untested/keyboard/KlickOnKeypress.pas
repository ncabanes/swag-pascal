(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0039.PAS
  Description: Klick on keypress
  Author: PER-ERIC LARSSON
  Date: 08-27-93  21:30
*)

{
PER-ERIC LARSSON

> How do you determine if a key is still held down after another is
> pressed ? KeyPressed returns False after second key is pressed and first
> key is still held down. ??

From the helpFile For KEEP :
}

Procedure Keyclick; interrupt;
begin
  if Port[$60] < $80 then
    { Only click when key is pressed }

