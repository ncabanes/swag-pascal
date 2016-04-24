(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0111.PAS
  Description: Toggle the Insert Key?!
  Author: BRAD ZAVITSKY
  Date: 05-31-96  09:16
*)

var
  KeyFlags1: Byte absolute $40:$17;

function InsertOn: Boolean;
begin
  InsertOn := (KeyFlags1 and $80) = $80;
end;

procedure ToggleInsert;
begin
  InsertOn := KeyFlags1 xor $80;
end;

