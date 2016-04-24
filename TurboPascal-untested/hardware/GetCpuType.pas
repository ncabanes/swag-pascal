(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0028.PAS
  Description: Get CPU Type
  Author: COLEK UMNICKI
  Date: 05-25-94  08:02
*)


{$D-} {$L-}
Program Cpuu;

Const
    Cpu      : Array[1..4] of String[5] = ('8086','80286','80386','80486');
    Cpu8086  = 1;
    Cpu80286 = 2;
    Cpu80386 = 3;
    Cpu80486 = 4;

Function GetCPU_Type: Byte; Assembler;
ASM
 MOV    DX, CPU8086
 PUSH   SP
 POP    AX
 CMP    SP,AX
 JNE    @OUT
 MOV    DX, CPU80286
 PUSHF

 POP    AX
 OR     AX,4000h
 PUSH   AX
 POPF
 PUSHF
 POP    AX
 TEST   AX,4000H
 JE     @OUT
 MOV    DX,CPU80386
 {"DB 66h" INDICATES '386 EXTENDED INSTRUCTION}
 DB 66h
 MOV    BX,SP
 DB 66h, 83h, 0E4h, 0FCh
 DB 66h
 PUSHF
 DB 66h
 POP AX
 DB 66h
 MOV    CX,AX
 DB 66h, 35h, 00h
 DB 00h, 04h, 00
 DB 66h
 PUSH   AX
 DB 66h
 POPF
 DB 66h
 PUSHF
 DB 66h
 POP    AX
 DB 66h,25h, 00h
 DB 00h, 04h, 00h
 DB 66h, 81h, 0E1h, 00h
 DB 00h, 04h, 00h
 DB 66h
 CMP    AX,CX
 JE @NOT486
 MOV DX, CPU80486
@NOT486:
 DB 66h
 PUSH   CX
 DB 66h
 POPF
 DB 66h
 MOV    SP,BX
@OUT:
 MOV    AX,DX
End;

Begin
    Writeln; Writeln('I detected an ',Cpu[GetCpu_Type],' chip.');
End.

