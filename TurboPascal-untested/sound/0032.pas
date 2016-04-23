{
RYNHARDT HAARHOFF

> Help!!! Does anyone have and source code for sampling through the
> Sound Blaster??? Its to do with my 'A' Level Project!!!!

the following is a small program using "realtime" sampling. If you would
rather use the CT-VOICE driver then please tell me so.

PLEASE NOTE: this was written for a VGA screen, and it uses direct video
memory access in 320x200 mode. If you have any problems with the screen, then
revert back to the BGI, and replace PutDot with PutPixel. It will be slightly
slower then :-(
I have an SB PRO, so I can't guarantee it will work on any other SB, or
on any other system. Use at own risk :-)
}

Program VoiceScope;

uses
  Crt;

const
  ResetPort    = $226;
  CommandPort  = $22C;
  ReadPort     = $22A;
  PollPort     = $22E;
  MaxOldDots   = 50000;  {max size of the array}
  MixerRegPort = $224;   {Volume : Hi nibble = left, Lo Nibble = right}
  MixerDatPort = $225;
  Master       = 35;
  Line         = 46;
  VOC          = 21;
  FM           = 23;     {Hi nibble = FM channel; Lo nibble = volume}
  CD           = 25;
  Mic          = 27;
  ADCChannel   = 29;
  StereoSell   = 31;     {0,1 = mono; 2,3 = stereo}


var
  Scr       : array [0..199, 0..319] of byte absolute $A000:0000;
  Ch        : char;
  XInt,
  XWidth,
  XMax,
  YMax,
  XMid,
  YMid,
  MaxHeight,
  XStart,
  Color,
  ColorBack : integer;
  OldDots   : array [0..MaxOldDots] of byte;     {to store old dots}


Procedure InitVideo(Mode : byte; Clr : boolean);
begin
  if NOT Clr then
    Mode := Mode + 128;
  ASM
    mov AH, 00
    mov AL, Mode
    int 10h
  end;
end;

Procedure PutDot(x, y : word; Color : byte);
begin
  Scr[y, x] := Color;
end;

Procedure SquareFill(x1, y1, x2, y2 : word; Color : byte);
var
  y : word;
begin
  for y := y1 to y2 do
    FillChar(Scr[y, x1], x2-x1, Color);
end;

Procedure SetMixer(PortNum, Vol : byte);  {Set mixer ports}
begin
  asm
    MOV DX, MixerRegPort       {Select register port}
    MOV AL, PortNum            {Select which channel}
    OUT DX, AL
    MOV DX, MixerDatPort       {Select data port}
    MOV AL, Vol                {Write volume/data}
    OUT DX, AL
  end;
end;

Function ResetSB : boolean;      {resets the SB}
begin
  Port[ResetPort] := 1;
  Delay(1);
  Port[ResetPort] := 0;
  Delay(1);
  if Port[PollPort] and 128 = 128 then
    ResetSB := True
  else
    ResetSB := False;
end;

Procedure ShowDots(D : integer);   {show the voice data}
var
  x, y : word;
  NewX : word;
begin
  for x := 1 to XWidth * d do
  begin
    port[CommandPort] := $20;                     { these three lines }
    repeat until (port[PollPort] and 128 = 128);  { gets the actual   }
    y := port[ReadPort];                          { data from the SB  }

    if y > 128 + MaxHeight then
      y := 128 + MaxHeight;
    if y < 128 - MaxHeight then
      y := 128 - MaxHeight;

    NewX := x div d;
    PutDot(NewX + XStart, OldDots[x] + YMid - 128, ColorBack);
    PutDot(NewX + XStart, y + YMid - 128, y div 2);
    OldDots[x] := y;
  end;
  if keypressed then
  begin    {pause}
    Ch := ReadKey;
    if Ch = #32 then
      repeat until keypressed;
  end;
end;

Procedure Init;    {initialize all the variables}
var
  N : longint;
begin
  InitVideo($13, TRUE);
  Ch        := #0;
  XMax      := 319;
  XMid      := XMax div 2;
  YMax      := 199;
  YMid      := YMax div 2;
  XInt      := 10;
  XWidth    := 280;
  XStart    := XMid - XWidth div 2;
  MaxHeight := 60;
  Color     := 9;
  ColorBack := 0;
  SquareFill(XStart-10, YMid-MaxHeight-1-10, XStart+XWidth+1+10, YMid+MaxHeight+1+10, 10);
  SquareFill(XStart, YMid-MaxHeight-1, XStart+XWidth+1, YMid+MaxHeight+1, ColorBack);
  for N := 0 to MaxOldDots do
    OldDots[N] := 128;
  if ResetSb then;
end;

BEGIN
  Init;
  SetMixer(ADCChannel, 1);   {Sets the ADC channel to MIC}

  {NOTE: I don't know if the mixer routines will work on any other
         SB. If something stalls, then exclude the mixer statements
         If you want to use the LINE-IN, then SetMixer(ADCChannel, 6);}

  While Ch <> #27 do ShowDots(1);    {This value is a time constant}
END.
