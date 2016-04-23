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