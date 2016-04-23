{****************************************************************************
 * Procedure ..... SetBright;
 * Purpose ....... To enable intensity vice blinking
 * Parameters .... None
 * Returns ....... Nothing
 * Notes ......... Colors with the background attribute high-bit set will
 *                 show the background in bright colors.
 * Author ........ Martin Richardson
 * Date .......... October 28, 1992
 ****************************************************************************}
PROCEDURE SetBright; ASSEMBLER;
ASM
   MOV  AX, 1003h
   XOR  BL, BL
   INT  10h
END;

