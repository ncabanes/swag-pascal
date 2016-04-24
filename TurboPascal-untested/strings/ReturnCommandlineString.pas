(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0031.PAS
  Description: Return commandline string
  Author: MARTIN RICHARDSON
  Date: 09-26-93  08:48
*)

{*****************************************************************************
 * Function ...... Command
 * Purpose ....... To return the command line as a string
 * Parameters .... None
 * Returns ....... The entire command line as one string
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION Command: STRING;
BEGIN
     Command := STRING( PTR(PREFIXSEG, $0080)^ );
END;


