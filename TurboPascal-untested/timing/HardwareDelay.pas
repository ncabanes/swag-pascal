(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0029.PAS
  Description: Hardware Delay
  Author: MAYNARD PHILBROOK
  Date: 05-26-95  23:08
*)

{
> Sometimes delay doesn't work in TP 7.0, I'm unsure what it's doing,
> but if I have like: delay(10) it will not delay for ten milliseconds..
> I don't have a sure fire way to reproduce this error, it just
> happens  whenever it wants to.

sounds like you mite be running under windoz ?
Delay will malfunction at times if a multitasker or you have
redirected some interrupts for background events.. like the iNT $08
for example..
I not sure how TP 7.0 does it but TP 6.0 uses a software loop..
you could use the timer 2 for a delay if you not use sound at the time.
if you use the PC speaker then poll timer 0..  it you leave timer 0 set
to its standard then its simple.
}

procedure HardWareDelay( Time :word); { time in Millisecs }
Var
 CompVar, LastReading:Word;
 Begin
   CompVar := (Time / 0.00000083);
 asm
  CLI;
  Mov AL, $36;
  out $43, AL;
  in AL , $40;
  Mov Byte Ptr LastReading, AL;
  In AL, $40;
  Mov Byte Ptr lastReading+1, AL;
 @L:
  CLI;
  Mov AL, $36;
  out $43, AL;
  in AL, $40;
  Mov BL, AL;
  in Al, $40;
  STI;
  Mov BH, Al;
  Mov AX, lastReading;
  Sub BX, AX;
  Cmp BX, CompVar
  Jb @l;
  Sti;
 End;
End;


