(*
>>This is not so. The period of Borland's generator is 2^32, i.e.,
>>4.3 billion. The linear recurrence is randseed :=
>>randseed*134775813+1 {mod 2^32}; (the mod is implemented by
>>letting the calculation overflow). A  recurrence of the form ax+c
>>mod 2^e has maximum period when c is odd and (a mod 4) is 1.
>>Borland's formula satisfies those conditions, so it will output a
>>permutation of the range 0 to 2^32-1 before the sequence repeats.

>you have the conditions wrong. the factor 2^e has to be prime and a
>has to be a primitive element modulo the factor before you get
>maximum period. 2^e is most definitely not prime. the generator
>happens to have much less than maximum period. the other
>relationship that a and m must have is that a^2 < m. this is also
>violated in the Borland formula.

Here's an easy counter-example: x := (x*5+1) mod 2^3 yields the maximum 
period repeating sequence 0,1,6,7,4,5,2,3. The modulus m = 2^3 = 8 is 
not prime and 5^2 = 25 is larger than 8.

I quote Knuth's 'The Art of Computer Programming', vol.2:
 (exercise 2 of section 3.2.1.2, p.20)
   Are the following two conditions sufficient to guarantee the
   maximum length period, when m = 2^e is a power of 2?
   "(i) c is odd; (ii) a mod 4 = 1."
 (answer, p.458)
   Yes, these conditions imply the conditions in Theorem A, since
   the only prime divisor of 2^e is 2, and any odd number is rela-
   tively prime to 2^e. (In fact, the conditions of the exercise
   are necessary and sufficient, if e <> 2.)
 (Theorem A referred to above, p.15)
   The linear congruential sequence has a period of length m if and
   only if
      i) c is relatively prime to m;
     ii) b = a-1 is a multiple of p, for every prime p dividing m;
    iii) b is a multiple of 4, if m is a multiple of 4.

If you don't believe Knuth, try this program. If you're right that the
period of Borland's generator is no more than 10^5, it won't run long
and it won't write a single asterisk (expect lots):
*)

program borpriod; {calculates the period of Borland's random}
{The period should be 2^32, so this will take hours}
var x,y,count1,count2: longint; s: string;
begin
randomize;
x := randseed; y := randseed;
for count2 := 0 to maxlongint do begin
  for count1 := 0 to 999999 do begin
    x := x*134775813+1; {TP7's and TP6's generator for random}
    y := y*134775813+1; {implicit modulus is 2^32}
    y := y*134775813+1; {see Knuth vol 2, p.453 for explanation}
    if x = y then begin
      inc(count1); {adjust because first count was 0}
      if count1 = 1000000 then begin count1 := 0; inc(count2) end;
      if count2 > 0 then begin
        str(count1,s);
        writeln(#13#10'Period: ',count2,
          copy('000000',1,6-length(s)),count1);
        end
      else writeln(#13#10'Period: ',count1);
      halt;
      end;
    end;
  write('*'); {one per million}
  end;
end.
