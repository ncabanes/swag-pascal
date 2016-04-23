
{ Updated MISC.SWG on May 26, 1995 }

{
To let every one know that mite have had some bad experience with Assembler
using the Basm I have found a Major bug in TP 6.0 and still exist in TP 7.0 !
with the BASM you are allowed to use @Data, @Code ect.. Well i found out
this ! if you do this

  asm
    mov Ax, Word ptr @Data;
  end;

which isn't really the correct way to use it but was the only way i could
think at the time i was pounding in the code because my fall fledged
assemblers let  me do this since it knows how to handle it properly an
produce the correct code..  Well in the BASM it also lets you do this with
no complaint from the compiler !, Well guess what? after examining the code
with Debug i found two things. one is that line of code that did that never
got generate in the finale EXE, the compiler just though it was ok to leave
out the whole line?  Secondly i did this in a UNIT and when any call in side
this unit made any call to another function or procedure in the same unit it
would generate a Near call which is fine because that is what tp does for
optimizing but guess what?, the address reference it makes is so far out
of range it produces a QEMM error over here but if a call is made to this
same function or procedure from the Main modual the correct address is
generated  because it uses the Far call to do so..

Example
}

Unit Test;
Interface
 procedure one;
 procedure two;
implementation
 procedure one;
  begin
    asm
       mov ax, Word Ptr @Data;
    End;
   End;
 procedure two;
  begin
    one; { call number one }
    Writeln(' hello, Testing ');
  End;
End.
{

When examining this with Debug i found that pro Two did this

  Push CS;
  Call Near One;  But mind you the address here

  Was not pointing to "ONE", but pointing to some far out of site
 locations to garbage code..
< ------ Main Modual ---->
}
Uses Test;
Begin
  One;
  Two;
End;

{
Now in this one when view with Debug the One & Two Calls are correct
in its addresses, but the calls with in the UNIT to another
neighboring block of code is optimized to a Near and the wrong address
is generated to does not point to anything that comforms..

 Now after aprox. four hours testing and Debug i found this..

Change the Line where i had the Mov AX, Word Ptr @Data to
Mov Ax, Seg @Data and all is ok, this line does finally end up in the
EXE and the Near call Addressing with in the same UNit also now works.

 Now keep in mind TP does not generate an Compiler error to halt the
compiling process of any type.!!!!!!!!!! no matter what the switches
are set but rather it des to corrupt the enviroment of TO while
it is compiling..
  I relized that using the @data as i did is not the intended way to
 use the this compiler directive for the BASM but since i am use to
do ing this in a Fall blown assembler and it knows what i want and
generates same results i am looking i just expect that TP would give
me a Syntax error of some kind, so lets say it don't, then way is it
messing up the compiler for Near calls then ?, shouldn't be doing that!

 I also know about anther Bug in Basm i found way back..
You can not perform a direct Absolute COnstant Far call Address.
 Call $FFFF:0000; for example will not generate what you want but will
point you to some area of the Data segment!.
   Even if use a const it will also generate the same results...
P.S.
   These serious errors in the compiler still exist in the TP 7.0 and
 the BP 7.0 protect mode...


--------------------------------

  From: Dj Murdoch

>   asm
>     mov Ax, Word ptr @Data;
>   end;

This might be related to another bug in TP/BP 7:

56.  In BASM, "dw @variable" will not assemble properly.  BP and BPC abort,
while TURBO and TPC give a wrong answer.


--------------------------------

  From: John Stephenson

> mov Ax, Word ptr @Data;
> which isn't really the correct way to use it

 Thats right! Use it with SEG, look up @data in the online help and see
that it says thats the only way to use it..

> generates same results i am looking i just expect that TP would give
> me a Syntax error of some kind

 Well, I bet C would hang on something like that after compiling it, due
to the lose type checking..

> You can not perform a direct Absolute COnstant Far call Address.
> Call $FFFF:0000; for example will not generate what you want but
> will point you to some area of the Data segment!.

 (ouch) That is a "small" bug, but, maybe you can't call up a absolute
memory call in assembler.

  On another note, I don't know if this is a bug or not, but it doesn't
work:
}

Procedure T(var thing: word); assembler;
var
 value: word;
asm
  mov value, 1h
  mov word ptr thing, value
end;
{
So you need to use this:
}
Procedure T(var thing: word); assembler;
var value: word; asm mov value, 1h; les di, thing; mov ax, value; stosw; end;
{
So that prompts me to ask "What is word ptr for then?"
}
