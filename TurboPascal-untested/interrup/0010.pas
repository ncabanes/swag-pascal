{
JONATHAN WRIGHT

> A/D (analog to digital conversion).  Somehow I need to use the PC
> clock/timer to call my A/D sampling interrupt at various rates from
> several hundred Hz to several thousand Hz.

> Hook interrupt 1Ch and point it to your interrupt handler.  Use
> a counter in this procedure to count the number of interrupts or

This will not work correctly.  Using interrupt 1Ch as it is normally set up,
your interrupt routine will only be called 18 times a second (18.2, actually),
so you could get a maximum of 18.2 Hz.  If you wait until a counter in this
interrupt (incremented by 1 each time) reaches 1820, it will take 10 seconds!
It WON'T be 100 Hz.

In order to hook the timer interrupt at a rate above 18.2 Hz, you'll need to
revector int 08h (which calls int 1Ch anyway).  You'll have to set up a counter
in int 08h which makes sure that the ORIGINAL int 08h routine is still called
18.2 times a second.  The value for this counter will vary, depending on how
fast you set timer channel 0.  The system clock has a maximum resolution of
about 1.19318 Mhz and IRQ0 is normally called 1193180/65536 times per second.

Here's some code for changing the clock rate (sorry but it's ASM):
}
;*********************
; called by SetClockRate (which is Pascal callable)

ClkRate PROC NEAR

  push  ax
  mov   al,36h
  out   43h,al
  pop   ax
  out   40h,al  xchg  ah,al
  out   40h,al
  ret
ClkRate ENDP

;******************
; call this routine from TP as SetClockRate (Hz : WORD);
SetClockRate PROC FAR

Rate EQU word ptr [bp+06]
  push  bp
  mov   bp,sp
  cmp   rate,0
  je    SCR01

  mov   ax,65535
  xor   dx,dx
  mov   bx,rate
  div   bx
  jmp   SCR02

SCR01:
  xor   ax,ax

SCR02:
  call  ClkRate

  mov   sp,bp
  pop   bp
  ret   2

SetClockRate ENDP

I pulled these procedures from some OLD code which I may have inadvertenly
screwed up over time, but it looks o.k.
  Actually revectoring int 08h is a bit more complex - you MUST make sure the
old it 08 is called appropriately because it controls a number of system
functions and your PC WILL lock up if it's not called.  I recommend finding a
book to help with that part.
