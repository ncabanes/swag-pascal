(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0032.PAS
  Description: Arrays in BASM
  Author: LEON DEBOER
  Date: 11-26-94  05:04
*)

{
ldeboer@cougar.multiline.com.au (Leon DeBoer)

{
:  At first I had a problem with tp7's inline assemble: I had an
: array[0..4] of word in my unit, and I wanted to access it's elements
: from inline assemble. I got it working like this

  Try
}

Asm
  MOV AX, SEG MyArray;   { Segment of array }
  MOV DS, AX;
  MOV SI, OFFSET MyArray;
  MOV AX, DS:[SI]+0;     {Element 0 in array }
  MOV AX, DS:[SI]+2;     { Element 1 in array etc }
End;



{
  Note from SWAG Team:

    From now on, all ASM/TASM/BASM Specific info (that don't fit in any
    other category), will be placed in FAQ.SWG instead of MISC.FAQ

  - Kerry
}
