(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0038.PAS
  Description: IF Boolean processing
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:09
*)

{*****************************************************************************
 * Function ...... CIF()
 * Purpose ....... To return a character based on a boolean expression
 * Parameters .... Exp        Boolean expression to evaluate
 *                 tVar       Result if <Exp> is TRUE
 *                 fVar       Result if <Exp> is FALSE
 * Returns ....... <tVar> if <Exp> is TRUE, <fVar> if <Exp> is FALSE
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION CIF( Exp: BOOLEAN; tVar, fVar: CHAR ): CHAR; ASSEMBLER;
ASM
     TEST Exp, 1
     JZ   @@1
     MOV  AL, tVar
     JMP  @@2
@@1: MOV  AL, fVar
@@2:
END;

{*****************************************************************************
 * Function ...... SIF()
 * Purpose ....... To return a string based on a boolean expression
 * Parameters .... Exp        Boolean expression to evaluate
 *                 tVar       Result if <Exp> is TRUE
 *                 fVar       Result if <Exp> is FALSE
 * Returns ....... <tVar> if <Exp> is TRUE, <fVar> if <Exp> is FALSE
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION SIF( Exp: BOOLEAN; tVar, fVAR: STRING ): STRING; ASSEMBLER;
ASM
       PUSH DS
       TEST Exp, 1
       JZ   @@1
       LDS  SI, tVar
       JMP  @@2
@@1:   LDS  SI, fVar
@@2:   LES  DI, @Result
       XOR  CH, CH
       MOV  CL, BYTE PTR DS:[SI]
       MOV  BYTE PTR ES:[DI], CL
       INC  DI
       INC  SI
       CLD
       REP  MOVSB
       POP  DS
END;

{*****************************************************************************
 * Function ...... IIF()
 * Purpose ....... To return an integer based on a boolean expression
 * Parameters .... Exp        Boolean expression to evaluate
 *                 tVar       Result if <Exp> is TRUE
 *                 fVar       Result if <Exp> is FALSE
 * Returns ....... <tVar> if <Exp> is TRUE, <fVar> if <Exp> is FALSE
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION IIF( Exp: BOOLEAN; tVar, fVar: LONGINT ): LONGINT; ASSEMBLER;
ASM
     TEST Exp, 1
     JZ   @@1
     MOV  AX, WORD PTR tVar[0]
     MOV  DX, WORD PTR tVar[2]
     JMP  @@2
@@1: MOV  AX, WORD PTR fVar[0]
     MOV  DX, WORD PTR fVar[2]
@@2:
END;

{*****************************************************************************
 * Function ...... RIF()
 * Purpose ....... To return a real based on a boolean expression
 * Parameters .... Exp        Boolean expression to evaluate
 *                 tVar       Result if <Exp> is TRUE
 *                 fVar       Result if <Exp> is FALSE
 * Returns ....... <tVar> if <Exp> is TRUE, <fVar> if <Exp> is FALSE
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION RIF( Exp : BOOLEAN; tVar, fVAR : REAL ) : REAL;
BEGIN
     IF Exp THEN RIF := tVAR ELSE RIF := fVar;
END;

