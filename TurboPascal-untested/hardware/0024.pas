{
> does anybody knows the address for serial/parallel ports?

you can find them by reading the 7 (seven) WORDs starting at address 0040:0000
<smile>...
}

CONST
  BIOSBASE : word = $0040;
  PORTADDR : word = $0000;

VAR
  COM1, COM2,
  COM3, COM4,
  LPT1, LPT2, LPT3 : word;

BEGIN
  COM1 := memw[BIOSBASE:PORTADDR+0];
  COM2 := memw[BIOSBASE:PORTADDR+2];
  COM3 := memw[BIOSBASE:PORTADDR+4];
  COM4 := memw[BIOSBASE:PORTADDR+6];
  LPT1 := memw[BIOSBASE:PORTADDR+8];
  LPT2 := memw[BIOSBASE:PORTADDR+10];
  LPT3 := memw[BIOSBASE:PORTADDR+12];
END.

{
RICHARD BROWNE

>I guess I can declare an absolute variable at $40:$0000 and use offset to fi
>the addresses.  Just a guess - haven't tried it yet. Thanks for your help.

Do this, it works.  When you WRITELN the variables to the
screen, they will be in decimal.  If you convert them to hex,
you'll see that they are the old, familiar addresses.  If any
variable is zero, there is no port present in your computer.

Another thing you'll notice, if you have com4, for instance, but
no com3.  The normal com4 address will show up in the com3
memory location, and the com4 adderess will be 0.  Which
explains why funny things happen when you are using ports 1, 2
and 4 with no 3, or 1 and 3 with no 2, etc., and why we are told
to always have consecutive com ports, with no "missing" numbers.
}
program testadr;
var
   com1adr : Word Absolute $0040:$0000; { Get COM1 Port address }
   com2adr : Word Absolute $0040:$0002; { Get COM2 Port address }
   com3adr : Word Absolute $0040:$0004; { Get COM3 Port address }
   com4adr : Word Absolute $0040:$0006; { Get COM4 Port address }
   lpt1adr : Word Absolute $0040:$0008; { Get LPT1 Port address }
   lpt2adr : Word Absolute $0040:$000A; { Get LPT2 Port address }
   lpt3adr : Word Absolute $0040:$000C; { Get LPT3 Port address }

begin
   writeln('com1 address: ',com1adr);
   writeln('com2 address: ',com2adr);
   writeln('com3 address: ',com3adr);
   writeln('com4 address: ',com4adr);
   writeln('lpt1 address: ',lpt1adr);
   writeln('lpt2 address: ',lpt2adr);
   writeln('lpt3 address: ',lpt3adr);
   readln;
end.
