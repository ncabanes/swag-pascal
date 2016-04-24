(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0087.PAS
  Description: Fastest Pi Calculator Yet!
  Author: BJ�RN FELTEN
  Date: 11-26-94  05:00
*)

{
> Here are my results using a 33MHz 386.
> Pi v2                               Pi v3
> 100  places =  0.1 sec              100  places = 0.3 sec
> 1000 places = 11   sec              1000 places =  32 sec
> 2135 places = 48   sec              2135 places = 150 sec

 Not very impressive IMHO. Here's the result of the program following below
(on my 33MHz 486):
Digits(max 150.000):    100  Done! It took   0.00s.
Digits(max 150.000):   1000  Done! It took   0.27s.
Digits(max 150.000):  10000  Done! It took  28.35s.
Digits(max 150.000):  40000  Done! It took 462.25s.

   The two units used should come after this message. Uncomment several write-
commands to get a "fully" operational program rather than this benchmark
version. You then also can skip the Timer unit and the two commands from that
unit (TimerOn and TimerOff) to make the program much smaller (no float math
linked into the program).
   I didn't post my 386 version (which is more than 50% faster), since I'm
under the impression that many of you still are struggling with them ol'
fashion 286'es or worse... :)
}

program PiCalc;  { The fastest PI calculator you'll ever find... :) }

{ From bits and pieces picked up mainly from the FidoNet PASCAL echo }
{ Collected, optimized, unitized, etc. by Björn Felten @ 2:203:208 }
{ Public Domain  --  Nov 1994 }

{ SWAG Note: The HugeUtil in this unit is in the NUMBERS.SWG Packet
   - Kerry }

uses HugeUtil, Timer; { use Crt if you want fast printout on screen }
                      { don't if you want to be able to redirekt o/p }

var
    words, number   : longint;
    nin, link, pii, a239    : HugePtr;

procedure ArcCoTan(n : integer; var angle : Huge);
var n2, del, remain : integer;
    positive : boolean;

begin                               { corresp. integer operations }
  ZeroHuge(angle,words);            { angle := 0 }
  ZeroHuge(nin^,words);             { nin   := 0 }
  ZeroHuge(link^,words);            { link  := 0 }
  angle.dat[angle.len] := 1;        { angle := 1 }
  DivHuge(angle,n,angle,remain);    { angle := angle div n }
  n2 := n*n;                        { n2    := n * n }
  del := 1;                         { del   := 1 }
  positive := true;
  CopyHuge(angle,nin^);             { nin   := angle }
  repeat
    DivHuge(nin^,n2,nin^,remain);   { nin   := nin div n2 }
    inc(del, 2);                    { del   := del + 2 }
    positive := not positive;
    DivHuge(nin^,del,link^,remain); { link  := nin div del }
    if positive then
      AddHuge(angle,link^)          { angle := angle + link }
    else
      SubHuge(angle,link^);         { angle := angle - link }
{    write(#13,word(del)) } { uncomment to see that program is not dead }
  until (link^.len <= 1) and (link^.dat[1] = 0);
{  writeln}                 { ... and this too }
end; { ArcCoTan }

begin
{  writeln('Program to get Pi (',pi:1:17,'...) with large precision.'); }
  write('Digits(max 40.000): '); readln(number);
  words := round(number / 4.7) + 3; { appr. 4.7 digits in one word }
  write(number:6,#9);
  TimerOn;
  GetHuge(pii,  words+2);
  GetHuge(a239, words+2);
  GetHuge(link, words+2);
  GetHuge(nin,  words+2);
  ArcCoTan(5,   pii^);        { ATan(1/5)  }
  AddHuge(pii^, pii^);
  AddHuge(pii^, pii^);        { * 4        }
  ArcCoTan(239, a239^);       { ATan(1/239)}
  SubHuge(pii^, a239^);
  AddHuge(pii^, pii^);
  AddHuge(pii^, pii^);        { * 4        }
  TimerOff;
{  WriteHuge(pii^, number)}     { uncomment if you want printout }
end.


