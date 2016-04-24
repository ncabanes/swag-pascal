(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0072.PAS
  Description: Program Origin
  Author: DJ MURDOCH
  Date: 01-27-94  12:17
*)


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
