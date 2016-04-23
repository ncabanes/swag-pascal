{
> I'm using 320x200x256.  I use mainly assembly to do my procedures and
> function in this library... but I can't manage to figure out a way to do
> GET and PUTs ... have ny Idea how to do it?  And yes, if you have any nice
> graphic procedures/functions, well, I'm interrested...

Ok, if you want, I can post a bitmap scaler I got from Sean Palmer... it's in
assembler, so it's fast, and you could use it just like put, except it doesn't
do "transparency."  If I ever figure out how to do it, I'll modify it and post
it.  But for now, here are some other routines for mode 13h:
}

TYPE
  RGBPalette = ARRAY[0..767] OF Byte;

PROCEDURE SetVideoMode(desiredVideoMode : Byte);
BEGIN ASM MOV AH,0; MOV AL,desiredVideoMode; INT $10; END; END;

FUNCTION GetPixel(pix2get_x, pix2get_y : Word) : Byte;
BEGIN GetPixel := Mem[$A000 : pix2get_y * 320 + pix2get_x]; END;

PROCEDURE SetPixel(pix2set_x, pix2set_y : Word; pix2set_c : Byte);
BEGIN Mem[$A000 : pix2set_y * 320 + pix2set_x] := pix2set_c; END;

PROCEDURE Ellipse(exc, eyc, ea, eb : Integer);
VAR elx, ely : Integer;
  aa, aa2, bb, bb2, d, dx, dy : LongInt;
BEGIN
  elx:=0; ely:=eb; aa:=LongInt(ea)*ea; aa2:=2*aa;
  bb:=LongInt(eb)*eb; bb2:=2*bb;
  d:=bb-aa*eb+aa DIV 4; dx:=0; dy:=aa2*eb;
  SetPixel(exc, eyc-ely, Colour); SetPixel(exc, eyc+ely, Colour);
  SetPixel(exc-ea, eyc, Colour); SetPixel(exc+ea, eyc, Colour);
  WHILE (dx < dy) DO BEGIN
    IF (d > 0) THEN BEGIN
      Dec(ely); Dec(dy, aa2); Dec(d, dy);
    END;
    Inc(elx); Inc(dx, bb2); Inc(d, bb+dx);
    SetPixel(exc+elx, eyc+ely, Colour);
    SetPixel(exc-elx, eyc+ely, Colour);
    SetPixel(exc+elx, eyc-ely, Colour);
    SetPixel(exc-elx, eyc-ely, Colour);
  END;
  Inc(d, (3*(aa-bb) DIV 2-(dx+dy)) DIV 2);
  WHILE (ely > 0) DO BEGIN
    IF (d < 0) THEN BEGIN
      Inc(elx); Inc(dx, bb2); Inc(d, bb + dx);
    END;
    Dec(ely); Dec(dy, aa2); Inc(d, aa-dy);
    SetPixel(exc+elx, eyc+ely, Colour);
    SetPixel(exc-elx, eyc+ely, Colour);
    SetPixel(exc+elx, eyc-ely, Colour);
    SetPixel(exc-elx, eyc-ely, Colour);
  END;
END;

{ these routines have been "compressed" to take up less line space; I
  like spaces between addition, subtraction, etc, but I took them out
  to save space... you can add them again if you want }


PROCEDURE Line(lnx1, lny1, lnx2, lny2 : Integer);
VAR lndd, lndx, lndy, lnai, lnbi, lnxi, lnyi : Integer;
BEGIN
  IF (lnx1 < lnx2) THEN BEGIN lnxi:=1; lndx:=lnx2-lnx1;
  END ELSE BEGIN lnxi := (-1); lndx:= lnx1-lnx2; END;
  IF (lny1 < lny2) THEN BEGIN lnyi:=1; lndy:=lny2-lny1;
  END ELSE BEGIN lnyi := (-1); lndy:=lny1-lny2; END;
  SetPixel(lnx1, lny1, Colour);
  IF (lndx > lndy) THEN BEGIN
    lnai:=(lndy-lndx)*2; lnbi:=lndy*2; lndd:=lnbi-lndx;
    REPEAT
      IF (lndd >= 0) THEN BEGIN
        Inc(lny1, lnyi);
        Inc(lndd, lnai);
      END ELSE Inc(lndd, lnbi);
      Inc(lnx1, lnxi);
      SetPixel(lnx1, lny1, Colour);
    UNTIL (lnx1 = lnx2);
  END ELSE BEGIN
    lnai := (lndx - lndy) * 2;
    lnbi := lndx * 2;
    lndd := lnbi - lndy;
    REPEAT
      IF (lndd >= 0) THEN BEGIN
        Inc(lnx1, lnxi);
        Inc(lndd, lnai);
      END ELSE inc(lndd, lnbi);
      Inc(lny1, lnyi);
      SetPixel(lnx1, lny1, Colour);
    UNTIL (lny1 = lny2);
  END;
END;

PROCEDURE GetPalette(index2get : Byte; VAR r_inte, g_inte, b_inte : Byte);
{ returns the r, g, and b values of a palette index }
BEGIN
  Port[$3C7] := index2get;
  r_inte := Port[$3C9];
  g_inte := Port[$3C9];
  b_inte := Port[$3C9];
END;

PROCEDURE SetPalette(index2set, r_inte, g_inte, b_inte : Byte);
{ sets the r, g, and b values of a palette index }
BEGIN
  Port[$3C8] := index2set;
  Port[$3C9] := r_inte;
  Port[$3C9] := g_inte;
  Port[$3C9] := b_inte;
END;

{ oh, I'll give credit where credit is due: Sean Palmer supplied the
  Bresenham line and ellipse procedures }


PROCEDURE BurstSetPalette(burstPalette : RGBPalette);
VAR
  burstCount : Word;
BEGIN
  Port[$3C8] := 0;
  FOR burstCount := 0 TO 767 DO Port[$3C9] := burstPalette[burstCount];
END;

PROCEDURE WaitForRetrace;
{ waits for a vertical retrace to reduce flicker }
BEGIN
     (* REPEAT UNTIL (Port[$3DA] AND $08) = 0; *)
     { the above loop has been commented because it is only }
     { necessary to wait until a retrace is in progress }
     REPEAT UNTIL (Port[$3DA] AND $08) <> 0;
END;

PROCEDURE ClearScr;
BEGIN
     FillChar(Mem[$A000:0000], 64000, 0);
END;

FUNCTION GetOverscan : Byte;
VAR
  tmpOverscanByte : Byte;
BEGIN
  ASM
    MOV AX,$1008
    INT $10
    MOV tmpOverscanByte,BH
  END;
  GetOverscan := tmpOverscanByte;
END;

PROCEDURE SetOverscan(borderColour : Byte);
BEGIN
  ASM
    MOV AX,$1001
    MOV BH,borderColour
    INT $10
  END;
END;

{
Well, that's basically it, except for the bitmap scaler.  If you want it, let
me know if you can receive NetMail, and I'll send it that way; otherwise, I'll
post.  The last two procedures/functions have not been tested.  In fact, I
can't guarantee that any of the stuff will work.  But try it out...  :^)
C-YA.
}