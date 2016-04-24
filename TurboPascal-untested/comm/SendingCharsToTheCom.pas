(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0054.PAS
  Description: Sending Chars to the COM
  Author: ASGDC@ACVAX.INRE.ASU.EDU
  Date: 08-25-94  09:06
*)

{
> I have a Turbo Pascal "interrupt" routine which "catches" incoming
> characters from a COM port and stashes them in a circular buffer.
> While it seems to work OK most of the time, occasionally it misses
> a character (it can NOT keep up with 600 baud, but Kermit does quite
> well at 9600 baud, so I know it can be "fixed").  Here is the code:
> (Please ignore the BEGINPROCEDURE, ENDIF, etc.; I use a pre-processor
> to translate Pascal-as-it-ought-to-be-IMHO into Turbo Pascal.)
>
I don't know what the trouble is with your interrupt routine, but I wrote one
about 6 months ago for a friend to use and it works fine on my machine (386
33) at 2400 and on my friends machine (486 66) at 9600.  Here it is, hope it
helps.

This unit is an array implementation of a queue, used to store incoming
characters.  An array is used instead of a linked list because I believed it
would be faster, and less overhead.
}
UNIT QPak;
{$R-}
{Range checking must be turned off, so as to permit the little trick with
the array}

INTERFACE

TYPE
  ElementType = Char;

  ElementArray = ARRAY[0..0] OF Char;

  QUEUE   = RECORD
    Front,
    Rear  : Word;
    EL    : ^ElementArray;
    Size  : Word;
    Count : Word;
  END;

PROCEDURE MakeQueueEmpty(VAR Q : Queue;
                         QSize : Word);

FUNCTION  QueueIsEmpty(Q : Queue) : Boolean;

FUNCTION  QueueIsFull(Q : Queue) : Boolean;

PROCEDURE Enqueue(VAR Q   : Queue;
                  Element : ElementType);

PROCEDURE Dequeue(VAR Q       : Queue;
                  VAR Element : ElementType);

IMPLEMENTATION


PROCEDURE MakeQueueEmpty(VAR Q : Queue; QSize : Word);

BEGIN
  GetMem(Q.EL,QSize);
  Q.Front := 1;
  Q.Rear  := 0;
  Q.Size  := QSize;
  Q.Count := 0;
END;

FUNCTION QueueIsEmpty(Q : Queue) : Boolean;

BEGIN
  QueueIsEmpty := (Q.Count = 0);
END;

FUNCTION QueueIsFull(Q : Queue) : Boolean;

BEGIN
  QueueIsFull := (Q.Count = Q.Size);
END;


PROCEDURE Enqueue(VAR Q : Queue; Element : ElementType);

BEGIN
  WITH Q Do BEGIN
    Rear := (Rear + 1) MOD Size;
    EL^[Rear] := Element;
    Inc(Count);
  END;
END;

PROCEDURE Dequeue(VAR Q : Queue; VAR Element : ElementType);

BEGIN
  WITH Q DO BEGIN
    Element := EL^[Front];
    Front := (Front + 1) MOD Size;
    Dec(Count);
  END;
END;

END.
{
-----------------------CUT HERE--------------------

Here is the com unit.  I've commented about everyline (since it was for a
friend) so hopefilly my comments are understandable.

-----------------------CUT HERE---------------------
}
UNIT ComUnit;

INTERFACE

USES DOS, CRT, QPak;

PROCEDURE InitPort(ComPort,
                   Parity,
                   Stop,
                   WLength : Byte;
                   Speed   : Word);

FUNCTION CharReady(ComPort : Byte) : Boolean;

{This procedure  writes a char to desired port}
PROCEDURE SendChar(Ch : Char; ComPort : Byte);

{This function reads a char from the serial port by dequeueing and element}
FUNCTION GetChar(ComPort : Byte) : Char;

PROCEDURE ShutDown(ComPort : Byte);

TYPE
  UART = RECORD
     THR : Integer; {Transmit Holding Register}
     RBR : Integer; {Receive Holding Register}
     IER : Integer; {Interrupt enable Regeister}
     LCR : Word;    {Line Control Register}
     MCR : Integer; {Modem Control Register}
     LSR : Integer; {Line Status Register}
     MSR : Integer; {Modem Status Register}
     IRQ : Integer;
     DLL : Word;
     DLM : WOrd;
  END;

  {This array holds the buffers for each port}
  BufferArray  = ARRAY[1..4] OF Queue;
  {Here is where we save the old interrupt vectors}
  PointerArray = ARRAY[1..4] OF Pointer;


CONST
{The following are constants used in initialization, and for port adressing}
  COM1 = 1;
  COM2 = 2;
  COM3 = 3;
  COM4 = 4;

{Baud rate divisors}
  B600  = 192;
  B1200 = 96;
  B2400 = 48;
  B4800 = 24;
  B9600 = 12;
  B19200 = 6;
  B38400 = 3;  {If your really feeling frisky}

{Parity masks}
  NoParity   = 0;
  OddParity  = $8;
  EvenParity = $18;

{Stop bit masks}
  OneStopBit = 0;
  TwoStopBit = 2;

{OR-Mask to set divisor latch in line control register}
  DLatch      = $80;

{Port address for interrupt mask port of 8259A}
  IntMaskPort = $21;

{Port address for 8259 interrupt control, used to send EOI}
  IntCtlPort  = $20;

{Masks for different word lengths}
  Word5 = 0;
  Word6 = 1;
  Word7 = 2;
  Word8 = 3;

IMPLEMENTATION

CONST
{Typed constant that contains all registers addresses for Com1..Com4}
  RS232 : ARRAY[1..4] OF UART =

((THR:$3F8;RBR:$3F8;IER:$3F9;LCR:$3FB;MCR:$3FC;LSR:$3FD;MSR:$3FE;IRQ:4;DLL:$3F8
;
LM:$3F9),

(THR:$2F8;RBR:$2F8;IER:$2F9;LCR:$2FB;MCR:$2FC;LSR:$2FD;MSR:$2FE;IRQ:3;DLL:$2F8;
LM:$2F9),
 
(THR:$3E8;RBR:$3E8;IER:$3E9;LCR:$3EB;MCR:$3EC;LSR:$3ED;MSR:$3EE;IRQ:4;DLL:$3E8;
LM:$3E9),
 
(THR:$2E8;RBR:$2E8;IER:$2E9;LCR:$2EB;MCR:$2EC;LSR:$2ED;MSR:$2EE;IRQ:3;DLL:$2E8;
LM:$2E9));


VAR
  Buffers     : BufferArray;
  IntVecsSave : PointerArray;

{Inline Macros}
PROCEDURE DisableInterrupts ;   inline( $FA {cli} ) ;
PROCEDURE EnableInterrupts ;    inline( $FB {sti} ) ;

{Here is the interrupt procedure for com3, its address is put int the int
 Vec table by InitPort}
PROCEDURE Com13ISR; INTERRUPT;

BEGIN
{Read the character from the port and put it in the queue}
  Enqueue(Buffers[Com3],Char(Port[RS232[Com3].RBR]));
  Port[IntCtlPort] := $20;  {Non-specific EOI}
END;

PROCEDURE Com24ISR; INTERRUPT;

BEGIN
{Read the character from the port and put it in the queue}
  Enqueue(Buffers[Com3],Char(Port[RS232[Com3].RBR]));
  Port[IntCtlPort] := $20;  {Non-specific EOI}
END;

{---------------------------------------------------------------}
{                        +++InitPort+++                         }
{                                                               }
{  ComPort: A byte specifying the comport to use Range 1..4     }
{  Speed  : This is really the baud rate divisor The predefined }
{           constants are the correct divisors for those speeds }
{  Parity,                                                      }
{  Stop,                                                        }
{  WLength: These are all bit-masks used to build               }
{           the line format byte                                }
{---------------------------------------------------------------}
PROCEDURE InitPort(ComPort,
                   Parity,
                   Stop,
                   WLength : Byte;
                   Speed   : Word);

VAR
  LineFormat : Byte;


BEGIN
  MakeQueueEmpty(Buffers[ComPort],2048);
  LineFormat := 0;
{Build the line format byte}
  LineFormat := LineFormat OR WLength OR Stop OR Parity;
{Set divisor latch so we can set baud rate}
  Port[RS232[ComPort].LCR] := LineFormat AND DLatch;
{Now we set baud rate, least sig part of divisor sent first then most sig}
  Port[RS232[ComPort].DLL] := Low(Speed);
  Port[RS232[ComPort].DLM] := Hi(Speed);
{Now set line format}
  Port[RS232[ComPort].LCR] := LineFormat;
{Must set out2 of modem control reg for interrupts, so we do it here}
  Port[RS232[ComPort].MCR] := $0B;
{Save interrupt vector so we can restore it later, then set vector to
 point at our ISR}

{Now we must unmask appropriate int line in 8259A interrupt controller
 We are using IRQ4 for com1 and 3, and IRQ3 for com2 and 4, use of any
 other IRQ line will require changes to the code}
  IF ODD(ComPort) THEN BEGIN
    GetIntVec(RS232[ComPort].IRQ+8,IntVecsSave[ComPort]);
    SetIntVec(RS232[ComPort].IRQ+8,@Com13ISR);
    Port[IntMaskPort] := Port[IntMaskPort] AND $EF
  END ELSE BEGIN
    GetIntVec(RS232[ComPort].IRQ+8,IntVecsSave[ComPort]);
    SetIntVec(RS232[ComPort].IRQ+8,@Com24ISR);
    Port[IntMaskPort] := Port[IntMaskPort] AND $F7;
  END;
{Here we tell 8250 UART to interrupt on received chars}
  DisableInterrupts;
    Port[Rs232[ComPort].IER] := 1;
  EnableInterrupts;

END;

{This function returns true if there are any chars in the buffer}
FUNCTION CharReady(ComPort : Byte) : Boolean;

BEGIN
  CharReady := NOT QueueIsEmpty(Buffers[ComPort]);
END;

{This procedure  writes a char to desired port}
PROCEDURE SendChar(Ch : Char; ComPort : Byte);

BEGIN
  {Loop until transmit holding register empty}
  WHILE (Port[RS232[ComPort].LSR] AND $20) <> $20 DO
    Delay(1);
  Port[RS232[ComPort].THR] := Byte(Ch);
END;

{This function reads a char from the serial port by dequeueing and element}
FUNCTION GetChar(ComPort : Byte) : Char;

VAR
  Ch : Char;

BEGIN
  Dequeue(Buffers[ComPort],Ch);
  GetChar := Ch;
END;


PROCEDURE ShutDown(ComPort : Byte);

BEGIN
  SetIntVec(RS232[ComPort].IRQ+8,IntVecsSave[ComPort]);
END;

END.

{
------------------CUT HERE---------------------

One remark is probably appropriate here.  My friend had the need to read two
ports simultaneously so that is why there are two interrupt rountine, one com
1 and 3 and one for com 2 and 4, since they use the same IRQ lines.

Here is a little test program I used.

-----------------CUT HERE----------------------
}
USES CRT, ComUnit;
VAR
 Ch   : Char;
 Done : Boolean;

BEGIN
  Done := FALSE;
  InitPort(Com3,NoParity,OneStopBit,Word8,B2400);
  ClrScr;
  Writeln('Com test in progress.  F1 to exit');
  REPEAT
    IF CharReady(Com3) THEN BEGIN
      Ch := GetChar(Com3);
      Write(Ch);
    END
    ELSE IF Keypressed THEN BEGIN
      Ch := ReadKey;
      IF CH = #0 THEN BEGIN {Extended key scan code}
        Ch := Readkey;
        IF Ch = #59 THEN  {F1}
          Done := True;
      END ELSE
        SendChar(Ch,Com3);
    END
 UNTIL Done;
 ShutDown(Com3);
END.
{

I hope this helps.  It does work, although there could some thing wrong given
I'm no expert.  I also wrote some routines in assember about a year and a
half ago, so if you really want assembly code I'd be happy to did them out.
}


