
I'm looking for a function that, with a date as param, would
return the date of the last day of the month, i.e.

function TForm1.LastDateOfMonth(Dt : TDateTime) : TDateTime;
var
   Year,Month,Day : Word;
begin
     DecodeDate(Dt,Year,Month,Day);
     {Make the date the first day of the next month}
     Day := 1;
     inc(Month);
     if Month = 13 then begin
        Month := 1;
        inc(Year);
     end;
     {Covert to TDateTime and minus 1 from it to give you the last day
      of the previous month}
     Dt := EncodeDate(Year,Month,Day);
     Result := Dt -1;
end;
