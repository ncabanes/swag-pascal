(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0029.PAS
  Description: Trim spaces from string
  Author: MARTIN RICHARDSON
  Date: 09-26-93  08:45
*)

{*****************************************************************************
 * Function ...... AllTrim()
 * Purpose ....... To trim off spaces from either side of a string
 * Parameters .... str        String to trim
 * Returns ....... str with leading and trailing spaces removed
 * Notes ......... Uses function LTrim and RTrim
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION AllTrim( str : STRING ) : STRING;
BEGIN
     IF LENGTH( Str ) > 0 THEN
         AllTrim := LTrim(RTrim(str, ' '), ' ')
     ELSE
         AllTrim := Str;
END;


