(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0085.PAS
  Description: SB Compatible Digital Sound Routines
  Author: TAPIO AIJALA
  Date: 09-04-95  10:57
*)

{
Here you are! This piece of code try to show how to play digitized voices
through Sound Blaster. It's from our little SB's Programming Tutorial which
is PD, so be free to distribute it freely!

}
Program SBPlay;

{------------------------------------
 SB compatible digital sound routines

      Copyright Tapio Äijälä 1994.

     Use and distribute freely, but
    please notice me in somewhere on
     your product if you use these
               routines!

                Thanks.
 ------------------------------------}

Uses crt;

Const DmaChannel : Array [0..3,1..3] of Byte =
  (($87,$0,$1),($83,$2,$3),($81,$2,$3),($82,$6,$7));

Var   Reset, ReadData, WriteData, DataAvailable : Word;
      Offset, Page                              : Word;

Function InitSoundSystem(Base : Word) : Byte;

{Check out Sound Blaster from given base address}

Begin
 InitSoundSystem := 1;
 Base := Base * $10;
 Reset := Base + $206;
 ReadData := Base + $20A;
 WriteData := Base + $20C;
 DataAvailable := Base + $20E;
 Port[Reset] := 1;
 Delay(1);
 Port[Reset] := 0;
 Delay(1);
 If (Port[DataAvailable] And $80 = $80) And (Port[ReadData] = $AA) then Begin
  InitSoundSystem := 0;
 End;
End;

Procedure WriteDSP(Data : Byte);

{Write a one byte to DSP.}

Begin
 While Port[WriteData] And $80 <> 0 Do;
 Port[WriteData] := Data;
End;

Function ReadDSP : Byte;

{Read a one byte from DSP.}

Begin
 While Port[DataAvailable] And $80 = 0 Do;
 ReadDSP := Port[ReadData];
End;

Procedure SpeakerOn;

{Send sound to line output.}

Begin
 WriteDSP($D1);
End;

Procedure SpeakerOff;

{Don't send anything to line output. Playing will continue, but you don't
 hear anything!}

Begin
 WriteDSP($D3);
End;

Procedure DMAStop;

{Stop DMA-transfer}

Begin
 WriteDSP($D0);
End;

Procedure DMAContinue;

{Continue DMA-transfer}

Begin
 WriteDSP($D4);
End;

Procedure PlaySample(Sample : Pointer; Size : Word; Freq : Word; DMACh : Byte);

{Play data from pointer sample through SB:

 Size           Size of data block (Max. 64 Kb in one time!)
 Freq           Sampling rate in herts
 DMACh          Number of DMA-channel (0-3)}

Begin
 SpeakerOn;
 Dec(Size);
 Offset := Seg(Sample^) Shl 4 + Ofs(Sample^);
 Page := (Seg(Sample^) + Ofs(Sample^) Shr 4) Shr 12;
 Port[$0A] := $4 + DMACh;
 Port[$0C] := 0; {Clear the internal DMA flip-flop}
 Port[$0B] := $48 + DMACh;
 Port[DMAChannel[1,2]] := Lo(Offset);
 Port[DMAChannel[1,2]] := Hi(Offset);
 Port[DMAChannel[1,1]] := Page;
 Port[DMAChannel[1,3]] := Lo(Size);
 Port[DMAChannel[1,3]] := Hi(Size);
 Port[$0A] := DMACh;
 WriteDSP($40);
 WriteDSP(256 - 1000000 Div Freq);
 WriteDSP($14);
 WriteDSP(Lo(Size));
 WriteDSP(Hi(Size));
End;

Begin
 If InitSoundSystem($2) <> 0 then Writeln('Error in initializing soundcard!');
{Check out for SB in give base address!}
PlaySample(Ptr($B800,0),65535,14000,1); {Plays data from video memory through
SB!}End.
