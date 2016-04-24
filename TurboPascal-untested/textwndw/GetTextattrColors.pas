(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0010.PAS
  Description: Get TextAttr Colors
  Author: KELLY SMALL
  Date: 11-02-93  05:43
*)

{
KELLY SMALL

>Get the foreground/background/blink attr out of TextAttr.

Assuming you're using TP/BP:
}

Procedure GetColor(Var f, b : Byte; Var BlinkOn : Boolean);
begin
  f := TextAttr And $F;
  b := (TextAttr Shr 4) And 7;
  BlinkOn := TextAttr And $80 = $80;
end;

