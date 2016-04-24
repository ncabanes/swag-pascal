(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0007.PAS
  Description: High Resolution Timer
  Author: TURBOPOWER SOFTWARE
  Date: 05-28-93  14:09
*)

{$S-,R-,I-,V-,B-}

{*********************************************************}
{*                   TPTIMER.PAS 2.00                    *}
{*                by TurboPower Software                 *}
{*********************************************************}

Unit TpTimer;
  {-Allows events to be timed With 1 microsecond resolution}



Interface
Const
  TimerResolution = 1193181.667;
Procedure InitializeTimer;
  {-ReProgram the timer chip to allow 1 microsecond resolution}

Procedure RestoreTimer;
  {-Restore the timer chip to its normal state}

Function ReadTimer : LongInt;
  {-Read the timer With 1 microsecond resolution}

Function ElapsedTime(Start, Stop : LongInt) : Real;
  {-Calculate time elapsed (in milliseconds) between Start and Stop}

Function ElapsedTimeString(Start, Stop : LongInt) : String;
  {-Return time elapsed (in milliseconds) between Start and Stop as a String}

  {==========================================================================}

Implementation

Var
  SaveExitProc : Pointer;
  Delta : LongInt;

  Function Cardinal(L : LongInt) : Real;
    {-Return the unsigned equivalent of L as a Real}
  begin                      {Cardinal}
    if L < 0 then
      Cardinal := 4294967296.0+L
    else
      Cardinal := L;
  end;                       {Cardinal}

  Function ElapsedTime(Start, Stop : LongInt) : Real;
    {-Calculate time elapsed (in milliseconds) between Start and Stop}
  begin                      {ElapsedTime}
    ElapsedTime := 1000.0*Cardinal(Stop-(Start+Delta))/TimerResolution;
  end;                       {ElapsedTime}

  Function ElapsedTimeString(Start, Stop : LongInt) : String;
    {-Return time elapsed (in milliseconds) between Start and Stop as a String}
  Var
    R : Real;
    S : String;
  begin                      {ElapsedTimeString}
    R := ElapsedTime(Start, Stop);
    Str(R:0:3, S);
    ElapsedTimeString := S;
  end;                       {ElapsedTimeString}

  Procedure InitializeTimer;
    {-ReProgram the timer chip to allow 1 microsecond resolution}
  begin                      {InitializeTimer}
    {select timer mode 2, read/Write channel 0}
    Port[$43] := $34;        {00110100b}
    Inline($EB/$00);         {jmp short $+2 ;Delay}
    Port[$40] := $00;        {LSB = 0}
    Inline($EB/$00);         {jmp short $+2 ;Delay}
    Port[$40] := $00;        {MSB = 0}
  end;                       {InitializeTimer}

  Procedure RestoreTimer;
    {-Restore the timer chip to its normal state}
  begin                      {RestoreTimer}
    {select timer mode 3, read/Write channel 0}
    Port[$43] := $36;        {00110110b}
    Inline($EB/$00);         {jmp short $+2 ;Delay}
    Port[$40] := $00;        {LSB = 0}
    Inline($EB/$00);         {jmp short $+2 ;Delay}
    Port[$40] := $00;        {MSB = 0}
  end;                       {RestoreTimer}

  Function ReadTimer : LongInt;
    {-Read the timer With 1 microsecond resolution}
  begin                      {ReadTimer}
    Inline(
      $FA/                   {cli             ;Disable interrupts}
      $BA/$20/$00/           {mov  dx,$20     ;Address PIC ocw3}
      $B0/$0A/               {mov  al,$0A     ;Ask to read irr}
      $EE/                   {out  dx,al}
      $B0/$00/               {mov  al,$00     ;Latch timer 0}
      $E6/$43/               {out  $43,al}
      $EC/                   {in   al,dx      ;Read irr}
      $89/$C7/               {mov  di,ax      ;Save it in DI}
      $E4/$40/               {in   al,$40     ;Counter --> bx}
      $88/$C3/               {mov  bl,al      ;LSB in BL}
      $E4/$40/               {in   al,$40}
      $88/$C7/               {mov  bh,al      ;MSB in BH}
      $F7/$D3/               {not  bx         ;Need ascending counter}
      $E4/$21/               {in   al,$21     ;Read PIC imr}
      $89/$C6/               {mov  si,ax      ;Save it in SI}
      $B0/$FF/               {mov  al,$0FF    ;Mask all interrupts}
      $E6/$21/               {out  $21,al}
      $B8/$40/$00/           {mov  ax,$40     ;read low Word of time}
      $8E/$C0/               {mov  es,ax      ;from BIOS data area}
      $26/$8B/$16/$6C/$00/   {mov  dx,es:[$6C]}
      $89/$F0/               {mov  ax,si      ;Restore imr from SI}
      $E6/$21/               {out  $21,al}
      $FB/                   {sti             ;Enable interrupts}
      $89/$F8/               {mov  ax,di      ;Retrieve old irr}
      $A8/$01/               {test al,$01     ;Counter hit 0?}
      $74/$07/               {jz   done       ;Jump if not}
      $81/$FB/$FF/$00/       {cmp  bx,$FF     ;Counter > $FF?}
      $77/$01/               {ja   done       ;Done if so}
      $42/                   {inc  dx         ;else count int req.}
      {done:}
      $89/$5E/$FC/           {mov [bp-4],bx   ;set Function result}
      $89/$56/$FE);          {mov [bp-2],dx}
  end;                       {ReadTimer}

  Procedure Calibrate;
    {-Calibrate the timer}
  Const
    Reps = 1000;
  Var
    I : Word;
    L1, L2, Diff : LongInt;
  begin                      {Calibrate}
    Delta := MaxInt;
    For I := 1 to Reps do begin
      L1 := ReadTimer;
      L2 := ReadTimer;
      {use the minimum difference}
      Diff := L2-L1;
      if Diff < Delta then
        Delta := Diff;
    end;
  end;                       {Calibrate}

  {$F+}
  Procedure OurExitProc;
    {-Restore timer chip to its original state}
  begin                      {OurExitProc}
    ExitProc := SaveExitProc;
    RestoreTimer;
  end;                       {OurExitProc}
  {$F-}

begin
  {set up our Exit handler}
  SaveExitProc := ExitProc;
  ExitProc := @OurExitProc;

  {reProgram the timer chip}
  InitializeTimer;

  {adjust For speed of machine}
  Calibrate;
end.

