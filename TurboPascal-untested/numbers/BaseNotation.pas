(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0036.PAS
  Description: Base Notation
  Author: GREG VIGNEAULT
  Date: 11-21-93  09:24
*)


{ How about a procedure that will display any integer in any base
 notation from 2 to 16?  The following example displays the values
 0 through 15 in binary (base 2), octal (base 8), decimal (base 10)
 and hexadecimal (base 16) notations ... }

(********************************************************************)
PROGRAM BaseX;                      (* compiler: Turbo Pascal v4.0+ *)
                                    (* Nov.14.93 Greg Vigneault     *)
(*------------------------------------------------------------------*)
(* Display any INTEGER in any base notation from 2 to 16...         *)
(*                                                                  *)
(*    number base 2  = binary notation       (digits 0,1)           *)
(*    number base 8  = octal notation        (digits 0..7)          *)
(*    number base 10 = decimal notation      (digits 0..9)          *)
(*    number base 16 = hexadecimal notation  (digits 0..9,A..F)     *)

PROCEDURE DisplayInteger (AnyInteger :INTEGER; NumberBase :BYTE);
  CONST DataSize = 16;  (* bit-size of an INTEGER *)
  VAR   Index : INTEGER;
        Digit : ARRAY [1..DataSize] OF CHAR;
  BEGIN
    IF (NumberBase > 1) AND (NumberBase < 17) THEN BEGIN
      Index := 0;
      REPEAT
        INC (Index);
        Digit [Index] := CHR(AnyInteger MOD NumberBase + ORD('0'));
        IF (Digit [Index] > '9') THEN INC (Digit [Index],7);
        AnyInteger := AnyInteger DIV NumberBase;
      UNTIL (AnyInteger = 0) OR (Index = DataSize);
      WHILE (Index > 0) DO BEGIN
        Write (Digit [Index]);
        DEC (Index);
      END; {WHILE Index}
    END; {IF NumberBase}
  END {DisplayInteger};

(*------------------------------------------------------------------*)
(*  to test the DisplayInteger procedure...                         *)

VAR Base, Number : INTEGER;

BEGIN
      FOR Base := 2 TO 16 DO
        CASE Base OF
          2,8,10,16 : BEGIN
                        WriteLn;
                        CASE Base OF
                          2  : Write ('Binary : ');
                          8  : Write ('Octal  : ');
                          10 : Write ('Decimal: ');
                          16 : Write ('Hex    : ');
                        END; {CASE}
                        FOR Number := 0 TO 15 DO BEGIN
                          DisplayInteger (Number, Base);
                          Write (' ');
                        END; {FOR}
                      END;
        END; {CASE}
      WriteLn;

END {BaseX}.

