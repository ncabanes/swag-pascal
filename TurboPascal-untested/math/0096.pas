{
Fibonacci for longints and comps, GCD for longint, plus LCM


Jud McCranie
jud.mccranie@camcat.com

================================================
}
function Fibonacci( n : word) : longint;

{ Fibonacci numbers, by Jud McCranie. }

var i   : word;
    f1, f2, fib : longint;

begin { ----- fibonacci ----- }

if n > 46 then
begin
  writeln( 'In Fibonicci - N is too large for a longint');
  halt;
end;

fib := 1;
f1  := 1;
f2  := 1;

for i := 3 to n do
begin
  fib := f1 + f2;
  f2  := f1;
  f1  := fib;
end;

Fibonacci := fib;

end; { ----- fibonacci ----- }



function FibonacciComp( n : word) : comp;

{ Fibonacci numbers, by Jud McCranie. }

var i   : word;
    f1, f2, fib : comp;

begin { ----- fibonacci comp ----- }

if n > 92 then
begin
  writeln( 'In Fibonicci - N is too large for a comp');
  halt;
end;

fib := 1.0;
f1  := 1.0;
f2  := 1.0;

for i := 3 to n do
begin
  fib := f1 + f2;
  f2  := f1;
  f1  := fib;
end;

FibonacciComp := fib;

end; { ----- fibonacci comp ----- }


-------------------------------------------------

function GCD( u, v : LongInt) : LongInt;

{ Greatest Common Divisor, by Jud McCranie }

var t : LongInt;

begin { --- gcd --- }

while v <> 0 do
begin
  t := u mod v;
  u := v;
  v := t;
end;

GCD := u;

end; { --- GCD --- }



function LCM( x, y : LongInt) : LongInt;

{ Least Common Multiple, by Jud McCranie }

begin { --- lcm --- }

LCM := (x div GCD( x, y)) * y;

end; { --- LCM --- }





Jud McCranie

 * Silver Xpress V4.02B03P SW20178

