
Uses CRT;

  Procedure Sound (Hertz : Word);Assembler;
  Asm
    Mov  Bx,SP
    Mov  Bx,&Hertz
    Mov  Ax,34DDh
    Mov  Dx,0012h
    CMP  Dx,Bx
    JNB  @J1
    Div  Bx
    Mov  Bx,Ax
    In   Al,61h
    Test Al,03h
    JNZ  @J2
    OR   Al,03h
    OUT  61h,Al
    Mov  Al,-4Ah
    OUT  43h,Al
   @J2:
    Mov  Al,Bl
    OUT  42h,Al
    Mov  Al,Bh
    Out  42h,Al
   @J1:
  End; {Sound}

  Procedure NoSound;Assembler;
  Asm
    IN  AL,61h
    AND AL,0FCh
    OUT 61h,AL
  End;

Begin

      SOUND (150);
      DELAY (100);
      SOUND (400);
      DELAY (100);
      NOSOUND;
END.