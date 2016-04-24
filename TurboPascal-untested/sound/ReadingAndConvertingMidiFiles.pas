(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0066.PAS
  Description: Reading and Converting MIDI Files
  Author: COLIN BUCKLEY
  Date: 05-26-95  23:20
*)

{
From: colin.buckley@canrem.com (Colin Buckley)

>> Does anyone have some good Pascal code for 1) real-time MIDI performance
>> on a standard (Roland MPU-401) card; or 2) reading of MIDI data files.

>Nope.  Nobody has any of this, nor does any exist anywhere on the
>Internet, I can guarantee you this.  I have been asking for this for over
>a year now and it just does *not* exist anywhere.

Which question are you answering?

MIDI is very simple stuff.  Playing or reading and writing the files.
Playing just involves tossing the midi messages out a port.  To read or
write, all you need are the MIDI specs, and you shouldn't have any problem
finding those.  But I don't have FTP so I wouldn't really know.

I have "pascal code" for question 1, but it's actually assembler.  I write
all my low level stuff in assembler, then I wrote a pascal shell around it
when someone in the Fido pascal conference wanted to play MIDI.  It should
be in SWAG, never looked though.  I'll include it at the end of this message.
Just a little while ago I saw a pure Turbo Pascal version.

As for question 2, I'll post the pascal code to my MIDI file convertor as it
can read in *certain* MIDI files.  I've only tested it on files created with
ROL2MIDI, which means there single track and only certain events appear.
It converts to a simple format I use in my games.

Look for the source code disk from the Official Sound Blaster Book (I think
that's the title).  It uses nothing but Creative Lab drivers, but it does
have code to read MOD and MIDI files.  I have the MIDI Unit (MIDUNIT), but
I didn't write it, so I won't post it or email it.  It supports more midi
messages then my routines do, but it's also single track.
}
Program MDI2MUS;

Uses
  CRT,Fast,FM,GM;
  { It's obivously not going to compile.  FAST is just my unit of little
    routines, like screen writes, string routines, etc.

    FM and GM have the same functions and procedures for playing sounds
    on those devices as the purpose of the program is to convert a MDI
    composed on an Adlib to something I can play on Adlib or General Midi.
    The PickGMInstrument, lets me pick a GM instrument by hearing both.

    Comment out the sound stuff, and supply your own generic routines.
  }


Const
  MUSID=245;
  MUSTempo=72.8;
  MUSOverflow=0 SHL 4;
  MUSInstrument=1 SHL 4;
  MUSVolume=2 SHL 4;
  MUSNoteOn=3 SHL 4;
  MUSNoteOff=4 SHL 4;
  MUSPitch=5 SHL 4;
  MUSMarker=14 SHL 4;
  MUSEnd=15 SHL 4;

Type
  MUSHeaderRec=Record
    ID:Byte;
    Title:MStr;
  End;

  MUSInsRec=Record
    GMIns:Byte;
    FMIns:FMInstrument;
  End;

  MDIHeaderRec=Record
    ID:Array[0..3] of Char;
    Length:LongInt;
    Format:Word;
    NumTracks:Word;
    Division:Word;
  End;

  MDITrackRec=Record
    ID:Array[0..3] Of Char;
    Length:LongInt;
  End;

Var
  MUS:File;
  MUSHeader:MUSHeaderRec;
  MDI:File;
  MDIHeader:MDIHeaderRec;
  MDITrack:MDITrackRec;
  EndOfTrack:Boolean;
  Next:Byte;
  NewTempo:Real;
  Tempo:LongInt;
  Time:Word;
  Channel:Byte;
  Command:Byte;
  Note:Byte;
  Volume:Byte;
  VolumeArray:Array[0..15] of Byte;
  Pitch:Word;
  FMIns:Instrument;
  MUSIns:MUSInsRec;

  Procedure Error(Msg:String);
  Begin
    Writeln('* '+Msg);
    Halt;
  End;

  Procedure PickGMInstrument(Voice:Byte);
  Var
    Patch:Byte;
    Key:Char;
    FMOn:Boolean;

    Procedure InitMUS;
    Begin
      FM.InitFM;
      GM.InitGM;
    End;

    Procedure ResetMUS;
    Begin
      FM.ResetFM;
      GM.ResetGM;
    End;

    Procedure SetNoteOn(Voice,Note:Byte);
    Begin
      If FMOn then
        FM.SetNoteOn(Voice,Note)
      Else
        GM.GMSetNoteOn(Voice,Note)
    End;

    Procedure SetNoteOff(Voice:Byte);
    Begin
      If FMOn then
        FM.SetNoteOff(Voice)
      Else
        GM.GMSetNoteOn(Voice,Note)
    End;

    Procedure SetVolume(Voice,Volume:Byte);
    Begin
      FM.SetVolume(Voice,Volume);
      GM.GMSetVolume(Voice,Volume);
    End;

  Begin
    FMOn:=True;
    Writeln('Encountered FM Instrument on Channel ',Voice);
    Writeln;
    Writeln('Instructions:');
    Writeln('C     = Middle C Note');
    Writeln('1..0  = Note Scale');
    Writeln('SPACE = Toggle Device');
    Writeln('P     = Change Patch');
    Writeln;
    InitMUS;
    FM.SetInstrument(Voice,@MUSIns.FMIns);
    GMSetInstrument(Voice,MUSIns.GMIns);
    SetVolume(Voice,127);
    Repeat
      Write('Patch: ',MUSIns.GMIns);ClrEol;
      GotoXY(1,WhereY);
      Key:=Upcase(BIOSKey);
      Case Key of
        '1'..'9':Begin
                   SetNoteOn(Voice,54+(Ord(Key)-48));
                   Delay(175);
                   SetNoteOff(Voice);
                 End;
        '0':     Begin
                   SetNoteOn(Voice,65);
                   Delay(175);
                   SetNoteOff(Voice);
                 End;
         SPACEKey:FMOn:=Not FMOn;
         'P':    Begin
                   Writeln;
                   Write('New Patch [0-127]: ');
                   Readln(MUSIns.GMIns);
                   GotoXY(1,WhereY-1);
                   ClrEol;
                   GotoXY(1,WhereY-1);
                   ClrEol;
                   GMSetInstrument(Voice,MUSIns.GMIns);
                 End;
      End;
    Until (Key=ESCKey) or (Key=ENTERKey);
    ResetMUS;
  End;

  Procedure WriteMUS(Time:Byte; Command,Channel:Byte; Var Data; DataSize:Byte);
  Var
    Combined:Byte;
    T:Byte;
  Begin
    { Set Delta Time }
    BlockWrite(MUS,Time,SizeOf(Time));
    ASM
      MOV  AL,[Command]
      AND  AL,11110000b
      MOV  AH,[Channel]
      AND  AH,00001111b
      ADD  AL,AH
      MOV  [Combined],AL
    End;
    { Set Command/Channel Combined Byte }
    BlockWrite(MUS,Combined,SizeOf(Combined));
    { Set Command Data }
    If DataSize>=1 then
      BlockWrite(MUS,Data,DataSize);
  End;

  Function IntelLong(Motorolla:LongInt):LongInt; Assembler;
  ASM
    MOV  AX,[WORD PTR Motorolla]
    MOV  DX,[WORD PTR Motorolla+2]
    XCHG AL,AH
    XCHG DL,DH
    XCHG AX,DX
  End;

  Function IntelWord(Motorolla:Word):Word; Assembler;
  ASM
    MOV  AX,[Motorolla]
    XCHG AL,AH
  End;

  Procedure ReadMDI(MDIFile:LStr);
  Begin
    Assign(MDI,MDIFile);
    Reset(MDI,1);
    If IOResult<>0 then
      Error(MDIFile+' Not Found!');
    BlockRead(MDI,MDIHeader,SizeOf(MDIHeader));
    BlockRead(MDI,MDITrack,SizeOf(MDITrack));
    With MDIHeader do
    Begin
      Length:=IntelLong(Length);
      Format:=IntelWord(Format);
      NumTracks:=IntelWord(NumTracks);
      Division:=IntelWord(Division);
    End;
    With MDITrack do
      Length:=IntelLong(Length);
    If (MDIHeader.ID<>'MThd') or (MDIHeader.Format<>0) or (MDITrack.ID<>'MTrk')
      Error('Invalid Type 0 .MDI File: '+MDIFile);
  End;

  Procedure CreateMUS(MUSFile:LStr);
  Var
    Temp:Byte;
  Begin
    FillChar(MUSHeader,SizeOf(MUSHeader),0);
    MUSHeader.ID:=MUSID;
    Write('Enter Title: ');
    Readln(MUSHeader.Title);
    Assign(MUS,MUSFile);
    Rewrite(MUS,1);
    BlockWrite(MUS,MUSHeader,SizeOf(MUSHeader));
  End;

  Procedure ConvertMDI;

    Procedure DoDeltaTime;
    Var
      VarLength:LongInt;
    Begin
      BlockRead(MDI,Next,1);
      VarLength:=Next;
      If (Next And $80)=$80 then
      Begin
        VarLength:=VarLength And $7F;
        Repeat
          BlockRead(MDI,Next,1);
          VarLength:=(VarLength Shl 7) + (Next And $7F)
        Until (Next And $80)<>$80;
      End;
      Time:=Trunc(VarLength*NewTempo);
      If Time>255 then
      Begin
        WriteMUS(0,MUSOverflow,0,Time,SizeOf(Time));
        Time:=0;
      End;
    End;

    Procedure DoSysExEvent;
    Begin

    End;

    Procedure DoMIDIEvent;
    Begin
      Channel:=Command And $F;
      Command:=Command And $F0;
      Case Command of
        { Note Off }
        $80:Begin
              BlockRead(MDI,Note,1);
              BlockRead(MDI,Volume,1);
              WriteMUS(Time,MUSNoteOff,Channel,Note,0);
            End;
        { Note On }
        $90:Begin
              BlockRead(MDI,Note,1);
              BlockRead(MDI,Volume,1);
              { If Volume=0 it's the same as a NoteOff }
              If Volume=0 then
                WriteMUS(Time,MUSNoteOff,Channel,Note,0)
              Else
              Begin
                { Update Volume if different then previous }
                If VolumeArray[Channel]<>Volume then
                Begin
                  VolumeArray[Channel]:=Volume;
                  WriteMUS(Time,MUSVolume,Channel,Volume,SizeOf(Volume));
                  Time:=0;
                End;
                WriteMUS(Time,MUSNoteOn,Channel,Note,SizeOf(Note));
              End;
            End;
        { Volume Change / Channel Pressure / After Touch }
        $D0:Begin
              BlockRead(MDI,Volume,1);
            End;
        { Pitch Change }
        $E0:Begin
              BlockRead(MDI,Pitch,2);
              Pitch:=IntelWord(Pitch);
              WriteMUS(Time,MUSPitch,Channel,Pitch,SizeOf(Pitch));
            End;
        Else
          Writeln('Unknown MIDI event!');
      End;
    End;

    Procedure DoMetaEvent;
    Var
      Length:Byte;
      FPos:LongInt;
      ID:Array[0..4] of Byte;
    Begin
      BlockRead(MDI,Command,1);
      BlockRead(MDI,Length,1);
      FPos:=FilePos(MDI);
      Case Command of
        $2F:Begin
              EndOfTrack:=True;
              WriteMUS(0,MUSEnd,0,Note,0);
            End;
        { Tempo }
        $51:Begin
              BlockRead(MDI,Next,1);
              Tempo:=Next*65536;
              BlockRead(MDI,Next,1);
              Inc(Tempo,Word(Next*256));
              BlockRead(MDI,Next,1);
              Inc(Tempo,Next);
              NewTempo:=MUSTempo/(MDIHeader.Division*(1000000/Tempo));
            End;
        { Sequencer Specific }
        $7F:Begin
              BlockRead(MDI,ID,SizeOf(ID));
              { Adlib ID }
              If (ID[0]=$00) And (ID[1]=$00) And (ID[2]=$3F) then
                Case Ord(ID[4]) of
                  { Instrument }
                  1:Begin
                      BlockRead(MDI,Channel,1);
                      BlockRead(MDI,FMIns,SizeOf(FMIns));
                      ConvertInstrument(FMIns,MUSIns.FMIns);
                      PickGMInstrument(Channel);
                      WriteMUS(Time,MUSInstrument,Channel,MUSIns
SizeOf(MUSIns))
                    End;
                  { Melodic or Percussion Mode }
                  2:BlockRead(MDI,Next,1);
                  { Waveforms }
                  3:BlockRead(MDI,Next,1);
                End;
            End;
      End;
      Seek(MDI,FPos+Length);
    End;

  Begin
    EndOfTrack:=False;
    Time:=0;
    NewTempo:=500000;
    FillChar(VolumeArray,SizeOf(VolumeArray),0);
    While Not (EOF(MDI) And EndOfTrack) do
    Begin
      { Get Time of Event }
      DoDeltaTime;
      { Get Event from Midi Stream }
      BlockRead(MDI,Command,1);
      Case Command of
        $80..$EF:DoMidiEvent;
        {
        $F0,$F7: DoSysExEvent;
        }
        $FF:     DoMetaEvent;
      Else
        Writeln('Unknown Event in MIDI Stream!');
      End;
    End;
    Close(MDI);
    Close(MUS);
  End;

Begin
  Writeln('+-----------------------  +++++-++|+++++ +++++++++-----------------
  Writeln('|                         ++++-++++++++- +++++++++-
  Writeln('|
  Writeln('|                              Music Conversion
  Writeln('|
  Writeln('|              Copyright 1992 by Absolute Magic, Inc and Colin Buckle
  Writeln('+--------------------------------------------------------------------
  Writeln;
  If ParamCount<2 then
  Begin
    Writeln;
    Writeln('USAGE: MUS <MDIFile> <MUSFile>');
    Writeln;
    Writeln('<MDIFile> is created by converting a .ROL with ROL2MIDI.EXE');
    Writeln;
    Exit;
  End;
  ReadMDI(ParamStr(1));
  CreateMUS(ParamStr(2));
  ConvertMDI;
  Writeln;
  If Not EndOfTrack then
    Writeln('* Unsuccessful Conversion.  End Of Track Not Encountered.')
  Else
    Writeln('* Successful Conversion');
End.





-----------------------------------------------------------------------------

Program GMTest;

{
Public domain.  Do whatever you want with it.
Colin Buckley.
}

Const
  GMPort        = $331;
  Send          = $80;
  Receive       = $40;

{ AL:=Command; }
Procedure WriteGMCommand; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ;Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    {; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Receive                  {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    OUT   DX,AL                       {;Send Data                         }
End;

{ ; AL:=Data }
Procedure WriteGM; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ; Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    { ; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Receive                  {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    DEC   DX                          {;DX:=DataPort                     }
    OUT   DX,AL                       {;Send Data                        }
End;

{ ;Returns Data }
Function ReadGM:Byte; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ; Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    { ; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Send                     {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    DEC   DX                          {;DX:=DataPort                      }
    IN    AL,DX                       {;Receive Data                      }
End;

Procedure ResetGM; Assembler;
ASM
    { ;Reset GM }
    MOV   DX,GMPort
    MOV   AL,0FFh
    OUT   DX,AL
    {; Get ACK }
    CALL  ReadGM
    {; UART Mode }
    MOV   AL,03Fh
    CALL  WriteGMCommand
End;

Procedure SetNoteOn(Channel,Note,Volume:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,90h
    Call  WriteGM
    MOV   AL,[Note]
    CALL  WriteGM
    MOV   AL,[Volume]
    CALL  WriteGM
End;

Procedure SetNoteOff(Channel,Note,Volume:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,80h
    Call  WriteGM
    MOV   AL,[Note]
    CALL  WriteGM
    MOV   AL,[Volume]
    CALL  WriteGM
End;

Begin
  ResetGM;
  SetNoteOn(0,64,127);
  ASM
    { ;Wait for Key }
    XOR   AX,AX
    INT   16h
  End;
  SetNoteOff(0,64,127);
  ResetGM;
End.

