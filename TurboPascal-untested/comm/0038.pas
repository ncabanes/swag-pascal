{
From: ELAD NACHMAN
Subj: High Speed COM I/O
---------------------------------------------------------------------------
 RL> Dose anyone know how a humble young TP programmer can access
 RL> modems at speeds of say 57,600 baud rates? I would love even
 RL> 14,400 routines. I had a set of simple I/O routines, but speeds
 RL> over 2400 term programs would lose characters. I would like to
 RL> write some doors for a BBS but can't break the 2400 limit.

You probably use a very simple way, which doesn't envolves capturing the
modem's Com port IRQ. That's why you use chars over faster transmitions.
To make sure the program will be fast, optimize it to assembler, or at least
use I/O Ports manipulations (If you odn't use it already).
A cut from a source I have here (Design for com1, if you need support for other
ports use a guide such as Helppc. If you want To write Doors for BBSes you
better use Fossil functions, For that either use Fsildoc.??? (It's in several
FTP sites) or Ralf Brown's Interrupt list):
}

const

{ 8250 IRQ Registers }

Data=$03f8; { Contains 8 bits for send/receive }

IER=$03f9; { Enables Serial Port when set to 1 }

LCR=$03fb; { Sets communication Parameters }

MCR=$03FC; { bits 1,2,4 are turned on to ready modems }

LSR=$3FD; { when bit 6 is on, it is safe to send a byte }

MDMMSR=$03FE; { initialized to $80 when starting }

ENBLRDY=$01; { initial value for port[IER] }

MDMMOD=$0b; { initial value for port[MCR] }

MDMCD=$80; { initial value for port[MDMMSR] }

INTCTLR=$21; { port for 8259 interrupt controller }

var

mybyte:byte;
vector:pointer;


procedure asyncint; interrupt;
begin
inline($FB); {STI}
mybyte:=port[dataport];
inline($FA); {CLI}

Port[$20]:=$20;

end;

procedure setmodem;
var
regs: registers;
parm : byte;

begin

parm:=3+4+0+$d0;
{8 databits,1 stopbit,no parity,9600 baud}
{databits: values 0,1,2,3 represent 5,6,7,8 databits
stopbits: value 4 is for 1 stopbits, 0 for none
parity: value 0 or $10 for none, $8 for odd, $18 for even
baud: $d0 for 9600, $b0 for 4800, $a0 for 2400, $80 for 1200, $60 for 600, $40
for 300 add all this values and get the correct byte parameter}

with regs do
begin
dx:=0; { comport -1 }
ah:=0;
al:=parm;
flags:=0;
intr($14,regs);
end;
end;

procedure EnablePorts;
var
b: byte;
begin
getintvec($0c,Vector); { $0c is for com1/com3 - IRQ 4 }
setintvec($0c,@AsyncInt);
b:=port[INTCTLR];
b:=b and $0ef;
port[INTCTLR]:=b;
b:=port[LCR];
b:=b and $7f;

port[lcr]:=b;
port[ier]:=enblrdy;
port[mcr]:=$08 or MDMMOD;
port[mdmmsr]:=mdmcd;
port[$20]:=$20;

{ when: port[MDMMSR] and $80 = $80 then there's carrier }

procedure sendchartoport(b: byte);
begin
while ( (port[lsr] and $20) <> $20 ) do
begin
end;
port[dataport]:=b;
end;

procedure sendstringtoport(s: string);
var
i:integer;
begin
for i:=1 to length(s) do
sendchartoport(ord(S[i]));
snedchartoport(13);
end;

procedure disableports;
var
b: byte;
begin
sendstringtoport('ATC0');
b:=port[intctlr];
b:=b or $10;
port[intctlr]:=b;
b:=port[lcr];
b:=b and $7f;
port[lcr]:=b;
port[ier]:=$0;

port[mcr]:=$0;
port[$20]:=$20;
setintvec($0c,vector);
end;

{ How the program itself should generally be }

begin

setmodem;
enableports;
send strings or chars
disableports;

end.
