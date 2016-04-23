Unit Tools;
Interface

Function DriveValid(Drive: Char): Boolean;
Function SelectDrive(Drive: Char): Word;

Implementation

Function DriveValid;
Assembler;
Asm
  Mov  Ah,19h
  Int  21h
  Mov  Bl,Al
  Mov  Dl,Drive
  Sub  Dl,'A'
  Mov  Ah,0Eh
  Int  21h
  Mov  Ah,19h
  Int  21h
  Mov  Cx,0
  Cmp  Al,Dl
  Jne  @@1
  Mov  Cx,1
  Mov  Dl,Bl
  Mov  Ah,0Eh
  Int  21h
@@1:
  Xchg Ax,Cx
End;

Function SelectDrive;
Assembler;
Asm
  Mov  Dl,Drive
  Sub  Dl,'A'
  Mov  Ah,0Eh
  Int  21h
End;

End.
