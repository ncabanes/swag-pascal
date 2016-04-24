(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0274.PAS
  Description: Re: FADING CODE
  Author: MIKE PHILLIPS
  Date: 08-30-96  09:35
*)

{
There is no such thing as an ANSI card.  I assume you mean VGA's CGA
text mode emulation?  A VGA is VGA is VGA, text mode or graphics.  The
CGA emulation only goes as far as the BIOS.  Fading out is easy:
}
var All_RGB : array[1..256*3] of byte;

  Procedure FadeOut;

    Label OneCycle,ReadLoop,DecLoop,Continue,Retr,Wait,Retr2,Wait2;

    Begin { FadeOut }
      Asm
        MOV   CX,64
OneCycle:

        MOV     DX,3DAh
Wait:   IN      AL,DX
        TEST    AL,08h
        JZ      Wait
Retr:   IN      AL,DX
        TEST    AL,08h
        JNZ     Retr

        MOV   DX,03C7h
        XOR   AL,AL
        OUT   DX,AL
        INC   DX
        INC   DX
        XOR   BX,BX
ReadLoop:
        IN    AL,DX
        MOV   Byte Ptr All_RGB[BX],AL
        INC   BX
        CMP   BX,256*3
        JL    ReadLoop

        XOR   BX,BX
DecLoop:
        CMP   Byte Ptr All_RGB[BX],0
        JE    Continue
        DEC   Byte Ptr All_RGB[BX]

Continue:
        INC   BX
        CMP   BX,256*3
        JL    DecLoop

        MOV     DX,3DAh
Wait2:   IN      AL,DX
        TEST    AL,08h
        JZ      Wait2
Retr2:   IN      AL,DX
        TEST    AL,08h
        JNZ     Retr2

        MOV   DX,03C8h
        MOV   AL,0
        OUT   DX,AL
        INC   DX
        MOV   SI,OFFSET All_RGB
        CLD
        PUSH  CX
        MOV   CX,256*3
        REP   OUTSB
        POP   CX

        LOOP  OneCycle

      End;
    End; { FadeOut }

That code may be used in any VGA color mode, text or graphics.  Even
though it fades all 256 color registers, it will work for the 16 color
modes.  You could change it to just fade the first 16 registers (change
all 256*3 to 16*3), but why?  As is, this code can be used in all
standard modes.

Fading in is a bit more complex.  Since you mentioned ANSI screens, I
assume you want to fade into the CGA text mode pallette.  You can get
this pallete by switching to graphics mode, switching back into text
mode, then read the first 16 pallete entries into a [1..16*3] array on
program start up.  When you switch into text mode using the VGA BIOS,
the BIOS assumes you want CGA compatibility, so it will initialize the
pallete with the CGA colors and sets the font to the CGA character set.
Once this is done however, the card behaves like the VGA that it is.
After you have stored the pallete values, zero out the pallete.  Now,
copy your ANSI to the screen.  After you have done this, you will
basically do the opposite of the fade out routine, incrementing each
color part until it reaches the stored value.  Remember to wait for
retrace after incrementing the entire pallete.  Use a temp array to
store your pallete values so you do not have to read in the pallete with
each loop.  You can easily change the DecLoop: section of the above code
to do the fading in.  Compare the value from the temp array to the value
in the CGA pallete array (the one you created at program start up)
instead of 0.  Change the dec to inc.  You also need to change all the
256*3's to 16*3 since you are only working with 16 pallete entries.  The
rest of them are undefined when you do that switch, so there's no need
of fading them in.  If you have called your pallete CGA_RGB, the changes
to the fade code would look like:

DecLoop:
        CMP   Byte Ptr All_RGB[BX], Byte Ptr CGA_RGB[BX]
        JE    Continue
        INC   Byte Ptr All_RGB[BX]

Of course you do not HAVE to use the CGA color pallete.  You can set
your final pallete values to anything you wish, provided they are all
different (or you may have some invisible text due to
background=foreground) for some interesting results.  The format for the
pallete array is:
red0, green0, blue0,
red1, green1, blue1,
etc.
They may vary between 0 and 63 inclusive.  Color 0 should normally be
black (0,0,0).  White would be (63,63,63); this is color 15 by default.
Bright red is (63,0,0), dull red could be (32,0,0), but I'm not sure of
the actual value.  If you're curious, it's color 4.  Note, however, that
if you change the final pallete values from the CGA values, your "ANSI"
screens will techincally no longer be ANSI.  You can get the CGA values
back by changing to graphics mode, then back into text mode on program
exit.

Note that the viewer of your magazine must have a 100% VGA compatible
card for any of the above to work.

 BM> And if someone out there wants to be an even greater help, could you
 BM> please post in some code that has scrolling ansi and stuff, cuz that
 BM> would look  really good on my title screen, if i had nice smooth moving
 BM> graphics (ansi) 

Use the BIOS putchar function instead of a direct screen write.  If
using the CRT unit and write(), set directvideo := false.

 BM> So if there is someone out there who has either or both of those codes
 BM> that i need can you please post them in a message to me.

Of course, I don't know how much you know about VGA programming.  If any
or all of this was over your head, let me know.  I have a feeling you
may need some code to get the pallete entries, but this message is
getting too long, especially since I don't know how much you know.

Mike Phillips
INTERNET:  phil4086@utdallas.edu

