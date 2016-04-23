{

Date: 07-03-94 (04:34)              Number: 131410 of 132082 (Refer# NONE)
  To: KERRY SOKALSKY
From: MARTIN_P@EFN.EFN.ORG
Subj: Re: SWAG
Read: 07-04-94 (01:01)              Status: RECEIVER ONLY
Conf: Internet_Mail (104)        Read Type: READING ALL (+)

From: Martin Preishuber <martin_p@efn.efn.org>

postscrp.pas unit, to create postscript files.. it includes the
  common commands like line, outtext and so on
psdemo.pas demo program for postscrp.pas. i made it to show, how
  to use the PSSetViewPort and PSOpen-commands.

}

PROGRAM PSDemo;

USES Postscrp;

BEGIN
  PSSetViewPort(0, 0, 21, 29.7);
  PSOpen('test.ps', 0, 479, 639, 479);
  PSTextSettings('Times-Roman', 40);
  PSOutTextXY(100, 100, 'Test');
  PSClose;
END.


UNIT PostScrp;

INTERFACE

USES Dos, Graph;

TYPE Viereck = ARRAY[1..4] OF PointType;
     Polygon = ARRAY[1..100] OF PointType;

PROCEDURE PSSetViewPort(x1, y1, x2, y2 : REAL);
PROCEDURE PSSetGray(intensity : REAL);
PROCEDURE PSSetCmykColor(cyan, magenta, yellow, black : REAL);
PROCEDURE PSSetRGBColor(rot, gruen, blau : REAL);
PROCEDURE PSSetHsbColor(hue, saturation, brightness : REAL);
PROCEDURE PSTextSettings(font : STRING; groesse : WORD);
PROCEDURE PSTextAngle(angle : REAL);
PROCEDURE PSOuttextxy(x, y : REAL; s : STRING);
PROCEDURE PSWriteNum(x, y, num : REAL);
PROCEDURE PSCircle(x, y, radius : REAL);
PROCEDURE PSLineWidth(x : REAL);
PROCEDURE PSLine(x1, y1, x2, y2 : REAL);
PROCEDURE PSRectangle(x1, y1, x2, y2 : REAL);
PROCEDURE PSMoveTo(x, y : REAL);
PROCEDURE PSLineTo(x, y : REAL);
PROCEDURE PSBar(x1, y1, x2, y2  : REAL);
PROCEDURE PsFillViereck(VAR points : Viereck);
PROCEDURE PSFillPoly(anzahl : BYTE; VAR PolyPoints : Polygon);
PROCEDURE PSOpen(filename : STRING; ursprx, urspry, maxx, maxy : WORD);
PROCEDURE PSClose;
FUNCTION PSError : BOOLEAN;
FUNCTION PixelToZoll(x : REAL) : WORD;

IMPLEMENTATION

CONST einheit = 2.54/72;
      faktor = 3/140;

VAR psfile : Text;
    error : BOOLEAN;
    dx, dy,
    ux1, uy1,
    xdim, ydim,
    diffx, diffy : REAL;
    newviewport : BOOLEAN;

FUNCTION PSError : BOOLEAN;
BEGIN
  PSError := error;
END;

PROCEDURE PSSetViewPort(x1, y1, x2, y2 : REAL);
VAR breite,hoehe : REAL;
BEGIN
  breite := x2 - x1;
  IF breite <= 0 THEN breite := 15;
  hoehe := y2 - y1;
  IF hoehe <= 0 THEN hoehe := 15;
  ux1 := x1 / einheit;
  uy1 := y1 / einheit;
  xdim := breite / einheit;
  ydim := hoehe / einheit;
  newviewport := TRUE;
END;

PROCEDURE PSSetGray(intensity : REAL);
BEGIN
  WriteLn(psfile, intensity:4:2, ' sg');
END;

PROCEDURE PSSetRGBColor(rot, gruen, blau : REAL);
BEGIN
  WriteLn(psfile, rot:4:2, ' ', gruen:4:2, ' ', blau:4:2, ' sr');
END;

PROCEDURE PSSetCmykColor(cyan, magenta, yellow, black : REAL);
BEGIN
  WriteLn(psfile,cyan:4:2, ' ', magenta:4:2, ' ', yellow:4:2, ' ', black:4:2,'
sc');
END;

PROCEDURE PSSetHsbColor(hue, saturation, brightness : REAL);
BEGIN
  WriteLn(psfile, hue:4:2, ' ', saturation:4:2, ' ', brightness:4:2, ' sh');
END;

FUNCTION PixelToZoll(x : REAL) : WORD;
BEGIN
  PixelToZoll := Round(x * dx);
END;

PROCEDURE PSTextSettings(font : STRING; groesse : WORD);
BEGIN
  WriteLn(psfile, '/', font, ' findfont ',groesse,' scalefont setfont');
END;

PROCEDURE PSTextAngle(angle : REAL);
BEGIN
  WriteLn(psfile, angle:4:2,' rotate');
END;

PROCEDURE PSOuttextxy(x,y : REAL; s : STRING);
BEGIN
  x := x - diffx;
  y := diffy - y;
  WriteLn(psfile, x * dx:4:2, ' ', y * dy:4:2, ' m');
  WriteLn(psfile, '(',s,')', ' show');
END;

PROCEDURE PSWriteNum(x, y, num : REAL);
VAR help : STRING;
BEGIN
  x := x - diffx;
  y := diffy - y;
  Str(num:4:2, help);
  WriteLn(psfile, x * dx:4:2, ' ', y * dy:4:2, ' m');
  WriteLn(psfile, '(',help,')', ' show');
END;

PROCEDURE PSCircle(x, y, radius : REAL);
BEGIN
  x := x - diffx;
  y := diffy - y;
  WriteLn(psfile, x * dx:4:2, ' ', y * dy:4:2, ' ', radius:4:2, ' 0 360 arc
s');
END;

PROCEDURE PSLineWidth(x : REAL);
BEGIN
  WriteLn(psfile, x:4:2, ' setlinewidth');
END;

PROCEDURE PSLine(x1, y1, x2, y2 : REAL);
BEGIN
  x1 := x1 - diffx;
  y1 := diffy - y1;
  x2 := x2 - diffx;
  y2 := diffy - y2;
  WriteLn(psfile, x1 * dx:4:2, ' ', y1 * dy:4:2, ' m');
  WriteLn(psfile, x2 * dx:4:2, ' ', y2 * dy:4:2, ' l s');
END;

PROCEDURE PSRectangle(x1, y1, x2, y2 : REAL);
VAR xn1, xn2, yn1, yn2 : REAL;
BEGIN
  x1 := x1 - diffx;
  y1 := diffy - y1;
  x2 := x2 - diffx;
  y2 := diffy - y2;
  xn1 := x1 * dx;
  yn1 := y1 * dy;
  xn2 := x2 * dx;
  yn2 := y2 * dy;
  WriteLn(psfile, 'n');
  WriteLn(psfile, xn1:4:2, ' ', yn1:4:2, ' m');
  WriteLn(psfile, xn2:4:2, ' ', yn1:4:2, ' l');
  WriteLn(psfile, xn2:4:2, ' ', yn2:4:2, ' l');
  WriteLn(psfile, xn1:4:2, ' ', yn2:4:2, ' l');
  WriteLn(psfile, 'c s');
END;

PROCEDURE PSMoveTo(x, y : REAL);
BEGIN
  x := x - diffx;
  y := diffy - y;
  WriteLn(psfile, x * dx:4:2, ' ', y * dy:4:2, ' m');
END;

PROCEDURE PSLineTo(x, y : REAL);
BEGIN
  x := x - diffx;
  y := diffy - y;
  WriteLn(psfile, x * dx:4:2, ' ', y * dy:4:2, ' l');
END;

PROCEDURE PSBar(x1, y1, x2, y2 : REAL);
VAR xn1, xn2, yn1, yn2 : REAL;
BEGIN
  x1 := x1 - diffx;
  y1 := diffy - y1;
  x2 := x2 - diffx;
  y2 := diffy - y2;
  xn1 := x1 * dx;
  yn1 := y1 * dy;
  xn2 := x2 * dx;
  yn2 := y2 * dy;
  WriteLn(psfile, 'n');
  WriteLn(psfile, xn1:4:2, ' ', yn1:4:2, ' m');
  WriteLn(psfile, xn2:4:2, ' ', yn1:4:2, ' l');
  WriteLn(psfile, xn2:4:2, ' ', yn2:4:2, ' l');
  WriteLn(psfile, xn1:4:2, ' ', yn2:4:2, ' l');
  WriteLn(psfile, 'c');
  WriteLn(psfile, 'f');
END;

PROCEDURE PsFillViereck(VAR points : Viereck);
BEGIN
  WriteLn(psfile, 'n');
  WriteLn(psfile, (points[1].x - diffx) * dx:4:2, ' ', (diffy - points[1].y) *
dy:4:2, ' m');
  WriteLn(psfile, (points[2].x - diffx) * dx:4:2, ' ', (diffy - points[2].y) *
dy:4:2, ' l');
  WriteLn(psfile, (points[3].x - diffx) * dx:4:2, ' ', (diffy - points[3].y) *
dy:4:2, ' l');
  WriteLn(psfile, (points[4].x - diffx) * dx:4:2, ' ', (diffy - points[4].y) *
dy:4:2, ' l');
  WriteLn(psfile, 'c');
  WriteLn(psfile, 'f');
END;

PROCEDURE PSFillPoly(anzahl : BYTE; VAR PolyPoints : Polygon);
VAR i : BYTE;
BEGIN
  IF anzahl = 1 THEN
  ELSE
    IF anzahl=2 THEN
      PSLine(PolyPoints[1].x, PolyPoints[1].y, PolyPoints[2].x,
PolyPoints[2].y)
    ELSE
      BEGIN
        WriteLn(psfile, 'n');
        WriteLn(psfile, (PolyPoints[1].x - diffx) * dx:4:2, ' ', (diffy -
PolyPoints[1].y) * dy:4:2, ' m');
        FOR i := 2 TO anzahl DO
          WriteLn(psfile, (PolyPoints[i].x - diffx) * dx:4:2, ' ', (diffy -
PolyPoints[i].y) * dy:4:2, ' l');
        WriteLn(psfile, 'c');
        WriteLn(psfile, 'f');
      END;
END;

PROCEDURE PSOpen(filename : STRING; ursprx, urspry, maxx, maxy : WORD);
BEGIN
  error:=FALSE;
  Assign(psfile,filename);
  {$I-}
  Rewrite(psfile);
  {$I+}
  IF IOResult<>0 THEN
    error:=FALSE
  ELSE
    BEGIN
      diffx:=ursprx;
      diffy:=urspry;
      IF newviewport THEN
        BEGIN
          WriteLn(psfile,'%!PS-Adobe-2.0');
          WriteLn(psfile,'/l',' ','{ lineto } def');
          WriteLn(psfile,'/li',' ','{ line } def');
          WriteLn(psfile,'/m',' ','{ moveto } def');
          WriteLn(psfile,'/f',' ','{ fill } def');
          WriteLn(psfile,'/n',' ','{ newpath } def');
          WriteLn(psfile,'/c',' ','{ closepath } def');
          WriteLn(psfile,'/s',' ','{ stroke } def');
          WriteLn(psfile,'/sr',' ','{ setrgbcolor } def');
          WriteLn(psfile,'/sh',' ','{ sethsbcolor } def');
          WriteLn(psfile,'/sc',' ','{ setcmykcolor } def');
          WriteLn(psfile,'/sg',' ','{ setgray } def');
          WriteLn(psfile,ux1:4:2,' ',uy1:4:2,' ','translate');
          dx:=xdim/maxx;
          dy:=ydim/maxy;
        END
      ELSE
        BEGIN
          dx:=800/maxx;
          dy:=750/maxy;
        END;
      WriteLn(psfile,'n');
    END;
END;

PROCEDURE PSClose;
BEGIN
  WriteLn(psfile,'showpage');
  {$I-}
  Close(psfile);
  {$I+}
  IF IOResult<>0 THEN error:=TRUE;
END;

BEGIN
  newviewport:=FALSE;
END.

