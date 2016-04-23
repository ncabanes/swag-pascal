{
        Here's a good (but a little slow) Program to calculate the
  decimals of Pi :


THIS Program CompUTES THE DIGITS of PI USinG THE ARCTANGENT ForMULA
(1)            PI/4 = 4 ARCTAN 1/5 - ARCTAN 1/239
in CONJUNCTION With THE GREGorY SERIES

(2)   ARCTAN X = SUM  (-1)^N*(2N + 1)^-1*X^(2N+1)  N=0 to  inFinITY.

SUBSTITUTinG into (2) A FEW VALUES of N  and NESTinG  WE HAVE,

PI/4 =  1/5[4/1 + 1/25[-4/3 + 1/25[4/5 + 1/25[-4/7 + ...].].]

    - 1/239[1/1 + 1/239^2[-1/3 + 1/239^2[1/5 + 1/239^2[-1/7 +...].].]

USinG THE LONG divISION ALGorITHM, THIS ( NESTED ) inFinITE SERIES CAN BE
USED to CALCULATE PI to A LARGE NUMBER of DECIMAL PLACES in A REASONABLE
AMOUNT of TIME. A TIME Function IS inCLUDED to SHOW HOW SLOW THinGS
GET WHEN N IS LARGE. IMPROVEMENTS CAN BE MADE BY CHANGinG THE SIZE of
THE Array ELEMENTS HOWEVER IT GETS A BIT TRICKY.

}

Uses
  Crt;

Var
  B,C,V,P1,S,K,N,I,J,Q,M,M1,X,R,D : Integer;
  P,A,T : Array[0..5000] of Integer;

Const F1=5;
Const F2=239;
Procedure divIDE(D : Integer);
 begin
    R:=0;
    For J:=0 to M do
     begin
     V:= R*10+P[J];
     Q:=V div D;
     R:=V Mod D;
     P[J]:=Q;
     end;
end;
Procedure divIDEA(D : Integer);
 begin
    R:=0;
    For J:=0 to M do
     begin
     V:= R*10+A[J];
     Q:=V div D;
     R:=V Mod D;
     A[J]:=Q;
     end;
 end;
Procedure SUBT;
begin
B:=0;
For J:=M Downto 0 do
    if T[J]>=A[J]  then T[J]:=T[J]-A[J] else
    begin
     T[J]:=10+T[J]-A[J];
     T[J-1]:=T[J-1]-1;
   end;
For J:=0 to M do
A[J]:=T[J];
end;
Procedure SUBA;
begin
For J:=M Downto 0 do
    if P[J]>=A[J]  then P[J]:=P[J]-A[J] else
    begin
     P[J]:=10+P[J]-A[J];
     P[J-1]:=P[J-1]-1;
   end;
For J:= M Downto 0 do
A[J]:=P[J];
end;
Procedure CLEARP;
 begin
  For J:=0 to M do
   P[J]:=0;
 end;
Procedure ADJUST;
begin
P[0]:=3;
P[M]:=10;
For J:=1 to M-1 do
P[J]:=9;
end;

Procedure ADJUST2;
begin
P[0]:=0;
P[M]:=10;
For J:=1 to M-1 do
P[J]:=9;
end;

Procedure MULT4;
 begin
  C:=0;
  For J:=M Downto 0 do
   begin
    P1:=4*A[J]+C;
    A[J]:=P1 Mod 10;
    C:=P1 div 10;
   end;
  end;

Procedure SAVEA;
begin
For J:=0 to M do
T[J]:=A[J];
end;

Procedure TERM1;
begin
 I:=M+M+1;
 A[0]:=4;
divIDEA(I*25);
While I>3 do
begin
I:=I-2;
CLEARP;
P[0]:=4;
divIDE(I);
SUBA;
divIDEA(25);
end;
CLEARP;
ADJUST;
SUBA;
divIDEA(5);
SAVEA;
end;
Procedure TERM2;
begin
 I:=M+M+1;
 A[0]:=1;
divIDEA(I);
divIDEA(239);
divIDEA(239);
While I>3 do
begin
I:=I-2;
CLEARP;
P[0]:=1;
divIDE(I);
SUBA;
divIDEA(239);
divIDEA(239);
end;
CLEARP;
ADJUST2;
SUBA;
divIDEA(239);
SUBT;
end;

{MAin Program}

   begin
   ClrScr;
   WriteLn('                        THE CompUTATION of PI');
   WriteLn('                     -----------------------------');
   WriteLn('inPUT NO. DECIMAL PLACES');
   READLN(M1);
   M:=M1+4;
    For J:=0 to M  do
       begin
         A[J]:=0;
         T[J]:=0;
       end;
   TERM1;
   TERM2;
   MULT4;
   WriteLn;WriteLn;
   Write('PI = 3.');
   For J:=1 to M1   do
   begin
    Write(A[J]);
   if J Mod 5 =0 then Write(' ');
   if J Mod 50=0 then Write('                    ');
   end;
   WriteLn;WriteLn;
   WriteLn;
end.
