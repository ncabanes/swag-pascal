(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0042.PAS
  Description: Convert STRING to INTEGER
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:28
*)

{*****************************************************************************
 * Function ...... STOI()
 * Purpose ....... To convert a string to an integer
 * Parameters .... cNum       String to convert to integer format
 * Returns ....... cNum as a numeric integer
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION STOI( cNum: STRING ): LONGINT;
VAR
   c: INTEGER;
   i: LONGINT;
BEGIN
     VAL( cNum, i, c );
     STOI := i;
END;


