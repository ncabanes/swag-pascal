{
Does any one know of a way to Write 80 chrs to the bottom line of the
screen without the screen advancing?

You're gonna have to Write directly to the screen : the problem is that,
when you use std ways to Write to the screen, the cursor is always one
Character ahead of the Text you displayed... so standard display procs
can not be used to Write to the 80th Character of the 25th line.

Here is a simple proc to Write Text directly to the screen :
}

Const
     VideoSeg  : Word = $b800 ;    { Replace With $b000 if no color card }

Procedure DisplayString(x, y : Byte; Zlika : String; Attr : Byte); Assembler ;

{ x and y are 0-based }
Asm
  Mov  ES, VideoSeg        { Initialize screen segment adr }

  { Let's Compute the screen address of coordinates (x, y) }
  { Address:=(160*y)+(x ShL 2) ; }
  Mov  AL, 160             { 160 Bytes per screen line }
  Mul  Byte Ptr y
  Mov  BL, x
  Xor  BH, BH
  ShL  BX, 1               { 2 Bytes per on-screen Character }
  Add  BX, AX              { BX contains offset where to display }

  { Initialize stuff... }
  Push DS                  { Save DS }
  ClD                      { String ops increment DI, SI }
  LDS  SI, Zlika           { DS:DI points to String }
  LodSB                    { Load String length in AL }
  Mov  CL, AL              { Copy it to CL }
  Xor  CH, CH              { CX contains String length }
  Mov  DI, BX              { DI contains address where to display }
  Mov  AH, Attr            { Attribute Byte in AH }
@Boucle:
  LodSB                    { Load next Char to display in AL }
  StoSW                    { Store Word (attr & Char) to the screen }
  Loop @Boucle             { Loop For all Chars }

  Pop  DS                  { Restore DS }
end ;

{
Furthermore, this is definitely faster than using Crt.Write...
I will ask those ones owning a CGA card to Forgive me, I ommited to
include the usual snow-checking... but this intends to be a short
example :-))
Also note that there is no kind of checking, so you can Write out of
the screen if you want... but that's no good idea.
BTW, the attribute Byte value is Computed With the "magic Formula"
Attr:=Foreground_Color + (16 * Background_color) [ + 128 For blinking ]
}
