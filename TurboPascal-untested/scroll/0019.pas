{
I am new to this echo, so here is my offering placed upon
the alter of exceptence. I have seen a couple of requests
for help with both scrolling the screen, as well as
reading/writting directly to/from the screen.

Here is a unit to do both. One note here, this unit is
assuming a color monitor. It can be used for a (Barrrrrfffffff)
monocrome monitor by changing the value of
"cscreen to $B000 : $0000"

If anyone has any questions, I will be monitoring this echo
from now on and will be happy to answer any questions.


                                        Robert Long....

   -------------------------[ Cut Here ]--------------------------
}

Unit screen;

INTERFACE

    Uses  dos, crt;

    Type
       scrp = ^scr;
        scr = array[1..25,1..80] of record
                                      ch : char;
                                      at : byte;
                                    end;

{ SCRP : Pointer to a screen record. Used to overlay video
         memory, and so you can create dynamic screens on
         the heap.
  SCR :  An array of records that duplicates the video memory.
         You can read any position on the screen like this:
             Character_on_screen:= cscreen[y,x].ch;
         And write to a screen position like this:
          cscreen[y,x].ch:= Character_to_put_on_screen;
         And of course the color attributes would be:
            Attribute_on_screen:= cscreen[y,x].at;
}

    Var
      cscreen : scr absolute $b800 : $0000;

{ Cscreen is overlaied on video memory, so it requires ZERO bytes
  of memory. This means what is on the screen is whats in the record
  and vica/versa. What you write to the record is on the screen as
  fast as the refresh rate of your monitor.
}

procedure setscrl(x1,y1,x2,y2 : byte);
procedure getscrl(var x1,y1,x2,y2 : byte);
procedure scrlup(b,f : byte);
procedure scrldn(b,f : byte);
procedure scrll(b,f : byte);
procedure scrlr(b,f : byte);


IMPLEMENTATION

    const
       setscrlx1 : byte = 1;
       setscrly1 : byte = 1;
       setscrlx2 : byte = 80;
       setscrly2 : byte = 25;

    var
      reg : registers;

{ The setscrl routine is just for convience. As the routines
  below will expect the upper-left and lower-right corners
  of your scroll window, why not set them once insted of
  every time you call the routine. As they are typed constants
  (see above) the defult window size (in 25X80 mode) is full
  screen, but can be set to any size.
}

procedure setscrl(x1,y1,x2,y2 : byte);

    begin
      setscrlx1:= x1;
      setscrly1:= y1;
      setscrlx2:= x2;
      setscrly2:= y2;
    end;

{ Getscrl is used to get the current scroll window size }


procedure getscrl(var x1,y1,x2,y2 : byte);

    begin
      x1:= setscrlx1;
      y1:= setscrly1;
      x2:= setscrlx2;
      y2:= setscrly2;
    end;

{ Scrlup will scroll the scroll window (defigned by setscrl) up
  one line. The passed parameters "b" and "f" are the background
  and foreground colors to set the now blank line at the bottom
  of the scroll window.
 }


procedure scrlup(b,f : byte);

    begin
      with reg do
     begin
      ah:= 6;
      al:= 1;
      bh:= ((b and 7) * 16) + (f and 15);
      ch:= setscrly1 - 1; cl:= setscrlx1 - 1;
      dh:= setscrly2 - 1; dl:= setscrlx2 - 1;
     end;
      intr(16,reg);
    end;

{ Scrldn will scroll the scroll window (defigned by setscrl) down
  one line. The passed parameters "b" and "f" are the background
  and foreground colors to set the now blank line at the top of
  the scroll window.
 }

procedure scrldn(b,f : byte);

    begin
      with reg do
     begin
      ah:= 7;
      al:= 1;
      bh:= ((b and 7) * 16) + (f and 15);
      ch:= setscrly1 - 1; cl:= setscrlx1 - 1;
      dh:= setscrly2 - 1; dl:= setscrlx2 - 1;
     end;
      intr(16,reg);
    end;

{ Scrll will scroll the scroll window (defigned by setscrl) left
  one line. The passed parameters "b" and "f" are the background
  and foreground colors to set the now blank line at the left of
  the scroll window.
 }

procedure scrll(b,f : byte);

    var
      x,y : byte;

    begin
      for y:= setscrly1 to setscrly2 do
      for x:= setscrlx1 to setscrlx2 - 1 do
     begin
      cscreen[y,x].at:= cscreen[y,x + 1].at;
      cscreen[y,x].ch:= cscreen[y,x + 1].ch;
     end;

      for y:= setscrly1 to setscrly2 do
     begin
      cscreen[y,setscrlx2].at:= b * 16 + f;
      cscreen[y,setscrlx2].ch:= #32;
     end;
    end;

{ Scrlr will scroll the scroll window (defigned by setscrl) rigth
  one line. The passed parameters "b" and "f" are the background
  and foreground colors to set the now blank line at the right of
  the scroll window.
 }

procedure scrlr(b,f : byte);

    var
      x,y : byte;

    begin
      for y:= setscrly1 to setscrly2 do
      for x:= setscrlx2 downto setscrlx1 + 1 do
     begin
      cscreen[y,x].at:= cscreen[y,x - 1].at;
      cscreen[y,x].ch:= cscreen[y,x - 1].ch;
     end;

      for y:= setscrly1 to setscrly2 do
     begin
      cscreen[y,setscrlx1].at:= b * 16 + f;
      cscreen[y,setscrlx1].ch:= #32;
     end;
    end;


end.
