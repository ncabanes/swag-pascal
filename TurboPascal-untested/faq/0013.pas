From: JACK MOFFITT                 Refer#: NONE
  To: ALL                           Recvd: NO
Subj: MODEM REFERENCE       1/       Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
            Pascal Programmer's Reference to Modem Communications

                                   by

                               Jack Moffitt

___-------------------------------------------------------------------------


INTRODUCTION
~~~~~~~~~~~~
        Direct UART programming is a subject that not many people are
familiar with.  Since the advent of FOSSIL, many people advise that one
should use that for all communications, to make it more portable.  But for
some instances, it is necessary to have internal modem routines to go on.
Because no one seems to know or understand this subject, and because I have
found no other texts on the subject, I have decided to put it all into one
text, and maybe round off the edges on this subject.


THE ASYNCRONOUS MODEM
~~~~~~~~~~~~~~~~~~~~~
        The asyncronous modem uses one (or more) specific ports on a
computer, as well as an IRQ (Interrupt Request).  Every time a character
of data is received in the device, an interrupt is processed.  One must
make a interrupt service routine to handle this input, but where does it go?
Since the IRQs are tied into interrupts, knowing the IRQ the device is using,
we can replace that interrupt.  The port addresses and IRQ vectors are as
follows:

Port Addresses: COM1  --  03F8h        IRQ Vectors   :  0  --  08h
                COM2  --  02F8h                         1  --  09h
                COM3  --  03E8h                         2  --  0Ah
                COM4  --  02E8h                         3  --  0Bh
                                                        4  --  0Ch
                                                        5  --  0Dh
Standard Port IRQs: COM1  --  4                         6  --  0Eh
                    COM2  --  3                         7  --  0Fh
                    COM3  --  4                         8  --  70h
                    COM4  --  3                         9  --  71h
                                                       10  --  72h
                                                       11  --  73h
                                                       12  --  74h
                                                       13  --  75h
                                                       14  --  76h
                                                       15  --  77h

For standard use, the IRQ for comm ports 1 and 3 is 4, and for 2 and 4 it's
3.  The 8250 UART has 10 registers available for getting, receiving and
interperating data.  They are all located at offsets from the base address
of the port.  Here are the registers and their offsets:

Register Offsets:  Transmitter Holding Register (THR)       --  00h
                   Receiver Data Register (RDR)             --  00h
                   Baud Rate Divisor Low Byte (BRDL)        --  00h
                   Baud Rate Divisor High Byte (BRDH)       --  01h
                   Interrupt Enable Register (IER)          --  01h
                   Interrupt Identification Register (IIR)  --  02h
                   Line Control Register (LCR)              --  03h
                   Modem Control Register (MCR)             --  04h
                   Line Status Register (LSR)               --  05h
                   Modem Status Register (MSR)              --  06h

With this information one can address any register by adding the offset to
the base address.  Therefor, if one is using COM2 (base address 02F8h) they
would access the Modem Status Register with: port[$02F8 + $06].


TRANSMITTER HOLDING REGISTER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        This register contains the data to be sent to the remote PC or modem.
When bit 5 (THR empty) of the LSR is set, one can write to this port, thus
sending data over the phone line or null modem cable.


RECEIVER DATA REGISTER
~~~~~~~~~~~~~~~~~~~~~~
        This register contains the incoming data.  Read this register only
if bit 0 (Data Received) of the LSR is set, otherwise one will get
unpredictable characters.


BAUD RATE DIVISOR
~~~~~~~~~~~~~~~~~
        The Baud Rate Divisor is used to set the BPS rate.  To calculate the
Baud Rate Divisor, one must use the formula: (UART Clock Speed)/(16*BPS).
The UART Clock Speed is 1843200.  To set the BRD one must first set bit 7
(port toggle) of the Line Control Register to 1, and then write the low and
high bytes to the correct offsets.  Always remember to reset LCR bit 7 to 0
after one is finished setting the BPS rate.


INTERRUPT ENABLE REGISTER
~~~~~~~~~~~~~~~~~~~~~~~~~
        The IER is used to simulate real interrupt calls.  Write a byte
containing to interrupt information to enable any interrupts, all interrupts
also have corresponding actions to clear the interrupts.  Here's the list:

Info Byte:

bit   7-6-5-4       3                 2                 1           0
      ~~~~~~~       ~                 ~                 ~           ~
     Always 0   MSR Change   Data Error or Break    THR empty  Data Received

To Clear:       Read MSR          Read LSR        Output to THR   Read RDR


INTERRUPT IDENTIFICATION REGISTER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        This register is used to determine what kind of interrupts have
occured.  Read one byte from this register, and use AND masks to find out
what has happened.  The information in the byte is:

Info Byte:

bit   7-6-5-4-3    2-1                                    0
      ~~~~~~~~~    ~~~                                    ~
       Unused      0-0 = Change in MSR                If this bit is set
                   0-1 = THR empty                    more than one
                   1-0 = Data Received                interrupt has
                   1-1 = Data Error or Break          occured.


LINE CONTROL REGISTER
~~~~~~~~~~~~~~~~~~~~~
        The Line Control Register (LCR) is used for changing the settings
on the serial line.  It is also used for initializing the modem settings.
Write a byte to the port, containing the following info:

LCR Byte.

      Port Toggle   Break Condition   Parity      Stop Bits   Data Bits
bit       7                6           5-4-3          2          1-0
          ~                ~           ~~~~~          ~          ~~~
          0 = Normal       0 = Off     0-0-0 = None   0 = 1      0-0 = 5
          1 = Set BRD      1 = On      1-0-0 = Odd    1 = 2      0-1 = 6
                                       1-1-0 = Even              1-0 = 7
                                       1-0-1 = Mark              1-1 = 8
                                       1-1-1 = Space
Everything is pretty clear except for the purpose of bits 6 and 7.  Bit 6
controls the sending of the break signal.  Bit 7 should always be 0, except
if one is changing the baud rate.  Then one must set it to one, write to
the BRD and then set it back to zero.  One can only write to the BRD if this
bit is set.


MODEM CONTROL REGISTER
~~~~~~~~~~~~~~~~~~~~~~
        The MCR is used to control the modem and it's function.  Write one
byte to the MCR containing the following info:

MCR Byte.

bit      0 = Set DTR Line
         1 = Set RTS Line
         2 = User Output #1
         3 = User Output #2
         4 = UART Loopback
     7-6-5 = Unused (Set to 0)

Typically one will set bits 3 through 0 to 1.  Bit 4 is used for testing
their routines without another modem, and the other bits are unused, but
should always be set to 0.


LINE STATUS REGISTER
~~~~~~~~~~~~~~~~~~~~
        The LSR reports the current status of the RS232 serial line.  The
information contained is obtained by reading one byte from the LSR.  The
bits and the info associated with each are listed below.

LSR Byte.

bit     0 = Data Received
        1 = Overrun Error
        2 = Parity Error
        3 = Framing Error
        4 = Break Detect
        5 = THR empty
        6 = Transmit Shift Register (TSR) empty
        7 = Time Out

The TSR takes the byte in the THR and transmits is one bit at a time.  When
bit 0 is set one should read from the RDR, and when bit 5 is set one should
write to the THR.  What actions are taken on various errors are left up to
the programmer.


MODEM STATUS REGISTER
~~~~~~~~~~~~~~~~~~~~~
        Just like the LSR returns the status of the RS232 line, the MSR
returns the status of the modem.  As with other registers, each bit in the
byte one reads from this port contains a certain piece of info.

MSR byte.

bit     0 = Change in CTS
        1 = Change in DSR
        2 = Change in RI
        3 = Change in DCD
        4 = CTS on
        5 = DSR on
        6 = RI on
        7 = DCD on

Carrier Detect is achieved by testing bit 7, to see if the line is ringing
test bit 6.



PUTTING IT ALL TOGETHER
~~~~~~~~~~~~~~~~~~~~~~~
        One can now use this information about the 8250 UART to start
programming their own modem routines.  But before they can do that, they
must learn a little about interrupts and the 8259 PIC (Programmable
Interrupt Controller).  This information is necessary to write modem
routines that are not dependant on a slow BIOS.


INTERRUPTS
~~~~~~~~~~
        Interrupts are a broad subject, and this is not a reference for them.
For for information on interrupts, one should look at DOS Programmer's
Reference 4th Edition.  Although there are two kinds of interrupts - Non-
Maskable and Maskable, maskable interrupts are the only ones that one should
be concerned with.  When an interrupt generates, the processor finishes the
current command, and then saves a few variables (the address to return to)
on the stack and jumps to the vector of the interrupt.  One can turn off
maskable interrupts with the STI, and back on with CLI.  One can not turn
off non-maskable interrupts.  Replacing interrupt routines in pascal is very
easy.  Include the DOS unit in their program, and use the procedures GetIntVec
and SetIntVec.  To replace the interrupt for COM2 (remember it's 0Bh) one
would do this:
               GetIntVec($0B, OldInt0Bh);
               SetIntVec($0B, NewInt0Bh);
At the end of the program, one MUST restore the interrupt using:
               SetIntVec($0B, OldInt0Bh);
Failing to do this will most likely result in a system crash after the
program terminates.  Because another interrupt may be called inside another
interrupt at any time, it is necessary to turn off interrupts, as mentioned
above, every once in a while.  Remember all this, and programming for the
modem will be much easier ( :) ).


8259 PROGRAMMABLE INTERRUPT CONTROLLER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        The 8259 PIC is used by the processor as a gateway for interrupts.
The 8259 decides which interrupts go first and which are currently active.
The order interrupts are processed in in the order of their IRQ number.
Thus, IRQ0 will always be processed before IRQ1 if both are generated at the
same time.  Since asyncronous communication uses IRQs, we must instruct the
8259 PIC on when are interrupts should start interrupting, and when they
should stop.  When initializing the modem, one must "turn on" the IRQ before
one can start to use it.  Turning back off is identical, but don't turn it
off if one is writing door routines!  To do either requires one assign the
value contained at the port the value AND the mask.  The masks for turning
on and off the 8259 follows.

To Turn On:
            mask = (1 shl (IRQ number)) xor $00FF
To Turn Off:
             mask = 1 shl (IRQ number)

One must also reset the PIC in the custom interrupt handler after one is
finished with it.  That will allow the PIC to process the next interrupt.
To reset the PIC, write 20h to it.  This is also refered to as the End Of
Interrupt (EOI) signal.  This must also be done after first initializing the
modem.  There is another PIC on the 286, allowing the last 8 IRQs (7 - 15).
The second PIC is called the cascade PIC.  The addresses for the PIC command
and mask ports are listed next.

8259 PIC command address         = 20h
8259 PIC mask address            = 21h
Cascade 8259 PIC command address = A0h
Cascade 8259 PIC mask address    = A1h

To reset the PIC always write to the command, and for turning off with the
masks always write to the mask.  The masks for the cascade PIC are the same
for the other PIC.  So the mask for IRQ0 is equal to the mask for IRQ7.
Also, one should write 20h to the cascade PIC as the EOI signal.


INPUT/OUTPUT CONTROL
~~~~~~~~~~~~~~~~~~~~
        To keep the text simple, only buffered input will be covered.
Buffered output is a subject of more depth than one can provide in a short
reference.  Buffered input is relatively simple, but there are a few things
one must consider.  The size of the buffer is very import, make the buffer
to big and one will eat up the datasegment, make the buffer to small and
one will get overruns.  A good choice for a general buffer would be in the
range of 4 to 8k.  This should allow plenty of room for all incoming data.
Another inportant factor is the type of buffer.  For simplicity and ease of
use, a circular input buffer is recommended.  A head and a tail point
to the start and end of the buffer, and they will both wrap around when
either go past the end of the buffer, thus making the buffer a kind of
circle.  Getting data in the buffer is the primary job of the custom
interrupt routine.  Clearing the buffer and reading characters from the
buffer is then as easy as reading a character from an array, and advancing
the head of the buffer.  Sending characters over the phone can be
accomplished by waiting for the flow control and then sending the character
to the THR, repeating for every character.

THE INTERRUPT SERVICE ROUTINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        The ISR (Interrupt Service Routine) is the backbone for asyncronous
communication.  The interrupt is called for every character that comes
through the modem.  So in the interrupt one must process these incoming
characters or else they will be lost.  Since the the interrupt got called,
one must check the IIR (Interrupt Identification Register) to see what
actually cause the interrupt to be called.  Since the interrupt is mainly
dealing with handling the incoming data, and for reasons of simplicity,
flow control will be ommited from the routine but will be discussed later
in this text.  Since one is writing to the buffer, and since another
character is likely to come in during this time, one must disable interrupts
for the shortest time possible while writing to the buffer, and then reenable
them so no data is lost.  (NOTE: If the ISR is to be contained in a unit, it
must be declared in the unit's interface section as an INTERRUPT procedure.)
After disabling interrupts, checking for data, discarding data if no buffer
space is available, putting the data in the buffer if there is room, and
clearing the RDR if any data error or break occured, one must turn on the
interrupts and issue the EOI signal to the 8259 PIC or both the 8259 PIC
and the cascade PIC if IRQ7 - IRQ15 is used.  Here is a sample routine:


const
  BaseAddr: array[1 .. 4] of word = ($03F8, $02F8, $03E8, $02E8);
  { Nice array to make finding the base address easy }

var
  Buffer: array[1 .. 4096] of char;  { A 4k buffer for input }
  Temp,  { Varible to hold various modem statuses }
  CommPort: byte;  { Comm Port in use }
  Head,  { Start of the buffer }
  Tail,  { End of the buffer }
  Size: word;  { Size of the buffer }
  Cascade: boolean;  { For IRQ7 - IRQ15 }

procedure Async_ISR; interrupt; { NOTE: must declare the procedure interrupt }
begin
  inline($FB); { STI - Disable interrupts }
  Temp := port[BaseAddr[CommPort] + $02];  { Read a byte from the IIR }
  if Temp and $06 = $04 then  { Character received }
  begin
    if Head <> Tail then  { Make sure there is room in the buffer }
    begin
      Buffer[Tail] := Chr(port[BaseAddr[CommPort] + $00]);  { Read char }
      inc(Tail);  { Position the Tail for the next char }
      if Tail > 4096 then Tail := 0;  { If Tail is greater, wrap the buffer }
    end
    else temp := port[BaseAddr[CommPort] + $00];  { Throw away overruns }
  end
  else if Temp and $06 = $06 then  { Data error or break }
    Temp := port[BaseAddr[CommPort] + $00];  { Clear RDR }
  inline($FA);  { CLI - Enable interrupts }
  port[$20] := $20;  { Reset the 8259 PIC }
  if Cascade then port[$A0] := $20;  { Reset the cascade PIC }
end;


First the procedure disables interrupts, then it reads the IIR to find out
what kind of interrupt needs processing.  The procedure then masks out bits
2 and 1 and tests it to see if bit 4 is set.  If data is received it checks
to make sure there is room in the buffer, and places the character at the
position marked by Tail, otherwise it disregards the character as overrun.
If a data error occured it clears the RDR to make sure no garbage is
received.  Finally it enables interrupts and resets the 8259 (and the cascade
if necessary).


SENDING CHARACTERS
~~~~~~~~~~~~~~~~~~
        Sending character over the modem is much simpler than getting them.
First one must wait for the flow control and for the UART and then write the
character to the THR.  Here's an example:

procedure XmitChar(C: char);  { Uses variable and constant declarations from
begin                           the previous example }
  while ((port[BaseAddr[CommPort] + $05] and $20 <> $20) and  { Wait for THR }
         (port[BaseAddr[CommPort] + $06] and $10 <> $10))  { Wait for CTS }
  do ;  { Do nothing until CTS and THR empty }
  port[BaseAddr[CommPort] + $00] := Ord(C);  { Send character }
end;

This waits for the CTS signal and for the THR to be clear and then sends the
character.  To send strings just use this in a repeat loop such as:

for x := 1 to length(s) do
  XmitChar(s[x]);


READING CHARACTERS
~~~~~~~~~~~~~~~~~~
        The actual reading of character takes place in the ISR, but one still
has to get them from the buffer.  Just read the character at the head of
the buffer and pass it back.  An example:

function RemoteReadKey: char;  { Uses var and const from above }
begin
  RemoteReadKey := Buffer[Head];  { Get the character }
  inc(Head);  { Move Head to the next character }
  if Head > 4096 then Head := 0;  { Wrap Head around if necessary }
  dec(Size);  { Remove the character }
end;

To find out if a character is waiting is even easier:

function RemoteKeyPressed: boolean;  { Uses vars and consts from above }
begin
  RemoteKeyPressed := Size > 0;  { A key was pressed if there is data in
end;                               the buffer }


INITIALIZING MODEM PARAMETERS AND OTHER TOPICS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        For most cases one can use interrupt 14h function 00h to initialize
modem parameters, but if the baud rate is over 9600, this function will
not work.  One must change the BRD themselves.  It is a simple matter of
accessing the BRD by setting the LCR bit 7 to 1 and writing to the BRD and
then reseting the LCR bit 7 back to 0.  Everything else, clearing buffers,
flushing buffers, formatting input, is all up to the programmer.  I have
provided one with enough information to grasp the basis of modem programming
and the I/O involved.

FLOW CONTROL
~~~~~~~~~~~~
        Flow control is mainly used to prevent overflow error on today's
high speed modems.  CTS/RTS was already covered earlier, but nothing has
been said for XOn/XOff.  XOn/XOff will send a certain character (usually
a ^S) when the input buffer has reached a certain percentage of capacity.
This signal is XOff.  When the buffer has gone down to another percentage of
capacity, XOn (usually a ^Q) will be sent.  It is the programmer's job to
look for XOn/XOff codes and interperate them, as there are no standard ways
to do it as with CTS/RTS.  It is also his job to make sure he or she sends
the signals at the appropriate time.


CONCLUSION
~~~~~~~~~~
        This text is general, and won't satisfy the needs of advanced modem
programmers.  It was written to help those just starting, or thinking about
starting, through the ordeal of finding a book, or read through source not
knowing what some of it does.  If one finds any mistakes, please feel free
to contact me via the Pascal FIDONet echo, and he will gladly correct
them.  Also, if one would like more information on other related topics,
contact me via the Pascal echo, and I will try to help.

_____________________________________________________----


I hope everyone will find this text useful, and please feel free to
comment or correct anything.  I posted it once but it got choped off in
places, so i'm posting it again.  Enjoy.

        Jack

