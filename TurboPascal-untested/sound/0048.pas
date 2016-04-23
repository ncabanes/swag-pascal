{
  I got FM-synth code for the PAS (originally for the SB).  Here it is:
}
Program fmtest;
uses
  sbfm, crt;
const
  instrument: TFMInstrument = (SoundCharacteristic: ($11, $1);
                               Level: ($8A, $40);
                               AttackDecay: ($F0, $F0);
                               SustainRelease: ($FF, $B3);
                               WaveSelect: ($01, $00);
                               FeedBack: $00;
                               Filler: ($06, $00, $00, $00, $00, $00));
  notes: array[0..12] of integer = ($157, $16B, $181, $198, $1B0, $1C1, $1E5,
        $202, $220, $241, $263, $287, $2AE);
begin
  SbFMReset;
  SbFMSetVoice(0,@instrument);
  SbFMSetVoice(1,@instrument);
  SbFMSetVoice(11,@instrument);
  SbFMSetVoice(12,@instrument);

  SbFMKeyOn(0,notes[0],2);
  delay(250);
  SbFMKeyOn(1,notes[4],3);
  delay(250);
  SbFMKeyOn(1,notes[7],3);
  delay(250);
  SbFMKeyOn(1,notes[12],3);
  delay(1000);

  sbFMKeyOff(0);
  sbFMKeyOff(1);
  sbFMKeyOff(11);
  sbFMKeyOff(12);
  sbFMReset;
end.

Unit SbFM;
interface
type
  PFMInstrument = ^TFMInstrument;
  TFMInstrument = record
                    SoundCharacteristic:array[0..1] of byte;
                    Level:              array[0..1] of byte;
                    AttackDecay:        array[0..1] of byte;
                    SustainRelease:     array[0..1] of byte;
                    WaveSelect:         array[0..1] of byte;
                    Feedback:           byte;
                    filler:             array[0..5] of byte;
                  end;
const
  SbIOAddr=$220;
  LeftFmAddress=0;
  RightFmAddress=2;
  FMADDRESS=$08;
Procedure WriteFM(chip, addr, data: byte);
Procedure SbFmReset;
Procedure SbFMKeyOff(voice: integer);
Procedure SbFMKeyOn(voice, freq, octave: integer);
Procedure SbFMVoiceVolume(voice, vol: integer);
procedure sbFMSetVoice(voicenum: integer; Ins: PFMInstrument);
implementation
Procedure WriteFM(chip, addr, data: byte);
var
  ChipAddr:                                integer;
  t:                                        byte;
begin
  if chip>0 then chipaddr:=SbIOAddr + RightFMAddress else
               chipaddr:=sbIOAddr + LeftFMAddress;
  chipaddr:=SbIOAddr + FMAddress;
  asm
    push dx
    push ax
    push cx
    mov dx,chipaddr
    mov al,addr
    out dx,al
    in al,dx
    inc dx
    mov al,data
    out dx,al
    dec dx
    mov cx,4
@L:
    in al,dx
    loop @L
    pop cx
    pop ax
    pop dx
  end;
end;
Procedure SbFmReset;
Begin
  WriteFM(0, 1, 0);
  WriteFM(1, 1, 0);
end;
Procedure SbFMKeyOff(voice: integer);
var
  regnum:                                byte;
  chip:                                        integer;
begin
  chip:=voice div 11;
  regnum:=$B0 + (voice mod 11);
  WriteFM(chip, regnum, 0);
end;
Procedure SbFMKeyOn(voice, freq, octave: integer);
var
  regnum, t:                                byte;
  chip:                                        integer;
begin
  chip:=voice div 11;
  regnum:=$A0 + (voice mod 11);
  WriteFM(chip, regnum, freq and $FF);
  regnum:=$B0 + (voice mod 11);
  t:=(freq shr 8) or (octave shl 2) or $20;
  WriteFM(chip, regnum, t);
end;
Procedure SbFMVoiceVolume(voice, vol: integer);
var
  regnum:                                byte;
  chip:                                        integer;
begin
  chip:=voice div 11;
  regnum:=$40 + (voice mod 11);
  WriteFM(chip, regnum, vol);
end;
procedure sbFMSetVoice(voicenum: integer; Ins: PFMInstrument);
var
  opcellnum:                                byte;
  celloffset, i, chip:                        integer;
begin
  chip:=voicenum div 11;
  voicenum:=voicenum mod 11;
  celloffset:=(voicenum mod 3) + ((voicenum div 3) shr 3);
  opcellnum:=$20 + celloffset;
  WriteFM(chip, opcellnum, ins^.SoundCharacteristic[0]);
  inc(opcellnum, 3);
  WriteFM(chip, opcellnum, ins^.SoundCharacteristic[1]);
  opcellnum:=$40 + celloffset;
  WriteFM(chip, opcellnum, ins^.level[0]);
  inc(opcellnum, 3);
  WriteFM(chip, opcellnum, ins^.Level[1]);
  opcellnum:=$60 + celloffset;
  WriteFM(chip, opcellnum, ins^.AttackDecay[0]);
  inc(opcellnum, 3);
  WriteFM(chip, opcellnum, ins^.AttackDecay[1]);
  opcellnum:=$80 + celloffset;
  WriteFM(chip, opcellnum, ins^.SustainRelease[0]);
  inc(opcellnum, 3);
  WriteFM(chip, opcellnum, ins^.SustainRelease[1]);
  opcellnum:=$E0 + celloffset;
  WriteFM(chip, opcellnum, ins^.WaveSelect[0]);
  inc(opcellnum, 3);
  WriteFM(chip, opcellnum, ins^.WaveSelect[1]);
  opcellnum:=$C0 + voicenum;
  WriteFM(chip, opcellnum, ins^.feedback);
end;
end.

{
Message 1 is FMTEST.PAS
Messages 2+3 are SBFM.PAS
That's all.  One thing: if you can make this work with more than two
voices at a time, I'd be interested in improved code.  I think that this
code uses the AdLib compatibility, which is by no means impressive :-).
}
