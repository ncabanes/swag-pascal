(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0057.PAS
  Description: Play VOC Files without CT-VOICE.DRV
  Author: ETHAN BRODSKY
  Date: 11-26-94  04:55
*)

{
                                  SBDSP
                          Version 1.03 (9/23/94)
                         Written by Ethan Brodsky
          Copyright 1994 by Ethan Brodsky.  All rights reserved.

This library is distributed AS IS.  The author specifically disclaims
any responsibility for any loss of profit or any consequential,
incidental, or other damages.  SBDSP is freeware and is distributed
with full Turbo Pascal source code.  You are free to incorporate parts
of the code into your own programs as long as you give credit to Ethan
Brodsky.  This source code may only be distributed in it's original
form, including this documentation file.

------------------------------------------------------------------------

    You may have used my SBVox and SBVoice units.  They played VOC files
on a Sound Blaster using Creative Labs' CT-VOICE driver.  Since they
used the CT-VOICE driver, they wouldn't work on other sound cards.  The
driver needed to be included with the program, either in a separate file
or linked into the executable.

    SBDSP performs the same functions as the SBVox unit without using
the CT-VOICE driver.  It has only been tested on a SB16 and PAS16, but
it should work on all Sound Blaster compatible sound cards.  By using
DMA transfers, it plays sound without using the CPU, saving processor
cycles for your program.

    I have many improvements planned, including 16-bit sound, stereo
effects, and mixing, along with new library for FM music.  But I NEED
FEEDBACK!  If you use my code, tell me about it!  If you make any
modifications, send them to me!  If you have any suggestions for
improvements, tell me about them!  If you want me to write a C version,
or a version to play WAV files, tell me!

   You don't need to pay me for using this unit.  All you have to do
is put my name in the credits for your product.  I'd appreciate it if
you'd send me a message telling me how you used SBDSP.  (If you used
it in a game, tell me where I can get it)  And finally, if you ever
have a sound programming job, think of me.

    You can find out most of the things you need to know in order to
use this library by looking at the PlayVOC example program, but I'll
go over it again.  The first thing you need to do is to reset the DSP,
initialize SBDSP's internal variables, and install the interrupt
handler.  In order to do this, you need to know the sound cards base
address, IRQ number, and 8-bit DMA channel.   If this is being used
on a Sound Blaster, this information can be obtained from the BLASTER
environment variable.  I don't know whether other cards use this.  You
can use the EnvironmentSet function to find out if the environment
variable is set.  If it is, you can call the function InitSBFromEnv.
Otherwise, you'll have to find out the settings some other way and pass
them to the InitSB function.

    Use the LoadVOCFile function to allocate a sound buffer.  Make sure
that you save the value returned from this function.  It is the size of
the allocated buffer.  It will be needed when you deallocate the buffer.
The memory needed for Sound will be allocated inside this function. You
do NOT need to allocate it beforehand.

    Before you can play any sounds, you have to turn on the speaker
output.  Do this by calling TurnSpeakerOn.  Make sure you turn it off
at the end of the program.  If you want to install a marker handler,
make sure you do it now by calling SetMarkerProc.  A marker handler
will be called each time a marker block is reached.  Before you install
your marker handler, save the old one using GetMarkerProc.  If the value
returned is not nil, then another marker procedure has been installed.
Call it each time your marker procedure is called.  This is a good
practice to get into when setting up a handler such as this.  It will
make it possible to install more than one marker procedure.

    To play a sound, pass a pointer to the sound buffer to PlaySound.
Any sound output in progress will be stopped.  To find out if the sound
is finished, check the SoundPlaying variable.  The VOC file format has
a provision for repeating sounds.  The sound can be set to repeat for
a number of times (Or forever)  You can break out of the loop by calling
BreakLoop.  The current iteration will finish and it will continue to
the next block.  When the program is completely finished playing sound,
call the ShutDownSB procedure.  This will stop any sound output in
progress and remove the interrupt handler.  You should deallocate all
sound buffers by using FreeBuffer.  The pointer to the buffer should be
typecasted as a pointer.  Make sure that you pass the buffer size that
was returned by LoadVOCFile so that the right amount of memory is
deallocated.

    This library will not allow you to play 16 bit or stereo VOC files.
It will not work in protected mode since it uses DMA transfers.  If you
have any other questions, feel free to ask.  If you would like me to
make any modifications or a customized version of this unit to use in
your program, contact me and we can work out some arrangements.

There are several ways to contact me:
    E-Mail:  ericbrodsky@psl.wisc.edu    (Preferred)
    Phone:   (608) 238-4830
    Mail:
        Ethan Brodsky
      4010 Cherokee Dr.
      Madison, WI 53711

Bug fixes and other announcements will be posted in:
    comp.lang.pascal
    comp.sys.ibm.pc.soundcard
    comp.sys.ibm.pc.soundcard.tech
    rec.games.programmer
}


{       SBDSP is Copyright 1994 by Ethan Brodsky.  All rights reserved.      }
unit Mem;
    interface
        function GetBuffer(var Buffer: pointer; BufferLength: LongInt): boolean;
        procedure FreeBuffer(Buffer: pointer; BufferLength: LongInt);
        function GetAbsoluteAddress(p: pointer): LongInt;
    implementation
        function GetBuffer(var Buffer: pointer; BufferLength: LongInt): boolean;
            var
                Dummy: pointer;
            begin
                if MaxAvail < BufferLength
                    then
                        begin
                            GetBuffer := false;
                            Buffer := nil;
                            Exit;
                        end;
                GetBuffer := true;
                if BufferLength < $FFFF
                    then
                        GetMem(Buffer, BufferLength)
                    else
                        begin
                            GetMem(Buffer, $FFFF);
                            BufferLength := BufferLength - $FFFF;
                            while BufferLength > $FFFF do
                                begin
                                    GetMem(Dummy, $FFFF);
                                    BufferLength := BufferLength - $FFFF;
                                end;
                            GetMem(Dummy, BufferLength);
                        end;
            end;
        procedure FreeBuffer(Buffer: pointer; BufferLength: LongInt);
            var
                Dummy: pointer;
                LeftToFree: LongInt;
            begin
                if BufferLength < $FFFF
                    then
                        FreeMem(Buffer, BufferLength)
                    else
                        begin
                            Dummy := Buffer;
                            LeftToFree := BufferLength;
                            FreeMem(Buffer, $FFFF);
                            LeftToFree := LeftToFree - $FFFF;
                            Dummy := Ptr(Seg(Dummy^) + $1000, Ofs(Dummy^));
                            while LeftToFree > $FFFF do
                                begin
                                    FreeMem(Dummy, $FFFF);
                                    LeftToFree := LeftToFree - $FFFF;
                                    Dummy := Ptr(Seg(Dummy^) + $1000, Ofs(Dummy^));
                                end;
                            FreeMem(Dummy, LeftToFree);
                        end;
            end;
        function GetAbsoluteAddress(p: pointer): LongInt;
            begin
                GetAbsoluteAddress := LongInt(Seg(p^))*16 + LongInt(Ofs(p^));
            end;
    end.




{       SBDSP is Copyright 1994 by Ethan Brodsky.  All rights reserved.      }
unit VOC;
    interface
        const
            EndBlockNum            = 0;
            VoiceBlockNum          = 1;
            VoiceContinueBlockNum  = 2;
            SilenceBlockNum        = 3;
            MarkerBlockNum         = 4;
            MessageBlockNum        = 5;
            RepeatBlockNum         = 6;
            RepeatEndBlockNum      = 7;
            ExtendedInfoBlockNum   = 8;
            NewVoiceBlockNum       = 9;
            BlockNames : array[0..9] of string =
                (
                 'Terminator',
                 'Voice Data',
                 'Voice Continuation',
                 'Silence',
                 'Marker',
                 'Message',
                 'Repeat Loop',
                 'End Repeat Loop',
                 'Extended Info',
                 'New Voice Data'
                );
            {Used in block type 1 and 8}
            Unpacked8  = 0; {8 bit (Uncompressed)}
            Packed4    = 1; {4 bit}
            Packed26   = 2; {2.6 bit}
            Packed2    = 3; {2 bit}
            PackingNames : array[0..10] of string =
                (
                 '8 bit unpacked',
                 '4 bit packed',
                 '2.6 bit packed',
                 '2 bit packed',
                 '1 channel multi',
                 '2 channel multi',
                 '3 channel multi',
                 '4 channel multi',
                 '5 channel multi',
                 '6 channel multi',
                 '7 channel multi'
                );
            {Used in block type 9}
            Uncompressed8     = $0000;
            Compressed4       = $0001;
            Compressed26      = $0002;
            Compressed2       = $0003;
            Uncompressed16    = $0004;
            CompressedALAW    = $0006;
            CompressedMULAW   = $0007;
            CompressedADPCM   = $0200; {Why couldn't they make this $0008?}
            CompressionNames : array[0..7] of string =
                (
                    '8 bit uncompressed',
                    '4 bit compressed',
                    '2.6 bit compressed',
                    '2 bit compressed',
                    '16 bit uncompressed',
                    '',
                    'ALAW compressed',
                    'MULAW compressed'
                );
            ExtendedMono   = 0;
            ExtendedStereo = 1;
            ExtendedModeNames : array[0..1] of string = ('Mono', 'Stereo');

            NewMono   = 1;      {This is Creative Labs' fault}
            NewStereo = 2;      {Blame it on Creative Labs}
            NewModeNames : array[1..2] of string = ('Mono', 'Stereo');
        type
            PSound = ^TSound;
            TSound = array[0..65520] of byte;

            PVOCHeader = ^TVOCHeader;
            TVOCHeader = array[1..26] of byte;

            TripleByte = array[1..3] of byte;

            PBlock = ^TBlock;
            TBlock =
                record
                    BlockType: byte;
                    BlockLength: TripleByte;
                end;

            PEndBlock = ^TEndBlock;
            TEndBlock =
                record
                    BlockType : byte;
                end;

            PVoiceBlock = ^TVoiceBlock;
            TVoiceBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    SR : byte;
                    Packing : byte;
                    Data : array[0..65520] of byte;
                end;

            PVoiceContinueBlock = ^TVoiceContinueBlock;
            TVoiceContinueBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Data : array[0..65520] of byte;
                end;

            PSilenceBlock = ^TSilenceBlock;
            TSilenceBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Duration : word;
                    SR : byte;
                end;

            PMarkerBlock = ^TMarkerBlock;
            TMarkerBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Marker : word;
                end;

            PMessageBlock = ^TMessageBlock;
            TMessageBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Data: array[0..65520] of char;
                end;

            PRepeatBlock = ^TRepeatBlock;
            TRepeatBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    Count: word;
                end;

            PRepeatEndBlock = ^TRepeatEndBlock;
            TRepeatEndBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                end;
            PExtendedInfoBlock = ^TExtendedInfoBlock;
            TExtendedInfoBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    ExtendedSR : word;
                    Packing : byte;
                    Mode : byte; {0 = mono, 1 = stereo}
                end;
            PNewVoiceBlock = ^TNewVoiceBlock;
            TNewVoiceBlock =
                record
                    BlockType : byte;
                    BlockLength : TripleByte;
                    SamplingRate : word; {HZ}
                    Dummy1 : array[1..2] of byte;
                    BitsPerSample : byte; {Uncompressed bits per sample}
                    Mode : byte; {1 = mono, 2 = stereo}
                    Compression: word;
                    Dummy2 : array[1..4] of byte;
                    Data : array[0..64000] of byte;
                end;
        function TripleByteToLongint(TB: TripleByte): LongInt;
        function GetSamplingRate(SR: byte): LongInt;
        function GetSRByte(SamplingRate: word): byte;
        function GetExtendedSamplingRate(ExtendedSR: word; Mode: byte): LongInt;
        function BlockSize(Block: PBlock): LongInt;
        procedure IncrementPtr(var P: pointer; Count: word);
        function FindNextBlock(Block: PBlock): PBlock;
        function LoadVOCFile(FileName: string; var Sound: PSound): LongInt;
    implementation
        uses
            Mem;
        function TripleByteToLongint(TB: TripleByte): LongInt;
            begin
                TripleByteToLongint := LongInt(TB[1]) + LongInt(TB[2]) SHL 8 + LongInt(TB[3]) SHL 16;
            end;
        function GetSamplingRate(SR: byte): LongInt;
            begin
                GetSamplingRate := -1000000 div (SR - 256);
            end;
        function GetSRByte(SamplingRate: word): byte;
            begin
                GetSRByte := 256-(1000000 div SamplingRate);
            end;
        function GetExtendedSamplingRate(ExtendedSR: word; Mode: byte): LongInt;
            begin
                case Mode
                    of
                        ExtendedMono:
                            GetExtendedSamplingRate := -256000000 div (ExtendedSR-65536);
                        ExtendedStereo:
                            GetExtendedSamplingRate := (-256000000 div (ExtendedSR-65536)) div 2;
                    end;
            end;
        function BlockSize(Block: PBlock): LongInt;
            begin
                BlockSize := TripleByteToLongInt(Block^.BlockLength) + 4;
            end;
        procedure IncrementPtr(var P: pointer; Count: word);
          {Easier to implement in assembly}
            begin
                asm
                    LES  DI, P
                    MOV  BX, Count
                    MOV  AX, ES:[DI]
                    MOV  DX, ES:[DI+2]
                    ADD  AX, BX
                    CMP  AX, $000F
                    JNA  @1
                    MOV  BX, AX
                    AND  AX, $F
                    AND  BX, $FFF0
                    MOV  CL, 4
                    SHR  BX, CL
                    ADD  DX, BX
                  @1:
                    MOV  ES:[DI], AX
                    MOV  ES:[DI+2], DX
                end;
            end;
        function FindNextBlock(Block: PBlock): PBlock;
            var
                NewBlock: PBlock;
                BlockSize: LongInt;
            begin
                if Block^.BlockType = EndBlockNum
                    then
                        begin
                            FindNextBlock := nil;
                            Exit;
                        end;
                NewBlock := Block;
                BlockSize := TripleByteToLongInt(Block^.BlockLength) + 4;
                while BlockSize > 0 do
                    begin
                        if BlockSize > 64000
                            then
                                begin
                                    IncrementPtr(pointer(NewBlock), 64000);
                                    Dec(BlockSize, 64000);
                                end
                            else
                                begin
                                    IncrementPtr(pointer(NewBlock), BlockSize);
                                    BlockSize := 0;
                                end;
                    end;
                FindNextBlock := NewBlock;
            end;
        function LoadVOCFile(FileName: string; var Sound: PSound): LongInt;
           var
                f: file;
                Dummy: Pointer;
                LeftToRead: LongInt;
                Header: PVOCHeader;
            begin
                Assign(f, FileName);
                {$I-}
                Reset(f, 1);
                {$I+}
                if IOResult <> 0
                    then
                        begin
                            LoadVOCFile := 0; {Couldn't open file}
                            Exit;
                        end;
                LeftToRead := FileSize(f) - SizeOf(Header^);
                LoadVOCFile := LeftToRead;
                New(Header);
                BlockRead(f, Header^, SizeOf(Header^));

                if GetBuffer(pointer(Sound), LeftToRead) <> true
                    then
                        begin
                            LoadVOCfile := 0; {Failed to allocate memory}
                            Exit;
                        end;
                Dummy := Sound;
                while LeftToRead > 0 do
                    begin
                        if LeftToRead < 64000
                            then
                                begin
                                    BlockRead(f, Dummy^, LeftToRead);
                                    LeftToRead := 0;
                                end
                            else
                                begin
                                    BlockRead(f, Dummy^, 64000);
                                    LeftToRead := LeftToRead - 64000;
                                    IncrementPtr(Dummy, 64000);
                                end;
                    end;
                Close(f);
                Dispose(Header);
            end;
    begin
    end.



{       SBDSP is Copyright 1994 by Ethan Brodsky.  All rights reserved.      }

{$X+} {Extended syntax on}
unit SBDSP;
    interface
        uses
            VOC;
        const
            On = true;
            Off = false;
        type
            Proc = procedure;
        function InitSB(IRQ: byte; BaseIO: word; DMAChannel: byte): boolean;
          {This function must be called before any sound is played.  It will }
          {initialize internal variables, reset the DSP chip, and install the}
          {interrupt handler.                                                }
          {IRQ:           The sound card's IRQ setting (Usually 5 or 7)      }
          {BaseIO:        The sound card's base IO address (Usually $220)    }
          {DMAChannel:    The sound card's 8-bit DMA channel (Usually 1)     }
          {Returns:                                                          }
          {    TRUE:      Sound card initialized correctly                   }
          {    FALSE:     Error initializing sound card                      }
        function EnvironmentSet: boolean;
          {Returns:                                                          }
          {    TRUE:  The BLASTER environment variable is set                }
          {    FALSE: The BLASTER environment variable isn't set             }
        function InitSBFromEnv: boolean;
          {This function initializes the sound card from the settings stored }
          {in the BLASTER environment variable.  I'm not sure if all sound   }
          {cards use the enviroment variable.                                }
          {Returns:                                                          }
          {    TRUE:  Environment variable found and sound card initialized  }
          {    FALSE: Environment variable not set or error initializing card}
        procedure ShutDownSB;
          {This procedure must be called at the end of the program.  It stops}
          {sound output, removes the interrupt handler, and restores the old }
          {interrupt handler.                                                }
        procedure InstallHandler;
          {This procedure will reinstall the }
        procedure UninstallHandler;
          {This procedure will remove the interrupt handler.  You should not }
          {need to call this.  If you do, sound output won't work until the  }
          {handler is reinstalled.                                           }
        function ResetDSP: boolean;
          {This function resets the sound card's DSP chip.                   }
          {Returns:                                                          }
          {    TRUE:    The sound card's DSP chip was successfully reseted   }
          {    FALSE:   The chip couldn't be initialized (Don't use it)      }
        function GetDSPVersion: string;
          {This function returns a string containing the DSP chip version.   }
        procedure TurnSpeakerOn;
          {This procedure turns on the speaker.  This should be called before}
          {a sound is played, but after the sound card is initialized.       }
        procedure TurnSpeakerOff;
          {Turn off the speaker so that sound can't be heard.  You should do }
          {this when your program is finished playing sound.                 }
        function GetSpeakerState: boolean;
          {Returns the state of the speaker.  Only works on SBPro and higher.}
          {Returns:                                                          }
          {    TRUE:    Speaker is on                                        }
          {    FALSE:   Speaker is off                                       }
        procedure PlaySound(Sound: PSound);
          {Stops any sound in progress and start playing the sound specified.}
          {Sound:       Pointer to buffer that the VOC file was loaded into  }
        procedure PauseSound;
          {Pauses the sound output in progress.                              }
        procedure ContinueSound;
          {Continues sound output stopped by Pause.                          }
        procedure BreakLoop;
          {Stops the loop at the end of the current iteration and continues  }
          {with the next block.                                              }
        procedure SetMarkerProc(MarkerProcedure: pointer);
          {Installs a marker handler.  Each time a marker block is reached,  }
          {the procedure specified is called.  Before installing a handler,  }
          {you should store the old handler.  Your handler should also call  }
          {the old handler.  Look in the example program to see how this is  }
          {done.                                                             }
          {MarkerProcedure:  Pointer to the marker procedure                 }
        procedure GetMarkerProc(var MarkerProcedure: pointer);
          {Gets the current marker procedure.                                }
          {MarkerProcedure:  Current marker procedure (nil if none)          }
        var
            SoundPlaying  : boolean;
            Looping       : boolean;
            UnknownBlock  : boolean;
            UnplayedBlock : boolean;
            LastMarker    : word;
    implementation
        uses
            DOS,
            CRT,
            Mem;
        const
            {DSP Commands}
            CmdDirectDAC       = $10;
            CmdNormalDMADAC    = $14;
            Cmd2BitDMADAC      = $16;
            Cmd2BitRefDMADAC   = $17;
            CmdDirectADC       = $20;
            CmdNormalDMAADC    = $24;
            CmdSetTimeConst    = $40;
            CmdSetBlockSize    = $48;
            Cmd4BitDMADAC      = $74;
            Cmd4BitRefDMADAC   = $75;
            Cmd26BitDMADAC     = $76;
            Cmd26BitRefDMADAC  = $77;
            CmdSilenceBlock    = $80;
            CmdHighSpeedDMADAC = $91;
            CmdHighSpeedDMAADC = $99;
            CmdHaltDMA         = $D0;
            CmdSpeakerOn       = $D1;
            CmdSpeakerOff      = $D3;
            CmdGetSpeakerState = $D8;
            CmdContinueDMA     = $D4;
            CmdGetVersion      = $E1;
            DACCommands : array[0..3] of byte = (CmdNormalDMADAC, Cmd4BitDMADAC, Cmd26BitDMADAC, Cmd2BitDMADAC);
        var
            ResetPort    : word;
            ReadPort     : word;
            WritePort    : word;
            PollPort     : word;

            PICPort      : byte;
            IRQStartMask : byte;
            IRQStopMask  : byte;
            IRQIntVector : byte;
            IRQHandlerInstalled : boolean;

            DMAStartMask : byte;
            DMAStopMask  : byte;
            DMAModeReg   : byte;

            OldIntVector : pointer;
            OldExitProc  : pointer;

            MarkerProc   : pointer;
        var
            VoiceStart     : LongInt;
            CurPos         : LongInt;
            CurPageEnd     : LongInt;
            VoiceEnd       : LongInt;
            LeftToPlay     : LongInt;
            TimeConstant   : byte;
            SoundPacking   : byte;
            CurDACCommand  : byte;

            LoopStart      : PBlock;
            LoopsRemaining : word;
            EndlessLoop    : boolean;

            SilenceBlock   : boolean;

            CurBlock       : PBlock;
            NextBlock      : PBlock;

        procedure EnableInterrupts;  InLine($FB); {STI}
        procedure DisableInterrupts; InLine($FA); {CLI}
        procedure WriteDSP(Value: byte);
            Inline
              (
                $8B/$16/>WritePort/    {MOV   DX, WritePort (Variable)  }
                $EC/                   {IN    AL, DX                    }
                $24/$80/               {AND   AL, 80h                   }
                $75/$FB/               {JNZ   -05                       }
                $58/                   {POP   AX                        }
                $8B/$16/>WritePort/    {MOV   DX, WritePort (Variable)  }
                $EE                    {OUT   DX, AL                    }
              );
        function ReadDSP: byte;
            Inline
              (
                $8B/$16/>PollPort/     {MOV   AL, PollPort  (Variable)  }
                $EC/                   {IN    AL, DX                    }
                $24/$80/               {AND   AL, 80h                   }
                $74/$FB/               {JZ    -05                       }
                $8B/$16/>ReadPort/     {MOV   DX, ReadPort  (Variable)  }
                $EC                    {IN    AL,DX                     }
              );
        function InitSB(IRQ: byte; BaseIO: word; DMAChannel: byte): boolean;
            const
                IRQIntNums : array[0..15] of byte =
                    ($08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
                     $70, $71, $72, $73, $74, $75, $76, $77);
            var
                Success: boolean;
            begin
                if IRQ <= 7
                    then PICPort := $21   {INTC1}
                    else PICPort := $A1;  {INTC2}
                IRQIntVector := IRQIntNums[IRQ];
                IRQStopMask  := 1 SHL (IRQ mod 8);
                IRQStartMask := not(IRQStopMask);

                ResetPort := BaseIO + $6;
                ReadPort  := BaseIO + $A;
                WritePort := BaseIO + $C;
                PollPort  := BaseIO + $E;

                DMAStartMask := DMAChannel + $00; {000000xx}
                DMAStopMask  := DMAChannel + $04; {000001xx}
                DMAModeReg   := DMAChannel + $48; {010010xx}

                Success := ResetDSP;
                if Success then InstallHandler;
                InitSB := Success;
            end;
        function EnvironmentSet: boolean;
            begin
                EnvironmentSet := GetEnv('BLASTER') <> '';
            end;
        function GetSetting(BLASTER: string; Letter: char; Hex: boolean; var Value: word): boolean;
            var
                EnvStr: string;
                NumStr: string;
                ErrorCode: integer;
            begin
                EnvStr := BLASTER + ' ';
                Delete(EnvStr, 1, Pos(Letter, EnvStr));
                NumStr := Copy(EnvStr, 1, Pos(' ', EnvStr)-1);
                if Hex
                    then Val('$' + NumStr, Value, ErrorCode)
                    else Val(NumStr, Value, ErrorCode);
                if ErrorCode <> 0
                    then GetSetting := false
                    else GetSetting := true;
            end;
        function GetSettings(var BaseIO, IRQ, DMAChannel: word): boolean;
            var
                EnvStr: string;
                i: byte;
            begin
                EnvStr := GetEnv('BLASTER');
                for i := 1 to Length(EnvStr) do EnvStr[i] := UpCase(EnvStr[i]);
                GetSettings := true;
                if EnvStr = ''
                    then
                        GetSettings := false
                    else
                        begin
                            if not(GetSetting(EnvStr, 'A', true, BaseIO))
                                then GetSettings := false;
                            if not(GetSetting(EnvStr, 'I', false, IRQ))
                                then GetSettings := false;
                            if not(GetSetting(EnvStr, 'D', false, DMAChannel))
                                then GetSettings := false;
                        end;
            end;
        function InitSBFromEnv: boolean;
            var
                IRQ, BaseIO, DMAChannel: word;
            begin
                if GetSettings(BaseIO, IRQ, DMAChannel)
                    then InitSBFromEnv := InitSB(IRQ, BaseIO, DMAChannel)
                    else InitSBFromEnv := false;
            end;
        procedure ShutDownSB;
            begin
                ResetDSP;
                UninstallHandler;
            end;
        function ResetDSP: boolean;
            var
                i: byte;
            begin
                Port[ResetPort] := 1;
                Delay(1);
                Port[ResetPort] := 0;
                i := 1;
                while (ReadDSP <> $AA) and (i < 100) do
                    Inc(i);
                if i < 100
                    then ResetDSP := true
                    else ResetDSP := false;
            end;
        function GetDSPVersion: string;
            var
                MajorByte, MinorByte: byte;
                MajorStr, MinorStr: string;
            begin
                WriteDSP(CmdGetVersion);
                MajorByte := ReadDSP;   Str(MajorByte, MajorStr);
                MinorByte := ReadDSP;   Str(MinorByte, MinorStr);
                GetDSPVersion := MajorStr + '.'  + MinorStr;
            end;
        procedure TurnSpeakerOn;
            begin
                WriteDSP(CmdSpeakerOn);
            end;
        procedure TurnSpeakerOff;
            begin
                WriteDSP(CmdSpeakerOff);
            end;
        function GetSpeakerState: boolean;
            var
                SpeakerByte: byte;
            begin
                WriteDSP(CmdGetSpeakerState);
                SpeakerByte := ReadDSP;
                if SpeakerByte = 0
                    then GetSpeakerState := Off
                    else GetSpeakerState := On;
            end;
        procedure StartDMADSP;
            var
                Page: byte;
                Offset: word;
                Length: word;
                NextPageStart: LongInt;
            begin
                Page := CurPos shr 16;
                Offset := CurPos mod 65536;
                if VoiceEnd < CurPageEnd
                    then Length := LeftToPlay-1
                    else Length := CurPageEnd - CurPos;

                Inc(CurPos, LongInt(Length)+1);
                Dec(LeftToPlay, LongInt(Length)+1);
                Inc(CurPageEnd, 65536);

                WriteDSP(CmdSetTimeConst);
                WriteDSP(TimeConstant);
                Port[$0A] := DMAStopMask;
                Port[$0C] := $00;
                Port[$0B] := DMAModeReg;
                Port[$02] := Lo(Offset);
                Port[$02] := Hi(Offset);
                Port[$03] := Lo(Length);
                Port[$03] := Hi(Length);
                Port[$83] := Page;
                Port[$0A] := DMAStartMask;
                WriteDSP(CurDACCommand);
                WriteDSP(Lo(Length));
                WriteDSP(Hi(Length));
            end;
        procedure CallMarkerProc;
            begin
                if MarkerProc <> nil then Proc(MarkerProc);
            end;
        function HandleBlock(Block: PBlock): boolean;
            begin
                HandleBlock := false;
                case Block^.BlockType
                    of
                        EndBlockNum:
                            begin
                                SoundPlaying := false;
                                HandleBlock := true;
                            end;
                        VoiceBlockNum:
                            begin
                                VoiceStart := GetAbsoluteAddress(Block) + 6;
                                CurPageEnd := ((VoiceStart shr 16) shl 16) + 65536 - 1;
                                LeftToPlay := BlockSize(Block) - 6;
                                VoiceEnd := VoiceStart + LeftToPlay;
                                CurPos := VoiceStart;
                                TimeConstant := PVoiceBlock(Block)^.SR;
                                SoundPacking := PVoiceBlock(Block)^.Packing;
                                CurDACCommand := DACCommands[SoundPacking];
                                StartDMADSP;
                                HandleBlock := true;
                            end;
                        VoiceContinueBlockNum:
                            begin
                                VoiceStart := GetAbsoluteAddress(Block)+4;
                                LeftToPlay := BlockSize(Block) - 4;
                                VoiceEnd := VoiceStart + LeftToPlay;
                                CurPos := VoiceStart;
                                StartDMADSP;
                                HandleBlock := true;
                            end;
                        SilenceBlockNum:
                             begin
                                 SilenceBlock := true;
                                 WriteDSP(CmdSetTimeConst);
                                 WriteDSP(PSilenceBlock(Block)^.SR);
                                 WriteDSP(CmdSilenceBlock);
                                 WriteDSP(Lo(PSilenceBlock(Block)^.Duration+1));
                                 WriteDSP(Hi(PSilenceBlock(Block)^.Duration+1));
                                 HandleBlock := true;
                             end;
                        MarkerBlockNum:
                             begin
                                 LastMarker := PMarkerBlock(Block)^.Marker;
                                 CallMarkerProc;
                             end;
                        MessageBlockNum:
                            begin
                            end;
                        RepeatBlockNum:
                            begin
                                 LoopStart := NextBlock;
                                 LoopsRemaining := PRepeatBlock(Block)^.Count+1;
                                 if LoopsRemaining = 0 {Wrapped around from $FFFF}
                                     then EndlessLoop := true
                                     else EndlessLoop := false;
                                 Looping := true;
                             end;
                        RepeatEndBlockNum:
                             begin
                                 if not(EndlessLoop)
                                     then
                                         begin
                                             Dec(LoopsRemaining);
                                             if LoopsRemaining = 0
                                                 then
                                                     begin
                                                         Looping := false;
                                                         Exit;
                                                     end;
                                         end;
                                 NextBlock := LoopStart;
                             end;
                        NewVoiceBlockNum:
                             begin
                                 if (PNewVoiceBlock(Block)^.Mode = NewStereo) or (PNewVoiceBlock(Block)^.BitsPerSample = 16)
                                     then
                                         UnplayedBlock := true
                                     else
                                         begin
                                             VoiceStart := GetAbsoluteAddress(Block) + 16;
                                             CurPageEnd := ((VoiceStart shr 16) shl 16) + 65536 - 1;
                                             LeftToPlay := BlockSize(Block) - 16;
                                             VoiceEnd := VoiceStart + LeftToPlay;
                                             CurPos := VoiceStart;
                                             TimeConstant := GetSRByte(PNewVoiceBlock(Block)^.SamplingRate);
                                             SoundPacking := PNewVoiceBlock(Block)^.Compression;
                                             CurDACCommand := DACCommands[SoundPacking];
                                             StartDMADSP;
                                             HandleBlock := true;
                                         end;
                             end;
                        else
                             UnknownBlock := true;
                    end;
            end;
        procedure ProcessBlocks;
            begin
                repeat
                    CurBlock := NextBlock;
                    NextBlock := FindNextBlock(pointer(CurBlock));
                until HandleBlock(CurBlock);
            end;
        procedure ClearInterrupt;
            var
                Temp: byte;
            begin
                Temp := Port[PollPort];
                Port[$20] := $20;
            end;
        procedure IntHandler; interrupt;
            begin
                if SilenceBlock {Interrupted because a silence block ended}
                    then
                        begin
                            SilenceBlock := false;
                            ProcessBlocks;
                        end
                    else {Interrupted because a DMA transfer was completed}
                        if LeftToPlay <> 0
                            then StartDMADSP
                            else ProcessBlocks;

                ClearInterrupt;
            end;
        procedure PlaySound(Sound: PSound);
            begin
                PauseSound;
                NextBlock      := PBlock(Sound);
                SoundPlaying   := true;
                Looping        := false;
                LastMarker     := 0;
                UnknownBlock   := false;
                UnplayedBlock  := false;

                LoopStart      := nil;
                LoopsRemaining := 0;
                EndlessLoop    := false;

                ProcessBlocks;
            end;
        procedure PauseSound;
            begin
                WriteDSP(CmdHaltDMA);
            end;
        procedure ContinueSound;
            begin
                WriteDSP(CmdContinueDMA);
            end;
        procedure BreakLoop;
            begin
                LoopsRemaining := 1;
                EndlessLoop := false;
            end;

        procedure StopSBIRQ;
            begin
                Port[PICPort] := Port[PICPort] OR IRQStopMask;
            end;
        procedure StartSBIRQ;
            begin
                Port[PICPort] := Port[PICPort] AND IRQStartMask;
            end;
        procedure InstallHandler;
            begin
                DisableInterrupts;
                StopSBIRQ;
                GetIntVec(IRQIntVector, OldIntVector);
                SetIntVec(IRQIntVector, @IntHandler);
                StartSBIRQ;
                EnableInterrupts;
                IRQHandlerInstalled := true;
            end;
        procedure UninstallHandler;
            begin
                DisableInterrupts;
                StopSBIRQ;
                SetIntVec(IRQIntVector, OldIntVector);
                EnableInterrupts;
                IRQHandlerInstalled := false;
            end;

        procedure SetMarkerProc(MarkerProcedure: pointer);
            begin
                MarkerProc := MarkerProcedure;
            end;
        procedure GetMarkerProc(var MarkerProcedure: pointer);
            begin
                MarkerProcedure := MarkerProc;
            end;
        procedure SBDSPExitProc; far;
            begin
                ExitProc := OldExitProc;
                ResetDSP;
                if (IRQHandlerInstalled = true) then UninstallHandler;
            end;
    begin
        MarkerProc   := nil;
        OldExitProc  := ExitProc;
        ExitProc     := @SBDSPExitProc;
        SoundPlaying := false;
    end. 


{       SBDSP is Copyright 1994 by Ethan Brodsky.  All rights reserved.      }
{$M 16384, 0, 419430   Give some memory to the DOS shell.  If you are not}
{going to shell to DOS, you can remove this line and let your program use}
{all available memory for the heap.}
program PlayVOCDirect;
    uses
        CRT,
        DOS,
        Mem,
        SBDSP,
        VOC;
    const
        IRQ        = 5;
        BaseIO     = $220;
        DMAChannel = 1;
        DefaultVOC = 'C:\MUSIC\ESCAPE2.VOC';
         {Put the name of the VOC file to play here}
         {or pass it as a parameter to the program.}
    var
        VOCFileName : string;
        SoundSize   : LongInt;
        Sound       : PSound;
        Chr         : char;
        OldMarkerProc : pointer;
    function GetHexWordStr(w: word): string;
        const
            HexChars: array [0..$F] of Char = '0123456789ABCDEF';
        begin
            GetHexWordStr := HexChars[Hi(w) shr 4] + HexChars[Hi(w) and $F] +
                             HexChars[Lo(w) shr 4] + HexChars[Lo(w) and $F];
        end;
    procedure DisplayMarker; far;
        var
            Hour, Minute, Second, Sec100: word;
        begin
            GetTime(Hour, Minute, Second, Sec100);
            writeln('Reached marker ', LastMarker,
                    ' at ', Hour, ':', Minute, ':', Second, '.', Sec100);
            if (OldMarkerProc <> nil) then Proc(OldMarkerProc);
              {If another handler is installed, call it}
        end;
    procedure WriteInstructions;
        begin
            writeln('Begining output of sound file');
            writeln('Press <B> to break loop');
            writeln('Press <P> to pause output');
            writeln('Press <C> to continue output');
            writeln('Press <D> to shell to DOS');
            writeln('Press <X> to stop output and exit');
        end;
    begin
        writeln; writeln;

        if EnvironmentSet
            then
                begin
                    if InitSBFromEnv
                        then
                            begin
                                writeln('Sound card initialized correctly using the BLASTER environment variable!');
                                writeln('DSP version ', GetDSPVersion);
                            end
                        else
                            begin
                                writeln('Error initializing sound card!');
                                Halt(255);
                            end;
                end
            else
                begin
                    writeln('BLASTER environment variable not set, using default settings');
                    writeln('IRQ = ', IRQ, '    Base IO = $', GetHexWordStr(BaseIO), '    DMA Channel = ', DMAChannel );
                    if InitSB(IRQ, BaseIO, DMAChannel)
                        then
                            begin
                                writeln('Sound card initialized correctly!');
                                writeln('DSP version ', GetDSPVersion);
                            end
                        else
                            begin
                                writeln('Error initializing sound card!');
                                Halt(255);
                            end;
                end;

        if ParamCount = 0
            then VOCFileName := DefaultVOC
            else VOCFileName := ParamStr(1);
        SoundSize := LoadVOCfile(VOCFileName, Sound);  writeln('Sound file loaded');
        if SoundSize = 0
            then
                begin
                    writeln('Error loading VOC file.  Probably because:');
                    writeln('    1.  There is no VOC file by name ', VOCFileName, '.');
                    writeln('    2.  There is not enough memory to load it.');
                    writeln('        Largest available block:  ', MaxAvail, ' bytes');
                    Halt;
                end;

        GetMarkerProc(OldMarkerProc);
        SetMarkerProc(@DisplayMarker);

        TurnSpeakerOn;
        WriteInstructions;
        PlaySound(Sound);
        repeat
            if KeyPressed
                then
                    begin
                        Chr := UpCase(ReadKey);
                        case Chr
                            of
                                'B':
                                    begin
                                        BreakLoop;
                                        writeln('Broke out of loop');
                                    end;

                                'P':
                                    begin
                                        PauseSound;
                                        writeln('Sound output paused');
                                    end;
                                'C':
                                    begin
                                        ContinueSound;
                                        writeln('Sound output continued');
                                    end;
                                'D':
                                    begin
                                        SwapVectors;
                                        Exec(GetEnv('COMSPEC'), '');
                                        if DOSError <> 0
                                            then
                                                begin
                                                    writeln('Error running COMMAND.COM!');
                                                    Halt(255);
                                                end;
                                        SwapVectors;
                                        WriteInstructions;
                                    end;
                                'X':
                                    begin
                                        PauseSound;
                                        writeln('Sound output stopped!');
                                        Exit;
                                    end;
                            end;
                    end;
            if UnknownBlock
                then
                    begin
                        writeln('An unknown VOC block was reached.  It is probably');
                        writeln('block 8, which I didn''t implement because it is');
                        writeln('useless. (At least for this library it is)');
                        UnknownBlock := false;
                    end;
            if UnplayedBlock
               then
                   begin
                       writeln('A 16-bit or stereo block was reached.  This library');
                       writeln('doesn''t support either of these.');
                       UnplayedBlock := false;
                   end;
        until (SoundPlaying = false);
        TurnSpeakerOff;

        SetMarkerProc(OldMarkerProc); {Not really necessary}
        FreeBuffer(pointer(Sound), SoundSize);
        ShutDownSB;
    end.
