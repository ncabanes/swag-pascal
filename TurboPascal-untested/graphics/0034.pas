{
Dave Foster

> Could anyone please post any routines or help on how
> to read an image into TURBO 6. I can save the image
> in any format, but i need code to be able to display
> it on the screen. Source code would be an advantage!
>
I wrote this Program For a friend to read a image into his Program, and
and I would be happy For any help on how to improve it.
}

Program  Read_Image;      { SRC-CODE.PAS   ver 1.00 }
{-----------------------------------------------------------------------------
 Program reads in a binary data File, and displays the image on the screen by
 using "PutPixel" Procedure in the Graph Unit.  The image can be displayed in
 color, or in grey-scale by using the subroutine "Set64Gray" below.
 This is a quick and dirty method to display the image using "PutPixel",
 and I hope someone will be able to show us how to use the "PutImage" to
 display the image quicker.
-----------------------------------------------------------------------------}

Uses
  Dos, Crt, Graph;

Type
  ByteArray = Array [0..175] of Byte;

Var
  Gd, Gm,
  m, n    : Integer;
  buffer  : ByteArray;
  f       : File;

{
> Does anyone know how can I get a Graphic mode in VGA in which I
> could use 64 gray level (at least 32)?  Could I keep on using the
> Graphical Procedures in Unit Graph then?

 The fragment below will initialize the first 64 VGA color values to
 gray scale.  These colors are valid For any VGA mode (including Text),
 but in most Graphics modes/devices the Borland Graph Unit limits you
 to using only 16 colors.
}

Procedure Set64Gray;
{ Sets up 64 shades of gray where 0 = black, 63 = full white }
Type
  CRec = Record
    R, G, B: Byte;
  end;
Var
  Regs : Registers;
  I    : Integer;
  G64  : Array [0..63] of CRec;
begin
  { Initialize the block of color values }
  For I := 0 to 63 do
  With G64[I] do
  begin
    R := I;
    G := I;          { Color is gray when RGB values are equal }
    B := I;
  end;

  Regs.ax := $1012;      { Dos Function to update block of colors }
  Regs.bx := 0;          { First color to change }
  Regs.cx := 64;         { Number of colors to change }
  Regs.es := seg(G64); { Address of block of color values }
  Regs.dx := ofs(G64);
  intr($10, Regs);
end;

begin
  Gd := detect;
  initGraph(Gd, Gm, 'e:\bp\bgi');

  { Open the image File which is 250 lines, and 175 pixels per line.
    Each pixel is 1 Byte, and no header data, or Record delimiters.
    File is 43,750 Bytes (250 x 175) in size.  Have look at the input
    File using binary File viewer. }

   assign(f, 'DOMINO.DAT');
   reset(f, 175);

  { if you enable this, you will be able to see the image in grey-scale,
    but I am not sure if it is quite right.  Currently it seems to display
    only few grey-scale levels instead of the full 64 levels.

   }Set64Gray;

  { Method used to read the File line at a time, and Write the pixel
    values to the screen. This is bit slow, and it would be lot faster
    by using "PutImage" but I do not know the method For that. }

   n := 1;
   While not eof(f) do
   begin
     BlockRead(f, buffer, 1);
     For m := 1 to 175 do
       PutPixel(m, n, buffer[m]);
     n := n + 1;
   end;

   close(f);
   readln;
   closeGraph;
end.

{
The image File "DOMINO.DAT" used in the Program "SRC-CODE.PAS".
Image File is 250 x 175 pixels (43,750 Bytes).
}

