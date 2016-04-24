(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0055.PAS
  Description: Protected Mode BIOS Example
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:10
*)

program BIOS;
{ Compile in protected mode only }

uses
  Crt, WINAPI;

const
  Coms:array[0..3] of String= ('Com1: ', 'Com2: ', 'Com3: ', 'Com4: ');
  Lpts:array[0..2] of String= ('Lpt1: ', 'Lpt2: ', 'Lpt3: ');

type
  PBios = ^TBios;
  TBios = Record
    SerialPortAdd    : Array [0..3] of Word;
    ParallelPortAdd  : Array [0..3] of Word;
    EqptFlags        : Word;
    MfgrTestFlags    : Byte;
    MainMem,
    ExpRam,
    KbdStat          : Word;
    KeyPad           : Byte;
    KbdBuffHead,
    KbdBuffTail      : Word;
    KbdBuff          : Array [0..31] of Char;
    SeekStatus,
    MortotStatus,
    MortoCnt,
    DiskError        : Byte;
    NECStatus        : Array [0..6] of Byte;
    VideoMode        : Byte;
    ScrnWidth,
    VideoBufferSize,
    VideoBufferOfs   : Word;
    CursorPos        : Array [0..7,0..1] of Byte;
    CursorBottom,
    CursorTop,
    ActiveDisplayPage : Byte;
    ActiveDisplayPort : Word;
    CRTModeReg,
    Palette           : Byte;
    DataEdgeTimeCount,
    CRCReg            : Word;
    LastCharInput     : Char;
    Tick              : Word;
    Hour              : Integer;
    TimerOverFlow,
    BrkStatus         : Byte;
    ResetFlag         : Word;
    HardDiskStatus    : LongInt;
    ParallelTimeout,
    SerialTimeout     : Array[0..3] of Byte;
    KbdBufferOfs,
    KbdBufferEnd      : Word;
  End;
  AtBios = Record
    Name : Array[0..164] of Char;
  End;

var
  SaveAttr: Byte;

Procedure CursorOff; assembler;
asm
  mov AH, $01;
  mov CH, $20;
  mov CL, $20;
  int $10;
End;

procedure CursorSmall;
Begin
  if LastMode <> CO80 then asm
    mov AH, $01;
    mov CH, 12;
    mov CL, 13;
    int $10;
  end else asm;
    mov AH, $01;
    mov CH, $06;
    mov CL, $07;
    int $10;
  end;
end;

function GetHexWord(w: Word): String;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 GetHexWord := hexChars[Hi(w) shr 4] + hexChars[Hi(w) and $F] +
               hexChars[Lo(w) shr 4] + hexChars[Lo(w) and $F];
end;

procedure WriteXY(X, Y: Integer; S: String);
begin
  GotoXY(X, Y);
  Write(S);
end;

procedure WriteXY2(X, Y: Integer; S: String; W: Word);
begin
  GotoXY(X, Y);
  Write(S);
  Write(W);
end;

procedure WriteXY3(X, Y: Integer; S: String; B: Boolean);
begin
  GotoXY(X, Y);
  Write(S);
  Write(B);
  ClrEOL;
end;

procedure WriteData(Ticks: PBios);
var
  SaveAttr, i: Integer;

begin
  for i := 0 to 3 do
    WriteXY(1, 1 + i, Coms[i] + GetHexWord(Ticks^.SerialPortAdd[i]));
  for i := 0 to 2 do
    WriteXY(1, 6 + i, Lpts[i] + GetHexWord(Ticks^.ParallelPortAdd[i]));
  WriteLn;
  WriteXY2(1, 10, 'VideoMode: ', Ticks^.VideoMode);
  WriteXY2(1, 11, 'Dos Mem: ', Ticks^.MainMem);
  WriteXY(1, 12, 'Video Card Port Addresss: ' +
                 GetHexWord(Ticks^.ActiveDisplayPort));
  WriteXY2(1, 13, 'Tick: ', Ticks^.Tick);
  WriteXY2(1, 14, 'Hour: ', Ticks^.Hour);
  WriteXY2(1, 15, 'Break Status: ', Ticks^.BrkStatus);
  WriteXY2(1, 16, 'Palette: ', Ticks^.Palette);
  WriteXY3(1, 18, 'Right Shift: ', 0 <> Ticks^.KbdStat and 1);
  WriteXY3(1, 19, 'Left Shift: ', 0 <> Ticks^.KbdStat and 2);
  WriteXY3(1, 20, 'Ctrl : ', 0 <> Ticks^.KbdStat and 4);
  WriteXY3(1, 21, 'Alt: ', 0 <> Ticks^.KbdStat and 8);
  WriteXY3(1, 22, 'Scroll Lock: ', 0 <> Ticks^.KbdStat and 16);
  WriteXY3(1, 23, 'Num Lock: ', 0 <> Ticks^.KbdStat and 32);
  WriteXY3(1, 24, 'Caps Lock: ', 0 <> Ticks^.KbdStat and 64);
  GotoXY(1,25);
  SaveAttr := TextAttr;
  TextAttr := 0 + 7 * 16;
  Write('Press Shift, Alt, Caps Lock, etc, to see status of keys ' +
        '-- Any key to exit    ');
  TextAttr := SaveAttr;
end;

procedure Opening;
begin
  SaveAttr := TextAttr;
  TextAttr := 7 + 1 * 16;
  ClrScr;
  GotoXY(1,25);
  TextAttr := 0 + 7 * 16;
  ClrEOL;
  TextAttr := 7 + 1 * 16;
  CursorOff;
end;

function RealToProt(P : Pointer; Siz : Word;
                    var Sel : Word) : Pointer;
begin
  SetSelectorBase(Sel,
                 LongInt(HiWord(LongInt(P))) shl 4+
                 LoWord(LongInt(P)));
  SetSelectorLimit(Sel, Siz);
  RealToProt := Ptr(Sel, 0);
end;

var
  Sel : Word;
  Ticks : PBios;
begin
  Opening;
  Sel := AllocSelector(DSeg);
  Ticks := Ptr($0000, $400);
  Ticks := RealToProt(Ticks, SizeOf(TBIOS), Sel);
  repeat
    WriteData(Ticks);
  until KeyPressed;
  FreeSelector(Sel);
  CursorSmall;
  TextAttr := SaveAttr;
end.

