Program RealConv;

{  This program demonstrates the conversion of a 6 byte Turbo Pascal   }
{  real variable type by re-creating the exponent and Mantissa.        }
{  The temporary variable Mantissa accumulates the value stored in     }
{  bytes 2 through 6.                                                  }

type
  SixByteArray = array[1..6] of byte;

var
  r : real;
  s : SixByteArray absolute r;
{ Allows access to individual real type bytes }
  i,j : byte;
  PosFlag : boolean;
  Mantissa : real;
  Number : real;

function power (x,y : integer) : real;
begin
  power := exp(y * ln(x));
end;

begin
  write('Enter floating point Number ');
  readln(r);
{ Check if entry is positive from bit 7 of byte 6 }
  PosFlag := ($80 and s[6]) = 0; 
{ Force bit 7 of byte 6 on }
  s[6] := s[6] or $80;           
{ Initialize the Mantissa }
  Mantissa := 1.0;               
{ Check each byte of mantissa }
  for i := 2 to 6 do             
{ Check each bit }
    for j := 0 to 7 do           
      if ((s[i] shr j) and 1 ) = 1 then
{ Increment mantissa appropriately }
        Mantissa := Mantissa + power(2, (j + (i-2)*8));

{ Normalize the number by dividing by 2^40 }
  Number := Mantissa / power(2,40);

{ Get number by multiply Mantissa by the exponent }
  Number := Number * power(2, s[1] - $80);  
  if not PosFlag then Number := Number * -1;
  writeln(Number);
  readln;
end.

