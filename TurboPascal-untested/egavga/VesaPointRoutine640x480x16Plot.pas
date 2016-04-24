(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0135.PAS
  Description: VESA point routine 640x480x16 Plot
  Author: OLAF BARTELT
  Date: 11-26-94  04:58
*)


{
> I don't see the need for Ystart.  Offset address =
well, Ystart is needed basically because I'm using two pages, and depending
on which page is visible at the time, ystart varies...

> (BytesPerScanLine * y)+x. Point_VESA should not XOR AX,AX after
> @skip.  The AH contains the error return from $4f05 function.
> AH=00h is success.

ok, but this doesn't solve my problem...  my problem is that I always get to
'see' the wrong colors - I don't mind which error codes there are :-))

> P.S.  Can you show me how to VESA PutPixel to 640x480x16 without using BGI?
sure, but 640x480x16 still is a normal VGA and not a VESA mode:
}

PROCEDURE plot_640x480x16; ASSEMBLER;
ASM
  MOV ES, SEGA000
  MOV DI, px
  MOV CX, DI
  SHR DI, 3
  MOV AX, py
  SHL AX, 4
  ADD DI, AX
  SHL AX, 2
  ADD DI, AX
  AND CL, $07
  MOV AH, $80
  SHR AH, CL
  MOV AL, $08
  MOV DX, $03CE
  OUT DX, AX
  MOV AX, pc
  MOV AH, [ES:DI]
  MOV [ES:DI], AL
END;

{
this should work (as always: px,py are the coordinates and pc is the color
(all global INTEGERs)
}
