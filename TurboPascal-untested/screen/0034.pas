{
SAM HASINOFF

> Can anyone help me With a Procedure that would let me change the
> border colors on the screen?

You don't *need* to know BAsm, but it sure will help cut down on code size!
Here is a plain-vanilla pascal Program which Uses the Dos Unit :( !
}

Program BorderTest;

Uses
  Dos;

Procedure border(colour : Byte);
Var
  regs : Registers;
begin
 regs.ah := $10;
 regs.al := $01;
 regs.bh := colour;
 intr($10, regs);
end;

begin
  border(10);
end;

{ Now let's reWrite the Procedure using BAsm: }

Procedure border(colour : Byte); Assembler;
Asm
  mov ah, 10h
  mov al, 01h
  mov bh, colour
  int 10h
end;

{
I almost never Program in BAsm, but have picked up just enough to do the
above with a fair amount of certainty... The code is almost self explanatory:

The "mov" moves the second parameter into the first:
  mov a,b    is equivalent to    a:=b;

(note: the h at the end of 10h, specifies that the number is hexadecimal, or
base 16.  In pascal we Write $10 to mean 16, in BAsm we Write 10h)

The "int" command calls the specified interrupt... in the above example we
are calling interrupt 10h (16).  I think the ah and al Registers tell the
computer which Function and sub-Function of int 10h to call, While bh and bl
are usually used as input values, and cx (something to do With the stack)
is normally used as an output value (like an error result from a disk read)
-- but don't quote me on any of that last sentence!
}
