(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0131.PAS
  Description: 32-Bit ASM
  Author: ALEX CHALFIN
  Date: 05-26-95  22:57
*)


{ Updated MISC.SWG on May 26, 1995 }

{
> I've seen a message where some guys were talking about 32 bits
> graphics programming. It was something like this
> db $66
> MOVSW
> When you use this it will move four bytes instead of 2.
> My problem is were to put those 4 bytes which should be stord.
> I know the first 2 bytes should be put in AX but were should you put
> the next 2. The trouble is that you can't use EAX because it's a 386
> instruction. I hope you can help me with this

 Using db 66h; Movsw is the same as the ASM instruction Movsd. AX and EAX
 are not used in this operation. A double word at [ds:si] is moved to [es:di]
 and si and di are incremented. In the case of db 66h; Stosw (an ASM Stosd),
 you must have a value in EAX. If you are clearing a screen, you must place
 the color value in each byte.

 Here are some sample procedures that use these ideas:
}
Procedure ClearScreen(Var Screen; Color : Byte); Assembler;
{$G+} { Enable 286 instructions }
Asm
  Les  di,Screen    { Load a the pointer to the screen into [es:di] }
  Mov  al,Color
  Mov  ah,al
 db 66h; Shl ax,16
  Mov  al,Color
  Mov  ah,al
  Mov  cx,16000   { Store 16000 DWords }
 db 66h Rep Stosw
End;

In this case, if the color value was $34, EAX would equal $34343434, and
this would be stored to the screen.

Procedure CopyScreen(Var Source, Dest); Assembler;

Asm
  Push  ds        { TP doesn't save DS }
  Les   di,Dest
  Lds   si,Source
  Mov   cx,16000
 db 66h; Rep Movsw  { Move 16000 words at [ds:si] to [es:di] }
  Pop   ds
End;

