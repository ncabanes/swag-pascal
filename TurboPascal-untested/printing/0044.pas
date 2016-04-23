
unit Prt;
interface
uses objects;
const
Lpt1=  0; Lpt2=  1;
Lpt3=  2; lf = #10;
cr = #13; pTimeOut= $01;
pIOError= $08; pNoPaper= $20;
pNotBusy= $80;
pTestAll= pTimeOut + pIOError + pNoPaper;
function WriteChar(const APort : word; s : char): boolean;
function Ready(const APort : word): boolean;
function Status(const APort : word): byte;
procedure InitPrinter(const APort : word);
implementation
procedure InitPrinter(const APort : word); assembler;
asm
mov ah, 1
mov bx, APort
int 17h
end;
function Status(const APort : word): byte; assembler;
asm
mov ah, 2  { Service 2 - Printer Status }
mov dx, APort { Printer Port  }
int 17h { ROM Printer Services  }
mov al, ah { Set function value }
end;
function Ready(const APort : word): boolean;
begin
Ready := Status(APort) and pTestAll = $00;
end;
function WriteChar(const APort : word; s : char): boolean;
begin
if Ready(APort) then
 asm
mov ah, 0  { Printer Service - Write Char }
mov al, s  { Char to write}
mov dx, APort  { Printer Port }
int 17h { ROM Printer Services }
mov al, 0  { Set procedure to false  }
and ah, 1  { Check for Error }
jnz @End{ Jump to end if error }
mov al, 1  { Set procedure to true}
  @End:
end;
end;

end.
