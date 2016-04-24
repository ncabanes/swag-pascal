(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0093.PAS
  Description: Simplex Method
  Author: HOWARD KAPLAN
  Date: 05-26-95  23:28
*)

{
In response to a request from rfv@maties.sun.ac.za in sunny South
Africa, here is some code from snowy Toronto which implements the
simplex method:

{SIMPLEX.PAS -- Simplex routine adapted from FORTRAN version in
                Numerical Recipes, by Press, Flannery, Teukolsy, and
                Vetterling, 1986 edition.  Adaptation made by
                Howard L. Kaplan, Addiction Research Foundation,
                Toronto, Ontario in 1993.  If you have the right to
                use the FORTRAN original, then Howard Kaplan grants
                you the right to use this adaptation.}

{$N+}
{if you want a standalone test, then do not $define UnitMode}
{$define UnitMode}

{$ifdef UnitMode}
unit    SIMPLEX;

interface
{$endif}

const   MaxSimplexDimensions=10;
        MaxIterations=200;

type    ParameterVector=array[1..MaxSimplexDimensions] of single;
        ParameterArray=array[1..MaxSimplexDimensions+1] of
                       ParameterVector;
        EvaluationArray=array[1..MaxSimplexDimensions+1] of single;
        String20=string[20];
        Evaluator=function(R: ParameterVector;
                           const Why: OpenString): single;

procedure Amoeba(var P: ParameterArray; {starting vertices}
                 NDim: integer; {N of elements of ParameterVector used}
                 FTol: single;  {fractional convergence tolerance}
                 Func: Evaluator; {fit evaluation function}
                 var Iter: integer {number of iterations used});
{$ifdef UnitMode}
implementation
{$else}
forward;
{$endif}

procedure Amoeba(var P: ParameterArray; {starting vertices}
                 NDim: integer; {N of elements of ParameterVector used}
                 FTol: single;  {fractional convergence tolerance}
                 Func: Evaluator; {fit evaluation function}
                 var Iter: integer {number of iterations used});
const Alpha=1.0;
      Beta=0.5;
      Gamma=2.0;
var   Y:     EvaluationArray;
      PBar:  ParameterVector; {centroid without worst point}
      PR,
      PRR:   ParameterVector; {test points to be evaluated}
      MPts,              {number of points in the simplex}
      I,J,
      IHi,               {index of highest (worst) evaluation}
      INHi,              {index of next-highest evaluation}
      ILo:   integer;    {index of lowest (best) evaluation}
      YPr,               {function evaluated at PR}
      YPrr,              {function evaluated at PRR}
      STemp: single;
      Why:   String[20];
{sub}function NString(N: integer): string20;
var   S: String[20];
begin
     Str(N,S);
     while (Length(S)<4) do
        S:=' '+S;
     NString:=S
end;
begin
     MPts:=NDim+1; {number of points in the simplex}
     Iter:=0;
     FillChar(Y,SizeOf(Y),0); {facilitate debugging}
     for J:=1 to MPts do
        Y[J]:=Func(P[J],'Initial row '+NString(J)); {initial simplex}
     repeat
       {Find the worst, next worst, and best vertices so far}
        if (Y[1]>Y[2]) then begin
           IHi:=1;
           INHi:=2
           end
        else begin
           IHi:=2;
           INHi:=1
           end;
        ILo:=1;
        for I:=1 to MPts do begin
           if (Y[I]<Y[ILo]) then
              ILo:=I;
           if (Y[I]>Y[IHi]) then begin
              INHi:=IHi;
              IHi:=I
              end
           else if (Y[I]>Y[INHi]) then
            if (I<>IHi) then
              INHi:=I
           end;
       {If the worst is 0 or close, return}
        if (Y[IHi]<=FTol) then
           Exit;
       {Compute the fractional range from worst to best, and return if
        satisfactory}
        if ((2*Abs(Y[IHi]-Y[ILo])/(Abs(Y[IHi])+Abs(Y[ILo])))<FTol) then
           Exit;
       {If we are not allowed to do any more work, return although
        unsatisfactory}
        if (Iter=MaxIterations) then
           Exit;
       {Do another iteration}
        Inc(Iter);
       {Compute the centroid of the face that leaves out the
        one worst point}
        for J:=1 to NDim do begin
           STemp:=0;
           for I:=1 to MPts do
            if (I<>IHi) then
              STemp:=STemp+P[I,J];
           PBar[J]:=STemp/NDim
           end;
       {Reflect the simplex from the worst point, and evaluate}
        for J:=1 to NDim do
           PR[J]:=(1+Alpha)*PBar[J]-Alpha*P[IHi,J];
        YPr:=Func(PR,'Reflect worst');
        if (YPr<=Y[ILo]) then begin
          {This is better than the best so far, so try an additional
           extrapolation factor of Gamma}
           for J:=1 to NDim do
              PRR[J]:=Gamma*Pr[J]+(1-Gamma)*PBar[J];
           YPrr:=Func(PRR,'Extend reflection');
           if (YPrr<Y[ILo]) then begin
             {replace the highest point with PRR}
              P[IHi]:=PRR;
              Y[IHi]:=YPrr
              end
           else begin
             {replace the highest point with PR}
              P[IHI]:=PR;
              Y[IHi]:=YPr
              end
           end {YPr<YLo}
        else if (YPr>=Y[INHi]) then begin
          {The new point is worse than the second highest, but it might
           still be better than the highest}
           if (YPr<Y[IHi]) then begin
              P[IHi]:=PR;
              Y[IHi]:=YPr
              end;
          {Whether or not the new point replaced the highest, see
           whether a point of the interior, interpolating between
           the (possibly new) highest point and the old centroid,
           is better than the highest point, and if so, replace the
           highest point; if not, contract around the best point so
           far.}
           for J:=1 to NDim do
              PRR[J]:=Beta*P[IHi,J]+(1-Beta)*PBar[J];
           YPrr:=Func(PRR,'Interp. reflection');
           if (YPrr<Y[IHi]) then begin {replace}
              P[IHi]:=PRR;
              Y[IHi]:=YPrr
              end
           else {contract}
              for I:=1 to MPts do
               if (I<>ILo) then begin
                 for J:=1 to NDim do
                    P[I,J]:=(P[I,J]+P[ILo,J])/2;
                 Y[I]:=Func(P[I],'Contract')
                 end
           end {PRR was worse than the second-highest}
        else begin
          {PR was better than the second-highest, so we replace the old
           highest point}
           P[IHi]:=PR;
           Y[IHi]:=YPr
           end
        until (false)
end;

{$ifndef UnitMode}

function  TestEvaluation(R: ParameterVector;
                         const S: OpenString): single;
{Try to fit Y=A*Sqr(X)+B*X+C, where A=20, B=3, C=16, for -30<=X<=30}
var   N:     integer;
      Sigma: single;
begin
      Write('Evaluating A=',R[1]:6:3,', B=',R[2]:6:3,', C=',R[3]:6:3);
      Sigma:=0;
      for N:=-30 to 30 do
         Sigma:=Sigma+Sqr((R[1]*N*N+R[2]*N+R[3])-(20*N*N+3*N+16));
      WriteLn(' : ',Sigma:10:2);
      TestEvaluation:=Sigma
end;

procedure TestAmoeba;
const Dimensions=3;
var   Simplex: ParameterArray;
      Iter:    integer;
begin
     WriteLn;
     Simplex[1,1]:=1;
     Simplex[1,2]:=1;
     Simplex[1,3]:=1;
     Simplex[2,1]:=-1;
     Simplex[2,2]:=-1;
     Simplex[2,3]:=-1;
     Simplex[3,1]:=1;
     Simplex[3,2]:=3;
     Simplex[3,3]:=5;
     Simplex[4,1]:=6;
     Simplex[4,2]:=4;
     Simplex[4,3]:=7;
     Amoeba(Simplex,3,0.00001,TestEvaluation,Iter);
     WriteLn('Converged to A=',Simplex[1,1]:6:3,', B=',Simplex[1,2]:6:3,
             ', C=',Simplex[1,3]:6:3,' after ',Iter,' iterations')
end;
{$endif}

begin
{$ifndef UnitMode}
     TestAmoeba
{$endif}
end.

