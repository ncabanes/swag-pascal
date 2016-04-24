(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0054.PAS
  Description: Nice Keyboard Handler
  Author: SWAG SUPPORT TEAM
  Date: 11-02-93  05:59
*)

UNIT KeyIntr;  { support for INT 09 16 routines } { Turbo Pascal 5.5+ }

INTERFACE

Type
  InterruptProcedure = Procedure;

Const
  BiosDataSegment = $40;

Procedure DisableInterrupts; Inline($FA);   { CLI }
Procedure EnableInterrupts;  Inline($FB);   { STI }
Procedure CallInterrupt(P : Pointer);

Function AltPressed : Boolean;
Function ControlPressed : Boolean;
Function ShiftPressed : Boolean;

Procedure EOI;                      { end of interrupt to 8259 }
Function  ReadScanCode : Byte;       { read keyboard }
Procedure ResetKeyboard;            { prepare for next key }
                                     { put key in buffer for INT 16 }
Function StoreKey(Scan, Key : Byte) : Boolean;

IMPLEMENTATION

Type
  TwoBytesPtr = ^TwoBytes;
  TwoBytes = Record  { one key in the keyboard buffer }
    KeyCode,
    ScanCode : Byte;
  End;

Var
  KeyState       : Word Absolute BiosDataSegment : $17;
  KeyBufferHead  : Word Absolute BiosDataSegment : $1A;
  KeyBufferTail  : Word Absolute BiosDataSegment : $1C;
  KeyBufferStart : Word Absolute BiosDataSegment : $80;
  KeyBufferEnd   : Word Absolute BiosDataSegment : $82;

Procedure CallInterrupt(P : Pointer);
Begin
  Inline($9C);           { PUSHF }
  InterruptProcedure(P);
End;

Function AltPressed : Boolean;
Begin
  AltPressed := (KeyState and 8) <> 0;
End;

Function ControlPressed : Boolean;
Begin
  ControlPressed := (KeyState and 4) <> 0;
End;

Function ShiftPressed : Boolean;
Begin
  ShiftPressed := (KeyState and 3) <> 0;
End;

Procedure EOI;  { end of interrupt to 8259 interrupt controller }
Begin
  Port[$20] := $20;
End;

Function ReadScanCode : Byte;
Var
  N : Byte;
Begin
  N := Port[$60];     { $FF means keyboard overrun }
  ReadScanCode := N;
End;

Procedure ResetKeyboard;      { prepare for next key }
Var
  N : Byte;
Begin
  N := Port[$61];
  Port[$61] := (N or $80);
  Port[$61] := N;
End;

Function StoreKey(Scan, Key : Byte) : Boolean;
Var                { put key in buffer that INT 16 reads }
  P : TwoBytesPtr;
  N : Word;
Begin
  DisableInterrupts;

  N := KeyBufferTail;
  P := Ptr(BiosDataSegment, N);

  Inc(N, 2);
  If(N = KeyBufferEnd) then        { end of the circular buffer }
    N := KeyBufferStart;
  If(N = KeyBufferHead) then       { buffer full }
  Begin
    EnableInterrupts;
    StoreKey := False;
  End
  Else
  Begin
    P^.KeyCode := Key;
    P^.ScanCode := Scan;             { store key in circular buffer }
    KeyBufferTail := N;              { advance tail pointer }
    EnableInterrupts;
    StoreKey := True;
  End;
End;


END.




