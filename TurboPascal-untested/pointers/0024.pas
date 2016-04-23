{
CC> I want to know how to retrieve the n(th) element from the
CC> table in BASM.

Solution:
}

 program _getvalue;

 const table:array[0..9] of integer=
   (1001,1002,1003,1004,1005,1006,1007,1008,1009,1010);

 function getvalue(nth:word):integer; assembler;
 asm
   mov si,nth                 { get index }
   add si,si                  { 'multiply' by two (word-sized) }
   mov ax,word ptr table[si]  { put table[index] in ax -> function-result }
 end;

 begin
   writeln(getvalue(7));
 end.
