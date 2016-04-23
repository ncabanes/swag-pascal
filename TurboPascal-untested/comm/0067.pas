{
> This is part of a procedure I use in my door to initialize the fossil
> driver.  However, I need the CORRECT numbers for 38400 (1 only works on
> some fossil drivers), 57600, and if anyone has it, 115200.  Can anyone
> help?

Here's what I use..
}

{ To initialize the modem.. Not to be confused with PortOn }
Procedure InitPort(Cp : word; Baud : Word; Charlength : byte; Parity : Char;
                   StopBits: Byte);
var temp : byte;
Begin
  comport := cp;
  port := pred(cp);
  temp := 0;  { Default of 19200 }

  Case Baud of           { 128, 64, 32... }
    19200 : Temp := 0;   { 000____ }
    38400 : Temp := 32;  { 001____ }
    300   : Temp := 64;  { 010____ }
    600   : temp := 96;  { 011____ }
    1200  : Temp := 128; { 100_____ }
    2400  : Temp := 160; { 101_____ }
    4800  : Temp := 192; { 110_____ }
    9600  : Temp := 224; { 111_____ }
  End;
  baudrate := baud;

  Case UpCase(Parity) of { 16, 8... }
{   'N' :;               { ___00___ }
    'O' : Inc(temp, 8);  { ___01___ }
    'E' : Inc(temp, 24); { ___11___ }
  End;
                                     { 4... }
  If StopBits = 2 then Inc(temp, 4); { _____1__ }
  { If StopBits = 1 then ;           { _____0__ }

  Case CharLength of  { 2, 1. }
    8 : inc(temp, 3); { ______11 }
    7 : inc(temp, 2); { ______10 }
  End;

  asm
    mov ah, $00
    mov al, temp
    mov dx, port
    int $14
  end;
End;

{
I used the revision FOSSIL revision 5.0 specs to do that with.. And it works
btw FOSSIL v5.0 specs don't mention 38400+ init's.
}
