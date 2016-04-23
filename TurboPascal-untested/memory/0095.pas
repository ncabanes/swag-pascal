{
The following code shows how to create a temporary stack
for use during ISRs and in other situations where the
default stack might not be big enough.

The following program intentionally creates a very small
default stack by using the $M compiler directive. It then
calls a function which pushes $2000 bytes onto the stack,
thereby setting up a situation which should cause a 202 error.

To avoid the error, the program creates a temporary stack
by allocating $4000 bytes on the heap and moving this value
into SS. It then sets SP to point at the end of this new
stack and proceeds to call the function, which does not
fail because of the new temporary stack.

This code has been tested in both real and protected mode.
}


{$M $800, 0, $12000}

procedure BreakDefaultStack;
var
  a:array[0..$2000] of char;
begin
  Writeln('Hello');
end;

var
  aSS, aSP: Word;
  Stck: pointer;

begin
  getmem(Stck, $4000);
  Word (Stck^) := 1;

  asm
    mov aSP, sp
    mov ax, ss
    mov aSS, ax
    mov ax, word ptr [Stck]
    mov bx, word ptr [stck+2]
    add ax, $4000-2
    cli
    mov ss, bx
    mov sp, ax
    sti
  end;

  BreakDefaultStack;

  asm
    mov ax, aSS
    mov ss, ax
    mov sp, aSP
  end;

  freemem(Stck, $4000);
end.
