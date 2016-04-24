(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0032.PAS
  Description: Extended Cursor Handling unit
  Author: CHAD MOORE
  Date: 05-30-97  18:17
*)


{ Author:  Chad Moore

  I have been writing my own multipurpose units for projects for quite some
  time now, and I noticed how all of the cursor routines in the SWAG used
  BIOS calls, well, I just happened to be writing an extended display unit
  for use with my display unit, and I figured you all could enjoy my
  routines.  They may not be as optomized as they could be, but they work.
  So, in other words, rip it, steal it, use it, distribute it, etc.

  Some of them may screw up while using the Crt unit, because it keeps track
  of cursor movement itself...  (remember, I have my OWN display unit...I
  hate the Crt one)  Anyway, they all DO work, but I am not responsible for
  any damages caused by these routines.  Oh, and the routines are all based
  on 0 through whatever - 1, rather than 1 through whatever.  (the way the
  computer would do it)

  If you would like to get information on the CRTC registers (the ones I
  used for this), Mode-X, sound, XMS/EMS/conventional memory, 3-D graphics,
  and much more, I recomend this book:

  PC Underground Unconventional Programming Topics
  from Abacus...

}

{ Extended alphanumeric display unit }
unit XDisplay;
{$G+} { Enable 286 instructions }

interface

procedure CursorOn;
  { turns the cursor ON }
procedure CursorOff;
  { turns the cursor OFF }
function CursorState : Boolean;
  { returns TRUE if the cursor is ON }
procedure CursorShape( StartScan, EndScan : Byte );
  { defines the cursor shape }
function GetCursorShape : Word;
  { high 8 bits = startscan, low 8 bits = endscan }
procedure CursorPosition( Column, Row : Byte );
  { positions the cursor }
function CursorColumn : Byte;
  { returns the cursor column }
function CursorRow : Byte;
  { returns the cursor row }

implementation

procedure CursorOn; assembler;
asm
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0AH          { select register 0Ah }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  AND   AL,0DFH         { bit 5 = 0 (Cursor on) }
  OUT   DX,AL
end;

procedure CursorOff; assembler;
asm
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0AH          { select register 0Ah }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  OR    AL,20H          { bit 5 = 1 (Cursor off) }
  OUT   DX,AL
end;

function CursorState : Boolean; assembler;
asm
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0AH          { select register 0Ah }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  AND   AL,20H          { if bit 5 = 1, cursor is off }
  CMP   AL,20H          { is bit 5 on? }
  JE    @@cursoroff
  MOV   AL,TRUE         { no, cursor is on }
  JMP   @@done          { return }
@@cursoroff:
  MOV   AL,FALSE        { yes, cursor is off }
@@done:
end;

procedure CursorShape( StartScan, EndScan : Byte ); assembler;
asm
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0AH          { select register 0Ah }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  MOV   AH,StartScan
  AND   AL,0E0H         { clear bits 0-4 }
  OR    AL,AH           { bits 0-4 = StartScan, save bits 5-7 }
  OUT   DX,AL
  DEC   DX              { CRTC index register }
  MOV   AL,0BH          { select register 0Bh }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  MOV   AH,EndScan
  AND   AL,0E0H         { clear bits 0-4 }
  OR    AL,AH           { bits 0-4 = EndScan, save bits 5-7 }
  OUT   DX,AL
end;

function GetCursorShape : Word; assembler;
asm
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0AH          { select register 0Ah }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  AND   AL,1FH          { clear bits 5-7 }
  MOV   AH,AL           { AH = startscan }
  DEC   DX              { CRTC index register }
  MOV   AL,0BH          { select register 0Bh }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  AND   AL,1FH          { clear bits 5-7 }
end;

procedure CursorPosition( Column, Row : Byte ); assembler;
asm
  { get cursor offset into BX }
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,13H          { select register 13H }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX
  MOV   AH,AL           { store row offset in AH }
  DEC   DX              { CRTC index register }
  MOV   AL,14H          { select register 14H }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX
  SHL   AH,01H          { multiply by 2 }
  AND   AL,40H          { check bit 5 for doubleword addressing }
  CMP   AL,00H          { doubleword? }
  JE    @@continue      { no, continue }
  SHL   AH,01H          { yes, multiply by 2 *more* }
@@continue:
                        { AH = row length }
  SHR   AX,08H          { AX = row length }
  MUL   Row             { row length * Row }
  MOV   BL,Column
  XOR   BH,BH
  ADD   AX,BX           { + Column }
  MOV   BX,AX           { BX = cursor offset }
  { send BX to CRTC }
  DEC   DX              { CRTC index register }
  MOV   AL,0EH          { select register 0EH (cursor offset HIGH) }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  MOV   AL,BH           { get HIGH to send }
  OUT   DX,AL
  DEC   DX              { CRTC index register }
  MOV   AL,0FH          { select register 0FH (cursor offset LOW) }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  MOV   AL,BL           { get LOW to send }
  OUT   DX,AL
end;

function CursorColumn : Byte; assembler;
asm
  { get cursor offset }
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0EH          { select register 0Eh }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX
  SHL   AX,08H          { AH = high bits }
  DEC   DX              { CRTC index register }
  MOV   AL,0FH          { select register 0Fh }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { AL = low bits }
  MOV   CX,AX           { save cursor offset }
  { get chars per line }
  DEC   DX              { CRTC index register }
  MOV   AL,14H          { select register 14h }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { doubleword addressing? }
  MOV   BL,AL           { save in BL }
  DEC   DX              { CRTC index register }
  MOV   AL,13H          { select register 13h }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get offset between 2 lines (line width) }
  SHL   AL,01H          { multiply by 2 }
  AND   BL,40H          { check bit 5 for doubleword addressing }
  CMP   BL,00H          { doubleword? }
  JE    @@continue      { no, continue }
  SHL   AL,01H          { multiply by 2 *more* }
@@continue:             { AL = chars per line }
  { calculate }
  XOR   AH,AH           { clear upper AX }
  MOV   BX,AX           { get chars per line in BX }
  XOR   DX,DX           { DX:AX gets ready for div }
  MOV   AX,CX           { get cursor offset }
  DIV   BX              { div DX = remainder, AX = answer }
  MOV   AX,DX           { get remainder }
end;

function CursorRow : Byte; assembler;
asm
  { get cursor offset }
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0EH          { select register 0Eh }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX
  SHL   AX,08H          { AH = high bits }
  DEC   DX              { CRTC index register }
  MOV   AL,0FH          { select register 0Fh }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { AL = low bits }
  MOV   CX,AX           { save cursor offset }
  { get chars per line }
  DEC   DX              { CRTC index register }
  MOV   AL,14H          { select register 14h }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { doubleword addressing? }
  MOV   BL,AL           { save in BL }
  DEC   DX              { CRTC index register }
  MOV   AL,13H          { select register 13h }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get offset between 2 lines (line width) }
  SHL   AL,01H          { multiply by 2 }
  AND   BL,40H          { check bit 5 for doubleword addressing }
  CMP   BL,00H          { doubleword? }
  JE    @@continue      { no, continue }
  SHL   AL,01H          { multiply by 2 *more* }
@@continue:             { AL = chars per line }
  { calculate }
  XOR   AH,AH           { clear upper AX }
  MOV   BX,AX           { get chars per line in BX }
  XOR   DX,DX           { DX:AX gets ready for div }
  MOV   AX,CX           { get cursor offset }
  DIV   BX              { div DX = remainder, AX = answer }
                        { returns AL }
end;

end.
