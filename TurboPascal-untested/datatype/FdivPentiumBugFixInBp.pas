(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0037.PAS
  Description: FDIV Pentium Bug Fix in BP
  Author: TERJE MATHISEN
  Date: 09-04-95  11:55
*)

{
> Still, I expect as a programmer for the CPU to have the right answer 100%
> of the time! My own errors are bad enough. :) It's still a bug and until
> it's 100% accurate and no less, it's not desirable to me and I would think
> others shall agree. Anything less is unreliable and unreliable doesn't
> cut it.

This is getting off-topic for the echo.  Please, if what you have to say has
nothing to do with programming in Pascal, don't say it here.

Here's something just posted to comp.lang.pascal on Usenet:

 From: Terje.Mathisen@hda.hydro.com (Terje Mathisen)
 Subject: FDIV fix for BP (fast & exact)
 Date: 1 Dec 1994 11:07:51 GMT

I have been working with Cleve Moler (from MathWorks) and Tim Coe about a sw
workaround for the Pentium FDIV bug.  Here is a BP version of the algorithm:

The FDIV_FIX unit defines a single function:

function fdiv(x: extended; y: extended): extended;

which will use about 25% more cycles than a single fdiv call, but always return
exact results for all double precision numbers, including the special cases of
Nan, Inf and denormal.
It also handles all extended precision numbers, giving a maximum error of a
single bit in the last position (1ulp).  This error can only be introduced if
the FDIV operations fails.
During the unit startup code, I test the FDIV instruction, and if if fails,
initialize a 16-byte table of critical nibble values.

If FDIV passes, the table is left empty, and no fixups will be done on
divisions.
=============== FDIV_FIX.PAS ===========================
}
{$N+,E-,G+}
Unit FDIV_FIX;

Interface

function fdiv(x, y : Extended): Extended;

const
  fdiv_risc_table : array [0..15] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  fdiv_scale : single = 0.9375;
  one_shl_63_l : Longint = $5f000000;
var
  one_shl_63 : single absolute one_shl_63_l;

Implementation

function fdiv(x, y : Extended): Extended;
Assembler;
asm
  fld [x]
@restart:
  mov bx,word ptr [y+6]
  fld [y]
  add bx,bx
   jnc @denormal
{$IFOPT G+}
  shr bx,4
{$ELSE}
  mov cl,4
  shr bx,cl
{$ENDIF}
  cmp bl,255
   jne @ok
{$IFOPT G+}
  shr bx,8
{$ELSE}
  mov bl,bh
  and bx,255
{$ENDIF}
  cmp byte ptr fdiv_risc_table[bx],bh
   jz @ok
  fld [fdiv_scale]
  fmul st(2),st
  fmulp st(1),st
   jmp @ok
@denormal:
  or bx,word ptr [y]
  or bx,word ptr [y+2]
  or bx,word ptr [y+4]
   jz @zero
  fld [one_shl_63]
  fmul st(2),st
  fmulp st(1),st
  fstp [y]
   jmp @restart
@zero:
@ok:
  fdivp st(1),st
end;

const
  a_bug : single = 4195835.0;
  b_bug : single = 3145727.0;

Procedure fdiv_init;
var
  r : double;
  i : Integer;
begin
  r := a_bug / b_bug;
  if a_bug - r * b_bug > 1.0 then begin
    i := 1;
    repeat
      fdiv_risc_table[i] := i;
      Inc(i,3);
    until i >= 16;
  end;
end;

begin
  fdiv_init;
end.


