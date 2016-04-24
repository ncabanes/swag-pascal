(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0041.PAS
  Description: Day Of Week
  Author: FRED JOHNSON
  Date: 05-26-94  06:19
*)

{Returns a string or an integer, what ever you want}
{You fix for leap year}

unit dow;
interface

const
  saDayOfWeek : array [0..6] of string =
     ('Monday','Tuesday','Wednesday','Thursday',
     'Friday','Saturday','Sunday');

type
   spString  = ^string;

function IntDow(yyyy,mm,dd : integer) : integer;
function StrDow(yyyy,mm,dd : integer) : spString;

implementation
   
function IntDow(yyyy,mm,dd : integer) : integer;
   var
      iAddVal : shortint;
   begin
      if mm < 3 then iAddVal := 1 else iAddVal := 0;
      IntDow := (((3*(yyyy)-(7*((yyyy)+((mm)+9) div 12)) 
         div 4+(23*(mm)) div 9+(dd)+2 
         +(((yyyy)-iAddVal) div 100+1)*3 div 4-16) mod 7));
   end;

function StrDow(yyyy,mm,dd : integer): spString;
   var 
      sReturnString : string;
   begin
      sReturnString := saDayOfWeek[IntDow(yyyy, mm, dd)];
      StrDow := @sReturnString;
   end;   
end.
{test file}

uses dow;
begin
   write(StrDow(1995, 10,08)^);
end.

