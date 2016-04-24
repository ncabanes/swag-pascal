(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0125.PAS
  Description: Scrolling Images
  Author: JENS LARSSON
  Date: 08-24-94  13:56
*)

{
Michael, you wondered how you could scroll an image (320*200) over the
screen. And yes, as you probably have figured out, the most reliable
solution to that is mode-x (or tweaked mode or whatever...).
Here's an example program:

--------------------------------------------------------->8-------------------
{

 Mode-x scrolling, by Jens Larsson 2:201/2120.3, Sweden, PD.
 ( btw, hope you know some assembly... <g> )

}
{$G+}
Uses Crt;

   Var i, ScrBase : Word;

    Procedure PutPix(x, y : Word; Color : Byte); Assembler;
      Asm
        mov     ax,0a000h
        mov     es,ax
        mov     bx,x
        mov     dx,3c4h
        mov     ax,0102h
        mov     cl,bl
        and     cl,3
        shl     ah,cl
        out     dx,ax
        mov     ax,y
        shl     ax,4
        mov     di,ax
        shl     ax,2
        add     di,ax
        shr     bx,2
        add     di,bx
        add     di,ScrBase
        mov     al,Color
        mov     es:[di],al
      End;

    Procedure ScrPan(ScrOfs : Word); Assembler;
      Asm
        mov     bx,ScrOfs
        mov     dx,3d4h
        mov     ah,bh
        mov     al,0ch
        out     dx,ax
        mov     ah,bl
        inc     al
        out     dx,ax
      End;

    Procedure SetModeX; Assembler;
      Asm
        mov     ax,0012h
        int     10h
        mov     ax,0013h
        int     10h
        mov     dx,3c4h
        mov     ax,0604h
        out     dx,ax
        mov     dx,3d4h
        mov     ax,0014h
        out     dx,ax
        mov     ax,0e317h
        out     dx,ax
      End;

    Procedure Synk; Assembler;
      Asm
        mov     dx,3dah
@L1:
        in      al,dx
        test    al,08h
        jne     @L1
@L2:
        in      al,dx
        test    al,08h
        je      @L2
      End;

       Begin
         Randomize;
         SetModeX;
         ScrBase := 200*80;
         For i := 0 to 9999 do PutPix(Random(320),Random(200),Random(256));
         For i := 0 to 200 do Begin
           ScrPan(i*80);
           Synk;
          End;
         ReadKey;
         Asm; mov ax,0003h; int 10h; End;
       End.


