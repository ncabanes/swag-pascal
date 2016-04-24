(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0041.PAS
  Description: Baud Rates
  Author: KELLY SMALL
  Date: 02-05-94  07:56
*)

{
Can anyone tell me how you would set the baud rate for a speed above 9600 BP
in the bit mask for int 14h. also how you could do a Null modem type
connection.

You can't.  You must program the divisor in the uart your self
for those higher baudrates.  Here's part of a serial routine I
use:
}

Unit SerialIn;
{F+}
Interface
Uses Crt,Dos;
Const  CommPort   = $3F8;   { normally com1 = $3F8 and com2 = $2F8 }
       CommIrq    = 4;      { normally com1 = 4 and com2 = 3 }
       BaudRate   = 9600;   { 300 - 9600 }
       Parameters = $03;    { 7 6 5  4 3  2  1 0
                              +-+-+  +-+  |  +-+--- width 10 = 7 bits
                              don't    |  |               11 = 8 bits
                              care     |  +------- stopbit 0 = 1 bit
                                       |                   1 = 2 bit
                                       +---------- parity X0 = none
                                                          01 = odd
                                                          11 = even    }

       BufferSize = 1000; { Size of receiver buffer }
       IntMask    : Array[2..5] of Byte = ($FB,$F7,$EF,$DF);

Var ComBuffer  : Array[0..Buffersize] of Byte;
    HeadPtr,
    TailPtr    : Integer;
    OldCommInt : Pointer;

Procedure ComInit;                    { Initialize serial port }
Procedure ComDisable;                 { Disable serial port }
Procedure SendChar(Ch:Char);          { Send character to serial port }
Procedure SendString(Message:String); { Send string to serial port}
Function  GetChar:Char;               { Get character from serial port }
Function  GetCharWait:Char;           { Wait for character ready, then get }
Function  CharReady:Boolean;          { Returns true if character has been }
                                      { received through serial port }

Implementation

Procedure ComInit;         { get the serial port ready for use }
Var Divisor : Integer;     { this routine MUST be called before }
    Dummy   : Integer;     { using serial port! }
  Begin
  Case BaudRate of
     300 : Divisor := 384;
    1200 : Divisor := 96;
    2400 : Divisor := 48;
    9600 : Divisor := 12;
   19200 : Divisor := 6;
    3840 : Divisor := 3;
    5760 : Divisor := 2;
   11520 : Divisor := 1;
    Else WriteLn('Illegal Baudrate');
    End;
  Port[CommPort+3] := $80;                 { Set divisor latch bit }
  Port[CommPort] := Lo(Divisor);           { Set lower divisor }

  Port[CommPort+1] := Hi(Divisor);         { set upper divisor }
  Port[CommPort+3] := Parameters;          { clear divisor latch and }
                                           { set data parameters }
  HeadPtr := 0;                            { reset buffer pointers }
  TailPtr := 0;
  GetIntVec(CommIrq+8,OldCommInt);         { Save the old vector }
  SetIntVec(CommIrq+8,@ComIntHandler);     { Install interrupt handler }
  Port[CommPort+1] := 1;                   { Enable receiver interrupt }
  Port[CommPort+4] := 9;                   { Enable DTR and OUT2 }
  Port[$21] := Port[$21] And
                         IntMask[CommIrq]; { Program 8259 Int mask }
  Dummy := Port[CommPort];                 { Read the receiver register }
  End;                                     { to clear status flags }

