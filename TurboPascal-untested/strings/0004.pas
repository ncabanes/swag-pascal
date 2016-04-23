Function FirstOccurence(s : String;
                        c : Char) : Integer; Assembler;
Asm
  CLD
  LES    DI, s
  xor    CH, CH
  xor    AH, AH
  MOV    CL, ES:[DI]
  JCXZ   @1
  MOV    BX, CX
  inC    DI
  MOV    AL, c
  REPNE  SCASB
  JCXZ   @1
  SUB    BX, CX
  XCHG   AX, BX
  JMP    @2
@1:
  xor    AX, AX
@2:
end;

begin   { This example returns 7 }
  WriteLn(FirstOccurence('smullen met de pet op dat is pas je ware', 'n'));
end.
