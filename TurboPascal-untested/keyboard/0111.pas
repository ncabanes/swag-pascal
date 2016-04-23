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