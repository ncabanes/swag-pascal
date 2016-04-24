(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0014.PAS
  Description: Rebooting the CPU
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{
REYNIR STEFANSSON

For anyone wondering how to reboot a PClone from Within Turbo Pascal:
The Inline code is a far jump to the restart vector at $FFFF:0.
}

Procedure ColdStart;
begin
   MemW[$40:$72] := 0;
   Inline($EA/0/0/$FF/$FF);
end;

Procedure WarmStart;
begin
   MemW[$40:$72] := $1234;
   Inline($EA/0/0/$FF/$FF);
end;


