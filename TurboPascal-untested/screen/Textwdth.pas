(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0016.PAS
  Description: TEXTWDTH.PAS
  Author: KELD HANSEN
  Date: 05-28-93  13:56
*)

{ Keld Hansen }
Procedure SetCrtC; NEAR; Assembler;
Const
  HorizParms : Array[1..2,1..7] of Word =
               (($6A00,$5901,$5A02,$8D03,$6004,$8505,$2D13),
                ($5F00,$4F01,$5002,$8203,$5504,$8105,$2813));
Asm
  PUSH    DX
  MOV     DX,ES:[0063h]
  PUSH    BX
  MOV     AX,1110h
  xor     CX,CX
  INT     10h
  POP     BX
  MOV     AL,11h
  OUT     DX,AL
  INC     DX
  in      AL,DX
  DEC     DX
  MOV     AH,AL
  MOV     AL,11h
  PUSH    AX
  and     AH,7Fh
  OUT     DX,AX
  xor     BH,BH
  SUB     BL,8
  NEG     BX
  and     BX,14
  LEA     SI,[BX+OFFSET HorizParms]
  MOV     CX,7
@LOOP:  LODSW
  OUT     DX,AX
  LOOP    @LOOP
  POP     AX
  OUT     DX,AX
  POP     DX
end;

Procedure SetCharWidth(W : Word); Assembler;
Asm
  MOV     ES,Seg0040
  MOV     BL,Byte PTR W
  MOV     BH,ES:[0085h]
  CALL    SetCrtC
  MOV     DX,03C4h
  MOV     AX,0100h
  CLI
  OUT     DX,AX
  MOV     BX,0001h
  CMP     W,8
  JE      @L01
  MOV     BX,0800h
@L01:       MOV     AH,BL
  MOV     AL,1
  OUT     DX,AX
  MOV     AX,0300h
  OUT     DX,AX
  STI
  MOV     BL,13h
  MOV     AX,1000h
  INT     10h
  MOV     AX,1000h
  MOV     BX,0F12h
  INT     10h
  xor     DX,DX
  MOV     AX,720
  div     W
  MOV     ES:[004Ah],AX
end;

{
SetCharWidth can then be called With 8 (giving 90 Characters per line) or 9
(giving 80 Characters per line) after having switched into f.ex. 80x28 (by
selecting the appropriate number of scan lines and font size).
}

