(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0019.PAS
  Description: Dpmi HiRes Timer
  Author: KAI ROHRBACHER
  Date: 08-24-94  13:21
*)


UNIT asytimer;
{Purpose  : High resolution timer which runs asynchronous to the     }
{           rest of the program                                      }
{Author   : Kai Rohrbacher, kai.rohrbacher@logo.ka.sub.org           }
{Language : BorlandPascal 7.0 }
{Date     : 26.06.1994        }
{Remarks  : - Runs both in real- and protected mode.                 }
{           - Only available on AT-style machines or better (uses    }
{             real time clock services)                              }
{           - Will "fall through" on PC's transparently: behaves as  }
{             if time ran off immediately}

INTERFACE

VAR TimeFlag:^BYTE;

FUNCTION ATClockAvailable:BOOLEAN;
PROCEDURE SetCycleTime(microseconds:LONGINT);
FUNCTION TimeOver:BOOLEAN;
  INLINE($C4/$1E/TimeFlag/   {LES BX,TimeFlag}
         $26/$8A/$07/        {MOV AL,ES:[BX] }
         $B1/$07/            {MOV CL,7 }
         $D2/$E8);           {SHR AL,CL}
PROCEDURE Trigger;

IMPLEMENTATION

USES CRT;

{$IFDEF DPMI}
TYPE Treg=RECORD  {stuff for that dumb DPMI-server}
           CASE BYTE OF
            0:(LoLo,LoHi,HiLo,HiHi:BYTE);
            1:(Lo16,Hi16:WORD);
          END;
     Tregisters32=
       RECORD
         EDI,ESI,EBP,junk32,EBX,EDX,ECX,EAX:Treg;
         Flags32,ES,DS,FS,GS,IP,CS,SP,SS:WORD
       END;
VAR regs32:Tregisters32;

 FUNCTION EmulateInt(IntNr:BYTE; VAR regs32:Tregisters32):BOOLEAN;
 ASSEMBLER; {emulate real mode interrupt IntNr with registers regs32}
 ASM
   MOV AX,300h   {emulate INT}
   XOR BH,BH     {no A20 gate reset, please}
   MOV BL,IntNr  {INT to emulate}
   XOR CX,CX     {no parameter passing via PM stack}
   LES DI,regs32 {pointer to register set}
   INT 31h       {go for it}
   CMC           {carry flag set if error, reflect this}
   MOV AX,0      {as a BOOLEAN value: return TRUE if C=0}
   ADC AX,AX     {and FALES otherwise}
 END;
{$ENDIF}

VAR CycleTimeLo16,CycleTimeHi16:WORD;
    IsAT:BYTE;

{$IFDEF DPMI}
FUNCTION ATClockAvailable:BOOLEAN; {protected mode function}
BEGIN
 TimeFlag^:=0;             {reset flag}
 FillChar(regs32,SizeOf(regs32),0);
 regs32.ECX.Lo16:=0;
 regs32.EDX.Lo16:=1;       {trigger flag after 1us}
 regs32.ES      :=$40;     {_segment_ address of Timeflag}
 regs32.EBX.Lo16:=Ofs(TimeFlag^); {offset part = $F0}
 regs32.EAX.Lo16:=$8300;

 IF NOT EmulateInt($15,regs32)
  THEN WRITELN('Something went wrong in the INT-emulation!?');

 Delay(1); {INT-emulation went ok, look for timer event:}
           {wait 1000us, so event must have happened:}
 {Flag now should have been set to $80:}
 ATClockAvailable:=TimeFlag^=$80;
END;

{$ELSE}

FUNCTION ATClockAvailable:BOOLEAN; {real mode function}
BEGIN
 TimeFlag^:=0;             {reset flag}
 IF Test8086<>0  {is it at least an AT?}
  THEN ASM {yes, have a closer look:}
         STI
         XOR CX,CX       {trigger after 1us}
         MOV DX,1
         LES BX,TimeFlag {set Flag to $80 after this time}
         MOV AX,8300h    {run asynchron to rest of program}
         INT 15h         {go!}
       END;
 Delay(1);               {wait a 1000us}
 ATClockAvailable:=TimeFlag^=$80 {Flag=$80, if it worked}
END;
{$ENDIF}

PROCEDURE SetCycleTime(microseconds:LONGINT);
BEGIN
 TimeFlag^:=$80;
 CycleTimeHi16:=microseconds SHR 16;
 CycleTimeLo16:=microseconds AND $FFFF;
 IF (microseconds<>0) AND ATClockAvailable
  THEN IsAT:=0     {ja, Zeitüberwachung soll benutzt werden  }
  ELSE IsAT:=$80   {nein, keine möglich oder nicht gewünscht }
END;

PROCEDURE Trigger;
{starts timer, which must have previously been set by SetCycleTime()}
BEGIN
 IF IsAT<>0 THEN EXIT; {jmp out, if timer services unavailable}
 TimeFlag^:=0;
{$IFDEF DPMI}
 regs32.ECX.Lo16:=CycleTimeHi16;
 regs32.EDX.Lo16:=CycleTimeLo16;  {trigger flag after t us}
 regs32.ES      :=$40;            {_segment_ address of Timeflag}
 regs32.EBX.Lo16:=Ofs(TimeFlag^); {offset part = $F0}
 regs32.EAX.Lo16:=$8300;

 IF NOT EmulateInt($15,regs32)
  THEN WRITELN('Something went wrong in the INT-emulation!?');
{$ELSE}
ASM
  MOV CX,CycleTimeHi16
  MOV DX,CycleTimeLo16
  LES BX,TimeFlag {set Flag to $80 after this time}
  MOV AX,8300h    {run asynchron to rest of program}
  INT 15h         {go!}
END;
{$ENDIF}
END;

BEGIN
 TimeFlag:=Ptr(Seg0040,$F0); {available byte in 1st MB}
 SetCycleTime(0)
END.

____

PROGRAM TestUnit_asytimer;
{Kai Rohrbacher, kai.rohrbacher@logo.ka.sub.org}
USES asytimer;
CONST wait:LONGINT=5000000; {trigger time in us -> 5sec}

 PROCEDURE SomeThing;
 CONST s:ARRAY[0..3] OF CHAR='\|/-';
       help:BYTE=0;
 BEGIN WRITE(s[help]+^H); help:=(help+1) AND 3 END;

BEGIN
 IF ATClockAvailable
  THEN WRITELN('INT15h-timer-routine available!')
  ELSE WRITELN('INT15h-timer-routine doesn''t work!');

 SetCycleTime(wait);
 WRITELN('Between the following 2 bells, there should be a delay of ',
         wait,' microseconds');
 Trigger;    {wait 5s = 5000ms}
 WRITE(#7);
 WHILE NOT TimeOver DO SomeThing;
 WRITELN(#7'Done!');
END.

