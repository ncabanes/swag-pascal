{
From: marcel.hoogeveen@hacom.wlink.nl (Marcel Hoogeveen)

GR> FFT stands for Fast Fourier Transform.  It is a quick way to conver
GR> time domain data (ie oscilliscopy data with time on the x-axis) to
GR> frequency domain (frequency on the x-axis, like a frequency spectrum
GR> analyzer).  This is a usefull data analysis method.  I would also like
GR> to get some source for this.


This is what i have of FFT source code, it should work if you tweak it a bit.
(It did for me when i used it in my analasis program).
Don't ask me how it works, i know how a DFT works but a FFT well .. just use
the source. :)

}
Program FFT;
Const Twopi=6.283185303;

Type Curve=array[1..nfft] of real;

Var {This is for you to find out}

{ Calculation of the Discrete Fourier Transfor }
{ Using a Fast Fourier Transform algorithm     }
{                                              }
{ XR and XI are array of reals !!!             }
{ They contain on entry the input sequence and }
{ on return the transfrom                      }
{ ISI defines the transform direction          }
{ If ISI=-1 then forward, if ISI=1 then invert }
{                                              }
{ The dimension is 2**M                        }

Procedure RFFT (VAR XR,XI:Curve;  N:integer;  ISI:Integer);
Var
M,NV2,LE,LE1,IP,I,J,K,L: Integer;
C,THETA,UR,UI,TR,TI:Real;

Begin
M:=Round(LN(N)/LN(2));
NV2:= N DIV 2;
J:=1;
For I:= 1 to N-1 do
Begin
If (I<J) then
Begin
TR:=XR[J];            TI:=X[J];
XR[J]:=XR[I];         XI[J]:=XI[I];
XR[I]:=TR;            XI[I]:=TI;
End;
K:=NV2;
While (K<J) do
Begin
J:=J-K;
K:=K DIV 2;
End;
J:=J+K;
End;
LE:=1;
C:=ISI*TWOPI;
For L:=1 TO M do
Begin
LE1:=LE;
LE:=LE*2;
For J:=1 TO LE1 do
Begin
THETA:= C*(J-1)/LE;
UR:=COS(tHETA);
UI:=SIN(THETA);
I:=J;
Repeat
IP:=I+LE1;
TR:=XR[IP]*UR-XI[IP]*UI;
TI:+XR[IP]*UI+XI[IP]*UR;
XR[IP]:=XR[I]-TR;           XI[IP]:=XI[I]-TP;
XR[I]:=XR[I]+TR;            XI[I]:=XI[I]+TI;
I:=I+LE;
Until (I>=N)
End;
End;
If ISI=-1 then
Begin
For I:= 1 TO N do
Begin
XR[I]:=4*XR[I]/N;             XI[I]:=4*XI[I]/N;
End;
End;
End;


Begin
For I := 1 to NUMSAM do
Begin
FREAL[I]:=SAMPLEBUFFER[I];
FIMAG[I]:=0;
End;
RFFT(FREAL,FIMAG,NUMSAM,-1);
DC:=FREAL[1]/2;
For I:= 1 to NUMSAM dO
FREAL[I]:=FREAL[I]*FREAL[I]+fIMAG[I]*FIMAG[I];
End.
