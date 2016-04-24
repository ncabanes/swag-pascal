(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0071.PAS
  Description: Serial Communications in Pascal
  Author: DAVE JARVIS
  Date: 11-26-94  05:05
*)


{
>     Ok... I have fifty million different modem units, sources, docs
> I have not been able to get any where with any of them....  All i want

I remember being in your shoes a long time ago, my friend.  I haven't
a Unit, per se, but here is _WORKING_ Pascal source (excuse the
documentation style, I originally wrote the code in C) that compiles under
TP 6.0.

  Written by Dave Jarvis.
  
  The purpose of this program is to do a simple communications protocol and 
  demonstrate how Serial communications can be Serially driven. 
} 
 
USES DOS, Crt; 
 
CONST 
  COM1      = $3F8;    { Communications port 1 address.     } 
  COM2      = $2F8;    { Communications port 2 address.     } 
  THR       = $00;     { Transmitter holding register.      } 
  RDR       = $00;     { Receiver data register.            } 
  BRDL      = $00;     { Baud rate low divisor register.    } 
  BRDH      = $01;     { Baud rate high divisor register.   } 
  IER       = $01;     { Interrupt enable register.         } 
  IIR       = $02;     { Interrupt identIFication register. } 
  LCR       = $03;     { Line control register.             } 
  MCR       = $04;     { Modem control register.            } 
  LSR       = $05;     { Line status register.              } 
  MSR       = $06;     { Modem status register.             } 
 
  SET_BAUD  = $80;     { DLAB.                              } 
  CTS_DSR   = $30;     { Check for DSR and CTS in MSR.      } 
  THREMPTY  = $20;     { Check for THR empty in LSR.        } 
 
  WORD7      = $02;    { Bits 0 and 1 when setting LCR.     } 
  WORD8      = $03; 
  BIT1       = $00;    { Bit 3 when setting LCR.            } 
  BIT2       = $04; 
  NONE       = $00;    { Bits 4, 5, and 6 when setting LCR. } 
  EVEN       = $30; 
  ODD        = $20; 
 
  INT_ENABL  = $0B;    { Tell UART to perform interrupts.   } 
  PIC        = $20;    { Address of PIC.                    } 
  PIC_CNTL   = $21;    { Address of PIC control register.   } 
  IRQ4_MASK  = $EF;    { Mask for IRQ4.                     } 
  COM_INT    = $0C;    { Communications interrupt to tap.   } 
  EOI        = $20;    { End of interrupt signal for PIC.   } 
  DATA_REC   = $01;    { Interrupt on data received.        } 
  WRITE_CH   = $0E;    { Write character function.          } 
 
  XON_CH     = #$11;   { XON protocol control character.    } 
  XOFF_CH    = #$13;   { XOFF protocol control character.   } 
  EOT        = #$04;   { End of transmission character.     }

  MAX_BUFF   = 256;     { Maximum characters in the buffer.  }
  BUFF_FULL  = 0.75;    { Buffer full @ 75% of MAX_BUFF.     }
  BUFF_EMPT  = 0.50;    { Buffer empty @ 50% of MAX_BUFF.    }

  ERR        = -1;

TYPE
  RecLinkPtr = ^Receive;

  Receive = RECORD
              rec_char : CHAR;
              Next     : RecLinkPtr;
            End;

VAR
  rec_buff,                  { Global linked list. } 
  to_write   : RecLinkPtr; 
  buff_Count : INTEGER;      { Number of characters in buffer.    } 
  xon        : BOOLEAN;      { Enable send ability.               } 
 
PROCEDURE ShowUsage; 
Begin 
   WriteLn( 'Usage : TERMINAL <baud> <parity> <data bits> <stop bits>' ); 
   WriteLn( 'Where : <baud> is any of 300, 1200, 2400, 9600;' ); 
   WriteLn( '        <parity> is any of N, O, E;' ); 
   WriteLn( '        <data bits> is either 7 or 8;' ); 
   WriteLn( '        <stop bits> is either 1 or 2.' ); 
 
   Halt( 0 );

End; 
 
PROCEDURE setup( baud, parity, data_bits, stop_bits : INTEGER ); 
VAR 
  setup : INTEGER; 
 
Begin 
  setup := parity;

 
  { Set DLAB such that baud rate can be changed/set. } 
  Port[ COM1 + LCR ] := SET_BAUD; 
 
  CASE baud OF 
     300 : Begin 
             Port[ COM1 + BRDL ] := $80; 
             Port[ COM1 + BRDH ] := $01; 
           End; 
    1200 : Begin 
             Port[ COM1 + BRDL ] := $60; 
             Port[ COM1 + BRDH ] := $00; 
           End; 
    2400 : Begin 
             Port[ COM1 + BRDL ] := $30; 
             Port[ COM1 + BRDH ] := $00; 
           End; 
    9600 : Begin 
             Port[ COM1 + BRDL ] := $0C; 
             Port[ COM1 + BRDH ] := $00; 
           End;
    ELSE
      ShowUsage;
  End;

  CASE data_bits OF
    7  : setup := setup OR WORD7;
    8  : setup := setup OR WORD8;
    ELSE
      ShowUsage;
  End;

  CASE stop_bits OF
    1  : setup := setup OR BIT1;
    2  : setup := setup OR BIT2;
    ELSE
      ShowUsage;
  End;

  { Send final (calculated) setup Value to the communications port. }
  Port[ COM1 + LCR ] := setup;
End;

PROCEDURE add_char( ch : CHAR );
Begin 
  { IF the buffer is full, then sound the speaker twice -- toss char. } 
  IF( buff_Count = MAX_BUFF ) THEN 
  Begin 
    Sound( 1000 ); 
    Sound( 900 ); 
    NoSound; 
 
    Exit; 
  End; 
 
  { Store character in buffer. } 
  rec_buff^.rec_char := ch; 
 
  { Point to next storage position. } 
  rec_buff := rec_buff^.next; 
 
  { Increment number of characters in buffer. } 
  INC( buff_Count ); 
End; 
 
{$F+} 
PROCEDURE receive_ch; INTERRUPT; 
VAR 
  ch : CHAR; 
 
Begin 
  ch := CHAR(Port[ COM1 + RDR ]); 
 
  IF( ch = XON_CH ) THEN 
    xon := TRUE 
  ELSE IF( ch = XOFF_CH ) THEN 
    xon := FALSE 
  ELSE 
    add_char( CHAR(ch) ); 
 
  { Send End of interrupt signal to PIC chip. } 
  Port[ PIC ] := EOI; 
End; 
{$F-} 
 
PROCEDURE xmit( ch : CHAR ); 
Begin 
  Port[ COM1 + THR ] := INTEGER(ch); 
End;

FUNCTION can_xmit : BOOLEAN;
Begin
  {  IF input characters can be sent, and the DSR, CTS and THREMPTY are
     all set high, then the character read from keyboard can be sent.
  }
  IF( xon AND ((Port[ COM1 + MSR ] AND CTS_DSR)  = CTS_DSR) AND
             ((Port[ COM1 + LSR ] AND THREMPTY) = THREMPTY) ) THEN
    can_xmit := TRUE
  ELSE
    can_xmit := FALSE;

End;

PROCEDURE writech;
Begin
  Write( to_write^.rec_char );

  { Decrement the number of actual elements in the buffer. }
  DEC( buff_Count );

  { Point to the next character to write (IF any are left). }
  to_write := to_write^.next;
End;

PROCEDURE send_string( s : STRING );
VAR 
  Count : INTEGER; 
 
Begin 
  FOR Count := 1 TO Length( S ) DO 
  Begin 
    WHILE( NOT can_xmit ) DO 
      ; 
 
    xmit( s[ Count ] ); 
  End; 
End; 
 
PROCEDURE Serial; 
VAR 
  ch       : CHAR;       { Character read from the keyboard.    } 
  done,                  { Loop until done = TRUE.              } 
  send_xon : BOOLEAN;    { TRUE IF XON character has been sent. } 
 
Begin 
  done     := FALSE; 
  send_xon := TRUE; 
 
  Repeat 
    {  IF a character is in the keyboard buffer, and it can be sent to the 
       UART, then read it from the keyboard buffer, and transmit it. 
    } 
    IF( can_xmit AND KeyPressed ) THEN 
    Begin 
      ch := ReadKey; 
 
      IF( ch = EOT ) THEN 
        done := TRUE 
      ELSE 
        xmit( ch ); 
    End; 
 
    IF( buff_Count > 0 ) THEN 
    Begin 
      { Display a character from the buffer. } 
      writech; 
 
      { IF the buffer is more than 75% full, then send XOFF char ASAP. } 
      IF( (buff_Count / (MAX_BUFF * 1.0)) > BUFF_FULL ) THEN 
      Begin
        { Wait until a character can be sent. } 
        WHILE( NOT can_xmit ) DO 
          ; 
 
        { Send the XOFF control code. } 
        xmit( XOFF_CH ); 
 
        { Indicate that an XON can be sent anytime. } 
        send_xon := FALSE; 
      End; 
 
      { IF the buffer is less than 50% full, then send XON char ASAP. } 
      IF( ((buff_Count / (MAX_BUFF * 1.0)) < BUFF_EMPT) AND 
           (NOT send_xon) ) THEN 
      Begin 
        { Wait until a character can be sent. } 
        WHILE( NOT can_xmit ) DO 
          ; 
 
        { Send the XON control code. } 
        xmit( XON_CH ); 
 
        { An XON control code has been sent. } 
        send_xon := TRUE; 
      End; 
    End; 
  Until( done ); 
End; 

FUNCTION Value( NumS : STRING ) : LONGINT;
VAR 
  O, M, S, C : LONGINT; 
 
Begin 
  S := 0; 
  M := 1; 
 
  FOR C := Length(NumS) DOWNTO 1 DO 
  Begin 
    O := Ord( NumS[C] ); 
 
    IF NumS[C] IN ['0'..'9'] THEN 
    Begin 
      INC( S, M * (O - 48) ); 
      M := M * 10; 
    End; 
  End; 
 
  Value := S; 
End; 
 
FUNCTION UCase( S : STRING ) : STRING; 
VAR 
  C : BYTE; 
 
Begin 
  FOR C := 1 TO Length(S) DO 
    S[C] := UpCase( S[C] ); 
 
  UCase := S; 
End; 
 
VAR 
  Count,                { Simple Counter.                    } 
  baud,                 { Baud rate.                         } 
  parity,               { Parity    - NONE, EVEN, ODD.       } 
  data_bits,            { Data bits - 7, 8.                  } 
  stop_bits  : INTEGER; { Stop bits - 1, 2.                  } 
  temp, 
  current    : RecLinkPtr; 
  SecParam   : STRING; 
  save_int   : POINTER; 
 
Begin 
  buff_Count := 0;
  xon        := TRUE;

  { 4 command line arguments (include program name) are required. }
  IF( ParamCount <> 4 ) THEN
    ShowUsage;

  { The first command line argument is specified to be the baud rate. }
  baud := Value( ParamStr( 1 ) );

  { Convert second argument to upper case so first letter can be checked
    for parity. }
  SecParam := ParamStr( 2 );
  SecParam := UCase( SecParam );

  { Check first character of 2nd command line parameter for parity. }
  CASE SecParam[1] OF
    'N' : parity := NONE;
    'O' : parity := ODD;
    'E' : parity := EVEN;
  ELSE
    ShowUsage;
  End;

  rec_buff := NIL;
  {  Allocate enough memory for MAX_BUFF characters (New is not re-entrant).
  } 
  FOR Count := 0 TO MAX_BUFF - 1 DO 
  Begin 
    New( temp ); 
 
    temp^.next     := NIL; 
    temp^.rec_char := #0; 
 
    IF( rec_buff = NIL ) THEN 
      rec_buff := temp 
    ELSE 
    Begin 
      current := rec_buff; 
 
      WHILE( current^.next <> NIL ) DO 
        current := current^.next; 
 
      current^.next := temp; 
    End; 
  End; 
 
  {  Create a circular buffer by pointing the last element in the list to 
     the start (head) of the list. 
  } 
  temp^.next := rec_buff; 
 
  { Point to the first character to write within the buffer. } 
  to_write := rec_buff; 
 
  data_bits := Value( ParamStr( 3 ) );

  stop_bits := Value( ParamStr( 4 ) ); 
 
  getintvec( COM_INT, save_int ); 
 
  { Set vector = $0C to new interrupt routine. } 
  SetIntVec( COM_INT, Addr( receive_ch ) ); 
 
  { Initialize the modem according to the command line parameters. } 
  setup( baud, parity, data_bits, stop_bits ); 
 
  { Interrupt on received character. } 
  Port[ COM1 + IER ] := DATA_REC; 
 
  { Enable interrupts }
  Port[ COM1 + MCR ] := INT_ENABL; 
 
  { Set PIC control register to enable IRQ4. } 
  Port[ PIC_CNTL ] := Port[ PIC_CNTL ] AND IRQ4_MASK; 
 
  { Set MSR such that CTS and DSR are high. } 
  Port[ COM1 + MSR ] := CTS_DSR; 
 
  ClrScr; 
  WriteLn( 'Type Control-D at any time to quit.' ); 
 
  { Repeat Serial communications. } 
  Serial; 
 
  { Disable interrupts } 
  Port[ COM1 + IER ] := 0; 
 
  { Set PIC control register to disable IRQ4. } 
  Port[ PIC_CNTL ] := Port[ PIC_CNTL ] AND (NOT IRQ4_MASK); 
 
  { Set vector = $0C to old interrupt routine. } 
  SetIntVec( COM_INT, save_int ); 
 
  { Deallocate all the memory used in the buffer. } 
  FOR Count := 0 TO MAX_BUFF - 1 DO 
  Begin 
    temp     := rec_buff; 
    rec_buff := rec_buff^.next; 
 
    Dispose( temp ); 
  End; 
End. 

