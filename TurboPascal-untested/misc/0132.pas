
{ Updated MISC.SWG on May 26, 1995 }

{
From: dmurdoch@mast.queensu.ca (Duncan Murdoch)

>How can I access double-dimentional arrays in Pascal using asm?  My array
>is declared like this: var myarray:array[0..5] of array[0..5] of byte.

You need to do the addressing yourself.  For example, to load myarray[i,j]
into AH, do the following:
}
  mov ax, i
  mov bx, 6     { The size of a row of your array }
  mul bx        { Now ax holds the offset to element myarray[i,0] }
  add ax,j      { now it holds the offset to element myarray[i,j] }
  mov bx,ax     { Put the offset in BX. }
  mov ah,myarray[bx]  { Load the byte at the calculated offset }
{
This is untested, but it looks okay to me...
}
