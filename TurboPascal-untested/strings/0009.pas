{
Here's a few routines you might find useful For your name problem.
I call the Function "UpperName" whenever the user presses a
valid Text key in a name field, but it can also be called just
once after the entire input String is entered.
}

(* First, some general routines: *)
(* ----------------------------- *)

Function  FindStrLength(S: String): Byte;
{ Finds "S"'s length, not counting trailing spaces }
Var
  StrLen: Byte Absolute S;
  I     : Byte;

begin
  I := StrLen;
  if StrLen > 0 then
    For I := StrLen downto 0 do
      if S[I] <> ' ' then
        Break;
  FindStrLength := I;
end; { FindStrLength }

Function WordDelimiter(C: Char): Boolean;
{ -Checks if "C" qualifies as a String Word-delimiter }
Const
  WordDels: Array[1..34] of Char =
    #32#9#13#10#39',./?;:"<>[]{}-=\+|()*%@&^$#!~';
Var
  I: Integer;

begin
  WordDelimiter := False;
  For I := 1 to 34 do
    if C = WordDels[I] then
    begin
      WordDelimiter := True;
      Break;
    end;
end; { WordDelimiter }

Function  ParceWord(S: String; Ind, L: Integer): String;
{ Returns the next Word from "Ind" index in "S" }
Var
  I: Integer;

begin
  ParceWord := '';
  I := Ind;
  For I := Ind to L do
    if WordDelimiter(S[I+1]) then
    begin
      ParceWord := Copy(S, Ind, I-Ind+1);
      Break;
    end;
end; { ParceWord }


(* Now down to business: *)
(* --------------------- *)

Procedure UpperName(Var S: String);
{ Converts the first Character in Words to upper Case letters }
Var
  I, L: Integer;
  St  : String;

begin
  L := FindStrLength(S);
  if L = 0 then
    Exit;
  For I := L downto 2 do
    if WordDelimiter(S[I-1]) then
    begin
      St := StUpCase(ParceWord(S, I, L));
      { you can put in exception Words here... }
      if (St = 'DE') or (St = 'DEN') then
      { ie: Markis de Bleuchamp or van den Haag }
         S[I] := 'd'
      else
        S[I] := UpCase(S[I]);
    end;
  S[1] := UpCase(S[1]);
end; { UpperName }

{
(The Function "StupCase" is from TurboPower Tpro, but any
routine that converts a String to upper Case letters will do).

Please note that I had to modify this source beFore
posting it here (it was full of norwegian name style
identifiers that only would've confused you), so it's not
tested in the current Form and may contain bugs.
...But I'm sure you get the general idea.  :-)

posting it here (it was full of norwegian name style
identifiers that only would've confused you), so it's not
tested in the current Form and may contain bugs.
...But I'm sure you get the general idea.  :-)
}