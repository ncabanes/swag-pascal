{
RAPHAEL VANNEY

> I've got a question about BAsm: How would I go about accessing a local
> Variable in an assembly block?  I know that locals are stored on the
> stack: Var temp:Byte;
}

Procedure TestLocal(Var a : Integer); Assembler;
Var
  i    : Byte;
  Stri : String;
Asm
  { Getting Pointers... }
  Push SS
  Pop  ES
  LEA  SI, i     { ES:SI points to i }
  LEA  DI, Stri  { ...and ES:DI points to Stri }

  { if you Really need DS as a segment... }
  Push DS        { Save DS }
  Mov  AX, SS    { Copy SS to AX... }
  Mov  DS, AX    { ...then to DS }
  LEA  DX, Stri  { DS:DX points to Stri }
  Pop  DS        { Restore DS }

  LES  DX, a     { ES:DX points to a }

  { Now using local Vars }
  Inc  i
  Mov  i, 10
  { etc... }
end;

