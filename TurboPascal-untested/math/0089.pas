Program DoubConv;
{$N+}

{ This program demonstrates the conversion of a 8 byte Turbo Pascal  }
{ real variable type by re-creating the exponent and Mantissa.       }
{ The temporary variable Mantissa accumulates the value stored in    }
{ bytes 2 through 8.                                                 }


type EightByteArray = array[1..8] of byte;
     UserReal = Extended; { Insert appropriate type to convert 8 byte
                            real type to.                            }

var r : double;
    s : EightByteArray absolute r;
                        { Allow access to individual real type bytes }
    i,j : byte;
    PosFlag : boolean;
    Mantissa : UserReal;
    Exponent : integer;
    Number : UserReal;

    { the mantissa and number can be typed as to the number desired  }
    { i.e. Real, Single, Extended, BCD                               }

function power (x,y : integer) : UserReal;
begin
  power := exp(y * ln(x));
end;

begin
  write('Enter floating point Number ');
  readln(r);
  PosFlag := ($80 and s[8]) = 0;
                   { Check if entry is positive from bit 7 of byte 8 }
  s[8] := s[8] and $7F;                   { Force bit 7 of byte 8 off }
  Mantissa := 0.0;                         { Initialize the Mantissa }
  for i := 1 to 6 do                   { Check each byte of mantissa }
    for j := 0 to 7 do                              { Check each bit }
      if ((s[i] shr j) and 1 ) = 1 then
        Mantissa := Mantissa + power(2, (j + (i-1) * 8));
                                  { Increment mantissa appropriately }
  for j := 0 to 3 do              { get mantissa info from byte 7    }
    if ((s[7] shr j) and 1) = 1 then
      Mantissa := Mantissa + power(2, (j + 48));
                                  { Increment mantissa appropriately }
  { add the assumed mantissa value at bit 52                         }
  Mantissa := (Mantissa + power(2,52)) / power(2,52);
                          { Normalize the number by dividing by 2^52 }

  Exponent := s[7] shr 4;
  Exponent := Exponent + s[8] * 16;

  if (Exponent > 0) and (Exponent < 2047) then begin
    Exponent := Exponent - 1023;
    Number := Mantissa * power(2, exponent);
                   { Get number by multiply Mantissa by the exponent }
  end
  else
    if (Exponent = 0) then begin
      if mantissa <> 0 then
        Number := Mantissa * power(2, -1022);
    end
    else number := 0;
  if not PosFlag then Number := Number * -1;
  writeln(Number);
  readln;
end.


