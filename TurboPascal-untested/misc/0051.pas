{
BOB SWART

> Does anybody have any tips on optimizing TP Programs?
What kind of optimization? Speed or Size? Optimizing For one may not be the
same as optimizing For the other...

> but now it has grown quite large (anybody want it? :), and I'd like
> to shrink it.
Ah, so optimizing For size! Minimizing data space, code space (and stack/heap
usage as well).

> I've gotten it from 40k down to 29k after a lot of work, but that is
> still too big.
Do you want to turn it into a TSR?

> Does anyone know of any common optimization techniques that would work?
Do you use BAsm code or plain Pascal?

> For instance, if inc(IntVar, amt) is more efficient (code size wise)
> than IntVar := IntVar + amt;
Yes, try dumpprog (by our beloved moderator) on those two statements:

test.pas#4:  i := i + 4;
   0000:000F A15000          MOV     AX,[DS: i(0050)]
   0000:0012 050400          ADD     AX,0004
   0000:0015 A35000          MOV     [DS: i(0050)],AX

It takes 9 Bytes For "i := i + 4;"

test.pas#5:  Inc(i,4);
   0000:0018 8306500004      ADD     [Word DS:+i(+0050)],+04

It takes only 5 Bytes to do "Inc(i,4);" (and it is also faster!!)


> That's the kind of thing that I'm looking for.
Well Brian, currently I'm working on a whole BOOK about 'Borland Pascal
Performance Optimization' (about 250-pages, english, early '94 ). In my book,
the process op Program optimization is divided into four steps: 1. finding the
bottle-necks in your Program, 2. using better datastructures & algorithms, 3.
using more efficient language Constructs, and 4. using BAsm code and InLine
macros. There will be a whole chapter devoted to 'optimization techniques for
Program size', but I will say a few Words here For you:

Most of the times optimization is a matter of SPEED vs. SIZE. if you want the
smallest code, then prepare let the Program do some more work. Eliminate big
look-up tables (if you use any), use small, simple datastructures (that often
imply not-so-efficient algorithms), do not use more Units than the ones you
Absolutely need. Even then, try to code the routines from those Units yourself
(avoid any and all overhead from those Units). If, For example, you need a
ReadKey-like Function, don't use the Crt Unit, but implement your own ReadKey
Function like this:

{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X+}
{.$DEFINE Crt}
Program test;
{$IFDEF Crt}
{ Code size: 3056
  Data size:  690
  .EXE size: 3232
}
Uses Crt;
{$else}
{ Code size: 1504 --> 1552 Bytes less
  Data size:  672 -->   18 Bytes less
  .EXE size: 1680 --> 1552 Bytes less
}
Const
  ScanCode : Byte =   0;
  _ReadKey : Byte = $00;

Function ReadKey : Char; Assembler;
Asm
  mov   AL, ScanCode { check old ScanCode }
  mov   ScanCode,0   { empty old ScanCode }
  or    AL, AL       { AL = 0? }
  jne   @end         { no: return ScanCode }
  xor   AH, AH       { AH := 0 }
  int   $16          { read Character }
  or    AL, AL       { AL = 0? }
  jne   @end         { no: simple Character }
  mov   ScanCode, AH { yes: extended Character }
 @end:
end;
{$endIF}

Var
  t : Char;
begin
  t := ReadKey;
end.

The resulting code is 1552 Bytes less when using your own ReadKey instead of
the Crt Unit. This is mainly due to the initalization code of the Crt Unit, of
course, but even For you 1.5 Kb is about 5% code size...

As you can see above, if you try to push your code to the limit, you MUST use
BAsm or InLine macros. The Turbo/Borland Pascal compilers simply do not
generate code as efficient as a good Programmer can do.

Finally, if you can't wait Until early '94, an article about Borland Pascal
Performance Optimization will be published in an opcoming issue of PC
Techniques. if you want more information about the book send me some netmail or
Write to the address below. I'll send you some information on paper.

