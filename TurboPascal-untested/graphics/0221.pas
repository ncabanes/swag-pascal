(*
PART 1 OF NEWGRAPH.PAS
APPEND NEWGRPH2.PAS TO THE BOTTOM OF THIS FILE AND SAVE THE
COMBINED FILES AS NEWGRAPH.PAS - COMPILE NEWGRAPH.PAS AND
NOW SEE HOW MUCH FASTER AND MORE COMPLETE IT IS THAN ALL OF 
THE OTHER SWAG GRAPHIC & SPRITE UNITS.


**************************************************************
NEWGRAPH! The (now slightly outdated) 320 x 200 x 256 VGA MODE
SUPPORT UNIT by Scott Tunstall (C) 1994, 1996. (Rev 1. created
in 1994, Final rev. Sept 1995)

Next project : This package converted to support VESA 16.7
               Million Colour graphic modes. (That'll be a
               task and a half)

After that   : Sleep for a year!!!

**************************************************************

READ THE DISCLAIMER FIRST BEFORE DOING ANYTHING!!!




Purpose of unit
---------------
The purpose of this unit is to provide an all-in-one package to
allow you to write FAST games in Turbo Pascal.

The unit incorporates :

         o Easy bitmap initialisation and manipulation routines

         o The fastest masked/unmasked/clipped sprite graphics
           routines you will EVER see for a 386/486 processor.

         o Easy to use palette routines (Not as many as I would
           have liked to have included but there are 100s of
           them available in the public domain - feel free to
           use em if ya like.)

         o Font load/save/display routines which are also the
           fastest you'll see (in 1994).

         o Versatile PCX load routines which can handle page sizes
           up to 320 x 200 (Handy for grabbing sprites.)


ALL time critical routines (i.e. Sprite drawing, Bitmap copying)
are written in 100% assembly language and have all been tested
extensively. (Yes Ronny I did write the assembler)

So in other words your machine shouldn't bomb when you use this unit!
(See Disclaimer)

Any drawbacks ?

Err.. unfortunately (due to the limitations of Pascal's 286
restrictions) you can't have a bitmap that exceeds 64K - yes
I know this sucks but huge pointers don't exist in Pascal!!

The speed in some areas isn't as fast as it could be.. shit!!
So, I am considering writing a version of this unit which does
not use standard Pascal "stack frames" (Where Procedure parameters are
moved to) but instead requires registers to be set on entry (about
100% faster).

But this will all be done once me B.Sc is over.


THE DISCLAIMER
--------------

Scott Tunstall (Me), the programmer of this pascal source and hence unit
cannot be held responsible if ANY damage, be it physical or otherwise, to
your system/peripherals etc. occurs from use/misuse of the code
and/or unit. (Not that this unit uses any system-unfriendly hack
tricks..)

You can distribute this unit UNALTERED and it would be nice if you
mentioned me in any software you create with this unit.

Feel free to add parts to the unit. If any good, please post em to the SWAG 
and let everyone see them. However, I would prefer to see ASM stuff be added
instead of plain vanilla pascal.


Name    : Scott Tunstall
Address : 40 leadside crescent, Fife, Scotland.


Minimum System requirements
---------------------------
Turbo Pascal 6 - (Mind and check some of the "switches" below ).
TP7 recommended though.

386 processor.
VGA graphics card that supports mode 13h and the 262,144
    colour palette.



CONTACT: CG93SAT@IBMRISC.DCT.AC.UK (Up till June 15 1996)
*)








{ You may have to remove some of these switches if using TP6.
  Turbo 7 really is the bees knees (?) when it comes to software
  development, laddie.
 }

{$A+,B-,E+,F-,G+,N+,Q-,R-,S-}

UNIT NEWGRAPH;

INTERFACE

Const
      GetMaxX                 = 319;    { Maximum X & Y coordinates }
      GetMaxY                 = 199;
      GetMaxColour             = 255;
      MaxColours               = 256;

      Int1fFont               = 0;
      Int43Font               = 1;
      StandardVGAFont         = 1;
      Font8x8                 = 1;      { Why do I get a "Constant Out
                                        of range error" with this ? }
      Font8x14                = 2;
      Font8x8dd               = 3;      { Abbreviated }
      Font8x8ddHigh           = 4;
      AlphaAlternateFont      = 5;
      FontAlpha               = 5;
      Font8x16                = 6;
      Font9x16                = 7;      { This doesn't appear, though }
      FontRomAlt              = 7;      { it may just be my VGA }


{
This record is used to hold a screen/PCX's palette.
}

TYPE
PaletteType = record
   RedLevel:   Array[0..MaxColours-1] of byte;
   GreenLevel: Array[0..MaxColours-1] of byte;
   BlueLevel:  Array[0..MaxColours-1] of byte;
end;




{
This record is used to hold a Font's details, if you didn't guess
that already ;-)
}


FontType = record
   FontSeg       : Word;           { Where Font is located }
   FontOfs       : Word;
   FontWidth     : Byte;           { Width (In Pixels) }
   FontByteWidth : Byte;           { Pixel width divided by 8 }
   FontHeight    : Byte;           { Height (In Pixels) }
   FontChars     : Byte;           { Number of characters in Font }
End;




{ Jump into Mode 13h }

Procedure InitVGAMode;

{
Bitmap initialisation and manipulation routines.
}

Procedure Bitmap(Var BmapSegment,BmapOffset:word);
Procedure FreeBitmap(BmapSegment,BmapOffset:word);
Procedure ShowBitmap(BmapSegment,BmapOffset:word);
Procedure GetSourceBitmapAddr(VAR SourceSeg,SourceOfs: word);
Procedure SetSourceBitmapAddr(NewSourceSeg,NewSourceOfs:word);
Procedure GetDestinationBitmapAddr(VAR DestinationSeg,DestinationOfs: word);
Procedure SetDestinationBitmapAddr(NewDestinationBitmapSeg,NewDestinationBitmapOfs:word);
Procedure CopySourceBitmap;
Procedure OverlaySourceBitmap;
Procedure DoubleBufferOff;


{ Drawing primitives }

Procedure PutPixel(x, y : integer; ColourValue : Byte);
Function  GetPixel(X,Y: integer): integer;
Procedure Line(X1, Y1, X2, Y2:integer);
Procedure LineRel(DiffX,DiffY: integer);
Procedure LineTo(Endx,Endy:integer);
Procedure Rectangle(x1,y1,x2,y2:integer);
Procedure MoveTo(NewCursX,NewCursY:integer);
Function  GetX: integer;
Function  GetY: integer;
Procedure OutTextXY(x,y:integer; txt:string);
Procedure OutText(txt:string);


{ Palette stuff }

Procedure SetColour(NewColour:byte);
Function  GetColour: byte;
Procedure GetPalette(ColourNumber : Byte; VAR RedValue, GreenValue, BlueValue : Byte);
Procedure SetPalette(ColourNumber, RedValue, GreenValue, BlueValue : Byte);
Procedure LoadPalette(FileName: String; Var Palette : PaletteType);
Procedure SavePalette(FileName: String; Palette : PaletteType);
Procedure GetAllPalette(Var Palette : PaletteType);
Procedure SetAllPalette(Palette : PaletteType);


{
Fast sprite (shape) routines.
}


Procedure GetAShape(x1,y1,x2,y2:word;Var DataPtr);
Procedure FreeShape(DataPtr:pointer);
Procedure Blit(x,y:word; Var DataPtr);
Procedure ClipBlit(x,y:integer; Var DataPtr);
Procedure Block(x,y:word; Var DataPtr);
Procedure ClipBlock(x,y:integer; Var DataPtr);
Function  BlitColl(x,y :integer; Var dataptr) : boolean;
Function  ShapeSize(x1,y1,x2,y2:word):word;
Function  ExtShapeSize(ShapeWidth, ShapeHeight : byte): word;
Function  ShapeWidth(Var DataPtr): byte;
Function  ShapeHeight(Var DataPtr): byte;
Procedure LoadShape(FileName:String; Var DataPtr:Pointer);
Procedure SaveShape(FileName:string; DataPtr:Pointer);


{
Custom Font routines. Unfortunately, I don't know how to load
in Windows bitmapped Fonts which is a real bast..

}

Procedure UseFont(FontNumber:byte);
Function  GetROMCharOffset(CharNum:byte): word;
Procedure GetCurrentFontAddr(VAR FontSeg,FontOfs:word);
Procedure SetCurrentFontAddr(NewFontSeg,NewFontOfs:word);
Procedure GetCurrentFontSize(Var CurrFontWidth, CurrFontHeight:byte);
Procedure SetCurrentFontSize(NewFontWidth, NewFontHeight:byte);
Procedure LoadFont(FontFileName:String; Var FontRec: FontType);
Procedure UseLoadedFont(FontRec : FontType);
Procedure SaveFont(FontFileName:String; FirstChar, Numchars:byte);


{
Can't include a GIF loader.. Compuserve don't like people using
their GIF datatype without paying a small fee.. :(
}

Procedure LoadPCX(FileName:string; Var ThePalette: PaletteType);
Procedure LocatePCX(filename:string; Var ThePalette: PaletteType;
          x,y,widthtoshow,heighttoshow:word);
Procedure SavePCX(filename:string;ThePalette: PaletteType);
Procedure SaveAreaAsPCX(filename:string;ThePalette: PaletteType;
          x,y, PCXWidth,PCXHeight: word);


{
Miscellaneous useful routines.
}

Procedure Vwait(TimeOut:word);
Procedure Cls;
Procedure CCls(TheColour : byte);




IMPLEMENTATION


Uses CRT,Dos;


{
This ** structure ** was nicked from READPCX.PAS that's currently
in the SWAG. Credit to Norman Yen for writing a PCX loader program,
it was very useful for understanding the PCX compression.

But my version of the PCX loader (rewritten from scratch) is faster
(and better) than Norm's effort. And what's more it can handle Mode 13h
PCX's of any size up to 320 x 200 pixels.

}

type Pcxheader_rec=record               { EXPECTED VALUES / COMMENTS}
                                        { --------------------------}
     manufacturer: byte;                { 10. (Why does Z-Soft have
                                          this field ?) }
     version: byte;                     { 5. }
     encoding: byte;                    { 0.  (RLE PCX encryption) }
     bits_per_pixel: byte;              { 8.  (8 bits = 256 colours) }
     xmin, ymin: word;                  { 0,0 (Top Left) }
     xmax, ymax: word;                  { 319,199 (Bottom right) }
     hres: word;                        { 320 (although this (and vres)
                                          may be ignored by some
                                          programs)}
     vres: word;                        { 200 }
     palette: array [0..47] of byte;    { Don't use }
     reserved: byte;                    { Don't use }
     colour_planes: byte;               { 0 (Mode 13h is not planar) }
     bytes_per_line: word;              { 320 (usually, may differ -
                                          although I hear this should
                                          be an even number my PCX load
                                          /save routines work with odd
                                          numbers too) }
     palette_type: word;                { 12 (to work with this unit) }
     filler: string[58];                { Don't know the purpose of this,
                                          could it be for comments etc ? }
end;



{
****************
Variable section
****************

Note : You could make these public variables and that would probably
increase the speed of your programs as you can access the data
directly (via assembler, for example) instead of using the
Setxxx() Procedures.
}

Var
    SourceBitmapSegment:          word;
    SourceBitmapOffset:           word;
    DestinationBitmapSegment:     word;
    DestinationBitmapOffset:      word;

    CurrentFontSegment:         word;
    CurrentFontOffset:          word;
    CurrentFontWidth:           byte;
    CurrentFontByteWidth:       byte;
    CurrentFontHeight:          byte;
    CurrentColour:               byte;
    CursorX:                    integer;
    CursorY:                    integer;

    header:                     Pcxheader_rec;




(*
This routine has nothing to do with graphics - it just helps
with some routines.

Expects : PT is a standard pointer.
          Segm and Offs are uninitialised word variables.

Returns : On exit Segm holds the segment part of the pointer
          Offs holds the offset.

Corrupts : AX,BX,DI,ES.

*)

Procedure GetPtrData(pt:pointer; VAR Segm, Offs:word); Assembler;
Asm
   LES DI,PT            { Point ES:DI to where PT is in memory }
   MOV AX,ES            { Set AX to hold segment }
   MOV BX,DI            { BX to hold offset }

   LES DI,Segm          { Now write directly to variable Segm }
   MOV [ES:DI],AX
   LES DI,Offs          { And variable Offs }
   MOV [ES:DI],BX
End;




{
Switch into VGA256 (320 x 200 x 256 Colour mode).

Expects : Nothing

Returns : Nothing

Affects : It affects the current screen mode (obviously) palette,
          Font (and the weather in eastern Czechoslovakia :-) )

Notes  : If all you want to do is clear the screen then use
         Cls or CCls, which does not affect palettes etc.
}

Procedure InitVGAMode; Assembler;
asm
   XOR AH,AH
   MOV AL,$13   { Mode 19 is the mode we want ! ;-) }
   INT $10      { VGA 256 Colours here we come }
End;







{
****************************
BITMAP MANIPULATION ROUTINES
****************************
}



(*
Allocate memory for a virtual screen. (This command
it is ALWAYS 64,000 bytes that are allocated - the same
size as what is used by the VGA bitmap.

Expects  : Two empty variables of word size which will be
           used to hold the segment and offset of the virtual
           screen.

Returns  : The segment and offset of the memory area.

Corrupts : Don't know (and don't care! ).

Notes    : Unfortunately Pascal doesnt allow allocation of
           > 64K or incorportate HUGE pointers so therefore
           it was made impossible for me to have a huge bitmap
           that exceeds 64K.

*)


Procedure Bitmap(Var BmapSegment,BmapOffset:word);
Var MemoryAccessVar: pointer;
Begin
     GetMem(MemoryAccessVar,64000);
     GetPtrData(MemoryAccessVar,BmapSegment,BmapOffset);
End;









(*
This routine will free a virtual screen allocated by the
Bitmap routine above.

Expects :  The variables passed in as BmapSegment, BmapOffset should hold
           the same contents as what was allocated by Bitmap;

Returns :  Your machine may crash if you try and free a Bitmap that has
           not been allocated !

Corrupts : Don't know which registers are altered.

*)


Procedure FreeBitmap(BmapSegment,BmapOffset:word);
Var ThePointer: pointer;
Begin
     ThePointer:=Ptr(BmapSegment,BmapOffset);
     FreeMem(ThePointer,64000);
End;




{
Procedure used to blit one bitmap to another bitmap. Private
to unit.

Expects : DS:SI points to source page
          ES:DI points to destination page
          DX holds data segment address

Corrupts : CX,SI,DI.

Returns : Nothing

}



Procedure FastCopy; Assembler;
Asm
     MOV CX,2000
     CLD

     { The reason I have repeated the instructions 8 times is because
     this method is a lot faster than :

@Copy:
     DB $F3,$66,$a5
     LOOP @Copy


     If you are a total speed junkie then why not block copy those
     8 instructions, append them at the bottom, and set CX (Above)
     to 1000. In fact, for total speed freaks why not type 16,000
     of these instructions :-)

     Alternatively, buy a Pentium 120. ;-)

     (Feb 96 update: No point in me cracking that joke now when
     Melv's got a P133 - how fast technology advances eh?)
     }

@Copy:
     DB $66; MOVSW      { MOVSD }
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW      { 32 bytes moved in one loop. Whoa !}
     DEC CX
     JNZ @Copy          { On my 486 this is faster than LOOP }

     MOV DS,DX
End;






{
Copy a bitmap in memory to the VGA memory, therefore showing it
on screen.

Expects  : BmapSegment, BmapOffset to point to a bitmap in memory.

Returns  : Nothing


Corrupts : AX,CX,DX,SI,DI,ES
}


Procedure ShowBitmap(BmapSegment,BmapOffset:word); Assembler;
Asm
   MOV DX,DS
   MOV AX,$a000
   MOV ES,AX
   XOR DI,DI
   MOV SI,BmapOffset
   MOV DS,BmapSegment
   CALL FastCopy
End;







(*
This copies the Source Bitmap to the Destination Bitmap. Simple as that.
If the Destination Bitmap resides at $a000 : 0 then the VGA screen will
be updated (The main purpose for this routine)

Expects : Source Bitmap & Destination Bitmap to point to two legal 64K
          regions of memory (By "legal" I mean you have reserved these
          regions in the program for your own use, or know that they
          are free)

Returns : Nothing.

Corrupts : CX,DX,DI,ES
*)


Procedure CopySourceBitmap; Assembler;
Asm
     MOV DX,DS
     MOV ES,DestinationBitmapSegment
     MOV DI,DestinationBitmapOffset
     MOV SI,SourceBitmapOffset
     MOV DS,SourceBitmapSegment
     CALL FastCopy
End;







{
Get the segment and offset of the source Bitmap. (Where data
is written to, i.e. Sprites, Lines, etc)

Expects : SourceSeg and SourceOfs are two uninitialised word variables

Returns : On exit from this routine SourceSeg shall hold the segment and
          SourceOfs shall hold the offset.

Corrupts : AX,BX,ES

Notes :    The value on unit initialisation is: Segment = $a000
                                                Offset  = 0.

You can change the Source Bitmap address by using SetSourceBitmapAddr.

}


Procedure GetSourceBitmapAddr(VAR SourceSeg,SourceOfs: word); Assembler;
Asm
   MOV AX,SourceBitmapSegment
   MOV BX,SourceBitmapOffset
   LES DI,SourceSeg
   MOV [ES:DI],AX
   LES DI,SourceOfs
   MOV [ES:DI],AX
End;








{
Set the Source Bitmap address. The source Bitmap is where ALL of the
graphics operations are performed, except for copying.


Expects : NewSourceSeg = Segment of the new Source Bitmap
          NewSourceOfs = Offset of the new Source Bitmap

Returns : Nothing

Notes   : The source Bitmap must reside within the first 640K of DOS memory,
          or at segment $a000 (Video Ram).

          I am sorry about this limitation but that's MS-DOS for you.
          And before a lot of mail floods in saying "what about using XMS"
          etc. I say, "It's in my new unit, old chap" :-)


Corrupts : AX
}


Procedure SetSourceBitmapAddr(NewSourceSeg,NewSourceOfs:word); Assembler;
Asm
     MOV AX,NewSourceSeg
     MOV SourceBitmapSegment,AX
     MOV AX,NewSourceOfs
     MOV SourceBitmapOffset,AX

End;






{
Get the address of the Destination Bitmap. (Where data is to be copied
to with CopySourceBitmap).

Expects : Two word variables to hold the segment & offset of the
          source Bitmap.

Returns : Segment & Offset of the source Bitmap.

Corrupts : AX,DI,ES.


Note : The Destination Bitmap defaults to segment $a000 offset 0.


}

Procedure GetDestinationBitmapAddr(VAR DestinationSeg,DestinationOfs: word); Assembler;
Asm
   MOV AX,DestinationBitmapSegment
   LES DI,DestinationSeg
   MOV [ES:DI],AX
   MOV AX,DestinationBitmapOffset
   LES DI,DestinationOfs
   MOV [ES:DI],AX
End;










{
Set the address of the Destination Bitmap.


Expects :  NewDestinationBitmapSeg is the segment of the New
           Destination Bitmap. (Never! :-) )
           NewDestinationBitmapOfs is the offset.

Returns :  Nothing

Corrupts : AX

}

Procedure SetDestinationBitmapAddr(NewDestinationBitmapSeg,NewDestinationBitmapOfs:word); Assembler;
Asm
   MOV AX,NewDestinationBitmapSeg
   MOV DestinationBitmapSegment,AX
   MOV AX,NewDestinationBitmapOfs
   MOV DestinationBitmapOffset,AX
End;






{
By setting the Destination Bitmap to the Source Bitmap, "double buffering"
is effectively turned OFF. This routine is only of use to those who
work with multiple graphics Bitmaps.

This will make sure that data is written to the Destination
Bitmap ALWAYS.

Expects : Nothing.

Returns : DestinationBitmap points to SourceBitmap.

Corrupts : AX
}


Procedure DoubleBufferOff; Assembler;
Asm
   MOV AX,SourceBitmapSegment
   MOV DestinationBitmapSegment,AX
   MOV AX,SourceBitmapOffset
   MOV DestinationBitmapOffset,AX
End;









{
This routine will overlay the SOURCE Bitmap with the DESTINATION
Bitmap (writing the overlaid Bitmap data to the DESTINATION screen)
therefore making it possible to create a parallaxing
effect.

Of course, you could simply use it to overlay two PCXs etc. etc.


Expects : SourceBitmapSegment, SourceBitmapOffset to point to an
          initialised Bitmap. This Bitmap is treated as the
          FOREGROUND. All pixels with colour 0 within the
          bitmap are treated as TRANSPARENT.

          The same applies to DestBitmapSegment, DestBitmapOffset.
          The Dest Bitmap is treated as the BACKGROUND.

Returns : Nothing

Corrupts : AX,CX,DX,SI,DI,ES

}

Procedure OverlaySourceBitmap; Assembler;
Asm
   MOV DX,DS                    { Save DS - faster than using stack }

   MOV DI,DestinationBitmapOffset
   MOV ES,DestinationBitmapSegment
   MOV SI,SourceBitmapOffset
   MOV DS,SourceBitmapSegment
   MOV CX,16000

@CheckIfTransparent:
   DB $66                       { 66h indicates 32 bit destination }
   LODSW                        { LODSD -> Read DWORD from source Bitmap
                                into AX }
   OR AL,AL                     { Check if AL is 0 }
   JZ @ALClear                  { If so, can't overlay it }
   MOV [ES:DI],AL               { Otherwise, write it }

@ALClear:
   INC DI
   OR AH,AH                     { Check if AH is 0 }
   JZ @AHClear                  { Shouldn't blit with a 0 byte }
   MOV [ES:DI],AH

@AHClear:
   INC DI
   DB $66
   SHR AX,16                    { Move upper word of EAX into
                                  into AH and AL }
   OR AL,AL                     { Check if AL is 0 }
   JZ @EALClear                 { If so, can't overlay it }
   MOV [ES:DI],AL               { Otherwise, write it }

@EALClear:
   INC DI
   OR AH,AH                     { Check if AH is 0 }
   JZ @NoBlit                   { Shouldn't blit with a 0 byte }
   MOV [ES:DI],AH


@NoBlit:
   INC DI                       { Next byte }
   DEC CX                       { Reduce count }
   JNZ @CheckIfTransparent

   MOV DS,DX                    { Restore DS }
End;







{
***********************
PRIMITIVE DRAWING TOOLS
***********************
}


{
Calculate the offset of a pixel on the SOURCE Bitmap.

Registers expected on entry:
AX = the horizontal coordinate (0 to GetMaxX) and ..
BX = the vertical coordinate (0 to GetMaxY)


Returns  : BX = -1 if X or Y were out of bounds.
           Otherwise, BX is an offset, which, combined with
           the contents of SourceBitmapSegment point to an address
           in RAM where the pixel can be plotted/read from.

Notes    : This routine is private to the unit. To maintain
           compatibility with further revisions (which I churn out
           with frightening regularity ;-) ) I recommend all extra
           unit routines that require a pixel address calc'ed call
           this proc.

Corrupts : AX, BX, CX are corrupted.

}


Procedure CalculateOffset; Near; Assembler;
Asm
     CMP AX,319         { Is X> 319 ? }
     JA @OutOfBounds    { Yes }
     CMP BX,199         { Is Y> 199 ?. Do not use BL instead as this is
                          when problems will occur.}
     JA @OutOfBounds    { Yes }

     XOR CH,CH                  { CX = Y }
     MOV CL,BL
     SHL CX,6                   { Y * 64 }
     MOV BH,BL                  { BX = Y * 256 }
     XOR BL,BL
     ADD BX,CX                  { BX = BX + CX, which gives Y * 320 }
     ADD BX,AX                  { Add the X position to offset in BX }
     ADD BX,SourceBitmapOffset    { Take into account the offset in memory
                                  of the source Bitmap }

     JMP @Finito                { And exit. }

@OutOfBounds:
     MOV BX,-1                  { Signal that coordinates were not within
                                  the screen limits }

@Finito:
End;






{
This GetPixel routine differs from the Turbo equivalent as the
return type is integer, not word. A small point, but still
(UN)worth mentioning. <grin>

Expects  : X and Y specify the horizontal and vertical coordinates of
           a pixel. X may be 0..GetMaxX, Y may be 0..GetMaxY.

Returns  : If the coordinates are within screen bounds, then GetPixel =
           Colour at X,Y. If not, then GetPixel = -1.

Corrupts : AX/BX/CX/DX/FS.
}

Function GetPixel(X,Y: integer): integer; Assembler;
Asm
   MOV AX,X
   MOV BX,Y

   CALL CalculateOffset         { Now get offset in BX }
   CMP BX,-1                    { Is coordinate off screen ? }
   JZ @NoGet                    { Yes, so return value of -1 }
   DB $8E, $26
   DW OFFSET SourceBitmapSegment

   XOR AH,AH
   DB $64
   MOV AL,[BX]

   JMP @Finished                { Can't put a RET here - maybe this
                                  unit was compiled in FAR mode, and
                                  a crash would occur! }

@NoGet:
   MOV AX,BX                    { AX = -1, meaning no pixel could be
                                  read }

@Finished:
End;






{
Write a pixel to the screen.

Expects :  AX to be the X coord for a pixel (0 to GetMaxX),
           BX for the Y coord (0 to GetMaxY) - Don't be tempted
           to optimize the code by using BL, as this causes
           problems when using negative Y coordinates. (As some
           programs will)
           DL is the colour (0 to 255) to plot.

Returns :  Nothing

Notes   :  This putpixel is private to the unit and should be
           used when plotting pixels that MAY be off screen
           to keep in step with the rest of the unit.

On exit AX,BX,CX,DX,FS are corrupt.
}


Procedure FPutPixel; Near; Assembler;
Asm
   CALL CalculateOffset                 { AX/ BX already set up }
   CMP BX,-1                            { Coordinates off screen ? }
   JA @NoPlot                           { Yeah, so don't put pixel }
   DB $8E,$26                           { MOV FS, [SourceBitmapSegment] }
   DW OFFSET SourceBitmapSegment
   DB $64                               { MOV [FS:BX],DL }
   MOV [BX],DL

@NoPlot:
End;







{
This is the Pascal interface for the Fputpixel routine, it's
really quite sad how Pascal uses the stack so much, when you see
the likes of Turbo C & it's (amazingly interesting) register
usage which is quite fast. :(

But not as fast as me when I'm going to the pub. :-)

Expects : X = Horizontal coordinate of a pixel (0-GetMaxX)
          Y = Vertical coordinate of a pixel (0-GetMaxY)
          ColourValue = Colour to plot , 0 - 255.

Returns : Nothing

Corrupts : See FPutPixel.
}

Procedure PutPixel(x, y : integer; ColourValue : Byte); Assembler;
Asm
   MOV AX,x               { I wish TP had the capacity to load these
                            automatically for you, instead of creating
                            a crappy stack frame and pushing X, Y. }
   MOV BX,y               { Is it any wonder I love C++ more ? }
   MOV DL,ColourValue
   CALL FPutPixel         { Don't use a JMP, your program will crash }
End;







{
This line routine was converted to assembler (by ME!!) from the
SWAG team's line draw routine (in Pascal) which was very fast.
So this means this'll be ULTRA FAST (hopefully ;-) ).

Bresenham who ? :-)  Diamond Geezer.

I wonder if this is faster than Sean Palmer's line draw in ASM ?
(Check the SWAG for that program - it's smart)

Expects : X1,Y1 defines the horizontal, vertical start of the line
          X2,Y2 defines the horizontal, vertical end of the line.
          Coordinates may be negative or exceed screen bounds.

          Line will be drawn in CurrentColour.

Returns : Nothing

Corrupts: AX,BX,CX,DX,SI,DI,ES,FS.

}


Procedure Line(X1, Y1, X2, Y2: Integer); Assembler;
Var
  LgDelta,
  ShDelta,
  LgStep,
  ShStep,
  Cycle : word;

Asm
  MOV BX,X2             { LgDelta = X2 - X1 }
  MOV SI,X1
  SUB BX,SI
  MOV LgDelta,BX

  MOV CX,Y2             { ShDelta = Y2 - Y1 }
  MOV DI,Y1
  SUB CX,DI
  MOV ShDelta,CX

  TEST BH,$80           { If bit 7 not set .. }
  JZ @LgDeltaPos        { Goto LgDeltaPos }

  NEG BX
  MOV LgDelta,BX
  MOV LgStep,$FFFF
  JMP @Cont1

@LgDeltaPos:
  MOV LgStep,1

@Cont1:
  CMP CH,$80           { If ShDelta < 0 Then.. }
  JB @ShDeltaPos
  NEG CX
  MOV ShDelta,CX
  MOV ShStep,$FFFF
  JMP @Cont2

@ShDeltaPos:
  MOV ShStep,1

@Cont2:
  CMP BX,CX                   { BX = LgDelta, CX = ShDelta }
  JB @OtherWay

  SHR BX,1                    { Cycle:= LgDelta SHR 1 }
  MOV Cycle,BX

  {
  O.K. I'm going to use :
  SI as X1, DI as Y1, CX as X2, DX as Y2.
  }

  MOV CX,X2

@FirstLoop:
  CMP SI,CX             { While X1 <> X2 }
  JZ @GetTheShitOut     { Why not have an expletive as a label ? }

  MOV AX,SI              { Set AX and BX to X1,Y1 ready for call }
  MOV BX,DI              { BX = Y1 }

  MOV ES,CX              { The only free register ! }
  MOV DL,CurrentColour
  CALL FPutPixel
  MOV CX,ES

  ADD SI, LgStep         { X1 = X1 + LgStep }
  MOV AX,Cycle
  ADD AX,ShDelta         { Inc(Cycle,ShDelta) }
  MOV Cycle,AX           { Yes I did check the code and this is fastest }

  MOV BX,LgDelta
  CMP AX,BX              { If Cycle > LgDelta }
  JB @FirstLoop

  ADD DI,ShStep          { Y1 = Y1 + ShStep }
  SUB AX,LgDelta         { Dec(Cycle,LgDelta) }
  MOV Cycle,AX
  JMP @FirstLoop

  {
  O.K. If we go in a different direction..

  On entry, BX = LgDelta, CX = ShDelta

  }

@OtherWay:
  MOV AX,CX
  SHR AX,1              { ShDelta SHR 1 }
  MOV Cycle,AX
  XCHG BX,CX            { BX = ShDelta, CX = LgDelta }
  MOV LgDelta, BX
  MOV ShDelta, CX

  MOV BX,LgStep         { Swap LgStep and ShStep round }
  MOV CX,ShStep
  MOV ShStep,BX
  MOV LgStep,CX

  {MOV CX,X2}             { CX = X2, DX = Y2 }
  MOV DX,Y2

@SecondLoop:
  CMP DI,DX             { While Y1 <> Y2 do }
  JZ @GetTheShitOut


{
If it can, then it's time for action!
}

  MOV AX,SI             { Set AX and BX to X1,Y1 }
  MOV BX,DI             { BX = Y1 }

  MOV ES,DX             { Sorry, but this was the only free register ! }
  MOV DL,CurrentColour
  CALL FPutPixel
  MOV DX,ES             { .. Please don't think I am sloppy ! }

  ADD DI,LgStep         { Inc(Y1,LgStep) }
  MOV AX,Cycle          { Inc(Cycle,ShDelta) }
  ADD AX,ShDelta
  MOV Cycle,AX

  MOV BX,LgDelta

  CMP AX,BX             { If Cycle > LgDelta Then.. }
  JB @SecondLoop

  ADD SI,ShStep         { Inc(X1,ShStep) }
  SUB Cycle,BX          { Dec(Cycle,LgDelta) }
  JMP @SecondLoop

@GetTheShitOut:
  MOV AX,X2             { Write last pixel. This was an absolute }
  MOV BX,Y2             { b****** to debug :-) }
  MOV DL,CurrentColour
  CALL FPutPixel        { Just a wee bit of Scottish humour there }

End;









{
Draw a line relative from the current cursor position.
Relative means that the DiffX and DiffY values are added to the
current cursor coordinates to give the resulting horizontal and vertical
end points of the line.

For example, if CursorX and CursorY were 10,10 and DiffX and DiffY
were -10,-10 then the line would be drawn to position 0,0. Conversely,
if DiffX was 10 and DiffY was 20 then the cursor would be drawn to
X 20, Y 30.


Expects : DiffX is a non zero value that may be negative, which
          specifies the relative distance from the current horizontal
          cursor position.

          DiffY specifies the relative distance from the current
          vertical position.

Returns : Nothing

Corrupts : Probably the same as the Line routine.
}

Procedure LineRel(DiffX,DiffY: integer); Assembler;
Asm
     MOV AX,CursorX
     MOV BX,AX
     ADD BX,DiffX
     MOV CX,CursorY
     MOV DX,CX
     ADD DX,DiffY

     {
     Strange method of reading the stack, Borland. :-(
     }

     PUSH BX            { X + DiffX }
     PUSH DX            { Y + DiffY }
     PUSH AX            { X }
     PUSH CX            { Y }
     CALL Line          { Must return so dynamic vars can be moved.
                          Wish I could get rid of them quicker. }
End;








{
Draw from the current cursor position to the horizontal and vertical
positions specified by EndX and EndY. The Graphics Cursor will be
moved to EndX, EndY.

Expects : EndX to be the horizontal position of the line end. (0 to GetMaxX)
          EndY to be the vertical position of the line end. (0 to GetMaxY)

Returns : Nothing, but you should be aware that the graphics cursor
          position is now at EndX, EndY.

Corrupts : AX,BX,CX,DX,SI,DI,ES,FS
}

Procedure LineTo(EndX,EndY:integer); Assembler;
Asm
   PUSH EndX
   PUSH EndY
   PUSH CursorX
   PUSH CursorY
   CALL Line
   MOV AX,EndX
   MOV CursorX,AX
   MOV AX,EndY
   MOV CursorY,AX
End;







{
Probably not the fastest rectangle draw you'll see.
But it is economical with memory, and it works !

Expects  : X1,Y1,X2,Y2 define a rectangular window.

Returns  : Nothing

Corrupts : Not a clue.

Notes    : This routine does not move the graphics cursor.
}


Procedure Rectangle(x1,y1,x2,y2:integer);
Begin
     Line(x1,y1,x2,y1);         { Top Line    }
     Line(x1,y2,x2,y2);         { Bottom Line }
     Line(x1,y1+1,x1,y2-1);     { Left edge   }
     Line(x2,y1+1,x2,y2-1);     { Right edge  }
End;









{
Change position of graphics cursor.

Expects : NewCursX and NewCursY are the horizontal and vertical
          coordinates that you wish to move the cursor to.
          NewCursX may be negative or more than GetMaxX.
          NewCursY may be negative or more than GetMaxY.

Returns : Nothing

Corrupts : AX.
}

Procedure MoveTo(NewCursX,NewCursY:integer); Assembler;
Asm
   MOV AX,NewCursX
   MOV CursorX,AX
   MOV AX,NewCursY
   MOV CursorY,AX
End;










{
Returns horizontal position of graphics cursor.
GetX May be negative.

Expects : Nothing

Returns : GetX = Current graphics cursor horizontal position, which
          may be negative or even exceed GetMaxX.
}

Function GetX: integer; Assembler;
Asm
   MOV AX,CursorX
End;








{
Returns vertical position of graphics cursor.
GetY may be negative.

Expects : Nothing

Returns : GetY = Current graphics cursor vertical position, which
          may be negative or even exceed GetMaxY.


}

Function GetY: integer; Assembler;
Asm
     MOV AX, CursorY
End;











{
*************
FONT ROUTINES
*************

}


{
Select which of the Fonts in ROM you use to write text to the
screen.

Expects : FontNumber can be:

          0: For CGA Font (Dunno what size it is tho')
          1: For 8 x 8 Font
          2: For 8 x 14 Font
          3: For 8 x 8 Font
          4: For 8 x 8 Font high 128 characters
          5: For Rom Alpha Alternate Font
          6: For 8 x 16 Font
          7: For Rom Alternate 9 x 16 Font


Returns : Nothing

Corrupts : AX,BX,ES

}

Procedure UseFont(FontNumber:byte); Assembler;
Asm
     MOV AX,$1130                      { Get Font address }
     MOV BH,FontNumber
     CMP BH,7                          { Font number > 7 ? }
     JA @NoWriteSize                   { Yes, so it's invalid }

     PUSH BP                           { Mustn't corrupt BP, as Turbo
                                         needs it preserved for local
                                         variable access }
     PUSH BX                           { Nor BH as it's to be used later }
     INT $10                           { Now get Font address }
     MOV CurrentFontSegMent,ES         { ES:BP points to where Font is }
     MOV CurrentFontOffset,BP          { located in ROM }
     POP BX                            { Restore Font number }
     POP BP                            { Restore BP }

     CMP BH,Int1fFont                  { User Font in memory ? }
     JZ @NoWriteSize                   { Don't set size, could be more than
                                         8 x 8. User will have to set himself.
                                         Please correct me if I am wrong }
     CMP BH,Font8x8                    { User want any of the 8 x 8 Fonts ? }
     JZ @Set8x8
     CMP BH,Font8x8dd
     JZ @Set8x8
     CMP BH,Font8x8ddHigh
     JZ @Set8x8
     CMP BH,AlphaAlternateFont
     JNZ @Check8x14Font

@Set8x8:
     MOV AL,8                          { Width of 8 }
     MOV AH,8                          { Height of 8 }
     MOV BL,1                          { 1 byte's width }
     JMP @DoWrite



@Check8x14Font:
     CMP BH,Font8x14
     JNZ @Check8x16Font
     MOV AL,8                          { Width 8, Height 14, ByteWidth 1 }
     MOV AH,14
     MOV BL,1
     JMP @DoWrite

@Check8x16Font:
     CMP BH,Font8x16
     JNZ @UseRomAlternateFont
     MOV AL,8                          { Oh C'mon do I have to document }
     MOV AH,16                         { this ? }
     MOV BL,1
     JMP @DoWrite

@UseRomAlternateFont:
     MOV AL,9
     MOV AH,16
     MOV BL,2


@DoWrite:
     MOV CurrentFontWidth,AL           { Write Font details so that }
     MOV CurrentFontByteWidth,BL       { outtextXY etc. can work with }
     MOV CurrentFontHeight,AH          { this Font }

@NoWriteSize:
End;






{
If you wish to do your own text routines, then this returns the
address of the current Font in FontSeg and FontOfs which specify the
segment and offset address of the character set.

Expects  : Two uninitialised word variables

Returns  : FontSeg = Segment where Font is located
           FontOfs = Offset of Font

Corrupts : AX,DI,ES.

}

Procedure GetCurrentFontAddr(VAR FontSeg, FontOfs:word); Assembler;
Asm
   MOV AX,CurrentFontSegment
   LES DI,FontSeg
   MOV [ES:DI],AX
   MOV AX,CurrentFontOffset
   LES DI,FontOfs
   MOV [ES:DI],AX
End;






{
If you want to use a Font loaded in from disk use SetFontAddr to
specify where the new Font resides in memory.

Expects : NewFontSeg and NewFontOfs are the segment and offset of the
          address.

Returns : Nothing

Corrupts : AX
}

Procedure SetCurrentFontAddr(NewFontSeg,NewFontOfs:word); Assembler;
Asm
   MOV AX,NewFontSeg
   MOV CurrentFontSegment,AX
   MOV AX,NewFontOfs
   MOV CurrentFontOffset,AX
End;







{
Find out what width and height the current Font is.

Expects: CurrFontWidth and CurrFontHeight are two uninitialised
         variables.

Returns: CurrFontWidth and CurrFontHeight on exit hold the width
         and height of the current Font. (Bet you never guessed that, huh)

Corrupts : AX,DI,ES
}


Procedure GetCurrentFontSize(Var CurrFontWidth, CurrFontHeight:byte); Assembler;
Asm
   MOV AL,CurrentFontWidth
   MOV AH,CurrentFontHeight

   LES DI,CurrFontWidth         { ES: DI points to variable now }
   MOV [ES:DI],AL
   LES DI,CurrFontHeight
   MOV [ES:DI],AH
End;







{
Specify width and height of a user created Font.

Expects  : NewFontWidth must be above 7,
           NewFontHeight can be any non-zero number.

Returns  : Nothing

Corrupts : AX

}

Procedure SetCurrentFontSize(NewFontWidth, NewFontHeight:byte); Assembler;
Asm
     MOV AL,NewFontWidth
     MOV AH,NewFontHeight

     CMP AL,8                   { Width >= 8 ? }
     JB @IllegalSize
     OR AH,AH                   { Is Height 0 ? }
     JZ @IllegalSize

     MOV CurrentFontWidth,AL
     MOV CurrentFontHeight,AH
     SHR AL,3                   { Calculate byte width of characters
                                  i.e. divide width in pixels by 8 }
     MOV CurrentFontByteWidth,AL

@IllegalSize:

End;







{
For those of you who want to do your own text routines, this
Procedure may lighten your workload a bit.

Expects : Characternumber to be (obviously) the number of the
          character.

Returns : This Function returns the offset address of character.

Corrupts : AX,BX,DX
}

Function GetROMCharOffset(CharNum:byte): word; assembler;
Asm
   MOV AL,CharNum                  { Get number of character into AL }
   MOV BH,CurrentFontByteWidth
   MOV BL,CurrentFontHeight
   MUL BL                          { Multiply character num by FontHeight }
   MOV BL,BH
   XOR BH,BH
   MUL BX                          { And FontWidth }
   ADD AX,CurrentFontOffset        { Now add in the font offset }
End;







(*
This routine lets you load bitmapped Font files (created by this
unit) from disk. Currently I am examining the file format of
Compugraphic Fonts and basically I understand absolutely sod all
of it.. send me some code for reading them please !!


FontType = record
   FontSeg    : Word;           { Where Font is located; when loaded }
   FontOfs    : Word;           { in these are set by system }
   FontWidth  : Byte;           { Width (In Pixels) }
   FontByteWidth : Byte;
   FontHeight : Byte;           { Height (In Pixels) }
   FontChars  : Byte;           { Number of characters in Font }
End;


*)


Procedure LoadFont(FontFileName:String; Var FontRec: FontType);
Var FontFile : File;
    BytesToReserve : word;
    FontPtr : Pointer;

Begin
     Assign(FontFile,FontFileName);
     Reset(FontFile,1);
     BlockRead(FontFile,FontRec,SizeOf(FontRec));
     With FontRec Do
          Begin
          BytesToReserve:=FontChars * (FontByteWidth * FontHeight);
          GetMem(FontPtr,BytesToReserve);
          GetPtrData(FontPtr,FontSeg,FontOfs);
          BlockRead(FontFile,Mem[FontSeg:FontOfs],BytesToReserve);
     End;
     Close(FontFile);
End;







{
This routine will save a portion (or all) of the current Font to disk.

Expects : FontFileName to be an MS-DOS filename to hold the char data.
          FirstChar to be the number of the first character to save
          (0-255);
          NumChars to be the number of characters to save (You may
          only want to save part of a Font).

Returns  : Nothing

Corrupts : Don't know.
}


Procedure SaveFont(FontFileName:String; FirstChar, Numchars:byte);
Var TempFontRec     : FontType;
    FontFile        : File;
    BytesPerChar    : word;
    FirstCharOffset : word;

Begin
     With TempFontRec do
          Begin
          FontSeg:=0;               { 0 Meaning uninitialised }
          FontOfs:=0;
          FontByteWidth:=CurrentFontByteWidth;
          FontWidth:=CurrentFontWidth;
          FontHeight:=CurrentFontHeight;
          FontChars:=NumChars;
     End;

     Assign(FontFile,FontFileName);
     Rewrite(FontFile,1);
     BlockWrite(FontFile,TempFontRec,SizeOf(TempFontRec));

     BytesPerChar:=CurrentFontByteWidth * CurrentFontHeight;
     FirstCharOffset:=CurrentFontOffset+(FirstChar * BytesPerChar);

     BlockWrite(FontFile, Mem[CurrentFontSegment:FirstCharOffset],
     NumChars * BytesPerChar);

     Close(FontFile);


End;






{
Use a Font loaded in from disk. Yes, I know there are many Font load
routines in the SWAG and most (if not ALL) use interrupt 10h to do
the business. But my routine doesn't because quite frankly using the
BIOS is slow, cack, and is far too limiting.

This routine allows characters of ANY size.

Expects : Variable FontRec to have been initialised (usually by LoadFont).
          You could initialise FontRec yourself if you liked and
          that would be faster than using SetFontAddr, SetFontSize etc.

Returns : Nothing

Corrupts : Don't know. That's the thing about Pascal!
}


Procedure UseLoadedFont(FontRec : FontType);
Begin
     With FontRec Do
          Begin
          CurrentFontSegment:=FontSeg;
          CurrentFontOffset:=FontOfs;
          SetCurrentFontSize(FontWidth,FontHeight);
     End;
End;








{
Display text at a position on screen. (May be off screen)

Expects : X,Y specify the top left of where the text is to be
          printed.
          txt is the actual text to be printed.

Returns : Graphics cursor position is changed. (In normal Turbo
          it is not, but what the hell)

Corrupts : AX,BX,CX,DX,SI,DI,ES,FS,GS.

}


Procedure OutTextXY(x,y:integer; txt:string); Assembler;
Asm
         MOV AX,X
         MOV CursorX,AX
         MOV AX,Y
         MOV CursorY,AX

         XOR BH,BH                    { Get Font height into BX }
         MOV BL,CurrentFontHeight
         NEG BX                       { Make BX negative number }

         CMP AX,BX                    { Check if text would not be
                                        seen at top edge of screen
                                        (i.e. If -FontHeight >
                                        CursorY) }
         JL @NoWrite                  { Yes, so don't write text }

         CMP AX,199                   { Check if off bottom of screen }
         JG @NoWrite                  { Yes, so don't write text }

         PUSH BP
         LES DI,TXT                   { Yes, I know LGS DI exists but
                                        it's a lot of hassle to find
                                        out it's opcodes !}
         MOV AX,ES
         DB $8E,$E8                   { MOV GS, AX }

         DB $65                       { GS : }
         MOV CL,[DI]                  { MOV CL, [GS:DI]
                                        CL = Length of string }

@ReadChar:

         INC DI                      { Prepare to read char }
         PUSH DI                     { And offset of char }
         PUSH CX

         DB $65                      { GS : }
         MOV AL,[DI]                 { AL = Character }
         XOR AH,AH



         PUSH AX

         MOV AL,CurrentFontByteWidth   { Now compute Fontbytewidth
                                         * Fontheight }
         MOV BL,CurrentFontHeight

         MUL BL                        { Fontbytewidth * FontHeight }
         MOV DI,AX                     { DI = Result }

         POP AX                        { Restore character number }
         MUL DI                        { AX = Char * (FontByteWidth *
                                         FontHite) }

         ADD AX,CurrentFontOffset
         MOV DI,AX                     { Now DI is correctly placed }


         {
         Now blit the data to the screen
         Come on Bas, write something faster for this purpose..
         Bet you can't !
         }

         MOV ES,CurrentFontSegment

         MOV AX,CursorX              { Update graphic coordinates }
         MOV BX,CursorY

         MOV CH,CurrentFontHeight

@ScanLineLoop:
         PUSH CX                     { Save Vert Count on stack }
         MOV CH,CurrentFontByteWidth

@OuterLoop:

         MOV CL,[ES:DI]        { Read byte from charmap }
         OR CL,CL              { test if it's 0 }
         JZ @RestoreByteOffset { If so, no point in wasting CPU time }

         {
         Otherwise..
         }

         MOV BP, AX            { Save X - Coord }
         MOV DH,8              { 8 bits make a character's byte }
         MOV DL,CurrentColour   { FPutPixel needs this }


@PlotLoop:
         TEST CL,$80           { Bit 7 set ? }
         JZ @NoPlot            { No, so don't plot a pixel }

         MOV SI,AX             { Save X in SI - SI is the only
                                 Free register and it's faster than
                                 a PUSH }

         PUSH BX
         PUSH CX

         CALL FPutPixel        { Plot pixel at AX,BX. }

         POP CX
         POP BX
         MOV AX,SI             { Restore X coord }

@NoPlot:
         SHL CL,1              { Shift char byte left }
         INC AX                { Adjust X }

         DEC DH                { Reduce horizontal count }
         JNZ @PlotLoop         { If not 0, go to plot loop }

         MOV AX,BP




@RestoreByteOffset:
         INC DI                { move to next byte }

         DEC CH                { Reduce byte count }
         JNZ @OuterLoop

         POP CX                { Restore vert count }

         INC BX                { Add 1 to Y, assuming Y is not more
                                 than 255. Do NOT use BL to gain more
                                 speed! unexpected side effects will
                                 occur when writing text at the top of
                                 your screen }
         DEC CH                { Reduce vert count }

         JNZ @ScanLineLoop


{
Now is the time to update the graphics cursor after the single
character has been printed.
}

         MOV AL,CurrentFontWidth
         XOR AH,AH                   { Make AH 0 }
         ADD CursorX,AX              { Update the graphics cursor }

         POP CX                { Restore width. Wish there were more
                                 data registers to work with but there
                                 aren't and it's a bad situation really }
         POP DI                { Restore next char to print's offset }

         DEC CL                { Reduce char length counter }
         JNZ @ReadChar

         POP BP

@NoWrite:
End;








{
Display a string of text at the current cursor position, using
the current Font.

Expects : Txt is the text to write at the current cursor position.

Returns : Graphics cursor has moved.

Corrupts : See OutTextXY.
}

Procedure OutText(txt:string);
Begin
     OutTextXY(CursorX,CursorY,txt);
End;
