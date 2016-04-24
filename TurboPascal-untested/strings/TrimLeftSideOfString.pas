(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0045.PAS
  Description: Trim LEFT side of STRING
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:15
*)

{*****************************************************************************
 * Function ...... LTrim()
 * Purpose ....... To trim a character off the left side of a string
 * Parameters .... s       String to trim
 *                 c       Character to trim from <s>
 * Returns ....... <s> with all characters <c> removed from the left side
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION LTrim( s: STRING; c: CHAR ): STRING; Assembler;
ASM
      PUSH   DS
      LDS    SI, s
      XOR    AX, AX
      LODSB
      XCHG   AX, CX
      LES    DI, @Result
      INC    DI
      JCXZ   @@2

      MOV    BL, c
      CLD
@@1:  LODSB
      CMP    AL, BL
      LOOPE  @@1
      DEC    SI
      INC    CX
      REP    MOVSB

@@2:  XCHG   AX, DI
      MOV    DI, WORD PTR @Result
      SUB    AX, DI
      DEC    AX
      STOSB
      POP    DS
END;


