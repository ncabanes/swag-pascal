(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0040.PAS
  Description: Moonphase Algorithm?
  Author: ALAN GRAFF
  Date: 05-25-94  08:19
*)

{
As Robert Forbes said to All on 25 Apr 94...

 RF>         Anyone have any idea how to make an algorithm to
 RF> calculate the moonphase given the date?

Here ya go:

TYPE DATETYPE = record
     day:WORD;
     MONTH:WORD;
     YEAR:WORD;
     dow:word;
     end;

{=================================================================}

Procedure GregorianToJulianDN(Year, Month, Day:Integer;
                              var JulianDN    :LongInt);
var
  Century,
  XYear    : LongInt;

begin {GregorianToJulianDN}
  If Month <= 2 then begin
    Year := pred(Year);
    Month := Month + 12;
    end;
  Month := Month - 3;
  Century := Year div 100;
  XYear := Year mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  JulianDN := ((((Month * 153) + 2) div 5) + Day) + D2
                                    + XYear + Century;
  end; {GregorianToJulianDN}

{=================================================================}

Function MoonPhase(Date:Datetype):Real;

  (***************************************************************)
  (*                                                             *)
  (* Determines APPROXIMATE phase of the moon (percentage lit)   *)
  (* 0.00 = New moon, 1.00 = Full moon                           *)
  (* Due to rounding, full values may possibly never be reached  *)
  (* Valid from Oct. 15, 1582 to Feb. 28, 4000                   *)
  (* Calculations and BASIC program found in                     *)
  (* "119 Practical Programs For The TRS-80 Pocket Computer" by  *)
  (* John Clark Craig, TAB Books, 1982                           *)
  (* Conversion to Turbo Pascal by Alan Graff, Wheelersburg, OH  *)
  (*                                                             *)
  (***************************************************************)

var
j:longint; m:real;

Begin
  GregorianToJulianDN(Date.Year,Date.Month,Date.Day,J);
  M:=(J+4.867)/ 29.53058;
  M:=2*(M-Int(m))-1;
  MoonPhase:=Abs(M);
end;


