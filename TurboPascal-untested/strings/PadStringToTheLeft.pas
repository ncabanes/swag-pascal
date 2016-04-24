(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0046.PAS
  Description: Pad STRING to the LEFT
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:21
*)

{*****************************************************************************
 * Function ...... PadL()
 * Purpose ....... To pad the left side of a string with a character
 * Parameters .... s      String to pad
 *                 c      Character to pad with
 *                 n      New length for <s>
 * Returns ....... <s> padded with character <c> with length <n>
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION PADL( s: STRING; n: BYTE; c: CHAR ): STRING; ASSEMBLER;
ASM
      PUSH   DS
      CLD

      LES    DI, @Result
      INC    DI
      LDS    SI, s
      XOR    AX, AX
      LODSB
      PUSH   AX

      XOR    CX, CX
      MOV    CL, n
      SUB    CL, AL

      CMP    CX, 0
      JNB    @@1
      XOR    CX, CX

@@1:  MOV    AL, c
      REP    STOSB

      POP    CX
      REP    MOVSB

      MOV    DI, WORD PTR @Result
      MOV    AL, n
      MOV    BYTE PTR ES:[DI], AL
      POP    DS
END;

