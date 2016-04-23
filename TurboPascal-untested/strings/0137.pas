{ EFLIB | Extended Function Library (C) Johan Larsson, 1992 - 1997
          All rights reserved. E-mail to jola@ts.umu.se.

          FREE STRING ROUTINE UNIT - SWAG RELEASE, June 1997.

  --------
  SYNOPSIS
  --------
  This is some of the string routines in an early release of EFLIB,
  the application framework for Borland Pascal with full OOP design.
  These routines are donated to the public domain and may freely be
  used, modified and distributed - in any way.

  THERE IS NO WARRANTY TO GO WITH THIS FREE STRING UNIT, NOR IS
  ANY SUPPORT AVAILABLE FOR THESE PROCEDURES.

  -------------------
  ABOUT EFLIB STRINGS
  -------------------
  This unit is donated to the public domain since EFLIB contains
  a 100% OO string engine, introduced in release 3 of EFLIB. This
  engine features sophisticated text structures, dynamic allocations,
  pattern matching, search algorithms (Boyer-Moore as well as KMP),
  extended text tokens, hyper strings, formatted strings and so on ...


  **********************************************************************
  |                                                                    |
  |  This program is DEVELOPED WITH EFLIB. EFLIB is a SOPHISTICATED    |
  |  OBJECT ORIENTED TOOLKIT for Borland Pascal. EFLIB contains        |
  |  hundreds of features, including ...                               |
  |                                                                    |
  |    o  Classic data structures       o  Data streams (in-/output)   |
  |    o  Full GUI                      o  Mathematics (matrixes, etc) |
  |    o  Windows, browsers, editors    o  Text handling               |
  |                                                                    |
  |  EFLIB combines the flexibility of the Borland C++ Class Library   |
  |  with features similar to Borland Turbo Vision.                    |
  |                                                                    |
  |  You can DOWNLOAD EFLIB together with 1 MB of kernel SOURCE CODE   |
  |  on Internet; http://www.ts.umu.se/~jola/EFLIB/. If you have any   |
  |  questions, write an e-mail to jola@ts.umu.se.                     |
  |                                                                    |
  **********************************************************************  }


UNIT FREESTRI;

INTERFACE

type tCharSet = set of char;

function BackwardPos (var SubString, Data : string; StartPosition : byte) : byte;
function CountPos (var SubString, Data : string; Count : byte) : byte;
function ForwardPos (var SubString, Data : string; StartPosition : byte) : byte;
function IsCharactersInString (Chars : tCharSet; Data : string) : boolean;
function IsInString (SubString : string; Data : string) : boolean;
function Occurrence (var SubString, Data : string) : byte;
function Replace (var Data, SubString1, SubString2 : string) : string;
function SearchPos (var SubString, Data : string; StartPosition : byte) : byte;
function StringBackwardPos (SubString, Data : string; StartPosition : byte) : byte;
function StringCentered (Data : string) : string;
function StringCountPos (SubString, Data : string; Count : byte) : byte;
function StringDoubled (Data : string) : string;
function StringFill (Count : byte; SubString : string) : string;
function StringFixed (Data : string; FixedLength : byte) : string;
function StringFixedCentered (Data : string; FixedLength : byte) : string;
function StringFixedRight (Data : string; FixedLength : byte) : string;
function StringForwardPos (SubString, Data : string; StartPosition : byte) : byte;
function StringOccurrence (SubString, Data : string) : byte;
function StringReplace (Data, SubString1, SubString2 : string) : string;
function StringSearchPos (SubString, Data : string; StartPosition : byte) : byte;
function StringSpace (Count : byte) : string;
function StringStripped (Data : string) : string;
function StringZeroStripped (Data : string) : string;
procedure Fill (var Data : string; Count : byte; SubString : string);
procedure StringRemoveLead (var Data : string; Character : char);
procedure StringRemoveTrail (var Data : string; Character : char);


IMPLEMENTATION


{ *****************************************
  *             Procedures                *
  ***************************************** }


{ Returns the position of a substring, beginning at specified position and
  searching forward }
function ForwardPos (var SubString, Data : string; StartPosition : byte) : byte;
var Position : integer;
begin
     if StartPosition < 1 then StartPosition := 1;
     Position := Pos (SubString, Copy (Data, StartPosition, Length(Data) - StartPosition + 1));
     if Position > 0 then ForwardPos := Pred(Position + StartPosition)
        else ForwardPos := 0; { Not found }
end;

{ Returns the position of a substring, beginning at specified position and
  searching forward }
function StringForwardPos (SubString, Data : string; StartPosition : byte) : byte;
begin
     StringForwardPos := ForwardPos (SubString, Data, StartPosition);
end;

{ Returns the position of a substring, beginning at specified position and
  searching backward }
function BackwardPos (var SubString, Data : string; StartPosition : byte) : byte;
begin
     if StartPosition > Length(Data) then StartPosition := Length(Data);
     BackwardPos := Pos (SubString, Copy (Data, 1, StartPosition));
end;

{ Returns the position of a substring, beginning at specified position and
  searching backward }
function StringBackwardPos (SubString, Data : string; StartPosition : byte) : byte;
begin
     StringBackwardPos := BackwardPos (SubString, Data, StartPosition);
end;

{ Returns the position of a character closests to a certain position }
function SearchPos (var SubString, Data : string; StartPosition : byte) : byte;
var ForwardIndex, BackwardIndex : byte;
begin
     ForwardIndex  := ForwardPos  (SubString, Data, StartPosition);
     BackwardIndex := BackwardPos (SubString, Data, StartPosition);
     { Return the position to the closest found substring }
     if StartPosition-ForwardIndex >= BackwardIndex-StartPosition then
        SearchPos := ForwardIndex else SearchPos := BackwardIndex;
end;

{ Returns the position of a character closests to a certain position }
function StringSearchPos (SubString, Data : string; StartPosition : byte) : byte;
begin
     StringSearchPos := SearchPos (SubString, Data, StartPosition);
end;

{ Returns the position of a numbered substring in a string (for example,
  if Count is set to two, the position of the second location of the substring
  is returned). }
function CountPos (var SubString, Data : string; Count : byte) : byte;
var Index : integer; Position : byte;
begin
     Position := 0; { Reset search position }
     for Index := 1 to Count do
         Position := ForwardPos (SubString, Data, Succ(Position));
     CountPos := Position; { Zero if not found }
end;

{ Returns the position of a numbered substring in a string (for example,
  if Count is set to two, the position of the second location of the substring
  is returned). }
function StringCountPos (SubString, Data : string; Count : byte) : byte;
begin
     StringCountPos := CountPos (SubString, Data, Count);
end;

{ Returns the number of occurrences of a substring inside a string }
function Occurrence (var SubString, Data : string) : byte;
var Count, Position : integer;
begin
     { Reset position and counter }
     Position := 0; Count    := 0;
     { Search for substring and go forward if one is found }
     repeat
           Position := ForwardPos (SubString, Data, Succ(Position));
           if Position <> 0 then Inc (Count);
     until (Position = 0);
     Occurrence := Count; { Return number of occurrences }
end;

{ Returns the number of occurrences of a substring inside a string }
function StringOccurrence (SubString, Data : string) : byte;
begin
     StringOccurrence := Occurrence (SubString, Data);
end;

{ Returns TRUE if substring is found inside string }
function IsInString (SubString : string; Data : string) : boolean;
begin
     IsInString := (Pos (SubString, Data) <> 0);
end;

{ Returns TRUE if any character in specified set is found inside string }
function IsCharactersInString (Chars : tCharSet; Data : string) : boolean;
var Index : integer;
begin
     IsCharactersInString := FALSE; { Assume that no character is found }
     for Index := 1 to Length(Data) do
         if Data[Index] in Chars then begin
            { Character in set found - break }
            IsCharactersInString := TRUE;
            Exit;
         end;
end;

{ Replaces a sub-string in a string with another sub-string }
function Replace (var Data, SubString1, SubString2 : string) : string;
var Index, Position : integer; TempString : string;
begin
     { Reset index variable and clear temporary string }
     Index := 0; TempString := '';
     while Index < Length(Data) do begin
           Inc (Index); { Go forward one step }
           Position := ForwardPos (SubString1, Data, Index);
           { Copy data if not search string found }
           if Index <> Position then TempString := TempString + Data[Index]
              else begin
                   { Replace SubString1 with SubString2 }
                   TempString := TempString + SubString2;
                   Index := Position + Pred(Length (SubString1));
              end;
     end;

     Replace := TempString; { Return replaced string }
end;

{ Replaces a sub-string in a string with another sub-string }
function StringReplace (Data, SubString1, SubString2 : string) : string;
begin
     StringReplace := Replace (Data, SubString1, SubString2);
end;


{ Generates a string filled with specified number of copies of the
  specified substring. }
procedure Fill (var Data : string; Count : byte; SubString : string);
var Index : byte;
begin
     Data := ''; { Clear data string }
     if Length(SubString) = 1 then begin
        { Use memory filling if data is a character }
        if Count > 0 then FillChar (Data[1], Count, Ord(SubString[1]));
        Data[0] := Chr(Count); { Set string length }
     end else for Index := 1 to Count do Data := Data + SubString;
end;

{ Generates a string filled with specified number of copies of the
  specified substring. }
function StringFill (Count : byte; SubString : string) : string;
var TempString : string;
begin
     { Avoid overlap of filling - use temporary string for filling }
     Fill (TempString, Count, SubString);
     StringFill := TempString;
end;

{ Generates a string containing specified number of blank spaces }
function StringSpace (Count : byte) : string;
begin
     StringSpace := StringFill (Count, #32);
end;

{ Removes all leading characters in string }
procedure StringRemoveLead (var Data : string; Character : char);
var Length : byte absolute Data;
begin
     { Delete all leading characters }
     while (Data[1] = Character) and (Length > 1) do Delete (Data, 1, 1);
end;

{ Removes all trailing characters in string }
procedure StringRemoveTrail (var Data : string; Character : char);
var Length : byte absolute Data;
begin
     { Delete all trailing characters }
     while (Data[Length] = Character) and (Length > 1) do Dec (Length);
end;

{ Removes blank spaces before and after text inside a string }
function StringStripped (Data : string) : string;
begin
     { Delete all leading and trailing spaces }
     StringRemoveLead (Data, #32);
     StringRemoveTrail (Data, #32);
     { Return stripped string }
     StringStripped := Data;
end;

{ Removes leading and trailing zeroes from a text string }
function StringZeroStripped (Data : string) : string;
begin
     { Delete all leading and trailing zeroes }
     StringRemoveLead (Data, '0');
     StringRemoveTrail (Data, '0');
     { Remove comma signs or add one leading zero if comma first in string }
     if (Data[Length(Data)] = '.') then Delete (Data, Length(Data), 1); { Delete last character }
     if (Data[1] = '.') then Data := '0' + Data;
     StringZeroStripped := Data;
end;

{ Centers text inside a string }
function StringCentered (Data : string) : string;
var FixSpace, StrippedStr : string; StartLength : byte;
begin
     StrippedStr := StringStripped(Data); { Removes leading and trailing spaces }
     { Calculate number of spaces available for centering }
     FixSpace    := StringSpace((Length(Data) - Length(StrippedStr)) div 2);
     StartLength := Length(Data);
     Data        := FixSpace + StrippedStr + FixSpace;
     if Length(Data) <  StartLength then Data := Chr(32) + Data;
     StringCentered := Data;
end;

{ Fixes the length of a string by inserting spaces or removing characters }
function StringFixed (Data : string; FixedLength : byte) : string;
var Length : byte absolute Data;
begin
     if (Data <> '') then Data := Copy (Data, 1, FixedLength);
     while (Length < FixedLength) do Insert (#32, Data, Succ(Length));
     StringFixed := Data;
end;

{ Centers and fixes the length of a string }
function StringFixedCentered (Data : string; FixedLength : byte) : string;
begin
     StringFixedCentered := StringCentered(StringFixed(Data, FixedLength));
end;

{ Right justifies and fixes the length of a string }
function StringFixedRight (Data : string; FixedLength : byte) : string;
begin
     if FixedLength >= Length(Data) then
        StringFixedRight := StringSpace (FixedLength - Length(Data)) + Data
     else StringFixedRight := StringFixed (Data, FixedLength);
end;

{ Inserts one blank space between each character inside string }
function StringDoubled (Data : string) : string;
var Index : byte; TempString : string;
begin
     TempString := '';
     for Index := 1 to Length(Data) do TempString := TempString + Data[Index] + #32;
     StringDoubled := Copy (TempString, 1, Pred(Length(TempString)));
end;


end. { unit }

{ (C) Johan Larsson, 1992 - 1997. Donated to the public domain. No warranty. }