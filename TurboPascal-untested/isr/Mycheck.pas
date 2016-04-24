(*
  Category: SWAG Title: ISR HANDLING ROUTINES
  Original name: 0006.PAS
  Description: MYCHECK.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{$ifDEF VER70}
{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+}
{$else}
{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S+,V-,X-}
{$endif}
{$DEFinE COLor}
Unit MyCheck;
{
  Version: 2.0 (8 jan 1993).

             TeeCee     Bob Swart  Saved:
  Code size: 514 Bytes  472 Bytes  42 Bytes
  Data size:  32 Bytes   32 Bytes   0 Bytes

  Here is the $1C ISR that I will add (unless you wish to do that).

  Some changes were made, which resulted in less code and data size, a
  little more speed, and display of the progress Variable on screen is
  made 'ticking' each second by changing the colour from white on blue
  to gray on blue and back With each update.
  Also, the Variable Test8086 is set to 0 when the ISR in entered, and
  reset to the value Save8086 (initialized at startup) on Exit. Hereby
  we elimiate potential BTP7 problems With using LongInts in ISRs, and
  not saving Extended Registers properly.
}
Interface

Var progress: LongInt Absolute $0040:$00F0;

Implementation
{ Everything is private to this Unit }
Uses Dos;

Const
  Line      = 0;    { Change as required For position of display on screen }
  Column    = 72;                                 { top left corner is 0,0 }
  ScreenPos = (line * 80 * 2) + (column * 2);
  Colour: Byte = $1F;                                 { White/Gray on Blue }

Type
  TimeStr = Array[0..15] of Char;
  TimePtr = ^TimeStr;

Var
  {$ifDEF COLor}
  Time: TimeStr Absolute $B800:ScreenPos;  { Assume colour display adaptor }
  {$else}
  Time: TimeStr Absolute $B000:ScreenPos; { otherwise mono display adaptor }
  {$endif}
  OldInt1C: Pointer;
  ExitSave: Pointer;
  Save8086: Byte;


{$F+}
Procedure Int1CISR; Interrupt;
{ This will be called every clock tick by hardware interrupt $08 }
Const DisplayTickCount = 20;
      TickCount: LongInt = DisplayTickCount;
      HexChars: Array[$0..$F] of Char = '0123456789ABCDEF';
Var HexA: Array[0..3] of Byte Absolute progress;
begin
  {$ifDEF VER70}
  Test8086 := 0;
  {$endif}
  Asm
    cli
  end;
  inc(TickCount);
  if TickCount > DisplayTickCount then { ticks to update the display }
  begin
    TickCount := 0;        { equality check and assignment faster than mod }
            { The following statements actually display the on-screen time }
    Colour := Colour xor $08;        { Swap between white and gray on blue }
    FillChar(Time[1],Sizeof(Time)-1,Colour);
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
  end;
  {$ifDEF VER70}
  Test8086 := Save8086
  {$endif}
end {Int1CISR};
{$F-}


Procedure ClockExitProc; Far;
{ This Procedure is VERY important as you have hooked the timer interrupt  }
{ and thereFore if this is omitted when the Unit is terminated your        }
{ system will crash in an unpredictable and possibly damaging way.         }
begin
  ExitProc := ExitSave;
  SetIntVec($1C,OldInt1C);               { This "unhooks" the timer vector }
end {ClockExitProc};


begin
  progress := 0;
  {$ifDEF VER70}
  Save8086 := Test8086;
  {$endif}
  ExitSave := ExitProc;                          { Save old Exit Procedure }
  ExitProc := @ClockExitProc;                 { Setup a new Exit Procedure }
  GetIntVec($1C,OldInt1C);              { Get old timer vector and save it }
  SetIntVec($1C,@Int1CISR);   { Hook the timer vector to the new Procedure }
end.

