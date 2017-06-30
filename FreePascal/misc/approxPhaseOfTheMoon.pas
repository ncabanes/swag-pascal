(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0159.PAS
  Description: approx phase of the moon
  Author: TIM MIDDLETON
  Date: 09-04-95  10:53
*)

program moondays;

uses dos;

{----------------------------------------------------------------------}
{--           Calculate Approxmiate Phase of the Moon:               --}
{----------------------------------------------------------------------}
{-- Uses formula by P. Harvey in the "Journal of the British         --}
{-- Astronomical Association", July 1941. Formula is accurate to     --}
{-- within one day (or on some occassions two days). If anyone knows --}
{-- a better formula please let me know! Internet: as544@torfree.net --}
{----------------------------------------------------------------------}
{-- Calculates number of days since the new moon where:              --}
{--    0 = New moon       15 = Full Moon                             --}
{--    7 = First Quarter  22 = Last Quarter (right half dark)        --}
{----------------------------------------------------------------------}
Function Moon_age(y : word; m : word; d : word) : byte;
var i : integer;
    c : word;
begin
     c:=(y div 100);
     if (m>2) then dec(m,2) else inc(m,10);
     i:=((((((y mod 19)*11)+(c div 3)+(c div 4)+8)-c)+m+d) mod 30);
     moon_age:=i;
end;

{----------------------------------------------------------------------}
{-- Enable Dos redirection:                                          --}
{----------------------------------------------------------------------}
Procedure DosRedirect;
begin
     ASSIGN(Input,'');RESET(Input);
     ASSIGN(Output,'');REWRITE(Output);
end;

{**********************************************************************}
{**********************************************************************}
var
   ty, tm, td, tdow : word;
BEGIN
     DosRedirect;
     Getdate(ty,tm,td,tdow);
     WriteLn('Today is the day ',td,' in the month ',tm,
        ' and the year ',ty);
     tdow := Moon_age(ty,tm,td);
     Write('The moon is ',tdow,' day');
     if tdow<>1 then write('s');
     write(' old.');
     case tdow of
          0 : Write('  New moon!');
          7 : Write('  First Quater!');
          15: Write('  Full moon!');
          22: Write('  Last Quarter!');
     end;
     writeln;
END.

