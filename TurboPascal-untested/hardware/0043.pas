
(* Program name, SPEED. Toggles the fast/slow turbo mode on most
386/486 mother boards with an AMI BIOS. *)

uses DOS;
var
reg : registers;

begin

if ParamCount = 0 then
   writeln(#13,#10,'"SPEED +" toggles turbo to fast, "SPEED -" toggles turbo to slow ');

if ParamStr(1) = '+' then
begin
 reg.ah := $F0;
 reg.al := $02;
 intr($16,reg);
end;              {Set turbo mode to fast}

if ParamStr(1) = '-'then
begin
 reg.ah := $F0;
 reg.al := $01;
 intr($16,reg);
end;              {Set turbo node to slow}
end.
