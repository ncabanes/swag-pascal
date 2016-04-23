{I have made some changes in your Unit Check, in order to make ik a bit faster
and use somewhat less code and data space (61 Bytes in all). Also, the display
of progress on screen is now 'ticking' because I swap the colors from white on
blue to gray on blue (perhaps a nice idea, now you can see if the machine
Really crashed)...
}
{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S+,V-,X-}
{$M 8192,0,655360}
{$DEFINE COLOR}
Unit MyCheck;
{
             TeeCee     Bob Swart  Saved:
  Code size: 514 Bytes  455 Bytes  59 Bytes
  Data size:  32 Bytes   30 Bytes   2 Bytes

  Here is the $1C ISR that I will add (unless you wish to do that).

  Some changes were made, which resulted in less code and data size, a
  little more speed, and display of the progress Variable on screen is
  made 'ticking' each second by changing the colour from white on blue
  to gray on blue and back With each update.
}
Interface

Var progress: LongInt Absolute $0040:$00F0;

Implementation
{ Everything is private to this Unit }
Uses Dos;

Const
  Line      = 0;    { Change as required For position of display on screen }
  Column    = 72;                                 { Top left corner is 0,0 }
  ScreenPos = (line * 80 * 2) + (column * 2);
  Colour: Byte = $1F;                                 { White/Gray on Blue }

Type
  TimeStr = Array[0..15] of Char;
  TimePtr = ^TimeStr;

Var
  {$IFDEF COLOR}
  Time: TimeStr Absolute $B800:ScreenPos;  { Assume colour display adaptor }
  {$ELSE}
  Time: TimeStr Absolute $B000:ScreenPos; { Otherwise mono display adaptor }
  {$endIF}
  OldInt1C: Pointer;
  ExitSave: Pointer;


{$F+}
Procedure Int1CISR; Interrupt;
{ This will be called every clock tick by hardware interrupt $08 }
Const DisplayTickCount = 20;
      TickCount: LongInt = DisplayTickCount;
      HexChars: Array[$0..$F] of Char = '0123456789ABCDEF';
Var HexA: Array[0..3] of Byte Absolute progress;
begin
  Asm
    cli
  end;
  inc(TickCount);
  if TickCount > DisplayTickCount then { ticks to update the display }
  begin
    TickCount := 0;        { equality check and assignment faster than mod }
            { The following statements actually display the on-screen time }
    Colour := Colour xor $08;        { Swap between white and gray on blue }
    FillChar(Time[1],SizeOf(Time)-1,Colour);
    Time[00] := HexChars[HexA[3] SHR 4];
    Time[02] := HexChars[HexA[3] and $F];
    Time[04] := HexChars[HexA[2] SHR 4];
    Time[06] := HexChars[HexA[2] and $F];
    Time[08] := HexChars[HexA[1] SHR 4];
    Time[10] := HexChars[HexA[1] and $F];
    Time[12] := HexChars[HexA[0] SHR 4];
    Time[14] := HexChars[HexA[0] and $F]
  end { if TickCount > DisplayTickCount };
  Asm
    sti
    pushf                                  { push flags to set up For IRET }
    call  OldInt1C                              { Call old ISR entry point }
  end
end {Int1CISR};
{$F-}


Procedure ClockExitProc; Far;
{ This Procedure is VERY important as you have hooked the timer interrupt  }
{ and therefore if this is omitted when the Unit is terminated your        }
{ system will crash in an unpredictable and possibly damaging way.         }
begin
  ExitProc := ExitSave;
  SetIntVec($1C,OldInt1C);               { This "unhooks" the timer vector }
end {ClockExitProc};


begin
  progress := 0;
  ExitSave := ExitProc;                          { Save old Exit Procedure }
  ExitProc := @ClockExitProc;                 { Setup a new Exit Procedure }
  GetIntVec($1C,OldInt1C);              { Get old timer vector and save it }
  SetIntVec($1C,@Int1CISR);   { Hook the timer vector to the new Procedure }
end.

