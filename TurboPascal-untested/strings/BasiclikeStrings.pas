(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0082.PAS
  Description: Basic-like Strings
  Author: TODD JACOBS
  Date: 08-24-94  13:21
*)

{
  *****************************************************************
  *                         Basic Strings                         *
  *                               by                              *
  *                         Todd A. Jacobs                        *
  *                                                               *
  * Duplicates the Basic string functions Left$, Right$, and Mid$ *
  *****************************************************************

  A very simple unit to assist in parsing strings using familiar
  Basic commands.  StrName is self-explanatory.  NumChars is the
  length of the string to be returned, and StartPos is the index to
  start at for the Mid$ (aka MidStr) function.

  Released into the public domain, I hope someone will: a) find it
  useful, and b) add support for comma-delimited and space-delimited
  input (a la Basic).

  Comments may be directed to 1:109/182 or tjacobs@epub.com.
  Flames may be directed to the NUL device.  :)
}

Unit BasicStr;

Interface

Function MidStr  ( StrName: String; StartPos, NumChars : Integer) : String;
Function LeftStr ( StrName: String; NumChars : Integer) : String;
Function RightStr( StrName: String; NumChars : Integer) : String;

Implementation

Function MidStr;
Begin
  MidStr := Copy ( StrName, StartPos, NumChars);
End; {Mid$}

Function LeftStr;
Begin
  LeftStr := Copy ( StrName, 1, NumChars);
End; {Left$}

Function RightStr;
Begin
  RightStr := Copy ( StrName, ( Length(StrName) - (NumChars - 1)), NumChars);
End; {Right$}

End. {Unit}

