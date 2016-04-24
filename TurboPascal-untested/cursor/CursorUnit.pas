(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0023.PAS
  Description: Cursor Unit
  Author: GRANT BEATTIE
  Date: 08-24-94  13:29
*)

Unit Cursor;  { Cursor.Pas }

interface

const
CursorOn  = True;
CursorOff = False;

{ Cursor shapes }

ThinCursor    = $0707; { Thin cursor }
OvrCursor     = $0307; { Overwrite cursor }
InsCursor     = $0607; { Insert cursor (default) }
BarCursor     = $000D; { Bar cursor }

procedure SetCursor(CursorFlag : boolean);
function GetCursorType : word;
function SetCursorType(Shape : word) : word;

implementation

uses Crt;

var
CursorShape : word;

Procedure SetCursor; assembler;

{ Sets the cursor on/off using the current value of the global
CursorShape variable. Monochrome monitors supported }
Asm
CMP CursorFlag,True
JNE @@2
CMP BYTE PTR [LastMode],Mono
JE  @@1
MOV CX,CursorShape  { Switch on cursor using the default shape }
JMP @@4
@@1:
MOV CX,0B0Ch  { Switch on mono cursor }
JMP @@4
@@2:
CMP BYTE PTR [LastMode],Mono
JE  @@3
MOV CX,2000h  { Switch off cursor }
JMP @@4
@@3:
XOR CX,CX     { Switch off mono cursor }
@@4:
MOV AH,01h
XOR BH,BH
INT 10h
End; { SetCursor }

Function GetCursorType;

{ Returns the current cursor shape/type in word }

Begin
GetCursorType := MemW[Seg0040:$0060]
End; { GetCursorType }

Function SetCursorType; assembler;

{ Sets new cursor type/shape. Old cursor shape is returned }

Asm
MOV AX,CursorShape { save old value }
MOV BX,Shape
CMP BYTE PTR [LastMode],Mono
JNE @@1
XOR BX,BX { Switch off mono cursor }
@@1:
MOV CursorShape,BX
End; { SetCursorType }

Begin
CursorShape := GetCursorType
End. { Cursor.Pas }

