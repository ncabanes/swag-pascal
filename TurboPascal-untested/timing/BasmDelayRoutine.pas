(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0036.PAS
  Description: Re: BASM delay routine
  Author: BRIAN PETERSEN
  Date: 02-21-96  21:03
*)

{
CC> does anyone have a good and accurate delay routine??
CC>
CC> the crt one doesn't work accurately when turbo is on, and the int 15h
CC> one doesn't work on xt's..does anyone have one that is NOT bios
CC> dependant.. }

procedure pause(hs:longint); assembler;
asm
  mov  es,seg0040
  mov  si,006ch
  mov  dx,word ptr es:[si+2]
  mov  ax,word ptr es:[si]
  add  ax,word ptr [hs]
  adc  dx,word ptr [hs+2]
  @@1:
  mov  bx,word ptr es:[si+2]
  cmp  word ptr es:[si+2],dx
  jl   @@1
  mov  cx,word ptr es:[si]
  cmp  word ptr es:[si],ax
  jl   @@1
end;


