{
> Can anybody give me any info on how to read signals from pins on say
> COM2: or from LPT1: or even from The joystick port? I think it has
> been done with the PORT command or something, but what are the values
> to use to read them with? Thanks.

You can read in signals from different pins on LPT ports with the PORT
command ( =OUT/IN command in assembler). Just determine the base adress of
the LPT port using
}

  LPTadress := MemW[$40 : 6 + LPTNr * 2];

{
where LPTNr is the number of the LPT port from 1 to 3.

Should return 03BCh, 0378h or 0278h.
That has to be done once at the beginning of the program.
Now you can start to read/write values on this port.
The LPT port has:

- 8 data outputs (pin 2 to 9), which can be written using
}

  Port[LPTAdress] := B;

{
where B is a byte consisting of the 8 bits. Voltage will be 5V for 1, and 0V
for 0. (but not very high power available (TTL/CMOS)

- 4 handshake outs which can be written by
}

  Port[LPTAdress + 2] := B;

{
where B is a byte with the lowest 4 bits set to the values of the pins and
the higher 4 bits always set to zero.

        PIN  1: Strobe --> bit 0
        PIN 14: AutoFD --> bit 1
        PIN 16: Init   --> bit 2
        PIN 17: SelIN  --> bit 3

        Attention! bit 2/pin 16 is 0V when set to zero, all others
        are INVERTED! (0 --> 5V and vice versa)

- 5 handshake inputs which can be read by
}

     B := Port[LPTAdress + 1];

{
     After the command, B contains the signals that are connected to the
     input pins of the LPT port:
        Bit 0-2: no function
        Bit 3 --> PIN 15/Error
        Bit 4 --> PIN 13/Select
        Bit 5 --> PIN 12/PaperEmpty
        Bit 6 --> PIN 10/Acknowledge
        Bit 7 --> PIN 11/Busy     ===> Attention! This input is INVERSE!

 For information: The pins 18 to 25 are Signal Ground pins.
 To use the inputs, connect TTL level 0V for 0, and 5V for 1 to them.
 (Or just use a resistor 10kOhm against +5V (take it from the keyboard
 connector or so, don't know what pin that is :-( and a switch against GND:
 then you can read in the status of the swith: CLOSED: 0, OPEN: 1...)
}