{
From: BERNIE PALLEK
Subj: GRAF_13H.PAS
---------------------------------------------------------------------------
}
(**************************************************)
(*                                                *)
(*         GRAPHICS ROUTINES FOR MODE 13H         *)
(*         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         *)
(*        320x200x256 (linearly-addressed)        *)
(*  Collected from routines in the Public Domain  *)
(*          Assembled by Bernie Pallek            *)
(*                                                *)
(**************************************************)

{ DISCLAIMER: Use this unit at your own risk.  I will not be liable
              for anything negative resulting from use of this unit. }

UNIT Graf_13h;

INTERFACE

CONST
  Color : Byte = 0;

TYPE
  RGBPalette = Array[0..767] of Byte;

FUNCTION  GetVideoMode : Byte;
PROCEDURE SetVideoMode(desiredVideoMode : Byte);
FUNCTION  GetPixel(pix2get_x, pix2get_y : Word) : Byte;
PROCEDURE SetPixel(pix2set_x, pix2set_y : Word; pix2set_c : Byte);
PROCEDURE Ellipse(exc, eyc, ea, eb : Integer);
PROCEDURE Line(lnx1, lny1, lnx2, lny2 : Integer);
PROCEDURE GetPalette(index2get : Byte; VAR r_inte, g_inte, b_inte : Byte);
PROCEDURE SetPalette(index2set, r_inte, g_inte, b_inte : Byte);
PROCEDURE BurstSetPalette(burstPalette : RGBPalette);
PROCEDURE ScaleBitmap(VAR bmp2scale; bwidth, bheight : Byte;
  bstrtx, bstrty, bendx, bendy : Word);
PROCEDURE WaitForRetrace;
PROCEDURE ClearScr;


IMPLEMENTATION


{ private type used by ScaleBitmap() }
TYPE
  Fixed = RECORD CASE Boolean OF
    True  : (w : LongInt);
    False : (f, i : Word);
  END;

FUNCTION GetVideoMode : Byte;
VAR
  tempVMode : Byte;
BEGIN
  ASM
    mov ah,$0f
    int $10
    mov tempvmode,al
  END;
  GetVideoMode := tempVMode;
END;

PROCEDURE SetVideoMode(desiredVideoMode : Byte);
{ desiredVideoMode = $03 : 80x25 colour text
                     $13 : 320x200x256 monoplaned
                           video data from $A000:0000 to $A000:FFFF
}
BEGIN
  ASM
    mov ah,0
    mov al,desiredvideomode;
    int $10
  END;
END;

FUNCTION GetPixel(pix2get_x, pix2get_y : Word) : Byte;
BEGIN
  GetPixel := Mem[$A000 : pix2get_y * 320 + pix2get_x];
END;

PROCEDURE SetPixel(pix2set_x, pix2set_y : Word; pix2set_c : Byte);
BEGIN
  Mem[$A000 : pix2set_y * 320 + pix2set_x] := pix2set_c;
END;

{ originally by Sean Palmer, I just mangled it  :^) }
PROCEDURE Ellipse(exc, eyc, ea, eb : Integer);
VAR
  elx, ely : Integer;
  aa, aa2, bb, bb2, d, dx, dy : LongInt;
BEGIN
  elx := 0; ely := eb; aa := LongInt(ea) * ea; aa2 := 2 * aa;
  bb := LongInt(eb) * eb; bb2 := 2 * bb;
  d := bb - aa * eb + aa DIV 4; dx := 0; dy := aa2 * eb;
  SetPixel(exc, eyc - ely, Color); SetPixel(exc, eyc + ely, Color);
  SetPixel(exc - ea, eyc, Color); SetPixel(exc + ea, eyc, Color);

  WHILE (dx < dy) DO BEGIN
    IF (d > 0) THEN BEGIN Dec(ely); Dec(dy, aa2); Dec(d, dy); END;
    Inc(elx); Inc(dx, bb2); Inc(d, bb + dx);
    SetPixel(exc + elx, eyc + ely, Color);
    SetPixel(exc - elx, eyc + ely, Color);
    SetPixel(exc + elx, eyc - ely, Color);
    SetPixel(exc - elx, eyc - ely, Color);
  END;
  Inc(d, (3 * (aa - bb) DIV 2 - (dx + dy)) DIV 2);
  WHILE (ely > 0) DO BEGIN
    IF (d < 0) THEN BEGIN Inc(elx); Inc(dx, bb2); Inc(d, bb + dx); END;
    Dec(ely); Dec(dy, aa2); Inc(d, aa - dy);
    SetPixel(exc + elx, eyc + ely, Color);
    SetPixel(exc - elx, eyc + ely, Color);
    SetPixel(exc + elx, eyc - ely, Color);
    SetPixel(exc - elx, eyc - ely, Color);
  END;
END;

{ originally by Sean Palmer, I just mangled it }
PROCEDURE Line(lnx1, lny1, lnx2, lny2 : Integer);
VAR
  lndd, lndx, lndy, lnai, lnbi, lnxi, lnyi : Integer;
BEGIN
  IF (lnx1 < lnx2) THEN BEGIN lnxi := 1; lndx := lnx2 - lnx1;
  END ELSE BEGIN lnxi := (-1); lndx := lnx1 - lnx2; END;
  IF (lny1 < lny2) THEN BEGIN lnyi := 1; lndy := lny2 - lny1;
  END ELSE BEGIN lnyi := (-1); lndy := lny1 - lny2; END;
  SetPixel(lnx1, lny1, Color);
  IF (lndx > lndy) THEN BEGIN lnai := (lndy - lndx) * 2;
    lnbi := lndy * 2;
    lndd := lnbi - lndx;
    REPEAT IF (lndd >= 0) THEN BEGIN Inc(lny1, lnyi);
      Inc(lndd, lnai); END ELSE Inc(lndd, lnbi);
      Inc(lnx1, lnxi); SetPixel(lnx1, lny1, Color);
    UNTIL (lnx1 = lnx2);
  END ELSE BEGIN lnai := (lndx - lndy) * 2; lnbi := lndx * 2;
    lndd := lnbi - lndy;
    REPEAT IF (lndd >= 0) THEN BEGIN Inc(lnx1, lnxi);
      Inc(lndd, lnai); END ELSE Inc(lndd, lnbi);
      Inc(lny1, lnyi); SetPixel(lnx1, lny1, Color);
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

PROCEDURE BurstSetPalette(burstPalette : RGBPalette);
VAR
  burstCount : Word;
BEGIN
  Port[$3C8] := 0;
  FOR burstCount := 0 TO 767 DO Port[$3C9] := burstPalette[burstCount];
END;

{ originally by Sean Palmer, I just mangled it }
PROCEDURE ScaleBitmap(VAR bmp2scale; bwidth, bheight : Byte;
  bstrtx, bstrty, bendx, bendy : Word);
{ - bmp2scale is an array [0..bwidth, 0..bheight] of byte      }
{   which contains the original bitmap                         }
{ - bwidth and bheight are the actual width - 1 and the actual }
{   height - 1 of the normal bitmap                            }
{ - bstrtx and bstrty are the x and y values for the upper-    }
{   left-hand corner of the scaled bitmap                      }
{ - bendx and bendy are the lower-right-hand corner of the     }
{   scaled version of the original bitmap                      }
{ - eg. to paste an unscaled version of a bitmap that is 64x64 }
{   pixels in size in the top left-hand corner of the screen,  }
{   fill the array with data and call:                         }
{     ScaleBitmap(bitmap, 64, 64, 0, 0, 63, 63);               }
{ - to create an array for the bitmap, make it like this:      }
{     VAR myBitmap : Array[0..bmpHeight, 0..bmpWidth] of Byte; }
{   where bmpHeight is the actual height of the normal-size    }
{   bitmap less one, and bmpWidth is the actual width less one }
VAR
  bmp_sx, bmp_sy, bmp_cy : Fixed;
  bmp_s, bmp_w, bmp_h    : Word;

BEGIN
  bmp_w := bendx - bstrtx + 1; bmp_h := bendy - bstrty + 1;
  bmp_sx.w := bwidth * $10000 DIV bmp_w;
  bmp_sy.w := bheight * $10000 DIV bmp_h;
  bmp_s := 320 - bmp_w; bmp_cy.w := 0;
  ASM
    push ds; mov ds,word ptr bmp2scale + 2;
    mov ax,$a000; mov es,ax; cld; mov ax,320;
    mul bstrty; add ax,bstrtx; mov di,ax;
   @l2:
    mov ax,bmp_cy.i; mul bwidth; mov bx,ax;
    add bx,word ptr bmp2scale;
    mov cx,bmp_w; mov si,0; mov dx,bmp_sx.f;
   @l:
    mov al,[bx]; stosb; add si,dx; adc bx,bmp_sx.i;
    loop @l;
    add di,bmp_s; mov ax,bmp_sy.f; mov bx,bmp_sy.i;
    add bmp_cy.f,ax; adc bmp_cy.i,bx;
    dec word ptr bmp_h; jnz @l2; pop ds;
  END;
END;

PROCEDURE WaitForRetrace;
{ waits for a vertical retrace to reduce flicker }
BEGIN
  REPEAT UNTIL (Port[$3DA] AND 8) = 8;
END;

PROCEDURE ClearScr;
BEGIN
  FillChar(Mem[$A000:0000], 64000, 0);
END;

END.  { of unit }

That's it!  It's not complete, but it's meant as a starter for all who are
interested in VGA graphics.  Happy programming!

Bernie.


--- Maximus/2 2.01wb
 * Origin: * idiot savant * +1 905 935 6628 * (1:247/128)
