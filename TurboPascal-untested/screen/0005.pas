{
│What would be the best way to find out what Character is at a certain
│location on the screen.  For example, Lets say I went to location
│(10,2) and at that location is the letter 'S' now without
│disturbing the letter S how can I determine if it is there or not?


A 25-line by 80-column screen has 2,000 possible cursor positions. The
2,000 Words that begin at the memory location $B800:0000 (or $B000:0000 if
your machine is monochrome) define the current image. The first Byte of
each Word is the ASCII Character to be displayed, and the second Byte is
the attribute of the display, which controls such Characteristics as color
and whether it should blink....

I you used the standard (X,Y) coordinate system to define a cursor positon
on the screen, With the upper left corner at (1,1) and lower right corner
at (80,25), then With a lettle algebra you can see that the offset value
For a cursor position can be found at:

   Words:  80*(Y-1) + (X-1)
or
   Bytes:  160*(Y-1) + 2*(X-1)


Here's a Function that will return the Character at location (X,Y):

}
Function GetChar(X,Y:Byte):Char;
  (* Returns the Character at location (X,Y) *)
Const
  ColorSeg = $B800;     (* For color system *)
  MonoSeg  = $B000;     (* For mono system  *)
begin
  GetChar := Chr(Mem[ColorSeg:160*(Y-1) + 2*(X-1)])
end;
