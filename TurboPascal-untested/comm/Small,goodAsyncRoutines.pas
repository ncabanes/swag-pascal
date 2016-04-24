(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0028.PAS
  Description: Small,Good ASYNC routines
  Author: GARY GORDON
  Date: 09-26-93  08:45
*)

{$B-} { Short circuit boolean ON }
{$I-} { I/O checking OFF }
{$R-} { Range checking OFF }
{$S-} { Stack checking OFF }
{$V-} { Var-str checking OFF}

UNIT ASYNC2;
  {PD async unit debugged and modified for doorgame use by Joel Bergen}
  {added com3 & com4 support and xon/xoff handshaking                 }
  {various bug fixes by Gary Gordon & Joel Bergen Jan 1990}
  {Last revised:  1/14/90}
  {still needs check for existance of comm port in Async_Open routine}

INTERFACE

USES DOS, CRT;

VAR
  Async_CheckCTS  : BOOLEAN;

PROCEDURE Async_Init;
  { initialize variables, call first to initialize }

PROCEDURE Async_Close;
  { reset the interrupt system when UART interrupts no longer needed }
  { Turn off the COM port interrupts.                                }
  { **MUST** BE CALLED BEFORE EXITING YOUR PROGRAM; otherwise you    }
  { will see some really strange errors and have to re-boot.         }

FUNCTION Async_Open(ComPort,BaudRate : WORD) : BOOLEAN;
  { open a communications port at 8/n/1 with supplied port & baud   }
  { Sets up interrupt vector, initialies the COM port for           }
  { processing, sets pointers to the buffer.  Returns FALSE if COM  }
  { port not installed.                                             }

FUNCTION Async_Buffer_Check : BOOLEAN;
  { see if a character has been received        }
  { If a character is available, returns TRUE   }
  { Otherwise, returns FALSE                    }

FUNCTION Async_Read : CHAR;
  { read a character, assuming it is ready}

PROCEDURE Async_Send(C : CHAR);
  { transmit a character }

PROCEDURE Async_Hangup;
  { drop carrier by dropping DTR}

FUNCTION Async_CarrierDetect : BOOLEAN;
  { true if carrier detected }

{----------------------------------------------------------------------------}

IMPLEMENTATION

CONST
  I8088_IMR = $21;   { port address of the Interrupt Mask Register }
  AsyncBasePort  : ARRAY[1..4] OF WORD = ($03F8,$02F8,$03E8,$02E8);
  AsyncIRQ       : ARRAY[1..4] OF WORD = (4,3,4,3);
  Async_Buffer_Max = 1024;          { size of input buffer }
  Ier = 1;
  Lcr = 3;
  Mcr = 4;
  Lsr = 5;
  Msr = 6;

VAR
  Async_OriginalVector : POINTER;
  Async_OriginalLcr    : INTEGER;
  Async_OriginalImr    : INTEGER;
  Async_OriginalIer    : INTEGER;

  Async_Buffer         : ARRAY[0..Async_Buffer_Max] OF CHAR;

  Async_Open_Flag      : BOOLEAN;   { true if Open but no Close }
  Async_Pause          : BOOLEAN;   { true if paused (Xoff received) }
  Async_Port           : INTEGER;   { current Open port number (1..4) }
  Async_Base           : INTEGER;   { base for current open port }
  Async_Irq            : INTEGER;   { irq for current open port }

  Async_Buffer_Overflow: BOOLEAN;   { True if buffer overflow has happened }
  Async_Buffer_Used    : WORD;      { number of characters in input buffer }

  { Async_Buffer is empty if Head = Tail }
  Async_Buffer_Head    : WORD;   { Locn in Async_Buffer to put next char }
  Async_Buffer_Tail    : WORD;   { Locn in Async_Buffer to get next char }

PROCEDURE DisableInterrupts; INLINE($FA {cli} );     {MACROS}
PROCEDURE EnableInterrupts;  INLINE($FB {sti} );

PROCEDURE Async_Isr;  INTERRUPT;
{ Interrupt Service Routine
  Invoked when the UART has received a byte of data from the
  communication line }
CONST
  Xon  = #17;  {^q resume}
  Xoff = #19;  {^s pause}
VAR
  c : CHAR;
BEGIN
  EnableInterrupts;
  IF Async_Buffer_Used < Async_Buffer_Max THEN BEGIN
    c := CHR(PORT[Async_Base]);
    CASE c OF
      Xoff : Async_Pause:=TRUE;
      Xon  : Async_Pause:=FALSE;
      ELSE BEGIN
        Async_Pause:=FALSE;
        Async_Buffer[Async_Buffer_Head] := c;
        IF Async_Buffer_Head < Async_Buffer_Max THEN
          INC(Async_Buffer_Head)
        ELSE
          Async_Buffer_Head := 0;
        INC(Async_Buffer_Used);
      END;
    END;
  END ELSE Async_Buffer_Overflow := TRUE;
  DisableInterrupts;
  PORT[$20] := $20;
END; { Async_Isr }

PROCEDURE Async_Init;
{ initialize variables }
BEGIN
  Async_Open_Flag       := FALSE;
  Async_Buffer_Head     := 0;
  Async_Buffer_Tail     := 0;
  Async_Buffer_Overflow := FALSE;
  Async_Buffer_Used     := 0;
  Async_Pause           := FALSE;
  Async_CheckCTS        := TRUE;
END; { Async_Init }

PROCEDURE Async_Close;
{ reset the interrupt system when UART interrupts no longer needed }
VAR
  i, m : INTEGER;
BEGIN
  IF Async_Open_Flag THEN BEGIN
    DisableInterrupts;             { disable IRQ on 8259 }
    PORT[Async_Base + Ier] := Async_OriginalIer;
    PORT[Async_Base+Lcr]   := Async_OriginalLcr;
    PORT[I8088_IMR]        := Async_OriginalImr;
    EnableInterrupts;
    SETINTVEC(Async_Irq + 8,Async_OriginalVector);
    Async_Open_Flag := FALSE     { flag port as closed }
  END
END; { Async_Close }

FUNCTION Async_Open(ComPort,BaudRate : WORD) : BOOLEAN;
VAR
  i, m : INTEGER;
  b    : BYTE;
BEGIN
    IF Async_Open_Flag THEN Async_Close;
    Async_Port := ComPort;
    Async_Base := AsyncBasePort[Async_Port];
    Async_Irq  := AsyncIRQ[Async_Port];
      { set comm parameters }
    Async_OriginalLcr := PORT[Async_Base+Lcr];

    PORT[Async_Base+Lcr] := $03;  {set 8/n/1. This shouldn't be hardcoded}
      { set ISR vector }
    GETINTVEC(Async_Irq+8, Async_OriginalVector);
    SETINTVEC(Async_Irq+8, @Async_Isr);
      { read the RBR and reset any possible pending error conditions }
      { first turn off the Divisor Access Latch Bit to allow access to RBR, etc. }
    DisableInterrupts;
    PORT[Async_Base+Lcr] := PORT[Async_Base+Lcr] AND $7F;
      { read the Line Status Register to reset any errors it indicates }
    i := PORT[Async_Base+Lsr];
      { read the Receiver Buffer Register in case it contains a character }
    i := PORT[Async_Base];
      { enable the irq on the 8259 controller }
    i := PORT[I8088_IMR];  { get the interrupt mask register }

    Async_OriginalImr := i;

    m := (1 shl Async_Irq) XOR $00FF;
    PORT[I8088_IMR] := i AND m;
      { enable the data ready interrupt on the 8250 }

    Async_OriginalIer := PORT[Async_Base + Ier];

    Port[Async_Base + Ier] := $01; { enable data ready interrupt }
      { enable OUT2 on 8250 }
    i := PORT[Async_Base + Mcr];
    PORT[Async_Base + Mcr] := i OR $08;
    EnableInterrupts;
      { Set baudrate}
    b := PORT[Async_Base+Lcr] OR 128;
    PORT[Async_Base+Lcr]:= b;
    PORT[Async_Base  ]  := LO(TRUNC(115200.0/BaudRate));
    PORT[Async_Base+1]  := HI(TRUNC(115200.0/BaudRate));
    PORT[Async_Base+Lcr]:= b AND 127;
      { set flags }
    Async_Open_Flag := TRUE;
    Async_Open := TRUE;
END; { Async_Open }

FUNCTION Async_Buffer_Check : BOOLEAN;
{ return true if character ready to receive }
BEGIN
  Async_Buffer_Check := (Async_Buffer_Used <> 0);
END; { Async_Buffer_Check }

FUNCTION Async_Read : CHAR;
{ return char, use Async_Buffer_Check first! }
BEGIN
  Async_Read := Async_Buffer[Async_Buffer_Tail];
  INC(Async_Buffer_Tail);
  IF Async_Buffer_Tail > Async_Buffer_Max THEN
    Async_Buffer_Tail := 0;
  DEC(Async_Buffer_Used);
END; { Async_Buffer_Check }

PROCEDURE Async_Send(c : CHAR);
{ transmit a character }
BEGIN
  PORT[Async_Base + Mcr] := $0B;                 {turn on OUT2, DTR, and RTS}
  IF Async_CheckCTS THEN
    WHILE (Port[Async_Base + Msr] AND $10) = 0 DO;  {wait for CTS}
  WHILE (Port[Async_Base + Lsr] AND $20) = 0 DO; {wait for Tx Holding Reg Empty}
  WHILE Async_Pause AND Async_CarrierDetect DO;  {wait for Xon}
  DisableInterrupts;
  PORT[Async_Base] := ORD(c);                    {send the character}
  EnableInterrupts;
END; { Async_Send }

PROCEDURE Async_Hangup;
BEGIN
  PORT[Async_Base+Mcr] := $00;  {dtr off}
  DELAY(1000);                  {wait 1 second}
  PORT[Async_Base+Mcr] := $03;  {dtr on}
END;

FUNCTION Async_CarrierDetect : BOOLEAN;
{true if carrier}
VAR
  b : BOOLEAN;
  w : WORD;
BEGIN
  w:=0; b:=TRUE;
  WHILE (w<500) AND b DO BEGIN              {make sure carrier stays down}
    INC(w);                                 {and is not just a fluke     }
    b:=(PORT[Async_Base+Msr] AND 128) <> 128; {true = no carrier};
  END;
  Async_CarrierDetect := NOT b;
END;

BEGIN
  Async_Init;
END. { ASYNC UNIT }

