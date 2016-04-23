{
kortemey@rudolf.nscl.msu.edu (Gerd Kortemeyer)

>Does anyone have a Turbo Pascal 6.0/7.0 Function that will return the
>square root of a regular 6 Byte Real argument.   I need a faster one than
>the one the comes With TP7.0 because my Program is spending a lot of time
>in it.

if you Really need to do fast FP-calculations you should use a coprocessor
(or a 486DX) together With its dataTypes SINGLE, DOUBLE and EXTendED.

if you already got a copro and still use Real, that's the worst thing you
can do. In fact using Real With copro is often slower than Without because
the 6 Byte Real always has to be converted into a copro dataType.

Now here is what you can Write instead of x:=sqrt(a);
}
Asm
  fld  a
  fsqrt
  fstp x
end;


