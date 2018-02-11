(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0092.PAS
  Description: Credit Card check
  Author: CAMERON CLARK
  Date: 05-25-94  08:01
*)

uses crt;
{
unit Vericard;

interface

  function Vc(c : string) : char;

implementation
}
  function Vc(c : string) : char;
  var
    card : string[21];
    Vcard : array[0..21] of byte absolute card;
    Xcard : integer;
    Cstr : string[21];
    y, x : integer;
  begin
    x := 0;
    Cstr := '                ';
    Cstr := '';
    fillchar(Vcard, 22, #0);
    card := c;
    for x := 1 to 20 do
      if (Vcard[x] in [48..57]) then
        Cstr := Cstr + chr(Vcard[x]);
    card := '';
    card := Cstr;
    Xcard := 0;
    if NOT odd(length(card)) then
      for x := (length(card) - 1) downto 1 do
        begin
          if odd(x) then
            y := ((Vcard[x] - 48) * 2)
          else
            y := (Vcard[x] - 48);
          if (y >= 10) then
            y := ((y - 10) + 1);
          Xcard := (Xcard + y)
        end
    else
      for x := (length(card) - 1) downto 1 do
        begin
          if odd(x) then
            y := (Vcard[x] - 48)
          else
            y := ((Vcard[x] - 48) * 2);
          if (y >= 10) then
            y := ((y - 10) + 1);
          Xcard := (Xcard + y)
        end;
    x := (10 - (Xcard mod 10));
    if (x = 10) then
      x := 0;
    if (x = (Vcard[length(card)] - 48)) then
      Vc := Cstr[1]
    else
      Vc := #0
  end;
{
END.
}
{ .....................DRIVER EXAMple........  }
{
program ValiCard;
}
  { Test routine for the Mod 10 Check Digit CC validator... }
{
uses
  dos,
  crt,
  VeriCard;
}
var
  card : string[22];
  k : char;

  procedure Squawk(Noise : byte);
  begin
    case Noise of
      1 : begin
            Sound(400);
            Delay(200);
            Sound(200);
            Delay(200);
            Nosound
          end;
      2 : begin
            Sound(392);
            Delay(55);
            Nosound;
            Delay(30);
            Sound(523);
            Delay(55);
            Nosound;
            Delay(30);
            Sound(659);
            Delay(55);
            Nosound;
            Delay(30);
            Sound(784);
            Delay(277);
            Nosound;
            Delay(30);
            Sound(659);
            Delay(55);
            Nosound;
            Delay(30);
            Sound(784);
            Delay(1200);
            Nosound
          end
    end                                { case }
  end;

BEGIN
  k := #0;
  clrscr;
  fillchar(card, 22, #0);
  writeln('VC: Integer Modulo-10 Visa/Mastercard/Amex Check-Digit');
  writeln('    verification routine. (c) 1990 Daniel J. Karnes');
  writeln;
  write('    Please enter a Credit Card number: ');
  readln(card);
  writeln;
  writeln;
  if (length(card) > 12) then
    k := Vc(card);
  if (k in ['3', '4', '5']) then
    Squawk(2)
  else
    Squawk(1);
  case k of
    #0 : writeln('    Could NOT verify this number with any card type.');
    '3' : writeln('    Card was verified as a valid Amex Card Number.');
    '4' : writeln('    Card was verified as a valid VISA Card Number.');
    '5' : writeln('    Card was verified as a valid Mastercard Number.')
  end
END.
{
...................
Hope that helps. I've only tried it on one card number BUT it did work
for the one and the info was received from someone in the business.
}
