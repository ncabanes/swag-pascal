
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