(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0231.PAS
  Description: Texture Mapping
  Author: ALEX CHALFIN & KRIS VERBEECK
  Date: 05-26-95  23:29
*)

{
> I'm hoping that some kind soul, possibly even the author, might be
> willing to repost this valuable source (that we can ALL learn off of),
> or lead me in the right direction to find it.

I don't know whether we have the same piece of code in mind, but I also read
that message and copied it.  But I did some altering.  If you would settle with
my (altered) source code, then here it is:
}
{===========================================================================}
{                                                                           }
{ Name         TEXTMAP.TPU                                                  }
{ Description  Unit used for texture mapping.                               }
{ Version      1.0                                                          }
{                                                                           }
{ Author       Alex Chalfin 1:108/180 (adapted by Kris Verbeeck)            }
{ Last update  9th Sep, 1994                                                }
{                                                                           }
{===========================================================================}


UNIT TextMap;


{$N+}


{===[ Interface part ]======================================================}


INTERFACE


{---[ Units used in interface part ]----------------------------------------}


 USES
  VGA;


{---[ Global constants ]----------------------------------------------------}


 CONST
  _TOP   =  1;
  _BOTTOM  =  2;
  _LEFT  =  3;
  _RIGHT  =  4;


{---[ Global Types ]--------------------------------------------------------}


 TYPE
  Corners = ARRAY[0..3] of Point2D;

  Bitmap = RECORD
       xs, ys : INTEGER;
       image  : POINTER;
      END;


{---[ Global Variables ]----------------------------------------------------}


 { VAR
   none }


{---[ Global Routines ]-----------------------------------------------------}


 PROCEDURE TextureMap( fp, tp : Corners; b : Bitmap );
 { -- Maps the 4 point polygon bitmap 'fp' to another 4 point
      polygon 'tp' }


{===[ Implementation part ]=================================================}


IMPLEMENTATION


{---[ Units used in implementation part ]-----------------------------------}


 { USES
   none }


{---[ Local constants ]-----------------------------------------------------}


 { CONST
   none }


{---[ Local Types ]---------------------------------------------------------}


 { TyPE
   none; }


{---[ Local Variables ]-----------------------------------------------------}


 VAR
  LeftTable, RightTable  :  ARRAY[0..199, 0..2] of INTEGER;

  Max_y, Min_y     :  INTEGER;
  LineHeight      :  INTEGER;

  PWidth, PHeight   : INTEGER;
  Px0, Py0      : INTEGER;


{---[ Local Routines ]------------------------------------------------------}


 PROCEDURE Swap( VAR a, b : INTEGER);
 VAR
  aux : INTEGER;
 BEGIN
  aux := a;
  a   := b;
  b   := aux;
 END;


 PROCEDURE FindMaxMin( p : Corners ); {ASSEMBLER;}
 VAR
  i : INTEGER;
 BEGIN
  Min_y := 0;
  Max_y := 32000;
  FOR i := 0 TO 3 DO BEGIN
   IF (p[i].y < Min_y) THEN
    Min_y := p[i].y;
   IF (p[i].y > Max_y) THEN
    Max_y := p[i].y;
  END;
(* ASM
   mov   Max_y,0000h
   mov Min_y,7FFFh
   les bx,p
   add bx,2       { Point to first y-coord }
   mov cx,0004h                { Check 4 coords }
  @Loop:
   mov ax,es:[bx]     { Get first y-coord }
   cmp ax,Min_y
   ja  @NotLower
   mov Min_y,ax
  @NotLower:
   cmp ax,Max_y
   jb  @NotHigher
   mov Max_y,ax
  @NotHigher:
   add bx,4       { Point to next y-coord }
   loop @Loop
 END;*)

 PROCEDURE ScanLeft( x1, x2, y1, lh, side : INTEGER );
 VAR
  y           : INTEGER;
  xAdd, Px, Py, PxAdd, PyAdd, x : SINGLE;
 BEGIN
  lh := lh + 1;
  xAdd := (x2-x1)/lh;
  CASE side OF
   _TOP  : BEGIN
        Px := PWidth;
        Py := 0;
        PxAdd := -PWidth/lh;
        PyAdd := 0;
       END;
   _RIGHT : BEGIN
        Px := PWidth;
        Py := PHeight;
        PxAdd := 0;
        PyAdd := -PHeight/lh;
       END;
   _BOTTOM : BEGIN
        Px := 0;
        Py := PHeight;
        PxAdd := PWidth/lh;
        PyAdd := 0;
       END;
   _LEFT  : BEGIN
        Px := 0;
        Py := 0;
        PxAdd := 0;
        PyAdd := PHeight/lh;
       END;
  END;
  x := x1;
  FOR y := 0 TO lh DO BEGIN
   LeftTable[y1+y, 0] := Round(x);
   LeftTable[y1+y, 1] := Round(Px);
   LeftTable[y1+y, 2] := Round(Py);
   x := x + xAdd;
   Px := Px + PxAdd;
   Py := Py + PyAdd;
  END;
 END;


 PROCEDURE ScanRight( x1, x2, y1, lh, side : INTEGER );
 VAR
  y           : INTEGER;
  xAdd, Px, Py, PxAdd, PyAdd, x : SINGLE;
 BEGIN
  lh := lh + 1;
  xAdd := (x2-x1)/lh;
  CASE side OF
   _TOP  : BEGIN
        Px := 0;
        Py := 0;
        PxAdd := PWidth/lh;
        PyAdd := 0;
       END;
   _RIGHT : BEGIN
        Px := PWidth;
        Py := 0;
        PxAdd := 0;
        PyAdd := PHeight/lh;
       END;
   _BOTTOM : BEGIN
        Px := PWidth;
        Py := PHeight;
        PxAdd := 0;
        PyAdd := -PHeight/lh;
       END;
   _LEFT  : BEGIN
        Px := 0;
        Py := PHeight;
        PxAdd := 0;
        PyAdd := -PHeight/lh;
       END;
  END;
  x := x1;
  FOR y := 0 TO lh DO BEGIN
   RightTable[y1+y, 0] := Round(x);
   RightTable[y1+y, 1] := Round(Px);
   RightTable[y1+y, 2] := Round(Py);
   x := x + xAdd;
   Px := Px + PxAdd;
   Py := Py + PyAdd;
  END;
 END;

 PROCEDURE ScanConvert( x1, y1, x2, y2, PLoc : INTEGER );
 BEGIN
  IF (y2 < y1) THEN BEGIN
   Swap( x1, x2 );
   Swap( y1, y2 );
   LineHeight := y2 - y1;
   ScanLeft( x1, x2, y1, LineHeight, PLoc );
  END ELSE BEGIN
   LineHeight := y2 - y1;
   ScanRight( x1, x2, y1, LineHeight, PLoc );
  END;
 END;

 PROCEDURE DoMapping( b : Bitmap );
 VAR
  lw, x, y, Px, Py          : INTEGER;
  Polyx1, Polyx2, Px1, Px2, Py1, Py2, PxA, PyA : SINGLE;
  color              : BYTE;
 BEGIN
  FOR y := Min_y TO Max_y DO BEGIN
   Polyx1 := LeftTable[y,0];
   Px1 := LeftTable[y,1];
   Py1 := LeftTable[y,2];

   Polyx2 := RightTable[y,0];
   Px2 := RightTable[y,1];
   Py2 := RightTable[y,2];

   lw := Round(Polyx2-Polyx1);
   lw := lw + 1;

   PxA := (Px2-Px1)/lw;
   PyA := (Py2-Py1)/lw;

   FOR x := Round(Polyx1) TO Round(Polyx2) DO BEGIN

    Px := Round(Px1);
    Py := Round(Py1);
    ASM
      push ds

      mov ax,Py0
      add ax,Py
      mul b.xs
      add ax,Px0
      add ax,Px
      lds si,b.image
      add si,ax

      mov ax,y
      mov bx,ax
      shl ax,8
      shl bx,6
      add ax,bx
      add ax,x
      mov di,VSEG
      mov es,di
      mov di,ax

      movsb

      pop ds
    END;
    Px1 := Px1 + PxA;
    Py1 := Py1 + PyA;
   END;
  END;
 END;


{---[ Implementation of Global routines ]-----------------------------------}


 PROCEDURE TextureMap( fp, tp : Corners; b : Bitmap );
 BEGIN
  FindMaxMin( tp );

  PWidth := fp[1].x - fp[0].x;
  PHeight := fp[2].y - fp[1].y;

  Px0 := fp[0].x;
  Py0 := fp[0].y;

  ScanConvert( tp[0].x, tp[0].y, tp[1].x, tp[1].y, _TOP );
  ScanConvert( tp[1].x, tp[1].y, tp[2].x, tp[2].y, _RIGHT );
  ScanConvert( tp[2].x, tp[2].y, tp[3].x, tp[3].y, _BOTTOM );
  ScanConvert( tp[3].x, tp[3].y, tp[0].x, tp[0].y, _LEFT );

  DoMapping( b );
 END;


{===[ Unit initialization part ]============================================}


 { none }

END.

