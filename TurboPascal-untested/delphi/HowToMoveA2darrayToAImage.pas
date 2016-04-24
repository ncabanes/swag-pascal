(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0030.PAS
  Description: How to move a 2D-array to a Image
  Author: PAUL SULLIVAN
  Date: 11-22-95  15:49
*)


In article <3pto5f$sgt@nic.tip.net>,
   christer.strandh@micro.se (Christer Strandh) wrote:
> I want to move a 2D-array with picture graylevels to a Image or BMP
> object without first save the array to disk!??
> I want to display the image faster on the canvas than I do now by
> using canvas.pixels(...  its slow!
> 
>  Christer Strandh...

A solution (not necessarily the best but it works) is as follows:

1. Create a Bitmap (TBitMap) within the TImage.
  Bitmap := TBitmap.Create;
  BitMap.Width:=NCol;
  BitMap.Height:=NRow;
...

2. Create logical palette (grayscale or whatever) and assign it to
BitMap.Palette.
  CreatePalette(MyLogPalette);
... etc.

3. Now draw pixels into the BitMap canvas NOT the image canvas (which is 
slow...). Use the number of colours in your logical palette to scale the 
intensity values.

4. Clean up. Free logical palette etc.
  DeleteObject(Image.Picture.Bitmap.ReleasePalette);

----Paul

 -----------------------------------------------------
| Dr Paul J. Sullivan            sullypj@enh.nist.gov |
| National Institute of Standards & Technology (NIST) |
| Gaithersburg, MD, USA 20899                         |
| Tel: (301) 975 6386             Fax: (301) 869 0822 |
 -----------------------------------------------------
---
 * Origin: Global-Net <-> Internet Gateway (1000:1000/5.0)

-------------------------------------------------------------------------------

From: swwarrio@ix.netcom.com (Stephen Warrior )
Subject: Reply to Delphi tip - GPHARRAY
Date: Sat, 17 Jun 1995 07:55:57 -0700

With regard to the tip GphArray attributed to Dr. Paul Sullivan, I have been developing a 
program to display and manipulate medical images (specifically Nuclear Medicine images) 
which consist of 2D arrays of grayscale values as described.  As was observed, the Pixels 
property is way too slow.

Here's what I discovered.  I think you'll find it a big improvement.

Assuming your data is stored in an array of bytes named TestArray, for example
    
   TestArray: array[0..127, 0..127] of byte ...

    ArrayPtr := addr(TestArray);   { ArrayPtr: pointer }

  { In this case we are going to display on the bitmap of a TImage component that has been }
  { dropped on the canvas and named Image1...                                              }

    Image1.Picture.Bitmap.Width := 128;
    Image1.Picture.Bitmap.Height := 128;

  {  This is a Windows API function that will copy the bits in TestArray, pointed to by  }
  {  ArrayPtr, into an HBitmap structure, in this case Image1.Picture.Bitmap.Handle.     }

    SetBitmapBits(Image1.Picture.Bitmap.Handle, sizeof(TestArray), ArrayPtr);

    Image1.Refresh;  { must refresh before changes are displayed }

You still have to deal with the palette but this technique works great for me.


