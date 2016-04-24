(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0049.PAS
  Description: Binary and Hexidecimal
  Author: DAVID DUNSON
  Date: 05-26-94  06:16
*)

{
I've seen requests for these two procedures several times, and finally got
around to writing them in ASM.

{ ------- CUT HERE ------- }

(* Hex converts a number (num) to Hexadecimal.                      *)
(*    num  is the number to convert                                 *)
(*    nib  is the number of Hexadecimal digits to return            *)
(* Example: Hex(31, 4) returns '001F'                               *)

Function Hex(num: Word; nib: Byte): String; Assembler;
ASM
      PUSHF
      LES  DI, @Result
      XOR  CH, CH
      MOV  CL, nib
      MOV  ES:[DI], CL
      JCXZ @@3
      ADD  DI, CX
      MOV  BX, num
      STD
@@1:  MOV  AL, BL
      AND  AL, $0F
      OR   AL, $30
      CMP  AL, $3A
      JB   @@2
      ADD  AL, $07
@@2:  STOSB
      SHR  BX, 1
      SHR  BX, 1
      SHR  BX, 1
      SHR  BX, 1
      LOOP @@1
@@3:  POPF
End;


(* Binary converts a number (num) to Binary.                        *)
(*    num  is the number to convert                                 *)
(*    bits is the number of Binary digits to return                 *)
(* Example: Binary(31, 16) returns '0000000000011111'               *)

Function Binary(num: Word; bits: Byte): String; Assembler;
ASM
      PUSHF
      LES  DI, @Result
      XOR  CH, CH
      MOV  CL, bits
      MOV  ES:[DI], CL
      JCXZ @@3
      ADD  DI, CX
      MOV  BX, num
      STD
@@1:  MOV  AL, BL
      AND  AL, $01
      OR   AL, $30
      STOSB
      SHR  BX, 1
      LOOP @@1
@@3:  POPF
End;

{ ------- CUT HERE ------- }

These procedures are fully optomized to my knowledge and have been tested
against normal Pascal routines that perform the same functions.  Test results
returned that Hex performed aprox. 2.14 times faster than it's Pascal
equivilent, and Binary performed aprox. 14 times faster than it's Pascal
equivilent.

Enjoy!
David

