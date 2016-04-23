{*****************************************************************************
 * Function ...... MinI()
 * Purpose ....... To return the lesser of two integers
 * Parameters .... nNum1, nNum2     The integers to compare
 * Returns ....... The lesser of nNum1 and nNum2
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... September 30, 1992
 *****************************************************************************}
FUNCTION MinI( nNum1, nNum2: LONGINT ): LONGINT; ASSEMBLER;
ASM
     MOV  AX, WORD PTR nNum1[0]
     MOV  DX, WORD PTR nNum1[2]
     CMP  DX, WORD PTR nNum2[2]
     JL   @@2
     JNLE @@1

     CMP  AX, WORD PTR nNum2[0]
     JB   @@2

@@1: MOV  AX, WORD PTR nNum2[0]
     MOV  DX, WORD PTR nNum2[2]
@@2:
END;
