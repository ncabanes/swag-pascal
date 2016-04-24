(*
  Category: SWAG Title: ISR HANDLING ROUTINES
  Original name: 0005.PAS
  Description: ISRINFO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{ What is an ISR?? Are there several things you have to know to create
 one in Pascal?? Thanks.

        ISR stands For interrupt service routine (I think; Hey, I
        just remember the abbriveation) :) But what it does is
        changes an interrupt vector to the address of a routine
        of yours then, your routine calls the actual interrupt code.

        In the next message, I'll post some heavily commented code
        that is a time TSR, But what is a TSR? Just a resident
        ISR. (By the way, The TSR screws up Blue Wave when resident)

        ---=== Extremely simplified version of how an ISR works ===---

        Assuming you know what an interrupt is (You called it a hardware
        command) ... When you call an interrupt (TP: Intr, Asm: int) the
        CPU stops what its doing and calls up a routine at a certain
        memory address (Which is called the interrupt's vector). You
        can get the address of the routine by using GETinTVEC. Now
        if you have this code
}
          Uses Dos;
          Var
             the_inTERRUPT: Procedure;
          begin
             getintvec (--Interrupt num--, @the_inTERRUPT);
          end.
{
        it will store the vector of the interrupt into @the_interrupt
        (if you dont know what a Pointer is, go back to the manual and
        read the section on them)
        So, Everytime you call the_inTERRUPT it will actually call what
        ever interrupt you made the_interrupt point to. on the same
        note SETinTVEC (--int num--, @your_Routine) will set it where
        when ever you call that interrupt it will execute your routine.

        What the ISR does is gets the vector of the interrupt you
        want to 'Latch' onto, puts it into a Procedure (As shown
        above) then, Uses SETinTVEC to set the ISR routine inside
        that interrupt. The ISR routine then calls the Procedure
        that points to the old interrupt.
}
