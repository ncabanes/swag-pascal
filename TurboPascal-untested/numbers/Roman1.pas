(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0019.PAS
  Description: ROMAN1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
·    Subject: Word to Roman Numeral

  OK, here is my second attempt, With error checking and all. Thanks to
Terry Moore <T.Moore@massey.ac.nz> For encouraging me. The last Function
also contained a couple of errors. This one is errorchecked.
}

Function RomantoArabic(Roman : String) : Integer;
{ Converts a Roman number to its Integer representation }
{ Returns -1 if anything is wrong }

  Function Valueof(ch : Char) : Integer;
  begin
    Case ch of
      'I' : Valueof:=1;
      'V' : Valueof:=5;
      'X' : Valueof:=10;
      'L' : Valueof:=50;
      'C' : Valueof:=100;
      'D' : Valueof:=500;
      'M' : Valueof:=1000;
      else Valueof:=-1;
    end;
  end;   { Valueof }

  Function AFive(ch : Char) : Boolean; { Returns True if ch = 5,50,500 }
  begin
    AFive:=ch in ['V','L','D'];
  end;   { AFive }

Var
  Position : Byte;
  TheValue, CurrentValue : Integer;
  HighestPreviousValue : Integer;
begin
  Position:=Length(Roman); { Initialize all Variables }
  TheValue:=0;
  HighestPreviousValue:=Valueof(Roman [Position]);
  While Position > 0 do
  begin
    CurrentValue:=Valueof(Roman [Position]);
    if CurrentValue<0 then
    begin
      RomantoArabic:=-1;
      Exit;
    end;
    if CurrentValue >= HighestPreviousValue then
    begin
      TheValue:=TheValue+CurrentValue;
      HighestPreviousValue:=CurrentValue;
    end
    else
    begin { if the digit precedes something larger }
      if AFive(Roman [Position]) then
      begin
              RomantoArabic:=-1; { A five digit can't precede anything }
              Exit;
      end;
      if HighestPreviousValue div CurrentValue > 10 then
      begin
              RomantoArabic:=-1; { e.g. 'XM', 'IC', 'XD'... }
              Exit;
      end;
      TheValue:=TheValue-CurrentValue;
    end;
    Dec(Position);
  end;
  RomantoArabic:=TheValue;
end;   { RomantoArabic }

begin
  Writeln('XXIV = ', RomantoArabic('XXIV'));
  Writeln('DXIV = ', RomantoArabic('DXIV'));
  Writeln('CXIV = ', RomantoArabic('CXIV'));
  Writeln('MIXC = ', RomantoArabic('MIXC'));
  Writeln('MXCIX = ', RomantoArabic('MXCIX'));
  Writeln('LXVIII = ', RomantoArabic('LXVIII'));
  Writeln('MCCXXIV = ', RomantoArabic('MCCXXIV'));
  Writeln('MMCXLVI = ', RomantoArabic('MMCXLVI'));
  Readln;
end.
