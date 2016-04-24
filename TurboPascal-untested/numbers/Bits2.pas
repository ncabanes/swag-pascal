(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0002.PAS
  Description: BITS2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
ROB GREEN

> What if I want to just access a bit?  Say I have a Byte, to store
> Various access levels (if it does/doesn't have this, that, or the
> other).  How can I
> 1)  Access, say, bit 4?
> 2)  Give, say, bit 4, a value of 1?

Heres a Procedure i wrote to handle all that.  if you need speed, then
i suggest to manually check each bit, rather than use the Procedures.

(these Procedures are based on 1, not 0.  thus each Byte is like so:
87654321   instead of 76543210.  to change to 0 base, change the Array to
[0..31] instead of [1..32].)

to set a bit: (b is an Integer Type, BIT is which bit to set
   b:=b or BIT;   ex: b:=b or 128  (set bit 8)

to clear a bit:
   b:=b and not BIT;  ex:b:=b and not 8;  (clears bit 4)

to check a bit:
   if b and BIT<>0 then..  ex:if b and 64 then..  (check bit 7)
}

Const
{ Used to convert the Bit value to the actual corresponding number }
   bit : Array[1..32] of LongInt =
       (1, 2, 4, 8, $10, $20, $40, $80, $100, $200, $400, $800, $1000, $2000,
        $4000, $8000, $10000, $20000, $40000, $80000, $100000, $200000,
        $400000, $800000, $1000000, $2000000, $4000000, $8000000, $10000000,
        $20000000, $40000000, $80000000);

{b is which bit to set(1-32), size is the size of temp.
Use  SIZEOF(TEMP) to get the value, and temp is the actuall Integer based
number
returns True if bit set, False if not}

Function checkbit(b : Byte; size : Byte; Var temp) : Boolean; {1-32}
Var
  c : Boolean;
begin
   c:=False;
   Case size of
     1 : c := Byte(temp) and bit[b] <> 0;     {Byte,shortint}
     2 : c := Word(temp) and bit[b] <> 0;     {Word,Integer}
     4 : c := LongInt(temp) and bit[b] <> 0;  {LongInt}
     else
       Writeln('Invalid size');
   end;
   checkbit := c;
end;

{b,size,and temp same as above.  if onoff =True the bit will be set,
else the bit will be cleared}

Procedure setbit(b : Byte; onoff : Boolean; size : Byte; Var temp); {1-32}
begin
   if onoff then
   Case size of
     1 : Byte(temp) := Byte(temp) or bit[b];        {Byte}
     2 : Word(temp) := Word(temp) or bit[b];        {Word}
     4 : LongInt(temp) := LongInt(Temp) or bit[b];  {LongInt}
     else
       Writeln('Invalid size');
   end
   else
   Case size of
     1 : Byte(temp) := Byte(temp) and not bit[b];   {Byte}
     2 : Word(temp) := Word(temp) and not bit[b];   {Word}
     4 : LongInt(temp) := LongInt(Temp) and not bit[b];{LongInt}
     else
       Writeln('Invalid size');
   end;
end;

{this is a sample test Program i wrote For you to see how to use the
stuff above}

Var
  i : LongInt;
  j : Byte;
begin
   i := 0;
   setbit(4,True,sizeof(i),i);  {8}
   Writeln(i);
   setbit(9,True,sizeof(i),i);  {256+8 = 264}
   Writeln(i);
   setbit(9,False,sizeof(i),i); {8}
   Writeln(i);
   setbit(20,True,sizeof(i),i); { $80000+8 = $80008}
   Writeln(i);
   For i := 65550 to 65575 do
   begin
     Write(i : 8, ' = ');
     For j := 32 downto 1 do {to print right}
       if checkbit(j, sizeof(i), i) then
         Write('1')
       else
         Write('0');
     Writeln;
   end;
end.

