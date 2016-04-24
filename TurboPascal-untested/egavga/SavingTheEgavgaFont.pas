(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0270.PAS
  Description: Saving the EGA/VGA Font
  Author: LDEBOER@IBM.NET
  Date: 05-31-96  09:17
*)

USES Graph;

TYPE

   TByteArray = Array [0..16384] Of Byte;
   PByteArray = ^TByteArray;

VAR I, J: Integer; BiosFont: PByteArray; F: Text;

PROCEDURE GetBiosFont; ASSEMBLER;
ASM
   PUSH BP;
   PUSH DS;
   MOV AX, 1130H;
   MOV BX, 0100H;
   INT 10H;
   MOV BX, BP;
   POP DS;
   POP BP;
   MOV WORD PTR [BiosFont], BX;
   MOV WORD PTR [BiosFont+2], ES;
END;

FUNCTION Hex (Num: Word; Nib: Byte): String; ASSEMBLER;
ASM
   LES DI, @Result;                                   { ES:DI -> return }
   XOR CH, CH;
   MOV CL, Nib;                                       { String length }
   MOV ES:[DI], CL;
   JCXZ @@3;                                          { Check for zero }
   ADD DI, CX;
   MOV BX, Num;
   STD;                                               { Strings backwards }
@@1:
   MOV AL, BL;                                        { Current nibble }
   AND AL, $0F;
   OR AL, $30 ;                                       { Convert to ascii }
   CMP AL, $3A;
   JB @@2;                                            { Contains A-F patch }
   ADD  AL, $07;
@@2:
   STOSB;                                             { Store the byte }
   SHR BX, 1;
   SHR BX, 1;
   SHR BX, 1;                                         { Roll of nible done }
   SHR BX, 1;
   LOOP @@1;
@@3:
   CLD;                                               { Reset direction }
END;

    BEGIN
       InitGraph(I, J, '');
       GetBiosFont;
       Assign(F, 'BiosFont.Bin');
       Rewrite(F);
       WriteLn(F, 'BiosFont: Array [0..4096] Of Byte = (');
       For J := 0 To 255 Do Begin
         For I := 0 To 15 Do Begin
            Write(F, '$', Hex(BiosFont^[J*16+I], 2), ',');
         End;
         WriteLn(F);
       End;
       WriteLn(F, '0);');
       Close(F);
       CloseGraph;
    END.


