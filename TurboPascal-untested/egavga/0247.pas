{
The Following code is a little cheeze example of getting around the ye ol'
retrace and flicker problem. To do this all writes are made to a vitual
screen and then the whole thing is moved at once. This code has quite a
nice effect even though it almost all in pure pascal.
Enjoy: Swag ready. [g]
}

{$q-,r-,d-,b-}

PROGRAM game_sprites;
{ Slow game-sprites-example, by Bas van Gaalen, Holland, PD }
{12/20/94}
{ Modified and completely rewritten by Mr. Krinkle : Cameron Clark}
USES crt;
CONST  maxSpr=110;                         {Reduce, if program runs slugish}
       ScrSze=64000;
TYPE a_scrn= ARRAY [1..ScrSze] OF byte;
     sprite= RECORD
             xCOR,  yCOR   : word;
             width, height : byte;
             vVEL,  hVEL   : word;
             it: ARRAY[1..500]  OF byte;   {bitmap}
     END;
VAR sprites : ARRAY[1..MaxSpr] OF sprite;
    point1 : Pointer;
    point2 : ^a_scrn; {Used for screen math}
    i,j,k  : word;
PROCEDURE setpal(col,r,g,b : byte); assembler; ASM
  mov dx,03c8h; mov al,col; out dx,al; Inc dx; mov al,r
  out dx,al; mov al,g; out dx,al; mov al,b; out dx,al; END;
 
PROCEDURE putsprite( VAR spriter : sprite );
VAR i : word;
BEGIN {Update coordinates according to H&V velocity and virtual draw}
  WITH Spriter DO BEGIN
   IF  (xCOR + hVEL > 320 - width)  OR (xCOR + hVEL < 1) THEN
       hVEL:=hVEL * -1;
   IF  (yCOR + vVEL > 200 - height) OR (yCOR + vVEL < 1) THEN
       vVEL:=vVEL * -1;
   xCOR:=xCOR + hVEL;  yCOR:=yCOR + vVEL;
   FOR i:=0 TO (width * height)-1 DO
       IF  it[i+1] <> 0 THEN
       Point2^[(yCOR + (i DIV width)) * 320 +
                xCOR + (i MOD width)]:= it[i+1];
  END;
END;
 
BEGIN {*Skeleton*}
  ASM mov ax,13h; Int 10h; END;
  FOR i:=1 TO 255 DO setpal(i,255-i DIV 6,255-i DIV 4,50);
 { create and save background }
  FOR i:=0 TO (320*200)-1 DO mem[$a000:i]:=random(50)+200;
  GetMem(Point1, ScrSze);
  GetMem(point2, ScrSze);
  Move(mem[$a000:0000], Point1^, ScrSze);
  Randomize;  { create random sprite }
  FOR J:=1 TO MaxSpr DO BEGIN
      sprites[j].xCor := random(300)+1;  {Screen Pos}
      sprites[j].yCor := random(170)+1;
      sprites[j].width := random(15)+5;  {Dimensions}
      sprites[j].height := random(15)+5;
      sprites[j].hVEL := 6-random(16);   {horiz. sprite displacement}
      sprites[j].vVEL := 6-random(13);   {Vert.  sprite displacement}
      K:=random(5)+1;
      FOR i:=1 TO sprites[j].width * sprites[j].height DO BEGIN
          IF I DIV k = i / k THEN sprites[J].it[I]:= I MOD 255;
      END;
  END;
  REPEAT
    Move(Point1^, Point2^, ScrSze);         {copy Background for writing on}
    FOR J :=1 TO MaxSpr DO BEGIN
       putsprite( sprites[J] );             {virtual write to Point2}
    END;
    Move(point2^, mem[$a000:0000], ScrSze); {write Point2}
  UNTIL KeyPressed;                         {NO retrace needed}
  ASM mov ax,03h; Int 10h; END;
END.

{ASM rewrite for putSprite requested! Update it for us poor ASM
illiterates!}

