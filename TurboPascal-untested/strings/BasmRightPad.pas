(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0074.PAS
  Description: BASM Right Pad
  Author: MAYNARD PHILBROOK
  Date: 02-03-94  16:18
*)


Procedure RightPas(Var S:String; MaxLen:Byte);
 Begin
 ASm
       LES     BX, S;
       ESSeg
       Mov     AL, [ES:BX];
      Xor      AH, AH;
       Add     BX, AX;
@@Loop:
       Cmp     AL, MaxLen;
       Jge     @@Done;
       Mov     Word Ptr [ES:BX],' ';
       Inc     BX;

       Inc     AL;
       Jmp     @@Loop;
@@Done:
End;

