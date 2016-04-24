(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0068.PAS
  Description: OOP Async Package
  Author: PATRICK HUNLOCK
  Date: 11-26-94  05:05
*)

{$O-} {This unit may >>>>NOT<<<< be overlaid}
{$X+} {Extended syntax is ok}
{$F+} {Allow far calls}
{$A+} {Word Align Data}
{$G+} {286 Code optimization - if you're using an 8088 get a real computer}
{$R-} {Disable range checking}
{$S+} {Enable Stack Checking}
{$I-} {Disable IO Checking}
{$Q-} {Disable Overflow Checking}
{$D-} {Turn off debugging - use only if you modify this unit and get a bug}
{$L-} {Turn off local symbols - again this unit has been thouroughly debuged}
{$V-} {Turn off strict VAR strings}
{$B-} {Allow short circuit boolean evaluations}
{$T-} {Turn off typed @ operators}

Unit Async;

{This unit was written by Patrick Hunlock, 10/19/1994     }
{Copyright @ 1994 by Patrick Hunlock - all rights reserved}

{Software License Agreement: If you use this unit you are bound by it's terms}

{You may use this unit in your programs without royalties. If you use this
 unit my name and the copyright notice must appear beneath your name and
 copyright notice even if you have made significant alterations to the
 source code in this unit.  This source code may only be transmitted via
 the telephone system.  It may not be distributed on any magnetic, optical,
 or any future computer media format without prior consent of the copyright
 holder.  No charge may ever be levied for the receipt of this source code
 other than normal phone charges and/or normal connect charges on a BBS which
 charges for access.  Any charges above and beyond what would be considered
 normal access charges to download this source is considered a SALE of this
 source code which is expressly prohibited by this License Agreement.
 You may distribute this source code via the telephone system (I.E.
 BBS or computer network) in it's original form only, you may not add or
 subtract to/from it in any way shape or form.}

{This ASYNC unit implements a >COMPLETE< multi-port serial interface wrapped
 in a turbo pascal object.  Baud rates up to 110,000 are supported.  Up to
 four ports may be opened at a time, up to two ports may be active at any
 given time (four can be active so long as they do not share interrupts).
 Some considerations.  A com port which shares the same interrupt as a
 serial mouse will over-ride the mouse driver for the duration of the
 program.  If you have a mouse on Com1, avoid using Com3 in your program.
 Likewise if you have a mouse on Com2, avoid using Com4 in your program.
 A mouse on a BUS card will not be affected by this unit.  Default addresses
 for the 4 com ports dictate that com1 & com3, and com2 & com4 share an
 interrupt on the system bus.  As such while you can open both ports, make
 sure that only - ONE of the ports on the shared interrupt has been .ENABLED
 at any one time.  See the .ENABLE and .DISABLE procedures for more
 information.}

Interface

Type

   Com_Port      = Object
                         CPort   : Byte;          {Com Port for this port}

                      {Initializes the buffers and the object}
                      Function Init(ComPort: Byte; RBufSize,TBufSize: Word): Byte;
                      {Sets the baud,parity,wordsize, and stopbits}
                      Procedure SetParam(Baud: Longint; WordSize: Byte;
                                         Parity: Char; StopBits: Byte);
                      {Used for shared interrupts}
                      Procedure Disable;
                      {Enable a com port for use}
                      Procedure Enable;
                      {Returns true if there is data waiting}
                      Function Waiting: Boolean;
                      {Returns a character waiting in the buffer}
                      Function Read: Char;
                      {Waits for a character if necessary}
                      Function Readw: Char;
                      {Writes a character to the transmit buffer}
                      Procedure Write(C: CHar);
                      {Passes a string to the transmit buffer}
                      Procedure WriteS(S: String);
                      {Returns true if modem is "on-line" re DCD status}
                      Function OnLine: Boolean;
                      {Disconnects the modem connection}
                      Procedure Hangup;
                      {Sends a Break Signal to the other computer}
                      Procedure Break;
                      {Terminates the comm port}
                      Procedure Done;
                   End;

Implementation

Uses DOS,       {Turbo Pascal's DOS Unit}
     CRT;       {Turbo Pascal's CRT Unit}

Const
                                     {Com1,Com2,Com3,Com4}
   PortBases : Array[1..4] Of Word = ($3F8,$2F8,$3E8,$2E8);
   Interrupts: Array[1..4] Of Byte = (   4,   3,   4,   3);

   Disable_Interrupts = $FA;       {Used in INLINE statements}
   Enable_Interrupts  = $FB;       {Used in INLINE statements}

Type
   {Buf Type is never actually >declared< in this unit.  It is created only
    as a pointer to an area of memory which can actually only be 10 to 64000
    bytes long.  However by creating the pointer in this way, the contents
    of the pointer memory can be accessed like an array of chars simplifying
    the coding of this unit.  If you only create a 10000 byte buffer then
    it's valid to read BUFTYPE[0] through BufTYPE[10000] anything higher
    is dangerous since no memory was set aside for this buffer.  However
    the unit knows how much memory was set asside and it never references
    any data outside of the "safe" range}
   BufType = Array[0..64000] Of Char;

   {ComBufferType is the actual buffer used by the COM_ISR routine and the
    record which actually makes COM_PORT work.  In reality COM_PORT is just
    a shell which is wrapped around this record to give the illusion of
    OOP.  Take away COM_PORT, write your own procedures to reference
    ComBufferType and your program will work just fine}

   ComBufferType = Record
                      Active       : Boolean;  {True if this buffer is active}
                      R_Buffer     : ^BufType; {Recieve buffer pointer       }
                      R_Head,R_Tail: Word;     {Buffer Head and Buffer Tail  }
                      R_Size       : Word;     {Size of the recieve buffer   }
                      T_Buffer     : ^BufTYpe; {Transmit Buffer Pointer      }
                      T_Head,T_Tail: Word;     {Transmit Buffer Head & Tail  }
                      T_Size       : Word;     {Size of the transmit buffer  }
                      UART_Data    : Word;     {Uart data address            }
                      UART_IER     : Word;     {Uart interrupt enable registr}
                      UART_IIR     : Word;     {Uart interrupt identification}
                      UART_LCR     : Word;     {UArt Line Control Register   }
                      UART_MCR     : Word;     {UArt Modem COntrol Register  }
                      UART_LSR     : Word;     {UArt Line Status Register    }
                      UART_MSR     : Word;     {UArt Modem Status Register   }
                      OLD_MCR      : Byte;     {Old Modem control register   }
                      Org_Vector   : Pointer;  {Original interrupt vector    }
                   End;

Var
   Bufs: Array[1..4] Of ComBufferType; {This declares 4 com buffers for  }
                                       {coms 1 - 4                       }

Procedure COM_ISR; Interrupt;

{COM_ISR is the main interrupt procedure which handles all the serial IO.
 This procedure is called >AUTOMATICALLY< by DOS whenever data arrives at
 the com port - or when it is clear to send data.  >SEVERE< restrictions
 as to what you can and can not add to this procedure apply.  You can not
 use WRITELN.  You can not reference any turbo pascal objects.  This unit
 may not be overlaid.  Etc, Etc, Etc}

Const Ktr: Byte = 0;  {These are STATIC variables so pascal doesn't }
      IIR: Byte = 0;  {constantly have to redeclare them on the heap}

Begin
   For Ktr:= 1 to 4 Do begin
      With Bufs[Ktr] Do Begin
         If Active Then Begin
            iir:= Port[UART_IIR];
            While Not Odd(IIR) Do Begin
               Case (iir SHR 1) Of
                  0: iir:= Port[UART_MSR]; {Modem status change}
                  1: If T_Head = T_Tail Then Begin    {Ok to transmit      }
                        {Transmit buffer empty - disable transmit interrupt}
                        Port[UART_IER]:= Port[UART_IER] And Not 2;
                     End Else Begin
                        Port[UART_DATA]:= Byte(T_Buffer^[T_Head]);
                        Inc(T_Head);
                        If T_Head > T_Size Then T_Head:= 0;
                     End;
                  2: Begin                  {Recieve buffer}
                        R_Buffer^[R_Tail]:= Char(Port[Uart_Data]);
                        Inc(R_Tail);
                        If R_Tail > R_Size Then R_Tail:= 0;
                        If (R_Tail = R_Head) Then Begin
                           Inc(R_Head); {Overflow}
                           If R_Head > R_Size Then R_Head:= 0;
                        End;
                     End;
                  3: iir:= Port[UART_LSR]; {Line status change}
               End;
               iir:= Port[UART_IIR];
            End;
         End;
      End;
   End;
   Port[$20]:= $20;  {We're done processing the interrupt}
End;

Function Com_Port.Init(ComPort: Byte; RBufSize,TBufSize: Word): Byte;

{Init is the standard object initialization routine. You must pass the
 comport (1-4) you want the object to be associated with and the buffer
 size (10-64000 bytes) you want the buffer to be.  Init returns the following
 codes based upon it's success or failure......

    0 - Com Port Initialized
    1 - ComPort is out of range - not 1, 2, 3, or 4.
    2 - ComPort is already active and in use.
    3 - Buffer size is either to small (10 bytes or more) or to large
        (greater than 64000) - Recieve Buffer
    4 - Transmit buffer size out of range (See #3)

 Init only sets up the buffers and prepares the interrupt vector.  You must
 follow this with a call to setparams (set baud rate, parity, etc), then
 a call to enable.  See enable and disable especially if you are going to
 use multiple comm ports simultaniously.
}

Var InUse: Boolean;     {Scratch variable to check for active interrupts}
    Ktr  : Byte;        {Counter Variable                               }

Begin
   {Set the initial state of the return code to OK}
   Init:= 0;
   {Check the comport validity}
   If (ComPort < 1) Or (ComPort > 4) Then Begin
      Init:= 1;
      Exit;
   End;
   {Check to see if the comport is already in use by another object}
   If Bufs[ComPort].Active Then Begin
      Init:= 2;
      Exit;
   End;
   {Check to make sure the buffer size is valid}
   If (RBufSize > 64000) Or (RBufSize < 10) Then Begin
      Init:= 3;
      Exit;
   End;
   If (TBufSize > 64000) Or (TBufSize < 10) Then Begin
      Init:= 4;
      Exit;
   End;

   {Begin main setup}

   CPort:= ComPort;                        {Store the comport for future use}
   Getmem(Bufs[ComPort].R_Buffer,RBufSize);{Allocate memory for the buffer  }
   Bufs[ComPort].R_Size:= RBufSize;        {Store the size of the buffer    }
   GetMem(Bufs[ComPort].T_Buffer,TBufSize);{Allocate transmit buffer memory }
   Bufs[ComPort].T_Size:= TBufSize;        {Store the size of the buffer    }

   {This next section sets up the PORT addresses used by the comport
    requested.  The base addresses are stored in PORTBASES, a constant
    declared at the top of the implenetation section of this unit.  Your
    program may need to change the address and/or interrupts found in
    that section for serial cards with unusual addresses and interrupts.
    Since PortBases and Interrupts are typed constant arrays you can
    easilly add an object method to change the address or interrupt for
    a given comm port}

    Bufs[ComPort].UART_DATA:= PortBases[ComPort]+0;
    Bufs[ComPort].UART_IER := PortBases[ComPort]+1;
    Bufs[ComPort].UART_IIR := PortBases[ComPort]+2;
    Bufs[ComPort].UART_LCR := PortBases[ComPort]+3;
    Bufs[ComPort].UART_MCR := PortBases[ComPort]+4;
    Bufs[ComPort].UART_LSR := PortBases[ComPort]+5;
    Bufs[ComPort].UART_MSR := PortBases[ComPort]+6;


   {This next section sees if there is already an interrupt vector set for
    a shared interrupt com port.  For instance COM1 and COM3 both use
    interrupt 4 and COM2 and COM4 use interrupt 3.  If we are setting up
    COM1, but COM3 is already up and running we don't need to do anything
    since the interrupt service routine (Procedure COM_ISR) will
    automatically check the com ports on it's interrupt}

   InUse:= False;
   For Ktr:= 1 to 4 Do
      If (Interrupts[Ktr] = Interrupts[ComPort]) And Bufs[Ktr].Active Then
         InUse:= True;

   {This next section is run if, and only if a shared interrupt is not
    currently running.}

   InLine(Disable_Interrupts);

   If Not InUse Then Begin
      {Get the old DOS interrupt vector, save it then change it to point
       to the COM_ISR procedure in this unit}
      Port[$21] := Port[$21] Or (1 SHL Interrupts[ComPort]);
      GetIntVec(8+Interrupts[ComPort],Bufs[ComPort].Org_Vector);
      SetIntVec(8+Interrupts[ComPort],@COM_ISR);
      Port [$21] := Port [$21] AND NOT (1 SHL Interrupts[ComPort]);
   End;

   Bufs[ComPort].Old_MCR:= Port[Bufs[ComPort].UART_MCR]; {Store MCR        }
   Port[Bufs[ComPort].UART_LCR]:= 3; {Parity to none and turn off the break}
   PORT[Bufs[ComPort].UART_IER]:= 1; {Enable data recieved interrupts      }

   InLine(Enable_Interrupts);

   Bufs[ComPort].Active:= True;      {Let COM_ISR know to check this port  }
End;

Procedure Com_Port.SetParam(Baud: Longint; WordSize: Byte;
                             Parity: Char; StopBits: Byte);

Const
      MaxBaud      = 115200;  {Maximum baud rate                            }

Var Divisor: Word;
    lcr    : Byte;

{Sets the baud rate, wordsize, parity, and stop bits used by the port.  The
 most common setting especially with high speed modems is 38400 baud, word
 size is 8 bits (one byte), 'N' or no parity, and one stop bit.  Compuserve
 uses 7 bits and even parity.}

Begin

   {This next section sets the baud rate based on the divisor of MAXBAUD}

   If Baud < 50 Then Baud:= 50;
   If Baud > MaxBaud Then Baud:= MaxBaud;
   Divisor:= MaxBaud Div Baud;
   InLine(Disable_Interrupts);
   Port [Bufs[CPort].uart_lcr ]:= Port[Bufs[Cport].uart_lcr] Or $80;
   Portw[Bufs[CPort].uart_Data]:= divisor;
   Port [Bufs[CPort].uart_lcr] := Port[Bufs[CPort].uart_lcr] And NOT $80;
   InLine(Enable_INterrupts);

   {This next section sets the parity}

   Case upcase(Parity) Of
      'N': lcr:= $00 or $03;
      'E': lcr:= $18 or $02;
      'O': lcr:= $08 Or $02;
      'S': lcr:= $38 Or $02;
      'M': lcr:= $28 OR $02;
      Else
         Lcr:= $00 or $03;
   End;
   If StopBits = 2 Then lcr:= Lcr OR $04;

   InLine(Disable_Interrupts);
   Port[Bufs[CPort].Uart_lcr]:= Port[Bufs[CPort].uart_lcr] And $40 Or LCR;
   InLine(Enable_Interrupts);
End;

Procedure Com_Port.Done;

{Use this procedure when you are done with your program.  You >MUST< run
 this procedure for each COM variable you have initialized.  If you don't
 if any data comes in to the comm port DOS will still try to go to the
 place where the COM_ISR >>>USED<<< to be!  Meaning your computer >COULD<
 crash.  Since this is an OOP approach exit-proc wasn't used since there
 could be any number of variables open and running.  Therefore it is YOUR
 responsibility to call this procedure for each COM_PORT object you have
 created}

Var InUse: Boolean;     {Scratch variable to test for shared interrupt}
    Ktr  : byte;        {Counter variable                             }

Begin
   {Check for shared interrupt usage}

   InUse:= False;
   For Ktr:= 1 to 4 Do
      If (Interrupts[Ktr] = Interrupts[CPort]) And Bufs[Ktr].Active Then
         InUse:= True;

   InLine(Disable_interrupts);

   {Restore the old Modem Control Register and disable incomming data
    interrupts}
   Port[Bufs[CPort].UART_MCR] := Bufs[CPort].Old_MCR;
   Port[Bufs[CPort].UART_IER] := 0;


   If Not InUse Then Begin
      {Remove the interrupt only if another object is not using it}
      Port[$21] := Port[$21] Or ($01 SHR Interrupts[CPort]);
      SetIntVec(8+Interrupts[CPort],Bufs[CPort].Org_Vector);
   End;

   InLine(Enable_Interrupts);

   CPort:= 0;                {Set CPort variable to 0     }

   {Release the buffer memory and set the active flag to false}
   Freemem(Bufs[CPort].R_Buffer,Bufs[CPort].R_Size);
   Freemem(Bufs[CPort].T_Buffer,Bufs[CPort].T_Size);
   Bufs[CPort].Active:= False;
End;

Function Com_Port.Read: Char;

{If a character is available on the buffer, this procedure will return the
 char.  If there is no character, char 0 (#0) will be returned.  If you
 expect #0 to be passed as part of the data call this routine only if
 function waiting returns true, or use readw - which will wait for
 a character from the com port if nothing is available}

Begin
   With Bufs[CPort] Do Begin
      If R_Head = R_Tail Then Begin  {Nothing in the buffer}
         Read:= #0;
      End Else Begin                 {Data waiting in the buffer}
         Read:= R_Buffer^[R_Head];          {Get the waiting character}
         Inc(R_Head);                       {Increment the queue pointer}
         If R_Head > R_Size Then R_Head:= 0; {Check for out of range}
      End;
   End;
End;

Function Com_Port.Readw: Char;

{Waits for a character from the comm port if none are available.  Passes
 back the first character it finds in the recieve buffer}

 Begin
    With Bufs[CPort] Do Begin
       While R_Head = R_Tail Do;
       Readw:= R_Buffer^[R_Head];
       Inc(R_Head);
       If R_Head > R_Size THen R_Head:= 0;
    End;
 End;

Function Com_Port.Waiting: Boolean;

{This function returns TRUE if there is data waiting in the recieve buffer}

Begin
   Waiting:= (Bufs[CPort].R_Head <> Bufs[CPort].R_Tail);
End;

Procedure Com_Port.Enable;

{This should be the third command you run after .INIT and .SETPARAM.  Enable
 and Disable are provided for multi-port use.  If you are using com1 and
 com2 together you can leave both ports enabled at the same time, likewise
 with com3 and com4.  However ports that share interrupts (Com1 & Com3)
 (com2 & com4) can not both be enabled at the same time.  This is the reason
 I wrote this unit because the most popular pascal com libraries
 (particularly the async libraries by rising sun which are otherwise
 extrodinarilly compitent packages) could not handle shared interrupts.
 This unit can, but it cheats by allowing you to "suspend" one of the ports
 on the shared interrupt.  While a port is suspended (disabled) you can not
 send or recieve data from that port.  Other considerations - a mouse on
 com1 will not work with this package when you use com3, likewise a mouse
 on com2 will not work when you run com4 this is because this package
 installs it's own interrupts - overwriting the mouse ports (although the
 mouse will begin working again once you call .DONE}

Begin
   InLine(Disable_interrupts);
   Port[Bufs[CPort].Uart_MCR]:= 11;
   InLine(Enable_Interrupts);
End;

Procedure Com_Port.Disable;

{Call this procedure only if you are about to enable another port which
 uses the same interrupt, see COM_PORT.Enable for more information}

Begin
   InLine(Disable_interrupts);
   Port[Bufs[CPort].Uart_MCR]:= 3;
   InLine(Enable_Interrupts);
End;

Procedure Com_Port.Write(C: Char);

{This procedure places a character on the transmit buffer}

Begin
   With Bufs[CPort] Do Begin
      T_Buffer^[T_Tail]:= C;
      Inc(T_Tail);
      If T_Tail > T_Size Then T_Tail:=0;
      If (T_Tail = T_Head) Then Begin
         Inc(T_Head); {Overflow}
         If T_Head > T_Size Then T_Head:=0;
      End;
      InLine(Disable_interrupts);
      {Tell the modem to alert us when it is OK to send data}
      Port[UART_IER]:= Port[UART_IER] Or 2;
      InLine(Enable_Interrupts);
   End;
End;

Procedure Com_Port.WriteS(S: String);

{Passes a string to the transmit buffer}

Var Ktr: Byte;

Begin
   For Ktr:= 1 to Length(S) Do
      Write(S[Ktr]);
End;

Procedure Com_Port.Break;

{This procedure sends a >BREAK< signal down the line.  It is usefull
 primarilly for mainframe and unix based systems, DOS based machines
 do not look for or respond to the break signal.}

Var
   Org_Data: byte;

Begin
   InLine(Disable_Interrupts);
   With Bufs[CPort] Do Begin
      Org_Data:= Port[UART_LCR];   {Save the contents of the LCR            }
      Port[UART_LCR]:= 255;        {Load up the Line Control Register       }
      Delay(3);                    {CRT unit - Delay 3 thousands of a second}
      Port[UART_LCR]:= Org_Data;   {Restore the Line Control Register       }
   End;
   InLine(Enable_Interrupts);
End;

Function Com_Port.OnLine: Boolean;

{This function returns TRUE if the Modem Status Register indicates a Data
 carrier detect signal.  Note that some modems always return true even when
 not connected, an AT command is needed to force DCD to return the true state
 of the modem.  Also note that some direct serial connections (I.E. no modem
 but hardwired to another machine, may not return the correct DCD stat or
 may be false even when connected - this is particularly true of three wire
 direct serial connections (pins 2, 3, and 7 wired all others unwired)}

Begin
    OnLine := (Port[Bufs[CPort].UART_MSR] And $80) > 0;
End;

Procedure Com_Port.Hangup;

{This procedure disconects the modem by lowering the DTR signal.  Note that
 some modems may not be affected by this procedure based on their AT
 configurations.  Direct serial lines are not usually affected by this
 signal.  Your best bet is to issue this command then send '+++' to the modem
 and wait five seconds and then issue 'ATH<return>'}

Var Org_MCR: Byte;  {Scratch var to store the original MCR stuff}

Begin
  With Bufs[CPort] Do Begin
     Org_Mcr := Port[UART_MCR];
     Port[UART_MCR]:= Org_MCR Or $FE;  {Lower the DTR signal  }
     Delay(100);                       {Delay 100 ms          }
     Port[UART_MCR]:= Org_MCR;         {Restore the DTR Signal}
  End;
End;

Var Ktr: Byte;

Begin

   {Initialize the 4 comm buffers to an inactive state, this code is run
    the moment you start the program, automatically}

   For Ktr:= 1 to 4 Do Begin
      Bufs[Ktr].Active  := False;
      Bufs[Ktr].R_Buffer:= Nil;
      Bufs[Ktr].R_Head  := 0;
      Bufs[Ktr].R_Tail  := 0;
      Bufs[Ktr].R_Size  := 0;
      Bufs[Ktr].T_Buffer:= Nil;
      Bufs[Ktr].T_Head  := 0;
      Bufs[Ktr].T_Tail  := 0;
      Bufs[Ktr].T_Size  := 0;
   End;
End.

{This area is ignored by turbo pascal}

Sample program:

Program Sample;

Uses Async,CRT;

Var
   C: Char;
   Com1: Com_Port;

Begin
   Com1.Init(1,10000,10000);            {Set up the buffers & Interrupt    }
   Com1.SetParam(38400,8,'N',1);        {Set up the baud,ws,parity,&stopbts}
   Com1.Enable;                         {Enable the com port               }
   C:= ' ';                             {Initialize the scratch variable   }
   WriteLn('Press ESC to exit dumb terminal');
   Loop
      If Keypressed Then Begin
        C:= Readkey;
        If C <> #27 Then Com1.Write(C);
     End;
     If Com1.Waiting Then Write(Com1.Read);
  Until C = #27;
  Com1.Done;
End.
}

{An explination of the UART data areas   The PORT address is offset by the
 numbers.  So if you're on com1 and com1 as at 3f8, the uart_IER address is
 at port address 3f8+1, uart_iir is 3f8+2, etc}

      uart_data    = 0;       {Uart Data Offset                             }
                                 {Transmit/Recieve Data area                }
      uart_ier     = 1;       {Uart Interrupt Enable Register               }
                                 {Bits 7-4 always 0                         }
                                 {Bit    3  1 = enable change in modem stat }
                                 {Bit    2  1 = enable line-status interrupt}
                                 {Bit    1  1 = enable transmit reg empty   }
                                 {Bit    0  1 = data available interrupt    }
      uart_iir     = 2;       {Uart Interrupt Identification Register       }
                                 {Bits 7-3 always 0                         }
                                 {Bits 2-1 01 = transmit - register empty   }
                                 {         10 = data available              }
                                 {         11 = line status                 }
                                 {Bit    0  1 = No Interrupt pending        }
                                 {          0 = Interrupt Pending           }
      uart_lcr     = 3;       {Uart Line Control Register}
                                 {Bit    7  0 = Normal, 1=Address Baud rate }
                                 {Bit    6  0 = break disabled, 1 enabled   }
                                 {Bit    5  0 = Don't force parity          }
                                 {          1 = if bit 4-3 = 01 parity = 1  }
                                 {              if bit 4-3 = 11 parity = 0  }
                                 {              if bit   3 = 0 no parity    }
                                 {Bit    4  0 = odd parity,1=even parity    }
                                 {Bit    3  0 = no parity, 1=parity         }
                                 {Bit    2  0 = 1 stop bit                  }
                                 {          1 = 1.5 stop bits if 5bits/char }
                                 {              or 2 stop bits if 6-8 bits  }
                                 {Bits 1-0 00 = 5 bits/character            }
                                 {         01 = 6 bits/character            }
                                 {         10 = 7 bits/character            }
                                 {         11 = 8 bits/character            }
      uart_mcr     = 4;       {Uart Modem Control Register                  }
                                 {Bits 7-5 always 0                         }
                                 {Bit    4  0=normal,1=loop back test       }
                                 {Bit    3  1=interrupts to system bus      }
                                 {Bit    2  user designated output          }
                                 {Bit    1  1=active rts                    }
                                 {Bit    0  1=active dtr                    }
      uart_lsr     = 5;       {Uart line status register                    }
                                 {Bit    7  always 0                        }
                                 {Bit    6  1=transmit shift reg is empty   }
                                 {Bit    5  1=transmit hold reg is empty    }
                                 {Bit    4  1=break recieved                }
                                 {Bit    3  1=framing error recieved        }
                                 {Bit    2  1=parity error recieved         }
                                 {Bit    1  1=overrun error recieved        }
                                 {Bit    0  1=data received                 }
      uart_msr     = 6;       {Uart Modem Status Register                   }
                                 {Bit    7  1=recieve line signal detect    }
                                 {Bit    6  1=ring indicator                }
                                 {Bit    5  1=data signal ready             }
                                 {Bit    4  1=clear to send                 }
                                 {Bit    3  1=recieve line signal change    }
                                 {Bit    2  1=ring indicator has changed    }
                                 {Bit    1  1=dsr has changed state         }
                                 {Bit    0  1=cts has changed state         }

