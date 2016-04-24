(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0137.PAS
  Description: New ANIVGA Fade - Horizontal
  Author: KAI ROHRBACHER
  Date: 11-26-94  04:58
*)

{
  Well,  some  guy from Scotland asked me if it is possible to do a fade
  in  AniVGA  V1.2  which  shoves in one half of a picture from the left
  side and the other half from the right side.
  As it was very easy to do so and the results indeed look GREAT, it may
  be  of  some interest for others, too, so here we go: You may add this
  routine    to    the    other    fades   as   usual;   I   called   it
  "Fade_HorizontalSplitClose  =  30;" Hopefully, I didn't mess things up
  by converting the example back to TP 6.0 & AniVGA V1.2 ...

kai.rohrbacher@logo.ka.sub.org
}

{$A+,B-,D+,L+,N-,E-,O-,R-,S-,V-,G-,F-,I-,X+}
{$M 32768,0,655360}
PROGRAM Example8D;
USES ANIVGA;

CONST pic='DOG1.PIC';      {or any other PIC}
      picPal1='DOG1.PAL';
{$IFDEF VER60}
      Seg0040:WORD=$40;
{$ENDIF}

  PROCEDURE HorizontalSplitClose(pa,time:WORD);
  { in: pa    = page, which contents will be made visible }
  {     time  = time (in milliseconds) for this action (approx.) }
  {out: - }
  {rem: the contents of page "pa" has been copied to page visualPage }
  CONST n = (XMAX+1) DIV 2; {number of executions of the delay loop}
  VAR counter:WORD;
      ClockTicks:^LONGINT; {LONGINT ABSOLUTE $40:$6C geht nicht}
      t: LONGINT;
      temp:REAL;
      mitte,columns:INTEGER;

      p:POINTER;

  BEGIN
   ClockTicks:=Ptr(Seg0040,$6C);
   t := ClockTicks^;
   counter := 0;
   temp := 0.0182*time/n;

   mitte:=XMAX SHR 1;
   FOR columns:=0 TO mitte DO
    BEGIN
     p:= GetImage(StartVirtualX+mitte-columns,StartVirtualY,
                  StartVirtualX+mitte,StartVirtualY+YMAX,pa);
     PutImage(StartVirtualX,StartVirtualY,p,1-Page);
     FreeImageMem(p);

     p:= GetImage(StartVirtualX+mitte+1,StartVirtualY,
                  StartVirtualX+mitte+1+columns,StartVirtualY+YMAX,pa);
     PutImage(StartVirtualX+XMAX-columns,StartVirtualY,p,1-Page);
     FreeImageMem(p);

     INC(counter);
     WHILE (ClockTicks^ < (t+counter*temp)) DO BEGIN END;
    END;

   {Cleanup:}
   (* IF Odd(XMAX+1)
       THEN CopyPage(pa,visualPage); *)
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

 HorizontalSplitClose(BACKGNDPAGE,2000);

 CloseRoutines;
END.


