(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0098.PAS
  Description: Programming the Keyboard
  Author: MARK OUELLET
  Date: 05-26-95  23:21
*)

(*
>>> procedure newkbdint; interrupt;   { new keyboard handler }
>>> begin
>>> keydown[port[$60] and $7f] := (port[$60] and $80) = $00;
>>> port[$20] := $20;
>>> end;
>>
>>> On the XT I tested that code on, it accepted the first keystroke but
>>> then acted like I never released the key or pressed another.
>>
>> I believe sending the EOI is insuficient. You also need to signify
>> the keyboard through port 61... But then again I might be wrong.

> What do you mean by "signify the keyboard through port 61h"?  Also, would
> that be specific to XTs?  I don't have problems with my 386, or my
> sister's, or a friend's, or another friend's 286 ...

Well I was hoping you might know what I was talking about ;-)

    It's just that I noticed you weren't calling the old interrupt routine and
I noticed most keyboard routines, including TP/BP's keyboard routine, seem to
interract with port $61. It might be some kind of handshaking between the
keyboard controller and the PC. Maybe it is specific to models prior to the AT
and that could be why you have problems with the XT only.

Here is what I found in HelpPc:

Ports 60-67 are linked to the 8255 (PPI) on PCs, XTs and Jr's
Ports 60-6F are linked to the 8042 on ATs and PS/2s

    Port 61 is Port B Status on 8255
            And System Control port on the 8042 (For compatibility with 8255)

So port 61 manipulation would be for XT compatibility reasons.

And here is more help from Tech Help


Port  Description
▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
060H  ■PC/XT■  PPI port A.  Read keyboard scan code:
      IN   al,60H  ;fetches most recent scan code.

061H  ■PC/XT■ PPI (Programmable Peripheral Interface) port B.
      ╓7┬6┬5┬4┬3┬2┬1┬0╖
      ║ │ │ │ │ │0│ │ ║
      ╙╥┴╥┴╥┴╥┴╥┴─┴╥┴╥╜ bit
       ║ ║ ║ ║ ║   ║ ╚═ 0: Timer 2 gate (speaker)  ═╦═ OR 03H=speaker ON
       ║ ║ ║ ║ ║   ╚═══ 1: Timer 2 data  ═══════════╝  AND 0fcH=speaker OFF
       ║ ║ ║ ║ ╚═══════ 3: 1=read high switches; 0=read low switches(see 62H)
       ║ ║ ║ ╚═════════ 4: 0=enable RAM parity checking; 1=disable
       ║ ║ ╚═══════════ 5: 0=enable I/O channel check
       ║ ╚═════════════ 6: 0=hold keyboard clock low
       ╚═══════════════ 7: 0=enable keyboard; 1=disable keyboard

062H  ■PC/XT■ PPI port C.
      ╓7┬6┬5┬4┬3┬2┬1┬0╖
      ║ │ │ │0│equip't║
      ╙╥┴╥┴╥┴─┴─┴─┴─┴─╜ bit
       ║ ║ ║   ╚═════╩═ 0-3: values of DIP switches.  See Equipment List
       ║ ║ ╚═══════════ 5: 1=Timer 2 channel out
       ║ ╚═════════════ 6: 1=I/O channel check
       ╚═══════════════ 7: 1=RAM parity check error occurred.

063H  ■PC/XT■ PPI Command/Mode Register.  Selects which PPI ports are input
      or output.  BIOS sets to 99H (Ports A and C are input, B is output).

With this and a look at BP 7's RTL source for the keyboard routines you should
be able to determine what's the problem.
*)
