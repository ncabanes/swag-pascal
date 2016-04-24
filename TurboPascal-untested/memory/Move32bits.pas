(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0096.PAS
  Description: Move 32bits
  Author: PATRICK VAN OOSTERWIJCK
  Date: 08-30-96  09:35
*)

program move32_test;

USES Crt;

const count=1000;
var block1,block2:pointer;
    i,time:longint;
    timer:longint absolute $40:$6C;
    size:word;

procedure Move32(var source,dest;count:word);assembler;

asm
                PUSH    DS
                LDS     SI,source
                LES     DI,dest
                MOV     CX,count
                SHR     CX,1
                JNC     @@1
                MOVSB
@@1:            SHR     CX,1
                JNC     @@2
                MOVSW
@@2:            DB      66h
                REP     MOVSW
                POP     DS
end;

{ --- Mainprog --- }
begin

  clrScr;
  getmem(block1,65010);
  getmem(block2,65010);

  for size:=65000 to 65003 do
    begin

     writeln('Timing blocks of ',size,' bytes :');

     writeln('  Timing Move ...');
     time:=timer;
     for i:=1 to count do
       move(block1^,block2^,size);
     writeln('  Time for ',count,' Move''s   : ',(timer-time)/18.2:8:1,' s');

     writeln('  Timing Move32 ...');
     time:=timer;
     for i:=1 to count do
       move32(block1^,block2^,size);
     writeln('  Time for ',count,' Move32''s : ',(timer-time)/18.2:8:1,' s');

    end;

end.
{ -------------------------------------------------------- }

If you can't find anything wrong in it, test it !
Here are the results on a 486DX4-100 :

Timing blocks of 65000 bytes :
  Timing Move ...
  Time for 1000 Move's   :     11.0 s
  Timing Move32 ...
  Time for 1000 Move32's :      3.6 s
Timing blocks of 65001 bytes :
  Timing Move ...
  Time for 1000 Move's   :     11.0 s
  Timing Move32 ...
  Time for 1000 Move32's :      6.0 s
Timing blocks of 65002 bytes :
  Timing Move ...
  Time for 1000 Move's   :     11.0 s
  Timing Move32 ...
  Time for 1000 Move32's :      6.0 s
Timing blocks of 65003 bytes :
  Timing Move ...
  Time for 1000 Move's   :     11.0 s
  Timing Move32 ...
  Time for 1000 Move32's :      6.0 s

3 times faster on a 4 byte boundary and still almost twice as fast on other
addresses ! I think that's a nice score...
 EH> For REP MOVSD to work faster the values to be moved have to be on "32
bit" EH> addresses, that is: both SI and DI have to be a multiple of 4.
 EH> You didn't test for that and with the extra MOVSB and MOVSW it might well
 EH> be they are on a multiple of 4 + 1 or 3 (as the aligment of TP normally
is EH> on EVEN addresses).

You're right about that, maybe I'll work on it... some day. ;-)

 EH> Apart from that you didn't test for overlap (does the move partially
 EH> overwrite the bytes TO be moved, because then those bytes have to be
moved EH> first)

I hadn't tought about that. I'm not often moving overlapping blocks though.
Are you sure the TP Move checks for that ? (I mean, do you not only assume,
but have you tested it ? :-))
 EH> and you didn't set a direction flag so it just MIGHT be you're
 EH> moving the wrong bytes (mostly the direction flag IS upwards, but it just
 EH> might be downwards, which means you're moving the bytes BELOW "ds:si" to
 EH> "es:di").

The direction flag is assumed to be cleared in TP. Every procudere that
changes it, should clear it again. But it's not forbidden to do a CLD of
course...
 EH> A complete Move32 has to be much more complicated than this (and much
 EH> bigger, thus). Further Move is most often used to/from screen memory and
 EH> unless you got a PCI screen card 32-bits moves are not possible to screen
 EH> memory (the cpu will automatically do each 32-bit doubleword as 2 16-bits
 EH> words, as the bus is only 16 bits).

PCI (and VLB) are becoming more common today, so I don't see the problem...
I tested this with mapping the 2'nd block to $A000 in mode 13h. And I've found
these _strange_ results with a VLB card :
Timing blocks of 65000 bytes :
  Timing Move ...
  Time for 1000 Move's   :     10.7 s
  Timing Move32 ...
  Time for 1000 Move32's :      3.4 s
Timing blocks of 65001 bytes :
  Timing Move ...
  Time for 1000 Move's   :     10.7 s
  Timing Move32 ...
  Time for 1000 Move32's :      5.8 s
Timing blocks of 65002 bytes :
  Timing Move ...
  Time for 1000 Move's   :     10.6 s
  Timing Move32 ...
  Time for 1000 Move32's :      5.8 s
Timing blocks of 65003 bytes :
  Timing Move ...
  Time for 1000 Move's   :     10.6 s
  Timing Move32 ...
  Time for 1000 Move32's :      5.8 s

I always tought videoRAM was SLOWER than normal RAM ???
Do you have an explanation for this ?


