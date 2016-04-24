(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0034.PAS
  Description: DETECTS SoundBlaster
  Author: LENNERT BAKKER
  Date: 11-02-93  18:38
*)

{
From: LENNERT BAKKER
Subj: SB AutoDetect
    Here's how to autodetect a soundblaster and it's baseaddress
    and some other support-stuff for your convenience: }


{ Hey let's check this SB out 8-)}

Const SBReset     = $6;
      SBRead      = $A;
      SBWrite     = $C;
      SBStatus    = $E;

Var   SBPort      : Word;
      SBInstalled : Boolean;

Procedure DetectSoundBlaster;
Const NrTimes           = 10;
      NrTimes2          = 50;
Var   Found             : Boolean;
      Counter1,Counter2 : Word;
Begin
 SBPort:=$210;
 Found:=False;
 Counter1:=NrTimes;
  While (SBPort<=$260) And Not Found Do
   Begin
    Port[SBPort+$6]:=1;
    Port[SBPort+$6]:=0;
    Counter2:=NrTimes2;
     While (Counter2>0) And (Port[SBPort+$E]<128) Do
      Dec(Counter2);
     If (Counter2=0) Or (Port[SBPort+$A]<>$AA) Then
      Begin
       Dec(Counter1);
        If (Counter1=0) Then
         Begin
          Counter1:=NrTimes;
          SBPort:=SBPort+$10;
         End
      End Else Found:=True;
   End;
  If Found then SBInstalled:=True
   Else SBInstalled:=False;
End;

Begin
 DetectSoundBlaster;
  If SBInstalled then
   Writeln('SoundBlaster found at port :', SBPort)
  else
   Writeln('No soundcard, no boogie!');
End.


{Here's how to initialize the DSP:}

Procedure SetupSoundBlaster;
Var I,BDum : Byte;
Begin
  If SBInstalled then
   Begin
    Port[SBPort+SBReset]:=1; {Reset DSP}
     For I:=1 to 6 do
      BDum:=Port[SBPort+SBStatus];
    Port[SBPort+SBReset]:=0;
     For I:=1 to 6 do
      BDum:=Port[SBPort+SBStatus];
     Repeat Until Port[SBPort+SBStatus]>$80;
   End;
End;

{Respectively turn the speaker on/off}

Procedure TurnOnSBSpeaker;
Begin
 Repeat Until Port[SBPort+SBWrite]<$80;
 Port[SBPort+SBWrite]:=$D1;
End;

Procedure TurnOffSBSpeaker;
Begin
 Repeat Until Port[SBPort+SBWrite]<$80;
 Port[SBPort+SBWrite]:=$D3;
End;

{
  Here's basically how you play a sample, you should reprogram
  the timer though and have your interrupt routine output bytes
  to the DSP at regular intervals, say 10000 times/sec or so.
  Rather use machine-language instead, but that shouldn't be too
  hard now, should it? 8)
}

Procedure PlaySample(Sample:Pointer;Length:Word);
Var A : Word;
Begin
 For A:=1 to Length Do
  Begin
   Port[SBPort+SBWrite]:=$10;
   Port[SBPort+SBWrite]:=Mem[Seg(Sample^):Ofs(Sample^)+A];
   {Delay some time}
  End;
End;

{Or sumtin like this (untested) }

Procedure PlaySampleASM(Sample:Pointer;Length:Word); Assembler;
Asm
 Les Di,[Sample]
 Mov Dx,SBPort+SBWrite
 Mov Cx,Length
@LoopIt:
 LodsB
 Out Dx,$10
 Out Dx,Al

 { Delay Some Time -- What about 1000 NOPs or so ;-) }

 Loop @LoopIt
End;


