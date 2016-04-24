(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0040.PAS
  Description: Sets with up to 500000 elements
  Author: JIRI MULLER
  Date: 11-29-96  08:17
*)


{
This is for all who wanted sometimes have a set with more than 256 elements.

The type defined for this is "BigSet". It may have up to 500 000 elements.
You need it initialize befor use with function bsInit and
at the end of program free memory for each BigSet-variable with bsDone.
  Any function returns TRUE if it's all OK, 
and FALSE when 
- the variable is not initialized (aray=nil), 
- the given parameters don't match (n out of <min, max> etc...), 
- we make anything with two BigSets, which have different range (min..max)
  (it would go, but I'm lazy ;-)

If you want the .asm sources of adddelin.obj, andorsub.obj and clrfill.obj,
my e-mail is: qmuller@fi.muni.cz.

{ cut here - JMBIGSET.PAS ---------------------------------------- }

{$X+}

{ Performs using of SETs, which may have up to 500 000 elements! }
{ Elements of BigSets are longint numbers}

unit jmbigset;

interface

type Paray=^Taray;
     Taray= array[0..31249] of word;
     BigSet=record
              aray:Paray;
              total:longint;
              minel:longint;
              maxel:longint;
             end;

Function bsInit(var bs: BigSet; min, max:longint):boolean;
 { initialize any BigSet variable befor use! }
 { min - minimal element of set, max - maximal elem. of set }
 { condition: (max-min) <= 500000 }
 { returns false if initialization is not possible }
Procedure bsDone(var bs: BigSet);
function bsAdd(var a: BigSet; n:longint):boolean;        { a:= a + [n] }
function bsDel(var a: BigSet; n:longint):boolean;        { a:= a - [n] }
function bsIn(var a: BigSet; n:longint):boolean;         { test n IN a }
Function bsAnd(var p:BigSet; a,b:BigSet):boolean;        { p:=a * b }
Function bsOr (var p:BigSet; a,b:BigSet):boolean;        { p:=a + b }
Function bsSub(var p:BigSet; a,b:BigSet):boolean;        { p:=a - b }
Function bsEQ(a,b: BigSet):boolean;                      { test a=b }
Function bsLE(a,b: BigSet):boolean;                      { test a<=b }
Function bsMov(var a: BigSet; b: BigSet):boolean;        { a:=b }
Function bsClear(var a: BigSet):boolean;                 { a:=[] }
Function bsFill(var a: BigSet):boolean;                  { a:=[minel..maxel] }
Function bsAddInt(var a: BigSet; m,n: longint):boolean;  { a:=a + [m..n] }
Function bsDelInt(var a: BigSet; m,n: longint):boolean;  { a:=a - [m..n] }


implementation
{$L ADDDELIN.OBJ}
function bsAdd(var a: BigSet; n:longint):boolean;  external;
function bsDel(var a: BigSet; n:longint):boolean;  external;
function bsIn(var a: BigSet; n:longint):boolean;   external;
{$L ANDORSUB.OBJ}
Function bsAnd(var p:BigSet; a,b:BigSet):boolean;  external;
Function bsOr (var p:BigSet; a,b:BigSet):boolean;  external;
Function bsSub(var p:BigSet; a,b:BigSet):boolean;  external;
Function bsEQ(a,b: BigSet):boolean;  external; 
Function bsLE(a,b: BigSet):boolean;  external; 
Function bsMov(var a: BigSet; b: BigSet):boolean; external; 
{$L CLRFILL.OBJ}
Function bsClear(var a: BigSet):boolean; external;
Function bsFill(var a: BigSet):boolean;  external;  

Function bsAddInt(var a: BigSet; m,n: longint):boolean; 
var i,lm,nl:longint; q:boolean;
begin
     q:=(m<=n) and (a.aray<>nil);
     if q then
     begin
          if a.minel>m then lm:=a.minel else lm:=m;
          if a.maxel<n then nl:=a.maxel else nl:=n;
          for i:=lm to nl do bsAdd(a,i)
     end;
     bsAddInt:=q;
end;

Function bsDelInt(var a: BigSet; m,n: longint):boolean;  {a:=a-[m..n]}
var i,lm,nl:longint; q:boolean;
begin
     q:=(m<=n) and (a.aray<>nil);
     if q then
     begin
          if a.minel>m then lm:=a.minel else lm:=m;
          if a.maxel<n then nl:=a.maxel else nl:=n;
          for i:=lm to nl do bsDel(a,i)
     end;
     bsDelInt:=q;
end;

Function bsInit(var bs: BigSet; min, max:longint):boolean;
var q:boolean;
    i,size:longint;
begin
   q:=(min<max) and (max-min <= 500000) and (bs.aray=nil);
   if q then
   begin
     size:=(max-min+15) div 16;
     with bs do begin
                  GetMem(aray,size*2);
                  total:=0; minel:=min; maxel:=max;
                  for i:=0 to size-1 do aray^[i]:=0;
                 end;
   end;
  bsInit:=q;
end;

Procedure bsDone(var bs: BigSet);
var size:longint;
begin
     if bs.aray=nil then exit;
     size:=(bs.maxel-bs.minel+15) div 16;
     FreeMem(bs.aray,size);
     bs.aray:=nil;
end;


end.
{ cut here - EXAMPLE.PAS ---------------------------------- }

{a very simple example:}

{$X+}
uses jmbigset;
var a,b,c: bigset;
    n: longint;
begin
   writeln;
   bsinit(a,1,1000);
   bsinit(b,1,1000);
   bsinit(c,1,1000);

   bsaddint(a, 1, 500);    { a = [1..500] }
    writeln('set a has ',a.total,' elements');
   bsaddint(b, 490, 800);  { b = [490.. 800] }
    writeln('set b has ',b.total,' elements');
   bsand(c, a, b);         { c = a*b =[490..500] }
    writeln('set c has ',c.total,' elements');
   for n:=1 to 1000 do if bsin(c, n) then write(n,' ');

   bsdone(a); bsdone(b); bsdone(c);
end.

{ cut here - ADDDELIN.XX ------------------------------------ }

*XX3402-000422-221096--72--85-54689----ADDDELIN.OBJ--1-OF--1
U+s+143YN4FZP4Zi9Y3HHG866++++-lIRL7WPm--QrBZPK7gNL6U63NZQbBdPqsUAmsmaMUI
+21dfIlK6ElVN4FYNKldPWt-IopvW-E+ECZCWp+H15-pQqVmNKRn9apVMmC6+k-+uImK+U++
O6U1+20VZ7M4++F2EJF-FdU5+2U+++6-+FKK-U+2Eox2FIKM-k+cjU+1+E3qY+g+++62EZB7
HV6++04E1++++UJ0Io32F++++DyE1++++UJ0IoF3H+Y++Ce6-+-+cU4FcA6++U++JMjgjsQ+
ulCEJMjgjtk+ukeEJMjgjvA+uk4E5UO9FUO9JUX3RUe1D+-p-cBw+U-o3SUO+6j8iU2+oy89
qB5XzySk+Sg1Y1D+-lxRmUU+CpECTUK1l+9fvbk8CoEATUK1l+9fsXZI0bs3UwE0uxVw0XZ2
05s3UwE0uwns8oE64pE8il++xzD1l1kaVF3p10M72TW1F+E-UpE4+CiZl1kaVF3o1jTG7W2F
y6Bg-+41L+M+usv2D0O32LE0usLfW+8Q1E12-3E0l+pI+gEKJ+9WWU6++5E+
***** END OF BLOCK 1 *****


{ cut here - ANDORSUB.XX ------------------------------------ }

*XX3402-000921-221096--72--85-53346----ANDORSUB.OBJ--1-OF--1
U+s+143iN4xmQrJW9Y3HHTa66++++-lIRL7WPm--QrBZPK7gNL6U63NZQbBdPqsUAmsmaMUI
+21dcopK6ElVPaFjQbBpMWt-IopPW-E+ECZCWp+H15-pQqVmNKRn9apVMmC6+k-+uImK+U++
O6U1+20VZ7M4++F1HoF3FNU5+0Wd+U6-+MeE1++++EJ0IpBJEfc++0KE0k+++EF0IoJFAE2+
+t+9+++--27HHp7R++1BY+g+++22EZBAFKU-+B4E1++++EJ0Io3CF++++DOE1++++EJ0IopD
Jdw-+1S6-+-+cU4Fc8o0+E++JMjgUyk85UNKJwFy1gJq0fY2+9g6+CXK+Hk-R+DfB712TUP3
RUet-+0v0+1ck+2w+LE1uluEuCM-l5sC7gR3-+++7gR3-U++u-k0uAY+u120g+3TLUQTWyJR
mUk+JMjgUyk85UNKJwFy1gJq0fY2+9g6+CVt+Hk-R+DfB712TUP3RUet-+0v0+1cMk2w+LE1
uluEu6Y-l5sC7gR3-+++7gR3-U++u9w-u5E+uBE-g+3TLUQTWyJRmUk+JMjgUyk85UNKJwFy
1gJq0fY2+9g6+CUQ+Hk-R+DfB712TUP3RUet-+0v0+1c-U2w+LE1uluEu0k-l5sC7gR3-+++
7gR3-U++u46-u-w+u5Q-g+3TLUQTWyJRmUk+fGMX-OjWyQCh7Ug3ey9tkurro0MX-OjWxwBJ
Wym1v+cS-ZNLl5s4lLM8iEM+ikE+u8I+D+3o+ygCYCX9+CUZ+MhCxjncQk-TLUQTWyJRmUU+
JMjgUyk85UNKJwFy-gJq0fY2+9g6+CVi+1k-R+Df1d1cZ+1cvU09HjPwu2Y+Lps55sjZLQc6
+3K9v6Dg0Vs4JZT2TUf3RUOt-+0v0+1cBk+w+LE1ukaEu3o+u72+g+3TLUQTWyJRmUU+drI5
sjik+Sg1Y19+kuoa0kKjRETWxv+-ukCEAg117cAx+5I57cBx+U-o66Aw+5I4Urk0+5EJz6g+
7Xg-R+Df0t01kk9WwP+-ukCEAg11JZTwiEE+jzXzWoE6WEC1lk81lU9WwpxSWoPwWpPyy+ID
+6DG+DUfFjUPJjev2+1rwsj6WIvqkvY4+6D4-6D5-DCZUysEUywEu-6+WovqwuL2TUv3RUPc
-+09HjP1lHEal1r1l5sC7gIpWovqi+2+VEFo0zUaUoI2+GO1JEM+oS-m+ijfUwM0siD16cc0
++-o
***** END OF BLOCK 1 *****


{ cut here - CLRFILL.XX ------------------------------------ }

*XX3402-000392-221096--72--85-24588-----CLRFILL.OBJ--1-OF--1
U+o+0qBgQaNdP4kiMLBh2MUU++++53FpQa7j623nQqJhMalZQW+UJaJmQqZjPW+n9X8NW-A+
ECY2dJMV0qBgQaNdP4kiMLBhicUI+21dHchE2klkRLBcQaJbQmthMKAXW+A+ECZAZU6++4W6
+k-+cNGK-U+2F23IEIOM-k-6+++0+E2JZUM+-2BDF2J3a+Q+89o++k2-Rt+B+++0-Y7HFYZA
H2A++3mE1U+++UR0IoBAFI3G++++LMU2+20W+N4UkE+0++-JWykS-ZNLlLM4Unk+REO1T+6+
R0Gv1k1cXU0v2+1rwsj6loE2++15F+M++AEwi+++zDCfg+5f+t+nk3xS-lxRmUE+JMjg5UNK
JwJq-cAw+5I4Urk0+5F5ik2+u2g+WIE2WJE4I39s-Es+Ux6+il++xzC9m3dMxzC1yU-p+Ib2
D9XzzzCfUzc+R-09mfU-+2bX-x5U1E2+sjafg+5f+t+nk3xS-lxRmUE+WoEAWpECy+D1Ux6+
y0h20-hI0gAMWU6++5E+
***** END OF BLOCK 1 *****


