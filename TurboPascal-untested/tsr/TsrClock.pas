(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0017.PAS
  Description: TSR Clock
  Author: WILBERT VAN LIEJEN
  Date: 01-27-94  11:55
*)

{
> I would like to include a clock in my current project which will be
> updated once a minute.  Instead of constantly checking the computer's clock
> and waiting for it to change, I would like to use an interrupt.

This one has even a hot key handler.  If you want to update it once per
minute, bump a counter within the interrupt 1Ch handler till it reaches the
value 60*18.2.  Then refresh the screen.
}

Program Clock;

{$G+,R-,S-,M 1024, 0, 0 }

uses
  Dos;

Const
  x           = 71;                   { x location on screen }
  y           = 1;                    { y location on screen }
  Keyboard    = 9;                    { Hardware keyboard interrupt }
  TimerTick   = $1C;                  { Gets called 18.2 / second }
  VideoOffset = 160 * (y - 1) + 2 * x;{ Offset in display memory }
  yellow      = 14;
  blue        = 1;
  attribute   = blue * 16 + yellow;   { Clock colours }
  VideoBase   : Word = $B800;         { Segment of display memory }
  ActiveFlag  : ShortInt = -1;        { 0: on, -1: off }

Var
  OrgInt9,                             { Saved interrupt 9 vector }
  OrgInt1Ch : Pointer;              { Saved interrupt 1Ch vector }
  VideoMode : Byte absolute $0000:$0449;

{ Display a string using Dos services (avoid WriteLn, save memory) }

Procedure DisplayString(s : String); Assembler;

ASM
  PUSH   DS
  XOR    CX, CX
  LDS    SI, s
  LODSB
  MOV    CL, AL
  JCXZ   @EmptyString
  CLD
 @NextChar:
  LODSB
  XCHG   AX, DX
  MOV    AH, 2
  INT    21h
  LOOP   @NextChar
 @EmptyString:
  POP    DS
end;

{ Returns True if a real time clock could be found }
Function HasRTClock : Boolean; Assembler;

ASM
  XOR    AL, AL
  MOV    AH, 2
  INT    1Ah
  JC     @NoRTClock
  INC    AX
 @NoRTCLock:
end;

{ Release Dos environment }
Procedure ReleaseEnvironment; Assembler;
ASM
  MOV    ES, [PrefixSeg]
  MOV    ES, ES:[002Ch]
  MOV    AH, 49h
  INT    21h
end;

{ INT 9 handler intercepting Alt-F11 }
Procedure ToggleClock; Interrupt; Assembler;
Const
  F11      = $57;                  { 'F11' make code }
  BiosSeg  = $40;                  { Segment of BIOS data area }
  AltMask  = $08;                  { Bitmask of Alt key }
  KbdFlags = $17;                  { Byte showing keyboard status }

ASM
  STI
  IN     AL, 60h

 { F11 pressed? }
  CMP    AL, F11
  JNE    @PassThru

 { Alt-key pressed? }
  PUSH   BiosSeg
  POP    ES
  MOV    AL, ES:[KbdFlags]
  AND    AL, AltMask
  CMP    AL, AltMask
  JNE    @PassThru

 { Flip status flag, force EOI and leave routine }
  NOT    [ActiveFlag]
  IN     AL, 61h
  MOV    AH, AL
  OR     AL, 80h
  OUT    61h, AL
  MOV    AL, AH
  OUT    61h, AL
  CLI
  MOV    AL, 20h
  OUT    20h, AL
  STI
  JMP    @Exit

 @PassThru:
  CLI
  PUSHF
  CALL   DWord Ptr [OrgInt9]
 @Exit:
end;  { ToggleClock }

{ Convert a packed BCD byte to ASCII character }
Procedure Digit; Assembler;
ASM
  PUSH   AX
  CALL   @HiNibble
  POP    AX
  CALL   @LoNibble
  RETN

 @HiNibble:
  SHR    AL, 4
  JMP    @MakeAscii
 @LoNibble:
  AND    AL, 0Fh
 @MakeAscii:
  OR     AL, '0'
  STOSW
end;

{ INT 1Ch handler that displays a clock on the right hand side of the screen }
Procedure DisplayClock; Interrupt; Assembler;
ASM
  CMP    [ActiveFlag], 0
  JNE    @Exit
  CLD
  MOV    AH, 2
  INT    1Ah
  MOV    ES, [VideoBase]
  MOV    DI, VideoOffset
  MOV    AH, attribute
  MOV    AL, CH
  CALL   Digit
  MOV    AL, ':'
  STOSW
  MOV    AL, CL
  CALL   Digit
  MOV    AL, ':'
  STOSW
  MOV    AL, DH
  CALL   Digit
  PUSHF
  CALL   DWord Ptr [OrgInt1Ch]
 @Exit:
end;

Begin
  If VideoMode = 7 Then
    VideoBase := $B000;
  GetIntVec(TimerTick, OrgInt1Ch);
  SetIntVec(TimerTick, @DisplayClock);
  GetIntVec(Keyboard, OrgInt9);
  SetIntVec(Keyboard, @ToggleClock);
  SwapVectors;
  ReleaseEnvironment;
  DisplayString('CLOCK installed.  <Alt-F11> toggles on/off');
  Keep(0);
end.

