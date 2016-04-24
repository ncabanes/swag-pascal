(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0103.PAS
  Description: Dialing phone using soundcard
  Author: JES RAHBEK KLINKE
  Date: 08-30-96  09:35
*)


program SBDial;

{ This program demonstrates how to use an Adlib or SoundBlaster card
  for automatically dialing a phone number. You just have to hold the
  microphone close to the speakers and run the program. If you have
  implemented your own address list you no longer have to read the
  phone number from the screen and dial it on the phone. }

{ This program was written by Jes R. Klinke, if you include it in your
  own creations a credit would be nice. }

uses
  Crt;

const
  NoteLength   = 100;  { Length of each note in ms }
  NoteDelay    = 50;   { Delay between two notes }
  LongDelay    = 1000; { Long delay between two notes indicated by
                         a hyphen in number }

{ Constants for MiscFlags }

  mfAmpMod     = $80; { Amplitude modulation }
  mfVibrato    = $40;
  mfShortNote  = $20; { No sustain, jump directly from decay to release }
  mfShorten    = $10; { Shorten the note as its pitch rises }

{ Constants for ScalingLevel }
{ Causes output levels to decrease as the frequency rises }

  slNo         = $00; { no change }
  sl15db       = $40; { 1,5 db per octave }
  sl3db        = $80; { 3 db per octave }
  sl6db        = $C0; { 6 db per octave }

{ Sets specified FM register }
procedure SetSBReg(Address, Value: Byte); assembler;
asm
    MOV    DX,0388h
    MOV    AL,Address
    OUT    DX,AL
    MOV    CX,6
@@0:IN AL,DX
    LOOP   @@0
    INC    DX
    MOV    AL,Value
    OUT    DX,AL
    DEC    DX
    MOV    CX,35
@@1:IN AL,DX
    LOOP   @@1
end;

{ Reads then FM status register }
function GetSBStatus: Byte; assembler;
asm
    MOV    DX,0388h
    IN     AL,DX
end;

{ Resets the FM chips }
procedure ResetSB;
var
  Adr: Byte;
begin
  for Adr := 0 to $F5 do
    SetSBReg(Adr, 0);
end;

{ Calculates offset of the control byte for the given channel and operator }
function OperatorOffset(Channel, Operator: Byte): Byte;
begin
  OperatorOffset := Operator * 3 + Channel mod 3 + (Channel div 3) * 8;
end;

{ Sets miscellaneous flags and parameters }
procedure SetMiscParam(Channel, Operator, MiscFlag, FreqvFaktor: Byte);
begin
  SetSBReg($20 + OperatorOffset(Channel, Operator), MiscFlag or FreqvFaktor);
end;

{ Sets volume and scaling level }
procedure SetVolume(Channel, Operator, ScalingLevel, Volume: Byte);
begin
  SetSBReg($40 + OperatorOffset(Channel, Operator), ScalingLevel or Volume);
end;

{ Sets attack, decay, sustain and release rates }
procedure SetADSR(Channel, Operator, Attack, Decay, Sustain, Release: Byte);
begin
  SetSBReg($60 + OperatorOffset(Channel, Operator), Attack shl 4 or Decay);
  SetSBReg($80 + OperatorOffset(Channel, Operator), Sustain shl 4 or Release);
end;

{ Sets feedback 0..7, 0 being no feedback, 7 the most }
{ Also sets whether operator 0 modulates operator 2 or
  they produce sound individually }
procedure SetFeedback(Channel, Feedback: Byte; Separate: Boolean);
begin
  SetSBReg($C0 + Channel, Feedback shl 1 or Byte(Separate));
end;

{ Starts playing the note given by Octave and Freq }
procedure PlayNote(Channel, Octave: Byte; Freq: Word);
begin
  SetSBReg($A0 + Channel, Lo(Freq));
  SetSBReg($B0 + Channel, $20 or Octave shl 2 or Hi(Freq) and 3);
end;

{ Stops playing }
procedure StopNote(Channel, Octave: Byte; Freq: Word);
begin
  SetSBReg($A0 + Channel, Lo(Freq));
  SetSBReg($B0 + Channel, Octave shl 2 or Hi(Freq) and 3);
end;

{ Detect if FM-chips i present }
function DetectSB: Boolean;
var
  Result1, Result2: Byte;
begin
  SetSBReg($4, $60);
  SetSBReg($4, $80);
  Result1 := GetSBStatus;
  SetSBReg($2, $FF);
  SetSBReg($4, $21);
  Delay (10);
  Result2 := GetSBStatus;
  DetectSB := ((Result1 and $E0) = 0) and ((Result2 and $E0) = $C0);
end;

{ Dials the specified phone number }
procedure Dial(const No: string);
const
{ Frequency combinations for the keys on a phone }
  Tone: array [0..11, 0..1] of Byte = (
    (3, 1),
    (0, 0),
    (0, 1),
    (0, 2),
    (1, 0),
    (1, 1),
    (1, 2),
    (2, 0),
    (2, 1),
    (2, 2),
    (3, 0),
    (3, 2));
{ Low frequency of the pair }
  LoFreq: array [0..3] of
    record
      O: Byte;
      F: Word;
    end = (
    (O: 5; F: 457),
    (O: 5; F: 505),
    (O: 5; F: 558),
    (O: 5; F: 617));
{ High frequency of the pair }
  HiFreq: array [0..2] of
    record
      O: Byte;
      F: Word;
    end = (
    (O: 6; F: 396),
    (O: 6; F: 438),
    (O: 6; F: 484));
var
  I, ToneNo: Integer;
begin
  SetMiscParam(0, 0, 0, 1);
  SetVolume(0, 0, 0, 8);
  SetADSR(0, 0, 15, 1, 7, 15);
  SetFeedBack(0, 0, True);
  SetMiscParam(1, 0, 0, 1);
  SetVolume(1, 0, 0, 8);
  SetADSR(1, 0, 15, 1, 7, 15);
  SetFeedBack(1, 0, True);
  SetMiscParam(0, 1, 0, 1);
  SetVolume(0, 1, 0, 8);
  SetADSR(0, 1, 15, 1, 7, 15);
  SetMiscParam(1, 1, 0, 1);
  SetVolume(1, 1, 0, 8);
  SetADSR(1, 1, 15, 1, 7, 15);
  for I := 1 to Length(No) do
  begin
    if No[I] in ['0'..'9', '*', '#'] then
    begin
      { Determine the number of the key }
      if No[I] = '*' then
        ToneNo := 10
      else if No[I] = '#' then
        ToneNo := 11
      else
        ToneNo := Byte(No[I]) - Byte('0');
      { Play the two frequencies in channel 0 and 1}
      PlayNote(0, LoFreq[Tone[ToneNo, 0]].O, LoFreq[Tone[ToneNo, 0]].F);
      PlayNote(1, HiFreq[Tone[ToneNo, 1]].O, HiFreq[Tone[ToneNo, 1]].F);
      Delay(NoteLength);
      { The contral ought to have had enough time to recognize the keypress }
      StopNote(0, LoFreq[Tone[ToneNo, 0]].O, LoFreq[Tone[ToneNo, 0]].F);
      StopNote(1, HiFreq[Tone[ToneNo, 1]].O, HiFreq[Tone[ToneNo, 1]].F);
      Delay(NoteDelay);
    end;
    { a hyphen in the number indicates a longer delay between the keypresses }
    if No[I] = '-' then
      Delay(LongDelay);
  end;
end;

begin
  if not DetectSB then
  begin
    WriteLn('This program requires an Adlib or compatible soundcard');
    Halt;
  end;
  Dial('875 8133');
end.



