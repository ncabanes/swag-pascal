(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0152.PAS
  Description: 32-Bit Registers
  Author: DUNCAN MURDOCH
  Date: 05-26-95  23:27
*)

{
>I read in the BP7 bug list that BP7 doesn't save the extended registers
>EAX through to EDX during an interrupt. Has anyone got the Inline code to
>do this for me? I don't know assembler, so your help would be
>appreciated.

You only need to do this if your program might change them, i.e. your ISR
uses longint calculations.  If that's the case, there are two approaches to
saving them.

From: dmurdoch@mast.queensu.ca (Duncan Murdoch)

1.  Faster and smaller, but uses 16 bytes of stack space:
}
 procedure PushEAXtoEDX;
 Inline(
  $66/                   {  db $66}
  $50/                   {  push ax}
  $66/                   {  db $66}
  $53/                   {  push bx}
  $66/                   {  db $66}
  $51/                   {  push cx}
  $66/                   {  db $66}
  $52);                  {  push dx}

 procedure PopEDXtoEAX;
 Inline(
  $66/                   {  db $66}
  $5A/                   {  pop dx}
  $66/                   {  db $66}
  $59/                   {  pop cx}
  $66/                   {  db $66}
  $5B/                   {  pop bx}
  $66/                   {  db $66}
  $58);                  {  pop ax}

{ 2.  Slightly slower and bigger, but only uses 8 bytes of stack space: }

  procedure PushHighWordEAXtoEDX;
  Inline(
  $66/                   {  db $66}
  $50/                   {  push ax}
  $58/                   {  pop ax}
  $66/                   {  db $66}
  $53/                   {  push bx}
  $5B/                   {  pop bx}
  $66/                   {  db $66}
  $51/                   {  push cx}
  $59/                   {  pop cx}
  $66/                   {  db $66}
  $52/                   {  push dx}
  $5A);                  {  pop dx}

  procedure PopHighWordEDXtoEAX;
  Inline(
  $52/                   {  push dx}
  $66/                   {  db $66}
  $5A/                   {  pop dx}
  $51/                   {  push cx}
  $66/                   {  db $66}
  $59/                   {  pop cx}
  $53/                   {  push bx}
  $66/                   {  db $66}
  $5B/                   {  pop bx}
  $50/                   {  push ax}
  $66/                   {  db $66}
  $58);                  {  pop ax}
{
(I used David Baldwin's INLINE assembler to get the opcodes.)

These are untested.  For tested ones, look at the source to TRASHDET,
included with the bug list.
}

