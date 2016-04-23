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