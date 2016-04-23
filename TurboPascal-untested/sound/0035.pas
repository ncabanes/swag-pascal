{
> Is there anyone here who has a source on how to play MID-files in
> PAS-programs, they could post here or NetMail to me???

I can tell you how to access the MIDI port for MPU-401 compatible
controllers.  The MFF (.MID) format is WAY too complex to describe here,
but I *highly* recommend studying the excellent set of articles by Charles
Petzold on MIDI and MIDI files in PC Magazine Vol 11, No 7 (April
14, 1992) to Vol 11, No 19 (November 10, 1992).  The article was mainly for
Windows programmers, but he spent a good portion of the articles
explaining MIDI itself in detail (including the MFF (.MID) format).  All
his source code and sample programs are availible on ZiffNet.  You can
also get the MFF format detailed in the 14-page document "Standard MIDI Files
1.0" from the International MIDI Association for $7 + $1.50p&h US funds (call
310-649-6434).

I wrote a small (buggy, not working yet) unit for MPU-401 access from
information I got here a few months back.  Your MIDI device must be
fully MPU-401 compatible to use this.

{ MPU-401 MIDI playback/record routines }
{ Public domain 1993 Steven Tallent     }
{ Plays the proper notes on an MPU-401  }
{ compatible synthesizer. }
{ Reading the Status port (331h) and masking 80h will tell you if}
{ something is waiting to be received from the mpu-401. }

Unit Midi;

{**********************} Interface {**********************}

Type MPU401 = object
     Address : Word; {Data port. Status/Comport 1 higher, standard 330h-331h}
     Silent  : Boolean;              {Silence : Software mute }
     Function  Exists : Boolean;     {Does an MPU-401 device exist here?}
     Function  ByteHere: Boolean;    {Is a byte ready to be received?}
     Function  RecByte : Byte;       {Get byte from MIDI device}
     Procedure SendByte (x:Byte);    {Send byte to MIDI device}
     Procedure SendStr (x : String); {Send string of bytes to MIDI device}
     end;

VAR Synth : MPU401;

{********************} Implementation {*******************}

Function MPU401.Exists : Boolean;
Begin
  Exists := True;
  end;

Function MPU401.ByteHere : Boolean;
Begin
  If (port[Address+1] and $80) = 0 then ByteHere := True {wrong?}
                                  else ByteHere := False;
  end;

Function MPU401.RecByte : Byte;
Begin
  RecByte := Port[Address];
  end;

Procedure MPU401.SendByte (x:Byte);
{Must wait for no data in the buffer}
Begin
  Repeat until (Port[Address+1] and $80) = $80; {wrong?}
  Port[Address] := x;
  end;

Procedure MPU401.SendStr (x : String);
Var t : Byte;
Begin
  For t := 1 to ord(x[0]) do SendByte (ord(x[t]));
  end;

{Initialize}
Begin
  Synth.Address := $300;
  Synth.Silent := False;
  end.

{
This is semi-OOP, so its pretty simple to use.  MIDI uses 1, 2, or 3 byte
commands to send messages.  For any commands you send to the MIDI device,
use SendByte for each byte or send them all in SendStr for convenience.
If you get it working, please respond with the fixed version either
here or Netmail.
}