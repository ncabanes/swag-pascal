(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0015.PAS
  Description: Turn cursor on (ASM)
  Author: MARTIN RICHARDSON
  Date: 09-26-93  08:49
*)

{****************************************************************************
 * Procedure ..... CsrOn
 * Purpose ....... To turn the cursor on
 * Parameters .... None
 * Returns ....... N/A
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE CsrOn; ASSEMBLER;
ASM
       MOV  AH, 1
       MOV  CX, 0607h
       INT  10h
END;


