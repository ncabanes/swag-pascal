(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0063.PAS
  Description: Upper/Lower Strings
  Author: FRED JOHNSON
  Date: 11-02-93  06:27
*)

{
FRED JOHNSON

After noticing the compiler error,  Arthur Choi said...

>How do I upcase a String, For use With
>a ReadLn?
AC>Simple as possible, please... thanx

{More than you wanted, but very useful}
Uses String_h;

Var
  sData : String;
begin
  sData := 'fred';
  Writeln('toupper  ', toupper(@sData)^);
  Writeln('original ', sData);
  Writeln('strupr   ', strupr(@sData)^);
  Writeln('original ', sData);

  Writeln('tolower  ', tolower(@sData)^);
  Writeln('original ', sData);
  Writeln('strlwr   ', strlwr(@sData)^);
  Writeln('original ', sData);
end.

{---- String_h.pas.tpu ---}
{*******************************************************************!HDR**
** Module Name: String_h.pas
** $LogFile:$
** $Revision:$
** $Author:$
** System Module Purpose:
** Public Functions Within this module:
** Global usage:
** Special notes:
** $Log$
** Initial revision.
** Initial revision. 10/05/93 19:35
********************************************************************!end*}
Unit String_h;

Interface
Type
   spStringPtr = ^String;

{-------------------------------------------------------------------!HDR--
** Function Name: toupper();
** Description  : converts String to upper case
** Returns      : Pointer to an uppercase String
** Calls        : length, upcase
** Special considerations:
** Modification history:
** Created: 10/05/93 19:28}
Function toupper(String_or_Char : spStringPtr) : spStringPtr;

{-------------------------------------------------------------------!HDR--
** Function Name: tolower();
** Description  : converts a String to lower case
** Returns      : Pointer to a lower Case String
** Calls        : length, ord, length
** Special considerations:
** Modification history:
** Created: 10/05/93 19:28}
Function tolower(String_or_Char : spStringPtr) : spStringPtr;

{-------------------------------------------------------------------!HDR--
** Function Name: strupr
** Description  : converts String and alters contents to uppercase
** Returns      : Pointer to uppercase String
** Calls        : upcase, length
** Special considerations:
** Modification history:
** Created: 10/05/93 19:28}
Function strupr (String_or_Char : spStringPtr) : spStringPtr;

{-------------------------------------------------------------------!HDR--
** Function Name: strlwr
** Description  : converts String and alters contents to lower case
** Returns      : Pointer to lower Case String
** Calls        : ord, Char, length
** Special considerations:
** Modification history:
** Created: 10/05/93 19:28}
Function strlwr (String_or_Char : spStringPtr) : spStringPtr;

Implementation

Function toupper(String_or_Char : spStringPtr) : spStringPtr;
Var
  byCounter : Byte;
begin
  toupper^[0] := String_or_Char^[0];
  For byCounter := 1 to length(String_or_Char^) do
    toupper^[byCounter] := upcase(String_or_Char^[byCounter]);
end;

Function tolower(String_or_Char : spStringPtr) : spStringPtr;
Var
  byCounter : Byte;
begin
  tolower^[0] := String_or_Char^[0];
  For byCounter := 1 to length(String_or_Char^) do
  begin
    if ord(String_or_Char^[byCounter]) in [65..90] then
      tolower^[byCounter] := Char(ord(String_or_Char^[byCounter])+32);
    else
      tolower^[byCounter] := String_or_Char^[byCounter];
  end;
end;

Function strupr(String_or_Char : spStringPtr) : spStringPtr;
Var
  byCounter : Byte;
begin
  strupr^[0] := String_or_Char^[0];
  For byCounter := 1 to length(String_or_Char^) do
  begin
    strupr^[byCounter] := upcase(String_or_Char^[byCounter]);
    String_or_Char^[byCounter] := upcase(String_or_Char^[byCounter]);
  end;
end;

Function strlwr(String_or_Char : spStringPtr) : spStringPtr;
Var
  byCounter : Byte;
begin
  strlwr^[0] := String_or_Char^[0];
  For byCounter := 1 to length(String_or_Char^) do
  begin
    if ord(String_or_Char^[byCounter]) in [65..90] then
    begin
      strlwr^[byCounter] := Char(ord(String_or_Char^[byCounter])+32);
      String_or_Char^[byCounter] := Char(ord(String_or_Char^[byCounter])+32);
    end
    else
    begin
      strlwr^[byCounter] := String_or_Char^[byCounter];
      String_or_Char^[byCounter] := String_or_Char^[byCounter];
    end;
  end;
end;

end.


