{
> I'm looking for a pascal V6 program to detect the UART-type installed.
}

program ComType;

{ Detect the type/presence of a comport-chip.
  Norbert Igl, 5/92 }

uses
  crt;

Const ComPortText :
    Array[0..4] of String[11] =
         ('    N/A    ',
          '8250/8250B ',
          '8250A/16450',
          '   16550A  ',
          '   16550N  ');
    IIR     = 2;
    SCRATCH = 7;

Var   PortAdr : Array[1..4] of Word absolute $40:0;

function ComPortType(ComX:byte):byte;

BEGIN
  ComPortType:=0;
  if (PortAdr[ComX] =0)
  or (Port[PortAdr[ComX]+ IIR ] and $30 <> 0)
     then exit;                                       {No ComPort !}
  Port[PortAdr[ComX]+ IIR ] := 1;                     {Test: enable FIFO}
  if (Port[PortAdr[ComX]+IIR] and $C0) = $C0          {enabled ?}
  then ComPortType := 3
  else If (Port[PortAdr[ComX]+IIR] and $80) = $80     {16550,old version..}
       then ComPortType := 4
       else begin
       Port[Portadr[ComX]+SCRATCH]:=$AA;
       if Port [Portadr[ComX]+SCRATCH]=$AA            {w/ scratch reg. ?}
           then ComPortType:= 2
           else ComPortType:= 1;
       end;
END;

var com : byte;

begin
  clrscr;
  writeln('COMPORT  Chiptest':75);
  writeln('Freeware by Norbert Igl, Germany':75);
  writeln;
  for com := 1 to 4 do
     writeln('COM:',com,':  ', ComPortText[ComPortType(com)]);
end.
