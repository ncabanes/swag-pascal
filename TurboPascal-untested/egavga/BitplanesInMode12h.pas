(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0222.PAS
  Description: Bitplanes in Mode 12h
  Author: ARNE DE.BRUIJN
  Date: 05-26-95  23:24
*)

(*
> Anyone who can describe the use of bitplanes in mode 12h to me?

There are 4 bitplanes, each holding a bit of the color number. Each bit in a
plane is a pixel. The pixel at (0,0) is at offset 0, bit 7. Each line is 640
pixels=640 bits=80 bytes. So (0,1) is at offset 80, bit 7.
If you have a line from (2,0)-(6,0) (bits 00111110) in color 10, (1010), the
first byte of the bitplanes would look like this:
bit      76543210

Plane 0: 00000000
Plane 1: 00111110
Plane 2: 00000000
Plane 3: 00111110

Now, what whould happen if we put a white pixel at (0,0)?
Exactly. Bit 7 of all the planes becomes 1.

Now how to access the bitplanes. The VGA card has a 64k window at $A000:0, so
not enough for each (64k) plane. Here the ports come in use. All ports we need
are in the VGA card a sort of array. To access an element, you first send the
index, then the data, or send the index and read the data. For most ports the
data port is at the address of the index port +1.
Example:
The index port of the Graphics Controller (part of the VGA interface) is at
$3CE. The data port is at (index+1), so $3CF. If we want to write a 4 to index
2, we do: Port[$3CE]:=2; { index } Port[$3CF]:=4; { data }
But there is a way to do it with one Port[]. There's also a PortW[] 'array',
and if the addressed port isn't a 16-bit one, it sends the lo byte to
<address>, and the high byte to <address>+1. Just what we need. The example
becomes: PortW[$3CE]:=$0402; { index in low byte, data in high byte }

Back to the bitplanes. To select which bitplanes are accessed by memory writes
(not reads!), you can write to index 2 of the sequencer (at $3C4).
If we want to put the line in the first example (from (2,0)-(6,0), color 10),
we can do: 
 Port[$3C4]:=$0A02; { Index 2 of the sequencer: select bitplanes 1,3 }
 Mem[$A000:0]:=$3E;
But everything at (0,0),(1,0) and (7,0) will be destroied, and, worser, if
there was already something at, say (2,0), in bitplane 0 or 2 (the ones we
didn't select), the values remain there, creating some ugly color or so.

The VGA card has 4 internal 8 bit latches, one for each plane. If you do a
read, no matter what will be returned to the processor, these latches are
loaded with the bits from all planes, from the selected address. 

Also there're so called write modes. These are the way the VGA card interprets
the byte written to the VGA memory. You set the write mode with the Mode
register, index 5 from the Graphics Controller ($3CE).
There are four modes:

Write mode 0
The is the default mode. With the bitmask register, index 8 form the Graphics
Controller ($3CE), you can select the bits used from the byte, the other bits
are from the registers. Each byte you write will go to all bitplanes, unless
you put a 1 in the correspondening bit in the Enable Set/Reset register, index
1 at the Graphics Controller ($3CE). If you've put a 1 in that register, that
plane will have the bit of the correspondening bit in Set/Reset register, index
0 at $3CE, and the CPU byte doesn't matter.So if you put $F (all planes) in the
Enable Set/Reset register, the desired color in the Set/Reset register, and the
desired bits in the bitmask register, you can put pixels in that color,
preserving other pixels in that byte.Example (again the same line):
*)
 PortW[$3CE]:=$0005; { Index 5 of the Graph Contr., set write mode 0 }
 PortW[$3CE]:=$0F01; { Index 1 of the Graph Contr., Enable Set/Reset }
                     { for all planes }
 PortW[$3CE]:=$0A00; { Index 0 of the Graph Contr., set with color 10 }
 PortW[$3CE]:=$3E08; { Index 8 of the Graph Contr., set only bits 2-6 }
 Dummy:=Mem[$a000:0]; { Load latches }
 Mem[$a000:0]:=Dummy; { Byte doesn't matter }
(*
Write mode 1
Nothing is done with the registers or the CPU byte. All the latches are
directly copied to the addressed byte. Usefull for screen to screen copy (e.g.
scrolling)
Example to copy (0,0)-(7,0) to (8,0)-(15,0):
*)
 PortW[$3CE]:=$0105;  { Set write mode 1 }
 Dummy:=Mem[$a000:0]; { Load latches with pixels (0,0)-(7,0) }
 Mem[$a000:1]:=Dummy; { Write latches to pixel (8,0)-(15,0) }
(*
Write mode 2
The lower 4 bits of the CPU byte are the bits for each plane. If set for a
plane, all bits selected with the Bitmask register are set, if clear, they're
cleared.
So you can do the same as in the example from mode 0, but with fewer
instructions:
*)
 PortW[$3CE]:=$0205;  { Set write mode 2 }
 PortW[$3CE]:=$3E08;  { Select bits 2-6 }
 Mem[$a000:0]:=10;    { Set that bits to color 10 }
(*
Write mode 3
If a bit from the CPU byte is set, that bit will get the color in the Set/Reset
register (index 0, $3CE), otherwise value from the latches is taken.
I find this mode the most usefull for drawing lines, circles etc. where the
bitmask changes, but the color not. Again the same line:
*)
 PortW[$3CE]:=$0305;  { Set write mode 3 }
 PortW[$3CE]:=$0A00;  { Set color 10 }
 Mem[$a000:0]:=$3E;   { Set bits 2-6 }
(*
There's also a Function Select register (index 3, $3CE).
bits 3,4 indicate the way the bits that you want to change (selected by Bitmask
register (write mode 0,2) or CPU byte (write mode 3)) are modified.
00 Not modified
01 ANDed with latches
02 ORed with latches
03 XOR with latches
For write mode 0 and 3 bits 0-2 indicate how many times the bits you want to
change are shifted to right. Bits rolling out the byte appear on the left.

There are two read modes, for the byte returned to the CPU on a memory read.
You select them with the same register as the write modes (index 5, $3CE), but
in bit 3.

Read mode 0:
The byte from the plane selected with the Read Map Select register (index 4,
$3CE) is returned

Read mode 1:
Each bit in the CPU byte is set if the color in the Color Compare register
(index 2, $3CE) is equal to the color of the corresponending bit.
To exclude a bit of the color value, clear that bit the in Color Don't care
register (index 7, $3CE), if set that bit from the color will be used.
*)


