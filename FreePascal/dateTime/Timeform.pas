(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0019.PAS
  Description: TIMEFORM.PAS
  Author: MIKE COPELAND
  Date: 05-28-93  13:37
*)

{
MIKE COPELAND

> I'm looking For some FAST routines to change seconds into a
> readable format, (ie. H:M:S).
> For instance, 8071 seconds = 2:14:31

   Here's the code I use, and it's fast enough For me:
}

Type
  Str8 = String[8];

Function FORMAT_TIME (V : Integer) : STR8; { format time as hh:mm:ss }
Var
  X, Z  : Integer;
  PTIME : STR8;
begin                            { note: incoming time is in seconds }
  Z := ord('0');
  PTIME := '  :  :  ';           { initialize }
  X := V div 3600;
  V := V mod 3600;               { process hours }
  if (X > 0) and (X <= 9) then
    PTIME[2] := chr(X+Z)
  else
  if X = 0 then
    PTIME[3] := ' '              { zero-suppress }
  else
    PTIME[2] := '*';             { overflow... }
  X := V div 60;
  V := V mod 60;                 { process minutes }
  PTIME[4] := chr((X div 10)+Z);
  PTIME[5] := chr((X mod 10)+Z);
  PTIME[7] := chr((V div 10)+Z); { process seconds }
  PTIME[8] := chr((V mod 10)+Z);
  FORMAT_TIME := PTIME
end;  { FORMAT_TIME }

begin
  Writeln(Format_Time(11122));
end.
