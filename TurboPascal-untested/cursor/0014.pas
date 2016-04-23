{****************************************************************************
 * Procedure ..... CsrOff
 * Purpose ....... To turn the cursor off
 * Parameters .... None
 * Returns ....... N/A
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE CsrOff; ASSEMBLER;
ASM
       MOV  AH, 1
       MOV  CX, 1400h
       INT  10h
END;

