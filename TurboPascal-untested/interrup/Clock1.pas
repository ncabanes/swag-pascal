(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0002.PAS
  Description: CLOCK1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{
CARLOS BEGUIGNE
}
Program ClockOnScreen;

{$R-,V-,S-,M 1024, 0, 0

  ClockOnScreen - Installs resident clock on upper right corner of screen.

{$IFOPT S+ }

{
  You must disable stack checking here, since a Runtime error 202 will
  be generated whenever the stack Pointer (as returned by SPtr) is likely
  to drop below 1024.
}
Uses
  Dos, Crt;
Const
  Offset       = $8E;    { Line 1, Column $8E/2 = 71 }
  TimerTick    = $1C;                  { Timer interrupt }
  black        = 0;
  gray         = 7;
  EnvSeg       = $002C;                { Segment of Dos environment }
  ColourSeg    = $B800;                { Segment of colour video RAM }
  MonoSeg      = $B000;                { Segment of monochrome ideo RAM }
  CrtSegment   : Word = ColourSeg;

Type
  ScreenArray  = Array[0..7] of Record
    number, attribute : Char;
  end;

  ScreenPtr    = ScreenArray;

Var
  VideoMode    : Byte Absolute $0000:$0449;
  Screen       : ^ScreenPtr;            { Physical screen address }
  ClockColour  : Char;
  Int1CSave    : Procedure;

Procedure ShowTime; Interrupt;
Const
  separator    = ':';
Var
  ThisMode     : Byte;
  Time         : LongInt;
  i            : Integer;
  BIOSTicker   : LongInt Absolute $0000:$046C;

  Procedure DisplayDigit(offset : Integer; digit : Integer);
  begin
    Screen^ [offset].number := Chr(digit div 10+Ord('0'));
    Screen^ [offset+1].number := Chr(digit mod 10+Ord('0'));
  end;  { DisplayDigit }

begin
  ThisMode := VideoMode;
  if not ((ThisMode = 2) or (ThisMode = 3) or (ThisMode = 7)) Then
    Exit;                              { Do not popup in a Graphic mode }
  For i := 0 to 7 Do
    Screen^[i].attribute := ClockColour;
  Time := (1365*BIOSTicker) div 24852;
  DisplayDigit(0, Time div 3600);      { hours }
  Screen^[2].number := separator;
  Time := Time mod 3600;
  DisplayDigit(3, Time div 60);        { minutes }
  Screen^[5].number := separator;
  DisplayDigit(6, Time mod 60);        { seconds }
  Inline($9C); { PUSHF }
  Int1CSave;
end;  { ShowTime }

Procedure Release(segment : Word);
InLine(
  $07/                 { POP   ES       ; get segment of block to release }
  $B4/$49/             { MOV   AH, 49h  ; Free Allocated Memory }
  $CD/$21);            { INT   21h      ; call Dos }

begin  { ClockOnScreen }
  if VideoMode = 7 Then
    CrtSegment := MonoSeg;
  ClockColour := Chr(gray*16+black);      {display video attribute }
  Screen := Ptr(CrtSegment, Offset);
  GetIntVec(TimerTick, @Int1CSave);
  SetIntVec(TimerTick, @ShowTime);
  Release(MemW[PrefixSeg:EnvSeg]);        {Release the environment }
  Keep(0);
  readln;
end.  { ClockOnScreen }


