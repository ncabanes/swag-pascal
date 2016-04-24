(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0039.PAS
  Description: Locate String in SUB-Str
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:09
*)

{*****************************************************************************
 * Function ...... InStr()
 * Purpose ....... To locate a substring in a string starting at a given
 *                 position.
 * Parameters .... n        Position in the string to start searching
 *                 sub      Substring to search for
 *                 s        String to search in
 * Returns ....... Numeric position of <sub> in string <s> after position <n>
 * Notes ......... Uses function Right
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION InStr( n: BYTE; sub: STRING; s: STRING ): BYTE;
BEGIN
     InStr := POS( sub, Right( s, LENGTH(s)-n+1 ) ) + n - 1;
END;


