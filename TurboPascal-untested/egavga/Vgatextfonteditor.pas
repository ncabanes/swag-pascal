(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0128.PAS
  Description: VGA-TEXT-FONT-EDITOR
  Author: LEW ROMNEY
  Date: 08-24-94  17:53
*)

{
DL> When i redefine a character as "─", i don't get a smooth line, but one
DL> pixel left blank between every character, so "---" instead of "───".

With EGA, everything used to be so simple: all characters are 8x16 bits.

With VGA, there's an odd difference; you'll love this story.  Somebody in
IBM once said, "Why not do our share in making this universe a complete
chaos, and thus implement an infuriating and highly illogical technological
mess in this new system we're calling VGA?"  Of course.  The brilliant new
invetion, ladies and germs, was the 9th vertical line.  It's all gone into
the history books by now; it tooks months and truckloads of money just to
think it up but as always, IBM succeeded.

Now, all characters in the VGA font set are 8 bits, or pixels, wide.
Except for 24 characters, 192 through 216 in ASCII.  These characters have
an additional vertical line; no problem.  The truly ingenious touch (as the
lesser-known Harry Stottle of the celebrated IBM Vertical Line Team said,
"Eureka!") is how this addition line is actually a copy of the 8th.

Ie., to make a horizontal line ('─'), use any of the characters 192-216 and
activate 8 bits from left to right.  The 8th bit is copied to the 9th, and
you've got a horizontal line.

And here the tale endeth.  Almost.  For it leaves to each hapless
programmer to figure this out and now I told you.  Pass the tale on as the
last oral tradition of the cybernetic age.

Lest we forget.

DL>      1 2 3 4 5 6 7 8    I believe the way to get this right, is to
DL>     ┌─┬─┬─┬─┬─┬─┬─┬─┐   repeat column 8 (x).
DL>    1│ │ │ │ │ │ │ │x│   However, i don't know how to do this...
DL>    2│ │ │ │ │ │ │ │x│
DL>    3│ │ │ │ │ │ │ │x│
DL>    4│ │ │ │ │ │ │ │x│
DL>     : : : : : : : : :
DL>   15│ │ │ │ │ │ │ │x│
DL>   16│ │ │ │ │ │ │ │x│   Please help,
DL>     └─┴─┴─┴─┴─┴─┴─┴─┘   Dirk Loeckx. [@]

Don't forget, too: use IN/OUT or Port/PortW to program the video card.  If
you use the BIOS routines, you'll generate flicker (even on a VGA card) and
stress that poor old card.  In case you missed those routines in SWAG, here
are my versions:

        procedure PutFontC (C : Char; var Data);
          {-Define font character bitmap}
        begin
          inline($FA);
          PortW[$3C4]:=$0402;
          PortW[$3C4]:=$0704;
          PortW[$3CE]:=$0204;
          PortW[$3CE]:=$0005;
          PortW[$3CE]:=$0006;
          Move(Data, Mem[SegA000:Byte(C) * 32], 16);
          PortW[$3C4]:=$0302;
          PortW[$3C4]:=$0304;
          PortW[$3CE]:=$0004;
          PortW[$3CE]:=$1005;
          PortW[$3CE]:=$0E06;
          inline($FB);
        end;

        procedure GetFontC (C : Char; var Data);
          {-Retrieve font character bitmap}
        begin
          inline($FA);
          PortW[$3C4]:=$0402;
          PortW[$3C4]:=$0704;
          PortW[$3CE]:=$0204;
          PortW[$3CE]:=$0005;
          PortW[$3CE]:=$0006;
          Move(Mem[SegA000:Byte(C) * 32], Data, 16);
          PortW[$3C4]:=$0302;
          PortW[$3C4]:=$0304;
          PortW[$3CE]:=$0004;
          PortW[$3CE]:=$1005;
          PortW[$3CE]:=$0E06;
          inline($FB);
        end;

(If you are using TP versions earlier than 7.0, replace "SegA000" with
"$A000"... but you knew that.)

                    ttyl, Lew.
                    lew.romney@thcave.bbs.no

