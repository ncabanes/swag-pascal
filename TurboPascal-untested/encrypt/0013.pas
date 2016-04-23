{
REYNIR STEFANSSON

Somebody was saying something about Soundex hashing. Here is my
Implementation of that:
}

Unit Soundex;

Interface

Type
  Sdx4 = String[4];

Function SoundexOf(WorkStr : String) : Sdx4;

Implementation

Var
  Group : Array[0..6] of String[8];

Function ValidityOf(Letter : Char) : Char;
Var
  Valu, j : Integer;
  Chs     : String[8];
begin
  For Valu := 0 to 6 DO
  begin
    Chs := Group[Valu];
    For j := 1 to Length(Chs) DO
    begin
      if UpCase(Letter) = Chs[j] then
        ValidityOf := Chr(48+Valu);
    end;
  end;
end;

Function SoundexOf(WorkStr : String) : Sdx4;
Var
  Sndex : Sdx4;
  Oval,
  Valu  : Char;
  i     : Integer;
begin
  Sndex := Copy(WorkStr, 1, 1);
  Oval  := ValidityOf(WorkStr[1]);
  For i := 2 to Length(WorkStr) DO
  begin
    Valu := ValidityOf(WorkStr[i]);
    if (Valu <> '0') and (Valu <> Oval) then
      Sndex := Sndex + Valu;
    Oval := Valu;
  end;
  Sndex := Sndex + '000';
  SoundexOf := Sndex;
end;

begin
  Group[0] := 'AEHIOUWY';
  Group[1] := 'BFPV';
  Group[2] := 'CGJKQSXZ';
  Group[3] := 'DT';
  Group[4] := 'L';
  Group[5] := 'MN';
  Group[6] := 'R';
end.

{
A Soundex-String looks like: `G032', one letter and three numbers.
Donald Knuth wrote about Soundexing in his _Art of Computer Programming_
series. I got my information out of Personal ComputerWorld (PCW), which in
turn got it from Knuth.
}
