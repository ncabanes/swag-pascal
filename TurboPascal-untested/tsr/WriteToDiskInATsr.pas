(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0008.PAS
  Description: Write to DISK in a TSR
  Author: STEVE MULLIGAN
  Date: 07-16-93  06:03
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-23-93 (10:24)             Number: 27349
From: STEVE MULLIGAN               Refer#: NONE
  To: EDWARD WALKER                 Recvd: NO  
Subj: TSRS THAT WRITE TO DISK..      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
Tuesday June 22 1993 02:38, Edward Walker wrote to All:

 EW> What do I need to set up in the code to write to disk in a TSR?

Here's a TSR called BootRes.  It opens a file and writes to disk every x
seconds :

=-=-=-=-=-=-=-=-= PART 1 =-=-=-=-=-=-=-=-=-=
program BootRes;

{$M 2048,0,0}
{$F+}

Uses BootVars, Crt, Dos;

const
 OLDSTACKSS :  WORD = 0;
 OLDSTACKSP :  WORD = 0;
 STACKSW :    INTEGER = - 1;
 OurStackSeg : word = 0;
 OurStackSp  : word = 0;
 DosDelimSet : set of Char = ['\', ':', #0];

var
 R                    : registers;
 DosSeg, DosBusy              : word;
 Tick, WaitBuf               : integer;
 NeedPop                 : boolean;

PROCEDURE BEGINint;
INLINE($FF/$06/STACKSW/
   $75/$10/
   $8C/$16/OLDSTACKSS/
       $89/$26/OLDSTACKSP/
       $8E/$16/OURSTACKSEG/
       $8B/$26/OURSTACKSP);

PROCEDURE ENDint;
INLINE($FF/$0E/STACKSW/
       $7D/$08/
       $8E/$16/OLDSTACKSS/
   $8B/$26/OLDSTACKSP);

PROCEDURE CALLPOP(SUB:POINTER);
BEGIN
INLINE($FF/$5E/$06);
END;

PROCEDURE CLI; INLINE($FA);
PROCEDURE STI; INLINE($FB);

function Exist(fname : string) : boolean;
var
     f1  : file;  err : integer;
begin
     {$I-}
     assign(f1,fname);     reset(f1);     err := ioresult;
     {$I+}
     if  err = 0 then close(f1);     exist := err = 0;
end;

  function AddBackSlash(DirName : string) : string;
    {-Add a default backslash to a directory name}
  begin
    if DirName[Length(DirName)] in DosDelimSet then
      AddBackSlash := DirName
    else
      AddBackSlash := DirName+'\';
  end;

procedure TsrCrap;
begin
 CLI;
 BEGINint;
 STI;

 NeedPop := False;

 GetDate(h, m, s, hund);
 TimeLoad.Year := h;
 TimeLoad.Month := m;
 TimeLoad.Day := s;
 GetTime(h, m, s, hund);
 TimeLoad.Hour := h;
 TimeLoad.Min := m;
 TimeLoad.Sec := s;

 DoDate;
 DoDate2;

 if not exist(LogName) then begin
  assign(LogFile, LogName);
  rewrite(LogFile);
  write(LogFile, LogRec);
  close(LogFile);
 end;

 assign(LogFile, LogName);
 reset(LogFile);
 if FileSize(LogFile) = 0 then begin
  close(LogFile);
  assign(LogFile, LogName);
  rewrite(LogFile);
  write(LogFile, LogRec);
  close(LogFile);
  assign(LogFile, LogName);
  reset(LogFile);
 end;
 seek(LogFile, FileSize(LogFile) - 1);
 read(LogFile, LogRec);
 DoDate2;
 seek(LogFile, FileSize(LogFile) - 1);
 write(LogFile, LogRec);
 close(LogFile);
 Tick := 0;

 CLI;
 ENDint;
 STI;
end;
=-=-=-=-=-=-=-=-= PART 1 =-=-=-=-=-=-=-=-=-=

--- GoldED 2.41
 * Origin: Ask me about SubMove * Carp, Ontario (1:163/307.30)
===========================================================================
 BBS: Canada Remote Systems
Date: 06-23-93 (10:25)             Number: 27350
From: STEVE MULLIGAN               Refer#: NONE
  To: EDWARD WALKER                 Recvd: NO  
Subj: TSRS THAT WRITE TO DISK..      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
=-=-=-=-=-=-=-=-= PART 2 =-=-=-=-=-=-=-=-=-=
procedure RunTSR; Interrupt;
begin
 CLI;
 BEGINint;
 STI;
 inc(Tick);
 if Tick > 18.2 * WaitBuf then begin
  NeedPop := True;
  if MEM[DosSeg:DosBusy] = 0 then begin
   NeedPop := False;
   PORT[$20] := $20;
   TsrCrap;
  end;
 end;
 CLI;
 ENDint;
 STI;
end;

procedure Int28TSR; Interrupt;
begin
 CLI;
 BEGINint;
 STI;
 if NeedPop = True then TsrCrap;
 CLI;
 ENDint;
 STI;
end;

procedure InitTSR;
begin
 OurStackSeg := SSEG;
 InLine($89/$26/OurStackSp);
 R.Ah := $34;
 MSDOS(R);
 DosSeg := R.ES;
 DosBusy := R.BX;
end;

procedure ShowHelp;
begin
 writeln('Usage : BOOTRES <command line options>');
 writeln;
 writeln('Valid Options : #    Number of seconds to wait before writing current
time');
 writeln('                /?   This screen');
end;

begin
 InitTSR;

 GetDir(0, LogName);
 LogName := AddBackSlash(LogName) + 'BOOTLOG.DAT';
 WaitBuf := 60;

 writeln;

 if ParamCount > 0 then begin
  if ParamStr(1) = '/?' then begin
   ShowHelp;
   halt(0);
  end;
  val(ParamStr(1), WaitBuf, Tick);
  if (Tick <> 0) or ((WaitBuf > 60 * 10) or (WaitBuf < 5)) then begin
   writeln('Must be an integer between 5 and ', 60 * 10);
   halt(1);
  end;
 end else begin
  writeln('Type BOOTRES /? for help');
  writeln;
 end;

 Tick := 0;

 SetIntVec($28,@Int28TSR);
 SetIntVec($1C,@RunTSR);

 writeln('BootRes installed');

 keep(0);
end. =-=-=-=-=-=-=-=-= PART 2 =-=-=-=-=-=-=-=-=-=

--- GoldED 2.41
 * Origin: Ask me about VoteFix * Carp, Ontario (1:163/307.30)
===========================================================================
 BBS: Canada Remote Systems
Date: 06-23-93 (10:26)             Number: 27351
From: STEVE MULLIGAN               Refer#: NONE
  To: EDWARD WALKER                 Recvd: NO  
Subj: TSRS THAT WRITE TO DISK..      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
=-=-=-=-=-=-=-=-= PART 3 =-=-=-=-=-=-=-=-=-=
unit BootVars;

interface

uses Dos;

const
 Version  = '1.00';
 ProgName = 'BootLog';
        CopYear  = '1992 - 1993';

type
 LogType = record
  TimeLoad : DateTime;
  TimeOff : DateTime;
 end;

var
 LogFile    : file of LogType;
 LogRec    : LogType;
 h, m, s, hund  : word;
 TimeLoad, TimeOff : DateTime;
 LogName    : string;

procedure DoDate;
procedure DoDate2;

implementation

procedure DoDate;
begin
 LogRec.TimeLoad.Year  := TimeLoad.Year;
 LogRec.TimeLoad.Month := TimeLoad.Month;
 LogRec.TimeLoad.Day   := TimeLoad.Day;
 LogRec.TimeLoad.Hour  := TimeLoad.Hour;
 LogRec.TimeLoad.Min   := TimeLoad.Min;
 LogRec.TimeLoad.Sec   := TimeLoad.Sec;
end;

procedure DoDate2;
begin
 LogRec.TimeOff.Year   := TimeLoad.Year;
 LogRec.TimeOff.Month  := TimeLoad.Month;
 LogRec.TimeOff.Day    := TimeLoad.Day;
 LogRec.TimeOff.Hour   := TimeLoad.Hour;
 LogRec.TimeOff.Min    := TimeLoad.Min;
 LogRec.TimeOff.Sec    := TimeLoad.Sec;
end;

end.
=-=-=-=-=-=-=-=-= PART 3 =-=-=-=-=-=-=-=-=-=

--- GoldED 2.41
 * Origin: Ask me about SubMove * Carp, Ontario (1:163/307.30)

