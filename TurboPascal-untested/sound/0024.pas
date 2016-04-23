{

 SoundS.INC  5-27-93  by Steven Tallent

This is a Unit to play 8-bit raw Sound Files on any PC, up to 64k
large.  It supports the PC speaker or a DAC (LPT1 or LPT2), although
I do plan to upgrade it to support the SoundBlaster and Adlib Sound
cards.  It is Object-oriented in nature, With one instance of a
speaker defined automatically.  This Unit is public domain, With
code and ideas captured from this echo and Dr. Dobbs Journal.

Using the code is simple.  Just setup the the Speaker.Kind,
Speaker.Silent, and Speaker.DisINT to the appropriate values, then
just use the methods included.  The SoundBoard Object is very
flexible For your own code.

SoundBoard.Play  - Plays 8-bit music in What^ For Size length, With
                   Speed milliseconds between each Byte, and SampleRate
                   as the sample rate (in Hz).  Speed will need to be
                   changed on different computers (of course).

SoundBoard.Sound - Plays a Sound at HZ Hertz, Duration in ms, on
                   VOICE voice.  The code included is useable on
                   the PC speaker (1 voice) or the Tandy speaker
                   (3 voices!).

SoundBoard.Reset - Resets the Sound board.

SoundBoard.Silent- Convenient Variable that disables all PLAY and Sound
                   if set to True.

SoundBoard.DisINT- Disables all interrupts (except during Delays)
                   While using PLAY.

This code may be freely distributed, changed, or included in your
own commercial or shareware code, as long as this isn't all your code
does.  This code may be included in commercial or shareware code
libraries only With my permission (I'd like to see someone get some
use out of it).
}

Unit Sounds;

Interface

Type
  BigArray    = Array[0..0] of Byte;
  PBigArray   = ^BigArray;
  KSoundBoard = (PCspeaker, Tandy, DAC1, DAC2, AdLib, SB, SBpro, SB16);

  SoundBoard  = Object
    Kind   : KSoundBoard;
    Silent : Boolean;
    DisINT : Boolean;
    Procedure Play(What : PBigArray; Size : Word; Speed : Byte;
                    SampleRate : Word);
    Procedure Sound(Hz, Duration : Word; Voice, Volume : Byte);
    Procedure Reset;
  end;

Var
  Speaker : SoundBoard;

Procedure Delay(ms : Word);

Implementation

Procedure SoundBoard.Reset;
begin
  Case Kind of
    PCspeaker, Tandy : Port[97] := Port[97] and $FC;
  end;
  end;

Procedure SoundBoard.Sound(Hz, Duration : Word; Voice, Volume : Byte);
Var
  Count   : Word;
  SendByte,
  VoiceID : Byte;
begin
  Case Kind of
    PCspeaker :
      begin
        Count := 1193180 div Hz;
        Port[97] := Port[97] or 3;
        Port[67] := 182;
        Port[66] := Lo(Count);
        Port[66] := Hi(Count);
        Delay(Duration);
        Port[97] := Port[97] and $FC;
      end;
    Tandy :
      begin
        if Voice = 1 then
          VoiceId := 0
        else
        if Voice = 2 then
          VoiceId := 32
        else
          VoiceId := 64;
        Count := 111861 div Hz;
        SendByte := 128 + VoiceId + (Count mod 16);
        Port [$61] := $68;
        Port [$C0] := SendByte;
        Port [$C0] := Count div 16;
        if Voice = 1 then
          VoiceId := 16
        else
        if Voice = 2 then
          VoiceId := 48
        else
          VoiceId := 96;
        SendByte := 128 + VoiceId + (15 - Volume);
        Port [$61] := $68;
        Port [$C0] := SendByte;
        Delay(Duration);
        SendByte := 128 + VoiceId + 15;
        Port [$61] := $68;
        Port [$C0] := SendByte;
    DAC1:;
    DAC2:;
    AdLib:;
    SB:;
    SBPro:;
    SB16:;
  end;

Procedure SoundBoard.Play(What : PBigArray; Size : Word;
                          Speed : Byte; SampleRate : Word);
Var
  Loop,
  Count,
  Data  : Word;
begin
  if not Silent then
  begin
    Case Kind of
      PCspeaker, Tandy :
        begin
          Port[97] := Port[97] or 3;
          Count := 1193180 div (SampleRate div 256);
          For Loop := 1 to Size do
          begin
            Data := Count div (What^[Loop] + 1);
            Port[67] := 182;
            Port[66] := Lo(Data);
            Port[66] := Hi(Data);
            Delay(Speed);
            if DisINT then
            Asm
              CLI
            end;
          end;
          Port[97] := Port[97] and $FC;
        end;

        DAC1:
          For Loop := 1 to Size do
          begin
            Port [$0378] := What^[Loop];
            Delay (Speed);
            if DisINT then
            Asm
              CLI
            end;
          end;

        DAC2:
          For Loop := 1 to Size do
          begin
            Port [$0278] := What^[Loop];
            Delay (Speed);
            if DisINT then
            Asm
              CLI
            end;
          end;

        AdLib:;
        SB:;
        SBPro:;
        SB16:;
      end;
      Asm
        STI
      end;
  end;
end;

Procedure Delay(ms : Word); Assembler;
Asm
  STI
  MOV AH, $86
  MOV CX, 0
  MOV DX, [ms]
  INT $15
end;

end.

{-----------------------------------------------------------------
Here's a Program that will accept three values from the command
line, the File, its speed, and the sample rate, and plays it
through the PC speaker.  I've tried in on WAV, VOC, SAM, and even
Amiga sampled Files, With no problems (limited to 64k). I've even
played MOD Files to hear all the sampled instruments!  This Program
does not strip header information, but plays it too, but I can't
hear the difference on WAV and VOC Files.
}
Program TestSnd;
Uses
  Sounds;
Var
  I2   : PBigArray;
  spd  : Integer;
  samp : Word;
  res  : Word;
  siz  : Word;
  s    : String;
  f1   : File of Byte;
  F    : File;
begin
  Speaker.Kind   := PCspeaker;
  Speaker.DisINT := True;
  Speaker.Silent := False;
  s := ParamStr(1);
  Assign(f1,s);  {Get size of File}
  Reset(f1);
  Val (ParamStr(2), Spd, Res);
  Val (ParamStr(3), samp, Res);
  siz := FileSize(f1);
  close(f1);
  Assign(f,s);
  Reset(f);
  getmem (I2,siz);  {Allocate Memory For Sound File}
  BlockRead(f,I2^,siz,res);  {Load Sound into Memory}
  Speaker.Play (i2, siz, spd, samp);
  FreeMem (I2, siz);
end.
