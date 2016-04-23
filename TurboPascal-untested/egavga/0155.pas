{
I went ahead and wrote a fade_HorizontalExpand using Kai
Rohrbacher's fade_VerticalExpand as a guide.  The fade was too slow, so I
reduced the detailed inner loop and had the clean-up complete the effect.
}
PROCEDURE HorizontalExpand(pa, time: WORD);                          { JH }
{ in: pa    = page, which contents will be made visible }
{     time  = time (in milliseconds) for this action (approx.) }
{out: - }
{rem: the contents of page "pa" has been copied to page visualPage }
{jh "n" was (YMAX+1)*(YMAX+1) DIV 8 = 5000}
CONST n = 2000; {number of executions of the delay loop}
VAR ClockTicks:^LONGINT;
    counter: WORD;
    t: LONGINT;
    temp, middle, step, akku: REAL;
    lines, x: INTEGER;

   PROCEDURE CopyLine(from, dest: WORD);
   { in: from = to duplicate line from page pa}
   {     dest = endline in page visualPage differ}
   VAR p1:POINTER;
   BEGIN
     p1 := GetImage(from+StartVirtualX,StartVirtualY,
                    from+StartVirtualX,StartVirtualY+YMAX,pa);
     PutImage(dest+StartVirtualX,StartVirtualY,p1, 1-Page); {jh visualPage}
     FreeImageMem(p1);
   END;  {CopyLine}

BEGIN
 ClockTicks := Ptr(Seg0040,$6C);
 t := ClockTicks^;
 counter := 0;
 temp := 0.0182*time/n;

 middle := XMAX/2;
 {jh FOR lines := 1 TO ((XMAX+1) SHR 1)-1 DO =159}
 FOR lines := 1 TO 99 DO
  BEGIN
   step := XMAX/(lines SHL 1);
   akku := step;
   FOR x := 0 TO lines-1 DO
    BEGIN  {jh The SHR 1 handling is for only two Copylines at a time}
     CopyLine( TRUNC(middle-akku),(XMAX+1) SHR 1 -x-1);
     CopyLine( TRUNC(middle+akku),(XMAX+1) SHR 1 +x);
     akku := akku + step;
     INC(counter);
     WHILE (ClockTicks^ < (t+counter*temp)) DO BEGIN END;
    END;
  END;

 {Cleanup:}
 lines := XMAX SHR 1;
 FOR x := 0 TO XMAX SHR 1 DO
  BEGIN
   CopyLine( lines-x,lines-x);
   CopyLine( lines+x,lines+x);
   INC(counter);
   WHILE (ClockTicks^ < (t+counter*temp)) DO BEGIN END;
  END;
 IF Odd(XMAX)
  THEN CopyLine(XMAX,XMAX);
END;  {HorizontalExpand}
