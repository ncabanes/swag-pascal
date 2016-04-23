{
>The utility I wrote, just Writes the contents of the $A000 from one to
>63999 (ya know 320x200), to a File.  then I bring it to an Array, and
>then I try to reWrite it to the video.  HOWEVER, I noticed that the
>palette inFormation is incorrect.  Is there any way to fix this, since
>it comes out in a messed up color.

How about writing also the palette info to the File ? You're probably
BlockWriting, so this should not be a big problem. You just have to
fetch the palette info through inT $10, Function $1017 :
}

Type
  TCouleurVGA =
    Record
      Rouge,
      Vert,
      Bleu   : Byte ;
    end ;

  TPaletteVGA = Array[0..255] of TCouleurVGA ;

Procedure LitPalette(Var p : TPaletteVGA) ; Assembler ;
Asm
  { Lecture table couleurs }
  Mov       AX, $1017
  Mov       BX, 0
  Mov       CX, 256
  LES       DX, p
  Int       $10
end ;

{
The reverse :
}

Procedure AffectePalette(Var Palette : TPaletteVGA) ; Assembler ;
Asm
  Mov     AX, $1012
  Xor     BX, BX
  Mov     CX, 256
  LES     DX, Palette
  Int     $10
end ;

{
>Also, I have successfully written color cycling, by changing each color
>index in a loop.  Only problem is that you can see it 'redrawing'.  Is
>there anyway ot change them all simultaneously, instead of a loop?  I am
>working in Pascal, using bits and chunks of Inline Asm.

I'm _not_ sure the following is the answer you expect :
}

Procedure AffectePaletteDeA(Var Palette ; De, A : Integer) ; Assembler ;
Asm
  Mov     AX, $1012
  Mov     BX, De
  Mov     CX, A
  Sub     CX, BX
  Inc     CX
  LES     DX, Palette
  Int     $10
end ;

Var
  Pal  : TPaletteVGA ;

begin
  { Here, fill the colors you need }
  { Say, you modified colors 37 to 124 into Pal Array }
  AffectePaletteDeA(Pal[37], 37, 124) ;
end.

