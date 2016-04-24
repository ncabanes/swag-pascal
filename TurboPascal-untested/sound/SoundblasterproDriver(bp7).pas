(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0101.PAS
  Description: Soundblaster-pro driver (BP7)
  Author: MENNO VICTOR VAN DER STAR
  Date: 11-29-96  08:17
*)

Unit Audio;
{----------------------------------------------------------------------------}
{  Audio : An implementation of a Soundblaster-pro driver (BP 7.0). The      }
{          Soundblaster-Pro object features record and playback using DMA    }
{          so your CPU can do something else while sound is being played     }
{          or recorded. Both Real and Protected Mode are supported.          }
{          This code has only been tested on a Soundblaster-Pro clone with   }
{          BasePort=$220, Irq=7 and DMAchannel=1.                            }
{          Do what ever you like with this code, but use it at your own      }
{          risk!!!!!                                                         }
{          Comments and/or bug fixes are welcome at the e-mail address below }
{****************************************************************************}
{  Author            : Menno Victor van der star                             }
{  E-mail            : s795238@dutiwy.twi.tudelft.nl                         }
{  Developed on      : 08-02-'95                                             }
{  Last update on    : 13-06-'95                                             }
{  Status            : Working, but only tested on a SB-pro clone with       }
{                      Baseport=$220, Irq=7 and DMAChannel=1                 }
{  Future extensions : - Direct input/output filter for playing .WAV/.VOC's  }
{                      - Extensive testing (Feedback appreciated :)          }
{----------------------------------------------------------------------------}
Interface

{$IFDEF DPMI} Uses WinAPI; {$ENDIF}

Const
{-- Constants for soundblaster-pro object --}

  Stereo = True;         { Stereo/Mono constants }
  Mono   = False;

  Master     = 0;        { Volume/Input devices }
  Microphone = 1;
  CDAudio    = 2;
  LineIn     = 3;
  Voice      = 4;
  FM         = 5;

  Left         = 0;      { Indications for left, right or both channels }
  Right        = 1;
  LeftAndRight = 2;

  HighPass = 0;          { Bandpass filter constants }
  LowPass  = 1;

Type
  PSoundBlasterPro = ^SoundBlasterPro;
  SoundBlasterPro = Object

                      Constructor Init (Port, IRQ, DMA : Word);
                      Destructor  Done; Virtual;

                      { The following 4 virtual procedures have to be redefined via inheritance :
                        - OutBuffer : Write 'Size' recorded bytes from 'Buffer'
                        - InBuffer : Read 'Size' bytes to be played back from 'Buffer'
                        - RecordingReady : This procedure is called after the recording is done
                        - PlaybackReady : This procedure is called after the sound has been played }

                      Procedure   OutBuffer (Var Buffer; Size : Word); Virtual;
                      Procedure   InBuffer  (Var Buffer; Size : Word); Virtual;
                      Procedure   RecordingReady; Virtual;
                      Procedure   PlaybackReady; Virtual;

                      Function    Reset : Boolean;
                      Procedure   PlaySample   (SampleRate : Word; Length : LongInt);
                      Procedure   RecordSample (SampleRate : Word; Length : LongInt);

                      Procedure   SetStereoIn;
                      Procedure   SetMonoIn;
                      Function    InputMode : Boolean;

                      Procedure   SetVolume (VolumeType, Channel, Volume : Byte);
                      Function    GetVolume (VolumeType, Channel : Byte) : Byte;
                      Procedure   SetInput (InputDevice, Filter : Byte; FilterOn : Boolean);
                      Procedure   GetInput (Var InputDevice, Filter : Byte; Var FilterOn : Boolean);
                      Procedure   SetOutput (StereoOut, FilterOutput : Boolean);
                      Procedure   GetOutput (Var StereoOut, FilterOutput : Boolean);

                      Procedure   HandleRecordIrq;
                      Procedure   HandlePlaybackIrq;

                    Private

                      DMAChannel, IrqVector, IrqIntVector, SBPort, PICPort,
                      ResetPort, ReadPort, WritePort, PollPort, MixerIndexPort,
                      MixerWritePort : Word;
                      OldIntVector, DMABuffer1, DMABuffer2, SoundBuffer1, SoundBuffer2 : Pointer;
                      IRQStopMask, IRQStartMask, DMAStartMask, DMAStopMask,
                      DMAModeReg : Byte;

                      StereoMode : Boolean;
                      CurrentPlay, CurrentRecord : Pointer;
                      PlayLength, RecordLength : LongInt;
                      RecSampleSize, RecSampleRate, PlaySampleRate, PlaySampleSize : Word;

                      Procedure WriteMixer (Index, Value : Byte);
                      Function  ReadMixer (Index : Byte) : Byte;
                      Procedure WriteDSP (Value : Byte);
                      Function  ReadDSP : Byte;
                      Procedure PlayBuffer (Buffer : Pointer; SampleRate : Word; Size : Word);
                      Procedure RecBuffer  (Buffer : Pointer; SampleRate : Word; Size : Word);
                      Procedure EnableInterrupts;
                      Procedure DisableInterrupts;
                      Procedure DisableIrq;
                      Procedure EnableIrq;

                    End;

Implementation

Uses Crt, Dos;

Const
  Module_ID = 'AUDIO';
  SBPro : PSoundBlasterPro = NIL;         { Pointer to current soundblaster-pro object }

Procedure RecordIRQ; Interrupt;

Var
  Dummy : Byte;

Begin
  Dummy:=Port [$22E];        { Maybe the value $22E should be replaced with the appropriate value }
                             { if a port other than $220 is used (I can't remember (anyone?)) }
  If Assigned (SBPro) then SBPro^.HandleRecordIrq;
  Port [$20]:=$20;
End;

Procedure PlayIRQ; Interrupt;

Var
  Dummy : Byte;

Begin
  Dummy:=Port [$22E];        { Maybe the value $22E should be replaced with the appropriate value }
                             { if a port other than $220 is used (I can't remember (anyone?)) }
  If Assigned (SBPro) then SBPro^.HandlePlaybackIrq;
  Port [$20]:=$20;
End;

Constructor SoundBlasterPro.Init (Port, IRQ, DMA : Word);

Const
  IrqIntNums : Array [0..15] Of Byte = ($08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
                                        $70, $71, $72, $73, $74, $75, $76, $77);
Var
  l : LongInt;

Begin
  If Assigned (SBPro) then Fail;     { Only one instance of the object is allowed at one time }

  DMAChannel:=DMA;
  IrqVector:=IRQ;
  SBPort:=Port;
  If IrqVector<=7 then PICPort:=$21 Else PICPort := $A1;
  IrqIntVector:=IrqIntNums[IrqVector];
  IrqStopMask:=1 SHL (IrqVector mod 8);
  IrqStartMask:=Not IrqStopMask;
  GetIntVec (IRQIntVector, OldIntVector);

  {$IFDEF DPMI}

    { This code looks a bit silly but I haven't had to time to clean it up }

    DMABuffer1:=Pointer (GlobalDosAlloc (32768));
    DMABuffer2:=Pointer (GlobalDosAlloc (32768));
    LongInt (DMABuffer1):=(LongInt (DMABuffer1) MOD 65536) SHL 16;
    LongInt (DMABuffer2):=(LongInt (DMABuffer2) MOD 65536) SHL 16;

    SoundBuffer1:=Pointer (AllocSelector (LongInt (DMABuffer1) SHR 16));
    LongInt (SoundBuffer1):=LongInt (SoundBuffer1) SHL 16;
    SoundBuffer2:=Pointer (AllocSelector (LongInt (DMABuffer2) SHR 16));
    LongInt (SoundBuffer2):=LongInt (SoundBuffer2) SHL 16;

    l:=GetSelectorBase (LongInt (SoundBuffer1) SHR 16);
    If l MOD 65536>49152 then Begin
      While l MOD 65536>0 Do Inc (l);
      SetSelectorBase (LongInt (SoundBuffer1) SHR 16,l);
    End;

    l:=GetSelectorBase (LongInt (SoundBuffer2) SHR 16);
    If l MOD 65536>49152 then Begin
      While l MOD 65536>0 Do Inc (l);
      SetSelectorBase (LongInt (SoundBuffer2) SHR 16,l);
    End;

  {$ELSE}
    DMABuffer1:=NIL;
    DMABuffer2:=NIL;
    GetMem (DMABuffer1,32768);
    GetMem (DMABuffer2,32768);
    If Not Assigned (DMABuffer1) Or Not Assigned (DMABuffer2) then Begin Done; Fail; End;
    l:=Seg (DMABuffer1^); l:=l*16; l:=l+Ofs (DMABuffer1^);
    If l MOD 65536<=49152 then SoundBuffer1:=DMABuffer1 Else SoundBuffer1:=Ptr (((l DIV 65536)+1)*4096,0);
    l:=Seg (DMABuffer2^); l:=l*16; l:=l+Ofs (DMABuffer2^);
    If l MOD 65536<=49152 then SoundBuffer2:=DMABuffer2 Else SoundBuffer2:=Ptr (((l DIV 65536)+1)*4096,0);
  {$ENDIF}

  ResetPort:=SBPort+$6;
  ReadPort:=SBPort+$A;
  WritePort:=SBPort+$C;
  PollPort:=SBPort+$E;
  MixerIndexPort:=SBPort+$4;
  MixerWritePort:=SBPort+$5;

  DMAStartMask:=DMAChannel+$00;
  DMAStopMask:=DMAChannel+$04;
  DMAModeReg:=DMAChannel+$48;

  If Not Reset then Begin Done; Fail; End;
  SetStereoIn;
  SetVolume (Master,LeftAndRight,15);
  SetVolume (Voice,LeftAndRight,15);
  SetVolume (FM,LeftAndRight,15);
  SetVolume (Microphone,Right,7);
  SetVolume (CDAudio,LeftAndRight,15);
  SetVolume (LineIn,LeftAndRight,15);
  SetInput (LineIn,LowPass,True);
  SetOutput (Stereo,True);
  SBPro:=@SELF;

  DisableIrq;
  SetIntVec (IRQIntVector, @PlayIrq);
  EnableIrq;
End;

Destructor SoundBlasterPro.Done;

Begin
  SetIntVec (IRQIntVector,OldIntVector);
  {$IFDEF DPMI}
    GlobalDosFree (LongInt (DMABuffer1) SHR 16);
    GlobalDosFree (LongInt (DMABuffer2) SHR 16);
    FreeSelector (LongInt (SoundBuffer1) SHR 16);
    FreeSelector (LongInt (SoundBuffer2) SHR 16);
  {$ELSE}
    If Assigned (DMABuffer1) then FreeMem (DMABuffer1,32768);
    If Assigned (DMABuffer2) then FreeMem (DMABuffer2,32768);
  {$ENDIF}
  SBPro:=NIL;
End;

Procedure SoundBlasterPro.OutBuffer (Var Buffer; Size : Word);

Begin
  RunError (211);
End;

Procedure SoundBlasterPro.InBuffer  (Var Buffer; Size : Word);

Begin
  RunError (211);
End;

Procedure SoundBlasterPro.RecordingReady;

Begin
  RunError (211);
End;

Procedure SoundBlasterPro.PlaybackReady;

Begin
  RunError (211);
End;

Function SoundBlasterPro.Reset : Boolean;

Var
  i : Byte;

Begin
  Port[ResetPort]:=1;
  Delay (1);
  Port[ResetPort]:=0;
  i:=1;
  While (ReadDSP<>$AA) And (i<100) Do Inc (i);
  Reset:=i<100;
  WriteMixer (0,0);
End;

Procedure SoundBlasterPro.PlaySample (SampleRate : Word; Length : LongInt);

Begin
  PlayLength:=Length;
  If PlayLength > 0 then Begin
    DisableIrq;
    SetIntVec (IRQIntVector, @PlayIrq);
    EnableIrq;
    CurrentPlay:=SoundBuffer1;
    PlaySampleRate:=SampleRate;
    If PlayLength >= 16384 then PlaySampleSize:=16384 Else PlaySampleSize:=PlayLength;
    Dec (PlayLength,PlaySampleSize);
    InBuffer (CurrentPlay^,PlaySampleSize);
    PlayBuffer (CurrentPlay,SampleRate,PlaySampleSize);
    If PlayLength > 0 then Begin
      If PlayLength >= 16384 then PlaySampleSize:=16384 Else PlaySampleSize:=PlayLength;
      Dec (PlayLength,PlaySampleSize);
      InBuffer (SoundBuffer2^,PlaySampleSize);
    End;
  End;
End;

Procedure SoundBlasterPro.RecordSample (SampleRate : Word; Length : LongInt);

Begin
  RecordLength:=Length;
  If RecordLength > 0 then Begin
    DisableIrq;
    SetIntVec (IRQIntVector, @RecordIrq);
    EnableIrq;
    CurrentRecord:=SoundBuffer1;
    RecSampleRate:=SampleRate;
    If RecordLength >= 16384 then RecSampleSize:=16384 Else RecSampleSize:=RecordLength;
    Dec (RecordLength,RecSampleSize);
    RecBuffer (CurrentRecord,RecSampleRate,RecSampleSize);
  End;
End;

Procedure SoundBlasterPro.SetStereoIn;

Begin
  WriteDSP ($A8);
  StereoMode:=Stereo;
End;

Procedure SoundBlasterPro.SetMonoIn;

Begin
  WriteDSP ($A0);
  StereoMode:=Mono;
End;

Function SoundBlasterPro.InputMode : Boolean;

Begin
  InputMode:=StereoMode;
End;

Procedure SoundBlasterPro.WriteMixer (Index, Value : Byte);

Begin
  Port [MixerIndexPort]:=Index;
  Port [MixerWritePort]:=Value;
End;

Function SoundBlasterPro.ReadMixer (Index : Byte) : Byte;

Begin
  Port [MixerIndexPort]:=Index;
  ReadMixer:=Port [MixerWritePort];
End;

Procedure SoundBlasterPro.SetVolume (VolumeType, Channel, Volume : Byte);

Var
  IndexReg : Byte;

Begin
  If VolumeType<>Microphone then Begin
    Case Channel Of
      Left         : Volume:=Volume SHL 4;
      LeftAndRight : Volume:=Volume Or (Volume SHL 4);
    End;
  End;
  Case VolumeType Of
    Master     : IndexReg:=$22;
    Voice      : IndexReg:=$4;
    FM         : IndexReg:=$26;
    Microphone : IndexReg:=$0A;
    CDAudio    : IndexReg:=$28;
    LineIn     : IndexReg:=$2E;
  End;
  WriteMixer (IndexReg,Volume);
End;

Function SoundBlasterPro.GetVolume (VolumeType, Channel : Byte) : Byte;

Var
  IndexReg, Volume : Byte;

Begin
  Case VolumeType Of
    Master     : IndexReg:=$22;
    Voice      : IndexReg:=$4;
    FM         : IndexReg:=$26;
    Microphone : IndexReg:=$0A;
    CDAudio    : IndexReg:=$28;
    LineIn     : IndexReg:=$2E;
  End;
  Volume:=ReadMixer (IndexReg);
  If (VolumeType<>Microphone) And (Channel=Left) then Volume:=Volume SHR 4;
  If VolumeType=Microphone then Volume:=Volume And 7 Else Volume:=Volume And 15;
  GetVolume:=Volume;
End;

Procedure SoundBlasterPro.SetInput (InputDevice, Filter : Byte; FilterOn : Boolean);

Var
  Value : Byte;

Begin
  Case InputDevice Of
    Microphone : Value:=0;
    CDAudio    : Value:=2;
    LineIn     : Value:=6;
  Else
    Exit;
  End;
  If Filter=LowPass then Value:=Value Or 8;
  If Not FilterOn then Value:=Value Or 32;
  WriteMixer ($0C,Value);
End;

Procedure SoundBlasterPro.GetInput (Var InputDevice, Filter : Byte; Var FilterOn : Boolean);

Var
  Value : Byte;

Begin
  Value:=ReadMixer ($0C);
  Case Value And 6 Of
    0 : InputDevice:=Microphone;
    2 : InputDevice:=CDAudio;
    6 : InputDevice:=LineIn;
  End;
  If Value And 8<>0 then Filter:=LowPass Else Filter:=HighPass;
  FilterOn:=(Value And 32)=0
End;

Procedure SoundBlasterPro.SetOutput (StereoOut, FilterOutput : Boolean);

Var
  Value : Byte;

Begin
  If StereoOut then Value:=2 Else Value:=0;
  If Not FilterOutput then Value:=Value Or 32;
  WriteMixer ($0E,Value);
End;

Procedure SoundBlasterPro.GetOutput (Var StereoOut, FilterOutput : Boolean);

Var
  Value : Byte;

Begin
  Value:=ReadMixer ($0E);
  StereoOut:=(Value And 2)<>0;
  FilterOutput:=(Value And 32)=0;
End;

Procedure SoundBlasterPro.HandleRecordIrq;

Begin
  If RecordLength>0 then Begin
    If CurrentRecord=SoundBuffer1 then CurrentRecord:=SoundBuffer2 Else CurrentRecord:=SoundBuffer1;
    If RecordLength >= 16384 then RecSampleSize:=16384 Else RecSampleSize:=RecordLength;
    Dec (RecordLength,RecSampleSize);
    RecBuffer (CurrentRecord,RecSampleRate,RecSampleSize);
    If CurrentRecord=SoundBuffer1 then OutBuffer (SoundBuffer2^,16384) Else OutBuffer (SoundBuffer1^,16384);
  End
  Else Begin
    If CurrentRecord=SoundBuffer1 then
      OutBuffer (SoundBuffer1^,RecSampleSize)
    Else
      OutBuffer (SoundBuffer2^,RecSampleSize);
    RecordingReady;
  End;
End;

Procedure SoundBlasterPro.HandlePlaybackIrq;

Begin
  If PlayLength>0 then Begin
    If CurrentPlay=SoundBuffer1 then CurrentPlay:=SoundBuffer2 Else CurrentPlay:=SoundBuffer1;
    PlayBuffer (CurrentPlay,PlaySampleRate,PlaySampleSize);
    If PlayLength >= 16384 then PlaySampleSize:=16384 Else PlaySampleSize:=PlayLength;
    Dec (PlayLength,PlaySampleSize);
    If CurrentPlay=SoundBuffer1 then
      InBuffer (SoundBuffer2^,PlaySampleSize)
    Else
      InBuffer (SoundBuffer1^,PlaySampleSize);
  End
  Else Begin
    If PlaySampleSize>0 then Begin
      If CurrentPlay=SoundBuffer1 then CurrentPlay:=SoundBuffer2 Else CurrentPlay:=SoundBuffer1;
      PlayBuffer (CurrentPlay,PlaySampleRate,PlaySampleSize);
      PlaySampleSize:=0;
    End
    Else
      PlaybackReady;
  End;
End;

Procedure SoundBlasterPro.WriteDSP (Value : Byte);

Begin
  While Port[WritePort] > 127 Do ;
  Port[WritePort]:=Value;
end;

Function SoundBlasterPro.ReadDSP : Byte;

Begin
  While Port[PollPort] < 128 Do;
  ReadDSP:=Port[ReadPort];
end;

Procedure SoundBlasterPro.PlayBuffer (Buffer : Pointer; SampleRate : Word; Size : Word);

Var
  SampleRateLimit, Time_constant, Page, Offset : Word;
  l : LongInt;

Begin

  If (Size=0) Or (Size>16384) then Exit;

  Dec (Size);

  { Set up the DMA chip }
  {$IFDEF DPMI}
    l:=GetSelectorBase (LongInt (Buffer) SHR 16);
  {$ELSE}
    l:=LongInt (Seg (Buffer^)) SHL 4+Ofs (Buffer^);
  {$ENDIF}
  Offset:=l MOD 65536;
  Page:=l SHR 16;
  Port[$0A] := DMAStopMask;
  Port[$0C] := 0;
  Port[$0B] := DMAModeReg;
  Port[$02] := Lo(offset);
  Port[$02] := Hi(offset);
  Port[$83] := Page;
  Port[$03] := Lo(size);
  Port[$03] := Hi(size);
  Port[$0A] := DMAStartMask;

  { Set the playback SampleRate }

  If InputMode=Stereo then Begin
    SampleRateLimit:=11025;
    If SampleRate<=SampleRateLimit then Begin
      Time_constant := 256 - (1000000 div (2*SampleRate));
    End
    Else Begin
      Time_constant := Hi (65536-(256000000 DIV (2*SampleRate)));
    End;
  End
  Else Begin
    SampleRateLimit:=22050;
    If SampleRate<=SampleRateLimit then Begin
      Time_constant := 256 - (1000000 div SampleRate);
    End
    Else Begin
      Time_constant := Hi (65536-(256000000 DIV SampleRate));
    End;
  End;
  WriteDSP ($40);
  WriteDSP (Time_constant);

  { Set the playback type (8-bit) }

  If SampleRate<=SampleRateLimit then WriteDSP($14) Else WriteDSP ($48);
  WriteDSP (Lo(size));
  WriteDSP (Hi(size));
  If SampleRate>SampleRateLimit then WriteDSP ($91);

  Port [PICPort]:=Port [PICPort] And IrqStartMask;
  Port [$20]:=$20;

End;

Procedure SoundBlasterPro.RecBuffer (Buffer : Pointer; SampleRate : Word; Size : Word);

Var
  SampleRateLimit, Time_constant, Page, Offset : Word;
  l : LongInt;

Begin

  If (Size=0) Or (Size>16384) then Exit;

  Dec (Size);

  { Set up the DMA chip }
  {$IFDEF DPMI}
    l:=GetSelectorBase (LongInt (Buffer) SHR 16);
  {$ELSE}
    l:=LongInt (Seg (Buffer^)) SHL 4+Ofs (Buffer^);
  {$ENDIF}
  Offset:=l MOD 65536;
  Page:=l SHR 16;
  Port[$0A] := DMAStopMask;
  Port[$0C] := 0;
  Port[$0B] := $45;
  Port[$02] := Lo (Offset);
  Port[$02] := Hi (Offset);
  Port[$83] := Page;
  Port[$03] := Lo (Size);
  Port[$03] := Hi (Size);
  Port[$0A] := DMAStartMask;

  { Set the record SampleRate }
  If InputMode=Stereo then Begin
    SampleRateLimit:=11025;
    If SampleRate<=SampleRateLimit then Begin
      Time_constant := 256 - (1000000 div (2*SampleRate));
    End
    Else Begin
      Time_constant := Hi (65536-(256000000 DIV (2*SampleRate)));
    End;
  End
  Else Begin
    SampleRateLimit:=22050;
    If SampleRate<=SampleRateLimit then Begin
      Time_constant := 256 - (1000000 div SampleRate);
    End
    Else Begin
      Time_constant := Hi (65536-(256000000 DIV SampleRate));
    End;
  End;
  WriteDSP ($40);
  WriteDSP (Time_constant);

  { Set the record type (8-bit) }
  If SampleRate<=SampleRateLimit then WriteDSP ($24) Else WriteDSP ($48);
  WriteDSP (Lo (Size));
  WriteDSP (Hi (Size));
  If SampleRate>SampleRateLimit then WriteDSP ($99);

  Port [PICPort]:=Port [PICPort] And IrqStartMask;
  Port [$20]:=$20;

End;

Procedure SoundBlasterPro.DisableInterrupts; ASSEMBLER; ASM CLI END;
Procedure SoundBlasterPro.EnableInterrupts; ASSEMBLER; ASM STI END;
Procedure SoundBlasterPro.DisableIrq;

Begin
  Port[PICPort]:=Port[PICPort] Or IrqStopMask;
End;

Procedure SoundBlasterPro.EnableIrq;

Begin
  Port[PICPort]:=Port[PICPort] And IrqStartMask;
End;

End.




