(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0153.PAS
  Description: SVGA Plotting that WORKS!
  Author: JASON RENNIE
  Date: 11-26-94  05:02
*)

{
> How do I set a pixel in that mode (800x600x256) ?

If the computer has a VESA driver installed, you can do it the same as you
would for 320x200 (13h).  You would first change the video mode to the
correct one and then plot the point.  The trouble is that every video card
has different mode numbers for the different modes.

     Resolution       Manuf.      Mode #    Chip

     320x200          All         13h       All

     640x480          ATI         62h       All
     640x480          Chips&Tech  79h       452,453
     640x480          Paradise    5Fh       All
     640x480          Trident     5Dh       All
     640x480          Tseng       2Eh       All
     640x480          Video7      67h       All
     640x480          Genoa       5Ch       All

     800x600          ATI         63h       All
     800x600          Chips&Tech  7Bh       453
     800x600          Tseng       30h       All
     800x600          Video7      69h       All

     1024x768         Trident     62h       8900
     1024x768         Tseng       38h       ET4000

   Ploting a Pixel
   ---------------

     To plot a pixel you would use the following Pascal Procedure:
}

Procedure Plot(x,y:integer; color:byte); assembler;
Asm
  mov bh,0
  mov cx,x { sets x coordinate }
  mov dx,y { sets y coordinate }
  mov al,color { sets color (0-255) }
  mov ah,0Ch { tells video to plot a point }
  int 10h
End;

{
The x coordinate is moved into cx, the y coordinate is moved into dx and
the color is moved into al.  You must make sure that color is a BYTE
variable.  It can go from 0-255.  When you pass the color, it either must
be from a byte variable or it must be 'variable mod 256' (where
'variable' is some integer type variable).

This example uses inline assembler.  To do anything significant with the SVGA
you either have to use assembler or find a good BGI file or unit that will do
it for you.
}

