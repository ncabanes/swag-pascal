(*
SEAN PALMER

> there is simple method of masking color 0 so it won't be displayed.
> An assembly language routine based around this:

Procedure PutImg(x, y : Integer; Var Img);
Type
  AList = Array[1..$FFFF] of Byte; {1-based Arrays are slower than 0-based}
Var
  APtr    : ^AList; {I found a very fast way to do this: With}
  j, i,
  Width,
  Height,
  Counter : Word;
begin
  Aptr    := @Img;
  Width   := (Aptr^[2] SHL 8) + Aptr^[1] + 1; {these +1's that 1-based Arrays }
  Height  := (Aptr^[4] SHL 8) + Aptr^[3] + 1; { require make For slower code}
  Counter := 5;
  For j := y to (y + height - 1) do
  begin  {try pre-calculating the offset instead}
    For i := x to (x + width - 1) do
    begin
      Case Aptr^[Counter] of {CASE is probably not the way to do this}
        0:; { do nothing }
      else _mcgaScreen[j, i] := Aptr^[Counter]; { plot it }
      end;
      Inc(Counter);
    end;
  end;
end;

ok, here's my try:
*)

Type
  pWord = ^Word;

Procedure putImg(x, y : Integer; Var image);
Var
  anImg : Record
    img : Array [0..$FFF7] of Byte;
  end Absolute image;

  aScrn : Record
    scrn : Array [0..$FFF7] of Byte;
  end Absolute $A000 : 0000;

  width,
  height,
  counter,
  offs, src : Word;

begin
  width  := pWord(@anImg[0])^;
  height := pWord(@anImg[2])^;
  offs   := y * 320 + x;
  src    := 4;   {skip width, height}
  With aScrn, anImg do
  Repeat
    counter := width;
    Repeat
      if img[src] <> 0 then
        scrn[offs] := img[src];
      inc(src);
      inc(offs);
      dec(counter);
    Until counter = 0;
    inc(offs, 320 - width);
    dec(height);
  Until height = 0;
end;

{
Those Arrays-pretending-to-be-Records above so they'll work With the With
statement should end up making BP keep the address in Registers, making it
faster. In any Case it won't be slower than yours. I'd appreciate you
timing them and letting me know the results. Actually, let me know if it
even compiles and works... 8)

But Really, man, if you're writing Graphics routines you Really have to
go For assembly. Pascal don't cut it. (c doesn't either...)
}
