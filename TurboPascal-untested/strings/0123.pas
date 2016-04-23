Optimized for speed:
=== ===
function UpperCase(S: string): string;
var 
  I: Integer;
begin
  for I := 1 to Ord(S[0]) do if S[I] in ['a'..'z'] then Dec(S[i], 32);
  Uppercase := S;
end;

function LowerCase(S: string): string;
var
  I: Integer;
begin 
  for I := 1 to Ord(S[0]) do if S[I] in ['A'..'Z'] then Inc(S[i], 32);
  Uppercase := S;
end;
=== ===
Optimized for memory (use constant declarations to cut down on stack
usage--but then you can't modify S) :

=== ===
function UpperCase(const S: string): string;
var
  I: Integer;
begin
  Uppercase := S;
  for I := 1 to Ord(S[0]) do if S[I] in ['a'..'z'] then
    UpperCase[I] := Chr(Ord(S[I])-32);
end;

function LowerCase(const S: string): string;
var
  I: Integer;
begin
  LowerCase := S;
  for I := 1 to Ord(S[0]) do if S[I] in ['A'..'Z'] then
    LowerCase[I] := Chr(Ord(S[I])+32);
end;
=== ===

With ASM, the fastest case routines I have seen so far {w.out using a 
look-up table that is}


function UpperCase(const S: string): string; assembler;
asm
  push ds
  lds si, s
  les di, @result
  lodsb
  stosb
  xor ch, ch
  mov cl, al
  jcxz @empty
@upperloop:
  lodsb
  cmp al, 'a'
  jb @cont
  cmp al, 'z'
  ja @cont
  sub al, ' '
@cont:
  stosb
  loop @upperloop
@empty:
  pop ds
end;

function LowerCase(const S: string): string; assembler;
asm
  push ds
  lds si, s
  les di, @result
  lodsb
  stosb
  xor ch, ch
  mov cl, al
  jcxz @empty
@lowerloop:
  lodsb
  cmp al, 'A'
  jb @cont
  cmp al, 'Z'
  ja @cont
  add al, ' '
@cont:
  stosb
  loop @lowerloop
@empty:
  pop ds
end;
