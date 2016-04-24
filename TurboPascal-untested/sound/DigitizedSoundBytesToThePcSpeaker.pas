(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0074.PAS
  Description: Digitized Sound Bytes to the PC Speaker
  Author: DON URQUHART
  Date: 05-26-95  23:28
*)

{
Hello.  I am developing a text-to-speech synthesizer for IBM-
compatible computers.  The system will support sound output
through the SoundBlaster-DAC, an LPT-port DAC, or the PC speaker
if no other device is available.  One of its goals is to provide
an _INEXPENSIVE_ speech option for visually-impaired computer
users.

Could someone please examine the following code and make
comments/suggestions on it?  It takes an eight-bit sample byte
and outputs it on the speaker.  The speaker I/O port address is
configurable, for the internal squeaker or an external speaker
device on a serial or parallel port.
}
Procedure Play_Eight_Bits (SoundByte, BitShift  : Byte;
Spkr  : Word);  Assembler;
CONST
   OffMask = 253;
   DataMask = 128;
 
ASM
   Push     AX
   Push     BX
   Push     CX
   Push     DX
   MOV     AH, SoundByte
   MOV     BL, BitCount
   MOV     CL, BitShift
   MOV     DX, Spkr     (* Speaker I/O port address *)
   And     AH, DataMask
 
   @SpeakerPoll:  In     AL, DX     (* Input from speaker port *)
   And     AL, OffMask
   Or     AL, AH     (* Set up byte to output *)
   Out     DX, AL     (* Send to speaker *)
   SHR     AH, CL     (* Position next bit *)
   SUB     BL, CL     (* Are we done with this byte? *)
   JNz     @SpeakerPoll     (* No, poll speaker again *)
   Pop     DX
   Pop     CX
   Pop     BX
   Pop     AX
End;     (* Play_Eight_Bits *)
{--------
Here's a straight Pascal way of polling the speaker and sending a
byte:
}
Procedure Play_Eight_Bits (SoundByte  : Byte;  Spkr  : Word);
CONST
   OffMask = 253;
   DataMask = 128;

Begin
   Port[Spkr] := (Port[Spkr] and OffMask)
   Or ((SoundByte and DataMask) shr 6);
   (* I am not sure why 6 is the magic number to shift by. *)
End;     (* Play_Eight_Bits *)
{
Using the assembler procedure, I have achieved _TWO_ volume
levels through the speaker: the first barely audible, the second
quite adequate (at least on my speaker).  A BitShift value of 1
results in the very low volume, and a shift value of 2 produces
the higher volume; anything higher produces either silence or
unintelligible squeaks.

Are there more effective [i.e] higher sound quality, methods of
playing eight-bit samples on the speaker, short of using the
driver built into Windows?  I've developed my playback routines
on my 286 under DOS 5.  Being blind, I cannot use the GUI
environment of windows with my text-based screen reader software,
so I plan to keep working on my synthesizer project under DOS,
until I can invest in a 486 machine.

I would greatly appreciate any hints/suggestions concerning the
above-listed playback procedure.  Thanks in advance.
}

