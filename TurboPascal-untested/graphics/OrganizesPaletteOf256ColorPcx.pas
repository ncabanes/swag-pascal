(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0261.PAS
  Description: Organizes Palette of 256 Color PCX
  Author: SCOTT TUNSTALL
  Date: 05-30-97  18:17
*)

{
====================================================================

FILENAME :    REMAP.PAS

AUTHOR   :    SCOTT TUNSTALL B.Sc

CREATION :    16TH NOVEMBER 1996
DATE

PURPOSE  :    ORGANISES THE PALETTE OF A 256 COLOUR PCX SO THAT
              THE USED COLOURS ARE ARRANGED SEQUENTIALLY,
              AND UN-USED COLOURS IN YOUR PCX ARE DELETED
              (MEANING, RESET TO R,G,B 0 0 0 )

              THIS UTIL IS ONLY USEFUL FOR GAMES PROGRAMMERS,
              OR THOSE WHO WANT A WELL ORGANISED PALETTE!


       THIS UTIL NEEDS KOJAKVGA 3.3 FOR SUCCESSFUL OPERATION!!
       KOJAKVGA 3.1/3.2 HAS BUGS IN THE PCX SAVE ROUTINES.

--------------------------------------------------------------------


INTRODUCTION
------------

With a 256 colour picture, it's quite likely that not all 256 colours
are used on screen.

This program counts the number of colours used in a PCX file, then
organises the palette entries so that all colours used are
sequential. Duh?

Say for example you had a PCX file which used 6 from the 256 colours.
The colours used being 1,2,4,9,127,255. (The rest obviously
are unused.)

Wouldn't you like those colours to be remapped so that colour 4
would move to unused colour slot 3, colour 9 to 4, colour 127 to 5?
Thus having colours 1,2,3,4,5,6 used? And 7-255 free?

"Why?" You ask. Reason is, games programmers like to reserve a portion
of the palette for sprites and the other portion for the background.

Say colours 0-127 was reserved for shapes, and 128-255 was
reserved for the background. But colour 200 was used as a
shape colour.

That would mean every 128 colour background palette you loaded
would have to preserve colour 200's RGB value just in case a
shape required it.

And say the shape palette needed to be changed but a background
palette needed a particular colour. Annoying huh?

By using this program with a bare background screen (no sprites
present) you can organise your palette and then allocate a sequential
palette space for sprites.


        This text is (C) 1996 Crap explanations ltd.
        Do not sue me :)



WHAT DO YOU DO?
---------------

This works from DOS:

Syntax: REMAP [/M] <256 Colour PCX to remap> [Dest PCX name]


If you specify the command line /M (For MERGE) then the palette
shall be shrunk to it's smallest size; duplicate palette entries
shall be merged if two colours present on screen have identical
RGB values. (Of course, this may disrupt PCX's with hidden
graphics, say for example, black text on a black background,
which will then be faded in later on in a program)

You MUST specify the name of the PCX to remap. The PCX may be
UP TO 320 x 200: IF LARGER, THE PCX's DIMENSIONS ARE CLIPPED
TO 320 x 200!!!

You need not specify the name of the destination PCX file. The
default name is REMAPPED.PCX .


When the program ends, you will be told how many colours were used.
This number also indicates the first free colour which you can use
for backgrounds etc.

If you decided to condense the palette, you will see how many
colours remain after palette merge.




DISCLAIMER
----------

If the PCX turns out funny it's not my fault OK! And I take ZERO
responsibility for any damage this program causes. This program
seems to work OK on my machine. (i.e. -> it's not crashed yet)

Use this program at your own risk.


--------------------------------------------------------------------
}




Program REMAP_PCX;

Uses crt,KOJAKVGA;


{
If you're using KOJAKVGA version 3.3, or you've removed the PCX
save errors from KOJAKVGA 3.1/3.2 then delete the next line :)
}


{$DEFINE EMBARASS_SCOTT}


Var
   SrcBmap   : Pointer;
   DstBMap   : Pointer;
   SrcPalette: PaletteType;
   DstPalette: PaletteType;
   Merge     : Boolean;
   Remapped  : Byte;
   Adjusted  : Byte;
   InFileName,
   OutFileName: string[80];







{ Returns TRUE if Colour WhichColour is present on the 64K
  bitmap specified }

Function ColourUsed(TheBitmap: pointer; WhichColour:byte): boolean;
Assembler;
Asm
     PUSH DS
     LDS SI,TheBitmap
     MOV AH,WhichColour

     MOV CX,64000
     CLD

@Check:
     LODSB
     CMP AL,AH
     JZ @ItsUsed
     DEC CX
     JNZ @Check

     MOV AL,False
     JMP @Exit

@ItsUsed:
     MOV AL,True

@Exit:
     POP DS
End;






{
Normally I'd write 20000 lines of documentation for this, but really
I can't be bothered as it's operation is so simple.

Basically the RGB data for colour ColNo in Palette SrcPal
is moved to colour NewNo in Palette DstPal, and every pixel
which matches colour ColNo on the source bitmap is changed to
colour NewNo on the dest bitmap.

Got that? No? Tough! =)

}



Procedure RemapBitmap( Src: pointer; ColNo: byte;
                       Dst: pointer; NewNo: byte);
Begin

     Asm
     PUSH DS
     MOV BL,NewNo

     LES DI,Dst
     LDS SI,Src

     MOV CX,64000
     CLD

@ChangeLoop:
     MOV AL,[SI]
     CMP AL,ColNo
     JNZ @NoRemapByte

     MOV [ES:DI],BL

@NoRemapByte:
     INC SI
     INC DI

     DEC CX
     JNZ @ChangeLoop
     POP DS
     End;

End;







{
If a colour is used, it's shunted to an area in the palette that's
unused, therefore bunching all used colours TOGETHER.
}



Function SqueezePalette( SrcBMap:pointer; SrcPal:PaletteType;
                         DstBMap:pointer; Var DstPal:PaletteType): byte;
Var ColCount: byte;
    RemapNum: byte;

Begin
     RemapNum:=0;
     For Colcount:=0 to 255 do
         If ColourUsed(SrcBmap,ColCount) Then
            Begin
            DstPal.RedLevel[RemapNum]:=SrcPal.RedLevel[ColCount];
            DstPal.GreenLevel[RemapNum]:=SrcPal.GreenLevel[ColCount];
            DstPal.BlueLevel[RemapNum]:=SrcPal.BlueLevel[ColCount];
            RemapBitmap(SrcBMap,ColCount,DstBMap,RemapNum);
            Inc(RemapNum);
         End;

     SqueezePalette:=RemapNum;
End;




{
Merge duplicate palette entries.
If any two colours on the bitmap have the same RGB, this will remove
one of the identical colours, therefore creating a free RGB entry.

Returns number of merged colours.
}


Function MergeDuplicates( TheBitmap:pointer;
                           Var ThePalette: PaletteType;
                           PaletteSize: byte) : byte;
Var ColCount:  byte;
    ColCount2: byte;

Begin
     For ColCount:=0 to (PaletteSize-1) do
         For ColCount2:=(ColCount+1) to PaletteSize do
             Begin
             With ThePalette do
             if (RedLevel[ColCount]=RedLevel[ColCount2])
             And (GreenLevel[ColCount]=GreenLevel[ColCount2])
             And (BlueLevel[ColCount]=BlueLevel[ColCount2]) Then
                 RemapBitmap(TheBitMap,ColCount2,TheBitMap,ColCount);
         End;

     MergeDuplicates:=SqueezePalette( TheBitmap,ThePalette,TheBitmap,
                                      ThePalette);
End;







Begin
     {
     KOJAKVGA 3.1/3.2 couldn't save PCX files 100% correctly
     so this code stops you from wasting time.
     }

{$IFDEF EMBARASS_SCOTT}

     If GetVersion < $0303 Then
        Begin
        Writeln;
        Writeln('YOU ARE USING AN OUT OF DATE KOJAKVGA UNIT.');
        Writeln;
        Writeln('This program needs KOJAKVGA version 3.3 or better');
        Writeln('in order for the PCX save routine to work properly !');
        Writeln('(ahem, sorry etc.)');
        Writeln;
        Writeln('Version 3.3 should be in the SWAG though, probably in');
        Writeln('the same post where you got this from ! :)');
        Writeln;
        Halt(1);
     End;

{$ENDIF}


     If (ParamCount = 0) or (ParamCount > 3) Then
        Begin
        Writeln;
        Writeln;
        Writeln('REMAP by Scott Tunstall B.Sc (whoo! =) )   16/11/96');
        Writeln;
        Writeln('Syntax: REMAP [/M] <InFileName> [OutFileName]');
        Writeln;
        Writeln('To merge duplicate palette entries, specify /M switch.');
        Writeln('   (This switch is optional)');
        Writeln;
        Writeln('<InFilename> is required, and specifies the name of the');
        Writeln('   PCX file to remap.');
        Writeln;
        Writeln('[OutFileName] is optional. It specifies the name of the');
        Writeln('   PCX file which shall be hold the remapped data. If you');
        Writeln('   do not specify a file name, the default is REMAPPED.PCX.');
        Writeln;
        If ParamCount > 3 Then
           Begin
           Writeln('Error: 3 parameters max..');
           Writeln;
        End;

        Halt(1);
     End;


     Merge:=False;
     OutFileName:='REMAPPED.PCX';


{ There's no validation of command line parameters. }

     If ParamCount = 1 Then
        InFileName:=Paramstr(1)
     Else
         If ParamCount = 2 Then
            Begin
            If (ParamStr(1)='/m') or (ParamStr(1)='/M') Then
               Begin
               Merge:=True;
               InFileName:=ParamStr(2);
               Sound(50);
               Delay(10);
               NoSound;
               End
            Else
                Begin
                InFileName:=ParamStr(1);
                OutFileName:=ParamStr(2);
            End;
            End
         Else
             Begin
             If (ParamStr(1)='/m') or (ParamStr(1)='/M') Then
                Begin
                Merge:=True;
                InFileName:=ParamStr(2);
                OutFileName:=ParamStr(3);
                End
             Else
                 Begin
                 Writeln;
                 Writeln('WHAT PLANET ARE YOU ON? /M EXPECTED !!!');
                 Halt(1);
             End;
         End;




     { Now lets get going :) }

     SrcBmap:=New64KBitmap;
     UseBitmap(SrcBMap);
     Cls;
     LoadPCX(InFileName,SrcPalette);
     DstBMap:=New64KBitmap;
     CopyBitmapTo(DstBMap);

     FillChar(DstPalette,SizeOf(DstPalette),0);         { All black }

     Write('Remapping ',InFileName,'...');
     Remapped:=SqueezePalette(SrcBmap,SrcPalette,DstBmap,DstPalette);
     Writeln('Done.');

     If Merge Then
        Begin
        Write('Removing duplicate colours...');
        Adjusted:=MergeDuplicates(DstBmap,DstPalette,Remapped-1);
        Writeln('Done.');
     End;

     Write('Saving ',OutFileName,'...');

     UseBitmap(DstBMap);
     SaveAreaAsPCX(OutFileName,DstPalette,0,0,320,200);
     Writeln('Done.');
     Writeln;


     { All done! :) }

     Writeln('# of unique colours used in original :',Remapped);
     If Merge Then
     Writeln('After duplicates removed             :',Adjusted);
     Writeln;

     Writeln('Press ENTER to return to DOS.');
     FreeBitmap(SrcBmap);
     FreeBitmap(DstBMap);
     Readln;
End.


