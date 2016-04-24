(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0052.PAS
  Description: Real Calculations
  Author: SEAN PALMER
  Date: 01-27-94  11:45
*)

{
>How about using fixed point math to speed things up even more - not
>everyone has a math coproccesor (either my routines suck, or REAL
>calculations aren't fast, BTW I got most of my routines from Flights of
>Fantasy).

> Well, its a combination, from my experience of flights of
> fantasy, I'd say that it really isn't too speedy.  But then REAL
> calculations are not notoriously quick either.  I think FOF is a Good
> resource, it teaches 3d fundamentals well, and in general is pretty
> nice, but the code is a little slow...  What I ended up doing is
> reading through the book and writing from what they said. (for the most
> part I skipped their code bits..)  I am not familiar with fixed point
> math... I know what it is, but don't know how to implement it... Could
> ya help a little?

Just (in this implementation) a longint, with the high 16 bits representing the
integer part, and the low 16 representing the binary fraction (to 16 binary
places). Basically a 32-bit binary number with the binary point fixed at the
16th position.

Adding and subtracting such numbers is just like working with straight
longints. No problem. But when multiplying and dividing the number must be
shifted so the binary point's still in the right place.

These are inline procedures, for speed, and only work on 386 or better,
to save me headaches while coding this sucker.
}

type
  fixed = record
  case byte of
    0 : (f : word;
         i : integer);
    1 : (l : longint);
  end;

{typecast parms to longint, result to fixed}
function fixedDiv(d1, d2 : longint) : longint;
inline(
  $66/$59/               {pop ecx}
  $58/                   {pop ax}
  $5A/                   {pop dx}
  $66/$0F/$BF/$D2/       {movsx edx,dx}
  $66/$C1/$E0/$10/       {shl eax,16}
  $66/$F7/$F9/           {idiv ecx}
  $66/$0F/$A4/$C2/$10);  {shld edx,eax,16}   {no rounding}

{typecast parms to longint, result to fixed}
function fixedMul(d1, d2 : longint) : longint;
inline(
  $66/$59/               {pop ecx}
  $66/$58/               {pop eax}
  $66/$F7/$E9/           {imul ecx}
  $66/$C1/$E8/$10);      {shr eax,16}

function scaleFixed(i, m, d : longint) : longint;
inline(  {mul, then div, no ovfl}
  $66/$5B/               {pop ebx}
  $66/$59/               {pop ecx}
  $66/$58/               {pop eax}
  $66/$F7/$E9/           {imul ecx}
  $66/$F7/$FB/           {idiv ebx}
  $66/$0F/$A4/$C2/$10);  {shld edx,eax,16}

var
  a, b : fixed;

begin
  a.l := $30000;
  outputFixed(a.l + fixedDiv(a.l, $20000));
  b.l := fixedMul(a.l, $48000);
  outputFixed(b.l);
  outputFixed(fixedDiv(b.l, $60000 + a.l));
  outputFixed(scaleFixed($30000, $48000, $60000));
end.

I'll let you figure out outputFixed for yourself.

