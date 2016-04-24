(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0045.PAS
  Description: Improved Decimal To Binar
  Author: VARIOUS
  Date: 05-25-94  08:08
*)


{Convert a Decimal to a String - Maximum number of bits = 16}

Function Dec2Bin (D: Word; No_Bits: Byte): String;
Var A   : Word;
    L   : Byte;
    S   : String;
Begin
   S := '';
   A := Trunc (Exp ((No_Bits-1)*Ln (2)));
   For L := No_Bits downto 1 do
   Begin
      A := A div 2;
      If (D AND A)=A then S := S+'1' else S := S+'0';
   End;
   Dec2Bin := S;
End;

(*------------------------------------------------------*)
Function BinStr(num:word;bits:byte):string; assembler;
ASM
      PUSHF
      LES  DI, @Result
      XOR  CH, CH
      MOV  CL, bits
      MOV  ES:[DI], CL
      JCXZ @@3
      ADD  DI, CX
      MOV  BX, num
      STD
@@1:  MOV  AL, BL
      AND  AL, $01
      OR   AL, $30
      STOSB
      SHR  BX, 1
      LOOP @@1
@@3:  POPF
End;


