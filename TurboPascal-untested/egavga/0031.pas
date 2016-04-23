I heard (read?) that you wanted to find out how to do 256-colour Graphics.
Here are some Procedures For you.

Uses Dos;   { if your Program doesn't already :) }

Procedure SetGrMode(grMode : Byte);  { enters a given Graphics mode }
{ does *not* check For presence of VGA -- use With caution!! }
Var
   r : Registers;
begin
     r.AX := grMode;
     Intr($10, R);
end;

Procedure PutPixel256(p_x, p_y : Integer; p_c : Byte);
begin
     Mem[$A000 : p_y * 320 + p_x] := p_c;
end;

OK, With the SetGrMode Procedure, to enter 256-colour mode, call the Program
with a value of $13.  So:  SetGrMode($13);
And to return to Text mode, call:  SetGrMode($03);
The second Procedure is self-explanatory, With a few bits of info required.
The valid co-ords are 0..319 (horizontal) x 0..199 (vertical), so you can't use
GetMaxX or GetMaxY, unless you define them as Constants in the beginning of
your Program.  The colour is in the range 0..255.

*WARNING*  These Procedure will not work together With a BGI driver or the
Graph Unit.  If you enter Graphics mode With my Procedure, you will not be able
to output Text, boxes, circles, etc. unless you Write your own Procedures for
the above.
