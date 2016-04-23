{
Kai Rohrbacher

>> Basically,  Mode  Y  works  like  this:  use  the BIOS to switch
>> into normal 320x200x256  mode,  then reprogram the sequencer to
>> unchain the 4 bitplanes. This  results  in  a bitplaned VRAM layout
>> very similiar to the EGA/VGA's 16 color modes:
>
> By saying 4 bitplanes, are you referering to the pages? I know that
> you can specify 4 pages in mode X/Y.

No, it just means that with each VRAM address, 4 physically different RAM cells
can be addressed: you may think of a "3-dimensional" architecture of your VGA's
VRAM (ASCII sucks, I know...)
             ____________
            |*  plane3   |
         ___|_________   |
        |*   plane2   |__|
     ___|__________   |
    |*   plane1    |__|
 ___|___________   |
|*   plane0     |__|
|               |
|_______________|

The upper left corner of each bitplane (marked by a "*") is referenced with the
address $A000:0, but refers to 4 pixels! It is quite simple: instead of
counting "$A000:0 is the first pixel, $A000:1 is the 2nd, $A000:2 is the 3rd,
$A000:3 is the 4th, $A000:4 is the 5th" (as you would do in the normal BIOS
mode 320x200x256), the pixels now are distributed this way: "$A000:0/plane 0 is
the 1st, $A000:0/plane 1 is the 2nd, $A000:0/plane 2 is the 3rd, $A000:0/plane
3 is the 4th, $A000:1/plane 0 is the 5th" and so on.
So obviously, w/o doing some "bitplane switching", you are always restricted to
work on one bitplane at a time --the one actually being activated. If this is
plane0, you may only change pixels which (x mod 4) remainder is 0, the other
ones with (x mod 4)=1|2|3 aren't accessible, you have to "switch to the plane"
first. Thus the name "bitplane"!

DT> And what exactly does "unchain" mean, as opposed to "chained". I have the
DT> feeling that they refer to each page(bitplane) being on its own.
Huhh, that would go pretty much into details; a bit simplified, "chained" means
that the bitplanes mentioned above are "glued" together for the simple BIOS
mode, so that bitplane switching isn't necessary anymore (that is equivalent in
saying that one VRAM address refers to one RAM cell). As there are only 65536
addresses in the $A000 segment and we need 320x200=64000 for a full page, you
only have 65536/64000=1.024 pages therefore. "Unchaining" means to make each
bitplane accessible explicitely.

> Now here is another problem I don't understand. I am familiar with VGA's
> mode 13h which has one byte specifying each pixel on the screen,
> therefore 1 byte = 1 pixel. But this takes up 64k.

Small note on this: not 64K, but only 64000 bytes!

> But how do you have one address represent 4 pixels, which only occupies
> 16000 address bytes, and still be able to specify 256 colours. Won't 4
> bitplanes at 320x200 each take up 64000x4 bytes of space?

We have 320x200=64000 pixels=64000 bytes. As each 4 pixels share one address,
16000 address bytes per page suffice. The $A000 segment has 64K address bytes,
thus 4*64K=256K VRAM can be addressed. 64K address bytes = 65536 address bytes;
65536/16000 = 4.096 pages.

> How would you go about adjusting the vertical retraces, and memory
> location you mentioned.

Assuming that the DX-register has been set to 3DAh or 3BAh for color/monochrome
display, respectively, you can trace the status of the electronic beam like
this:

  @WaitNotVSyncLoop:
    in   al, dx
    and  al, 8
    jnz  @WaitNotVSyncLoop
  @WaitVSyncLoop:
    in   al, dx
    and  al, 8
    jz   @WaitVSyncLoop
  {now change the starting address}
{
(If you use "1" instead of "8" and exchange "jz" <-> "jnz" and vice vs., then
you sync on the shorter horizontal retrace (better: horizontal _enable_)
signal).
The alteration of the starting address is done by the code I already posted in
my first mail! (Its done by addressing the registers $C and $D of the
CRT-controller).
Note that reprogramming the starting address isn't restricted to mode X/Y, you
can have it in normal mode 13h, too: there are 65536 addresses available, but
only 64000 needed, thus giving a scroll range of 4.8 lines! And to complicate
things even further, for start addressing purposes, even the BIOS mode is
planed (that is, a row consists of 320/4 bytes only). Just for the case you
don't believe...
}
PROGRAM Scroll;
VAR
  CRTAddress,
  StatusReg   : WORD;
  a           : ARRAY[0..199, 0..319] OF BYTE ABSOLUTE $A000 : 0000;
  i, j        : WORD;

PROCEDURE SetAddress(ad : WORD); ASSEMBLER;
ASM
  MOV BX, ad

  MOV DX, StatusReg
  @WaitNotVSyncLoop:
    in   al, dx
    and  al, 8
    jnz  @WaitNotVSyncLoop
  @WaitVSyncLoop:
    in   al, dx
    and  al, 8
    jz   @WaitVSyncLoop

  MOV DX, CRTAddress
  MOV AL, $0D
  CLI
  OUT DX, AL
  INC DX
  MOV AL, BL
  OUT DX, AL
  DEC DX
  MOV AL, $0C
  OUT DX, AL
  INC DX
  MOV AL, BH
  OUT DX, AL
  STI
END;

BEGIN
  IF ODD(port[$3CC]) THEN
    CRTAddress := $3D4
  ELSE
    CRTAddress := $3B4;

  StatusReg := CRTAddress + 6;
  ASM
    MOV AX,13h
    INT 10h
  END;

  FOR i := 1 TO 1000 DO
   a[Random(200), Random(320)] := Random(256);

  {scroll horizontally by 4 pixels}
  FOR i := 1 TO 383 DO
    SetAddress(i);
  FOR i := 382 DOWNTO 0 DO
    SetAddress(i);

  {scroll vertically by 1 row}
  FOR j := 1 TO 20 DO
  BEGIN
    FOR i := 1 TO 4 DO
      SetAddress(i * 80);
    FOR i := 3 DOWNTO 0 DO
      SetAddress(i * 80)
  END;

  ASM {back to 80x25}
    MOV AX,3
    INT 10h
  END;

END.
{
> Your said you could specify how the memory can be layed out by the user,
> but I am in need of what each PORT does. I know you have to send
> different values to the port to program it, but I have no idea what each
> port reads.

There are incredibly much registers to program! For a good overview of most of
them, try to get your hands on a copy of VGADOC*.* by Finn Thoegersen
(jesperf@daimi.aau.dk) which covers programming a lot of SVGA's chipsets, too.

