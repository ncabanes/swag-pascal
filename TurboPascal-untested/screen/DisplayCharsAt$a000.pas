(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0036.PAS
  Description: Display Chars at $A000
  Author: SWAG SUPPORT TEAM
  Date: 11-02-93  05:00
*)

{
>Does anyone know how display characters in 320x200x256 ($A000)??
>I want to write letters on the screen, but how do I? Is there a
>way without a special program???

  You need to use interrupt calls to the BIOS video routines to write a
  character to the screen.  Include the DOS unit in your program as
  you'll need it for the definition of "Intr" and "Registers" below:
}

procedure SetCursorPosition(Column, Row : byte);
var
  reg : registers;
begin
   reg.AH := $02;
   reg.BH := $00;    {* Display Page Number. 0 for Graphics Modes! *}
   reg.DL := Column; {* Row/Column are Zero-Based! *}
   reg.DH := Row;
   intr($10, reg);
end;

procedure WriteCharAtCursor(x : char; Color : byte);
var
  reg : registers;
begin
   reg.AH := $0A;
   reg.AL := ord(x);
   reg.BH := $00;    {* Display Page Number. * for Graphics Modes! *}
   reg.BL := Color   {* For Graphics Modes only? *}
   reg.CX := 1;      {* Word for number of characters to write *}
   intr($10, reg);
end;

{
Use the first routine to set the cursor position and the second routine
to write the character.  (I don't remember if writing a character will
modify the cursor position or not--you'll have to play with that one).
Play with these routines a bit and write another to output a string &
you should be all set.  WARNING: the characters you write in 300x200
mode will be very large and VIC-20-like....

I recommend you get a copy of Ron Brown's Interrupt List files
(INTERnnA.ZIP through INTERnnC.ZIP, where nn is the current number--my
guess if 34 or 35 by now).  I also have a copy of the "DOS Programmer's
Reference 2nd Edition" (Que Books) which describes many of the
Interrupts and how to interface with them in ASM, BASIC, C or Pascal,
as well as how DOS, BIOS, VIDEO, etc. are arranged.  It is a VERY
worthwhile reference....
}

