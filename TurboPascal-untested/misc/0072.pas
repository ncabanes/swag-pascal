
{$X+}  { Need this for easy handling of Asciiz strings }
var
  parentseg : ^word;
  p : pchar;
begin
  parentseg := ptr(prefixseg,$16);
  p := ptr(parentseg^-1,8);
  writeln('I was launched by ',p);
end.

