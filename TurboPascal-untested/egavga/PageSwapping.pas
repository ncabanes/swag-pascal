(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0220.PAS
  Description: Page Swapping
  Author: MINTO GEORGE
  Date: 05-26-95  23:23
*)

{
Code, without interrupts to display a pixel in mode 101h (640**480**256)
using direct writes.  Jort Bloem helped some, but his page routine is to
slow.  If not the entire procedure then please, just the following code
with direct, as fast as possible, access vga memory writes.}
{donated by Jort Bloem, updated in asm by me}

Procedure Page (p : byte);
  begin
    if lastpage = p then exit;
    lastpage := p;
    asm
      mov ax, 4f05h;
      mov bx, 0000h;
      mov dx, p;
      int 10h;
    end;
 end;

