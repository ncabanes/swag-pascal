(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0269.PAS
  Description: Re: Mode 80x50 or whatever
  Author: JIM LEONARD
  Date: 02-21-96  21:04
*)

{
>How do I set those REALLY low-resolution modes which people keep on
>using? i.e. 80x50, etc.  I can tell that the only real reason that most
>scaling effects are so fast is because rather than doing it fullscreen in
>320x200, they use something like 80x50 or so...

Correct, in the old days, anyway.  They usually were unchained
modes with the cell height changed.  Changing the cell height makes
every pixel twice as high, three times as high, etc.  They were
unchained modes so you could change the write plane registers so
when you wrote one pixel to the screen, it wrote four in a row.
Voila, 80x50.

You can't do that because of the way you program (you're strictly
mode 13h) but you *can* change the cell height, like this:
}

Procedure cellheight(a:Byte);Assembler;
  Asm
    push    DX
    mov     AH,a            {cell height is a}
    mov     DX,$3D4         {CRTC_Index $3d4 }
    mov     AL,9            {register function}
    out     DX,AL           {do it!}
    Inc     DL
    In      AL,DX
    And     AL,11100000b
    Or      AL,AH
    out     DX,AL           {do it!}
    pop     DX
  End;


