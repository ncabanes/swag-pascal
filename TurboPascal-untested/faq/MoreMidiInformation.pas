(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0020.PAS
  Description: More MIDI Information
  Author: JOHN GUILLORY
  Date: 11-02-93  06:07
*)

{
JOHN GUILLORY

> - the UART 8250, the chip which is their I/O controller
I don't think they use an 8250 UART chip, yet they are similar.  the MIDI
UART is supposed to be faster than the 8250.

> - the MIDI protocol ( as far as there is one ... )
Basically it's like this:  Commands start at 80h the lower 4 bits (nibble)
designate the channel number such that 0 = Channel 1, 0f = 16.  Once a
command is given, it is assumed that that command is in effect Until another
command has been given. eg.

$C0 is a command to change the Program number, and I think 80 is note on.
if so, an example from the MIDI would be:

80 33 60 80 33 00 C0 02 80 33 60 80 33 00

where the 33 is the note to play For the command 80h and 60 is the
pressure/volume (non-presure sensitive keyboards send 64 For the pressure)
Notes are in the order of a keyboard e.g. 0 would tech. be the first C on
the keyboard, 1 would be a C sharp, 2 = D ..., Although most keyboards
(unless they're their enormous) start w/Middle C at around 36 or so, and any
key above middle C is that much above 36, any key below middle C is that
much below....  in MIDI, you can add an octive to a note by adding 12,
subtract 12 to lower it an octive....

To setup keyboards, you can send a System Request command (think its F0 or
something like that...) then an ID and a series of Bytes.  The ID Designates
the manufacturer of the keyboard, such that only the devices With that ID
will respond to that event.

Seek the Electronic Musician Magazine, May 1989 I'm told gives an article on
handling the MPU-401 interrupts, as well as lots of source code that I used
to have on the MPU-401 seems to come from this magazine.


The MIDI is quite easy to Program compared to the Sound blaster where you
have to count of so many clock-tick's etc. the MPU-401 is pretty much a
'check and see if we can send, then do it...' Type card.  Certain commands
do however take a little time For the devices to process eg. change a Program
# it takes so many ms. For that device to be ready For another command, play
a note, a few ms. before the next one...

This can become frustation before you learn how to use it...  (I never could
find out why it'd change the first Program # but none of the rest...<grin>)

I/O Address 330h is the Std. (though can change on some MPU-401's) I/O Port
for Data. I/O Address 331 is the Status/Comport.

Reading the Status port (331h) and masking 80h will tell you if something is
waiting to be received from the mpu-401. e.g.
}

Function Receive_MPU(Var B : Byte) : Boolean;
begin
  if (Port[$331] and $80) = 0 then
  begin
    B := Port[$330];
    Receive_MPU := True;
  end
  else
    Receive_MPU := False;
end;

{
To Send a Command to the MPU, you must wait till there's no data in the
buffer... The original code I used to have would flush the data if it was
for some reason present when you'd send a Byte...  here's a rough example of
sending data...
}

Procedure Send_MPU(B : Byte);
begin
  Repeat Until (Port[$331] and $80) = 0;
  Port[$330] := B;
end;


