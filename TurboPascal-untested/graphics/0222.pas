{
PART 2 OF NEWGRAPH.PAS

You need NEWGRPH1.PAS first. Insert this into the bottom of the
NEWGRPH1.PAS file, compile and use this TPU till yer blue in the
face!!!



****************
Palette routines
****************

}




{
Get the red, green and blue components of a colour.

Expects :   ColourNumber is the number of the colour of which you
            want to read the Palette values (0-255).
            RedValue, GreenValue, BlueValue need not be initialised.

Returns :   The Red, Green, Blue Values of the colour specified
            by ColourNumber.

}

Procedure GetPalette(ColourNumber : Byte;
          VAR RedValue, GreenValue, BlueValue : Byte); Assembler;
Asm
   MOV DX,$3C7          { $3C7 is colour ** READ ** select port. }
   MOV AL,ColourNumber   { Select colour to read }
   OUT DX,AL
   ADD DL,2             { DX now = $3C9, which must be read 3 times
                          in order to obtain the Red, Green and
                          Blue values of a colour }

   IN AL,DX             { Read red amount. Don't use IN AX,DX as
                          for some strange reason it doesn't work ! }
   LES DI,RedValue
   MOV [ES:DI],AL       { Techie saddos note : STOSB is approx 4 cycles
                          slower and requires double cache multiplex,
                          which basically means "who gives a shit ?". :-)
                        }

   IN AL,DX
   LES DI,GreenValue
   MOV [ES:DI],AL

   IN AL,DX             { Read blue }
   LES DI,BlueValue
   MOV [ES:DI],AL
End;





{
This will change the red green and blue components of a colour,
thereby affecting it's shade. How's that for picturesque speech ?

Note : You don't need a PaletteType record to use this command,
it affects the screen directly.

Expects : ColourNumber is the number of the colour from 0 to 255.
          RedValue is the red component of the colour (0-63).
          GreenValue is the green component of the colour (0-63).
          BlueValue is the blue component of the colour (0-63).

Returns : Nothing

Corrupts : AL,DX
}


Procedure SetPalette(ColourNumber, RedValue, GreenValue, BlueValue : Byte); Assembler;
Asm
   MOV AL,ColourNumber
   MOV DX,$3c8          { Write to Port $3C8 with number of Colour to alter }
   OUT DX,AL
   INC DL               { $3C9 again ! }
   MOV AL,RedValue      { Store Red }
   OUT DX,AL
   MOV AL,GreenValue    { Store Green }
   OUT DX,AL
   MOV AL,BlueValue     { Store Blue }
   OUT DX,AL
End;






(*
This Procedure takes a snapshot of all of the colours on screen.

Expects : Palette is a variable of type PaletteType which will
          hold the 256 colour palette.

Returns : Nothing

Notes   : Use this command just before a mode change so that
          you can restore the palette to it's original state
          (via SetAllPalette) at the end of the program.
          (Unless of course you want to corrupt everything)

*)


Procedure GetAllPalette(Var Palette : PaletteType);
Var ColourCount:byte;
Begin
     For ColourCount:=0 to (MaxColours - 1) do
     GetPalette(ColourCount,Palette.RedLevel[ColourCount],
     Palette.GreenLevel[ColourCount],Palette.BlueLevel[ColourCount]);
End;







{
Do I need to explain what this does? It loads in a Palette
from file FileName and stores it in the variable Palette.
Easy enough to use.

Expects : FileName is standard MS-DOS filename which refers to the
          palette file.
          Palette is variable of type PaletteType used to hold
          the palette data.

Corrupts : Don't know.
}

Procedure LoadPalette(FileName: String; Var Palette : PaletteType);
Var PaletteFile: File;
Begin
     Assign(PaletteFile,FileName);
     Reset(PaletteFile,1);
     BlockRead(PaletteFile,Palette,SizeOf(Palette));
     Close(PaletteFile);
End;





{
Guess what this does then !.

Expects : FileName is the MS-DOS file spec of the palette to be saved.
          Palette is the palette to be saved.

Returns : Nothing

Corrupts : As it's not in assembler it's hard to say, but I guess
           Pascal preserves all registers on entry to a routine ..
           (Don't quote me on that !)
}

Procedure SavePalette(FileName: String; Palette : PaletteType);
Var PaletteFile: File;
Begin
     Assign(PaletteFile,FileName);
     Rewrite(PaletteFile,1);
     BlockWrite(PaletteFile,Palette,SizeOf(Palette));
     Close(PaletteFile);
End;







{
This sets the DACs to the Colours specified in your
Palette array. Do NOT alter the Palette data structure
or else this won't work.

Expects : Palette is an initialised palette of PaletteType.

Returns : Nothing

Corrupts : AL, BX, CL, DX, SI, DI, ES
}


Procedure SetAllPalette(Palette : PaletteType); Assembler;
Asm
   PUSH DS
   LDS BX, Palette      { DS:BX points to Palette record }
   XOR AL,AL
   MOV DX,$3c8          { $3c8 selects the first colour to alter.
                          After 3 writes to $3c9, the VGA automatically
                          moves to the next Colour so there is no
                          need to write to $3c8 again. }
   OUT DX,AL
   INC DL               { Make DX = $3c9, which is used to set the
                          Red / Green and Blue values of a Colour }

   MOV CL,(MaxColours-1) { 256 colours }

   MOV SI,BX
   ADD SI,MaxColours     { Make SI point to green levels }
   MOV DI,BX
   ADD DI,MaxColours     { Make DI point to blue levels }
   ADD DI,MaxColours

{
Note: I read somewhere that some VGA adapters don't like
      being hit with continuous data too quickly..

      If not then you should use the BIOS load palette
      function (which will be 20 times slower than this
      hack trick)
}

@WritePaletteInfo:
   MOV AL, [BX]         { Read red level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   MOV AL, [SI]         { Read green level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   MOV AL, [DI]         { Read blue level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }

   INC DI               { Next Red part of record }
   INC BX               { Next Green }
   INC SI               { Next Blue }

   DEC CL
   CMP CL,$FF               { Dunno if a JNZ works when register is 0
                            or $ff. }
   JNZ @WritePaletteInfo
   POP DS
End;






{
Set the new graphics colour. Also affects text routines as well.

Expects : NewColour is the new graphics Colour.

Returns : Nothing.

Corrupts : AL.
}


Procedure SetColour(NewColour:byte); Assembler;
Asm
    MOV AL,NewColour
    MOV CurrentColour,AL
End;






{
Get the current graphics colour.
}

Function GetColour: byte; Assembler;
Asm
     MOV AL, CurrentColour;
End;
























{
****************
Sprite Functions
****************
}


{
Get the width of a shape

Expects : DataPtr^ points to a shape in memory

Returns : Width of shape (1-255)

Corrupts : ES, DI
}

Function ShapeWidth(Var DataPtr): byte; assembler;
Asm
   LES DI,DataPtr
   MOV AL,[ES:DI]
End;




{
Get the height (in pixels) of an Shape.

Expects : DataPtr^ points to a shape held in memory

Returns : Height of shape (1-255)

Corrupts : ES,DI
}

Function ShapeHeight(Var DataPtr): byte; assembler;
Asm
   LES DI,DataPtr
   MOV AL,[ES:DI+1]
End;







{
This Function returns the number of bytes required to store
a shape object of a given width and height.

Expects : ShapeWidth is the width of the Shape (1-255). You can
          obtain the width of a shape by using the ShapeWidth
          Function above.

          Shapeheight is the height of the Shape (1-255). You can
          obtain the height of a shape by using the ShapeHeight
          Function above.

Returns : ExtShapeSize = No of bytes shape uses.


Corrupts : AL,BL.

}


Function ExtShapeSize(ShapeWidth, ShapeHeight : byte): word; Assembler;
Asm
   MOV AL, ShapeWidth
   MOV BL, ShapeHeight
   MUL BL
   INC AX
   INC AX
End;




{
Calculate the number of bytes required to hold a shape in memory,
if grabbed from the screen.

Expects :     X1, Y1, X2, and Y2 define a rectangular region that
              lies on an imaginary screen (No reading of source/
              dest Bitmap is done!). X1 and X2 must be in the range of
              0-319; Y1 and Y2 must be in the range of 0-199.

              You are restricted to images up to 255 x 200 pixels
              in size. (Why 200? Well, you can't grab past the
              vertical limits of the VGA screen can you ?)

Returns :     Number of bytes used to hold image. If 0, then this
              means the image is too large to load into a 64K
              portion of RAM.

Corrupts :    BX,DX.
}

Function ShapeSize(x1,y1,x2,y2:word):word; Assembler;
Asm
     MOV AX,x2          { Width = (X2 - X1) + 1 }
     SUB AX,x1
     INC AX             { Add one extra width byte }
     AND AH,$7F
     OR AH,AH
     JNZ @TooBig

     MOV BX,y2          { Height = (Y2 - Y1) + 1 }
     SUB BX,y1
     INC BX
     AND BH,$7F         { And again }
     CMP BX,201
     JB @ShapeFine      { No, shape is OK in width and height }

@TooBig:
     XOR AX,AX          { Set AX to return 0, meaning error }
     JMP @Finished

@ShapeFine:
     MUL BL             { SpriteDataSize = Width * Height }
     ADD AX,2           { Take into account 2 bytes for Shape "header" }

@Finished:
End;











{
Display a shape at a given position on screen, over the current
background (Most games with sprites use this technique). And
if this isn't the fastest sprite routine in the SWAG then I'll
eat my C64.

Expects : X and Y specify a horizontal and vertical position for
          the TOP LEFT of an Shape. (Regardless whether or not the
          shape's edge is transparent)

          X and Y are presumed ALWAYS valid : i.e. Within bounds of
          screen; Also, it is presumed that the sprite is not placed
          in a position on screen that over runs the screen borders:
          unexpected effects would occur. Sorry! Use ClipBlit if you
          must place sprites in the screen border.

          DataPtr, the untyped variable, must point to data for a
          sprite which is up to 254 pixels wide and 200 pixels
          tall.

Returns : Nothing

Corrupts : AX,BX,CX,DX,SI,DI,ES, & Direction Flag

}

Procedure Blit(x,y:word; Var DataPtr); Assembler; { A - Ha ! }
Asm
   MOV AX,x
   MOV BX,y
   CALL CalculateOffset         { Calculate where to blit to }

   MOV ES,SourceBitmapSegment   { Point ES to source Bitmap }

   MOV CX,DS                    { Faster than stack }
   LDS SI,DataPtr               { resides in memory. }

   MOV DX,[SI]                  { Get Width into DL and height to DH }
   INC SI                       { Faster than ADD SI,2 - I think }
   INC SI
   CLD                          { Make sure writes are descending }

   MOV AH,DL                    { Save width in CL }

@Outer:
   MOV DL,AH                    { Reload DL }
   MOV DI,BX                    { DI = Where to write to }

{ You could use a LODSD, but to be honest it's more trouble than
  it's worth writing the tons of extra code just to save an extra
  clock cycle or two. That is, if it does..
}


@Main:
   LODSB                { Read byte from DS:SI }
   OR AL,AL             { Is it value 0, meaning transparent ? }
   JZ @NoBlit           { Yes, so ignore byte }
   MOV [ES:DI],AL       { Otherwise write it to the screen. Don't
                          use STOSB ! }

@NoBlit:
   INC DI
   DEC DL               { Reduce horizontal counter }
   JNZ @Main            { If not zero then do next byte of the
                          sprite column }

@NextScanLine:
   ADD BX,320           { Move down 1 scan line }
   DEC DH               { Reduce vertical count }
   JNZ @Outer           { If not all lines of sprite done back to @Outer }
   MOV DS,CX            { Restore Data Segment }
End;








{
This routine writes a shape to the source Bitmap with no Colour 0
transparency, totally overwriting everything "beneath" it.
Also, there is no clipping of Shape. (Use ClipBlock for this
purpose)

Expects  : X and Y specify the horizontal and vertical coordinate
           of the Shape pointed to by DataPtr.

Returns  : Nothing

Corrupts : AX,BX,CL,DX,SI,DI,ES

Notes    : Block is especially useful for "tile" based maps.
}

Procedure Block(x,y:word; Var DataPtr); Assembler;
Asm
   MOV AX,x
   MOV BX,y
   CALL CalculateOffset
   CMP BX,-1                    { Off screen ? }
   JZ @StupidUser

   PUSH DS                      { Save DS on stack }
   MOV ES,SourceBitmapSegment   { ES: BX -> Where sprite written to }

   CLD                          { Make sure writes are descending }
   LDS SI,DataPtr               { This has to be last access of memory
                                  variable as DS is now altered }
   MOV DX,[SI]                  { Get width into DL, height into DH }
   ADD SI,2                     { SI now points to sprite data }


@Outer:
   MOV DI,BX                    { DI = Offset into VGA screen }
   MOV CL,DL                    { CL = Width of sprite }

   CMP CL,4                     { Bytes left < 4 ? }
   JB @CantDoLongWordBlit       { Yeah, so can't do the 4 byte blit }

   SHR CL,2                     { Divide Bytes left by 4 }

@CopyLong:
   DB $66                       { Otherwise, store longword to [ES:DI] ! }
   MOVSW
   DEC CL                       { CL is long word count }
   JNZ @CopyLong                { If CL <> 0 go back to CopyLong }

   MOV CL,DL                    { Restore CL }
   AND CL,3
   OR CL,CL
   JZ @NoBytesLeft

@CantDoLongWordBlit:
   CMP CL,2                     { Byte count < 2 ? }
   JB @DoByteBlit               { Yes, can't do a word blit (Shit !)
                                  so that means that there's only
                                  1 byte left. }

@CopyWord:
   MOVSW                        { Otherwise, write word }

@DoByteBlit:
   TEST CL,1                    { Is there a byte left ? }
   JZ @NoBytesLeft              { No, so no more blits this line }

   MOVSB                        { Store the last byte }

@NoBytesLeft:
   ADD BX,320                   { Advance BX to next scan line }
   DEC DH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }
   POP DS                       { Otherwise, restore Data Segment }

@StupidUser:
End;







{
Perform clipping calculations on an object.

Expects : AX to be an X coordinate for a sprite
          BX to be a Y coordinate
          ES:DI to point to the sprite data

Returns : If no draw can be done, carry is set TRUE.
          Else carry is FALSE and :

          SI will point to first byte to blit
          DI will be the VGA screen offset for first blit
          (ES still is at sprite segment however so must
          be changed afterwards)
          CL is the number of bytes to blit ACROSS
          CH is the number of bytes to blit DOWN
          DX is the MODULO for the image (i.e. how many bytes SI should
          skip (after reload) to get to the start of next row of
          sprite data)

Notes :   Unless you are planning to write extra routines which may
          clip images up to 256 x 256 it is wise to leave this Procedure
          as private to the unit as it is quite complex.
}


Procedure ClipCalculations; Near; Assembler;
Asm
   CMP BX,199              { Y > 199 ? }
   JG @NoDraw              { JG is for SIGNED integers. If Y pos is
                             > 199 then no blit }

   CMP AX,319              { X > 319 ? }
   JG @NoDraw              { Yes, Do not do any blits at all }

   MOV SI,DI
   INC SI
   INC SI                  { Make SI point to actual sprite data }

   XOR CH,CH
   MOV CL,[ES:DI]          { CL holds Clipwidth }

   CMP AH,$80              { Quick test if X position is negative }
   JB @XNotNegative        { If not then check if image is off right hand
                             of screen }
   NEG AX                  { Make X position positive }

   CMP AX,CX               { If Abs(X) >= Image Width Then Don't Draw }
   JA @NoDraw

   SUB CX,AX               { Dec(ClipWidth, Abs(X)) }
   ADD SI,AX               { Inc(DataStart, Abs(X)) }
   XOR AX,AX               { Set X to 0 }
   JMP @NowDoY             { Do Y portion of data now. }


@XNotNegative:
   MOV DX,CX               { Set DX to clipwidth }
   ADD DX,AX               { If X + ClipWidth < 320 Then }
   CMP DX,320
   JB @NowDoY              { Do Y part (No need to clip width) }
   MOV CX,320
   SUB CX,AX               { ClipWidth = 320 - X }


{
At this point:

AX is the X position of the Shape
BX is the Y position of the Shape
CL is the clipped width of the Shape.

Now it is time to do the height part and set the result in
CH.
}

@NowDoY:
   XOR DH,DH               { Make DX the height of image }
   MOV DL,[ES:DI+1]
   MOV CH,DL               { Set CH also to height for main blit routine }

   CMP BH,$80              { Quick test if Y position is negative }
   JB @YNotNegative

   NEG BX                  { Make Y a positive number }

   CMP BX,DX               { If Y > ClipHeight }
   JA @NoDraw
   SUB DX,BX               { Dec(ClipHeight, Abs(Y) ) }
   MOV CH,DL               { As an image can only be 255 bytes high
                             this works fine.. }
   PUSH AX                 { Save X Coord on stack }
   XOR AH,AH
   MOV AL,[ES:DI]          { AX = Width }
   MUL BX                  { Calculate Y * Width }
   ADD SI,AX               { Inc(DataStart, Abs(Y) * Width ) }
   POP AX
   XOR BX,BX               { Set Y to 0 }
   JMP @NowDoBlit          { NOW do the blit work. Whew! }



@YNotNegative:
   ADD DX,BX               { If Y + ClipHeight > 199 Then }
   CMP DX,200
   JB @NowDoBlit
   MOV DX,200
   SUB DX,BX               { ClipHeight = 200 - Y }
   MOV CH,DL


{
At this point AX is the X position
              BX is the Y position
              CL is the ClipWidth and
              CH is the ClipHeight.

As the width/height of an Shape can only be an 8 bit
quantity (i.e. < 256) I can discard the H portions of
the registers. Whew!

Now follows some weird code.. I'm going to make :

DX = Modulo for datastart (which is the width in bytes of Shape.
And yes, I do know that Width could be held in DL but adding extra
code just to satisfy you optimisation junkies is v. boring.)

DS:SI already points to data
ES:DI points to active (source) Bitmap

}

@NowDoBlit:
   PUSH CX                     { Save ClipWidth & ClipHeight on stack }
   CALL CalculateOffset        { Use AX and BX to calculate screen
                                 offset. On exit BX is offset }
   POP CX                      { Restore ClipWidth and ClipHeight }

   XOR DH,DH
   MOV DL,[ES:DI]              { DX = Modulo }
   MOV DI,BX                   { Ahhh. Now DI points to the screen offset }
   CLC
   JMP @End

@NoDraw:
   STC                         { Indicate no blit possible }

@End:
End;









{
This routine does the same as Blit but takes into account
the fact that the sprite may be off the edges of the
screen.

Its quite a bit slower than the normal Blit, but that's only
to be expected as there's more computations to be
done.

Expects  : X, Y specify the horizontal and vertical position of the Shape,
          DataPtr points to the data to blit.

Returns  : Nothing

Corrupts : BX,CX,DX,SI,DI,ES.
}

Procedure ClipBlit(x,y:integer; Var DataPtr); Assembler;
Asm
   MOV AX,X
   MOV BX,Y
   LES DI,DataPtr
   CALL ClipCalculations
   JC @NoDraw

   PUSH DS
   PUSH BP

   MOV AX,SourceBitmapSegment
   MOV BX,ES
   MOV DS,BX                   { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                   { BX to be used to reload SI }
   MOV BP,DI                   { And the screen modulo }

   MOV AH,CL                   { AH = Width }
   CLD                         { Make sure LODSB works OK }

@Outer:
   MOV CL,AH                   { Re-load CL }
   MOV SI,BX                   { And SI with address of next sprite row }
   MOV DI,BP                   { And DI with address of next scan line }


@WriteByte:
   LODSB                       { Read byte from DS:SI }
   OR AL,AL                    { Is byte 0 (transparent) ? }
   JZ @NoBlit                  { yes, so don't blit }
   MOV [ES:DI],AL              { Otherwise store byte }

@NoBlit:
   INC DI                       { Move DI to next pos. on screen }
   DEC CL                       { Reduce shape width count }
   JNZ @WriteByte               { If not zero, end of shape not reached }

   ADD BX,DX                    { BX = BX + Modulo, so BX now points
                                  to first byte of next sprite line
                                  to blit }
   ADD BP,320                   { Make BP point to next line. Note :
                                  If you are going to add some extra
                                  stuff here make sure you're not
                                  accessing local variables! }


   DEC CH
   JNZ @Outer

   POP BP
   POP DS
@NoDraw:
End;





{
This routine does the same as Block except that it takes into account
that the shape object may be off screen.

Expects  : Same as Block.

Returns  : Nothing

Corrupts : AX,BX,CX,DX,SI,DI,ES are corrupt on exit.
}



Procedure ClipBlock(x,y:integer; Var DataPtr); Assembler;
Asm
   MOV AX,X
   MOV BX,Y
   LES DI,DataPtr          { ES:DI points to data }
   CALL ClipCalculations
   JC @NoDraw


{
Prepare for blit !
}

   PUSH DS
   PUSH BP

   MOV AX,SourceBitmapSegment
   MOV BX,ES
   MOV DS,BX                   { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                   { BX to be used to reload SI (+Image Width) }
   MOV BP,DI                   { And BP to reload DI (+Screen Width) }

   CLD                         { Make sure LODSB works OK }

@Outer:
   PUSH CX
   MOV CH,CL                   { CH is set to ClipWidth }

   MOV SI,BX
   MOV DI,BP

   CMP CH,4                     { Bytes left < 4 ? }
   JB @CantDoLongWordBlit       { Yeah, so can't do the 4 byte blit }

   SHR CH,2                     { Divide Bytes left by 4 }

@CopyLong:
   DB $66                       { Otherwise, store longword to [ES:DI] ! }
   MOVSW
   DEC CH                       { Reduce long word count }
   JNZ @CopyLong

   MOV CH,CL                    { Restore CL }
   AND CH,3
   OR CH,CH
   JZ @NoBytesLeft



@CantDoLongWordBlit:
   CMP CH,2                     { Byte count < 2 ? }
   JB @CheckDoByteBlit          { Yes, can't do a word blit (Shit !)
                                  so that means that there's only
                                  1 byte left. }
@CopyWord:
   MOVSW                        { Otherwise, write word }


@CheckDoByteBlit:
   TEST CH,1                    { Is there a byte left ? }
   JZ @NoBytesLeft              { No, so no more blits this line }

@DoByteBlit:
   MOVSB                        { Store the last byte }

@NoBytesLeft:
   ADD BX,DX                    { BP to next byte of image to read }
   ADD BP,320                   { Advance BX to next scan line }

   POP CX
   DEC CH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }

   POP BP                       { Restore base pointer and }
   POP DS                       { Data Segment }

@NoDraw:
End;







{
Grab a rectangular area of bytes from the screen for use
as a shape object.

Expects     : X1,Y1 define the TOP LEFT of the area to grab.
              X2,Y2 define the BOTTOM RIGHT of the area.

              X1 MUST be less than X2;
              Similarly, Y1 MUST be less than Y2.

              Also, it is NOT possible to grab an image that
              is more than 255 pixels wide and 200 pixels
              high.

Returns     : Nothing

Notes       : Use the ShapeSize Function to calculate
              bytes needed to hold shape object in memory .

Corrupts    : AX,BX,CX,DX,SI,DI,ES

}

Procedure GetAShape(x1,y1,x2,y2:word;Var DataPtr); Assembler;
Asm
   MOV AX,x1
   MOV BX,y1
   CALL CalculateOffset
   CMP BX,-1
   JZ @StupidUser

   MOV AX,x2                    { Width = (X2 - X1) +1 }
   SUB AX,x1
   INC AX                       { Take into account extra pixel }
   MOV DL,AL

   MOV AX,y2                    { Height = (Y2 - Y1) +1 }
   SUB AX,y1
   INC AX
   MOV DH,AL

   LES DI,DataPtr
   MOV [ES:DI],DX               { Store Width & Height }
   ADD DI,2

   PUSH DS
   MOV DS,SourceBitmapSegment
   CLD                          { Make sure writes are descending }


@Outer:
   MOV SI,BX                    { SI = Offset into VGA screen }
   MOV CL,DL                    { CL = Width of sprite held in DL }

   CMP CL,4                     { Bytes left < 4 ? }
   JB @CantDoLongWordBlit       { Yeah, so can't do the 4 byte blit }

   SHR CL,2                     { Divide Count by 4 }

@CopyLong:
   DB $66                       { Otherwise, store longword to [ES:EDI] ! }
   MOVSW
   DEC CL                       { CL is long word count }
   JNZ @CopyLong                { If CL <> 0 go back to CopyLong }

   MOV CL,DL                    { Restore CL to width of Shape }

@CantDoLongWordBlit:
   AND CL,3
   OR CL,CL                     { Any bytes left ? }
   JZ @NoBytesLeft

   CMP CL,2                     { Byte count < 2 ? }
   JB @DoByteBlit               { Yes, can't do a word blit (Shit !)
                                  so that means that there's only
                                  1 byte left. }

@CopyWord:
   MOVSW                        { Otherwise, write word }
   TEST CL,1
   JZ @NoBytesLeft              { No, so no more blits this line }


@DoByteBlit:
   MOVSB                        { Store the last byte }

@NoBytesLeft:
   ADD BX,320                   { Advance BX to next scan line }
   DEC DH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }

   POP DS                       { Otherwise, restore Data Segment }

@StupidUser:
End;









{
This routine checks if the data contained within a Shape will
"Collide" with the background. (Background data is held within
the Source Bitmap)

This command is very useful for games that need accurate
Shape to background collision detection.

Expects : X and Y specify the horizontal and vertical position
          of a shape pointed to by DataPtr.

Returns : If the Shape has collided with ANY background (represented
          by colours 1-255) on the SOURCE Bitmap then BlitColl is TRUE.

Corrupts : AX,BX,CX,DX,SI,DI,ES
}

Function BlitColl(x,y :integer; Var dataptr) : boolean; Assembler;
Asm
   MOV AX,x
   MOV BX,y
   CALL CalculateOffset         { On exit, BX will hold screen "Offset" }

   MOV ES,SourceBitmapSegment

   PUSH DS
   PUSH BP
   LDS SI,DataPtr


   MOV DX,[SI]             { DL= Width, DH = Height }
   INC SI
   INC SI                  { Make SI point to sprite data }

   CLD                     { Make sure writes are descending }

   MOV CL,DL

@Outer:
   MOV DI,BX               { DI = Offset into Source Bitmap }
   MOV DL,CL

{ Check if any long words can be checked }

   CMP DL,4                { Is width at least 4 bytes ? }
   JB @CantCheckLong       { No }
   SHR DL,2                { Otherwise, divide width by 4 so that
                             DL will hold number of LONGs to check }


@CheckLong:
   DB $66; LODSW           { LODSD : Load EAX from DS:SI }
   DB $66; OR AX,AX        { OR EAX,EAX }
   JZ @NoCheckBackLong     { If EAX is zero then no point in checking
                             background is there ? }

   DB $66
   MOV BP,AX               { Make a copy of EAX }
   DB $66
   XOR AX,[ES:DI]          { XOR EAX, [ES:DI]  (Xor EAX with Background) }
   DB $66
   CMP BP,AX               { Is EAX unaffected by the XOR - i.e.
                             No collision }
   JNZ @CollisionOccurred


@NoCheckBackLong:
   ADD DI,4                { Bump DI to next long word }
   DEC DL                  { Reduce long word count }
   JNZ @CheckLong          { And now do the collision check for long word }



   MOV DL,CL               { Restore DL to it's previous contents }
   AND DL,3                { Mask out all but bits 0 & 1 }


{ Any words left to be checked ? }

@CantCheckLong:
   CMP DL,2                { Is there at least 2 bytes left to move ? }
   JB @CantCheckWord       { No }

@CheckWord:
   LODSW                   { Read word from DS:SI into AX }
   OR AX,AX                { Is Shape data non zero ? }
   JZ @CantCheckWord       { Yes, so can't be a collision }

   MOV BP,AX
   XOR AX,[ES:DI]          { Otherwise, check background too }
   CMP BP,AX               { Is AX different ? }
   JNZ @CollisionOccurred  { Yes, so this means a collision }
   ADD DI,2                { Otherwise add 1 byte }

@CantCheckWord:
   TEST CL,1               { Is there a single byte left to check }
   JZ @AllChecksDone       { Nope }
   LODSB                   { Otherwise, read it }
   OR AL,AL                { Zero ? }
   JZ @AllChecksDone       { Yes, so basically no more checks to do }

   MOV CH,AL
   XOR AL,[ES:DI]          { No, so check background byte }
   CMP CH,AL               { Is AL different ? }
   JNZ @CollisionOccurred  { Yes, so a collision has occurred }


@AllChecksDone:
   ADD BX,320              { 320 is the number of bytes in one scan-line }
   DEC DH                  { Reduce vertical count (Counts from height of Shape) }
   JNZ @Outer              { If <>0 then check for next line of Shape }
   MOV AL,False            { If all lines have been done then this means
                             that no collision has occurred }

   JMP @Exit               { And exit. Don't insert a RET here -
                             you'll crash the program ! }

@CollisionOccurred:
   MOV AL,True             { This part is only reached if a collision has
                             occurred. }

@Exit:
   POP BP                 { Restore Base Pointer }
   POP DS                 { Restore data segment }
End;






{
De-allocate memory for an Shape.

Expects  : DataPtr is an Shape pointer.

Returns  : A crash if you're not careful !! :-(

Corrupts : The assembler part uses AX,DI and ES. Don't know about
           the Pascal part however.
}

Procedure FreeShape(DataPtr:pointer);
Var ImWidth,
    ImHeight: byte;
Begin
     Asm
     LES DI,DataPtr
     MOV AX,[ES:DI]
     MOV ImWidth,AL
     MOV ImHeight,AH
     End;
     FreeMem(DataPtr,ExtShapeSize(ImWidth,ImHeight));
End;






{
Load in a .IMG file from disk.

WARNING! This is NOT the IMG file type used by some paint packages!
It is a non-standard file (albeit very simple) format that NEWGRAPH
writes, so trying to load a shape created from a paint package
etc. will not work.


Expects  :  FileName to be a valid MS-DOS path.
            DataPtr to be a valid pointer to where data will be stored.

Returns  :  Nothing, although sprite may have loaded into memory.

Corrupts :  Don't know.

}

Procedure LoadShape(FileName:String; Var DataPtr: Pointer);
Var F: File;
    DestSeg,
    DestOffset,
    ImgSize: word;
    ShapeWidth,
    ShapeHeight: byte;

Begin
     Assign(F,FileName);
     Reset(F,1);
     BlockRead(F,ShapeWidth,1);       { Read in width & height }
     BlockRead(F,ShapeHeight,1);


     {
     Calculate number of bytes that need to be reserved for the
     Shape.
     }

     ImgSize:= ExtShapeSize(ShapeWidth,ShapeHeight);
     If ImgSize < MaxAvail Then
        Begin

        GetMem(DataPtr,ImgSize);
        GetPtrData(DataPtr,DestSeg,DestOffset);

        Reset(F,1);
        BlockRead(F,Mem[DestSeg:DestOffset], ImgSize);
        Close(F);
        End
     Else
         Asm
         DB $66
         MOV WORD [OFFSET DataPtr],0         { Signal no memory claimed }
         DW 0
     End;

End;








{
Write an Shape to disk, where you could convert it if you like
to a PCX. With the reg. version, there is a command to do this.

Expects :  FileName is a standard DOS filename.
           P is a pointer to where the sprite data exists in memory.

Returns :  Nothing.

Corrupts : Don't know.
}

Procedure SaveShape(FileName:string; DataPtr:Pointer);
Var F: File;
    SourceSeg, SourceOffset: word;
Begin
     Assign(F,FileName);
     Rewrite(F,1);
     GetPtrData(DataPtr,SourceSeg,SourceOffset);

     BlockWrite(F, Mem[SourceSeg:SourceOffset],
                   ExtShapeSize(mem[SourceSeg:SourceOffset],
                   mem[SourceSeg:SourceOffset+1]));
     Close(F);
End;









{
***************************************
PCX LOAD AND SAVE ROUTINES - WHICH WORK
***************************************
}



{
This will put a mode 13h 256 colour PCX at position X,Y and
show a defined area. Useful for low res multimedia applications. :-)
This PCX loader can handle PCX's of variable dimensions up to
width 320 and height 200 so you could design sprites
with a graphics package and save them as a PCX then grab them
off the screen as Shapes. Also, this PCX loader is far faster than
Norman Yen's effort and intelligently uses memory. (Note: How can
a program dumbly use memory? Hmm?)

Expects: Filename is an MS-DOS filespec relating to the PCX's name,
         i.e. 'C:\WORK\SHEEP.PCX' (Oh well explained Scott :^( )
         ThePalette is a PaletteType record used to hold the PCX's
         palette data.
         X,Y specifies the top left coordinates on screen of where
         the PCX is to be drawn. X should be in the range of 0 to
         319, Y should be in the range of 0 to 199. The picture
         will be clipped as necessary.

Returns: Your program will halt with an error message if the PCX file
         does not exist, or if the PCX is not of the correct "type".
         (I.E. It's not mode 13h or it's not 256 colour etc.).
}

Procedure LocatePCX(filename:string; Var ThePalette: PaletteType;
          x,y,widthtoshow,heighttoshow:word);

var PCXFile: file;

    ReadingFromMem  : Boolean;      { If True it means All/Some PCX
                                      Data is in RAM }
    MemRequired     : longint;      { Size of PCX bitmap data }
    BytesRead       : longint;      { Number of PCX bytes read }
    PCXFileSize     : longint;      { How many bytes PCX uses }
    Count           : integer;      { I is a general counter used to set
                                      the PCX's palette and then count
                                      scan lines }
    RedVal          : byte;         { Used for ColourMap, Palette values }
    GreenVal        : byte;         { which define a colour }
    BlueVal         : byte;

    MemoryAccessVar : pointer;      { Pointer to read bitmap data }
    BufferSeg,                      { Where PCX will be loaded to }
    BufferOffset    : word;

    VidOffset       : word;         { Screen offset }

    Width,Height,                   { Width is number of horizontal bytes to grab
                                      Height is number of vertical bytes to grab }
    N,Bytes             : word;     { N counts up to Bytes }
    RunLength,c     : byte;         { RunLength is the Run Length Encoding
                                      byte, C is the character read from
                                      PCX data }
    PastHorizontalLimit : boolean;  { Set true this means no more
                                     horizontal pixel writes to do, advance 
                                     to next line as soon as poss.}

begin
    assign(PCXFile,FileName);

{$i-}
    reset (PCXFile,1);
{$i+}
    If IOResult = 0 Then
       Begin

       blockread (PCXFile, header, sizeof (header));       { Read in PCX header }

       if (header.manufacturer=10) and (header.version=5) and
          (header.bits_per_pixel=8) and (header.colour_planes=1) then
          begin
               seek (PCXFile, filesize (PCXFile)-769);     { Move to palette data }
               blockread (PCXFile, c, 1);                  { Read Colourmap type }
               if (c=12) then                              { 12 is correct type }
               begin
                    {
                    Read palette data and write to palette
                    structure.
                    }

                    for Count:=0 to 255 do
                        Begin
                          BlockRead(PCXFile,RedVal,1);
                          BlockRead(PCXFile,GreenVal,1);
                          BlockRead(PCXFile,BlueVal,1);

                          ThePalette.RedLevel[Count]:=RedVal SHR 2;
                          ThePalette.GreenLevel[Count]:=GreenVal SHR 2;
                          ThePalette.BlueLevel[Count]:=BlueVal SHR 2;
                      End;


                  seek (PCXFile, 128);

                  {
                  If entire size of PCX is less than 64K in length then
                  it can be stored in a memory buffer and uncompacted
                  from there. However, if PCX exceeds 64K then it must
                  be split into several chunks. If your machine does
                  not have 64K left for the buffer used (You're in trouble !!)
                  then the system will read the PCX from disk continually,
                  which works OK but is very slow. So there.
                  }

                  MemRequired:=Filesize(PCXFile)-897;
                  PCXFileSize:=MemRequired;
                  BytesRead:=0;

                  If (MemRequired < 65528) And (MaxAvail > MemRequired) Then
                     Begin
                     getmem(MemoryAccessVar,MemRequired);
                     GetPtrData(MemoryAccessVar, BufferSeg, BufferOffset);
                     BlockRead(PCXFile,Mem[BufferSeg:BufferOffset],MemRequired);
                     ReadingFromMem:=True;
                     End
                  Else

                  {
                  If the PCX occupies more than approx. 64K bytes then it
                  is necessary to read the data into memory in 64K chunks
                  which is still considerably faster than the
                  final method (continual reading from disk)
                  }

                      If (MaxAvail > 65527) Then
                         Begin
                         GetMem(MemoryAccessVar,65528);
                         GetPtrData(MemoryAccessVar, BufferSeg, BufferOffset);
                         BlockRead(PCXFile,Mem[BufferSeg:BufferOffset],65528);
                         BytesRead:=65528;
                         MemRequired:=65528;
                         ReadingFromMem:=True;
                         End
                      Else
                          { CLUCK!! Oh well, system is just going to have
                          to read from disk as there is not even 64K
                          memory left. (A very bad situation) }

                          ReadingFromMem:=False;

                  {
                  Find out width & height of PCX.
                  }

                  width:=(header.xmax - header.xmin)+1;
                  height:=(header.ymax - header.ymin)+1;
                  bytes:=header.bytes_per_line;

                  {
                  Adjust width & height of PCX if necessary so that PCX
                  "fits" on screen.

                  }

                  if widthtoshow > width Then
                     widthtoshow:=width;

                  if (widthtoshow + x) > 320 Then
                     widthtoshow:=width-x;

                  if heighttoshow > height Then
                     heighttoshow:=height;

                  if (heighttoshow + y)> 200 Then
                     heighttoshow:=height-y;


                  {
                  Do all scan lines.
                  }

                  for Count:=0 to (heighttoshow-1) do
                  begin
                      n:=0;
                      PastHorizontalLimit:=False;
                      vidoffset:= SourceBitmapOffset+((Y+Count)* 320)+X;

                      while (n<bytes) do
                      begin

                           { Display any more pixels width wise from PCX ? }

                           If N >= WidthToShow Then
                              PastHorizontalLimit:=True;

                           If ReadingFromMem Then
                               Begin
                               c:=Mem[BufferSeg:BufferOffset];
                               Inc(BufferOffset);
                               If BufferOffset = 65528 Then
                                  Begin
                                  { End of buffer has been reached, so
                                    it's time to load another part of the
                                    PCX }

                                  If (PCXFileSize - BytesRead)> 65527 Then
                                     Begin
                                     BlockRead(PCXFile,Mem[BufferSeg:0],65528);
                                     Inc(BytesRead,65528);
                                     End
                                  Else
                                      { Load last chunk of PCX }

                                      Begin
                                      BlockRead(PCXFile,Mem[BufferSeg:0],
                                      (PCXFileSize - BytesRead));
                                      End;

                                  {
                                  Now reset buffer pointer to start
                                  }

                                  BufferOffset:=0;
                                  End;
                               End
                            Else
                                BlockRead(PCXFile,c,1);

{
At this point one element of data has been read, and stored in
variable C. If bits 6 & 7 of C are set then this means to the system
a "run of bytes" has been found. (i.e. a number sequence - for example,
four 1's, twenty 15's, any sequence of identical numbers).

In this case, the 6 least significant bits of C indicate how long the run
of bytes is. For example, if a sequence of five bytes has been found
the run = 5. Of course, using 6 bits limits you to a maximum run length
of 63 bytes but that should be more than enough for most pictures.

Quite a simple method of compaction eh? Definitely the easiest format to
understand!

}

                            if ((c and 192)=192) then
                            begin

                               { Get the 6 least significant bits }
                               RunLength:=c and 63;

                               { get the run byte }

                               If ReadingFromMem Then
                                  Begin
                                  c:=Mem[BufferSeg:BufferOffset];
                                  Inc(BufferOffset);

                               { Time to read in more data from disk ? }

                                  If BufferOffset = 65528 Then
                                     Begin
                                     If (PCXFileSize - BytesRead)> 65527 Then
                                        Begin
                                        BlockRead(PCXFile,Mem[BufferSeg:0],65528);
                                        Inc(BytesRead,65528);
                                        End
                                     Else
                                         Begin
                                         BlockRead(PCXFile,Mem[BufferSeg:0],
                                         (PCXFileSize - BytesRead));
                                     End;

                                     BufferOffset:=0;
                                     End;
                                  End
                               Else
                                   BlockRead(PCXFile,c,1);

                               {
                               Can't do blit if past the horizontal limit
                               of the window.
                               }

                               If Not PastHorizontalLimit Then
                                  Begin
                                  If n+RunLength > widthtoshow Then
                                     fillchar(Mem[SourceBitmapSegment:VidOffset],WidthToShow-n,c)
                                  else
                                      fillchar(Mem[SourceBitmapSegment:VidOffset],RunLength,c);

                                  inc(vidoffset,RunLength);
                               End;

                               inc(n,RunLength);
                               end
                            else
                                begin
                                If Not PastHorizontalLimit Then
                                   Begin
                                   mem [SourceBitmapSegment:vidoffset]:=c;
                                   inc (vidoffset);
                                End;
                                inc (n);
                            end;

                      end;

                  end;

                  If ReadingFromMem Then
                     freemem(MemoryAccessVar,MemRequired);
               end
          else
              Begin
              DirectVideo:=False;
              Writeln('The PCX''s ColourMap is not of the correct type !');
              Close(PCXFile);
              Halt(0);
              End;
          end
       Else
           Begin
           DirectVideo:=False;
           Writeln('PCX unsuitable for loading.');
           Close(PCXFile);
           Halt(0);
       End;

       close (PCXFile);  { Do this anyway ! }

       end
    Else
        Begin
        DirectVideo:=False;
        Writeln('File not found ?');
        Close(PCXFile);
        Halt(0);
        End;

end;













{
What this does is load a PCX at the TOP LEFT of the source Bitmap,
very quickly. If you need to put the PCX somewhere else use LocatePCX.


Expects:  FileName to be a standard MS-DOS filename, relating to a
          320 x 200 PCX.
          ThePalette to be of type Palette. This holds the colour
          information of the PCX file you are loading.

You can then use SetAllPalette to set the VGA palette so that
the pic can display properly.
}

Procedure LoadPCX(FileName:string; Var ThePalette: PaletteType);
Begin
     LocatePCX(Filename,ThePalette,0,0,320,200);
End;






{
Home grown PCX packer.

This PCX routine is able to cope with the full 256 colours,
unlike some other SWAG PCX packers I could mention.. !

Expects:    FileName is the name of the PCX to save.
            ThePalette is a PaletteType variable, which has been
            initialised by, for example, the GetAllPalette routine.
            X,Y specify the horizontal and vertical positions of where to
            begin grabbing the PCX data from.
            PCXWidth and PCXHeight specify the width & height of the
            window to grab. Easy eh?

            For example, to grab one half of the VGA screen you could use:
            SaveAreaAsPCX('1STHALF.PCX',MyPalette,0,0,160,200);

            And the other half with :

            SaveAreaAsPCX('2NDHALF.PCX',MyPalette,160,0,160,200);

            These files can then be loaded into a paint package such
            as PC Paintbrush or Neopaint (great program!) and manipulated.

            Use the SAVEPCX routine below to save an entire PCX screen.


Returns:    Program will halt if the PCX is not found.


P.S. This routine manages to save a 256 colour screen properly,
     unlike some other PCX writing routines I could mention. Do you
     programmers actually TEST your code before sending it into the
     SWAG ? (Like, are there any GIF loaders that work ?!!)
}


Procedure SaveAreaAsPCX(filename:string;ThePalette: PaletteType;
          x,y, PCXWidth,PCXHeight: word);

Var f: File;                    { File for writing PCX to }
    ColourMapID: byte;           { Always holds 12, for the PCX }
    ColourCount: byte;           { Counts up to number of colours on
                                  screen (255) }
    RedValue: byte;             { Palette Values of a colour }
    GreenValue: byte;
    BlueValue: byte;

    LastOffset: word;           { Used as a latch for VidOffset }
    VidOffset: word;            { Offset into Source Bitmap }
    VerticalCount: byte;        { Number of scan lines to use }
    LastByte : byte;            { The last byte read from Source Bitmap }
    NewByte: byte;              { The current byte }
    RunLength : byte;           { Counter for run length compression }
    ByteCount: word;            { Counts up to bytes per scan line (320) }



Begin
     Assign(f,filename);
     Rewrite(f,1);

     With header do
     Begin
          Manufacturer := 10;
          Version := 5;
          Encoding :=0;
          Bits_per_pixel:=8;    { 8 bits = 256 colours }
          XMin:=0;
          YMin:=0;

          {
          Can't save a PCX more than 320 x 200 in size.
          }

          if (PCXwidth + x) > 320 Then
             PCXwidth:=320-x;
          if (PCXheight+ y) > 200 Then
             PCXheight:=200-y;

          XMax:=(PCXWidth-1);
          YMax:=(PCXHeight-1);
          Hres:=320;                        { Hres/Vres could be used to
                                              determine screen mode -
                                              probably :-( }
          VRes:=200;

          Colour_planes:=1;                 { Mode 13h is not planar }
          Bytes_per_line:=PCXWidth;         { One byte per pixel }
          Palette_type:=12;                 { Dunno what 12 is for }
     End;

     BlockWrite(F,Header,SizeOf(Header));

     Asm
     MOV AX,X
     MOV BX,Y
     CALL CalculateOffset
     MOV VidOffset,BX
     End;

     For VerticalCount:=0 to PCXHeight-1 do
     Begin
          LastOffset:=VidOffset;
          ByteCount:=0;
          LastByte:=0;

          Repeat
                NewByte:=Mem[SourceBitmapSegment:Vidoffset];

                {
                If the last byte read is equal to the new byte read
                then a run of bytes has been identified and so the
                system needs to count how many identical bytes (up
                to a total of 63) follow. When finished, the
                system writes this count to disk PLUS a value of
                192 (which is the signal to the PCX reader that
                a run of bytes follows) then writes the byte that
                was prevalent in the run.

                For example, say in the data stream there were 10
                values :

                0 1 2 6 9 8 7 7 7 4

                When the system gets to 8 it would then compare
                that number with the next value (7) and see that 8 is
                not equal to 7, then the computer would move to said 7
                (after the 8) and compare it to the next digit, which
                is also a 7.

                As a match has been found, the system counts the
                number of 7s there, which is (all together now !)
                3!! and then adds 192 to the result.. to give 195.

                As stated before, bits 6 + 7 of the byte have
                been set in order to "flag" to the PCX reader that
                a run of bytes have been found.

                The value 195 is written to disk, then value 7 so the
                PCX reader that loads this file knows what value (and
                how many times) to write to the screen during unpacking.

                I hope this has explained one of the PCX mysteries. If
                it hasn't I typed all that for nothing!! :-)
                }

                If NewByte = LastByte Then
                   Begin

                   RunLength:=0;
                   While (NewByte = LastByte) and (RunLength < 63)
                      and (ByteCount <> PCXWidth) do
                      Begin
                      Inc(RunLength);
                      Inc(ByteCount);

                      {
                      Move to next byte on Source Bitmap
                      }

                      Inc(vidoffset);

                      NewByte:=Mem[SourceBitmapSegment:Vidoffset];
                   End;


                   Asm
                   OR Byte Ptr RunLength, 192
                   End;

                   BlockWrite(f,RunLength,1);
                   BlockWrite(f,LastByte,1);

                   LastByte:=NewByte;
                   End
                Else

                { How to deal with colours > 191. }
                    If (NewByte > 191) Then
                       Begin
                       Inc(ByteCount);
                       Inc(VidOffset);                { Point to next byte on screen }
                       RunLength:=193;
                       BlockWrite(f,RunLength,1);     { Write run length byte of 1  ! }
                       BlockWrite(f,NewByte,1);       { The ONLY way to get round }
                       LastByte:=NewByte;
                       End
                    Else
                        Begin
                        Inc(ByteCount);
                        Inc(vidoffset);
                        BlockWrite(f,NewByte,1);
                        LastByte:=NewByte;
                        End;

          Until ByteCount = PCXWidth;

          VidOffset:=LastOffset+320;
     End;

     {
     12 is Colourmap ID.
     }

     ColourMapID:=12;
     BlockWrite(f,ColourMapID,1);

     {
     Now write Palette R,G,B values to disk. The only reason
     I didn't implement :

     BlockWrite(F,Palette,SizeOf(Palette))

     was that all the palette entries had to be shifted LEFT
     twice (To represent a 16.7 million colour palette..) 
     
                                DAMN!
     }

     For ColourCount:=0 to 255 do
         Begin

         RedValue:=ThePalette.   RedLevel[ColourCount] SHL 2;
         GreenValue:=ThePalette. GreenLevel[ColourCount] SHL 2;
         BlueValue:=ThePalette.  BlueLevel[ColourCount] SHL 2;

         BlockWrite(F,RedValue,1);
         BlockWrite(F,GreenValue,1);
         BlockWrite(F,BlueValue,1);
     End;

     Close(F);         { That's it - it's not over, not over yet .. :-) }
End;






{
Save a PCX file to disk.

Expects  :  Filename is the MS-DOS filespec , i.e. "C:\PICS\MYFILE.PCX"
           ThePalette specifies a PaletteType record to save to disk in
           the PCX file.

Returns  :  Nothing

Corrupts :  Don't know !!
}


Procedure SavePCX(filename:string;ThePalette: PaletteType);
Begin
     SaveAreaAsPCX(filename,ThePalette,0,0,320,200);
End;





{
**********************
MISCELLANEOUS ROUTINES
**********************
}

{
Wait for a certain number of vertical retraces, specified by
the number in TimeOut. (A vertical retrace occurs when the
monitor begins to draw the screen; If you wait for this
retrace and then update the screen your graphics will not
flicker - well not as much as before ;-) )


Corrupts AL,CX,DX
}


Procedure Vwait(TimeOut:word); Assembler;
Asm
         MOV CX,TimeOut         { CX = Number of times to wait }

         MOV DX,$3DA            { Port $3DA holds vertical & horizontal
                                  retrace status bits }
@WaitEnd:
         IN AL,DX               { Read port }
         TEST AL,8              { Test for bit 3 being set: If
                                  it is then that means the system may
                                  be in the middle of it's refresh
                                  and so writing to the screen now may
                                  cause flicker. }
         JNZ @WaitEnd           { If set, go back to @waitend }

{
When the routine gets to here it's the end of the retrace.
}

@WaitStart:
         IN AL,DX               { Read port again }
         TEST AL,8              { Is the bit set ? }
         JZ @WaitStart          { No ! So go back }

         DEC CX
         JNZ @WaitEnd          { Reduce count in CX, if <>0 go back
                                  to WaitEnd ! }

End;






{
Clear the Source Bitmap with Colour 0 (Always).

Expects : SourceBitmapSegment, SourceBitmapOffset to point to the source
          Bitmap (of course).

Returns : Nothing.

Corrupts : AX,CX,DI,ES


}

Procedure Cls; Assembler;
Asm
     MOV ES,SourceBitmapSegment
     MOV DI,SourceBitmapOffset

     MOV CX,4000         { 4000 x 16 byte moves are executed }
     DB $66
     XOR AX,AX           { XOR EAX,EAX - Colour 0 used to clear screen }

@ClearLoop:
     DB $66; STOSW       { STOSD }
     DB $66; STOSW
     DB $66; STOSW
     DB $66; STOSW
     DEC CX
     JNZ @ClearLoop

End;





{
Clear the screen with the graphics colour specified.

Expects : CurrentColour set to non-zero value
          Source Bitmap initialised with Bitmap

Returns : Nothing

Corrupts : AX,BX,CX,DI,ES
}

Procedure CCls(TheColour : byte); Assembler;
Asm
   MOV ES,SourceBitmapSegment
   MOV DI,SourceBitmapOffset

   MOV CX,4000
   MOV AH,TheColour
   MOV AL,AH
   MOV BX,AX

   DB $66; SHL AX,16            { SHL EAX,16 -> Move AH & AL into
                                  upper word of EAX}
   MOV AX,BX                    { Now EAX is fully set }

@FillLoop:
   DB $66; STOSW                { STOSD }
   DB $66; STOSW
   DB $66; STOSW
   DB $66; STOSW
   DEC CX
   JNZ @FillLoop                { You could use LOOP but I heard this
                                  method is faster }
End;





{
This is the initialisation part of the unit.
}

Begin
     SetSourceBitmapAddr($a000,0);
     DoubleBufferOff;
     Cls;                            { Flush video mem }
     MoveTo(0,0);                    { Graphics Cursor to top left }
     SetColour(1);                   { Use Colour 1 }
     UseFont(Font8x8);               { standard 8 x 8 }

     Writeln('NewGraph unit (C) 1995, 1996 Scott Tunstall. All rights');
     Writeln('reserved. Unauthorised editing/duplication of this code');
     Writeln('is PROHIBITED.');
     Writeln;

End.  { of unit }