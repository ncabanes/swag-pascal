(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0104.PAS
  Description: Gaussian Distribution
  Author: DR. JOHN STOCKTON
  Date: 02-21-96  21:03
*)

{ From : Dr John Stockton (JRS@merlyn.demon.co.uk)

  Function RandomGaussianSD1 returns a number drawn from
  a Gaussian distribution with mean of zero, unit standard
  deviation, cutoff at +/- 4 ; I have taken it from another,
  working, program.

  It may very easily be amended for any distribution
  whatsoever, provided that the probability density may
  be sufficiently well represented by a known expression
  within a finite rectangular box;
  see RandomDistrib, which is but slightly tested.

  In each case, the probable time taken varies inversely with
  the fraction of the box area which is under the PD line. }


program Distribs ;


function RandomGaussianSD1 : extended
  { Gaussian distribution, SD = 1, cutoff @ +/- 4.0 } ;
var X : extended ;
begin
  repeat X := (Random-0.5)*8.0 ;
    until Exp(-Sqr(X)*0.5)>Random ;
  RandomGaussianSD1 := X end {RandomGaussianSD1} ;

procedure GaussTest ;
var j : byte ; s, t : extended ; const k = 80 ;
begin t := 0.0 ;
  for j := 1 to k do begin
    s := RandomGaussianSD1 ; t := t + Sqr(s) ;
    Write(s:9:3) ; if (j and 7)=0 then Writeln ;
    end ;
  Writeln('RMS: ', Sqrt(t/k):10:3, '  ~ 1 ?  '^G) ;
  Write('That should look Gaussian, mean 0, RMS 1 !') ;
  end {GaussTest} ;


{ The following more general form is less tested but should be OK : }

type func = function (X : extended) : extended
  { Normalised so that 0.0 <= func <= 1.0 } ;

function RandomDistrib(Min, Max : extended ; Fn : func) : extended
  { Fn distribution from Min to Max } ;
var X : extended ;
begin repeat X := Random*(Max-Min) + Min until Fn(X)>Random ;
  RandomDistrib := X end {RandomDistrib} ;

function Gauss(X : extended) : extended ; FAR ;
begin Gauss := Exp(-Sqr(X)*2.0) end {Gauss} ;

procedure GenTest ;
var j : byte ; s, t : extended ; const k = 80 ;
begin t := 0.0 ;
  for j := 1 to k do begin
    s := RandomDistrib(-6.0, +6.0, Gauss) ; t := t + Sqr(s) ;
    Write(s:9:3) ; if (j and 7)=0 then Writeln ;
    end ;
  Writeln('RMS: ', Sqrt(t/k):10:3, '  ~ 1 ?  '^G) ;
  Write('That should look Gaussian, mean 0, RMS 0.5 !') ;
  end {GenTest} ;


BEGIN ;
Writeln('Distributions :') ;
Randomize ;
GaussTest ; Readln ;
GenTest ; Readln ;
END.  E&OE.

