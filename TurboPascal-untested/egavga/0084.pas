{
> I'm trying to find out a way to do GET and PUT of sections of the screen
> into a variable... but the method I'm using is too slow and I cannot truly
> store it in a variable (it does a .INC program that you link with your
> files...).

Well, the most simple attempt would probably be something like....
}

PROGRAM bitmap_images;

USES
  CRT,
  some_mode13h_routs;

VAR
  screen : ARRAY [0..199,0..319] OF BYTE ABSOLUTE $a000:0000;
  imgptr : POINTER;
  ch     : CHAR;

PROCEDURE get_image(p:POINTER;xp,yp:WORD;xs,ys:BYTE);
VAR
  s,o   : WORD;
BEGIN
  s:=SEG(p^);
  o:=OFS(p^);
  FOR yp:=yp TO PRED(yp+ys)
  DO BEGIN
    MOVE(screen[yp,xp],MEM[s:o],xs);
    INC(o,xs);
  END;
END;

PROCEDURE put_image(p:POINTER;xp,yp:WORD;xs,ys:BYTE);
VAR
  s,o   : WORD;
BEGIN
  s:=SEG(p^);
  o:=OFS(p^);
  FOR yp:=yp TO PRED(yp+ys)
  DO BEGIN
    MOVE(MEM[s:o],screen[yp,xp],xs);
    INC(o,xs);
  END;
END;

BEGIN
  init_mode($13);               { init mode 13h }
  load_piccy('some.gfx');       { load some picture }
  GETMEM(imgptr,160*100);       { allocate memory for bitmap }
  get_image(p,0,0,160,100);     { get left part of screen }
  put_image(p,160,0,160,100);   { copy to right part of screen }
  FREEMEM(imgptr,160*100);      { release memory }
  ch:=READKEY;                  { wait for a key }
  init_mode($03);               { back to textmode }
END.
