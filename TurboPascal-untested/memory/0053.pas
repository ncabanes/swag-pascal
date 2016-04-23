{$R-,S-,V-}
{
**
**  CompMem - A routine to compare to areas of memory for equality
**  by Richard S. Sadowsky [74017,1670]
**  version 1.0  5/11/88
**  released to the public domain
**  requires file MEMCOMP.OBJ to recompile
**

}
unit MemComp;

interface

function CompMem(var Block1,Block2; Size : Word) : Word;
{ returns 0 if Block1 and Block2 are equal for Size bytes, otherwise }
{ returns position of first non matching byte }

implementation

function CompMem(var Block1,Block2; Size : Word) : Word; External;
{$L memcomp.Obj}

end.

{ ---------------------   XX3402 CODE --------------------- }
{ cut this out and save as MEMCOMP.XX  execute :
{    XX3402 D MEMCOMP.XX to create MEMCOMP.OBJ              }



*XX3402-000108-110588--72--85-20839-----MEMCOMP.OBJ--1-OF--1
U+o+0qpZPKBjPL+iEJBBOtM5+++2Eox2FIGM-k+c7++0+E2FY+s+++25EoxBI2p3HE+++2m6
-+++cU5Fc0U++E++WxmAqXD+BchD-CAHBgJr0XP2TkPwwuNo-XO9FkEfkMvOmUc+9sc0++-o
***** END OF BLOCK 1 *****

{ -------------   TEST PROGRAM ---------------------  }

{$R-,S-}
program CompTest;
uses MemComp;

type
  Tipe = array[1..128] of byte;

var
  Var1,Var2 : Tipe;
  I,CompRes : Word;

begin
  FillChar(var2,SizeOf(Tipe),0); { init Var2 to all zeros }
  for I := 1 to 128  do          { set var1 = 1 2 3 4 5 ... 128 }
    Var1[I] := I;
  CompRes := CompMem(Var1,Var2,128); { compare, should return first }
                                     { byte as non match }
  WriteLn('While not equal, CompMem = ',CompRes); { show results }
  Var2 := Var1;                  { make them equal }
  CompRes := CompMem(Var1,Var2,128); { test again, should return 0 }
  WriteLn('While equal, CompMem = ',CompRes);
  Var2[128] := 0;                    { make all equal except last byte }
  CompRes := CompMem(Var1,Var2,128); { test again, should return 128 }
  WriteLn('While not equal, CompMem = ',CompRes);
end.
