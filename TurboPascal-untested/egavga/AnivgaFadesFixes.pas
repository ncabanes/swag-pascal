(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0138.PAS
  Description: ANIVGA Fades - Fixes
  Author: KAI ROHRBACHER
  Date: 11-26-94  04:58
*)

(*
> Here are some ANIVGA v1.2 fades I am releasing to public domain:
> { FEB-01-94 Added more FadeIn routines: Curtains, Blinds.  MaxFade CONST. }
  As  I posted some time ago, there's a bug in the GetImage() routine in
  V1.2  (which  can  easily  be  fixed by adding "dec(x1,StartVirtualX);
  dec(y1,StartVirtualY);  dec(x2,StartVirtualX); dec(y2,StartVirtualY);"
  at the beginning of the GetImage() procedure).
  If you did so, you can code your fade's kernel as follows:

  kai.rohrbacher@logo.ka.sub.org
*)

PROCEDURE SweepOutVertical(pa, time: WORD; seam: BOOLEAN);    {JH New! }
{ in: pa    = page, which contents will be made visible }
{     time  = time (in milliseconds) for this action (approx.) }
{     seam  =TRUE/FALSE for: show curtain seam in actual drawing color}
{     color =seam color (if seam=TRUE)}
{     1-PAGE= (visible) graphic page on which to draw }
{out: - }
{rem: the contents of page "pa" has been copied to page 1-PAGE }
CONST n=Succ(YMAX);      {number of executions of the delay loop }
      centerY = YMAX DIV 2; {middle of screen }
VAR y, counter: WORD;
    ClockTicks: LONGINT ABSOLUTE $40:$6C;
    t: LONGINT;
    temp: REAL;
    p1: POINTER;
    p2: POINTER;
BEGIN {SweepOutVertical}
 t := ClockTicks;
 counter := 0;
 temp := 0.0182*time/n;

 {upward }
 FOR y := centerY DOWNTO 0 DO
  BEGIN
   IF seam
    THEN BEGIN
          Line(StartVirtualX,y+StartVirtualY,
               StartVirtualX+XMAX,y+StartVirtualY,1-PAGE);
           {downward }
          Line(StartVirtualX,YMAX-y+StartVirtualY,
               StartVirtualX+XMAX,YMAX-y+StartVirtualY,1-PAGE);
         END;
   INC(counter);
   WHILE (ClockTicks < (t+counter*temp)) DO BEGIN END;
 {upward }
   p2 := GetImage(StartVirtualX,y+StartVirtualY,
                  StartVirtualX+XMAX,y+StartVirtualY,pa);
   PutImage(StartVirtualX,y+StartVirtualY,p2,1-PAGE);
   FreeImageMem(p2);
 {downward }
   p1 := GetImage(StartVirtualX,YMAX-y+StartVirtualY,
                  StartVirtualX+XMAX,YMAX-y+StartVirtualY,pa);
   PutImage(StartVirtualX,YMAX-y+StartVirtualY,p1,1-PAGE);
   FreeImageMem(p1);
  END;
END;  {SweepOutVertical}

PROCEDURE SweepOutHorizontal(pa, time: WORD; seam: BOOLEAN);  {JH New! }
{ in: pa    = page, which contents will be made visible }
{     time  = time (in milliseconds) for this action (approx.) }
{     seam  =TRUE/FALSE for: show curtain seam in actual drawing color}
{     color =seam color (if seam=TRUE)}
{     1-PAGE= (visible) graphic page on which to draw }
{out: - }
{rem: the contents of page "pa" has been copied to page 1-PAGE }
CONST n = Succ(XMAX);      {number of executions of the delay loop }
      centerX = XMAX DIV 2; {middle of screen }
VAR x, counter: WORD;
    ClockTicks: LONGINT ABSOLUTE $40:$6C;
    t: LONGINT;
    temp: REAL;
    p1: POINTER;
    p2: POINTER;
BEGIN {SweepOutHorizontal}
 t := ClockTicks;
 counter := 0;
 temp := 0.0182*time/n;

 {right_to_left }
 FOR x := centerX DOWNTO 0 DO
  BEGIN
   IF seam
    THEN BEGIN
          Line(x+StartVirtualX,StartVirtualY,
               x+StartVirtualX,StartVirtualY+YMAX,1-PAGE);
          {left_to_right }
          Line(XMAX-x+StartVirtualX,StartVirtualY,
               XMAX-x+StartVirtualX,StartVirtualY+YMAX,1-PAGE);
         END;
   INC(counter);
   WHILE (ClockTicks < (t+counter*temp)) DO BEGIN END;
 {right_to_left }
   p2 := GetImage(x+StartVirtualX,StartVirtualY,
                  x+StartVirtualX,StartVirtualY+YMAX,pa);
   PutImage(x+StartVirtualX,StartVirtualY,p2,1-PAGE);
   FreeImageMem(p2);
 {left_to_right }
   p1 := GetImage(XMAX-x+StartVirtualX,StartVirtualY,
                  XMAX-x+StartVirtualX,StartVirtualY+YMAX,pa);
   PutImage(XMAX-x+StartVirtualX,StartVirtualY,p1,1-PAGE);
   FreeImageMem(p1);
  END;
END;  {SweepOutHorizontal}

...and they will work with any (StartVirtualX,StartVirtualY) values.
(I  omitted  the "color:=white" stuff so that the seam is drwan in the
actual drawing color).


BTW:  As we are talking about fades, here's another one, check it out!
With  this one, the picture creeps out from the middle line to the top
and bottom (as if you look at an image folded at its middle line which
becomes opened slowly).
I  saw  that one in the opening sequence of EPIC's OVERKILL, and found
it looks nice.

PROCEDURE VerticalExpand(pa,time:WORD);
{ in: pa    = page, which contents will be made visible }
{     time  = time (in milliseconds) for this action (approx.) }
{out: - }
{rem: the contents of page "pa" has been copied to page visualPage }
CONST n = (YMAX+1)*(YMAX+1) DIV 8; {number of executions of the delay loop}
VAR ClockTicks:^LONGINT; {LONGINT ABSOLUTE $40:$6C geht nicht}
    t: LONGINT;
    temp,mitte,step,akku:REAL;
    lines,y:INTEGER;

 PROCEDURE CopyLine(von,nach:WORD);
 { in: von = zu kopierende Zeile von Seite pa}
 {     nach= Zielzeile in Seite visualPage dafuer}
 VAR p1:POINTER;
 BEGIN
  p1 := GetImage(StartVirtualX,von+StartVirtualY,
                 StartVirtualX+XMAX,von+StartVirtualY,pa);
  PutImage(StartVirtualX,nach+StartVirtualY,p1,visualPage);
  FreeImageMem(p1);
 END;

BEGIN
 ClockTicks:=Ptr(Seg0040,$6C);
 t := ClockTicks^;
 counter := 0;
 temp := 0.0182*time/n;

 mitte:=YMAX/2;
 FOR lines:=1 TO ((YMAX+1) SHR 1)-1 DO
  BEGIN
   step:=YMAX/(lines SHL 1);
   akku:=step;
   FOR y:=0 TO lines-1 DO
    BEGIN
     CopyLine(TRUNC(mitte-akku),(YMAX+1) SHR 1 -y-1);
     CopyLine(TRUNC(mitte+akku),(YMAX+1) SHR 1 +y);
     akku:=akku+step;
     INC(counter);
     WHILE (ClockTicks^ < (t+counter*temp)) DO BEGIN END;
    END;
  END;

 {Cleanup:}
 lines:=YMAX SHR 1;
 FOR y:=0 TO YMAX SHR 1 DO
  BEGIN
   CopyLine( lines-y,lines-y);
   CopyLine( lines+y,lines+y);
   INC(counter);
   WHILE (ClockTicks^ < (t+counter*temp)) DO BEGIN END;
  END;
 IF Odd(YMAX)
  THEN CopyLine(YMAX,YMAX);
END;
{
  I  gave  it  the fade constant "Fade_VerticalExpand=29", so in routine
  FadeIn() extend the CASE clause by:
     Fade_VerticalExpand: VerticalExpand(pa,ti);
}


