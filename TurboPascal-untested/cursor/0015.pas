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