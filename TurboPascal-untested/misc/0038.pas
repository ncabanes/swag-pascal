{*****************************************************************************
 * Function ...... MaxI()
 * Purpose ....... To return the greater of two integers
 * Parameters .... nNum1, nNum2     The integers to compare
 * Returns ....... The greater of nNum1 and nNum2
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... September 30, 1992
 *****************************************************************************}
FUNCTION MaxI( nNum1, nNum2: LONGINT ): LONGINT; ASSEMBLER;
ASM
     MOV  AX, WORD PTR nNum1[0]
     MOV  DX, WORD PTR nNum1[2]
     CMP  DX, WORD PTR nNum2[2]
     JNLE @@2
     JL   @@1

     CMP  AX, WORD PTR nNum2[0]
     JA   @@2

@@1: MOV  AX, WORD PTR nNum2[0]
     MOV  DX, WORD PTR nNum2[2]
@@2:
END;
