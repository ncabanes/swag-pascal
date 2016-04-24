(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0058.PAS
  Description: Complete Icon Format Explanation
  Author: ALFONS HOOGERVORST
  Date: 05-26-95  23:08
*)

{
Some days ago someone asked me about the icon file format. I will publish
these messages just once. So put it in your archives please :-)
(I don't save my own messages, I never did :).



Header
}
TIconHeader = record
  idReserved: Word; (* Always set to 0 *)
  idType: Word;     (* Always set to 1 *)
  idCount: Word;    (* Number of icon images *)
  (* immediately followed by idCount TIconDirEntries *)
end;
{

A .ICO file can contain several icon images. Each image can differ in size,
resolution and color format.

}
TIconDirEntry = record
  bWidth: Byte;          (* Width *)
  bHeight: Byte;         (* Height *)
  bColorCount: Byte;     (* Nr. of colors used, see below *)
  bReserved: Byte;       (* not used, 0 *)
  wPlanes: Word;         (* not used, 0 *)
  wBitCount: Word;       (* not used, 0 *)
  dwBytesInRes: Longint; (* total number of bytes in images *)
  dwImageOffset: Longint;(* location of image from the beginning of file *)
end;

{
bColorCount refers to the number of palette entries in the image data. For the
most common icon type (32x32 pixels, 16 colors) the first three fields would be
32, 32 and 16 resp.

dwBytesInRes is the total number of bytes in the image data (including palette
data!). dwImageOffset is an offset (from the beginning of the file) to the
image data.


Image data

The icon file stores image data in the so-called device independent bitmap
(DIB) format. It's supposed to be fairly device independent :-). The actual
pixel data is preceded by two "structures": the bitmap info header and the
palette data.

First the bitmap info header (pasted from the BP WinSDK help, comments are
mine):
}
TBitmapInfoHeader = record
  biSize: Longint;    (* sizeof(TBitmapInfoHeader *)
  biWidth: Longint;   (* width of bitmap *)
  biHeight: Longint;  (* height of bitmap, see notes *)
  biPlanes: Word;     (* planes, always 1 *)
  biBitCount: Word;   (* number of color bits *)
  biCompression: Longint; (* compression used, 0 *)
  biSizeImage: Longint;   (* size of the pixel data, see notes *)
  biXPelsPerMeter: Longint; (* not used, 0 *)
  biYPelsPerMeter: Longint; (* not used, 0 *)
  biClrUsed: Longint;       (* nr of colors used, set to 0 *)
  biClrImportant: Longint;  (* important colors, set to 0 *)
end;

{
biBitcount contains the number of color bits per pixel. If it's 4, it means a
pixel can have 16 colors (2 shl 4). biBitcount also refers to how a pixel is
"coded" in the pixel data. If biBitcount is 4 a pixel takes 4 bits of an image
byte. If it's 8 (256 possible colors), a pixel is a byte.

As you perhaps know, icons are created by combining two bitmap masks: the
XOR-mask and the monochrome AND-mask. To draw an icon you first copy the mask
to the screen with an AND operator, then you copy the XOR-mask with an XOR
operator. 

Therefore the biHeight field is set to 2 * TIconDirEntry.bHeight and
biSizeImage is set to the size of the AND plus the XOR mask (ofcourse in
bytes). For example, for a 32x32 16 color icon biHeight would be 64 and
biSizeImage 512 + 128.

OK. How do you determine the size of the masks? 

XOR mask: (TIconDirEntry.bWidth * TIconDirEntry.bHeight * biBitCount) / 8
AND mask: (TIconDirEntry.bWidth * TIconDirEntry.bHeight) / 8

The palette data

The bitmap info header is followed by a table with palette entries. The actual
pixel data refer to this table. So when a pixel has color 13, look at palette
entry number 13 to get the actual RGB color for the pixel. At this moment
Windows just supports 2 (monochrome), 16 and 256 colors, so there's always a
palette table.

An entry in the palette table has the following format:
}

TRGBQuad = record
  rgbBlue: Byte;      (* blue component of color *)
  rgbGreen: Byte;     (* green component of color *)
  rgbRed: Byte;       (* red component of color *)
  rgbReserved: Byte;  (* reserved, 0 *)
end;

{
For Windows programmers: this record is *not* equivalent to a TColorRef (or
COLORREF). If you forget this, you'll get some odd colored icons :-).

An icon has TIconDirEntry.bColorCount palette entries. So there are
sizeof(TRGBQuad) * TIconDirEntry.bColorCount bytes in the palette.

The monochrome AND mask does _not_ have a palette table. A 1 bit in the AND
mask's pixel data means a _white_ pixel on-screen. A 0 bit means a black pixel.

On the other hand, the pixel data of monochrome icons _are_ preceded by a
palette table.


Pixel data

Now to the real nitty-gritty. Immediately after the palette data, the pixel
data follow. Remember: the pixel data contain both the XOR and AND bits.

There's something odd with the storage of the mask bits: both mask data are
stored in bottom up format. For example: in a 32 x 32 16 color icon the first
32 nibbles belong actually to the last pixel row. The second 32 nibbles form
the last - 1 pixel row. And so on.
Retrieving pixels is a little bit hard. Just keep track of the biBitCount
value. Write different functions for monochrome, 16 and 256 color icons or keep
a running bit mask ready.
In Windows creating an icon from .ICO file is rather easy, call the
CreateDIBitmap function twice (for the AND mask/XOR mask). Then call
GetBitmapBits to retrieve the bitmap data.
Under DOS you have to do a little more: e.g. translation of RGB colors.
}
