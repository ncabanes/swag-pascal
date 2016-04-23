{
FreeWare by Emmanuel CECCHET
(C) 1992 3D CONCEPT PRODUCTION
}

Procedure Cold_Boot; Assembler;
Asm
  mov AX,1700h
  int 14h
end;

Procedure Warm_Boot; Assembler;
Asm
  mov AX,1701h
  int 14h
end;
