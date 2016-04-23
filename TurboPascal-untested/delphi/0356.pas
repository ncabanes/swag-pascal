
{ This code came from Lloyd's help file! }

Soundex function--determines whether two words sound alike. Written after reading an article in PC Magazine about the Soundex algorithm. Pass the function a string. It returns a Soundex value string. This value can be saved in a database or compared to another Soundex value. If two words have the same Soundex value, then they sound alike (more or less). 
Note that the Soundex algorithm ignores the first letter of a word. Thus, "won" and "one" will have different Soundex values, but "Won" and "Wunn" will have the same values.

Soundex is especially useful in databases when one does not know how to spell a last name.



--------------------------------------------------------------------------------

Function Soundex(OriginalWord: string): string;
var
  Tempstring1, Tempstring2: string;
  Count: integer;
begin
  Tempstring1 := '';
  Tempstring2 := '';
  OriginalWord := Uppercase(OriginalWord); {Make original word uppercase}
  Appendstr(Tempstring1, OriginalWord[1]); {Use the first letter of the word}
  for Count := 2 to length(OriginalWord) do
    {Assign a numeric value to each letter, except the first}

    case OriginalWord[Count] of
      'B','F','P','V': Appendstr(Tempstring1, '1');
      'C','G','J','K','Q','S','X','Z': Appendstr(Tempstring1, '2');
      'D','T': Appendstr(Tempstring1, '3');
      'L': Appendstr(Tempstring1, '4');
      'M','N': Appendstr(Tempstring1, '5');
      'R': Appendstr(Tempstring1, '6');
      {All other letters, punctuation and numbers are ignored}
    end;
  Appendstr(Tempstring2, OriginalWord[1]);
  {Go through the result removing any consecutive duplicate numeric values.}

  for Count:=2 to length(Tempstring1) do
    if Tempstring1[Count-1]<>Tempstring1[Count] then
        Appendstr(Tempstring2,Tempstring1[Count]);
  Soundex:=Tempstring2; {This is the soundex value}
end;

--------------------------------------------------------------------------------
SoundAlike--pass two strings to this function. It returns True if they sound alike, False if they don't. Simply calls the Soundex function. 


--------------------------------------------------------------------------------

Function SoundAlike(Word1, Word2: string): boolean;
begin
  if (Word1 = '') and (Word2 = '') then result := True
  else
  if (Word1 = '') or (Word2 = '') then result := False
  else
  if (Soundex(Word1) = Soundex(Word2)) then result := True
  else result := False;
end;

