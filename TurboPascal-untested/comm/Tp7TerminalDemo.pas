(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0100.PAS
  Description: TP7 Terminal Demo
  Author: STEPHAN A. MACIEJ
  Date: 05-31-96  09:17
*)

program TERMINAL;

{ ************************************************************************** }
{ TERMINAL                                                                   }
{ Turbo Pascal 7.0 Demo Programm                                             }
{ Written 1995 by Stephan A. Maciej                                          }
{ Internet: stephan@maciej.muc.de                                            }
{ For any questions, please mail to support@maciej.muc.de !                  }
{ WWW: http://www.muc.de/~stephanm                                           }
{ ************************************************************************** }
{ This program is for demonstration purpose only. Any commercial use with-   }
{ out the written permission of the author is illegal. Please report bugs,   }
{ corrections or any other ideas to stephan@maciej.muc.de. You are allowed   }
{ to distribute this program as often as you want as long as you do not      }
{ change it or edit it anyway. The author is not responsible for any damage  }
{ or destruction caused - directly or indirectly - by this program.          }
{ ************************************************************************** }

uses Crt;

const
  TxDataReg = 0;                { transmitter data register            }
  RxDataReg = 0;                { reciever data register               }
  DivLow = 0;                   { divisor latch, low byte              }
  DivHigh = 1;                  { divisor latch, high byte             }
  IntrEnable = 1;               { interrupt enable register            }
  IntrId = 2;                   { interrupt identification register    }
  FifoCtrl = 2;                 { first-in/first-out buffer controller }
  LineCtrl = 3;                 { line controll register               }
  ModemCtrl = 4;                { modem controll register              }
  LineStatus = 5;               { line status register                 }
  ModemStatus = 6;              { modem status register                }
  ScratchReg = 7;               { scratch pad (free useable)           }

const
  QueueLen = 1024;              { Length of a queue in bytes }

type
  { The TQueue type }
  TQueue = record
    Content: array[0..QueueLen - 1] of byte;
    Start: word;
    Stop: word;
    end;

type
  { The TQuadString type }
  TQuadString = string[4];      { For the Hex-function }

var
  { The two queues, one for incoming characters, the other for }
  { outgoing characters.                                       }
  InQueue: TQueue;              { The two queues: one for input buffering, }
  OutQueue: TQueue;             { the other for output buffering           }

const
  SpeedCount = 19;              { Number of valid speeds stored below }

const
  AllowedSpeeds: array[0..SpeedCount] of longint =
    (    50,      75,    110,    150,    300,    600,     900,    1200,
       1800,    2400,   3600,   4800,   7200,   9600,   14400,   19200,
      28800,   38400,  57600, 115200);

    { Just add any other speeds supported by your UART/Modem - don't }
    { forget to increase the SpeedCount                              }

var
  { Some global variables... }
  PortNr: byte;                 { Number of the used port (1, 2 etc.)       }
  PortBase: word;               { I/O base address of the used port         }
  Speed: longint;               { Speed in baud                             }
  UARTType: byte;               { UART type (one of the UART_xxxx constants }
  UsedIRQ: byte;                { The number of the used IRQ                }

procedure SendEOI; assembler;
{ Send a EOI to the Interrupt Controller }
asm
        mov     al, 20h
        out     20h, al
end;

function GetPortBase(N: byte): word; assembler;
{ Read the I/O base address of the desired port from the BIOS data segment }
asm
        { Load the segment address of the BIOS data segment into ES }
        mov     ax, 0040h
        mov     es, ax
        { Calculate the offset of the I/O port base address }
        xor     ax, ax
        mov     al, N
        dec     al
        shl     ax, 1
        mov     si, ax
        { Read the desired value and return }
        mov     ax, es:[si]
end;

procedure SetIntVec(N: byte; P: pointer); assembler;
{ Set an interrupt vector to the given address }
asm
        push    ds
        { Just use the MS-DOS function 25h to set the vector }
        mov     ah, 25h
        mov     al, N
        { ds:dx contains the vector to set }
        lds     dx, P
        int     21h
        pop     ds
end;

function GetIntVec(N: byte): pointer; assembler;
{ Get the interrupt vector }
asm
        push    es
        { Use the MS-DOS function 35h to read the vector }
        mov     ah, 35h
        mov     al, N
        int     21h
        { Move the vector from es:bx to dx:ax }
        mov     ax, bx
        mov     dx, es
        pop     es
end;

procedure ResetQueue(var Q: TQueue);
{ Resets a Queue }
begin
  Q.Start := 0;
  Q.Stop := 0;
end;

procedure PutQueueByte(var Q: TQueue; B: byte);
{ Put a byte into the Queue }
begin
  { Put the byte into the Queue before incrementing the Queue end }
  Q.Content[Q.Stop] := B;

  { Now increment the Queue end position. When Q.Stop reaches QueueLen, }
  { be sure you don't increment Q.Stop but wrap it around to 0 again !  }
  inc(Q.Stop);
  if (Q.Stop = QueueLen) then
    Q.Stop := 0;

end;

function GetQueueByte(var Q: TQueue; var B: byte): boolean;
{ Get a byte out of the Queue }
begin
  if (Q.Stop = Q.Start) then
    { If the Queue is empty, just return false. Don't set B anyway. }
    GetQueueByte := false
  else
    begin
      { Queue is not empty: return true. }
      GetQueueByte := true;

      { Get the first byte out of the Queue and return it in B. }
      B := Q.Content[Q.Start];

      { Now increment the Queue position. Be sure to wrap it to zero }
      { if the Q.Start field reaches the QueueLen constant.         }
      inc(Q.Start);
      if (Q.Start = QueueLen) then
        Q.Start := 0;
    end;
end;

procedure SerialInterrupt; interrupt;
{ This procedure handles any incoming events from the UART. }
var
  Id: byte;
  Trash: byte;
begin
  repeat
    { Now read the Interrupt Identification register }
    Id := Port[PortBase + IntrId];

    { Check if there's any pending interrupt. }
    if ((Id and 1) = 0) then
      begin

        { Now select the event. }
        case ((Id and 6) shr 1) of
          $03:
            { The Line Status register changed. }
            begin
              { Just read the LSR to clear the event. }
              Trash := Port[PortBase + LineStatus];
            end;
          $02:
            { Data arrived at the UART. }
            begin
              { Read out the data from the RxD register and store }
              { it in the incoming Queue.                         }
              Trash := Port[PortBase + RxDataReg];
              PutQueueByte(InQueue, Trash);
            end;
          $01:
            { The TxD register is empty. }
            begin
              { If there's any byte in the outgoing Queue, send it to the }
              { UART, else disable this interrupt.                        }
              if (GetQueueByte(OutQueue, Trash)) then
                Port[PortBase + TxDataReg] := Trash
              else
                Port[PortBase + IntrEnable] := $0D;

            end;
          $00:
            { The Modem Status register changed. }
            begin
              { Just read the MSR to clear the event. }
              Trash := Port[PortBase + ModemStatus];
            end;
          end;
        end;

    { Handle all interrupts ! Just check if there's }
    { one more interrupt pending.                   }
  until ((Id and 1) = 1);

  { Now tell the PIC our interrupt handler has finished it's work. }
  SendEOI;
end;

procedure SendChar(C: char);
{ Send a char to the modem }
begin
  { Put the character into the outgoing queue. }
  PutQueueByte(OutQueue, byte(C));

  { Enable the "Transmitter register empty" interrupt }
  Port[PortBase + IntrEnable] := $0F;
end;

const
  UART_Bad = 0;                 { Bad UART: not working or unidentifieable }
  UART_8250 = 1;                { Standart 8250 UART                       }
  UART_16450 = 2;               { 16450 UART (faster than 8250)            }
  UART_16550 = 3;               { 16550 UART (with buggy 16-byte FIFO)     }
  UART_16550A = 4;              { 16550A UART (with working FIFO)          }

function GetUARTType(Base: word): byte; assembler;
{ Check which UART type is assigned to the appropriate port }
asm
        { First difference: The 16450 has a scratch register which is }
        { readable and writeable. Check if it's there. If not, we've  }
        { got a 8250 UART.                                            }
        mov     dx, Base
        add     dx, ScratchReg
        mov     al, 0AAh
        out     dx, al
        in      al, dx
        cmp     al, 0AAh
        je      @@1
        mov     ax, UART_8250
        jmp     @@5
@@1:    { Now check out if the UART has got a FIFO. If it has none, it's  }
        { a 16450, if it has one but it's not working it's a 16550.       }
        { The UART will be identified as a 16550A if the FIFO is working. }
        mov     dx, Base
        add     dx, FifoCtrl
        mov     al, 01h
        out     dx, al
        nop
        mov     dx, Base
        add     dx, IntrId
        in      al, dx
        and     al, 0C0h
        cmp     al, 0C0h
        jne     @@2
        mov     al, UART_16550A
        jmp     @@5
@@2:    cmp     al, 80h
        jne     @@3
        mov     al, UART_16550
        jmp     @@5
@@3:    cmp     al, 0
        jne     @@4
        mov     al, UART_16450
        jmp     @@5
@@4:    mov     al, UART_Bad
@@5:    nop
end;

procedure UpCaseStr(var S: string); assembler;
{ Convert all chars in a string to uppercase letters }
asm
        les     di, S
        xor     cx, cx
        mov     cl, es:[di]
        inc     di
@@1:    mov     al, es:[di]
        cmp     al, 'a'
        jb      @@2
        cmp     al, 'z'
        ja      @@2
        { Chars between 'a' and 'z' will be uppercased here. }
        sub     al, 20h
@@2:    mov     es:[di], al
        inc     di
        loop    @@1
end;

function IsAllowedSpeed(Speed: longint): boolean;
{ Check if a speed is valid or not }
var
  I: byte;
begin
  { Return false by default. }
  IsAllowedSpeed := false;

  { Check if you can find the desired speed in the speeds table. }
  { If you found it, return "true".                              }
  for I := 0 to SpeedCount do
    if (AllowedSpeeds[I] = Speed) then
      begin
        IsAllowedSpeed := true;
        exit;
      end;

  { The default value ("false") will be returned if the speed wasn't }
  { found in the table.                                              }
end;

procedure GetCommandLine(var PortId: byte; var Speed: longint);
{ Check the command line and extract all parameters }
var
  S: string;
  I: byte;
  J: integer;
begin
  { If less than 1 parameter is specified, print a little help and }
  { terminate the programm.                                        }
  if (ParamCount <=0) THEN
     BEGIN
      writeln(' is one out of COM1, COM2, COM3 or COM4.');
      writeln(' is the desired communication speed. The default value is 9600.');
      writeln;

      { Halt the programm immediately. }
      halt;
    end;

  S := '';

  { Just create one long string from all parameters }
  for I := 1 to ParamCount do
    S := S + ParamStr(I);

  { Convert all lower-cased characters in that string to uppercased-chars }
  UpCaseStr(S);

  { The first three bytes of the string must be 'COM'. If not, }
  { there's an error in the command line.                      }
  if (copy(S, 1, 3) <> 'COM') or (S[5] <> '/') then
    begin
      writeln('Error in command line. Call TERMINAL without options to see the help text.');
      halt;
    end;

  { Extract the number of the COM port that shall be used. }
  I := byte(S[4]) - ord('0');

  { Check for it's boundaries ! }
  if (i > 4) then
    begin
      writeln('Wrong COM port specified.');
      halt;
    end
  else
    PortId := I;

  { Now extract the desired speed and check if it's a valid input. }
  val(copy(S, 6, length(S) - 5), Speed, J);
  if (J > 0) then
    begin
      writeln('Error in speed specifier.');
      halt;
    end;

  { At last, check if the desired speed is supported. }
  if (not IsAllowedSpeed(Speed)) then
    begin
      writeln('The speed you selected is not supported by this TERMINAL.');
      halt;
    end;
end;

procedure EnableIRQ(IRQ: byte); assembler;
{ Enable a given IRQ from 0 to 7 }
asm
        mov     cl, IRQ
        mov     bl, 1
        shl     bl, cl
        mov     ah, 255
        sub     ah, bl
        in      al, 21h
        and     al, ah
        out     21h, al
end;

procedure DisableIRQ(IRQ: byte); assembler;
{ Disable a given IRQ from 0 to 7 }
asm
        mov     cl, IRQ
        mov     bl, 1
        shl     bl, cl
        in      al, 21h
        or      al, bl
        out     21h, al
end;

procedure PrintChar(Character: char); assembler;
{ Print a character on the screen - fast }
asm
        mov     ah, 0Eh
        mov     al, Character
        xor     bh, bh
        mov     bl, 07h
        int     10h
end;

var
  OldInterruptVec: pointer;

procedure SetupPort(PortBase: word; Speed: longint; IRQ: byte);
{ Setup the UART and prepare for communication. }
var
  D: word;
  B: byte;
begin
  { For startup, disable the IRQ for the UART. }
  DisableIRQ(IRQ);

  { Get the address of the old interrupt handler and set the vector }
  { to our won interrupt handling procedure ("SerialInterrupt")     }
  OldInterruptVec := GetIntVec($08 + IRQ);
  SetIntVec($08 + IRQ, @SerialInterrupt);

  { Enable the "Recieved Data avaliable" interrupt so we can }
  { read all data out of the UART's RxD register.            }
  Port[PortBase + IntrEnable] := $01;

  { Now clear all pending interrupts - if any }
  repeat
    { Read all important registers to clear any interrupt types, }
    { B is just used for temporary result storage                }
    B := Port[PortBase + RxDataReg];
    B := Port[PortBase + LineStatus];
    B := Port[PortBase + ModemStatus];

    { Just repeat until no more interrupts are pending. }
  until ((Port[PortBase + IntrId] and 1) = 1);

  { Enable the IRQ line for the UART after all pending interrupts }
  { have been cleared.                                            }
  EnableIRQ(IRQ);

  { Calculate the divisor latch contents for the desired baud rate }
  D := (115200 div Speed);

  { Set the DLAB bit to 1, then write the divisor latch low and high bytes }
  Port[PortBase + LineCtrl] := $80;
  Port[PortBase + DivLow] := Lo(D);
  Port[PortBase + DivHigh] := Hi(D);

  { Now set the divisor latch bit to 0 and write all other values }
  Port[PortBase + LineCtrl] := $03;
  Port[PortBase + ModemCtrl] := $0B;
  Port[PortBase + IntrEnable] := $0F;

  { Check if a 16550A UART is present... }
  if (UARTType = UART_16550A) then
    begin
      { Clear the FIFO queues }
      Port[PortBase + FifoCtrl] := $07;

      { Enable the FIFO queues }
      Port[PortBase + FifoCtrl] := $C1;

      { Print a message so the user recognizes the FIFO queues are on }
      writeln('Enabling 16550A FIFO queues...');
    end;
end;

procedure RunTerminal(PortBase: word);
{ Run the Terminal }
var
  B: char;
begin
  { Just print a free line }
  Writeln;

  repeat
    { Was a key pressed ? If yes, the character is written }
    { into the outgoing queue.                             }
    if (KeyPressed) then
      begin
        { Read the key. If it was , the terminal session will }
        { be aborted, else the character will be sent out.         }
        B := ReadKey;
        if (B = #27) then
          SendChar(B);
      end
    { Is there any character in the incoming queue ? }
    else if (GetQueueByte(InQueue, byte(B))) then
      { If yes, just get the character and write it onto screen. }
      PrintChar(B);

    { Repeat this loop until the  key was pressed. }
  until (B = #27);
end;

procedure ResetPort(PortBase: word; IRQ: byte);
{ Reset UART and reset interrupt vectors }
begin
  { Reset the DLAB bit. Clear all other registers. }
  Port[PortBase + LineCtrl] := Port[PortBase + LineCtrl] and $7F;
  Port[PortBase + ModemCtrl] := 0;
  Port[PortBase + IntrEnable] := 0;

  { Disable the IRQ for the UART, then restore the old interrupt vector. }
  DisableIRQ(IRQ);
  SetIntVec($08 + IRQ, OldInterruptVec);

  { Inform the user that the terminal session was aborted. }
  Writeln;
  Writeln('Port closed.');
end;

function Hex(W: word): TQuadString;
{ Convert a number into hexadecimal outfit }
const
  HexChars: array[0..15] of char = '0123456789ABCDEF';
begin
  Hex := HexChars[W shr 12] +
         HexChars[(W shr 8) and 15] +
         HexChars[(W shr 4) and 15] +
         HexChars[W and 15];
end;

procedure WritePortInfo;
{ Output some info about the selected port }
begin
  write('Using COM', PortNr, ' (base address ', Hex(PortBase), ', IRQ ', UsedIRQ);
  write(', UART is a ');

  { Print the detected UART type }
  case UARTType of
    UART_8250:
      write('8250');
    UART_16450:
      write('16450');
    UART_16550:
      write('16550');
    UART_16550A:
      write('16550A');
    end;

  writeln(')...');
end;

{--- Main Routine ---}
begin
  { Just output some information. }
  writeln;
  writeln('TERMINAL     Version 1.00     Written 1995 by Stephan A. Maciej');
  writeln('Internet: stephan@maciej.muc.de     http://www.muc.de/~stephanm');
  writeln;

  { Check for some correct parameters on the command line. }
  GetCommandLine(PortNr, Speed);
  PortBase := GetPortBase(PortNr);
  if (PortBase = 0) then
    begin
      writeln('COM', PortNr, ': no such port !');
      halt;
    end;
  UsedIRQ := 4 - ((PortNr - 1) and 1);
  UARTType := GetUARTType(PortBase);

  { Reset both the incoming as well as the outgoing Queue. }
  ResetQueue(InQueue);
  ResetQueue(OutQueue);

  { Write some information about the selected port. }
  WritePortInfo;

  { Setup the port, run the terminal and reset the port when ready. }
  SetupPort(PortBase, Speed, UsedIRQ);
  RunTerminal(PortBase);
  ResetPort(PortBase, UsedIRQ);
end.

