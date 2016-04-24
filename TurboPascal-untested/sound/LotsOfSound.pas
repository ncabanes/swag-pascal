(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0025.PAS
  Description: Lots of Sound
  Author: DAVID DAHL
  Date: 08-27-93  21:36
*)

{
I've gotten tired of writing these routines and have gone on to other
projects so I don't have time to work on them now.  I figured others may get
some use out of them though.  They're not totally done yet, but what is there
does work (as far as I can tell).  They support playing digitized Sound
(signed or unsigned) at sample rates from 18hz to 44.1khz (at least on my
386sx/25), on the PC Speaker (polled), LPT DACs (1-4) or Adlib FM channels. I
was planning on adding Sound Blaster DAC, Gravis UltraSound, and PC Speaker
(pulse width modulated) support.  I also planned on adding VOC support.  I
may add those at a later date, but no promises.  I'll release any new updates
(if there are any) through the PDN since these routines are a little long
(this will be the ONLY post of these routines in this echo).  I haven't
tested the LPT DAC routines, so could someone who has an LPT DAC please test
them and let me know if they work?  (They SHOULD work, but you never know.)
These routines work For me under Turbo Pascal V6.0 on my 386sx/25.
}

Unit Digital;
(*************************************************************************)
(*                                                                       *)
(*  Programmed by David Dahl                                             *)
(*  This Unit and all routines are PUBLIC DOMAIN.                        *)
(*                                                                       *)
(*  Special thanks to Emil Gilliam For information (and code!) on Adlib  *)
(*  digital output.                                                      *)
(*                                                                       *)
(*  if you use any of these routines in your own Programs, I would       *)
(*  appreciate an acknowledgement in the docs and/or Program... and I'm  *)
(*  sure Mr. Gilliam wouldn't Object to having his name mentioned, too.  *)
(*                                                                       *)
(*************************************************************************)
Interface

Const
  BufSize       = 2048;

Type
  BufferType = Array[1 .. BufSize] of Byte;
  BufPointer = ^BufferType;

  DeviceType = (LPT1, LPT2, LPT3, LPT4, PcSpeaker, PCSpeakPW, Adlib,
                SoundBlaster, UltraSound);

Var
  DonePlaying : Boolean;

Procedure SetOutPutDevice(DeviceName : DeviceType; SignedSamples : Boolean);
Procedure SetPlaySpeed(Speed : LongInt);

Procedure PlayRAWSoundFile(FileName : String; SampleRate : Word);
Function  LoadBuffer(Var F : File; Var BufP : BufPointer) : Word;
Procedure PlayBuffer(BufPtr : BufPointer; Size : Word);

Procedure HaltPlaying;
Procedure CleanUp;

Implementation

Uses
  Crt;

Const
  C8253ModeControl   = $43;
  C8253Channel       : Array [0..2] of Byte = ($40, $41, $42);
  C8253OperatingFreq = 1193180;
  C8259Command       = $20;

  TimerInterrupt     = $08;
  AdlibIndex         = $388;
  AdlibReg           = $389;

Type
  ZeroAndOne = 0..1;

Var
  DataLength  : Word;
  Buffer      : BufPointer;

  LPTAddress  : Word;
  LPTPort     : Array [1 .. 4] of Word Absolute $0040 : $0008;

  OldTimerInterrupt : Pointer;
  InterruptVector   : Array [0..255] of Pointer Absolute $0000 : $0000;

{=[ Misc Procedures ]=====================================================}

{-[ Clear Interrupt Flag (Disable Maskable Interrupts) ]------------------}
Procedure CLI;
Inline($FA);

{-[ Set Interrupt Flag ]--------------------------------------------------}
Procedure STI;
Inline($FB);


{=[ Initialize Sound Devices ]============================================}

{-[ Initialize Adlib FM For Digital Output ]------------------------------}
Procedure InitializeAdlib;
Var
  TempInt : Pointer;

  Procedure Adlib(Reg, Data : Byte); Assembler;
  Asm
    mov  dx, AdlibIndex            { Adlib index port }
    mov  al, Reg

    out  dx,al                     { Set the index }

    { Wait For hardware to respond }
    in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx

    inc  dx                        { Adlib register port }
    mov  al, Data
    out  dx, al                    { Set the register value }

    dec  dx                        { Adlib index port }

    { Wait For hardware to respond }
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx
    in al, dx; in al, dx; in al, dx; in al, dx; in al, dx

  end;

begin
  Adlib($00, $00);    { Set Adlib test Register }
  Adlib($20, $21);    { Operator 0: MULTI=1, AM=VIB=KSR=0, EG=1 }
  Adlib($60, $F0);    { Attack = 15, Decay = 0 }
  Adlib($80, $F0);    { Sustain = 15, Release = 0 }
  Adlib($C0, $01);    { Feedback = 0, Additive Synthesis = 1 }
  Adlib($E0, $00);    { Waveform = Sine Wave }
  Adlib($43, $3F);    { Operator 4: Total Level = 63, Attenuation = 0 }
  Adlib($B0, $01);    { Fnumber = 399 }
  Adlib($A0, $8F);
  Adlib($B0, $2E);    { FNumber = 143, Key-On }

  { Wait For the operator's sine wave to get to top and then stop it there
    That way, we have an operator who's wave is stuck at the top, and we can
    play digitized Sound by changing it's total level (volume) register. }

  Asm
    mov  al, 0                    { Get timer 0 value into DX }
    out  43h, al
    jmp  @Delay1

   @Delay1:
    in   al, 40h
    mov  dl, al
    jmp  @Delay2

   @Delay2:
    in   al, 40h

    mov  dh, al
    sub  dx, 952h                 { Target value }

   @wait_loop:
    mov  al, 0                    { Get timer 0 value into BX }
    out  43h, al
    jmp  @Delay3

   @Delay3:
    in   al, 40h
    mov  bl, al
    jmp  @Delay4

   @Delay4:
    in   al, 40h
    mov  bh, al
    cmp  bx, dx                   { Have we waited that much time yet? }
    ja   @wait_loop               { if no, then go back }

  end;

 { Now that the sine wave is at the top, change its frequency to 0 to keep
   it from moving  }

  Adlib($B0, $20);  { F-Number = 0 }
  Adlib($A0, $00);  { Frequency = 0 }

  Port[AdlibIndex] := $40;
end;

{=[ Sound Device Handlers ]===============================================}
Procedure PlayPCSpeaker; Interrupt;
Const
  Counter : Word = 1;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= DataLength Then
    begin
      Port[$61] := (Port[$61] and 253) OR ((Buffer^[Counter] and 128) SHR 6);
      Inc(Counter);
    end
    else
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interrupts }
end;

Procedure PlayPCSpeakerSigned; Interrupt;
Const
  Counter : Word = 1;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= DataLength Then
    begin
      Port[$61] := (Port[$61] and 253) OR
                   ((Byte(shortint(Buffer^[Counter]) + 128) AND 128) SHR 6);
      Inc(Counter);
    end
    else
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interrupts }
end;

Procedure PlayLPT; Interrupt;
Const
  Counter : Word = 1;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= DataLength Then
    begin
      Port[LPTAddress] := Buffer^[Counter];
      Inc(Counter);
    end
    else
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interupts }
end;

Procedure PlayLPTSigned; Interrupt;
Const
  Counter : Word = 1;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= DataLength Then
    begin
      Port[LPTAddress] := Byte(shortint(Buffer^[Counter]) + 128);
      Inc(Counter);
    end
    else
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interupts }
end;

Procedure PlayAdlib; Interrupt;
Const
  Counter : Word = 1;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= DataLength Then
    begin
      Port[AdlibReg] := (Buffer^[Counter] SHR 2);
      Inc(Counter);
    end
    else
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interupts }
end;

Procedure PlayAdlibSigned; Interrupt;
Const
  Counter : Word = 1;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= DataLength Then
    begin
      Port[AdlibReg] := Byte(shortint(Buffer^[Counter]) + 128) SHR 2;
      Inc(Counter);
    end
    else
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interupts }
end;

{=[ 8253 Timer Programming Routines ]=====================================}
Procedure Set8253Channel(ChannelNumber : Byte; ProgramValue : Word);
begin
  Port[C8253ModeControl] := 54 or (ChannelNumber SHL 6); { XX110110 }
  Port[C8253Channel[ChannelNumber]] := Lo(ProgramValue);
  Port[C8253Channel[ChannelNumber]] := Hi(ProgramValue);
end;

{-[ Set Clock Channel 0 (INT 8, IRQ 0) To Input Speed ]-------------------}
Procedure SetPlaySpeed(Speed : LongInt);
Var
  ProgramValue : Word;
begin
  ProgramValue := C8253OperatingFreq div Speed;
  Set8253Channel(0, ProgramValue);
end;

{-[ Set Clock Channel 0 Back To 18.2 Default Value ]----------------------}
Procedure SetDefaultTimerSpeed;
begin
  Set8253Channel (0, 0);
end;


{=[ File Handling ]=======================================================}

{-[ Load Buffer With Data From Raw File ]---------------------------------}
Function LoadBuffer(Var F : File; Var BufP : BufPointer) : Word;
Var
  NumRead : Word;
begin
  BlockRead(F, BufP^, BufSize, NumRead);
  LoadBuffer := NumRead;
end;


{=[ Sound Playing / Setup Routines ]======================================}

{-[ Output Sound Data In Buffer ]-----------------------------------------}
Procedure PlayBuffer(BufPtr : BufPointer; Size : Word);
begin
  Buffer      := BufPtr;
  DataLength  := Size;
  DonePlaying := False;
end;

{-[ Halt Playing ]--------------------------------------------------------}
Procedure HaltPlaying;
begin
  DonePlaying := True;
end;

{=[ Initialize Data ]=====================================================}
Procedure InitializeData;
Const
  CalledOnce : Boolean = False;
begin
  if Not(CalledOnce) Then
  begin
    DonePlaying       := True;
    OldTimerInterrupt := InterruptVector[TimerInterrupt];
    CalledOnce        := True;
  end;
end;

{=[ Set Interrupt Vectors ]===============================================}

{-[ Set Timer Interrupt Vector To Our Device ]----------------------------}
Procedure SetOutPutDevice(DeviceName : DeviceType; SignedSamples : Boolean);
begin
  CLI;

  Case DeviceName of

    LPT1..LPT4 :
      begin
        LPTAddress := LPTPort[Ord(DeviceName)];
        if SignedSamples Then
          InterruptVector[TimerInterrupt] := @PlayLPTSigned
        else
          InterruptVector[TimerInterrupt] := @PlayLPT;
      end;

    PCSpeaker :
      if SignedSamples Then
        InterruptVector[TimerInterrupt] := @PlayPCSpeakerSigned
      else
        InterruptVector[TimerInterrupt] := @PlayPCSpeaker;

    Adlib :
      begin
        InitializeAdlib;
        if SignedSamples Then
          InterruptVector[TimerInterrupt] := @PlayAdlibSigned
        else
          InterruptVector[TimerInterrupt] := @PlayAdlib;
      end;

    else
      begin
        STI;

        Writeln;
        Writeln ('That Sound Device Is Not Supported In This Version.');
        Writeln ('Using PC Speaker In Polled Mode Instead.');

        CLI;
        if SignedSamples Then
          InterruptVector[TimerInterrupt] := @PlayPCSpeakerSigned
        else
          InterruptVector[TimerInterrupt] := @PlayPCSpeaker;
      end;
  end;
  STI;
end;

{-[ Set Timer Interupt Vector To Default Handler ]------------------------}
Procedure SetTimerInterruptVectorDefault;
begin
  CLI;
  InterruptVector[TimerInterrupt] := OldTimerInterrupt;
  STI;
end;

Procedure PlayRAWSoundFile(FileName : String; SampleRate : Word);
Var
  RawDataFile : File;
  SoundBuffer : Array [ZeroAndOne] of BufPointer;
  BufNum      : ZeroAndOne;
  Size        : Word;
begin
  New(SoundBuffer[0]);
  New(SoundBuffer[1]);

  SetPlaySpeed(SampleRate);

  Assign(RawDataFile, FileName);
  Reset(RawDataFile, 1);

  BufNum := 0;
  Size := LoadBuffer(RawDataFile, SoundBuffer[BufNum]);

  PlayBuffer(SoundBuffer[BufNum], Size);

  While Not(Eof(RawDataFile)) do
  begin
    BufNum := (BufNum + 1) and 1;
    Size   := LoadBuffer(RawDataFile, SoundBuffer[BufNum]);

    Repeat Until DonePlaying;

    PlayBuffer(SoundBuffer[BufNum], Size);
  end;

  Close (RawDataFile);

  Repeat Until DonePlaying;

  SetDefaultTimerSpeed;

  Dispose(SoundBuffer[1]);
  Dispose(SoundBuffer[0]);
end;

{=[ MUST CALL BEFORE ExitING Program!!! ]=================================}
Procedure CleanUp;
begin
  SetDefaultTimerSpeed;
  SetTimerInterruptVectorDefault;
end;

{=[ Set Up ]==============================================================}
begin
  InitializeData;
  NoSound;
end.







Program RAWDigitalOutput;

(*************************************************************************)
(*                                                                       *)
(*  Programmed by David Dahl                                             *)
(*  This Program and all routines are PUBLIC DOMAIN.                     *)
(*                                                                       *)
(*  if you use any of these routines in your own Programs, I would       *)
(*  appreciate an acknowledgement in the docs and/or Program.            *)
(*                                                                       *)
(*************************************************************************)

Uses
  Crt,
  Digital;

Type
  String4  = String[4];
  String35 = String[35];

Const
  MaxDevices = 9;

  DeviceCommand  : Array [1..MaxDevices] of String4 =
    ('-L1', '-L2', '-L3', '-L4',
     '-P' , '-PM', '-A' , '-SB', '-GUS' );

  DeviceName : Array [1..MaxDevices] of String35 =
    ('LPT DAC on LPT1',
     'LPT DAC on LPT2',
     'LPT DAC on LPT3',
     'LPT DAC on LPT4',
     'PC Speaker (Polled Mode)',
     'PC Speaker (Pulse Width Modulated)',
     'Adlib / SoundBlaster FM',
     'SoundBlaster DAC',
     'Gravis UltraSound');

  SignedUnsigned  : Array [False .. True] of String35 =
    ('Unsigned Sample', 'Signed Sample');


{-[ Return An All Capaitalized String ]-----------------------------------}
Function UpString(StringIn : String) : String;
Var
  TempString : String;
  Counter    : Byte;
begin
  TempString := '';
  For Counter := 1 to Length (StringIn) do
    TempString := TempString + UpCase(StringIn[Counter]);

  UpString := TempString;
end;

{-[ Check if File Exists ]------------------------------------------------}
Function FileExists(FileName : String) : Boolean;
Var
  F : File;
begin
  {$I-}
  Assign (F, FileName);
  Reset(F);
  Close(F);
  {$I+}
  FileExists := (IOResult = 0) And (FileName <> '');
end;

{=[ Comand Line Parameter Decode ]========================================}
Function FindOutPutDevice : DeviceType;
Var
  Counter       : Byte;
  DeviceCounter : Byte;
  Found         : Boolean;
  Device        : DeviceType;
begin
  Counter := 1;
  Found   := False;
  Device  := PcSpeaker;

  While (Counter <= ParamCount) and Not(Found) do
  begin
    For DeviceCounter := 1 To MaxDevices do
      if UpString(ParamStr(Counter)) = DeviceCommand[DeviceCounter] Then
      begin
        Device := DeviceType(DeviceCounter - 1);
        Found  := True;
      end;

    Inc(Counter);
  end;

  FindOutPutDevice := Device;
end;

Function FindRawFileName : String;
Var
  FileNameFound : String;
  TempName      : String;
  Found         : Boolean;
  Counter       : Byte;
begin
  FileNameFound   := '';
  Counter := 1;
  Found   := False;

  While (Counter <= ParamCount) and Not(Found) do
  begin
    TempName := UpString(ParamStr(Counter));
    if TempName[1] <> '-' Then
    begin
      FileNameFound := TempName;
      Found         := True;
    end;
    Inc (Counter);
  end;

  FindRawFileName := FileNameFound;
end;

Function FindPlayBackRate : Word;
Var
  RateString : String;
  Rate       : Word;
  Found      : Boolean;
  Counter    : Byte;
  ErrorCode  : Integer;
begin
  Rate := 22000;
  Counter := 1;
  Found   := False;

  While (Counter <= ParamCount) and Not(Found) do
  begin
    RateString := UpString(ParamStr(Counter));
    if Copy(RateString,1,2) = '-F' Then
    begin
      RateString := Copy(RateString, 3, Length(RateString) - 2);
      Val(RateString, Rate, ErrorCode);
      if ErrorCode <> 0 Then
      begin
        Rate := 22000;
        Writeln ('Error In Frequency. Using Default');
      end;
      Found := True;
    end;
    Inc (Counter);
  end;

  if Rate < 18 Then
    Rate := 18
  else
  if Rate > 44100 Then
    Rate := 44100;

  FindPlayBackRate := Rate;
end;

Function SignedSample : Boolean;
Var
  Found   : Boolean;
  Counter : Word;
begin
  SignedSample := False;
  Found   := False;
  Counter := 1;

  While (Counter <= ParamCount) and Not(Found) do
  begin
    if UpString(ParamStr(Counter)) = '-S' Then
    begin
      SignedSample := True;
      Found        := True;
    end;

    Inc(Counter);
  end;
end;

{=[ Main Program ]========================================================}
Var
  SampleName : String;
  SampleRate : Word;
  OutDevice  : DeviceType;
begin
  Writeln;
  Writeln('RAW Sound File Player V0.07');
  Writeln('Programmed By David Dahl');
  Writeln('Thanks to Emil Gilliam For Adlib digital output information');
  Writeln('This Program is PUBLIC DOMAIN');

  if ParamCount <> 0 Then
  begin
    SampleRate := FindPlayBackRate;
    SampleName := FindRawFileName;
    OutDevice  := FindOutPutDevice;
    Writeln;

    if SampleName <> '' Then
    begin
      Writeln('Raw File   : ',SampleName);
      Writeln('Format     : ',SignedUnsigned[SignedSample]);
      Writeln('Sample Rate: ',SampleRate);
      Writeln('Device     : ',DeviceName[Ord(OutDevice)+1]);

      if FileExists(SampleName) Then
      begin
        SetOutputDevice(OutDevice, SignedSample);
        PlayRAWSoundFile(SampleName, SampleRate);
      end
      else
        Writeln('Sound File Not Found.');
    end
    else
      Writeln('Filename Not Specified.');
  end
  else
  begin
    Writeln;
    Writeln('USAGE:');
    Writeln(ParamStr(0),' [SWITCHES] <RAW DATA File>');
    Writeln;
    Writeln('SWITCHES:');
    Writeln(' -P      PC Speaker, Polled (Default)');
    Writeln(' -L1     LPT DAC on LPT 1');
    Writeln(' -L2     LPT DAC on LPT 2');
    Writeln(' -L3     LPT DAC on LPT 3');
    Writeln(' -L4     LPT DAC on LPT 4');
    Writeln(' -A      Adlib/Sound Blaster FM');
    Writeln;
    Writeln(' -S      Signed Sample (Unsigned Default)');
    Writeln;
    Writeln(' -FXXXXX Frequency Of Sample. XXXXX can be any Integer ',
             'between 18 to 44100');
    Writeln ('         (22000 Default)');
  end;

  CleanUp;
end.



