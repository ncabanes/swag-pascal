{
MARK DIXON

Um, have a look at this, and see what you can come up with. It's some code I
wrote a while back to use mode-x and do double buffering (or page-flipping).
}

Program Test_ModeX;

Uses
  crt;


{ This program will put the VGA card into a MODEX mode (still only 320x200)
  and demonstrate double buffering (page flipping)

  This program was written by Mark Dixon, and has been donated to the
  Public Domain with the exception that if you make use of these routines,
  the author of these routines would appreciate his name mentioned somewhere
  in the documentation.

  Use these routines at your own risk! Because they use the VGA's registers,
  cards that are not 100% register compatible may not function correctly, and
  may even be damaged. The author will bear no responsability for any actions
  occuring as a direct (or even indirect) result of the use of this program.

  Any donations (eg Money, Postcards, death threats.. ) can be sent to  :

  Mark Dixon
  12 Finchley St
  Lynwood,
  Western Australia
  6147

  If you have Netmail access, then I can also be contacted on 3:690/660.14

  }

Const
  Page : Byte = 0;

Var
  I, J : Word;


Procedure InitModeX;
{ Sets up video mode to Mode X (320x200x256 with NO CHAIN4) making available
  4 pages of 4x16k bitmaps }
Begin
  asm
    mov    ax, 0013h    { Use bios to enter standard Mode 13h }
    int    10h
    mov    dx, 03c4h    { Set up DX to one of the VGA registers }
    mov    al, 04h      { Register = Sequencer : Memory Modes }
    out    dx, al
    inc    dx           { Now get the status of the register }
    in     al, dx       { from the next port }
    and    al, 0c7h     { AND it with 11000111b ie, bits 3,4,5 wiped }
    or     al, 04h      { Turn on bit 2 (00000100b) }
    out    dx, al       { and send it out to the register }
    mov    dx, 03c4h    { Again, get ready to activate a register }
    mov    al, 02h      { Register = Map Mask }
    out    dx, al
    inc    dx
    mov    al, 0fh      { Send 00001111b to Map Mask register }
    out    dx, al       { Setting all planes active }
    mov    ax, 0a000h   { VGA memory segment is 0a000h }
    mov    es, ax       { load it into ES }
    sub    di, di       { clear DI }
    mov    ax, di       { clear AX }
    mov    cx, 8000h    { set entire 64k memory area (all 4 pages) }
    repnz  stosw        { to colour BLACK (ie, Clear screens) }
    mov    dx, 03d4h    { User another VGA register }
    mov    al, 14h      { Register = Underline Location }
    out    dx, al
    inc    dx           { Read status of register }
    in     al, dx       { into AL }
    and    al, 0bFh     { AND AL with 10111111b }
    out    dx, al       { and send it to the register }
                        { to deactivate Double Word mode addressing }
    dec    dx           { Okay, this time we want another register,}
    mov    al, 17h      { Register = CRTC : Mode Control }
    out    dx, al
    inc    dx
    in     al, dx       { Get status of this register }
    or     al, 40h      { and Turn the 6th bit ON }
    out    dx, al       { to turn WORD mode off }
                        { And thats all there is too it!}
  End;
End;


Procedure Flip;
{ This routine will flip to the next page, and change the value in
  PAGE such that we will allways be drawing to the invisible page. }
Var
  OfsAdr : Word;
Begin
  OfsAdr := Page * 16000;
  asm
    mov    dx, 03D4h
    mov    al, 0Dh      { Set the Start address LOW register }
    out    dx, al
    inc    dx

    mov    ax, OfsAdr
    out    dx, al       { by sending low byte of offset address }
    dec    dx
    mov    al, 0Ch      { now set the Start Address HIGH register }
    out    dx, al
    inc    dx
    mov    al, ah
    out    dx, al       { by sending high byte of offset address }
  End;

  Page := 1 - Page;     { Flip the page value.
                          Effectively does a :
                          If Page = 0 then Page = 1 else
                          If Page = 1 then Page = 0.       }
End;



Procedure PutPixel (X, Y : Integer; Colour : Byte );
{ Puts a pixel on the screen at the current page. }
Var
  OfsAdr : Word;
BEGIN
  OfsAdr := Page * 16000;
  ASM
    mov    bx, x
    mov    ax, Y
    mov    cx, 80     { Since there are now 4 pixels per byte, we
                        only multiply by 80 (320/4) }
    mul    cx
    mov    di, ax
    mov    ax, bx
    shr    ax, 1
    shr    ax, 1
    add    di, ax
    and    bx, 3
    mov    ah, 1
    mov    cl, bl
    shl    ah, cl

    mov    al, 2
    mov    dx, 03C4h

    mov    bx, $A000
    mov    es, bx
    add    di, OfsAdr

    out    dx, ax        { Set plane to address (where AH=Plane) }
    mov    al, Colour
    mov    es:[di], al
  end;
end;

Begin
  Randomize;
  InitModeX;
  Flip;

  For I := 0 to 319 do
    For J := 0 to 199 do
      PutPixel(I, J, Random(32) );
  Flip;

  For I := 0 to 319 do
    For J := 0 to 199 do
      PutPixel(I, J, Random(32) + 32);

  Repeat
    Flip;
    Delay(200);
  Until Keypressed;

End.
