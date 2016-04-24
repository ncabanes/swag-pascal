(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0015.PAS
  Description: TEXTMODE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
 A small follow-up to the VGA tricks:
 how about a 40x12 Textmode (posted earlier in the Assembler conference):
}

Procedure Set12x40; Assembler;
Asm
  MOV     AX, 1
  inT     $10            { activate 40x25 Text With BIOS }
  MOV     DX, $03D4      { CrtC }
  MOV     AL, 9          { maximum scan line register }
  OUT     DX, AL
  inC     DX
  in      AL, DX
  or      AL, $80        { Double each scan-line   bit7 = 1 }
  OUT     DX, AL
  MOV     AX, $0040      { set up BIOS data area access }
  MOV     ES, AX
  MOV     AL, $0B        { BIOS txtlines on 12 = $B +1 }
  MOV     ES:[$0084], AL { so Programs like QEDIT will work With this }
end;


