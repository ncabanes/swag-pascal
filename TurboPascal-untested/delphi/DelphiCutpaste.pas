(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0059.PAS
  Description: Re: Delphi Cut/Paste
  Author: THOMAS SCHEFFCZYK
  Date: 11-24-95  10:15
*)

{
I don't know if this will help you, but the following (simple) functions
helped me handling substrings. Perhaps you can use them to seperate
the text for each field (for i := 1 to NumToken do ...) and store it
seperatly in the database-fields. }

function GetToken(aString, SepChar: String; TokenNum: Byte):String;
{
parameters: aString : the complete string
            SepChar : a single character used as separator 
                      between the substrings
            TokenNum: the number of the substring you want
result    : the substring or an empty string if the are less then
            'TokenNum' substrings
}
var
   Token     : String;
   StrLen    : Byte;
   TNum      : Byte;
   TEnd      : Byte;

begin
     StrLen := Length(aString);
     TNum   := 1;
     TEnd   := StrLen;
     while ((TNum <= TokenNum) and (TEnd <> 0)) do
     begin
          TEnd := Pos(SepChar,aString);
          if TEnd <> 0 then
          begin
               Token := Copy(aString,1,TEnd-1);
               Delete(aString,1,TEnd);
               Inc(TNum);
          end
          else
          begin
               Token := aString;
          end;
     end;
     if TNum >= TokenNum then
     begin
          GetToken1 := Token;
     end
     else
     begin
          GetToken1 := '';
     end;
end;

function NumToken(aString, SepChar: String):Byte;
{
parameters: aString : the complete string
            SepChar : a single character used as separator 
                      between the substrings
result    : the number of substrings
}

var
   RChar     : Char;
   StrLen    : Byte;
   TNum      : Byte;
   TEnd      : Byte;

begin
     if SepChar = '#' then
     begin
          RChar := '*'
     end
     else
     begin
         RChar := '#'
     end;
     StrLen := Length(aString);
     TNum   := 0;
     TEnd   := StrLen;
     while TEnd <> 0 do
     begin
          Inc(TNum);
          TEnd := Pos(SepChar,aString);
          if TEnd <> 0 then
          begin
               aString[TEnd] := RChar;
          end;
     end;
     NumToken1 := TNum;
end;

