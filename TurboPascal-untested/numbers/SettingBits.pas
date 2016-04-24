(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0041.PAS
  Description: Setting BITS
  Author: FRANK BITTERLICH
  Date: 02-05-94  07:56
*)

{
 >   This would seem like something simple but can
 > someone explain how to
 >   calculate what is included in the following
 > statement once I have read
 >   the variable:
Looks like a user record of some BBS system or so...

Or did you want to know how to check / set the bits? }

FUNCTION GetBit (v, BitNumber: BYTE): BOOLEAN;
   BEGIN
      IF (v AND (1 SHL BitNumber))<>0 THEN
         GetBit:=TRUE
      ELSE
         GetBit:=FALSE;
   END;     {Returns TRUE if specified bit is set }

PROCEDURE SetBit (VAR v: Byte; BitNumber: Byte; SetReset: BOOLEAN);
   BEGIN
      IF SetReset THEN
         v:=v OR (1 SHL BitNumber)
      ELSE
         v:=v AND NOT (1 SHL BitNumber);
   END;


