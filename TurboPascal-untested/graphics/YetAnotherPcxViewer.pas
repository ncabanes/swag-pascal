(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0203.PAS
  Description: Yet another PCX viewer
  Author: JANI ALANEN
  Date: 11-22-95  15:49
*)

{ here's a unit to view PCX-files in 320x200x256 }

UNIT PCX;

INTERFACE

USES crt;

PROCEDURE DoPCXPalette;
FUNCTION LoadPCX  (Filename:String; Where:Word):Boolean;
  { Load a PCX file to the screen "where"
    Dopal = True sets up the correct PCX pallette, otherwise it leaves
            the pallette alone }

VAR Palette: ARRAY[0..767] OF Byte;
    loop1:Word;
IMPLEMENTATION


PROCEDURE DoPal(Col,R,G,B : Byte); ASSEMBLER; ASM
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
END;

PROCEDURE DoPCXPalette;
BEGIN
  FOR loop1:=0 TO 255 DO
      DoPal (loop1,palette[loop1*3] shr 2,palette[loop1*3+1] shr 2,
            palette[loop1*3+2] shr 2);
END;

FUNCTION LoadPCX (Filename:String; Where:Word):Boolean; VAR f:File;
    Res:Word;
    Temp:Pointer;
BEGIN
    Assign (f,Filename);
    Reset (f,1);
    Seek(f,FileSize(f)-768);
    BlockRead(f,Palette,768);
    Seek(f,128);
    GetMem (Temp,65535);
    BlockRead (f,Temp^,65535,Res);
  ASM
    push ds
    mov  ax,where
    mov  es,ax
    xor  di,di
    xor  ch,ch
    lds  si,temp
@Loop1 :
    lodsb
    mov  bl,al
    and  bl,$c0
    cmp  bl,$c0
    jne  @Single

    mov  cl,al
    and  cl,$3f
    lodsb
    rep  stosb
    jmp  @Fin
@Single :
    stosb
@Fin :
    cmp  di,63999
    jbe  @Loop1
    pop  ds
  END;
  FreeMem (Temp,65535);
  Close (f);
END;

BEGIN

END.

