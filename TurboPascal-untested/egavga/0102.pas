{
 ▒   Hey.. AnyBody out there know how to change TEXT fonts w/ Pascal?
 ▒ Any routines would be apprecited....

Yes, a friend of mine made a text font editor, a couple of years ago, but it
would be too long to post it in this conference. You may use this routine to
set a 8x16 text font.

You should pass to this procedure an array of 4096 bytes. This array should
contain the whole 256 character set, structured in blocks of 16 bytes for
each char:

{------Cut Here------}

Unit Fonts;

Interface

Type TextFont=Array[0..4095] of byte;

Procedure ActivateFont(Block:Textfont);

Implementation

Procedure ActivateFont; Assembler;
Asm
  push es
  mov ax,1100h
  mov bx,1000h
  mov cx,100h
  xor dx,dx
  push bp
  les bp,Block
  int 10h
  pop bp
  pop es
End;

Begin
End.

