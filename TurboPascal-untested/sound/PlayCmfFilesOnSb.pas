(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0021.PAS
  Description: Play CMF Files on SB
  Author: SWAG SUPPORT TEAM
  Date: 07-16-93  06:29
*)

UNIT CMFTool;
{** Unit - uses SBFMDRV.COM **}
INTERFACE
USES Dos;
TYPE
  CMFFileTyp = FILE;
  CMFDataTyp = Pointer;
  CMFHeader = RECORD
    CMFFileID         : ARRAY[0..3] OF CHAR;
    CMFVersion        : WORD;
    CMFInstrBlockOfs  : WORD;
    CMFMusicBlockOfs  : WORD;
    CMFTickPerBeat    : WORD;
    CMFClockTicksPS   : WORD;
    CMFFileTitleOfs   : WORD;
    CMFComposerOfs    : WORD;
    CMFMusicRemarkOfs : WORD;
    CMFChannelsUsed   : ARRAY[0..15] OF CHAR;
    CMFInstrNumber    : WORD;
    CMFBasicTempo     : WORD;
  END;
CONST
   CMFToolVersion       = 'v1.0';
VAR
   CMFStatusByte      : BYTE;
   CMFErrStat         : WORD;
   CMFDriverInstalled : BOOLEAN;
   CMFDriverIRQ       : WORD;
   CMFSongPaused      : BOOLEAN;
   OldExitProc        : Pointer;
PROCEDURE PrintCMFErrMessage;
FUNCTION  CMFGetSongBuffer(VAR CMFBuffer : Pointer; CMFFile : STRING):BOOLEAN;
FUNCTION  CMFFreeSongBuffer (VAR CMFBuffer : Pointer):BOOLEAN;
FUNCTION  CMFInitDriver : BOOLEAN;
FUNCTION  CMFGetVersion : WORD;
PROCEDURE CMFSetStatusByte;
FUNCTION  CMFSetInstruments(VAR CMFBuffer : Pointer):BOOLEAN;
FUNCTION  CMFSetSingleInstruments(VAR CMFInstrument:Pointer; No:WORD):BOOLEAN;
PROCEDURE CMFSetSysClock(Frequency : WORD);
PROCEDURE CMFSetDriverClock(Frequency : WORD);
PROCEDURE CMFSetTransposeOfs (Offset : INTEGER);
FUNCTION  CMFPlaySong(VAR CMFBuffer : Pointer) : BOOLEAN;
FUNCTION  CMFStopSong : BOOLEAN;
FUNCTION  CMFResetDriver:BOOLEAN;
FUNCTION  CMFPauseSong : BOOLEAN;
FUNCTION  CMFContinueSong : BOOLEAN;
IMPLEMENTATION
TYPE
   TypeCastTyp = ARRAY [0..6000] of Char;
VAR
   Regs : Registers;
   CMFIntern : ^CMFHeader; { Internal pointer to CMF structure }
PROCEDURE PrintCMFErrMessage;
{ PURPOSE : Displays SB error as text; no change to error status. }
BEGIN
   CASE CMFErrStat OF
      100 : Write(' SBFMDRV sound driver not found ');
      110 : Write(' Driver reset successful ');
      200 : Write(' CMF file not found ');
      210 : Write(' No memory free for CMF file ');
      220 : Write(' File not in CMF format ');
      300 : Write(' Memory allocation error occurred ');
      400 : Write(' Too many instruments defined ');
      500 : Write(' CMF data could not be played ');
      510 : Write(' CMF data could not be stopped ');
      520 : Write(' CMF data could not be paused ');
      530 : Write(' CMF data could not be continued ');
      END;
   END;
FUNCTION Exists (Filename : STRING):BOOLEAN;
{ PURPOSE : Checks for the existence of a file, and returns a Boolean exp. }
VAR
   F : File;
BEGIN
   Assign(F,Filename);
{$I-}
   Reset(F);
   Close(F);
{$I+}
   Exists := (IoResult = 0) AND (Filename <> '');
   END;
PROCEDURE AllocateMem (VAR Pt : Pointer; Size : LongInt);
{ Reserves as many bytes as Size allows, then sets the pointer in the
  Pt variable. If not enough memory is available, Pt is set to NIL. }
VAR
   SizeIntern : WORD;
BEGIN
   Inc(Size,15);
   SizeIntern := (Size shr 4);
   Regs.AH := $48;
   Regs.BX := SizeIntern;
   MsDos(Regs);
   IF (Regs.BX <> SizeIntern) THEN Pt := NIL
   ELSE Pt := Ptr(Regs.AX,0);
   END;
FUNCTION  CheckFreeMem (VAR CMFBuffer : Pointer; CMFSize : LongInt):BOOLEAN;
{ Ensures that enough memory has been allocated for CMF file. }
BEGIN
   AllocateMem(CMFBuffer,CMFSize);
   CheckFreeMem := CMFBuffer <> NIL;
   END;
FUNCTION  CMFGetSongBuffer(VAR CMFBuffer : Pointer; CMFFile : STRING):BOOLEAN;
{ Loads file into memory; returns TRUE if load successful, FALSE if not. }
CONST
   FileCheck : STRING[4] = 'CTMF';
VAR
   CMFFileSize : LongInt;
   FPresent    : BOOLEAN;
   VFile       : CMFFileTyp;
   Segs        : WORD;
   Read        : WORD;
   Checkcount  : BYTE;
BEGIN
   FPresent := Exists(CMFFile);

{ CMF file could not be found }
   IF Not(FPresent) THEN BEGIN
      CMFGetSongBuffer := FALSE;
      CMFErrStat   := 200;
      EXIT
      END;
   Assign(VFile,CMFFile);
   Reset(VFile,1);
   CMFFileSize := Filesize(VFile);
   AllocateMem(CMFBuffer,CMFFileSize);
{ Insufficient memory for CMF file }
   IF (CMFBuffer = NIL) THEN BEGIN
      Close(VFile);
      CMFGetSongBuffer := FALSE;
      CMFErrStat   := 210;
      EXIT;
      END;
   Segs := 0;
   REPEAT
      Blockread(VFile,Ptr(seg(CMFBuffer^)+4096*Segs,Ofs(CMFBuffer^))^,$FFFF,Read
);
      Inc(Segs);
      UNTIL Read = 0;
   Close(VFile);
{ File not in CMF format }
   CMFIntern := CMFBuffer;
   CheckCount := 1;
   REPEAT
      IF FileCheck[CheckCount] = CMFIntern^.CMFFileID[CheckCount-1]
         THEN Inc(CheckCount)
         ELSE CheckCount := $FF;
      UNTIL CheckCount >= 3;
   IF NOT(CheckCount = 3) THEN BEGIN
      CMFGetSongBuffer := FALSE;
      CMFErrStat   := 220;
      EXIT;
      END;
{ Load was successful }
   CMFGetSongBuffer := TRUE;
   CMFErrStat   := 0;
   END;
FUNCTION CMFFreeSongBuffer (VAR CMFBuffer : Pointer):BOOLEAN;
{ Frees memory allocated for CMF file. }
BEGIN
   Regs.AH := $49;
   Regs.ES := seg(CMFBuffer^);
   MsDos(Regs);
   CMFFreeSongBuffer := TRUE;
   IF (Regs.AX = 7) OR (Regs.AX = 9) THEN BEGIN
      CMFFreeSongBuffer := FALSE;
      CMFErrStat := 300
      END;
   END;
FUNCTION CMFInitDriver : BOOLEAN;
{ Checks for SBFMDRV.COM resident in memory, and resets driver }
CONST
   DriverCheck :STRING[5] = 'FMDRV';
VAR
   ScanIRQ,
   CheckCount  : BYTE;
   IRQPtr,
   DummyPtr    : Pointer;

BEGIN
{ Possible SBFMDRV interrupts lie in range $80 - $BF }
   FOR ScanIRQ := $80 TO $BF DO BEGIN
      GetIntVec(ScanIRQ, IRQPtr);
      DummyPtr := Ptr(Seg(IRQPtr^), $102);
{ Check for string 'FMDRV' in interrupt program. }
      CheckCount := 1;
      REPEAT
         IF DriverCheck[CheckCount] = TypeCastTyp(DummyPtr^)[CheckCount]
            THEN Inc(CheckCount)
            ELSE CheckCount := $FF;
         UNTIL CheckCount >= 5;
      IF (CheckCount = 5) THEN BEGIN
{ String found; reset executed }
         Regs.BX := 08;
         CMFDriverIRQ := ScanIRQ;
         Intr(CMFDriverIRQ, Regs);
         IF Regs.AX = 0 THEN
            CMFInitDriver := TRUE
         ELSE BEGIN
            CMFInitDriver := FALSE;
            CMFErrStat    := 110;
            END;
         Exit;
         END
      ELSE BEGIN
{ String not found }
         CMFInitDriver := FALSE;
         CMFErrStat := 100;
         END;
      END;
   END;
FUNCTION CMFGetVersion : WORD;
{ Gets version number from SBFMDRV driver. }
BEGIN
   Regs.BX := 0;
   Intr(CMFDriverIRQ,Regs);
   CMFGetVersion := Regs.AX;
   END;
PROCEDURE CMFSetStatusByte;
{ Place driver status byte in CMFStatusByte variable. }
BEGIN
   Regs.BX:= 1;
   Regs.DX:= Seg(CMFStatusByte);
   Regs.AX:= Ofs(CMFStatusByte);
   Intr(CMFDriverIRQ, Regs);
   END;
FUNCTION CMFSetInstruments(VAR CMFBuffer : Pointer):BOOLEAN;
{ Sets SB card FM registers to instrumentation stated in CMF file. }
BEGIN
    CMFIntern := CMFBuffer;
    IF CMFIntern^.CMFInstrNumber > 128 THEN BEGIN
       CMFErrStat := 400;
       CMFSetInstruments := FALSE;
       Exit;
       END;
    Regs.BX := 02;
    Regs.CX := CMFIntern^.CMFInstrNumber;
    Regs.DX := Seg(CMFBuffer^);
    Regs.AX := Ofs(CMFBuffer^)+CMFIntern^.CMFInstrBlockOfs;
    Intr(CMFDriverIRQ, Regs);
    CMFSetInstruments := TRUE;
   END;
FUNCTION CMFSetSingleInstruments(VAR CMFInstrument:Pointer; No:WORD):BOOLEAN;
{ Sets SB FM registers to instrument values corresponding to the
  data structure following the CMFInstrument pointer. }
BEGIN
    IF No > 128 THEN BEGIN
       CMFErrStat := 400;
       CMFSetSingleInstruments := FALSE;
       Exit;
       END;
    Regs.BX := 02;
    Regs.CX := No;
    Regs.DX := Seg(CMFInstrument^);
    Regs.AX := Ofs(CMFInstrument^);
    Intr(CMFDriverIRQ, Regs);
    CMFSetSingleInstruments := TRUE;
   END;
PROCEDURE CMFSetSysClock(Frequency : WORD);
{ Sets default value of timer 0 to new value. }
BEGIN
   Regs.BX := 03;
   Regs.AX := (1193180 DIV Frequency);
   Intr(CMFDriverIRQ, Regs);
   END;
PROCEDURE CMFSetDriverClock(Frequency : WORD);
{ Sets driver timer frequency to new value. }

BEGIN
   Regs.BX := 04;
   Regs.AX := (1193180 DIV Frequency);
   Intr(CMFDriverIRQ, Regs);
   END;
PROCEDURE CMFSetTransposeOfs (Offset : INTEGER);
{ Transposes all notes in the CMF file by "Offset." }
BEGIN
   Regs.BX := 05;
   Regs.AX := Offset;
   Intr(CMFDriverIRQ, Regs);
   END;
FUNCTION CMFPlaySong(VAR CMFBuffer : Pointer) : BOOLEAN;
{ Initializes all important parameters and starts song playback. }
VAR
   Check : BOOLEAN;
BEGIN
   CMFIntern := CMFBuffer;
{ Set driver clock frequency }
   CMFSetDriverClock(CMFIntern^.CMFClockTicksPS);
{ Set instruments }
   Check := CMFSetInstruments(CMFBuffer);
   IF Not(Check) THEN Exit;
   Regs.BX := 06;
   Regs.DX := Seg(CMFIntern^);
   Regs.AX := Ofs(CMFIntern^)+CMFIntern^.CMFMusicBlockOfs;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN BEGIN
      CMFPlaySong := TRUE;
      CMFSongPaused := FALSE;
      END
   ELSE BEGIN
      CMFPlaySong := FALSE;
      CMFErrStat := 500;
      END;
   END;
FUNCTION CMFStopSong : BOOLEAN;
{ Attempts to stop song playback. }
BEGIN
   Regs.BX := 07;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN
      CMFStopSong := TRUE
   ELSE BEGIN
      CMFStopSong := FALSE;
      CMFErrStat  := 510;
      END;
   END;
FUNCTION CMFResetDriver:BOOLEAN;
{ Resets driver to starting status. }
BEGIN
   Regs.BX := 08;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN
      CMFResetDriver := TRUE
   ELSE BEGIN
      CMFResetDriver := FALSE;
      CMFErrStat    := 110;
      END;
   END;
FUNCTION CMFPauseSong : BOOLEAN;
{ Attempts to pause song playback. If pause is possible, this
  function sets the CMFSongPaused variable to TRUE. }
BEGIN
   Regs.BX := 09;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN BEGIN
      CMFPauseSong  := TRUE;
      CMFSongPaused := TRUE;
      END
   ELSE BEGIN
      CMFPauseSong := FALSE;
      CMFErrStat   := 520;
      END;
   END;
FUNCTION CMFContinueSong : BOOLEAN;
{ Attempts to continue playback of a paused song. If continuation
  is possible, this function sets CMFSongPaused to FALSE. }
BEGIN
   Regs.BX := 10;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN BEGIN
      CMFContinueSong  := TRUE;
      CMFSongPaused    := FALSE;
      END
   ELSE BEGIN
      CMFContinueSong := FALSE;
      CMFErrStat      := 530;

      END;
   END;
{$F+}
PROCEDURE CMFToolsExitProc;
{$F-}
{ Resets the status byte address, allowing this program to exit.}
BEGIN
   Regs.BX:= 1;
   Regs.DX:= 0;
   Regs.AX:= 0;
   Intr(CMFDriverIRQ, Regs);
   ExitProc := OldExitProc;
   END;
BEGIN
{ Reset old ExitProc to the Tool unit proc }
   OldExitProc := ExitProc;
   ExitProc := @CMFToolsExitProc;
{ Initialize variables }
   CMFErrStat := 0;
   CMFSongPaused := FALSE;
{ Initialize driver }
   CMFDriverInstalled := CMFInitDriver;
   IF CMFDriverInstalled THEN BEGIN
      CMFStatusByte := 0;
      CMFSetStatusByte;
      END;
   END.

{ ---------------------    DEMO PROGRAM  -----------------  }

Program CMFDemo;
{* Demo program for CMFTOOL unit *}
{$M 16384,0,65535}
Uses CMFTool,Crt;
VAR
   Check      : BOOLEAN;
   SongName   : String;
   SongBuffer : CMFDataTyp;
PROCEDURE TextNumError;
{* INPUT   : None; data comes from CMFErrStat global variable
 * OUTPUT  : None
 * PURPOSE : Displays SB error as text, including error number. }
BEGIN
   Write(' Error #',CMFErrStat:3,': ');
   PrintCMFErrMessage;
   WriteLn;
   Halt(CMFErrStat);
   END;
BEGIN
   ClrScr;
{ Displays error if SBFMDRV driver has not been installed }
   IF Not (CMFDriverInstalled) THEN TextNumError;
{ If no song name is included with command line parameters,
  program searches for the default name (here STARFM.CMF). }
   IF ParamCount = 0 THEN SongName := 'STARFM.CMF'
                     ELSE SongName := ParamStr(1);
{ Display driver's version and subversion numbers }
   GotoXY(28,5);
   Write  ('SBFMDRV Version ',Hi(CMFGetVersion):2,'.');
   WriteLn(Lo(CMFGetVersion):2,' loaded');
{ Display interrupt number in use }
   GotoXY(24,10);
   Write  ('System interrupt (IRQ) ');
   WriteLn(CMFDriverIRQ:3,' in use');
   GotoXY(35,15);
   WriteLn('Song Status');
   GotoXY(31,23);
   WriteLn('Song name: ',SongName);
{ Load song file }
   Check := CMFGetSongBuffer(SongBuffer,SongName);
   IF NOT(Check) THEN TextNumError;
{ CMFSetTransposeOfs() controls transposition down or up of the loaded song
  (positive values transpose up, negative values transpose down). The value
  0 plays the loaded song in its original key. }
   CMFSetTransposeOfs(0); { Experiment with this value }
{ Play song }
   Check := CMFPlaySong(SongBuffer);
   IF NOT(Check) THEN TextNumError;
{ During playback, display status byte }
   REPEAT
      GotoXY(41,17);Write(CMFStatusByte:3);
      UNTIL (KeyPressed OR (CMFStatusByte = 0));
{ Stop playback if user presses a key }
   IF KeyPressed THEN BEGIN
      Check := CMFStopSong;
      IF NOT(Check) THEN TextNumError;
      END;
{ Re-initialize driver }
   Check := CMFResetDriver;
   IF NOT(Check) THEN TextNumError;
{ Free song file memory }
   Check := CMFFreeSongBuffer(SongBuffer);
   IF NOT(Check) THEN TextNumError;
   END.

