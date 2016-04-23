{
From: Kai_Henningsen@ms.maus.de (Kai Henningsen)
Newsgroups: comp.dcom.modems
Subject: Help upgrade to 16550A
Date: Tue, 04 Aug 92 16:13:00 GMT
Organization: MausNet

Any noncommercial use allowed. For commercial, ask me - or use something
else. The ideas in this program are really very simple ... I seem to
remember most came from an article in DDJ.
}

program ShowUARTs;

uses
  m7UtilLo;

type
  tUART           = (uNoUART, uBadUART, u8250, u16450, u16550, u16550a);

const
  MCR             = 4;
  MSR             = 6;
  Scratch         = 7;
  FCR             = 2;
  IIR             = 2;
  LOOPBIT         = $10;

function UARTat(UART: Word): tUART;
var
  HoldMCR,
  HoldMSR,
  Holder          : Byte;
begin {|UARTat}
  HoldMCR := Port[UART + MCR];
  Port[UART + MCR] := HoldMCR or LOOPBIT;
  HoldMSR := Port[UART + MSR];
  Port[UART + MCR] := $0A or LOOPBIT;
  Holder := Port[UART + MSR] and $F0;
  Port[UART + MSR] := HoldMSR;
  Port[UART + MCR] := HoldMCR and not LOOPBIT;
  if Holder <> $90 then begin
    UARTat := uNoUART;
    Exit
  end {|if Holder<>$90};
  Port[UART + Scratch] := $AA;
  if Port[UART + Scratch] <> $AA then
    UARTat := u8250
  else begin
    Port[UART + FCR] := $01;
    Holder := Port[UART + IIR] and $C0;
    case Holder of
      $C0: UARTat := u16550a;
      $80: UARTat := u16550;
      $00: UARTat := u16450;
      else UARTat := uBadUART;
    end {|case Holder};
    Port[UART + FCR] := $00;
  end {|if Port[UART+Scratch]<>$AA else};
end {|UARTat};

procedure DisplayUARTat(UART: Word; name: string; num: Integer);
begin {|DisplayUARTat}
  Write(Hex(UART, 4), ' ', name, num);
  if UART = 0 then
    Writeln(' not defined')
  else
    case UARTat(UART) of
      uNoUART: Writeln(' not present');
      uBadUART: Writeln(' broken');
      u8250: Writeln(' 8250B');
      u16450: Writeln(' 16450');
      u16550: Writeln(' 16550');
      u16550a: Writeln(' 16550A');
      else Writeln(' unknown');
    end {|case UARTat(UART)};
end {|DisplayUARTat};

var
  i               : Integer;
  BIOSPortTab     : array [1 .. 4] of Word absolute $40: 0;
begin {|ShowUARTs}
  Writeln; Writeln;
  Writeln('COM Port Detector');
  Writeln;
  for i := 1 to 4 do
    DisplayUARTat($02E8 + $100 * (i and 1) + $10 * Ord(i < 3), 'Standard COM',
        i);
  Writeln;
  for i := 3 to 8 do
    DisplayUARTat($3220 + $1000 * ((i - 3) div 2) + $8 * Ord(not Odd(i)),
        'PS/2 COM', i);
  Writeln;
  for i := 1 to 4 do
    DisplayUARTat(BIOSPortTab[i], 'BIOS COM', i);
end {|ShowUARTs}.

m7utillo is a general utility unit I use a lot; all you need is this routine:

function Hex(v: Longint; w: Integer): String;
var
  s               : String;
  i               : Integer;
const
  hexc            : array [0 .. 15] of Char= '0123456789abcdef';
begin
  s[0] := Chr(w);
  for i := w downto 1 do begin
    s[i] := hexc[v and $F];
    v := v shr 4
  end;
  Hex := s;
end {Hex};
