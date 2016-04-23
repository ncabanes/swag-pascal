
This is a FAQ answer on serial communications using the TTY protocol. It
contains information on the TTY protocol and hardware and software implemen-
tations on IBM PCs which is derived from National Semiconductor data sheets.

PART ONE - HARDWARE & SOFTWARE


Acknowledgements
================

  The following persons have contributed (directly or indirectly :-) to this
summary:
      Madis Kaal <mast@anubis.kbfi.ee ??>     this address is known to be bad
      Steve Poulsen <stevep@ims.com>
      Scott C. Sadow <NS16550A@mycro.UUCP>
      Dan Norstedt <?>
        [Commercial: This line could display YOUR name!]



Introduction
============

  One of the most universal parts of the PC is its serial port. You can
connect a mouse, a modem, a printer, a plotter, another PC, ...
  But its usage (both software and hardware) is one of the best-kept secrets
for most users, besides that it is not difficult to understand how to
connect (not plug-in) devices to it and how to program it.
  Regard this FAQ as a manual of the serial port of your PC for both
hardware and software.


Historical summary
------------------

  In early days of telecommunications, errand-boys and optical signals (flags,
lights, clouds of smoke) were the only methods of transmitting information
across long distances. With increasing requirements on speed and growing
amount of information, more practical methods were developed. One milestone
was the first wire-bound transmission on May 24th, 1844 ("What hath God
wrought", using the famous Morse-alphabet). Well, technology improved a bit,
and soon there were machines that could be used like typewriters, except that
you typed not only on your own piece of paper but also on somebody elses.
The only thing that has changed on the step from the teletyper to your PC
is speed.


The TTY (teletyping) protocol
-----------------------------

  Definition: A protocol is a clear description of the LOGICAL method of
transmitting information. This does NOT include physical realisation.

  The TTYp uses two different states of the line called 'mark' and 'space'.
If no data is transmitted, the line is in the 'space' state. Data looks
like

      space  ----------+   +-------+   +---+   +-------
                       |   |       |   |   |   |
      mark             +---+       +---+   +---+

                        (1)  --------(2)-------- (3)

  (1) start bit   (2) data bits   (3) stop bit(s)

  Both transmitter (TX) and receiver (RX) use the same data rate (measured
in baud, which is the reciprocal value of the smallest time interval between
two changes of the line state. TX and RX know about the number of data
bits (probably with a parity bit added), and both know about the size of
the stop step (called the stop bit or the stop bits, depending on the size
of the stop step; normally 1, 1.5 or 2 times the size of a data bit). Data
is transmitted bit-synchroneously and word-asynchroneously, which means that
the size of the bits, the length of the word etc.pp. is clearly defined
but the time between two words is undefined.
  The start bit indicates the beginning of a new data word. It is used to
synchronize transmitter and receiver.
  Data is transmitted LSB to MSB, which means that the least significant
bit (Bit 0) is transmitted first with 4 to 7 bits of data following, re-
sulting in 5 to 8 bits of data. A logical '0' is transmitted by the
'space' state of the line, a logical '1' by 'mark'.
  A parity bit can be added to the data bits to allow error detection.
There are two (well, actually five) kinds of parity: odd and even (plus
none, mark and space). Odd parity means that the number of 'mark' steps in
the data word (including parity bit) is always odd, so the parity bit is
set accordingly (I don't have to explain 'even' parity, must I?). It is
also possible to set the parity bit to a fixed state or to omit it.
  The stop bit does not indicate the end of the word (as it could be
derived from its name); it rather separates two consecutive words by
putting the line into the 'space' state for a minimum time.
  The protocol is usually described by a sequence of numbers and letters,
e.g. 8n1 means 1 start bit (always), 8 bits of data, no parity bit, 1 stop
bit. 7e2 would indicate 7 bits of data, even parity, 2 stop bits (but I've
never seen this one...). The usual thing is 8n1 or 7e1.
  Early teletypers used the neckbreaking speed of 50 baud (which means
that one step is 20ms), 5 bits of data, no parity and 1.5 stop bits (don't
ask me why!). Your PC is capable of serial transmission at up to 115,200
baud (step size of 8.68 microseconds!). Typical rates are 300 baud, 1200 baud,
2400 baud and 9600 baud.


The physical transmission
-------------------------

  Teletypers used a closed-loop line with a space current of 20ma and a
mark current of 0ma (typical), which allowed to detect a 'broken line'.
The RS232C port of your PC uses voltages rather than currents to indicate
logical states: 'space' is signaled by +3v to +15v (typically +12v), 'mark'
by -3v to -15v (typically -12V). The typical output impedance of the serial
port of a PC is 2 kiloohms (resulting in about 5ma @ 10v), the typical input
impedance is about 4.3 kiloohms, so there should be a maximum fan-out of 5
(5 inputs can be connected to 1 output). Please don't rely on this, it may
differ from PC to PC.
  Three lines (RX, TX & ground) are needed.

Q. Why does my PC have a 25pin/9pin connector if there are only 3 lines
   needed?
A. There are several status lines that are only used with a modem. See the
   software section of this FAQ.

Q. How can I easily connect two PCs by a three-wire lead?
A. This connection is called a 'null-modem' connection. RX1 is connected
   to TX2 and vice versa, GND1 to GND2. In addition to this, connect RTS
   to CTS & DCD and DTR to DSR (modem software often relies on that). See
   the hardware section for further details.


Hardware
========


The connectors
--------------

  PCs have 9pin/25pin male SUB-D connectors. The pin layout is as follows
(looking at the back side of your PC):

        1                         13             1               5
      _______________________________      _______________
      \  . . . . . . . . . . . . .  /      \  . . . . .  /
       \  . . . . . . . . . . . .  /            \  . . . .  /
        ---------------------------          -----------
        14                      25            6       9

 Name (V24)  25pin  9pin  Dir  Full name               Remarks
--------------------------------------------------------------------------
    TxD         2     2    o   Transmit Data
    RxD         3     3    i   Receive Data
    RTS         4     5    o   Request To Send
    CTS         5     8    i   Clear To Send
    DTR        20     4    o   Data Terminal Ready
    DSR         6     6    i   Data Set Ready
    RI         22     9    i   Ring Indicator
    DCD         8     1    i   Data Carrier Detect
    GND         7     5    -   Signal ground
     -          1     -    -   Protective ground       Don't use this one!
    SCTE       24     -    -   Sync. clock trans. end  Several PCs only
    SCT        15     -    o   Sync. clock TX          dito.
    SCR        17     -    i   Sync. clock RX          dito.

  The most important lines are RxD, TxD, and GND. Others are used with
modems, printers and plotters to indicate internal states or to use
synchroneous transmission (this is rarely used, and most PCs don't support
it).
  '0' means +3v to +15V, '1' means -3v to -15v. '1' is the active state.

  The lines are:

  RxD, TxD: These lines carry the data.
  RTS, CTS: Are used by the PC and the modem/printer/whatsoever (further
    on referred to as the data set) to start/stop a communication. The PC
    sets RTS to its active state ('1'), and the data set responds with CTS
    '1' (always in this order). If the data set wants to stop/interrupt the
    communication (e.g. buffer overflow), it drops CTS to '0'; the PC uses
    RTS to control the data flow.
  DTR, DSR: Are used to establish a connection at the very beginning, i.e.
    the PC and the data set 'shake hands' first to assure they are both
    present. The PC sets DTR to '1', and the data set answers with DSR
    '1'. Modems often indicate hang-up by resetting DSR to '0'.
  (These six lines plus GND are often referred to as '7 wire'-connection or
  'hand shake'-connection.)
  DCD: The modem uses this line to indicate that it has detected the
    carrier of the modem on the other side of the line.
  RI: The modem uses this line to signal that 'the phone rings' (even if
    there isn't a bell fitted to your modem).
  SCTE, SCT, SCR: forget about these.
  Protective ground: This line is connected to the power ground of the
    serial adapter. It should not be used as a signal ground, and it
    MUST NOT be connected to GND (even if your DMM shows up a
    connection!). Connect this line to the screen of the lead (if there is
    one).

  Technical data (typical):

    Signal level: -10.5v/+11v
    Short circuit current: 6.8ma  (yes, that's enough for your mouse!)
    Output impedance: 2 kiloohms
    Input impedance: 4.3 kiloohms


Connecting devices
------------------

  Normally, a 7 wire connection is used. Connect:
        GND1    to    GND2
        RxD1    to    TxD2
        TxD1    to    RxD2
        DTR1    to    DSR2
        DSR1    to    DTR2
        RTS1    to    CTS2
        CTS1    to    RTS2
  If a modem is connected, add lines for the following:
        RI, DCD
  If software wants it, connect DCD1 to CTS1 and DCD2 to CTS2.
  BEWARE! While PCs use pin 2 for RxD and pin 3 for TxD, modems normally
have those pins reversed! This allows to easily connect pin1 to pin1, pin2
to pin 2 etc. If you connect two PCs, cross RxD and TxD.

  If hardware handshaking is not needed, a so-called null-modem connection
can be used. Connect:
        GND1    to    GND2
        RxD1    to    TxD2
        TxD1    to    RxD2
Additionally, connect (if software needs it):
        RTS1    to    CTS1 & DCD1
        RTS2    to    CTS2 & DCD2
        DTR1    to    DSR1
        DTR2    to    DSR2
You won't need long wires for these!
  The null-modem connection is used to establish an XON/XOFF-transmission
between two PCs (see software section for details).
  Remember: the names DTR, DSR, CTS & RTS refer to the lines as seen from
the PC. This means that for your data set DTR & RTS are incoming signals
and DSR & CTS are outputs!


Base addresses & interrupts
---------------------------

  Normally, the following list is correct:


    Port     Base address    Int #

    COM1         0x3F8        0xC
    COM2         0x2F8        0xB
    COM3         0x3E8        0xC
    COM4         0x2E8        0xB


  In PCs, serial communication is realized with a set of three chips
(there are no further components needed!): a UART (Universal Asynchroneous
Receiver/Transmitter) and two line drivers. Normally, the 82450/16450/8250
does the 'brain work' while the 1488 and 1489 drive the lines.
  The chips are produced by many manufacturers; it's of no importance
which letters are printed in front of the numbers (mostly NS for National
Semiconductor). Don't regard the letters behind the number also; they just
indicate special features and packaging (Advanced, FIFO, New, MILitary,
bug fixes [see below] etc.).
  You might have heard of the possibility to replace the 16450 by a 16550A
to improve reliability and software throughput. This is only useful if your
software is able to use the FIFO (first in-first out) buffer features. The
chips are fully pin-compatible except for two pins that are not used by
any board known to the author: pin 24 (CSOUT, chip select out) and pin 29
(NC, no connection to be made). With the 16550A, pin 24 is -TXRDY and pin
29 is -RXRDY, signals that aren't needed and that even won't care if they
are shorted to +5v or ground. Therefore it should always be possible to
simply replace the 16450 by the 16550A - even if it's not always useful due
to lacking software capabilities. IT IS DEFINITELY NOT NECESSARY FOR
COMMUNICATION UP TO LOUSY 9600 BAUD! These rates can easily be handled by
any CPU and the interrupt-driven communication won't slow down the computer
substantially. But if you want to use high-speed transfer with or without
using the interrupt features (i.e. by 'polling'), it is recommended to use
the 16550A in order to make transmission more reliable if your software
supports it (see excursion some pages below).


How to detect which chip is used
--------------------------------

  This is really not difficult. The 8250 has no scratch register (see data
sheet info below), the 16450/82450 has no FIFO, the 16550 has no working
FIFO :-) and the 16550A performs alright. See the software section for
an example.


Data sheet information
----------------------

  Some hardware information taken from the data sheet of National
Semiconductor (shortened and commented):

  Pin description of the 16450(16550A) [Dual-In-Line package]:

                   +-----+ +-----+
               D0 -|  1  +-+   40|- VCC
               D1 -|  2        39|- -RI
               D2 -|  3        38|- -DCD
               D3 -|  4        37|- -DSR
               D4 -|  5        36|- -CTS
               D5 -|  6        35|- MR
               D6 -|  7        34|- -OUT1
               D7 -|  8        33|- -DTR
             RCLK -|  9        32|- -RTS
              SIN -| 10        31|- -OUT2
             SOUT -| 11        30|- INTR
              CS0 -| 12        29|- NC (-RXRDY)
              CS1 -| 13        28|- A0
             -CS2 -| 14        27|- A1
         -BAUDOUT -| 15        26|- A2
              XIN -| 16        25|- -ADS
             XOUT -| 17        24|- CSOUT (-TXRDY)
              -WR -| 18        23|- DDIS
               WR -| 19        22|- RD
              VSS -| 20        21|- -RD
                   +-------------+

A0, A1, A2, Register Select, Pins 26-28:
Address signals connected to these 3 inputs select a UART register for
the CPU to read from or to write to during data transfer. A table of
registers and their addresses is shown below. Note that the state of the
Divisor Latch Access Bit (DLAB), which is the most significant bit of the
Line Control Register, affects the selection of certain UART registers.
The DLAB must be set high by the system software to access the Baud
Generator Divisor Latches.

  DLAB  A2  A1  A0    Register
    0    0   0   0    Receive Buffer (read) Transmitter Holding Reg. (write)
    0    0   0   1    Interrupt Enable
    x    0   1   0    Interrupt Identification (read)
    x    0   1   0    FIFO Control (write) (undefined on the 16450. CB)
    x    0   1   1    Line Control
    x    1   0   0    Modem Control
    x    1   0   1    Line Status
    x    1   1   0    Modem Status
    x    1   1   1    Scratch (special use on some boards. CB)
    1    0   0   0    Divisor Latch (LSB)
    1    0   0   1    Divisor Latch (MSB)

-ADS, Address Strobe, Pin 25: The positive edge of an active Address
Strobe (-ADS) signal latches the Register Select (A0, A1, A2) and Chip
Select (CS0, CS1, -CS2) signals.
Note: An active -ADS input is required when Register Select and Chip
Select signals are not stable for the duration of a read or write
operation. If not required, tie the -ADS input permanently low. (As it is
done in your PC. CB)

-BAUDOUT, Baud Out, Pin 15: This is the 16 x clock signal from the
transmitter section of the UART. The clock rate is equal to the main
reference oscillator frequency divided by the specified divisor in the
Baud Generator Divisor Latches. The -BAUDOUT may also be used for the
receiver section by tying this output to the RCLK input of the chip. (Yep,
that's true for your PC. CB).

CS0, CS1, -CS2, Chip Select, Pins 12-14: When CS0 and CS1 are high and CS2
is low, the chip is selected. This enables communication between the UART
and the CPU.

-CTS, Clear To Send, Pin 36: When low, this indicates that the modem or
data set is ready to exchange data. This signal can be tested by reading
bit 4 of the MSR. Bit 4 is the complement of this signal, and Bit 0 is '1'
if -CTS has changed state since the previous reading (bit0=1 generates an
interrupt if the modem status interrupt has been enabled).

D0-D7, Data Bus, Pins 1-8: Connected to the data bus of the CPU.

-DCD, Data Carrier Detect, Pin 38: blah blah blah, can be tested by
reading bit 7 / bit 3 of the MSR. Same text as -CTS.

DDIS, Driver Disable, Pin 23: This goes low whenever the CPU is reading
data from the UART.

-DSR, Data Set Ready, Pin 37: blah, blah, blah, bit 5 / bit 1 of MSR.

-DTR, Data Terminal Ready, Pin 33: can be set active low by programming
bit 0 of the MCR '1'. Loop mode operation holds this signal in its
inactive state.

INTR, Interrupt, Pin 30: goes high when an interrupt is requested by the
UART. Reset low by the MR.

MR, Master Reset, Pin 35: Schmitt Trigger input, resets internal registers
to their initial values (see below).

-OUT1, Out 1, Pin 34: user-designated output, can be set low by
programming bit 2 of the MCR '1' and vice versa. Loop mode operation holds
this signal inactive high.

-OUT2, Out 2, Pin 31: blah blah blah, bit 3. (Used in your PC to connect
the UART to the interrupt line of the slot when '1'. CB)

RCLK, Receiver Clock, Pin 9: This input is the 16 x baud rate clock for
the receiver section of the chip. (Normally connected to -BAUDOUT, as in
your PC. CB)

RD, -RD, Read, Pins 22 and 21: When Rd is high *or* -RD is low while the
chip is selected, the CPU can read data from the UART. (One of these is
normally tied. CB)

-RI, Ring Indicator, Pin 39: blah blah blah, Bit 6 / Bit 2 of the MSR.
(Bit 2 indicates only change from active low to inactive high! Curious,
isn't it? CB)

-RTS, Request To Send, Pin 32: blah blah blah, see DTR (Bit 1).

SIN, Serial Input, Pin 10.

SOUT, Serial Output, Pin 11: ... Set to 'space' (high) upon MR.

-RXRDY, -TYRDY: refer to NS data sheet. Those pins are used for DMA
channeling. Since they are not connected in your PC, I won't describe them
here.

VCC, Pin 40, +5v

VSS, Pin 20, GND

WR, -WR: same as Rd, -RD for writing data.

XIN, XOUT, Pins 16 and 17: Connect a crystal here (1.5k betw. xtal & pin 17)
and pin 16 with a capacitor of approx. 20p to GND and other xtal conn. 40p
to GND. Resistor of approx. 1meg parallel to xtal. Or use pin 16 as an input
and pin 17 as an output for an external clock signal.


Absolute Maximum Ratings:

  Temperature under bias: 0 C to +70 C
  Storage Temperature: -65 C to 150 C
  All input or output voltages with respect to VSS: -0.5v to +7.0v
  Power dissipation: 1W

Further electrical characteristics see the very good data sheet of NS.

UART Reset Configuration

Register/Signal        Reset Control      Reset State
--------------------------------------------------------------------
  IER                       MR            0000 0000
  IIR                       MR            0000 0001
  FCR                       MR            0000 0000
  LCR                       MR            0000 0000
  MCR                       MR            0000 0000
  LSR                       MR            0110 0000
  MSR                       MR            xxxx 0000 (according to signals)
  SOUT                      MR            high
  INTR (RCVR errs)     Read LSR/MR        low
  INTR (data ready)    Read RBR/MR        low
  INTR (THRE)          Rd IIR/Wr THR/MR   low
  INTR (modem status)  Read MSR/MR        low
  -OUT2                     MR            high
  -RTS                      MR            high
  -DTR                      MR            high
  -OUt1                     MR            high
  RCVR FIFO           MR/FCR1&FCR0/DFCR0  all bits low
  XMIT FIFO           MR/FCR1&FCR0/DFCR0  all bits low



Known problems with several chips
---------------------------------

(From material Madis Kaal received from Dan Norstedt)

    8250 and 8250-B:

        * These UARTs pulse the INT line after each interrupt cause has
          been serviced (which none of the others do). [Generates interrupt
          overhead. CB]

        * The start bit is about 1 us longer than it ought to be. [This
          shouldn't be a problem. CB]

        * 5 data bits and 1.5 stop bits doesn't work.

        * When a 1 bit is written to the bit 1 (Tx int enab) in the IER,
          a Tx interrupt is generated. This is an erroneous interrupt
          if the THRE bit is not set. [So don't set this bit as long as
          the THRE bit isn't set. CB]

        * The first valid Tx interrupt after the Tx interrupt is enabled
          is probably missed. Suggested workaround:
          1) Wait for the TRHE bit to become set.
          2) Disable CPU interrupts.
          3) Write Tx interrupt enable to the IER.
          4) Write Tx interrupt enable to the IER, again.
          5) Enable CPU interrupts.

        * The TSRE (bit 6) doesn't work properly.

        * If both the Rx and Tx interrupts are enabled, and a Rx interrupt
          occurs, the IIR indication may be lost; Suggested workarounds:
          1) Test THRE bit in the Rx routine, and either set IER bit 1
             or call the Tx routine directly if it is set.
          2) Test the THRE bit instead of using the IIR.

        * [If one of these chips vegetates in your PC, go get your solder
          iron heated... CB]

    8250A, 82C50A, 16450 and 16C450:

        * (Same problem as above:)
          If both the Rx and Tx interrupts are enabled, and a Rx interrupt
          occurs, the IIR indication may be lost; Suggested workarounds:
          1) Test THRE bit in the Rx routine, and either set IER bit 1
             or call the Tx routine directly if it is set.
          2) Test the THRE bit instead of using the IIR.
          3) [Don't enable both interrupts at the same time. I've never
             had any need to do this. CB]

    16550 (without the A):

        * Rx FIFO bug: Sometimes a FIFO will get extra characters.
          [This seemed to be very embarracing for NS; they've added a
          simple detection method in the 16550A (bit 6 of IIR). CB]

No bugs reported in the 16550A (yet?)

[Same is true for the 16C552, a two-in-one version of the 16550A. CB]



Software
========


  First some information from the data sheet. Then: HOW TO USE IT.


Register Description
--------------------

See "Hardware" for addresses.

Register  Bit 0    Bit 1    Bit 2    Bit 3    Bit 4    Bit 5    Bit 6    Bit 7

RBR (r/o)  ----------------------- data bits received ------------------------
THR (w/o)  ------------------ data bits to be transmitted --------------------
IER       ERBFI    ETBEI    ELSI     EDSSI      0        0        0       0
IIR (r/o) pending  IID0     IID1     IID2       0        0      FIFO en  FIFOen
FCR (w/o) enable   RFres    XFres    DMAsel     0        0      - RX trigger -
LCR       - word length -   stopbits PAR en   even sel stick par SBR     DLAB
MCR       DTR      RTS      OUT1     OUT2     Loop       0        0       0
LSR       RBF      OE       PE       FE       Break    THRE     TEMT    FIFOerr
MSR       DCTS     DDSR     TERI     DDCD     CTS      DSR      RI      DCD

ERBFI:   Enable Receiver Buffer Full Interrupt
ETBEI:   Enable Transmitter Buffer Empty Interrupt
ELSI:    Enable Line Status Interrupt
EDSSI:   Enable Delta Status Signals Interrupt
IID#:    Interrupt IDentification
RFres:   Receiver FIFO reset
XFres:   Transmitter FIFO reset
SBR:     Set BReak
RBF:     Receiver Buffer Full (Data Available)
OE:      Overrun Error
PE:      Parity Error
FE:      Framing Error
THRE:    Transmitter Holding Register Empty (new data can be written to THR)
TEMT:    Transmitter Empty (last word has been sent)
DCTS:    Delta Clear To Send
DDSR:    Delta Data Set Ready
TERI:    Trailing Edge Ring Indicator
DDCD:    Delta Data Carrier Detect

LCR (Line Control Register):

   Bit 1  Bit 0    word length         Bit 2      Stop bits
     0      0        5 bits              0            1
     0      1        6 bits              1          1.5/2
     1      0        7 bits         (1.5 if word length is 5)
     1      1        8 bits   (1.5 does not work with some chips, see above)

   Bit 5  Bit 4  Bit 3     Parity type       Bit 6   SOUT condition
     x      x      0       no parity           0     normal operation
     0      0      1       odd parity          1     force 'mark' (break)
     0      1      1       even parity       Bit 7   DLAB
     1      0      1       mark parity         0     normal registers
     1      1      1       space parity        1     divisor at reg 0, 1

Baud Rate Generator:

  DLAB must be set. Write word (16 bits) to address 0 of the UART (this is
the base address) to program baud rate as follows:
     xtal frequency in Hz / 16 / rate = divisor
  Your PC uses an xtal frequency of 1.8432 MHz.
  Do *NOT* use 0 as a divisor (your maths teacher told you so)! [It
results in a rate of some 1000 baud. CB]
  An error of up to 5 percent is irrelevant.
  Some values:

     Baud rate   Divisor (hex)   Percent Error
         50          900             0.0%
         75          600             0.0%
        110          417             0.026%
        134.5        359             0.058%
        150          300             0.0%
        300          180             0.0%
        600           C0             0.0%
       1200           60             0.0%
       1800           40             0.0%
       2000           3A             0.69%
       2400           30             0.0%
       3600           20             0.0%
       4800           18             0.0%
       7200           10             0.0%
       9600            C             0.0%
      19200            6             0.0%
      38400            3             0.0%
      56000            2             2.86%
     115200            1             0.0%

  NS specifies that the 16550A is capable of 256 kbaud if you use a 4 MHz
or an 8 MHz crystal. But a staff member of NS Germany (I know that this
abbreviation is not well-chosen :-( ) told one of my friends on the phone
that it runs correctly at 512 kbaud as well, but I don't know if the
1488/1489 manage this. This is true for the 16C552, too.
  BTW: Ever tried 1.76 baud? Kindergarten kids write faster.
  Mice typically use 2400 baud, 8n1.


LSR (Line Status Register):

   Bit 0    Data Ready (DR). Reset by reading RBR.
   Bit 1    Overrun Error (OE). Reset by reading LSR. Indicates loss of data.
   Bit 2    Parity Error (PE). Indicates transmission error. Reset by LSR.
   Bit 3    Framing Error (FE). Indicates missing stop bit. Reset by LSR.
   Bit 4    Break Indicator (BI). Set if 'space' for more than 1 word. Reset
            by LSR.
   Bit 5    Transmitter Holding Register Empty (THRE). Indicates that a new
            word can be written to THR. Reset by writing THR.
   Bit 6    Transmitter Empty (TEMT). Indicates that no transmission is
            running. Reset by reading LSR.
   Bit 7    Set if at least 1 word in FIFO has been received with an error.
            Cleared by reading LSR if there is no further error in the FIFO.

FCR (FIFO Control Register):

   Bit 0:   FIFO enable.
   Bit 1:   Clear receiver FIFO. This bit is self-clearing.
   Bit 2:   Clear transmitter FIFO. This bit is self-clearing.
   Bit 3:   DMA mode (pins -RXRDY and -TXRDY), see sheet
   Bits 6-7:Trigger level of the DR-interrupt.
   Bit 7  Bit 6    Receiver FIFO trigger level
     0      0         01
     0      1         04
     1      0         08
     1      1         14


   Excursion: why and how to use the FIFOs (by Scott C. Sadow)
   -----------------------------------------------------------

   Normally when transmitting or receiving, the UART generates an
   interrupt for every character sent or received. For 2400 baud, typically
   this is 240/second. For 115,200 baud, this means 11,520/second. With FIFOs
   enabled, the number of interrupts is greatly reduced. For transmit
   interrupts, the UART indicates the transmit holding register is not busy
   until the 16 byte FIFO is full. A transmit hold register empty interrupt
   is not generated until the FIFO is empty (last byte is being sent) Thus,
   the number of transmit interrupts is reduced by a factor of 16. For
   115,200 baud, this means only 7,200 interrupts/second. For receive data
   interrupts, the processing is similar to transmit interrupts. The main
   difference is that the number of bytes in the FIFO before generating an
   interrupt can be set. When the trigger level is reached, a recieve data
   interrupt is generated, but any other data received is put in the FIFO.
   The receive data interrupt is not cleared until the number of bytes in the
   FIFO is below the trigger level.

   To add 16550A support to existing code, there are 2 requirements.

      1) When reading the IIR to determine the interrupt source, only
         use the lower 3 bits.

      2) After the existing UART initialization code, try to enable the
         FIFOs by writing to the FCR. (A value of C7 hex will enable FIFO mode,
         clear both FIFOs, and set the receive trigger level at 14 bytes) Next,
         read the IIR. If Bit 6 of the IIR is not set, the UART is not a
         16550A, so write 0 to the FCR to disable FIFO mode.


IIR (Interrupt Identification Register):

   Bit 3  Bit 2  Bit 1  Bit 0    Priority   Source    Description
     0      0      0      1                 none
     0      1      1      0      highest    Status    OE, PE, FE or BI of the
                                                      LSR set. Serviced by
                                                      reading the LSR.
     0      1      0      0      second     Receiver  DR or trigger level rea-
                                                      ched. Serviced by read-
                                                      ing RBR 'til under level
     1      1      0      0      second     FIFO      No Receiver FIFO action
                                                      since 4 words' time
                                                      (neither in nor out) but
                                                      data in RX-FIFO. Serviced
                                                      by reading RBR.
     0      0      1      0      third      Transm.   THRE. Serviced by read-
                                                      ing IIR (if source of
                                                      int only!!) or writing
                                                      to THR.
     0      0      0      0      fourth     Modem     One of the delta flags
                                                      in the MSR set. Serviced
                                                      by reading MSR.
   Bit 6 & 7: 16550A: set if FCR bit 0 set.
              16550:  bit 7 set, bit 6 cleared
              others: clear
   In most software applications bits 3, 6 & 7 should be masked when servicing
   the interrupt since they are not relevant. These bits cause trouble with
   old software relying on that they are cleared...
   NOTE! Even if some of these interrupts are masked, the service routine
   can be confronted with *all* states shown above when the IIR is loop-polled
   until bit 0 is set. Check examples.

IER (Interrupt Enable Register):

   Bit 0:   If set, DR interrupt is enabled.
   Bit 1:   If set, THRE interrupt is enabled.
   Bit 2:   If set, Status interrupt is enabled.
   Bit 3:   If set, Modem status interrupt is enabled.

MCR (Modem Control Register):

   Bit 0:   Programs -DTR. If set, -DTR is low and the DTR pin of the port is
            '1'.
   Bit 1:   Programs -RTS.
   Bit 2:   Programs -OUT1. Not used in a PC.
   Bit 3:   Programs -OUT2. If set, interrupts generated by the UART are trans-
            ferred to the ICU (Interrupt Control Unit).
   Bit 4:   '1': local loopback. All outputs disabled.

MSR (Modem Status Register):

   Bit 0:   Delta CTS. Set if CTS has changed state since last reading.
   Bit 1:   Delta DSR. Set if DSR has changed state since last reading.
   Bit 2:   TERI. Set if -RI has changed from low to high (i.e. RI at port
            has changed from '1' to '0').
   Bit 3:   Delta DCD. Set if DCD has changed state since last reading.
   Bit 4:   CTS. 1 if '1' at port.
   Bit 5:   DSR.
   Bit 6:   RI. If loopback is selected, it is equivalent to OUT1.
   Bit 7:   DCD.


PART TWO - PROGRAMMING


Programming
-----------

  Now for the clickety-clickety thing. I hope you're a bit keen in
assembler programming (if not, you've got a problem B-). Programming the UART
in high level languages is, of course, possible, but not at very high
rates or interrupt-driven. I give you several routines in assembler (and,
wherever possible, in C) that do the dirty work for you.

  First thing to do is detect which chip is used. It shouldn't be difficult
to convert this C function into assembler; I'll omit the assembly version.

int detect_UART(unsigned baseaddr)
{
   // this function returns 0 if no UART is installed.
   // 1: 8250, 2: 16450, 3: 16550, 4: 16550A
   int x;
   // first step: see if the LCR is there
   outp(baseaddr+3,0x1b);
   if (inp(baseaddr+3)!=0x1b) return 0;
   outp(baseaddr+3,0x3);
   if (inp(baseaddr+3)!=0x3) return 0;
   // next thing to do is look for the scratch register
   outp(baseaddr+7,0x55);
   if (inp(baseaddr+7)!=0x55) return 1;
   outp(baseaddr+7,0xAA);
   if (inp(baseaddr+7)!=0xAA) return 1;
   // then check if there's a FIFO
   outp(baseaddr+2,0x1);
   x=inp(baseaddr+2);
   if ((x&0x80)==0) return 2;
   if ((x&0x40)==0) return 3;
   return 4;
}

  Remember: if it's not a 16550A, don't use the FIFO mode!


  Now the non-interrupt version of TX and RX.

  Let's assume the following constants are set correctly (either by
'CONSTANT EQU value' or by '#define CONSTANT value'). You can easily use
variables instead, but I wanted to save the extra lines for the ADD
commands necessary then...

  UART_BASEADDR   the base address of the UART
  UART_BAUDRATE   the divisor value (e.g. 12 for 9600 baud)
  UART_LCRVAL     the value to be written to the LCR (e.g. 0x1b for 8N1)
  UART_FCRVAL     the value to be written to the FCR. Bit 0, 1 and 2 set,
                  bits 6 & 7 according to trigger level wished (see above).
                  0x87 is a good value.

  First thing to do is initializing the UART. This works as follows:

init_UART proc near
  push ax  ; we are 'clean guys'
  push dx
  mov  dx,UART_BASEADDR+3  ; LCR
  mov  al,80h  ; set DLAB
  out  dx,al
  mov  dx,UART_BASEADDR    ; divisor
  mov  ax,UART_BAUDRATE
  out  dx,ax
  mov  dx,UART_BASEADDR+3  ; LCR
  mov  al,UART_LCRVAL  ; params
  out  dx,al
  mov  dx,UART_BASEADDR+4  ; MCR
  xor  ax,ax  ; clear loopback
  out  dx,al
  ;***
  pop  dx
  pop  ax
  ret
init_UART endp

void init_UART()
{
   outp(UART_BASEADDR+3,0x80);
   outpw(UART_BASEADDR,UART_BAUDRATE);
   outp(UART_BASEADDR+3,UART_LCRVAL);
   outp(UART_BASEADDR+4,0);
   //***
}

  If we wanted to use the FIFO functions of the 16550A, we'd have to add
some lines to the routines above (where the ***s are).
In assembler:
  mov  dx,UART_BASEADDR+2  ; FCR
  mov  al,UART_FCRVAL
  out  dx,al
And in C:
   outp(UART_BASEADDR+2,UART_FCRVAL);

  Don't forget to disable the FIFO when your program exits! Some other
software may rely on this!

  Not very complex so far, isn't it? Well, I told you so at the very
beginning, and we wanted to start easy. Now let's send a character.

UART_send proc near
  ; character to be sent in AL
  push dx
  push ax
  mov  dx,UART_BASEADDR+5
us_wait:
  in   al,dx  ; wait until we are allowed to write a byte to the THR
  test al,20h
  jz   us_wait
  pop  ax
  mov  dx,UART_BASEADDR
  out  dx,al  ; then write the byte
  pop  ax
  pop  dx
  ret
UART_send endp

void UART_send(char character)
{
   while ((inp(UART_BASEADDR+5)&0x20)!=0) {;}
   outp(UART_BASEADDR,(int)character);
}

  This one sends a null-terminated string.

UART_send_string proc near
  ; DS:SI contains a pointer to the string to be sent.
  push si
  push ax
  push dx
  cld  ; we want to read the string in its correct order
uss_loop:
  lodsb
  or   al,al  ; last character sent?
  jz   uss_ende
  ;*1*
  mov  dx,UART_BASEADDR+5
  push ax
uss_wait:
  in   al,dx
  test al,20h
  jz   uss_wait
  mov  dx,UART_BASEADDR
  pop  ax
  out  dx,al
  ;*2*
  jmp  uss_loop
uss_ende:
  pop  dx
  pop  ax
  pop  si
  ret
UART_send_string endp

void UART_send_string(char *string)
{
   int i;
   for (i=0; string[i]!=0; i++)
      {
      //*1*
      while ((inp(UART_BASEADDR+5)&0x20)!=0) {;}
      outp(UART_BASEADDR,(int)string[i]);
      //*2*
      }
}

  Of course, we could have used our already programmed function/procedure
UART_send instead of the piece of code limited by *1* and *2*, but we are
interested in high-speed code.

  It shouldn't be a hard nut for you to modify the above function/procedure
so that it sends a block of data rather than a null-terminated string. I'll
omit that here.

  Now for reception. We want to program routines that do the following:
  - check if a character received or an error occured
  - read a character if there's one available

  Both the C and the assembler routines return 0 (in AX) if there is
neither an error condition nor a character available. If a character is
available, Bit 8 is set and AL or the lower byte of the return value
contains the character. Bit 9 is set if we lost data (overrun), bit 10
signals a parity error, bit 11 signals a framing error, bit 12 shows if
there is a break in the data stream and bit 15 signals if there are any
errors in the FIFO (if we turned it on). The procedure/function is much
smaller than this paragraph:

UART_get_char proc near
  push dx
  mov  dx,UART_BASEADDR+5
  in   al,dx
  mov  ah,al
  and  ah,9fh
  test al,1
  jz   ugc_nochar
  mov  dx,UART_BASEADDR
  in   al,dx
ugc_nochar:
  pop  dx
  ret
UART_get_char endp

unsigned UART_get_char()
{
   unsigned x;
   x=(inp(UART_BASEADDR+5)<<8)&0x9f;
   if (x&0x100) x|=((unsigned)inp(UART_BASEADDR))&0xff);
   return x;
}

  This procedure/function lets us easily keep track of what's happening
with the RxD pin. It does not provide any information on the modem status
lines! We'll program that later on.

  If we wanted to show what's happening with the RxD pin, we'd just have to
write a routine like the following (I use a macro in the assembler version
to shorten the source code):

DOS_print macro pointer
  ; prints a string in the code segment
  push ax
  push ds
  push cs
  pop  ds
  mov  dx,pointer
  mov  ah,9
  int  21h
  pop  ds
  pop  ax
  endm

UART_watch_rxd proc near
uwr_loop:
  ; check if keyboard hit; we want a possibility to break the loop
  mov  ah,1
  int  16h
  jnz  uwr_exit
  call UART_get_char
  or   ax,ax
  jz   uwr_loop
  test ah,1  ; is there a character in AL?
  jz   uwr_nodata
  push ax    ; yes, print it
  mov  dl,al
  mov  ah,2
  int  21h
  pop  ax
uwr_nodata:
  test ah,0eh ; any error at all?
  jz   uwr_loop  ; this speeds up things
  test ah,2  ; overrun error?
  jz   uwr_noover
  DOS_print overrun_text
uwr_noover:
  test ah,4  ; parity error?
  jz   uwr_nopar
  DOS_print parity_text
uwr_nopar:
  test ah,8  ; framing error?
  jz   uwr_loop
  DOS_print framing_text
  jmp  uwr_loop
overrun_text    db "*** Overrun Error ***$"
parity_text     db "*** Parity Error ***$"
framing_text    db "*** Framing Error ***$"
UART_watch_rxd endp

void UART_watch_rxd()
{
   union _useful_
      {
      unsigned val;
      char character;
      } x;
   while (!kbhit())
      {
      x.val=UART_get_char();
      if (!x.val) continue;  // nothing? Continue
      if (x.val&0x100) putc(x.character);  // character? Print it
      if (!(x.val&0x0e00)) continue;  // any error condidion? No, continue
      if (x.val&0x200) printf("*** Overrun Error ***");
      if (x.val&0x400) printf("*** Parity Error ***");
      if (x.val&0x800) printf("*** Framing Error ***");
      }
}

  If you call these routines from a function/procedure as shown below,
you've got a small terminal program!

terminal proc near
ter_loop:
  call UART_watch_rxd  ; watch line until a key is pressed
  xor  ax,ax  ; get that key from the buffer
  int  16h
  cmp  al,27  ; is it ESC?
  jz   ter_end  ; yes, then end this function
  call UART_send  ; send the character typed if it's not ESC
  jmp  ter_loop  ; don't forget to check if data comes in
ter_end:
  ret
terminal endp

void terminal()
{
   int key;
   while (1)
      {
      UART_watch_rxd();
      key=getche();
      if (key==27) break;
      UART_send((char)key);
      }
}

  These, of course, should be called from an embedding routine like the
following (the assembler routines concatenated will assemble as an .EXE
file. Put the lines 'code segment' and 'assume cs:code,ss:stack' to the
front).

main proc near
  call UART_init
  call terminal
  mov  ax,4c00h
  int  21h
main endp
code ends
stack segment stack 'stack'
  dw 128 dup (?)
stack ends
end main

void main()
{
   UART_init();
   terminal();
}

  Here we are. Now you've got everything you need to program null-modem
polling UART software.
  You know the way. Now go and add functions to check if a data set is
there, then establish a connection. Don't know how? Set DTR, wait for DSR.
If you want to send, set RTS and wait for CTS before you actually transmit
data. You don't need to store old values of the MCR: this register is
readable. Just read in the data, AND/OR the bit required and write the
byte back.


  Now for the interrupt-driven version of the program. This is going to be
a bit voluminous, so I draw the scene and leave the painting to you. If you
want to implement interrupt-driven routines in a C program use either the
inline-assembler feature or link the objects together.

  First thing to do is initialize the UART the same way as shown above.
But there is some more work to be done before you enable the UART
interrupt: FIRST SET THE INTERRUPT VECTOR CORRECTLY! Use Function 0x25 of
the DOS interrupt 0x21. See also the note on known bugs if you've got a
8250.

UART_INT      EQU 0Ch  ; for COM2 / COM4 use 0bh
UART_ONMASK   EQU 11101111b  ; for COM2 / COM4 use 11110111b
UART_OFFMASK  EQU 00010000b  ; for COM2 / COM4 use 00001000b
UART_IERVAL   EQU ?   ; replace ? by any value between 0h and 0fh
                      ; (dependent on which ints you want)
                      ; DON'T SET bit 1 yet!

initialize_UART_interrupt proc near
  push ds
  push cs  ; build a pointer in DS:DX
  pop  ds
  lea  dx,interrupt_service_routine
  mov  ax,2500h+UART_INT
  int  21h
  pop  ds
  mov  dx,UART_BASEADDR+4  ; MCR
  in   al,dx
  or   al,8  ; set OUT2 bit to enable interrupts
  out  dx,al
  mov  dx,UART_BASEADDR+1  ; IER
  mov  al,UART_IERVAL
  out  dx,al
  in   al,21h  ; last thing to do is unmask the int in the ICU
  and  al,UART_ONMASK
  out  21h,al
  sti  ; and free interrupts if they have been disabled
  ret
initialize_UART_interrupt endp

  Now the interrupt service routine. It has to follow several rules:
first, it MUST NOT change the contents of any register of the CPU! Then it
has to tell the ICU (did I tell you that this is the interrupt control
unit?) that the interrupt is being serviced. Next thing is test which part
of the UART needs service. Let's have a look at the following procedure:

interupt_service_routine proc far  ; define as near if you want to link .COM
  ;*1*
  push ax
  push cx
  push dx
  push bx
  push sp
  push bp
  push si
  push di
  ;*2*   replace the part between *1* and *2* by pusha on an 80186+ system
  push ds
  push es
  mov  al,20h    ; remember: first thing to do in interrupt routines is tell
  out  20h,al    ; the ICU about it. This avoids lock-up
int_loop:
  mov  dx,UART_BASEADDR+2  ; IIR
  xor  ax,ax  ; clear AH; this is the fastest and shortest possibility
  in   al,dx  ; check IIR info
  test al,1
  jnz  int_end
  and  al,6  ; we're interested in bit 1 & 2 (see data sheet info)
  mov  si,ax ; this is already an index! Well-devised, huh?
  call word ptr cs:int_servicetab[si]  ; ensure a near call is used...
  jmp  int_loop
int_end:
  pop  es
  pop  ds
  ;*3*
  pop  di
  pop  si
  pop  bp
  pop  sp
  pop  bx
  pop  dx
  pop  cx
  pop  ax
  ;*4*   *3* - *4* can be replaced by popa on an 80186+ based system
  iret
interupt_service_routine endp

  This is the part of the service routine that does the decisions. Now we
need four different service routines to cover all four interrupt source
possibilities (EVEN IF WE DIDN'T ENABLE THEM!! Since 'unexpected'
interrupts can have higher priority than 'expected' ones, they can appear
if an expected [not masked] interrupt situation shows up).

int_servicetab    DW int_modem, int_tx, int_rx, int_status

int_modem proc near
  mov  dx,UART_BASE+6  ; MSR
  in   al,dx
  ; do with the info what you like; probably just ignore it...
  ; but YOU MUST READ THE MSR or you'll lock up the system!
  ret
int_modem endp

int_tx proc near
  ; get next byte of data from a buffer or something
  ; (remember to set the segment registers correctly!)
  ; and write it to the THR (offset 0)
  ; if no more data is to be sent, disable the THRE interrupt
  ; If the FIFO is used, you can write data as long as bit 5
  ; of the LSR is 0

  ; end of data to be sent?
  ; no, jump to end_int_tx
  mov  dx,UART_BASEADDR+1
  in   al,dx
  and  al,00001101b
  out  dx,al
end_int_tx:
  ret
int_tx endp

int_rx proc near
  mov  dx,UART_BASEADDR
  in   al,dx
  ; do with the character what you like (best write it to a
  ; FIFO buffer)
  ; the following lines speed up FIFO mode operation
  mov  dx,UART_BASEADDR+5
  in   al,dx
  test al,1
  jnz  int_rx
  ret
int_rx endp

int_status proc near
  mov  dx,UART_BASEADDR+5
  in   al,dx
  ; do what you like. It's just important to read the LSR
  ret
int_status endp

  How is data sent now? Write it to a FIFO buffer that is read by the
interrupt routine. Then set bit 1 of the IER and check if this has already
started transmission. If not, you'll have to start it by yourself... THIS
IS DUE TO THOSE NUTTY GUYS AT BIG BLUE WHO DECIDED TO USE EDGE TRIGGERED
INTERRUPTS INSTEAD OF PROVIDING ONE SINGLE FLIP FLOP FOR THE 8253/8254!
  This procedure can be a C function, too. It is not time-critical at all.

  ; copy data to buffer
  mov  dx,UART_BASEADDR+1  ; IER
  in   al,dx
  or   al,2  ; set bit 1
  out  dx,al
  mov  dx,UART_BASEADDR+5  ; LSR
  in   al,dx
  test al,40h  ; is there a transmission running?
  jz   dont_crank  ; yes, so don't mess it up
  call int_tx  ; no, crank it up
dont_crank:

  Well, that's it! Your main program has to take care about the buffers,
nothing else!

  One more thing: always remember that at 115,200 baud there is service to
be done at least every 8 microseconds! On an XT with 4.77 MHz this is
about 5 assembler commands!! So forget about servicing the serial port at
this rate in an interrupt-driven manner on such computers. An AT with 12
MHz probably will manage it if you use 'macro commands' such as pusha and/or
a 16550A in FIFO mode. An AT can perform about 20 instructions between two
characters, a 386 with 25 MHz will do about 55, and a 486 with 33 MHz will
manage about 150. Using a 16550A is strongly recommended at high rates.
  The interrupt service routines can be accelerated by not pushing that
much registers, and pusha and popa are fast instructions.

  Another last thing: due to the poor construction of the PC interrupt
system, one interrupt line can only be driven by one device. This means if
you want to use COM3 and your mouse is connected to COM1, you can't use
interrupt features without disabling the mouse (write 0x0 to the mouse's
MCR).
