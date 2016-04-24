(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0288.PAS
  Description: Calculating Credit Cards
  Author: SCOTT KANE
  Date: 05-30-97  18:17
*)

{
Here's a snippet I thought some programmers could use on this list, its'
from the Webhub list...  Calculates the checksum of a credit card.

The webhub javascript directory contains a nice bit of code from
Mauricio Korbman that does the mod10 credit card checksum for validating
that an entered credit card number is ok.  This is very important for
us, but because we still want to maintain backward compatibility for
mission critical events (and what's more critical than getting money
over the web?) I have "ported" this code into delphi.

I only have one credit card, a visa, and the code works right for it.
So I'm sending this to the list for two purposes, to share this with
everyone and to get anybody else who finds it useful to take a look at
it and see if it's running right for other card types (and to catch any
dumb mistakes I've committed).

-Mark Wladika
markw@kweb.com
}

procedure TMainForm.Button1Click(Sender: TObject);

var
cardNumber: String;
CalcCard, calcs, CC, i: Integer;
R: Real;

begin


cardNumber := Edit1.Text;

R := Length(cardNumber) / 2;

        if (Length(cardNumber) - (R*2) = 0)     then
        begin
           for i := Length(cardNumber)-1 downto  1 do
              R := i / 2;
              if (R < 1) then
                R := R + 1;

              if (i - (R * 2) <> 0) then
                 calcs := StrToInt((Copy(cardNumber, (i-1), 1))) * 2
              else
                 calcs := StrToInt((Copy(cardNumber, (i-1), 1)));

              if (calcs >= 10) then
                 calcs := calcs - 10 + 1;

              CalcCard := CalcCard + calcs;

        end
        else
           begin
           for i := Length(cardNumber)-1 downto 1 do
              R := i / 2;
              if (R < 1) then
                R := R + 1;

              if (i - (R * 2) <> 0) then
                 calcs := StrToInt((Copy(cardNumber, (i-1), 1)))
              else
                 calcs := StrToInt((Copy(cardNumber, (i-1), 1))) * 2;

              if (calcs >= 10)then
                 calcs := calcs - 10 + 1;

              CalcCard := CalcCard + calcs;
            end;

        calcs := 10 - (CalcCard mod 10);
        if (calcs = 10)  then
           calcs := 0;

        if (calcs = StrToInt((Copy(cardNumber, Length(cardNumber)-1,1)))) then
           Edit2.Text := 'Credit Card Number Valid'
        else
           Edit2.Text := 'Credit Card Number Not Valid';



end;


