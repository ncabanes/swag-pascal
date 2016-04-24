(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0029.PAS
  Description: Another READKEY in ASM
  Author: YVAN RIVARD
  Date: 07-16-93  06:10
*)

===========================================================================
 BBS: The Beta Connection
Date: 06-20-93 (12:25)             Number: 1081
From: YVAN RIVARD                  Refer#: 984
  To: BOB GIBSON                    Recvd: NO  
Subj: console I/O                    Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
BG> You know, since I wrote my own unit to replace CRT, you'd think I'd know
BG> something like that!
BG> Which brings up a question...my unit uses direct video writes, and
BG> (supposedly) so does TP unless you tell it otherwise.  So why does my
BG> unit do a screen faster than TP's units?  Not as much overhead?

You made your own 'Crt'? I'd like some help!
The only thing I haven't been able to do so far is the stupid KeyPressed...
I have successfully made a really good ReadKey (return a String [2], so I can
even read arrows, Functions keys (even F11 and F12))

Here's my ReadKey (I case anybody would like to have it),
but I you could help me with the KeyPressed...
(Byt the way, does your 'direct video' is made like this?
 Type
    VideoChar = Record
                   Ascii : Char;
                   Color : Byte;
                end;
    Var
       VideoRam : Array [1..25,1..80] of VideoChar Absolute $B800:0000; )

Here's my 'ReadKey':

Function Inkey : String;
   Var
      K : Word;
      T : String [2];
   Begin
      Asm
         mov  ah, 10h
         int  16h
         mov  K, ax
      end;
      T := '';
      If ((K and 255) = 0) or ((K and 255) = 224) then
         T := ' '+ Chr (Trunc ((K and 65280) / 256))
      else
         T := Chr (K and 255);
      Inkey := T;
   End;

So what about a 'KeyPressed' ?

Thanks 'n bye
---
 * Info Tech BBS 819-375-3532
 * PostLink(tm) v1.06  ITECH (#535) : RelayNet(tm)

