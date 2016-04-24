(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0044.PAS
  Description: Even more CMOS Info
  Author: GERHARD SKOLNIK
  Date: 05-26-95  23:00
*)

{
>I heard many times about people talking about CMOS password ?
>Is it a password that comes with the hardware ???
>
I'll try to make a long story short. One of the crucial parts of the PC
is the MC146818 RTC chip. Although this primarily is a real time clock,
it also contains 64 bytes of RAM, which conveniently are buffered by a
battery or an accu, so they keep the volatile info even when you turn
the PC off (at least as long the battery hasn't turned into fluid :-)
All the setup options of the BIOS are stored in those 64 bytes. Modern
BIOSes usually allow to have a password option set for either at every
booting or just when entering the setup. Below you find the standard CMOS
layout as it was defined by IBM. AMI, Phoenix and others have added some
options called "Advanced Setup" and used the bytes which are marked reserved
here. Somewhere in this reserved range the password gets stored.

Maybe there are PCs with some other RTC chip with more RAM, but at least
around here even the latest buys still carry this old but worthy chip.

From: skolnik@kapsch.co.at (Gerhard Skolnik)

+----------------------------------------------------------------------+
ª                       CMOS Storage Layout                      more  ª
+----------------------------------------------------------------------+

00H-0dH used by real-time clock
0eH     POST diagnostics status byte
0fH     shutdown status byte
10H     diskette drive type      -----+
11H     reserved                      ª
12H     hard disk drive type          ª
13H     reserved                      ª- checksum-protected
14H     equipment byte                ª   configuration record (10H-20H)
15H-16H Base memory size              ª
17H-18H extended memory above 1M      ª
19H     hard disk 1 type (if > 15)    ª
1aH     hard disk 2 type (if > 15)    ª
1bH-2dH reserved                 -----+
2eH-2fH storage for checksum of CMOS addresses 10H through 20H
30H-31H extended memory above 1M
32H     current century in BCD (eg, 19H)
33H     miscellaneous info.
34H-3fH reserved

+----------------+
ªUsing CMOS Data ª
+----------------+
To read a byte from CMOS, do an OUT 70H,addr; followed by IN 71H.
To write a byte to CMOS,  do an OUT 70H,addr; followed by OUT 71H,value.

Example: ;------- read what type of hard disk is installed
         mov     al,12H
         out     70H,al        ;select CMOS address 12H
         jmp     $+2           ;this forces a slight delay to settle things
         in      al,71H        ;AL now has drive type (0-15)
}

