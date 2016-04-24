(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0068.PAS
  Description: Prime Numbers
  Author: RUUD KUCHLER
  Date: 05-26-94  06:18
*)

{
JT>Does anyone know of anyway to code a prime number generator??  I've had
JT>some ideas, but none so far that have worked... I am just learning Pascal
JT>right now, so I do need some help... Any would be appreciated because
JT>this is for a class assignment!!  ThankX

Try this:

------ take scissors and cut here :-)  ------------------------ }

program priem;

{Program creates prime numbers.

Working of the program:
- an array is created where found prime numbers are stored.
Checking whether a number is prime:
- the number is checked with the previously found prime number
if it is prime
- if it is prime it is stored in the array and printed}

const
maxpriems=10000;

type
priemarrtype=array[1..maxpriems] of longint; {array to store primes}

var
priemarr: priemarrtype;
nrofpriem: word;
number, divider: longint;
isapriemnumber: boolean;

begin {priem}
number:=1;
nrofpriem:=0; {number of prime numbers already found}
while(nrofpriem<maxpriems) do
begin
inc(number);
isapriemnumber:=true;
divider:=1;
while (isapriemnumber) and (divider<=nrofpriem) do
begin
if (number mod priemarr[divider]=0)
{calculate "remains" of division}
then isapriemnumber:=false {no prime}
else inc(divider) {get next prime}
end; { not (isapriemnumber) or (divider>nrofpriem) }
if (isapriemnumber) then
begin {a prime number is found}
inc(nrofpriem);
priemarr[nrofpriem]:=number; {store it in the array}
writeln('prime number ',nrofpriem:5,' found is:
',priemarr[nrofpriem]:8)
end
end; { nrofpriem>=maxpriems }
end. {priem}


