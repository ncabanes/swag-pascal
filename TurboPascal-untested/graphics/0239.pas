(*
====================================================================

FILENAME : GRABIMG2.PAS

AUTHOR   : SCOTT TUNSTALL (aka LIEUTENANT KOJAK)

CREATION : 20TH JULY 1996
DATE


DISTRIBUTE FREELY AS LONG AS MY NAME, CODE AND COMMENTS REMAIN
INTACT.

ALL WORK (C) 1996 SCOTT TUNSTALL

--------------------------------------------------------------------


REQUIREMENTS:

NEEDS KOJAKVGA, WHICH SHOULD BE IN THE GRAPHICS.SWG POST.


WHAT THIS PROGRAM DOES
----------------------

This program allows you to load in a 256 colour PCX and save
areas of it as a .IMG file. Specify the PCX filespec on the command
line.

Use the cursor keys to move the cross hairs. (Using CTRL + direction
makes the crosshairs move faster).

Press space when you are at the top left of the area you wish to cut,
then when the second pair of cross hairs appear, move them to the
bottom right of the image to cut. You will see the size of the
image in horizontal width & vertical height at the bottom left
of the screen. When you have a sprite of the desired size defined
within the crosshairs, press space again.

If the Shape (it must be <= width/height 255 * 200) can be
grabbed then you will be presented with a menu which allows
you to manipulate the sprite. (If you can't see the menu text, use
the + and - keys to change the menu text colour. Also, pressing
T moves menu to (t)op of screen whereas B moves menu to (b)ottom )



IMPROVEMENTS OVER 1ST GRABIMG
-----------------------------

All known bugs have been fixed, more options allowed...
validation, what more can I say? Except GRABIMG2 is the
BUSINESS! I should be charging you lot for writing
this !!! :)




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
         saved line by line.

To read it use the LoadShape command present in NEWGRAPH

ex:
        var p: pointer;
        LoadShape('SPRITE.IMG',p);
        ...

To display it use the Blit/Block/ClipBlit/ClipBlock commands.

*)


{
Requires KOJAKVGA, which should be in the SWAG post you got this
GRABIMG2 from. I wrote it, so it has my name.

If you can't find KOJAKVGA then you will have to convert this
to work with NEWGRAPH. Sorry!


NWKBDINT is in June 96's KEYBOARD.SWG - author: Me!
}

Uses KOJAKVGA, NWKBDINT, CRT, DOS;


Var BarColour : byte;
    MenuColour: byte;
    MenuY     : byte;

    FirstBarX,
    FirstBarY,
    SecondBarX,
    SecondBarY: integer;
    LastWidth : word;
    LastHeight: word;

    Grabbing  : boolean;
    BufferPtr : pointer;
    ThePalette: PaletteType;





{
Find the brightest colour available. (Smarm removed :) )

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
           GetRGB(Count,RedTotal,GreenTotal,BlueTotal);
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






{
Thought I'd re-write this in asm, just to be nerdy.
}


Procedure Sort(Var N1, N2: integer); Assembler;
Asm
   PUSH DS
   LDS SI,N1
   LES DI,N2

   MOV AX,[SI]
   MOV BX,[ES:DI]

   CMP AX,BX
   JL @NoSwap
   MOV [SI],BX
   MOV [ES:DI],AX

@NoSwap:
   POP DS
End;









Procedure ShowImage(boxcolour: byte; Var Theimage:pointer);
Begin
     Cls;

     UseColour(boxcolour);
     Rectangle(0,0, 1+ShapeWidth(TheImage^),
                          1+ShapeHeight(TheImage^));
     Block(1,1,TheImage^);
End;



{
Oh my God! The original code here was so err.. unoptimised!
}




Procedure GetTheShape(bmapptr:pointer; x1,y1,x2,y2:integer);
Var ShapeFile, PaletteFile: PathStr;
    TheShapePointer: pointer;

    MemRequired: word;

    Key: char;

Begin

     Sort(x1,x2);
     if (x2-x1)>254 then x2:=x1+254;

     Sort(y1,y2);
     if (y2-y1)>199 then y2:=y1+199;


{
Ahem. A small bug was here in the last version :(
}

     MemRequired:= ShapeSize(x1,y1,x2,y2);

     UseBitmap(Bmapptr);

     GetMem(TheShapePointer,MemRequired);
     GetAShape(X1,Y1,X2,Y2,TheShapePointer^);


     UseBitmap(ptr($a000,0));
     UnHookKeyboardInt;




     repeat
           ShowImage(MenuColour,TheShapePointer);

           UseFont(1);
           FillArea(0,MenuY,319,MenuY+24,0);
           PrintAt(0,MenuY,    'T/B = MENU TOP/BOTTOM  +/- = COLOUR');
           PrintAt(0,MenuY+8,  'S/P = SAVE IMAGE/PALETTE TO DISK');
           PrintAt(0,MenuY+16, 'X/Y = FLIP IN X/Y DIRECTION  C = CANCEL');


           Repeat
                 key:=upcase(readkey);
           Until (key in ['T', 'B', '-', '+', 'S','P','X','Y','C']);

	   Case key of
           'T' : MenuY:=0;

           'B' : MenuY:=191-24;

           '-' : Dec(MenuColour);

           '+' : Inc(MenuColour);

	   'S' : Begin
                 ShowImage(MenuColour, TheShapePointer);
                 Gotoxy(1,1+(MenuY SHR 3));
                 TextColor(MenuColour);
                 TextBackground(0);
                 Write('SAVE IMAGE AS :');
                 ReadLn(ShapeFile);
                 SaveShape(ShapeFile,TheShapePointer);
                 End;

           'P' : Begin
                 ShowImage(MenuColour, TheShapePointer);
                 Gotoxy(1,1+(MenuY SHR 3));
                 TextColor(GetBrightestColour);
                 TextBackground(0);
                 Write('SAVE PALETTE AS :');
                 Readln(PaletteFile);
                 SavePalette(PaletteFile, ThePalette);
                 End;

           'X' : XFlipShape(TheShapePointer^);
           'Y' : YFlipShape(TheShapePointer^);
           End;

     until key = 'C';


     FreeShape(TheShapePointer);

End;











{
Small optimisations!
}



Procedure UpdateBars(Var HorizontalBar, VerticalBar: integer);
Begin
     If Keydown[72] Then
        Begin
        If KeyDown[29] Then
           Dec(VerticalBar,4)
        Else
            Dec(VerticalBar);

        If (VerticalBar <0) Then VerticalBar:=0;
        End;

     If Keydown[80] Then
        Begin
        If KeyDown[29] Then
           Inc(VerticalBar,4)
        Else
            Inc(VerticalBar);

        If (VerticalBar >199) Then VerticalBar:=199;
        End;


     If Keydown[75] Then
        Begin
        If KeyDown[29] Then
           Dec(HorizontalBar,4)
        Else
            Dec(HorizontalBar);

        If (HorizontalBar <0) Then HorizontalBar:=0;
        End;

     If Keydown[77] Then
	Begin
        If KeyDown[29] Then
           Inc(HorizontalBar,4)
        Else
            Inc(HorizontalBar);

        If (HorizontalBar >319) Then HorizontalBar:=319;
        End;


End;










Procedure GrabShape(BMapPtr: pointer);
Var
    Dist: integer;
    TempString: string[4];

Begin
     BarColour:=MenuColour;
     HookKeyboardInt;
     UseBitmap(ptr($a000,0));


     Repeat
           ShowAllBitmap(BMapPtr);

           UseColour(BarColour);

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

              LastWidth:=Dist;

              Str(Dist,TempString);
              PrintAt(0,190,'WIDTH: '+TempString);


              If SecondBarY > FirstBarY Then
                 Dist:=(SecondBarY - FirstBarY)+1
              Else
                  Dist:=(FirstBarY - SecondBarY)+1;

              Dist:=(SecondBarY-FirstBarY)+1;

              LastHeight:=Dist;

	      Str(Dist,TempString);
              PrintAt(160,190,'HEIGHT:'+TempString);


              UpdateBars(SecondBarX, SecondBarY);

              If Keydown[57] Then
                 Begin
                 GetTheShape( BMapPtr, FirstBarX,FirstBarY, SecondBarX,
                              SecondBarY);

                 UseBitmap(ptr($a000, 0));

                 HookKeyBoardInt;

                 Grabbing:=False;
                 End;
              End
           Else
              Begin
              UpdateBars(FirstBarX, FirstBarY);
              If Keydown[57] Then
              Begin
                  Sound(50);
                  Delay(100);
		  NoSound;
                  Grabbing:=True;
                  SecondBarX:=FirstBarX+LastWidth;
                  SecondBarY:=FirstBarY+LastHeight;
              End;
           End;


           Until KeyDown[1];
     UnHookKeyboardInt;
End;















{
What this does is allocate memory for the PCX (Assuming 64000
bytes are free for it) then loads the PCX into RAM, where it
can be read (but not altered) by this program.
}

Procedure LoadPCXIntoBuffer(ThePCXFileName:string; var BMapPtr: pointer);
Begin
     If MaxAvail > 64000 Then
        Begin
        BMapPtr:=New64KBitmap;
        UseBitmap(BMapPtr);
	Cls;
	LoadPCX(ThePCXFileName,ThePalette);

        InitVGAMode;
        UsePalette(ThePalette);
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











{
Ask for the name of PCX to load.
}


Procedure LoadPCXFile(var BMapPtr: pointer);
Var PCXName: PathStr;
    DummyFileVar: File;
Begin
     TextColor(LIGHTGRAY);
     Writeln;
     Writeln;
     Writeln;
     Writeln('════════════════════════════════════════════════════');
     Writeln('PCX Shape grabber version 2 (C) 1996 Scott Tunstall.');
     Writeln('All rights reserved. This item is FREEWARE.');
     Writeln('════════════════════════════════════════════════════');
     Writeln;
     Writeln('Written especially for :');
     Writeln('   SourceWare Archival Group');
     Writeln('   Geoff Bassett');
     Writeln('   Scott "B & Q" Ramsay');
     Writeln('   Paul Langa');
     Writeln;


     If ParamCount = 0 Then
        Begin
        Writeln;
        Write('Enter name of 256 colour PCX file to load :');

        PCXName:='';
	Readln(PCXName);
        Assign(DummyFileVar,PCXName);
        {$i-}
        Reset(DummyFileVar);
        {$i+}

        If IoResult = 0 Then
           LoadPCXIntoBuffer(PCXName,BMapPtr)
        Else
            Begin
            TextColor(LIGHTRED);
            Writeln;
	    Writeln('Error in loading your .PCX file! The file with the name');
            Writeln('that you specified does not exist...');
            Halt(1);
        End;
        End
     Else
         LoadPCXIntoBuffer(ParamStr(1),BMapPtr);

End;









{
Main()
}

Begin

     Grabbing:=False;
     FirstBarX:=160;
     FirstBarY:=100;
     SecondBarX:=160;
     SecondBarY:=100;
     LastWidth:=16;
     LastHeight:=16;


     Directvideo:=False;

     LoadPCXFile(BufferPtr);
     MenuColour:=GetBrightestColour;
     MenuY:=191-24;

     GrabShape(BufferPtr);
     FreeBitmap(BufferPtr);
END.



