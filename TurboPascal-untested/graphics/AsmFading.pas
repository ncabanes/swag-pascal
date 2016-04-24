(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0009.PAS
  Description: ASM Fading
  Author: STEPHEN CHEOK
  Date: 08-27-93  20:03
*)

{
STEPHEN CHEOK

> Could you post the fade out source?
}

PROCEDURE DimDisplay(delayfactor : INTEGER); ASSEMBLER;

{ Total time to fade out in seconds = ((DelayFactor+1)*MaxIntensity) / 1000 }

CONST
  MaxIntensity = 45;
 {MaxIntensity = 63;}

VAR
  DACTable : Array [0..255] OF RECORD
               R, G, B : BYTE;
             END;
ASM
  PUSH   DS
  MOV    AX, SS
  MOV    ES, AX
  MOV    DS, AX

 { Store colour information into DACTable }

  LEA    DX, DACTable
  MOV    CX, 256
  XOR    BX, BX
  MOV    AX, 1017h
  INT    10h

  MOV    BX, MaxIntensity

 { VGA port 3C8h: PEL address register, (colour index,
 increments automatically after every third write)
 VGA port 3C9h: PEL write register (R, G, B) }

  CLD
 @1:
  LEA    SI, DACTable
  MOV    DI, SI
  MOV    CX, 3*256
  XOR    AX, AX
  MOV    DX, 3C8h
  OUT    DX, AL
  INC    DX

 { Get colour value, decrement it and update the table }

 @2:
  LODSB
  OR     AX, AX
  JZ     @3
  DEC    AX
 @3:
  STOSB
  OUT    DX, AL
  LOOP   @2

 { Delay before next decrement of R, G, B values }

  PUSH   ES
  PUSH   BX
  MOV    AX, DelayFactor
  PUSH   AX
  CALL   Delay
  POP    BX
  POP    ES

  DEC    BX
  OR     BX, BX
  JNZ    @1
  POP    DS
END;  { DimDisplay }



