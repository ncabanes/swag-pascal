{
  Yes,  I  should have been able to imagine myself that there will be at
  least  _one_ person out there who asks for the Fade_VerticalSplitClose
  after  he  has  tried  the  Fade_HorizontalSplitClose for AniVGA V1.2,
  couldn't I?... <sigh>
  Well,  here  it  is;  for  the  bored  ones  amongst us, here's a more
  challenging question:

  What  do you expect to see when you remove the comment brackets of the
  line  in the main body part of the snippet below? --Try to answer that
  question w/o further trying! :-)

kai.rohrbacher@logo.ka.sub.org
}

{$A+,B-,D+,L+,N-,E-,O-,R-,S-,V-,G-,F-,I-,X+}
{$M 32768,0,655360}
PROGRAM Example8E;
USES ANIVGA;

CONST pic='DOG1.PIC';      {or any other PIC}
      picPal1='DOG1.PAL';
{$IFDEF VER60}
      Seg0040:WORD=$40;
{$ENDIF}

  PROCEDURE VerticalSplitClose(pa,time:WORD);
  { in: pa    = page, which contents will be made visible }
  {     time  = time (in milliseconds) for this action (approx.) }
  {out: - }
  {rem: the contents of page "pa" has been copied to page 1-PAGE }
  CONST n = (YMAX+1) DIV 2; {number of executions of the delay loop}
  VAR counter:WORD;
      ClockTicks:^LONGINT; {LONGINT ABSOLUTE $40:$6C geht nicht}
      t: LONGINT;
      temp:REAL;
      mitte,lines:INTEGER;

      p:POINTER;

  BEGIN
   ClockTicks:=Ptr(Seg0040,$6C);
   t := ClockTicks^;
   counter := 0;
   temp := 0.0182*time/n;

   mitte:=YMAX SHR 1;
   FOR lines:=0 TO mitte DO
    BEGIN
     p:= GetImage(StartVirtualX,StartVirtualY+mitte-lines,
                  StartVirtualX+XMAX,StartVirtualY+mitte,pa);
     PutImage(StartVirtualX,StartVirtualY,p,1-PAGE);
     FreeImageMem(p);

     p:= GetImage(StartVirtualX,StartVirtualY+mitte+1,
                  StartVirtualX+XMAX,StartVirtualY+mitte+1+lines,pa);
     PutImage(StartVirtualX,StartVirtualY+YMAX-lines,p,1-PAGE);
     FreeImageMem(p);

     INC(counter);
     WHILE (ClockTicks^ < (t+counter*temp)) DO BEGIN END;
    END;

   {Cleanup:}
   (* IF Odd(YMAX+1)
       THEN CopyPage(pa,1-PAGE); *)
  END;


VAR pal1:Palette;
    i:WORD;
BEGIN
 InitGraph;
 StartVirtualX:=20; StartVirtualY:=10;
 LoadBackgroundPage(pic);
 LoadPalette(picPal1,0,pal1); SetPalette(pal1,FALSE);
 FillPage(1-Page,0);
 FOR i:=1 TO 20000 DO
  PutPixel(Random(Succ(XMAX)),Random(Succ(YMAX)),Random(256));

 VerticalSplitClose(BACKGNDPAGE,2000);

 (* So what do you expect when uncommenting the following line??? *)
 (* VerticalSplitClose(1-PAGE,2000); *)

 CloseRoutines;
END.
