(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0097.PAS
  Description: Locking the Keyboard
  Author: EMIL GILLIAM
  Date: 05-26-95  23:19
*)

{
> Who can give me a hand in reprogramming the keyboard. I am
> writing a TSR changing all the functions of the keys. Even
> allowing two (normal) keys to be pressed at the same time (=
> keydown, keydown, keyup, keyup -> result). Who is familiar with
> programming the keyboard, ports 60h & 64h, INT 9, keyboard
> buffers and all that sort of stuff? Or who can give information
> what INT 9 exactly does? Any kind of help is welcome.

   Locking out the keyboard simply by redirecting int 9 to an IRET won't
do it.  The reason is that at the end of every interrupt handler (for an
IRQ,  not for software-generated interrupts like int 21h  or  processor-
generated  interrupts like divide-by-zero int 0) you must send the  byte
20h to I/O port 20h.  You can do it with the instructions MOV AL,20h and
OUT  20h,AL.   What they do is send  a  "non-specific  end-of-interrupt"
(EOI) to the 8259 programmable interrupt controller chip.

   The 8259 chip (which on newer computers usually isn't a separate chip
but  part  of some chip that contains other things)  is  what  generates
IRQ's.  It's connected to all of the hardware devices that can  generate
interrupts  (except  for  memory parity error  which  is  another  thing
entirely, which doesn't even use IRQ's but is connected straight to  the
processor's  NMI  pin and generates interrupt 2).  When one of  its  IRQ
pins  (there's  one for each IRQ that can be generated)  goes  high,  it
figures  out  what the interrupt number is.  How does it know  what  the
interrupt  number is?  (to send to the processor on the data  bus  while
making  the processor's IRQ pin go high) When the computer is booted  up
the BIOS sends a setup command to the 8259 that tells it to add 8 to the
number of an IRQ line that goes high to get the interrupt number to send
to the processor.  (The keyboard is connected to the 8259's IRQ1 pin, so
that's why it generates interrupt 9.)

   However,  the  8259  is designed not to let  one  hardware  interrupt
interrupt  another hardware interrupt.  For example, if the computer  is
in  the middle of processing interrupt 8 (the timer tick)  and  keyboard
signals  an  interrupt  to the 8259, int 9 won't  be  called  until  the
interrupt  8 handler is done. How does the 8259 know when the  processor
is  executing an interrupt handler?  When an interrupt is generated  the
8259  assumes  that the interrupt handler is being  executed  until  the
software  sends it an end-of-interrupt command (sending the byte 20h  to
I/O port 20h), and the end-of-interrupt command lets other interrupts be
processed.

   What happens in your program is that when int 9 is generated, it just
IRETs,  so no further IRQs can be generated (timer tick or  keyboard  or
anything like that).  Even when the int 9 vector is stored, the program
mable  interrupt  controller won't allow an interrupt to  interrupt  the
processor.  (I think that's how it works, maybe it just don't let  other
IRQ1's  interrupt  the  processor while other IRQ's  can  interrupt  the
processor.)

  One workaround is to have your temporary int 9 handler look like this:

push ax                 ;Save AX
mov  al,20h             ;Send a non-specific EOI to the PIC (programmable
out  20h,al             ; interrupt controller) so that other interrupts
                        ; can be generated
pop  ax                 ;Restore AX
iret                    ;Return from the interrupt

HOWEVER...  (and I'm sorry if I've wasted your time up to this point...)
there's  a much easier way to disable the keyboard  without  revectoring
interrupt 9.

TO DISABLE THE KEYBOARD...    in  al,21h
                              or  al,00000010b
                              out 21h,al

TO ENABLE THE KEYBOARD...     in  al,21h
                              and al,11111101b
                              out 21h,al

I/O port 21h is the programmable interrupt controller's "mask" register.
It  controls  which  IRQ's the PIC will allow and  which  ones  it  will
ignore.  Bit 0 is for IRQ0, bit 1 is for IRQ1 (the keyboard), and so on.
Setting  a bit disables that IRQ, clearing it enables it.  When you  get
whatever's in port 21h and set bit 1 and write that back it will disable
the keyboard interrupt.


