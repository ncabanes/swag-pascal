(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0084.PAS
  Description: Pentium-Optimized Permutations
  Author: TERJE MATHISEN
  Date: 11-26-94  05:00
*)

{
Just for fun, I sat down last night and generated an inline asm version
of the C code I posted that permuted character strings.  This version
uses about 90 clock cycles/call on a 486 and 60 on a Pentium, i.e.
one microsecond/call on my P5-60:  (The average time is very nearly
independent of the length of the string.)

From: terjem@hda.hydro.com (Terje Mathisen)
}

{$R-,S-}
Program Permutate;

Function Permute(var a; alen : word): Boolean;
Assembler;
asm
  push ds         { BX -> beginning of array }
  lds bx,[a]
  mov di,[alen]   { Array length }
  xor cx,cx       { Return value = False }
  lea si,[di+bx-2]{ SI -> one character before last }
  lea di,[di+bx-1]{ DI -> last position in a[] }

@loop1:
  cmp si,bx       { Check if we've gotten to the beginning of the array!}
   jb @reverse    { Yes, so no permutation found, return reversed array!}
  mov ax,[si]     { Get another pair of bytes from the end }
  dec si
  cmp al,ah
   jae @loop1     { Loop until a[si] < a[si+1] }

{ We have found a pair of bytes where the first is less than
  the second, which means that there exists at least one more
  permutation of the a[] array.
}

  mov bx,di       { BX -> Last byte in a[] }
  inc si          { SI was decremented one extra time, adjust back }
  mov cl,True     { Return value = True }

{ Find the last byte which is > al (a[si]) }

@loop2:
  mov dl,[bx]
  dec bx
  cmp dl,al
   jbe @loop2

{ Swap the two positions found: }

  mov [si],dl
  mov [bx+1],al
   jmp @reverse   { Reverse the rest of the array! }

@loop3:
  mov al,[si]
  mov dl,[di]
  mov [di],al
  dec di
  mov [si],dl
@reverse:
  inc si
  cmp si,di
   jb @loop3

  mov ax,cx
  pop ds
end;

var
  test, org : String;
  n : LongInt;

begin
  org := ParamStr(1);
  test := org;
  n := 0;

  if ParamCount > 1 then begin {Verbose version }
    repeat
      WriteLn(n:10,' ',test);
      Inc(n);
    until not Permute(test[1],Length(test));
    WriteLn(n:10,' ',test);
  end
  else begin
    repeat
      Inc(n);
    until not Permute(test[1],Length(test));
    WriteLn(n,' permutations of ',org,' found!');
  end;
end.


