                           MCGA Graphics Tutorial
                                 Lesson #1
                                by Jim Cook

I'm not sure how this online tutorial will be received, but with your
comments and feedback I plan on creating a full-blown animation package. This
graphics library will be available to the public domain and will contain the
following abilities:

                Setting/Reading Pixels
                Drawing lines
                Saving/Restoring areas of the screen
                Displaying PCX/LBM files to the screen
                Spriting (Display picture with transparent areas)
                Palette control (Smooth fades to black)
                Page flipping

Before we're done, you will have the tools to produce programs with rich,
even photo-realistic (for the resolution) images on your PC.  The necessary
hardware is a VGA card and monitor that's it.  I'll be using Turbo Pascal
version 6.0.  Please holler if that will be a problem.  I'm using it to
create inline assembly.  My alternatives are inline code (yuk) or linking in
external assembly.  For speed (and actually ease) the latter is better.  If I
receive three complaints against 6.0, I'll use external assembly.

                                What is MCGA?

Multi-Color Graphics Array is the video card that IBM built into it's Model
25 and 30 PS/2's.  It subsequently became a subset of the standard VGA
adapter card.  It has the distiction of being the first card (excluding
Targa and other expensive cards) to display 256 colors at once on the
computer screen.  To us that meant cool games and neat pictures.  The MCGA
addapter has added two new video modes to the PC world:

                Mode $11        640x480x2 colors
                Mode $13        320x200x256 colors

Obviously, we will deal with mode $13.  If we wanted to deal with two
colors, we'd be programming a CGA.  So much for the history lesson...let's
dive in.

I've created a unit, MCGALib, that will contain all of our MCGA routines.
The first two procedures we will concern ourselves with are setting the
graphics mode and setting a pixel.  The MCGALib is followed by a test
program that uses the two procedures:

Unit MCGALib;

interface

Procedure SetGraphMode (Num:Byte);
Procedure SetPixel     (X,Y:Integer;Color:Byte);

implementation

var
  ScreenWide  :  Integer;
  ScreenAddr  :  Word;

Procedure SetGraphMode (Num:Byte);
begin
  asm
    mov al,Num
    mov ah,0
    int 10h
    end;
  Case Num of
    $13 : ScreenWide := 320;
    end;
  ScreenAddr := $A000;
end;
{
Function PixelAddr (X,Y:Word) : Word;
begin
  PixelAddr := Y * ScreenWide + X;
end;

Procedure SetPixel (X,Y:Integer;Color:Byte);
var
  Ofs    :  Word;
begin
  Ofs := PixelAddr (X,Y);
  Mem [ScreenAddr:Ofs] := Color;
end;
}

Procedure SetPixel (X,Y:Integer;Color:Byte);
begin
  asm
    push ds
    mov  ax,ScreenAddr
    mov  ds,ax

    mov  ax,Y
    mov  bx,320
    mul  bx
    mov  bx,X
    add  bx,ax

    mov  al,Color
    mov  byte ptr ds:[bx],al
    pop  ds
    end;
end;

Begin
End.

This is the test program to make sure it's working...

Program MCGATest;

uses
  Crt,Dos,MCGALib;

var
  Stop,
  Start  :  LongInt;
  Regs   :  Registers;

Function Tick : LongInt;
begin
  Regs.ah := 0;
  Intr ($1A,regs);
= egs.cx hl 16  Rgs.dx;
end;

Procedure Control;
var
  I,J :  Integr;begin
  Start := ic;
  Fr I := 0 to 199 do
  For J  SetPixe (J,I,Random(256));
 Stop := Tick;
end;

Pocdure Closing;
var
  Ch    :  Chr;
begin
  Repet Until Keypressed;
  While Keypressed do Ch:= Reake;
  TextMode (3);
ook '(Stop-Start),' ticks or ,(Stop-Start)/182:4:3,'
 seconds!');
nd;

Procedure Init;
begin
  SetGaphMode ($13);
 Randoiz;
end;

Begin
 Init
  Control;
  Cosing;
e where these listings coul get unbearably long in time.  I'l
explore a few ays I can get this information to ya'll without takingup too
much pace. Iwould like you tomake sue this routine works, ust in case
you ou graphis card. You may notce two SetPxel
procedures in the MCGALib, one is commented out.  Remove he comments,
comment up the uncommented SetPixel and run the test program aain.  Notice
the speed degradation.  Linking in raw assembly will eve improve upon the
speed of the inline assembly.
Please take the time to study each procedure and ASK ANY QUESTIONS tht you
may have, even if it doesn't relate to the graphics routines.  I'm cetain I
do not want to get pulled off track by any discussions about STYLE,ur critique
 for others to learn rom.

                              Coming next time

I think a discussio of video memory is paramount.  Possibly vertical and
horizontal lines, if spce permits.

Happy grafx
jim

--- QuickBBS 2.75
 * Origin: Quantum Leap.. (512)333-5360  HST/DS (1:387/307)
                                                                                                                     