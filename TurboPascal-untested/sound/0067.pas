{
> Umm, I don't think you understood my question...  I don't know how
> to play 8 or 16 bit sound  (Like a mod file), I CAN do FM...
> I just want help on making the routines to play things like a
> mod...
> Gotta, go...  Could you please see if you could help me on this,
> though? Justin Greer

 Here is some Pascal source code to Read a (Standard) MOD 4 Tracks:

 READ it's not play, that is another story...

 Here is some example files that you sould see:
 ==============================================
 DEMOVT15.ZIP    MOD's 8 Borland C/ MS C/ (Real Mode/Protected Mode)
                 PAS/C/Assembly
 GOLDPALY.ZIP    MOD's 4 tracks Assembly/Pascal
 MDSS031A.ZIP    MOD's e S3M's  C/Pascal/Assembly
 PPS.ZIP         MOD's 4 tracks Assembly
 TNYPL212.ZIP    MOD's 8 tracks C/Assembly (Real Mode/Protected Mode)
 VTSRC12B.ZIP    MOD's 8 Pascal source of a player
}

Unit MODTool;
{* Reads information from a Soundtracker module. *}
INTERFACE
CONST
   MODToolVersion = 'v1.0';
   MaxIns = 31;
   Octaves : ARRAY[1..36] OF WORD =
      (856,808,762,720,678,640,604,570,538,508,480,453,
       428,404,381,360,339,320,302,285,269,254,240,226,
       214,202,190,180,170,160,151,143,135,127,120,113);
TYPE
   InstrumentType = RECORD
      SampName : ARRAY[0..21] OF CHAR;
      SampLen  : WORD;
      SampTune : BYTE;
      SampAmp  : BYTE;
      SampRepS : WORD;
      SampRepL : WORD;
      END;
   MODHeaderType = RECORD
      MODName  : ARRAY[0..19] OF CHAR;
      MODInstr : ARRAY[1..MaxIns] OF InstrumentType;
      MODLen   : BYTE;
      MODMisc  : BYTE;
      MODPattr : ARRAY[1..128] OF BYTE;
      MODSign  : ARRAY[1..4] OF CHAR;
      END;
   NoteType    = ARRAY[1..4] OF BYTE;
   PatternLine = RECORD
      Channel1, Channel2,
      Channel3, Channel4  : NoteType;
      END;
   PatternType = ARRAY[1..64] OF PatternLine;
PROCEDURE BuildModScript(ModFilename, ScriptFilename : STRING);
IMPLEMENTATION
FUNCTION ConvertString(Source : Pointer; Size : BYTE):String;
{* INPUT   : Pointer to an ARRAY OF CHAR, length in BYTES
 * OUTPUT  : Pascal string in Size bytes length
 * PURPOSE : Convertor, e.g., converts string ending in NULL to a Pascal
              string. This routine can convert any other memory range
              into a string. }
VAR
   WorkStr : String;
BEGIN
   Move(Source^,WorkStr[1],Size);
   WorkStr[0] := CHR(Size);
   ConvertString := WorkStr;
   END;
FUNCTION Words(FalseWord : WORD):WORD;
{* INPUT   : Word variable with rotated high/low-byte
 * OUTPUT  : Restored Word, multiplied by 2
 * PURPOSE : Gets a Word value from the MOD file and restores the proper
             high-byte/low-byte sequence; also multiplies the result by
             2, as this function must store the information as Word units
             to coincide with sample length. }
BEGIN
   Words := (Hi(FalseWord)+Lo(FalseWord)*256)*2;
   END;

FUNCTION NoteName(Period : WORD):String;
{* INPUT   : Note length value as WORD
 * OUTPUT  : Note in text as string
 * PURPOSE : Using tuning table, converts pitch values to note names. }
CONST
   NNames : ARRAY[0..11] OF String[2] =
      ('C-','C#','D-','D#','E-','F-','F#','G-','G#','A-','A#','B-');
VAR
   WorkStr : String;
   NCount  : BYTE;
BEGIN
   NCount := 1;
   IF (Period = 0) THEN BEGIN
      NCount := 37;
      NoteName := '----';
      END;
   WHILE (NCount <= 36) DO BEGIN
      IF (Period = Octaves[NCount]) THEN BEGIN
         Dec(Ncount);
         Str((NCount DIV 12)+1:2,WorkStr);
         NoteName := NNames[NCount-(NCount DIV 12)*12]+WorkStr;
         NCount := 37;
         END;
      Inc(NCount);
      END;
   END;
PROCEDURE BuildModScript(ModFilename, ScriptFilename : STRING);
{* INPUT   : Module name and name of desired script file
 * OUTPUT  : None
 * PURPOSE : Reads a SoundTracker module and writes the most important
             information to a text file.  The module _must_ contain 31
             instruments, or incorrect results will occur.
             Patterns are stored in sequence. }
VAR
   ModFile  : File;
   ScrFile  : TEXT;
   Result   : WORD;
   Header   : ModHeaderType;
   DummyStr : String;
   InsCount : BYTE;
   PatCount : BYTE;
   Pattern  : PatternType;
   HiPatt   : BYTE;
   Counter  : WORD;
BEGIN
{ Make sure that desired MOD file is available }
{$I-}
   Assign(ModFile,ModFilename);
   Reset(ModFile);
   Close(ModFile);
{$I+}
   IF (IOResult <> 0) THEN BEGIN
      Writeln('Cannot find MOD file: ',ModFilename:12,'. Sorry.');
      HALT(100);
      END;
{ Read MOD header data into Header variable }
   Reset(ModFile,1);
   BlockRead(ModFile,Header,SizeOf(Header),Result);
{ Analyze data in Header }
   WITH Header DO BEGIN
      Assign(ScrFile,ScriptFilename);
      ReWrite(ScrFile);
      WriteLn(ScrFile,'Soundtracker module script file ',ModFilename);
      WriteLn(ScrFile);
{ Write module name }
      DummyStr := ConvertString(Addr(MODName),SizeOf(MODName));
      WriteLn(ScrFile,'Module name  : ',DummyStr);
{ Write module length (valid numbers = 1 - 128) }
      Str(MODLen,DummyStr);
      Write  (ScrFile,'Module length  : ',DummyStr, ' Pattern(s),');
{ Search for highest pattern number }
      HiPatt := 0;
      FOR PatCount := 1 TO MODLen DO
         IF ModPattr[PatCount] >= HiPatt THEN
            HiPatt := ModPattr[PatCount];
      Str(HiPatt,DummyStr);
      WriteLn(ScrFile,' - highest pattern number is ',DummyStr);
      WriteLn(ScrFile);
{ Write instrument information }
      FOR InsCount := 1 TO MaxIns DO BEGIN
         WITH MODInstr[InsCount] DO BEGIN
            DummyStr := ConvertString(Addr(SampName),SizeOf(SampName));
            WriteLn(ScrFile,'Instrument # ',InsCount:2,' = ',DummyStr);
            Str(Words(SampLen):6,DummyStr);
            WriteLn(ScrFile,'Length in bytes = ',DummyStr);
            Str(SampTune:6,DummyStr);
            WriteLn(ScrFile,'Fine tune       = ',DummyStr);
            Str(SampAmp:6,DummyStr);
            WriteLn(ScrFile,'Volume          = ',DummyStr);
            Str(Words(SampRepS):6,DummyStr);
            WriteLn(ScrFile,'Repeat start    = ',DummyStr);
            Str(Words(SampRepL):6,DummyStr);
            WriteLn(ScrFile,'Repeat length   = ',DummyStr);
            WriteLn(ScrFile,'----------------------------------------');
            END;
      END;
{ Read patterns and write note values into script file }
{ (parentheses following pitch name contain sample number of note) }
      FOR PatCount := 1 TO HiPatt+1 DO BEGIN
         IF NOT(EOF(ModFile)) THEN
            Blockread(ModFile,Pattern,SizeOf(Pattern),Result);
         WriteLn('Read pattern ',PatCount-1:3);
         WriteLn(ScrFile,'Pattern number : ',PatCount-1:3);
         WriteLn(ScrFile,'Lines #   Chan.1     Chan.2     Chan.3     Chan.4');
         FOR Counter := 1 TO 64 DO BEGIN
            Write(ScrFile,'  ',Counter:2,'    ');
            WITH Pattern[Counter] DO BEGIN
{ Display note and sample number for channel 1 }
               DummyStr := NoteName((Channel1[1] AND $0F)*256+(Channel1[2]));
               Write(ScrFile,' ',DummyStr);
               Write(ScrFile,'(',((Channel1[1] AND $F0)+
                                  (Channel1[3] SHR 4)):2,')  ');
{ Display note and sample number for channel 2 }
               DummyStr := NoteName((Channel2[1] AND $0F)*256+(Channel2[2]));
               Write(ScrFile,' ',DummyStr);
               Write(ScrFile,'(',((Channel2[1] AND $F0)+
                                  (Channel2[3] SHR 4)):2,')  ');
{ Display note and sample number for channel 3 }
               DummyStr := NoteName((Channel3[1] AND $0F)*256+(Channel3[2]));
               Write(ScrFile,' ',DummyStr);
               Write(ScrFile,'(',((Channel3[1] AND $F0)+
                                  (Channel3[3] SHR 4)):2,')  ');
{ Display note and sample number for channel 4 }
               DummyStr := NoteName((Channel4[1] AND $0F)*256+(Channel4[2]));
               Write(ScrFile,' ',DummyStr);
               Write(ScrFile,'(',((Channel4[1] AND $F0)+
                                  (Channel4[3] SHR 4)):2,')  ');
               WriteLn(ScrFile);
               END;
            END;
         WriteLn(ScrFile,'-------------------------------------------------');
         WriteLn(ScrFile);
         END;
{ Close script file and MOD file }
      Close(ScrFile);
      CLose(ModFile);
      END;
   END;
END.

{

MAIN FILE to test MODTOOL.PAS
-------------------------------- MODSCRIP.MOD ------------------------------
}
Program MODScript;
{* Demo program for MODTOOL unit: Creating a script file *}
Uses MODTool; { Use MODTool unit }
VAR
   WorkStr : String; { String for processing provided filename }
BEGIN
   WriteLn('MODScript v1.0 (C) 1992 Abacus -  Author: Axel Stolz');
{ No command line parameter given? display syntax }
   IF (ParamCount = 0) THEN BEGIN
      WriteLn('Syntax : MODSCRIP module[.MOD]');
      HALT(0);
      END;
{ Pass command line paramters }
   WorkStr := ParamStr(1);
{ If user enters filename and extension, replace extension with ".MOD"}
   IF Pos('.',WorkStr) > 0 THEN
      WorkStr := Copy(WorkStr,1,Pos('.',WorkStr)-1);
   WriteLn('Create a script file from a sound module ',WorkStr,'.MOD !');
{ Create script file }
   BuildModScript(WorkStr+'.MOD',WorkStr+'.TXT');
   WriteLn('Ready. Result stored in ',WorkStr,'.TXT.');
END.
