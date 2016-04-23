unit FM;

{Version 1.0

Copyright 1996 Jack Neely

This unit was written by Jack Neely using Borland's Turbo
Pascal 7.0.  You may contact me for any reason using the
e-mail address hneely@ac.net

This unit takes advantage of the FM sound abilities of the
Adlib/Sound Blaster and compatible sound cards.  All the
procedures below should be self explanatory to those who
know a little of creating FM sound.  Documentation to help
you understand FM sound and that I used in writing this unit
can be found on my Pascal page at

http://www.ac.net/~hneely/pascal/

The rhythm parts of FM sound I do not fully understand.  They
are supported in this unit but un-tested.  Any pointers on how
to uses these would be welcome.  If you find any bugs please
let me know.  Bugs that I can confirm will be corrected
and a new version of this unit will become available.

I ask that you do not change this unit without my permission.
All improvements I want to make so that I can make a new version
of this unit available as I said before.

I would like to give note to Jeffery S. Lee.  Without his
documentation of the OPL2 chip I would not have been able to
write this.  His documentation is available on my Pascal Page.
I would also like to thank R. E. Donais for pointing out my
stupid mistakes and for a bit of wisdom.

I hope you enjoy this unit and that it satisfies your FM
programming needs.  Please contact me and tell me what you
think!

Jack Neely
hneely@ac.net
http://www.ac.net/~hneely/                                   }

interface

const
   {  Note constants.  "s" implies a sharp.  Use for the PITCH parameter
   in the KEY_ON procedure.}
   Cs = $16B; Db = $16B;
   D =  $181;
   Ds = $198; Eb = $198;
   E =  $1B0;
   F =  $1CA;
   Fs = $1E5; Gb = $1E5;
   A =  $241;
   As = $263; Bb = $263;
   B = $287;
   C = $2AE;
   {  Offset array.  Offsets[operator, channel]  This is to be used for
      the offsets in the procedures below.  It calculates the correct
      channel and operator.}
   Offsets : array[1..2, 1..9] of word =
      (($00, $01, $02, $08, $09, $0A, $10, $11, $12),
       ($03, $04, $05, $0B, $0C, $0D, $13, $14, $15));
   {Main IO ports for Adlib/Sound Blaster}
   IOPort = $388;
   IODataPort = $389;

type
   FMregisters = array[1..244] of byte;

var
   IsSound:boolean;             {True if sound card detected else false.}
   FMdata:FMregisters;           {Contains the data in the FM registers.}
      {You cannot set the registers by changing the values in this array
       directly, you must call the apporpiate procedure.  This only stores
       the data curently in the registers sence they are write only.}

procedure Out(p:word; reg:byte; value:byte);
   {Procedure Out sends VALUE to REG (register) using ports P and P + 1}
procedure resetFM;
   {Resets the sound card by writing 0 to all registers.}
procedure setvibrato(offset:word; bit, vd:boolean);
   {Changes the vibrato bit to the value of BIT. If VD is true the vibrato
   is set at 14 cent else 7 cent.  If BIT is false, VD is a dummy.  OFFSET
   controls channel and operator.}
procedure amplitude_modulation(offset:word; bit, AMd:boolean);
   {Applies amplitued modulation when BIT is true.  When AMD is true depth
   is 4.8dB else 1 dB.  If BIT is false AMD is a dummy.  OFFSET controls
   channel and operator.}
procedure setsustain(offset:word; bit:boolean);
   {When BIT is true the sustain level is maintained until released, else
   the sound begins to decay after susatin phase is hit.}
procedure set_harmonic_op(offset:word; value:byte);
   {VALUE controls what harmonic multiple sound (or modulation) will be
   produced.
                      0 - one octave below
                      1 - at the voice's specified frequency
                      2 - one octave above
                      3 - an octave and a fifth above
                      4 - two octaves above
                      5 - two octaves and a major third above
                      6 - two octaves and a fifth above
                      7 - two octaves and a minor seventh above
                      8 - three octaves above
                      9 - three octaves and a major second above
                      A - three octaves and a major third above
                      B -  "       "     "  "   "     "     "
                      C - three octaves and a fifth above
                      D -   "      "     "  "   "     "
                      E - three octaves and a major seventh above
                      F -   "      "     "  "   "      "      "  }
procedure setvolume(offset:word; value:byte);
   {BYTE must be in the range of [0..63] (decimal).  0 is loudest 63
   is softest.}
procedure attackrate(offset:word; value:byte);
   {VALUE must be in rang of [0..F] (hex).  0 is slowest, F is shortest.}
procedure decayrate(offset:word; value:byte);
   {Same as attackrate.}
procedure sustain_level(offset:word; value:byte);
   {VALUE must be in rang of [0..F] (hex). 0 is loudest, F is softest.}
procedure release_rate(offset:word; value:byte);
   {VALUE must be in rang of [0..F] (hex). 0 is slowest, F is fastest.}
procedure waveform(offset:word; value:byte);
   {Changes waveform.  Diagram below.  Numbers are in binary.
         ___              ___            ___    ___       _      _
        /   \            /   \          /   \  /   \     / |    / |
       /_____\_______   /_____\_____   /_____\/_____\   /__|___/__|___
              \     /
               \___/

            00              01               10               11
    }
procedure scalling_rate(offset:word; value:byte);
   {Causes output level to decrease as frequency rises. Numbers are in binary.
                          00   -  no change
                          10   -  1.5 dB/8ve
                          01   -  3 dB/8ve
                          11   -  6 dB/8ve
   }
procedure feedback(channel:word; value:byte);
   {Feedback strength.  Value must be in the range [1..7].  0 is the
   least ad 7 is the greatest.  CHANNLE is the channel affected.}
procedure connection(channel:word; value:boolean);
   {If FALSE operator 1 modulates operator 2, therefore operator 2 is the
   only one producing sound.  If TRUE both operators produce sound
   directly.  Create complex sounds by setting to FALSE.  CHANNEL is the
   channel affected.}
procedure key_on(channel:word; octave:byte; pitch:word);
   {Sounds note.  OCTAVE is [0..7] where 4 contains middle C.  Pitch
   is a note constant defined above.  CHANNEL is the channel to sound
   note on.}
procedure key_off(channel:word);
   {Truns note off.}
procedure rhythm(value:boolean);
   {If VALUE true then rhythm is enabled, else disenabled.  When enabled,
   KEY-ON bits for channels 6 - 8 must be off.  6 melodic voices.  Other
   parameters such as attack/decay/sustain/release must be set appropriately.
   When disenabled, 9 melodic voices.}
procedure bass_drum(value:boolean);
   {Bass drum on/off.}
procedure Snare_drum(value:boolean);
   {Snare on/off}
procedure Tom_tom(value:boolean);
   {Tom tom on/off}
procedure cymbal(value:boolean);
   {Cymbal on/off}
procedure Hi_Hat(value:boolean);
   {Hi hat on/off}

implementation  {Documentation ENDS here.}

PROCEDURE MyDelay(Clocks: Longint);
VAR
   Elapsed: Longint;
   Last, Next, NCopy, Diff: Word;
BEGIN
   Elapsed := 0;
   Port[$43] := 0;
   Last := Port[$40];
   Last := NOT((Port[$40] shl 8) + Last);
   REPEAT
      Port[$43] := 0;
      Next := Port[$40];
      Next := NOT((Port[$40] shl 8) + Next);
      NCopy := Next;
      Dec(Next, Last);
      Inc(Elapsed, Next);
      Last := NCopy;
   UNTIL Elapsed >= Clocks;
END;

procedure out(p:word; reg:byte; value:byte);
begin
   port[p]:= reg;
   mydelay(8);
   port[p+1]:= value;
   mydelay(55);
end;

procedure detect(var sound:boolean);
var
   store1, store2:byte;
begin
   out(IOport, 4, $60);
   out(ioport, 4, $80);
   store1:= port[$388];
   out(ioport, 2, $FF);
   out(ioport, 4, $21);
   mydelay(191);
   store2:= port[$388];
   out(ioport, 4, $60);
   out(ioport, 4, $80);
   sound:= ((store1 and $E0 = 0) and (store2 and $E0 = $C0));
end;

procedure setbit(var b:byte; bit:integer; value:boolean);
var
   c:byte;
begin
   c:= 1;
   if value then
      b:= b or (c shl bit)
   else
      b:= b and not(c shl bit);
end;

procedure resetFM;
var
   i:integer;
begin
   for i:= 1 to 244 do
      begin
         out(IOport, i, 0);
         FMdata[i]:= 0;
      end;
   setbit(FMdata[1], 5, true);
   out(IOport, 1, FMdata[1]);
end;

procedure setvibrato(offset:word; bit, vd:boolean);
begin
   setbit(FMdata[offset+$20], 6, bit);
   setbit(FMdata[$BD], 6, vd);
   out(ioport, offset+$20, FMdata[offset+$20]);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure amplitude_modulation(offset:word; bit, amd:boolean);
begin
   setbit(FMdata[offset+$20], 7, bit);
   setbit(FMdata[$BD], 7, amd);
   out(ioport, offset+$20, FMdata[offset+$20]);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure setsustain(offset:word; bit:boolean);
begin
   setbit(FMdata[offset+$20], 5, bit);
   out(ioport, offset+$20, FMdata[offset+$20]);
end;

procedure set_harmonic_op(offset:word; value:byte);
begin
   FMdata[offset+$20]:= FMdata[offset+$20] and 240;
   FMdata[offset+$20]:= FMdata[offset+$20] + value;
   out(ioport, offset+$20, FMdata[offset+$20]);
end;

procedure setvolume(offset:word; value:byte);
begin
   FMdata[offset+$40]:= FMdata[offset+$40] and 192;
   FMdata[offset+$40]:= FMdata[offset+$40] + value;
   out(ioport, offset+$40, FMdata[offset+$40]);
end;

procedure attackrate(offset:word; value:byte);
var
   temp:byte;
begin
   temp:= FMdata[offset+$60] and 15;
   FMdata[offset+$60]:= (value shl 4) + temp;
   out(ioport, offset+$60, FMdata[offset+$60]);
end;

procedure decayrate(offset:word; value:byte);
begin
   FMdata[offset+$60]:= (FMdata[offset+$60] and 240) + value;
   out(ioport, offset+$60, FMdata[offset+$60]);
end;

procedure sustain_level(offset:word; value:byte);
var
   temp:byte;
begin
   temp:= FMdata[offset+$80] and 15;
   FMdata[offset+$80]:= (value shl 4) + temp;
   out(ioport, offset+$80, FMdata[offset+$80]);
end;

procedure release_rate(offset:word; value:byte);
begin
   FMdata[offset+$80]:= (FMdata[offset+$80] and 240) + value;
   out(ioport, offset+$80, FMdata[offset+$80]);
end;

procedure waveform(offset:word; value:byte);
begin
   FMdata[offset+$E0]:= value;
   out(ioport, offset+$E0, FMdata[offset+$E0]);
end;

procedure scalling_rate(offset:word; value:byte);
var
   temp:byte;
begin
   temp:= FMdata[offset+$40] and 63;
   FMdata[offset+$40]:= (value shl 6) + temp;
   out(ioport, offset+$40, FMdata[offset+$40]);
end;

procedure feedback(channel:word; value:byte);
begin
   channel:= channel - 1;
   FMdata[channel+$C0]:= (FMdata[channel+$C0] and 241) + (value shl 1);
   out(ioport, channel+$C0, FMdata[channel+$C0]);
end;

procedure connection(channel:word; value:boolean);
begin
   channel:= channel - 1;
   setbit(FMdata[channel+$C0], 0, value);
   out(ioport, channel+$C0, FMdata[channel+$C0]);
end;

procedure key_on(channel:word; octave:byte; pitch:word);
var
   highpitch,
   lowpitch:byte;
begin
   lowpitch:= pitch and $00FF;
   highpitch:= (pitch and $FF00) shr 8;
   channel:= channel - 1;
   FMdata[channel+$B0]:= (octave shl 2) + highpitch;
   FMdata[channel+$A0]:= lowpitch;
   setbit(FMdata[channel+$B0], 5, true);
   out(ioport, channel+$A0, FMdata[channel+$A0]);
   out(ioport, channel+$B0, FMdata[channel+$B0]);
end;

procedure key_off(channel:word);
begin
   channel:= channel - 1;
   setbit(FMdata[channel+$B0], 5, false);
   out(ioport, channel+$B0, FMdata[channel+$B0]);
end;

procedure rhythm(value:boolean);
begin
   setbit(FMdata[$BD], 5, value);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure bass_drum(value:boolean);
begin
   setbit(FMdata[$BD], 4, value);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure snare_drum(value:boolean);
begin
   setbit(FMdata[$BD], 3, value);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure Tom_tom(value:boolean);
begin
   setbit(FMdata[$BD], 2, value);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure cymbal(value:boolean);
begin
   setbit(FMdata[$BD], 1, value);
   out(ioport, $BD, FMdata[$BD]);
end;

procedure Hi_hat(value:boolean);
begin
   setbit(FMdata[$BD], 0, value);
   out(ioport, $BD, FMdata[$BD]);
end;

{initialization}
begin
   detect(IsSound);
   if IsSound then
      resetFM;
end.