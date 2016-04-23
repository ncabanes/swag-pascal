{
> Hi I am looking For some help on use 2 monitors at the same time... 1
> is mono and the other is vga.  I would like to just post a certain
> screen on the mono and leave the vga like normal..

VGA Text mode memory begins at $b800, VGA Graphics memory at $A000, and
MDA/Herc memory begins at $b000.  If you plan on running Text and Text,
try something like this:
}
Type
  WhichMonitor = (MDA, VGA);

Procedure ChangeCel (Row, Column, Foreground, Background, Character : Byte;
                     Which : WhichMonitor);
Var
  Point : Word;
begin
  If Which = MDA then
    Point := $b000
  else
    Point := $b800;
  MemW[Point : (Row - 1) * 160 + Col * 2] :=
               (Foreground + Background * 16) * 256 + Character;
  end;
{
Of course, there are more optimized ways to do this, but this should
portray the basic concept.  Herc Graphics and VGA Graphics would be
done in much the same manner, but I don't have an Herc With my VGA to
check it.
}