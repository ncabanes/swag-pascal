{
MAYNARD PHILBROOK

>> I've never had to do this, so I'm not sure, but can't you just pass a
>> pointer to the array? eg.
>> type
>>   DorkArray = Array[0..255] of Byte;
>> var
>>   Dork : ^DorkArray;
>
> but what exactly do I declare in the assembly procedure to get thses
> values?
}
ASm
   Mov   Word AX, [Dork];
   Mov   Word BX, [Dork+2];
   Mov   ES, BX;
   Mov   BX, AX;
   { Now ES:BX } {equal the same value as Dork}
   Mov    Byte AL, [ES:BX];   {Get the first byte of Dork into AL. }
   Mov    Byte AL, [ES:BX+1]; {Get the Secoce Byte of Dork into al.}
   Mov    Word SI, 00;
   Mov    AL, [ES:BX+SI]; {also do this.}
   Inc    SI;
   Mov    AL  {ES:BX+SI]; Ect//
 { Another way to load up a poiter }
   LES    Dowrd BX, [Dork];   { This is simpler way of defining a piiner.
