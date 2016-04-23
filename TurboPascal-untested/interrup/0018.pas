{
Via SLMAIL v3.5C  (#2081)
 -=> Quoting Joe Irwin to Maynard Philbrook <=-
 JI> either inline code or assembler that could be compiled to obj and
 JI> linked that would read the keyboard and if a key is not pressed in a
 JI> variable or set amount of time jump to a procedure.  I'm talking about
 JI> a tsr routine and what I have in mind is a tsr dos screensaver.  I've
 JI> been working on this forever and am just not good enough with interupts
 JI> or assembler to do it. I'm using tp 5.5 which does not support the asm
 JI> command but inline(/) only.  Any help would be appreciated.
 JI> Joe Irwin
 JI> -!- FMail 0.92
 JI>  ! Origin: MK Tech BBS-MK Software (513)237-7737 Dayton,OH HST/v32
 JI> (1:110/290)
}

Uses dos,crt;

Const Set_Time :Word = 100;      { 0 for no blanking }
Var
Temp,Temp1 : Integer;
C :Char;
Old_Screen :Array[0..1999] of Word;
OLD_INT9, OLD_INT8 :Pointer;
NO_Pressed :Word;      { Counter }
Saved_Flag :Word;       { varifie Flag }

{$F+}
Procedure New_Int9; Assembler;     { all of this could be done in TASM }
asm     Push   ES;
       Push    DS;
        Push   BX;
        Push   AX;
        Mov    AX, Seg NO_Pressed;
        Mov    DS, AX;
        Mov    AX, Set_TIme;
        Mov    NO_Pressed, AX;
        Mov    AX, Word [Old_INT9];
        Mov     Word ptr CS:@Return, AX;
        Mov    AX, Word [OLD_INT9+2];
        Mov    Word ptr CS:@Return+2, AX;
        Cmp    Word Ptr Saved_Flag, 00;
        Je     @Done;
       Mov     Word ptr Saved_Flag, 00;
        Mov    BX, 3999;
        Mov    AX, $B800;
        Mov    ES, AX;
@loop:
       Mov     AL, byte [OLD_SCREEN+BX];
       Mov     [ES:BX], AL;
        Dec    BX;
        Jnz    @Loop;
        Mov    AL, byte [OLD_SCREEN+BX];
        Mov    [ES:BX], AL;
@Done:
        Pop    AX;
        Pop    BX;
        Pop    DS;
        Pop    ES;
        Jmp  [Dword(@Return)];
@Return:
       DD      0;
End;

Procedure New_Int8; Assembler;
ASm
       Push    ES;
       Push    DS;
        Push    BX;
        Push    AX;
        Mov    AX, Seg NO_Pressed;
        Mov    DS, AX;
        Mov    AX, Word [Old_INT8];
        Mov     Word ptr @Return, AX;
        Mov    AX, Word [OLD_INT8+2];
        Mov    Word ptr @Return+2, AX;
        Cmp    NO_PRESSED, $00;
        Je     @Done;
        Dec    Word Ptr NO_PRESSED;
        Jnz    @Done;
        Mov    Saved_Flag, $01;
       Mov     AX, $B800;
        Mov    ES, AX;
       Mov     BX, 3999;
@loop:
       Mov     AL, byte ptr [ES:BX];
       Mov     byte  ptr OLD_SCREEN+BX, AL;
        Mov    byte [ES:BX], 0 ;
        Dec    BX;
        Jnz    @Loop;
        Mov    AL, byte ptr [ES:BX];
        Mov    byte ptr OLD_SCREEN+BX, AL;
@DONE:
        Pop    AX;
        Pop    BX;
        Pop    DS;
        Pop    ES;
        Jmp    [Dword(@Return)];
@Return:
       DD      0;
End;

BEGIN

   Val(Paramstr(1), Temp, Temp1);
   If Temp1 = 0 Then Set_Time := temp*18;
   NO_PRESSED := Set_Time;
   SAVED_FLAG := 00;
   GetIntVec($08, OLD_INT8);
   GetIntVec($09, OLD_INT9);
   SetIntVec($09, @New_Int9);
   SetIntVec($08, @New_Int8);


   While NOT Keypressed DO;
   { process  your program here }

SetIntVec($08, old_int8);      { to restore it back to normal }
SetIntVec($09, old_int9);
CLrScr;
WriteLn(' Program Writen Bye Maynard A. Phibrook Jr. ');
WriteLn('          1-203-456-2521  (1993)');

END.
