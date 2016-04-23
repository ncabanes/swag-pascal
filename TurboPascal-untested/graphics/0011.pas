{
WILBERT VAN LEIJEN

> I am looking for a way to get an Image into a pointer (besides arrays)
> and write it to my disk. I am using arrays right now, and works fine, but
> When  I get big images I run out of mem fast...  :: IBUF : array [1..30000]
> of byte; getimage(x1,y1,x2,y2,IBUF); repeat Write(f,IBUF[NUM]); num:=num+1;
> until num=sizeof(ibuf);
> This works as long as I dont try to grab a large image.

These "large images" are in fact stored in "planes", chunks of up to 64 kByte
in size. You must understand the VGA architecture to store these in a file.
The only VGA video mode that keeps all data (from the programmer's point of
view) into a single data space is mode 13h (320x200 with 256 colours): a simple
array [1..200, 1..320] of Byte.  The other video modes require you to access
the VGA hardware: take for example 640x480 by 16 colours: 4 planes of 38,400
bytes (Red, Green, Blue and Intensity).  Together with the colour information
as returned by BIOS call INT 10h/AX=1012h they make up the picture.

Here's how you select a plane:
}

Procedure SwitchBitplane(plane : Byte); Assembler;

ASM
  MOV   DX, 3C4h
  MOV   AL, 2
  OUT   DX, AL
  INC   DX
  MOV   AL, plane
  OUT   DX, AL
end;

{
Assume the video mode to be 12h (640x480/16 colours), BitplaneSize = 38400, and
Bitplane is an Array[0..3] of pointer to an array [1..38400] of Byte:
}
      For i := 0 to 3 Do
        Begin
          SwitchBitplane(1 shl i);
          Move(Bitplane[i]^, Ptr($A000, $0000)^, BitplaneSize);
        end;
{
This is a snippet of code lifted from my VGAGRAB package; a TSR that dumps
graphic information (any standard VGA mode) to a disk file by pressing
<PrtScr>, plus a few demo programs written in TP - with source code.  Available
on FTP sites.
}
