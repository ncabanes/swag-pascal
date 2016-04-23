{
> If I make a Assembly routine in a Turbo Pascal program,
> how can I make far jumps, calls, etc?

Here's two procedures:
}

procedure CallFar(Where : pointer); assembler;
asm
  call Where
end;

procedure JmpFar(Where : pointer); inline($cb);

{
> How can I make labels?
You can make local labels.
}

asm
  jcxz @1
  shl  ax, cl
 @1:
  add  cx, bx
  ...
end;
{
But with assembly in Pascal you can also make local variables;
}

procedure Test; assembler;
var
  MyLocalVar : word; { a variable }
asm
   mov MyLocalVar, 0 { clear contents }
end;

{
> how to discover the offset of a certain instruction?

To discover the offset for a variable, you might use LEA
(Load Effective Address).
}
   LEA  bx, MyLocalVar { for the above example }
{
Will NOT return the contents of MyLocalVar, but the offset
within the stack segment to MyLocalVar.
}