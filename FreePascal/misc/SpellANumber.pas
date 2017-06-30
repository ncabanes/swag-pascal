(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0082.PAS
  Description: Spell a Number
  Author: MIKE COPELAND
  Date: 01-27-94  17:36
*)

{
From: MIKE COPELAND
Subj: Spell a Number
---------------------------------------------------------------------------
>>       I'm in the process of writing a Checkbook program for my Job
>>       and I was wondering if anyone out there has a routine to
>>     convert a check amount written in numerical to text.  Here's an
>>     example of what I need. Input Variable :  142.50
>>    Needed Output  : One Hundred Forty Two 50/100--------------------

   What you're looking for is "spell-a-number", and here's a program
which does it.  Note that this one operates only on integer-type data,
and you'll have to modify it for the decimal part - but that's the
easiest task...  If you have questions, just post them here.
}
program Spell_A_Number;                     { MRCopeland 901105 }
USES CRT;
const C_ONES : array[1..9] of string[6] = ('one ','two ','three ','four ',
                              'five ','six ','seven ','eight ','nine ');
      C_TEEN : array[0..9] of string[10] = ('ten ','eleven ','twelve ',
                              'thirteen ','fourteen ','fifteen ',
                              'sixteen ','seventeen ','eighteen',
                              'nineteen');
      C_TENS : array[2..9] of string[8] = ('twenty ','thirty ','forty ',
                              'fifty ','sixty ','seventy ','eighty ',
                              'ninety ');
var   I,J  : LongInt;                             { global data }

procedure HUNS (N : LongInt);           { process a 0-999 value }
var P : integer;                          { local work variable }
begin
  P := N div 100; N := N mod 100;                { any 100-900? }
  if P > 0 then
    write (C_ONES[P],'hundred ');
  P := N div 10;  N := N mod 10;                        { 10-90 }
  if P > 1 then                                         { 20-90 }
    write (C_TENS[P])
  else
    if P = 1 then                                       { 10-19 }
      write (C_TEEN[N]);
  if (P <> 1) and (N > 0) then        { remainder of 1-9, 20-99 }
    write (C_ONES[N]);
end;  { HUNS }

begin  { MAIN LINE }
  ClrScr;
  write ('Enter a value> '); readln (I);
  if I > 0 then
    begin
      J := I div 1000000; I := I mod 1000000;
      if J > 0 then                          { process millions }
        begin
          HUNS (J); write ('million ')
        end;
      J := I div 1000; I := I mod 1000;
      if J > 0 then                         { process thousands }
        begin
          HUNS (J); write ('thousand ')
        end;
      HUNS (I)                        { process 0-999 remainder }
    end                                                    { if }
end.

