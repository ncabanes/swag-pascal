(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0073.PAS
  Description: Sending Strings to the Modem
  Author: JOHN STEPHENSON
  Date: 11-26-94  05:05
*)

{
> Could anybody PLEASE tell me how I can send a string (for example
> 'ATH1') to the modem? I want to create a program that dials a number
> and then automaticly enters a few other numbers....
> so, for example:

Without giving you a complete com-unit here's something that will do the
trick.
}
uses crt;
const
  RBR     = $00;             { Receive Buffer offset               }
  THR     = $00;             { Transmitter Holding offset          }
  IER     = $01;             { Interrupt Enable offset             }
  IIR     = $02;             { Interrupt Identification offset     }
  LCR     = $03;             { Line Control offset                 }
  MCR     = $04;             { Modem Control offset                }
  LSR     = $05;             { Line Status offset                  }
  MSR     = $06;             { Modem Status offset                 }
  DLL     = $00;             { Divisor Latch Low byte              }
  DLH     = $01;             { Divisor Latch Hi byte               }
  CMD8259 = $20;             { Interrupt Controller Command offset }
  IMR8259 = $21;             { Interrupt Controller Mask offset    }

Var Combase: Word;           { Hardware Com-port Base Adress }

Function Carrier : boolean;
{ To detect carrier on remote port, requires combase to be set to the  }
{ correct com base address                                             }
begin
  carrier := port[Combase + MSR] and $80 = $80;
end;

Procedure RaiseDTR;
{ To raise the DTR signal bit 0 of the mcr must be changed to on       }
begin
  port[combase + msr] := port[combase + mcr] or $1;
end;

Procedure LowerDTR;
{ To lower the DTR signal, causing carrier loss, bit 0 must be turned  }
{ off                                                                  }
begin
  port[combase + msr] := port[combase + mcr] and not $1;
end;

Procedure Writeport(st : string);
{ This procedure takes a string from the parameters and sends each          }
{ character making sure that the com base address is not equal to 0 (not    }
{ Installed)                                                                }
Var
  Count,LoopLimit: word; { Time out counter }
  loop: byte;
Begin
  LoopLimit := 2000;
  for loop := 1 to length(st) do begin
    Count := 0;
    Repeat
      inc(Count);
    Until ((port[Combase + LSR] and $20) <> 0) or (Count > LoopLimit);
    If Count < LoopLimit then port[Combase+THR] := byte(st[loop]);
  End;
End;

Procedure Hangup;
{ To drop carrier to hangup the phone -- Simple eh? }
Begin
  lowerdtr;   { Drop DTR }
  delay(500);
  { If the modem can't handle DTR drops go back to grade school and use }
  { Hayes compatiable hangups }
  if carrier then begin
    writeport('+++');
    delay(1000);
    writeport('ATH0'#13);
  End;
End;

Procedure Initport(Cb : word; Baudrate : word; Bits : Byte; Parity : Char; Stop
: byte);Var
  tempstop,temppar: byte;
  tempbaud: word;
Begin
  Combase := Cb;                                   { Set Comport baseadress }

  if stop = 1 then tempstop := $0                  { Decode the stopbits    }
    else tempstop := $04;
  case upcase(Parity) of                           { Decode parity          }
    'S': tempPar := $38;
    'O': tempPar := $08;
    'M': tempPar := $28;
    'E': tempPar := $18;
    'N': tempPar := $00;
  end;
  case baudrate of                                 { Decode baud rate       }
    110     : tempbaud := $417;
    150     : tempbaud := $300;
    300     : tempbaud := $180;
    600     : tempbaud := $C0;
    1200    : tempbaud := $60;
    2400    : tempbaud := $30;
    4800    : tempbaud := $18;
    9600    : tempbaud := $0C;
    19200   : tempbaud := $06;
{   38400   : tempbaud := $03;
    57600   : tempbaud := $02;
    115200  : tempbaud := $01; {-- Outside of ordinal range}
  End;

  port[Combase+LCR] := $80;                        { Adress Divisor Latch   }
  port[Combase+DLH] := Hi(tempbaud);               { Set Baud rate          }
  port[Combase+DLL] := Lo(tempbaud);
  port[Combase+LCR] := $00 or temppar              { Setup Parity           }
                             or (Bits - 5)         { Setup databits         }
                             or tempstop;          { Setup stopbits         }
  port[Combase+MCR] := $0B;                        { Set RTS, DTR           }
End;

begin
  initport($3F8,19200,8,'N',1);
  writeport('ATD'#13);
end.

{
Please note that this program is well.. unable to recieve characters, if
you're to poll the CTS/RTS every so often you could check it easily and
you'd have a non-interrupt driven comm routine, probably end up loosing
characters left & right, but it would work for what you're trying to do
and save some coding. Anyhow this should get you started.
}

