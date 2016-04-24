(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0005.PAS
  Description: A Color Star Field
  Author: SWAG SUPPORT TEAM
  Date: 07-16-93  06:47
*)

{-------------------------- SCHNIPP -----------------------------}

{STARSCROLL.PAS geaenderte Fassung  }

{$A+,B-,D-,E-,F+,I+,L-,N-,O-,R-,S-,V-}
{$M 64000,0,655360}

USES crt,graph,BGIDriv;                 {ich binde die Treiber ein}

CONST MaxStars=500;                     {auf meinem 386-25er muss ich in
                                        der geaenderten Fassung schon 500
                                        Sterne eintragen, damit es nur noch
                                        ein wenig schneller ist als die alte
                                        Fassung mit 100 Sternen ;-)}

TYPE Punkt=ARRAY[1..3] OF INTEGER;     {Siehe ganz unten Move()}

VAR
   gd,gm,mpx,mpy,scal,a,b,e:integer;
   Stars1,Stars:ARRAY[1..MaxStars] OF Punkt;

   mx,my,m2x,m2y,sop,                   {siehe Init}
   act:INTEGER;

PROCEDURE dpunkt( x,y,z, Col:integer);
VAR n:INTEGER;
  BEGIN
   n:=z+e;

   {n=Nenner, nur einmal berechnen, geht schneller}

   PutPixel(mpx+ (scal*x div n),mpy+ (scal*y div n),col);

                 {hier nur integer-operationen}
  END;

PROCEDURE dline( x1,y1,z1,x2,y2,z2:integer);
VAR n1,n2:INTEGER;
  BEGIN
   n1:=z1+e;n2:=z2+e;  {n1=Nenner fuer 1.Punkt, n2=Nenner fuer 2.Punkt}

   Line(mpx+(scal*(x1 div n1)),mpy+(scal*(y1 div n1)),
        mpx+(scal*(x2 div n2)),mpy+(scal*(y2 div n2)));

      {Nix mit Round(xxx / nX), dauert zu lange: Integer ->Real ->Integer}
  END;

PROCEDURE Init;
begin
 act:=1;
 e:=1;
 scal := 2;

 mx:=getmaxx;     {damit man es auch in EgaLo oder anderen GModes}
 m2x:=mx shr 1;   {betreiben kann, alle Werte abhaengig von MaximalX und}
 my:=getmaxy;     {MaximalY}
 m2y:=my shr 1;
 mpx:=m2x;
 mpy:=m2y-(mpy shr 1);

 sop:=sizeof(punkt);  {Schreibt sich leichter :-) }
end;

BEGIN
  Randomize;
  gd:=ega;
  gm:=egahi;

  if RegisterBGIdriver(@EgaVgaDriverProc) < 0 then halt(255);

  InitGraph(gd,gm,'');  {oder InitGraph(gd,gm,'PathToDriver');}
  Init;
  FOR a:=0 TO 15 DO  SetRGBPalette(a,a*3,a*3,a*3);
  FOR a:=1 TO MaxStars DO
    BEGIN
      Stars[a,1]:=Random(mx)-m2x;
      Stars[a,2]:=Random(my)-m2y;
      Stars[a,3]:=Random(30)+1;
    END;

  Move(Stars,Stars1,SoP*MaxStars);      {man sollte Stars1 initialisieren}
                                        {wenn man es benutzt}
  SetColor(15);
  SetVisualPage(act);

  {AB hier kommt es auf Geschwindigkeit an}

  REPEAT
            {IF act=0 THEN act:=1 ELSE act:=0; dauert zu lange, deshalb:}
            {wenn (act)=1 -> act:=1-(1) = 0  wenn (act)=0 -> act:=1-(0)=1}
    act:=1-act;

    SetActivePage(act);
    FOR a:= 1 TO MaxStars DO
    BEGIN
      Stars[a,3]:=Stars[a,3]-1;
      IF stars[a,3]= 0 THEN
      BEGIN
        Stars[a,1]:=Random(mx)-m2x;
        Stars[a,2]:=Random(my)-m2y;
        Stars[a,3]:=30;
      END;
      dpunkt(Stars[a,1],Stars[a,2],Stars[a,3],15-(stars[a,3] shr 1));

                        {round(xxx/2) dauert zu lange {shr 1 = div 2 }
    END;
    SetVisualPage(act);

    act:=1-act;   {s.o.}

    SetActivePage(act);
    FOR a:=1 TO MaxStars DO
    BEGIN
      dpunkt(Stars1[a,1],Stars1[a,2],Stars1[a,3],0);

      {Wenn man Stars1 nicht initialisierst kommt es schon mal vor, dass
       man einen Division by Zero Error beim ersten beim 1. Aufruf erhaelt}

      move(stars[a],stars1[a],sop);

      {nicht einzeln uebertragen, Move ist schneller, deshalb auch Type Punkt}

    END;

    act:=1-act; {s.o.}

  UNTIL KeyPressed;

  closegraph;          {Nicht vergessen !!!! ;-) }
END.

{------------------------- SCHNAPP --------------------------------------}


