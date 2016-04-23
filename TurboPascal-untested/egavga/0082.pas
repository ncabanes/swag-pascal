{
How does Norton defeat the one vertical scan line dividing its
characters in order to write their alphanumeric menu screens?  I have a
"user-font" which loads successfully into vga display memory using tp7:
}
type
  bytearray = array[0..maxbytes] of byte;
var
  fontarray : bytearray;  { character byte array }
procedure wrfont(input : bytearray; blknum, numline : byte);  assembler;
{ "input" is an array containing character bit patterns (8x16 character)
  "blknum" is the block number
  "numline" is the number of scanlines per character }
  asm
    push    bp            { save the base point register }
    mov     bl, blknum    { get block number }
    and     bl, 07        { limit to 0-7 block number }
    les     ax, input     { point to "C" buffer es:ax }
    mov     bh, numline   { number of bytes per characters }
    mov     bp, ax        { load offset to "C" buffer es:bp }
    mov     cx, 100h      { do for 256 characters }
    xor     dx, dx        { begin at 0 }
    mov     ax, 1110h     { load font }
    int     10h           { call interrupt }
    pop     bp            { restore the base point register }
  end;
{
    This procedure loads my user-font correctly into display memory;
however, I still have one verical scanline between my horizontal line
characters making them basically worthless for my purposes (it "draws"
a dashed line like above).  I thought when alphanumeric characters are
mapped, you need to leave a bit pattern open along the right and bottom
edges in order to separate the characters.  Closing up the right and
bottom edges should "connect" the characters, yet I've found it does
not.  I have tried replacing the original ASCII horizontal line
characters and this also fails.
    What information do I need?  How can I connect my font characters
to display Norton-like menus in alphanumeric 8x16 vga font format (or
for that matter, any two primitive graphic fonts)?  Does it make any
difference with which ASCII characters I replace in my table?
    By the way, I noticed that Norton's alternate font does have a
small (anal retentively) defect.  Their upper right box characters
do not have a "crisp" corner.  Each one has a pixel "nub" to the right.
I have a feeling this is a clue to answer my problem but I still
haven't gotten it right.  Anyone know?
}