
-------------------------------------------------------------------------------
Message From 
-------------------------------------------------------------------------------
Group #2 - Fidonet
Conference #9 - Pascal
Message Date: 08-22-97 18:16:17

To:      Nathan Malyon
From:    Peter Louwen
Subject: Re: ASM Formula
-------------------------------------------------------------------------------

 -=> Quoting Nathan Malyon to All <=-

 NM> does anyone know how to after getting an answer from an 
 NM> Interrupt call (using ASM Command for TP)
 NM> figure out which flags are on/off like

 NM> bit 0 : on
 NM> bit 1 : off
 NM> bit 2 : off
 NM> bit 3 : on 
 NM> bit 4 : off
 NM> bit 5 : off
 NM> bit 6 : off
 NM> bit 7 : on 
 NM> 
 NM> from the actual number
 NM> 10010001b

First define some constants:

CONST Bit0 =   1;
      Bit1 =   2;
      Bit2 =   4;
      Bit3 =   8;
      Bit4 =  16;
      Bit5 =  32;
      Bit6 =  64;
      Bit7 = 128;

Now, if you want to see if, say, bit number two is set,  you do it like 
this:

in Pascal: IF YourVariable AND Bit2 <> 0 THEN { -- it's set }

in BASM  : ; assume the quantity of interest is in AH
           test ah, Bit2
           je @@Yes
           ; -- at this point, the bit is not set
           @@Yes:
           ; -- and here, it is

Peter

... "She's a gift." "Obviously you unwrapped her."  
--- EBO-BBS Diemen - NL
 * Origin: EBO-BBS Diemen (http://www.worldonline.nl/~biginski) (2:280/901)
