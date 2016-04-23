===========================================================================
 BBS: Canada Remote Systems
Date: 07-11-93 (13:22)             Number: 30113
From: STEVE WIERENGA               Refer#: NONE
  To: TRAVIS GRIGGS                 Recvd: NO  
Subj: SPEAKER(OFF)                   Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
Hello Travis:

 >> { untested, but should work }
 >> {$M 1024,0,0}
 >> {$F+}
 >> uses DOS;
 >> Var
 >>   Old1C : Procedure;
 TG>
 >> Procedure SpeakerOff; Interrupt;
 >> Begin
 >>     ASM { no sound proc, removes need to use CRT unit in a TSR }
 >>       mov dx,061h
 >>       in al,dx
 >>       and al,11111100b
 >>       out dx,al
 >>       pushf
 >>     End;
 >>     Old1C;
 >> End;
 TG>
 >> Begin
 >>   GetIntVec ($1C,@Old1C);
 >>   SetIntVec ($1C,@SpeakerOff);
 >>   Keep(0);
 >> End.
 TG>
 TG> I'm trying to learn to write a TSR.  Could you explain every step and
 TG> why it's there?  Thanks...

I didn't write that code, actually.  I have never written a TSR and don't plan
to in the near future, so I suggest you ask one of the gurus here.

 >> --- FMail 0.90
 TG>
 TG> Fmail 0.94 is out.  You should get it.  It's much better...

I'm still with .90 because I can't afford to register .94 (.90 doesn't have a
registration) :-(.
Take Care, Steve
Shockwave Software Systems

--- FMail 0.90
 * Origin: The Programmer's Armpit... Home of Monsoon*Qomm! (1:2613/228.2)
===========================================================================
 BBS: Canada Remote Systems
Date: 07-10-93 (11:08)             Number: 30157
From: STEVEN TALLENT               Refer#: NONE
  To: NIELS LANGKILDE               Recvd: NO  
Subj: RE: SPEAKER(OFF)               Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 -=> Quoting Niels Langkilde to Everyone <=-

 NL> Is it possible to diable/enable the speaker output (alternatvly
 NL> redirect it) ?? If so, please help !

The only thing that can be done is disabling the speaker many times
a second to do it.  Here's some code that disables it 18 times a second,
but notably does NOT work with programs that shut down interrupts
during playback.

{$M 1024,0,0}
{$N-,S-,G+} { Use g- for 8088 systems, g+ for V20 and above }
PROGRAM NoSpeak;
USES Dos;
VAR OLDINT1C : Procedure;

PROCEDURE ShutOff; INTERRUPT;
BEGIN
  Port [97] := Port[97] and 253; {Turn off speaker}
  OldInt1C;
  end;

BEGIN
  GetIntVec($1C, @OldInt1C);
  SetIntVec($1C, @ShutOff);
  Keep(0);
  end.

Note this is a TSR, and I can't guarantee that it'll work right on
anyone's computer.

___ Blue Wave/QWK v2.12
--- Renegade v06-25 Beta
 * Origin: Pink's Place  (409)883-8344 735-3712 (1:3811/210)
