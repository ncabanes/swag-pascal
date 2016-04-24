(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0213.PAS
  Description: Grab 256 Color PCX and save to file
  Author: SCOTT TUNSTALL
  Date: 05-31-96  09:17
*)

{
========================================

GRABIMG.PAS (C) 1994-1996 SCOTT TUNSTALL
DISTRIBUTE FREELY

----------------------------------------

This program allows you to load in a 256 colour PCX and save
areas of it as a .IMG file.

Use the cursor keys to move the cross hairs. Press space when you
are at the top left of the area you wish to cut, then when the
second pair of cross hairs appear, move them to the bottom right
of the image to cut. You will see the size of the image in
horizontal width & vertical height at the bottom left of the
screen. When you have a sprite of the desired size defined
within the crosshairs, press space again.

If the Shape (it must be less than width/height 255 * 255) can be
grabbed then you will be asked for a filename for the Shape to
be saved.

Standard MS - DOS filenames are required.





===============

For the coders:

---------------

Shape grabbed is from the non planar, unchained VGA mode $13.




=====================

File format of image:

---------------------

Byte 0 : Width
Byte 1 : Height
Byte 2.. Actual Shape data itself, uncompressed. The data is
         saved row by row, line by line.

To read it use the LoadShape command present in NEWGRAPH

ex:
        var p: pointer;
        LoadShape('SPRITE.IMG',p);
        ...

To display it use the Blit/Block/ClipBlit/ClipBlock commands.

}

Uses NEWGRAPH, NWKBDINT, CRT, DOS;

     { NOTE : NWKBDINT - in KEYBOARD.SWG
              NEWGRAPH - in GRAPHICS.SWG }


Var BarColour : byte;
    FirstBarX,
    FirstBarY,
    SecondBarX,
    SecondBarY: word;
    Grabbing: boolean;
    BufferSeg,
    BufferOffset:word;
    ThePalette: PaletteType;





{
Find the brightest colour available, and, yes I did program
this, it's not from SWAG or anything like that. Shall I explain
it to you ?

Each Colour has it's own Red, Green and Blue value attached to it.
Each Colour can have Red, Green and Blue component values of 64
thus giving 262,144 colours (64 * 64 * 64)

To find the brightest colour you just read the palette entries,
add up the Red, Green and Blue values and check if they are the
brightest so far. If they are, take a note of what Colour has
those values and do until all Colours are scanned. Easy eh? :-)
}




Function GetBrightestColour: byte;
Var Total: byte;
    Count: byte;
    RedTotal,
    GreenTotal,
    BlueTotal, ColourWithBestHue : byte;

    BestHueFound,
    HueValue: longint;

Begin
     Count:=0;

     BestHueFound:=0;
     ColourWithBestHue:=0;

     HueValue:=0;

     Repeat
           GetPalette(Count,RedTotal,GreenTotal,BlueTotal);
           HueValue:=BlueTotal+(GreenTotal*16)+(RedTotal * 256);
           If HueValue > BestHueFound Then
              Begin
              BestHueFound:=HueValue;
              ColourWithBestHue:=Count;
           End;
           Inc(Count);
     Until Count=0;

     GetBrightestColour:=ColourWithBestHue;
End;









Procedure Sort(Var N1, N2: word);
Var Temp: word;
Begin
     If N1 > N2  Then
        Begin
        Temp:=N1;
        N1:=N2;
        N2:=Temp;
     End;
End;







Procedure GetTheShape;
Var ShapeName: PathStr;
    Palette: PaletteType;
    OldBarX,
    OldBarY: word;
    TheShapePointer: pointer;
    MemRequired: word;
    Key: char;

Begin
     OldBarX:=FirstBarX;
     OldBarY:=FirstBarY;

     {
     O.K. As the graphics unit I've written only takes X and Y
     coordinates that are ordered (i.e. define a rectangular
     area) I've got to make sure than X1 is less than X2 and
     Y1 is less than Y2.
     }


     Sort(FirstBarX,SecondBarX);
     Sort(FirstBarY,SecondBarY);


     If (FirstBarX < SecondBarX) And (FirstBarY < SecondBarY) Then
        Begin

        GetAllPalette(Palette);

        MemRequired:= ExtShapeSize((SecondBarX-FirstBarX),
                      (SecondBarY-FirstBarY));

        GetMem(TheShapePointer,MemRequired);
        GetAShape(FirstBarX,FirstBarY,SecondBarX,SecondBarY,TheShapePointer^);

        SetSourceBitmapAddr($a000,0);
        Cls;

        Block(0,0,TheShapePointer^);

        BarColour:=GetBrightestColour;
        SetColour(BarColour);
        OutTextXY(0,192,'SAVE THIS IMAGE (Y/N) :');

        Repeat
              key:=upcase(readkey);
        Until (key= 'Y') or (key = 'N');

        If key = 'Y' Then
           Begin
           Asm
           MOV AX,2
           INT $10
           End;

           Write('Save Shape as :');
           Readln(ShapeName);

           {$i-}
           SaveShape(ShapeName,TheShapePointer);
           {$i+}
        End;

        FreeShape(TheShapePointer);

        InitVGAMode;
        SetAllPalette(ThePalette);
        ShowBitmap(BufferSeg,BufferOffset);

        FirstBarX:=OldBarX;
        FirstBarY:=OldBarY;

     End;
End;








{
I'm not too keen on this proc.. reckon I will change it later
when my Bsc is over.
}




Procedure UpdateBars(Var HorizontalBar, VerticalBar: word);
Begin
     If Keydown[72] And (VerticalBar >0) Then
        Dec(VerticalBar);
     If Keydown[80] And (VerticalBar <200) Then
        Inc(VerticalBar);
     If Keydown[75] And (HorizontalBar >=0) Then
        Dec(HorizontalBar);
     If Keydown[77] And (HorizontalBar <320) Then
        Inc(HorizontalBar);
End;










Procedure GrabShape;
Var
    Dist: integer;
    TempString: string[4];

Begin
     BarColour:=GetBrightestColour;
     HookKeyboardInt;

     Repeat
           ShowBitmap(BufferSeg,BufferOffset);
           SetSourceBitmapAddr($a000,0);

           SetColour(BarColour);

           Line(FirstBarX,0,FirstBarX,199);
           Line(0,FirstBarY,319,FirstBarY);

           If Grabbing Then
              Begin
              Line(SecondBarX,0,SecondBarX,199);
              Line(0,SecondBarY,319,SecondBarY);

              If SecondBarX > FirstBarX Then
                 Dist:=(SecondBarX - FirstBarX)+1
              Else
                  Dist:=(FirstBarX - SecondBarX)+1;

              Str(Dist,TempString);
              OutTextXY(0,190,'WIDTH: '+TempString);

              If SecondBarY > FirstBarY Then
                 Dist:=(SecondBarY - FirstBarY)+1
              Else
                  Dist:=(FirstBarY - SecondBarY)+1;

              Str(Dist,TempString);
              OutTextXY(160,190,'HEIGHT:'+TempString);

              End;

           { Memw[$40:$1a]:=Memw[$40:$1c]; }

           If Not Grabbing Then
              Begin
              UpdateBars(FirstBarX, FirstBarY);
              If Keydown[57] Then Begin
                  Sound(50);
                  Delay(100);
                  NoSound;
                  Grabbing:=True;
                  SecondBarX:=FirstBarX+15;
                  SecondBarY:=FirstBarY+15;
              End;
              End
           Else
               Begin
               UpdateBars(SecondBarX, SecondBarY);

               If Keydown[57] Then
                  Begin
                  UnHookKeyBoardInt;
                  SetSourceBitmapAddr(BufferSeg,BufferOffset);
                  GetTheShape;
                  Grabbing:=False;
                  HookKeyBoardInt;
                  End;
               End;

           { Make sure that bars flicker }

           Until KeyDown[1];
     UnHookKeyboardInt;
End;















{
What this does is allocate memory for the PCX (Assuming 64000
bytes are free for it) then loads the PCX into RAM, where it
can be read (but not altered) by this program.
}

Procedure LoadPCXIntoBuffer(ThePCXFileName:string);
Begin
     If MaxAvail > 64000 Then
        Begin
        Bitmap(BufferSeg,BufferOffset);
        SetSourceBitmapAddr(BufferSeg,BufferOffset);
        InitVGAMode;

        LoadPCX(ThePCXFileName,ThePalette);
        SetAllPalette(ThePalette);
        SetSourceBitmapAddr($a000,0);
        CopySourceBitmap;
        End
     Else
         Begin
         Writeln;
         Writeln('Out of memory error. The program needed 64K for the');
         Writeln('PCX buffer but only ',maxavail div 1024,'K was');
         Writeln('available.');
         Writeln;
         Halt;
         End;

End;






Procedure FreeBuffer;
Begin
     FreeBitmap(BufferSeg,BufferOffset);
End;










{
Ask for the name of PCX to load.
}


Procedure RequestPCXFile;
Var PCXName: PathStr;
    DummyFileVar: File;
Begin
     Writeln;
     Writeln('Enter name of Mode 13h 256 colour PCX file to load :');
     Readln(PCXName);
     Assign(DummyFileVar,PCXName);
     {$i-}
     Reset(DummyFileVar);
     {$i+}

     If IoResult = 0 Then
        LoadPCXIntoBuffer(PCXName)
     Else
         Begin
         Writeln;
         Writeln('Error in loading your .PCX file!');
         Writeln('The filename (and/or path) specified does not exist.');
         Halt;
     End;
End;









{
Main()
}

Begin
     Writeln;
     Writeln('PCX Shape grabber  (C) 1995 Scott Tunstall.');
     Writeln;
     Writeln('Written especially for :');
     Writeln('   Scott "B & Q" Ramsay');
     Writeln('   Paul Langa');
     Writeln;

     If ParamCount <>1 Then
        RequestPCXFile
     Else
         LoadPCXIntoBuffer(Paramstr(1));

     Grabbing:=False;
     FirstBarX:=160;
     FirstBarY:=100;
     SecondBarX:=160;
     SecondBarY:=100;

     GrabShape;
     FreeBuffer;
END.




