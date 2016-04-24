(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0086.PAS
  Description: ASM Array Min/Max Finder
  Author: TERJE MATHISEN
  Date: 11-26-94  05:00
*)

{
>I need to find the minimum and maximum values in large arrays (~20,000
>points) of type word.  Looking for a faster way using TP7 (assembler?)
>to do it than:
>
>min := data^[1];
>max := data^[1];
>
>for i := 2 to num_points do
>begin
> data_value := data^[i];
> if data_value < min then min := data_value;
> if data_value > max then max := data_value;
>end;
>
Lets try some asm here:

From: terjem@hda.hydro.com (Terje Mathisen)
}

Procedure FindMinMax(var data; num_points : word; var min, max : word);
Assembler;
asm
  push ds
  lds si,[data]
  mov cx,[num_points]
  sub cx,1
   jc @done   {Empty array! }
  mov dx,[si] {Min value}
  lea si,[si+2] {Point at second table entry}
  mov bx,dx   {Max value}
   jz @store  {Single-entry array!}

@loop:
  mov ax,[si]
  add si,2
  cmp ax,dx
   jb @new_min
  cmp ax,bx
   ja @new_max
  dec cx
   jnz @loop
   jmp @store

@new_min:
  mov dx,ax   {Save new min value}
  dec cx
   jnz @loop
   jmp @store

@new_max:
  mov bx,ax   {Save new max value}
  dec cx
   jnz @loop

@store:       {Return the values found!}
  lds si,[min]
  mov [si],dx
  lds si,[max]
  mov [si],bx
@done:
  pop ds
end;

{
This was written from scratch, so no testing whatsoever!  It should be quite
well optimized for both 486 and Pentium-class machines, running in about 10
cycles/word on a 486, and just 4 cycles/word on a Pentium, since the
8 inner-loop instructions will pair perfectly.  With 20,000 points in your
array, this should correspond to 6ms on a 486-33, and less than a milli-
second on a Pentium-90.

The most important feature to note is that new extremal values will be quite
rare, averaging just O(log(n)) for a random n-element array.  That's why I
jump out of the loop to handle these cases, making the normal case much
faster.  With a worst-case, already sorted array, we will find a new max
value on each iteration, which will increase the running time to 12 cycles
on the 486, while the Pentium will stay constant at 4 cycles.

If the array is pre-sorted in reverse (declining) order, the 486 is back to
10 cycles, while the P5 is actually faster, at just 3 cycles/word.

I think the only way to improve on this code is by unrolling it, which will
save up to 4 cycles/word for the 486, and just a single P5 cycle.

PS. Make sure that your array is naturally aligned (16-bit word), if not it
will run a lot slower, esp. on a P5.
}

