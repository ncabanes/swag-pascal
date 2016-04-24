(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0032.PAS
  Description: Determine empty string
  Author: MARTIN RICHARDSON
  Date: 09-26-93  08:51
*)

{*****************************************************************************
 * Function ...... Empty()
 * Purpose ....... To determine if a string is empty
 * Parameters .... s          String to check
 * Returns ....... TRUE if <s> is 0 bytes in length, or is filled with #0 or
 *                 spaces.
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION Empty( s: STRING ): BOOLEAN; ASSEMBLER;
ASM
       CLD
       XOR   CH, CH
       LES   DI, s
       MOV   CL, BYTE PTR ES:[DI]
       JCXZ  @@1
       INC   DI
       MOV   AL, ' '
       REPE  SCASB
       JZ    @@1          { empty }
       MOV   AL, False
       JMP   @@2
@@1:   MOV   AL, True
@@2:
END;


