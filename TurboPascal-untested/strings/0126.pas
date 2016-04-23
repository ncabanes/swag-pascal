{-----------------------------------------------}
Function  LoCase(ch:Char):Char;
{ Convert Ch to the LOWER case with Russian specifications }
var

  OutCH: Char;

begin
   OutCh:=Ch;

   if (OutCh>='A') and (OutCh<='Z') then
      OutCh:=Chr(Ord(Outch) + $20);       { Convert chars "A...Z" to "a...z"}
   if (OutCh>=#128) and (OutCh<=#143) then
      OutCh:=Chr(Ord(Outch) + $20);       { Convert the first portion
                                            of Russian chars }
   if (OutCh>=#144) and (OutCh<=#159) then
      OutCh:=Chr(Ord(Outch) + $50);       { Convert the second portion of
                                            of Russian chars }
   if (OutCh=#240) then  OutCh:=#241;     { Convert Russian umlaut }

   Lower:=OutCh;
end; { Lower }

{-----------------------------------------------}
Function Upper(Ch:Char):Char;
{ Convert Ch to UPPER case with Russian specificatios }

var

  OutCH: Char;

begin
  OutCh:=Ch;
  if (Ch>='a') and (Ch<='z') then
     OutCh:=Chr(Ord(Ch) - $20)           { convert "a...z" to "A...Z"}
  else if (Ch>=#160) and (Ch<=#175) then
     OutCh:=Chr(Ord(Ch) - $20)           { convert the first russian portion}
  else if (Ch>='╥' {rus}) and (Ch<='╤') then
     OutCh:=Chr(Ord(Ch) - $50)           { convert the second Russian portion}
  else if (Ch=#241) then Ch:=#240;       { convert Russian umlaut }
 Upper:=OutCh;
end; { Upper }
