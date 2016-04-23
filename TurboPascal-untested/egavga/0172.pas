(*

> Can anyone recomend any books/source/reference/people that would be
> necessary to read/talk to to learn how to do 3 dimensional graphics for
> 1st person game programming similar to the Wolfenstein/Doom/Flight
> simulator type games.

  If  you  can read "C", you should look out for ACK3D (a "3D" shareware
  graphic  engine)  which  comes  with  some sources. Note however, that
  neither  ACK3D nor Wolfenstein or Doom are true 3D games: They all use
  a clever technique called "raycasting".

  The  underlying  idea  of raycasting is quite simple: use a 2D program
  and  just  paste in a 3rd dimension, only for the screen display. Just
  take  a  2nd  look  at  DOOM  at you'll notice that there is no single
  location  in the map where you may have two different height-positions
  throughout  the  game.  Or more mathematically: There is no coordinate
  (x,y) in the plane for which there are more than one z-coordinate. The
  basic  map  of  such games is a normal 2D map: the player moves within
  this  plane  (which  is divided by a grid into basic "blocks") and his
  view  will  be computed for each animation frame. For example, say his
  angle  of view is 60 degrees. Then from his actual position, imaginary
  rays  will  be  sent out from -30..+30 degrees through the 2D (!) map.
  Each  ray  is  traced until it hits a block of the grid. The according
  object  will  then  be drawn to the screen at the proper position; the
  length  of  the  ray  from the player's position to the hit-point is a
  measurement  how  far  the object is from the viewer and thus, how big
  (and bright) the object should be drawn.
  As the player only moves within the (x,y) plane, there is no change of
  information  in  the  z-coordinate. Therefore, for each screen column,
  there is only one single computation necessary! (Even small changes in
  the z-coordinate could be simulated easily by shifting the column data
  a  bit). The profits are dramatic: for a screen resolution of 320x200,
  you  only  have  320  computations  (instead  of  64000)  --that's  an
  improvement of 99.5%!
  The problem with this method is the exact detection where the rays hit
  the  grid blocks. Instead of decreasing the mesh size of the grid, one
  may  think  that  the  original  blocks  consist of a second "subgrid"
  (ACK3D  uses  a  64x64  subgrid for each block). If you start counting
  blocks  row-wise,  starting  with zero, then you can compute the block
  number  and  the  relative  coordinates  (rx1,ry1)  of  a point P with
  absolute corrdinates (x1,y1) by

  b = (y1 DIV 64)*gridwidth_in_blocks + (x1 DIV 64)
  rx1 = x1 MOD 64
  ry1 = y1 MOD 64

  See the profits of powers of two for the subgrid size here?:
  b = (y1 SHR 6)*gridwidth_in_blocks + (x1 AND 63)
  rx1 = x1 AND 63
  ry1 = y1 AND 63

  Computing the collision points rays <-> blocks is pure trigonometry:
  Given are the position of the player P = (x1,y1) and his viewing angle
  alpha  (measured  from the x-axis, for example). If he is looking with
  angle of 20 degrees, one would have to compute all rays from 20-30=-10
  degrees  up  to  20+30=50  degrees.  If your screen has a width of 320
  columns, then a simple algorithm would look something like this:

column:=0
FOR beta:=alpha-30 TO alpha+30 STEP 60/320
  cast ray from P=(x1,y1) with angle beta
  IF ray hits nontransparent block b
    THEN draw block columns which we hit
         at screen position "column";
         compute distance to hit location and
         darken graphic accordingly
  ELSEIF ray leaves the plane edge
    THEN draw complete column black
  ELSE {ray runs through empty/transparent block}
    trace ray further
  INC(column)
ENDFOR

  As  we  do  have a fixed size of the game area, we do know the maximum
  length  of  a  ray  in before. If the ray's length is bigger than this
  maximum, you may stop tracing the ray any further. Using a bit college
  math  trigometry,  one  can  optimize this even further to compute the
  last   point   Q   =  (x2,y2)  on  the  ray  which  must  be  checked:
  x2:=x1+cos(beta)*diag;    y2:=y1+sin(beta)*diag;    (diag:=length   of
  diagonal of the (x,y) plane).

  Now  just  use  some  standard line-algorithm like Brensenham's on the
  line  between  P and Q and check the points if they hit a block and if
  so,  where.  Note  that  you don't have to check every point, but only
  those which lie on the grid edges!


> Can this type of program be created with Pascal or are they Assembler/C
> only areas?
  I  once  saw  a  small piece of (buggy) PASCAL code, but didn't try to
  debug it more than necessary; however, it should suffice for a start:
*)

PROGRAM RayCast2;
USES DOS, CRT;
TYPE
 { Map : 10 * 10 squares - 1 square consists of 64 * 64 units !! }
     TMap = ARRAY[1..10] OF ARRAY[1..10] OF BYTE;
     TPlayer= OBJECT
                x            ,
                y            : SHORTINT;
                ViewPoint  : INTEGER;
                MapX       ,
                Mapy       : SHORTINT;
                PROCEDURE Init;
              END;
      HeightTab = ARRAY[0..90] OF BYTE;
      WallBmp= ARRAY[0..63] OF BYTE;

CONST Up   = 1;
      Down = 2;
      Right =3;
      Left  =4;

VAR Map : TMap;
    P     : TPlayer;
    ch    : CHAR;
    xAtt  ,
    yAtt  : BYTE;
    Angle : REAL;
    Height ,
    Width  : BYTE;
    Distance: INTEGER;
    yDis   ,
    xDis   ,
    Hyp    : REAL;
    DeltaX ,
    DeltaY : REAL;
    DeltaKX,
    DeltaKY: LONGINT;
    WMapX,
    WMapY: INTEGER;
    Column ,
    XColumn,
    YColumn: SHORTINT;
    HeightTabTable : HeightTab;
    Wall        : WallBmp;
    sinus, cosinus:ARRAY[0..359] OF REAL;
    i:INTEGER;

PROCEDURE Modus(m:WORD); ASSEMBLER;
ASM
  MOV AX,m
  INT $10
END;

PROCEDURE TPlayer.Init;
BEGIN
  MapX:=2; MapY:=2;
  x:=32; y:=32;
  Angle:=0;
END;

FUNCTION init:BOOLEAN;
VAR x,y : BYTE;
    HeightTabF : FILE OF HeightTab;
BEGIN
  Modus($13);
  { Erase Map }
  FOR x:=1 TO 10 DO
    FOR y:=1 TO 10 DO
      Map[x,y]:=0;

  { Draw a few walls }
  FOR x:=1 TO 10 DO BEGIN
    Map[x,1]:=129;
    Map[x,10]:=129;
  END;
  FOR y:=1 TO 10 DO BEGIN
    Map[1,y]:=129;
    Map[4,y]:=129;
    Map[10,y]:=129;
  END;
  Map[2,3]:=129;
  { Build Character }
  P.Init;
  FOR x:=0 TO 90 DO
    HeightTabTable[x]:=90-x;

  { Different Palette }
  { JansPalette; }
  { Init Wall Bitmap }
  FOR x:=0 TO 31 DO
    Wall[x]:=100+x;
  FOR x:=32 TO 63 DO
    Wall[x]:=100-(x-32);
END;

PROCEDURE Clear; ASSEMBLER;
ASM
 CLD
 MOV AX,$A000
 MOV ES,AX
 MOV CX,32000
 XOR AX,AX
 REP STOSW
END;

PROCEDURE deInit;
BEGIN
  Modus( 3 );
END;

PROCEDURE DownProc;  { looking down }
BEGIN
  yDis:=907;
  { Step through each square }
  FOR Height:=P.MapY+1 TO 10 DO BEGIN
    Distance:= 65-P.Y + 64 * (Height-P.MapY-1);
    Hyp    := Distance / cosinus[Round(angle)];
    DeltaX := sinus[Round(angle)] * Hyp;
    IF DeltaX>MaxLongInt THEN DeltaX:=MaxLongInt;
    { Subtract when looking to the right , else add}
    IF xAtt=Right THEN
      DeltaKX:= (P.MapX-1)*64+P.X - Round(DeltaX)
    ELSE
      DeltaKX:= (P.MapX-1)*64+P.X + Round(DeltaX);

    WMapX:= DeltaKX DIV 64+1;
    XColumn:= DeltaKX MOD 64;
    WMapY:= Height;
    Hyp:=Abs(Hyp);
    { If out of bounds or wall found }
    IF (WMapX<1) OR (WMapX>10) OR (Hyp>906) OR (Map[WMapX,WMapY]>128) THEN
    BEGIN
      yDis:=Hyp;
      Height:=10;
    END
  END;
  IF (xDis>906) AND (yDis>906) THEN BEGIN
    Distance:=906;
    Column :=0;
  END ELSE
    IF yDis<xDis THEN BEGIN
      Distance:=Round(yDis);
      Column:= xColumn;
    END ELSE BEGIN
      Distance:=Round(xDis);
      Column :=yColumn;
    END;
END;

PROCEDURE UpProc;
BEGIN
  yDis:=907;
  FOR Height:=P.MapY-1 DOWNTO 1 DO BEGIN
    Distance:= -P.Y - 64 * (P.MapY-Height-1);
    Hyp    := Distance / cosinus[Round(angle)];
    DeltaX := sinus[Round(angle)] * Hyp;
    DeltaKX:= (P.MapX-1)*64+P.X- Round(DeltaX);
    WMapX:= DeltaKX DIV 64+1;
    XColumn:= DeltaKY MOD 64;
    WMapY:= Height;
    Hyp    :=ABs(Hyp);
    { If out of bounds, or wall struck }
    IF (WMapX<1) OR (WMapX>10) OR (Hyp>906) OR (Map[WMapX,WMapY]>128) THEN
BEGIN      yDis:=Hyp;
      Height:=1;
    END
  END;
  IF (xDis>906) AND (yDis>906) THEN BEGIN
    Distance:=906;
    Column:=0;
  END ELSE
    IF yDis<xDis THEN BEGIN
      Distance:=Round(yDis);
      Column:=xColumn;
    END ELSE BEGIN
      Distance:=Round(xDis);
      Column:=YColumn;
    END;

END;


PROCEDURE RightProc(angle:WORD);
BEGIN
  xDis:=907;
  FOR Width:=P.MapX+1 TO 10 DO BEGIN
    Distance:= 65-P.X + 64 * (Width-P.MapX-1);
    Hyp    := Distance / cosinus[angle];
    DeltaY := sinus[angle] * Hyp;
    IF DeltaY>MaxLongInt THEN DeltaY:=MaxLongInt;
    DeltaKY:= (P.MapY-1)*64 +P.Y -Round(DeltaY);

    WMapX:= Width;
    WMapY:= DeltaKY DIV 64 +1;
    YColumn:= DeltaKY MOD 64;
    Hyp    := Abs(Hyp);

    { If out of bounds, or wall struck }
    IF (WMapY<1) OR (WMapY>10) OR (Hyp>906) OR (Map[WMapX,WMapY]>128) THEN
BEGIN      Width:=10;
      xDis:=Hyp;
    END;
  END;
  { Now check yRay }
  CASE yAtt OF
    Down : DownProc;
    Up  : UpProc;
  END;
END;

PROCEDURE LeftProc(angle:WORD);
BEGIN
  xDis:=907;
  FOR Width:=P.MapX-1 DOWNTO 1 DO BEGIN
    Distance:= -P.X - 64 * (P.MapX-Width-1);
    Hyp    := Distance / cosinus[angle];
    DeltaY := sinus[angle] * Hyp;
    DeltaKY:= (P.MapY-1)*64 + P.Y - Round(DeltaY);

    WMapX:= Width;
    WMapY:= DeltaKY DIV 64 +1;
    YColumn:= DeltaKY MOD 64;
    Hyp    := Abs(Hyp);
    { If out of bounds, or wall struck }
    IF (WMapY<1) OR (WMapY>10) OR (Hyp>906) OR (Map[WMapX,WMapY]>128) THEN
BEGIN      Width:=1;
      xDis:=Hyp;
    END;
  END;
  { Now check yRay }
  CASE yAtt OF
    Down : DownProc;
    Up  : UpProc;
  END;
END;

PROCEDURE Proc0; { Angle = 0 degrees }
BEGIN
  WMapY:=P.MapY;
  Column:= 0;
  Distance:=907;
  FOR Width:=P.MapX+1 TO 10 DO BEGIN
    WMapX:=Width;
    IF Map[WMapX,WMapY]>128 THEN BEGIN
      Distance:=65-P.x + 64 * (Width-P.MapX-1);
      Width:=10;
      Column:=P.y;
    END;
  END;
END;

PROCEDURE Proc18; { Angle = 180 degrees }
BEGIN
  WMapY:=P.MapY;
  Column :=0;
  Distance:=907;
  FOR Width:=P.MapX-1 DOWNTO 1 DO BEGIN
    WMapX:=Width;
    IF Map[WMapX,WMapY]>128 THEN BEGIN
      Distance:=Abs( -P.X - 64 * (P.MapX-Width-1) );
      Width:=1;
      Column:=P.Y;
    END;
  END;
END;

PROCEDURE Proc27; { Angle = 270 degrees }
BEGIN
  WMapX:=P.MapX;
  Distance:=907;
  Column :=0;
  FOR Height:=P.MapY+1 TO 10 DO BEGIN
    WMapY:=Height;
    IF Map[WMapX,WMapY]>128 THEN BEGIN
      Distance:=65-P.y + 64 * (Height-P.MapY-1);
      Height:=10;
      Column:=P.Y;
    END;
  END;
END;

PROCEDURE Proc90; { Angle = 90 degrees }
BEGIN
  WMapX:=P.MapX;
  Column:=0;
  Distance:=907;
  FOR Height:=P.MapX-1 DOWNTO 1 DO BEGIN
    WMapY:=Height;
    IF Map[WMapX,WMapY]>128 THEN BEGIN
      Distance:=Abs( -P.Y - 64 * (P.MapY-Height-1)  );
      Height:=1;
      Column:=p.Y;
    END;
  END;
END;

PROCEDURE VLine(x,y1,y2:WORD; c:BYTE); ASSEMBLER;
ASM
 MOV CX,y2
 MOV DI,y1
 SUB CX,DI
 JCXZ @ende
 JG @doit
 NEG CX
 MOV DI,y2
@doit:
 MOV AX,320
 MUL DI
 ADD AX,x
 MOV DI,AX
 CLD
 MOV AL,c
 MOV DX,320
@l1:
 MOV ES:[DI],AL
 ADD DI,DX
 LOOP @l1
@ende:
END;

PROCEDURE Draw;
VAR counter: INTEGER;
    intAngle:WORD;
BEGIN
  { 70 degree viewfield (not just 60) }
  angle:=(70*160 / 320) + P.ViewPoint;
  IF angle>=360 THEN angle:=angle-360;

  FOR counter:=0 TO 319 DO BEGIN { loop each column }
   intAngle:=Round(angle);
    IF intAngle=90 THEN             { xDirection }
      xAtt:=90
    ELSE
      IF intAngle=270 THEN
        xAtt:=27
      ELSE
        IF (intAngle<90) OR (intAngle>270) THEN
          xAtt:=Right
        ELSE
          xAtt:=Left;
    IF intAngle=180 THEN            { y Direction }
      xAtt:=18
    ELSE
      IF intAngle=0 THEN
        xAtt:=0
      ELSE
        IF intAngle<180 THEN
          yAtt:=Up
        ELSE
          yAtt:=Down;

    CASE xAtt OF
      Right : RightProc(intAngle);
      Left  : LeftProc(intAngle);
      0      : Proc0;
      18     : Proc18;
      90     : Proc90;
      27     : Proc27;
    END;

    { Draw Line }
    VLine(counter,99,99-HeightTabtable[Distance DIV 10],Wall[Abs(Column)]);

    { decrease angle }
    angle:=angle- (70 / 320);
    IF angle<0 THEN angle:=angle+360;
  END; { next column }
END;

BEGIN
  FOR i:=0 TO 359 DO
   BEGIN
    cosinus[i]:=cos(i*Pi/180);
    sinus[i]  :=sin(i*Pi/180);
   END;
  ch:=#1;
  IF Init THEN BEGIN
    P.ViewPoint:=90;
    REPEAT   { Loop until ESC pressed }
      Clear;
      Draw;
      ch:=ReadKey;
      CASE ch OF
        'a' : BEGIN  { Left turn }
                Inc(P.ViewPoint,5);
                IF P.ViewPoint>359 THEN P.ViewPoint:=P.ViewPoint-360;
              END;
        's' : BEGIN {right turn }
                Dec(P.ViewPoint,5);
                IF P.ViewPoint<0 THEN P.ViewPoint:=P.ViewPoint+360;
              END;
        'w' : BEGIN { Move forward }
                Dec(P.y,2);
                IF P.y<1 THEN BEGIN
                  Dec(P.MapY);
                  P.y:=64+P.y;
                END;
              END;
        'y' : BEGIN {Move backward }
                Inc(P.y,2);
                IF P.y>64 THEN BEGIN
                  Inc(P.MapY);
                  P.y:=P.y-64;
                END;
              END;
      END;

    UNTIL ch=#27;
    DeInit;
  END;
END.
