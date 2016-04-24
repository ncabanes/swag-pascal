(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0023.PAS
  Description: Compare Memory Blocks
  Author: JOACHIM BARTZ
  Date: 08-27-93  20:27
*)

{ JOACHIM BARTZ }

Function CompBlocks(Buf1, Buf2 : Pointer;
                          BufSize : Word) : Boolean; Assembler;
Asm                 { Compares two buffers and returns True if contents are equal }
  PUSH        DS
  MOV          AX,1                { Init error return: True }
  LDS          SI,Buf1
  LES          DI,Buf2
  MOV          CX,BufSize
  JCXZ        @@Done
  CLD                            { Loop Until different or end of buffer }
  REP          CMPSB       { Flag to bump SI,DI }
  JE          @@Done
                          { Compare error }
  XOR          AX, AX            { Return False }
 @@Done:
  POP          DS                { Restore }
end;

