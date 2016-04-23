{RV│ok i would like some info on how to remove a tsr added to memory by a
  │i'd like some info on ext. VGA screens. For examplw i know that in
  │320x200x256 that one Byte is equal to one pixel. i need this Type of
  │info For =< 640x480

Mode $10 (ie 640x350x16)
-------------------------

In this mode, the  256K display memory is divided into 4 bit planes of
64K each. Each pixel is produced by 4 bits, one from each bit plane, which
are combined into a 4-bit value that determines which of the 16 colors will
appear on the screen For that pixel.

There is a one-to-one correspondense between the bits in each bit plane and
the pixel on the screen. For example, bit 7 of the first Byte in each bit
plane correspond to the pixel in the upper left-hand corner of the screen.

The display memory For the 640x350 Graphics mode is mapped into memory as
a 64K block starting at A000h, With each 64K bit plane occupying the same
address space (ie: in parallel).

Because of the one-to-one relationship of bits in bit planes With the pixels
on the screen, it's straightForward to calculate the address needed to
access a particular pixel. There are 640 bits = 80 Bytes per line on the
screen. Thus the Byte address corresponding to a particular X,Y coordinate
is given by 80*Y + X/8. A desired pixel can then be picked out of the Byte
using the bit mask register.
}

Procedure PutPixel(X,Y:Integer; Color:Byte);
Var
  Byte_address : Word;
  wanted_pixel        : Byte;
begin
  Port[$3CE] := 5;        (* mode register *)
  Port[$3CF] := 2;        (* select Write mode 2 *)
  Port[$3CE] := 8;        (* bit mask register *)
                          (* calculate pixel's Byte address *)
  Byte_address := (80 * Y) + (X div 8);
                          (* set the bit we want *)
  wanted_pixel := (1 SHL (7 - (X MOD 8)));
                          (* mask pixel we want *)
  Port[$3CF] := $FF and wanted_pixel;
                          (* turn the pixel we want on *)
  Mem[$A000:Byte_address] := Mem[$A000:Byte_address] or Color
end; (* PutPixel *)

Function ActiveMode : Byte;
  (* Returns the current display mode *)
Var
  Regs : Registers;     (* Registers from Dos Unit *)
begin
  Regs.AH := $0F;       (* get current video mode service *)
  Intr($10,Regs);       (* call bios *)
  ActiveMode := Reg.AL  (* current display mode returns in AL *)
end;

{
Some video numbers:

  CGA04         = $04;        (* CGA 320x200x4 *)
  CGA06         = $06;        (* CGA 640x200x2 *)

  EGA0D         = $0D;        (* 320x200x16,EGA,2 pages (64K), A0000*)
  EGA0E         = $0E;        (* 640x200x16,EGA,4 pages(64K)      " *)
  EGA0F         = $0F;        (* 640x350 B&W,EGA,2 "     "        "  *)
  EGA10         = $10;        (* 640x350x16 EGA,2 "    (128K)     " *)

  VGA11         = $11;        (* 640x480x2 B&W VGA, 4 pages (256K) " *)
  VGA12         = $12;        (* 640x480x16  VGA   1 page  (256K) " *)
  VGA13         = $13;        (* 320x200x256 VGA   4 pages (256K) " *)

Example:

  ...
  if (ActiveMode = VGA13) then
    begin
      ....
      ShowPCX256
      ....
    end
  ...
}
