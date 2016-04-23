===========================================================================
 BBS: Canada Remote Systems
Date: 06-15-93 (09:40)             Number: 26422
From: CHRIS JANTZEN                Refer#: NONE
  To: JANOS SZAMOSFALVI             Recvd: NO  
Subj: Re: No print screen            Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
On Sunday June 13 1993, Janos Szamosfalvi wrote to All:

 JS> PROGRAM NoPrintScreen;

 JS> PROCEDURE Null; Interrupt;
 JS> BEGIN
 JS> END;

 JS> BEGIN
 JS>   SetIntvec($05, @Null);
 JS>   Keep(1);
 JS> END.

 JS> I have several questions about this code:
 JS>   a) when it comes to reloading COMMAND.COM, my computer hangs
 JS>      with memory allocation error when the above program is in
 JS>      memory.
 JS>      Any idea why?

An easy one: You forgot to tell the compiler how much memory your program
wants. Put the following directive at the beginning of your program:

{$M 1024,0,0}
PROGRAM NoPrintScreen;
[...]

That little "{$M" tells the compiler to tell DOS that you don't want a lot of
RAM when loaded. Otherwise, your application will allocate (and Keep) all
available RAM in the system (effectively making your program a 640K TSR!).

 JS>   b) can anyone tell me how to modify this so PrintScren
 JS>      would be the second Esc key?

Ah, that would be a bit trickier.... You'd need to trap Int 9 using some
assembly code (but my brain is mush right now, so I'll let someone else help
you on that).

Chris KB7RNL =->

--- GoldED 2.41
 * Origin: SlugPoint * Home to fine silly people everywhere (1:356/18.2)
