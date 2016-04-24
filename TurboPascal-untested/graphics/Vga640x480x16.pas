(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0121.PAS
  Description: VGA 640X480x16
  Author: OLAF BARTELT
  Date: 08-24-94  13:50
*)

{
 NV>     Could somebody tell me how to use mode 640x480x16? I
 NV> don't mean using     it with int 10, 'cause it's too slow,
 NV> but writing directly to VGA     memory. So how do I draw a
 NV> pixel and how do I read a pixel?
well, you set the mode with:

      ASM MOV AX, 12h; INT 10h; END;

and then draw a pixel with: }

PROCEDURE plot_640x480x16(x, y : WORD; c : BYTE); ASSEMBLER;
ASM
  {$IFDEF DPMI}
  MOV ES, SEGA000
  {$ELSE}
  MOV AX, $A000
  MOV ES, AX
  {$ENDIF}
  MOV DI, x
  MOV CX, DI
  SHR DI, 3
  MOV AX, 80
  MUL y
  ADD DI, AX
  AND CL, $07
  MOV AH, $80
  SHR AH, CL
  MOV AL, $08
  MOV DX, $03CE
  OUT DX, AX
  MOV AL, c
  MOV AH, [ES:DI]
  MOV [ES:DI], AL
END;


{ and read a pixel with: }


FUNCTION point_640x480x16(x, y : WORD) : BYTE; ASSEMBLER;
ASM
  MOV  AX, 80
  MUL  y
  MOV  SI, x
  MOV  CX, SI
  SHR  SI, 3
  ADD  SI, AX
  AND  CL, $07
  XOR  CL, $07
  MOV  CH, 1
  SHL  CH, CL
  {$IFDEF DPMI}
  MOV  ES, SEGA000
  {$ELSE}
  MOV  AX, $A000
  MOV  ES, AX
  {$ENDIF}
  MOV  DX, $03CE
  MOV  AX, 772
  XOR  BL, BL
@gp1:
  OUT  DX, AX
  MOV  BH, ES:[SI]
  AND  BH, CH
  NEG  BH
  ROL  BX, $0001
  DEC  AH
  JGE  @gp1
  MOV  AL, BL
END;


