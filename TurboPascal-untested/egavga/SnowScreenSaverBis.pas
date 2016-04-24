(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0124.PAS
  Description: Snow Screen Saver
  Author: ERIC COOLMAN
  Date: 08-24-94  13:57
*)

{
NB>{Hello All! I've recently coded this screen saver.It really looks like
NB>snow is falling all over, don't you think?

Yeah, it looked pretty neat!

NB>However, I did not set out to do a snow screen saver and if you exp
NB>with it a little you will see that it can even turn out to be a fir
NB>If anyone can improve this code or make anything out of it, I would
NB>very pleased to have a copy of the source.

Ok, I played around with it a bit today, and following is my modified
version.  I pretty much just cleaned it up, got rid of all the unused
variables and stuff (there were quite a few <G>) for readability,
simplified a the calculations, and removed a lot of the overhead, and
removed most of the global variables.  You will see that now you can
have a lot more snowflakes without it bogging out.  I also removed the
custom palette because you can get pretty much the same colours using
the default palette (indexes 19-31).  It can probably be simplified
even further (ie. remove the x and y tables and just use newPos table).
Oh yeah, I threw in a little snowflake explosion at the start too :-).

(********************************************************************
 Originally by    : Nick Batalas, 14-6-1994
 Modifications by : Eric Coolman, 19-6-1994
********************************************************************)
}

Program SnowFall;
Uses crt;                                  { for keypressed only }

const
  Flakes = 500;            { try less flakes for faster snowfall }

{---------------- Stuff not specific to snowfall ----------------}
Procedure vidMode(mode : byte);assembler;
  asm mov ah,$00;  mov al,mode; int 10h; end;

Procedure setPixel(pixPos : word; color : byte);
begin
    mem[$A000:pixPos] := color;
end;

{---------------------------MAIN PROGRAM-------------------------}

var
  CurFlake : integer;                        { snowflake counter }
  i : longint;                       { to add velocity to flakes }
  x,y, newPos: array[0..Flakes] of word;         { lookup tables }
BEGIN
  randomize;
  for curFlake:=0 to Flakes do        { set up snow lookup table }
  begin
    x[curFlake]:=random(319);
    y[curFlake]:=random(199);
  end;

  vidMode($13);                       { 320x200x256 graphics mode }

  i := 0; { change to 100 or higher to get rid of start explosion }

  repeat
    inc(i);

    for curFlake:=0 to Flakes do
      begin
        setPixel(newPos[curFlake], 0);     { erase old snowflake }
        newPos[curFlake] :=      { set up and draw new snowflake }
          round(x[curFlake]*(i*0.01)) +                  { new X }
          round(y[curFlake]*(i*0.01)) * 320;             { new Y }
        setPixel(newPos[curFlake], (curFlake mod 13) + 19);
      end;

    while (port[$3da] and $08) = $08 do;  { wait for vRetrace to }
    while (port[$3da] and $08) = $00 do;  { start and end        }
  until keypressed;

  vidMode($03);                       { return to 80x25 textmode }
end.


