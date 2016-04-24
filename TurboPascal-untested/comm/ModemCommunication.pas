(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0069.PAS
  Description: Modem Communication
  Author: PETER BEEFTINK
  Date: 11-26-94  05:05
*)


{$R-,S-}
unit ComPort;

interface

uses TPDos,
     TpString,
     TpInt;


function OpenCom(PortNum,Params: Word): boolean;

{ Issues interrupt $14 to initialize the UART, sets up buffers            }
{ This procedure should be called using the const declarations following. }
{ Sample calling sequence:                                                }
{      Port := Com1Port;                                                  }
{      Params := Baud9600 + NoParity + WordSize8 + StopBits1;             }
{      if InitCom( Port, Params ) then;                                   }

function ComReady: boolean;
{returns true if character ready;  false if no character waiting }

function ReadCom: char;
{returns character from com port}

procedure WriteCom( C: char );
{Send a character}

procedure WriteComStr( S: string );
{Writes a string, S, by repeatedly calling WriteCom}

const
  AsyncBufMax = 4095;     {Upper limit of Async Buffer}

var
  Async: record
    Overflow: boolean;
    PortNum,
    Base,
    Max,
    Head,
    Tail:    word;
    Buffer: array[0..AsyncBufMax] of char;
    end;

const
  Baud110 =       $00;
  Baud150 =       $20;
  Baud300 =       $40;
  Baud600 =       $60;
  Baud1200 =      $80;
  Baud2400 =      $A0;
  Baud4800 =      $C0;
  Baud9600 =      $E0;
  EvenParity =    $18;
  OddParity =     $08;
  NoParity =      $00;
  WordSize7 =     $02;
  WordSize8 =     $03;
  StopBits1 =     $04;
  StopBits2 =     $00;
  Com1Port =      $00;
  Com2Port =      $01;

{===========================================================================}
{.pa}
implementation

const
  UART_THR  = $00;     {Transmit Hold Register}
  UART_RBR  = $00;     {Receive Buffer Register}
  UART_IER  = $01;     {Data ready interrupt}
  UART_IIR  = $02;     {}
  UART_LCR  = $03;     {}
  UART_MCR  = $04;     {OUT2}
  UART_LSR  = $05;     {Line Status Register}
  UART_MSR  = $06;     {}
  I8088_IMR = $21;     {Interrupt Mask Register on 8250\9}

var
  AsyncBIOSPortTable: array[1..2] of word absolute $40:0;
  SaveExitProc:  pointer;

procedure BiosInitCom(PortNum,Params: Word);
inline(
  $58/          { POP   AX      ;Pop parameters         }
  $5A/          { POP   DX      ;Pop port number        }
  $B4/$00/      { MOV   AH,0    ;Code for initialize    }
  $CD/$14);     { INT   14H     ;Call BIOS              }

function InChar(PortNum: Word): Char;
inline(
  $5A/          { POP   DX      ;Pop port number        }
  $B4/$02/      { MOV   AH,2    ;Code for input         }
  $CD/$14);     { INT   14H     ;Call BIOS              }

function InReady(PortNum: Word): Boolean;
inline(
  $5A/          { POP   DX      ;Pop port number        }
  $B4/$03/      { MOV   AH,3    ;Code for status        }
  $CD/$14/      { INT   14H     ;Call BIOS              }
  $88/$E0/      { MOV   AL,AH   ;Get line status in AH  }
  $24/$01);     { AND   AL,1    ;Isolate Data Ready bit }

{$F+} procedure ComIntHandler( BP: word ); interrupt; {$F-}

var
  Regs:      IntRegisters absolute BP;
  NewHead:   word;

begin   {ComIntHandler}

  with Async do begin
    Buffer[Head] := Chr( Port[UART_RBR + Base] );
    NewHead := succ( Head );
    if NewHead > Max then NewHead := 0;
    if NewHead = Tail then Overflow := true
    else Head := NewHead;
    InterruptsOff;
    Port[$20] := $20;   {use non-specific EOI}
    end;  {with Async}

  end;   {ComIntHandler}

function OpenCom(PortNum,Params: Word): boolean;

const
  Handle =  15;    {Select an arbitrary handle for TPInt}

var
  IntNumber: byte;
  Junk,
  Mask:      word;
  IRQ,
  Vector:    byte;
  I:         integer;

begin

  if Async.PortNum <> $FFFF then begin
    OpenCom := false;
    exit;
    end;
  Async.Base := AsyncBIOSPortTable[PortNum + 1];
  IRQ := Hi(Async.Base) + 1;
  IntNumber := IRQ + $8;
  if (Port[UART_IIR + Async.Base] and $F8) <> 0 then begin
    OpenCom := false;
    exit;
    end;
  if not InitVector( IntNumber, Handle, @ComIntHandler ) then begin
    OpenCom := false;
    exit;
    end;
  Async.PortNum := PortNum;
  {Other parameters already initialized}
  BiosInitCom(PortNum,Params);
  InterruptsOff;
  Port[UART_LCR + Async.Base] := Port[UART_LCR + Async.Base] and $7F;
  Junk := Port[UART_LSR + Async.Base];  {Reset any Line Status Register errors}
  Junk := Port[UART_RBR + Async.Base];  {Empty Receive Buffer Register}

  {Enable IRQ on the 8259 controller}
  Port[I8088_IMR] := Port[I8088_IMR] and ((1 shl IRQ) xor $FF);

  Port[UART_IER + Async.Base] := $01; {Enable data ready interrupt on the 8250}

  {Enable OUT2 on 8250}
  Port[UART_MCR + Async.Base] := Port[UART_MCR + Async.Base] or $08;
  Port[$20] := $20;   {clear out non-specific EOI}

  InterruptsOn;
  OpenCom := true;

  end;

function ReadCom: char;
{returns character from com port}

begin

  with Async do begin
    repeat until Head <> Tail;   {Wait here for a character}
    ReadCom := Buffer[Tail];
    InterruptsOff;
    Inc( Tail );
    if Tail > Max then Tail := 0;
    InterruptsOn;
    end;

  end;    {ReadCom}

function ComReady: boolean;
{returns true if character ready;  false if no character waiting }

begin

  with Async do begin
    if Head = Tail then ComReady := false
    else ComReady := true;
    end;

  end;    {ComReady}

procedure WriteCom( C: char );
{Send a character}

var
  WaitCount: word;

begin

  with Async do begin
    Port[UART_MCR + Base] := $0B;  {Turn on OUT2, DTR, and RTS}
    WaitCount := $FFFF;
    while (WaitCount <> 0) and ((Port[UART_MSR + Base] and $10) = 0) do
      dec(WaitCount);   {Wait for CTS (clear to send)}
    if WaitCount <> 0 then WaitCount := $FFFF;
    while (WaitCount <> 0) and ((Port[UART_LSR + Base] and $20) = 0) do
      dec(WaitCount);   {Wait for THRE  (transmit hold register empty)}
    if WaitCount <> 0 then begin
      InterruptsOff;
      Port[UART_THR + Base] := ord(C);   {send the character}
      InterruptsOn;
      end;
    end;

  end;   {WriteCom}

procedure WriteComStr( S: string );
{Writes a string, S, by repeatedly calling WriteCom}

begin

  while length(S) > 0 do begin
    WriteCom( S[1] );
    S := copy( S, 2, 255 );     {throw away first character}
    end;

  end;

procedure CloseCom;

var
  IRQ:  byte;

begin


  if Async.PortNum <> $FFFF then begin
    IRQ := Hi(Async.Base) + 1;
    InterruptsOff;
    Port[I8088_IMR] := Port[I8088_IMR] or (1 shl IRQ); {Turn off int reqs}
    Port[UART_IER + Async.Base] := 0;  {Disable 8250 Data ready interrupt}
    Port[UART_MCR + Async.Base] := 0;   {Disable OUT2 on 8250}
    InterruptsOn;
    end;

  end;   {CloseCom}

{$F+} procedure ExitCom; {$F-}

begin

  ExitProc := SaveExitProc;
  CloseCom;

  end;
begin

  with Async do begin
    Overflow := false;
    PortNum := $FFFF;
    Max := AsyncBufMax;
    Head := 0;
    Tail := 0;
    end;
  SaveExitProc := ExitProc;
  ExitProc := @ExitCom;

end.

