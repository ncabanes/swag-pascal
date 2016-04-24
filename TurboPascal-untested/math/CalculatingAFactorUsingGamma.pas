(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0115.PAS
  Description: Calculating a Factor using Gamma
  Author: DANIEL DOUBROVKINE
  Date: 08-30-96  09:35
*)

(*
                Daniel Doubrovkine - dblock@infomaniak.ch
   part of the Expression Calculator 2.0 Multithread, destribute freely
              http://www.infomaniak.ch/~dblock/express.htm
  (ref. Wanner / Hairer - Analysis by it's History - University of Geneva)

  calculating a factor of any defined value inclusing negative and positive
      non integers! using Euler's (another swiss guy) Gamma function:
       n!=Gamma(n+1) and (n-1)!=Gamma(n)/(n-1) for negative values
        Gamma(Alpha):=Integral zero->infinity of x^(Alpha-1)*E^-x

 in GammaIntegral function TOTAL PRECISION (not just approx!) is reached by
   calculating an integral from 0 to 100 with a step if 0.01 from Gamma(4)
*)
function Gamma(alpha,step:extended):extended;
 function GammaIntegral(alpha:extended):extended;
  (*x^y:=e^(y*ln(x));*)
  function Power(base, exponent: extended): extended;
   begin
      Power:=exp(exponent*ln(base));
      end;
  function IntegralStep(x: extended):extended;
  begin
     (*Gamma Integral Step...just to have less mess*)
     IntegralStep:=power(x,alpha-1)/power(Exp(1),x);
     end;
 (*Gamma Integral*)
 var
   GammaTempIntegral:extended;
   l: extended;
 begin
   l:=0;
   GammaTempIntegral:=0;
   while l<100 do begin
         l:=l+Step;
         GammaTempIntegral:=GammaTempIntegral+IntegralStep(l)*step;
       end;
       GammaIntegral:=GammaTempIntegral;
       end;
(*Gamma*)
var
  NewGamma: extended;
  i: integer;
  begin
  if (alpha<=0) then begin
    if (trunc(alpha)=alpha) then begin
       writeln('factor results to infinite value');
       halt;
       end
       else begin
            NewGamma:=GammaIntegral(abs(1+frac(alpha))+1);
            for i:=0 to trunc(abs(alpha))-1 do begin
                NewGamma:=NewGamma/(frac(alpha)-i);
                end;
            Gamma:=NewGamma;
            exit;
            end
  end  else begin
     (*the following values return trailing decimals, this corrects it*)
     if alpha=1 then Gamma:=1 else
     if alpha=2 then Gamma:=1 else
     if alpha=3 then Gamma:=2 else
     Gamma:=GammaIntegral(alpha);
     end
end;

function Factor(n: extended):extended;
 begin
   Factor:=Gamma(n+1,0.01);
   end;

begin
     writeln(Factor(6):0);
end.

