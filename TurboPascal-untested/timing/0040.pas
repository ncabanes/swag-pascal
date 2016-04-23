{
>The hardware requires several types of simple 'wait' delay from about
>100us through to 100's of ms. Currently this is done using a
>software-calibrated technique and count loops, but a (say) 10ms delay is
>only about 5% accurate. To improve this operation, I propose to change to
>the following:
>
>If my app is running in DOS only (real or DPMI).
>------------------------------------------------
>To use a standard 'timer'-based unit which is known to be solid with the
>PC timer to generate delays. (Eg Turbopowers sample file).
>
>If my app is running as a DOS app under Windows.
>------------------------------------------------
>The standard 'timer'-based unit above does NOT work now - presumably
>because Windows virtualises the timer. In this mode I would like my
>(DOS!) app to be able to access MMSYSTEM to get at its timer services.
>
>
>So to the questions.
>1. How can a DPMI program running under windows get at (say) MMSYSTEM?
>2. Is it possible for a real-mode DOS program running under windows to
>get at any of these services?
>

Don't know about any of that but there is a way to get at the microtimer
port on any computer above an "AT" here is the code }

{
In <Ds2woK.CCA@cix.compulink.co.uk>, bfrost@cix.compulink.co.uk ("Brian Frost") writes:
>Well, I've tried ReadMicroTimer and it looked promising at first. If you 
>call it (in BP7 but under W95) in a simple routine to loop reading it 
>until an elapsed duration is complete, it works for durations > 100,000 
>counts (each count is actually 0.8us I think) but if you then try 10,000 
>counts it appears that the routine actually hangs around looping on 
>something and times go out by a factor of 5 or so.

The code was for micro timing not for long delays you've got the interrupts
held up while it does the reads thus when the interrupt routines come 
through between calls they upset the timing! For OS2 native mode you can use the following code on a compiler such as speed or Virtual Pascal

{$IFNDEF OS2}                                         { Non OS2 version }
FUNCTION ReadMicroTimer: LongInt; ASSEMBLER;
ASM  { Read the system timer With 1 microsecond resolution }
   CLI;                                               { Disable interrupts }
   MOV AL, 0AH;                                       { Set irr address }
   OUT 20H, AL;                                       { Ask to read irr }
   MOV AL, 00H;                                       { Value to set timer }
   OUT 43H, AL;                                       { Set timer 0 latch }
   IN AL, DX;                                         { Read irr value }
   MOV DI, AX;                                        { Save value in DI }
   IN AL, 40H;                                        { Read counter value }
   MOV BL, AL;                                        { LSB in BL }
   IN AL, 40H;                                        { Read counter value }
   MOV BH, AL;                                        { MSB in BH }
   NOT BX;                                            { Asscending count }
   IN AL, 21H;                                        { Read PIC imr }
   MOV SI, AX;                                        { Save value in SI }
   MOV AL, 0FFH;                                      { Mask all interrupts }
   OUT 21H, AL;                                       { Stop all interrupts }
   MOV AX, [Seg0040];                                 { Dos data segment }
   MOV ES, AX;                                        { Set register }
   MOV DX, ES:[006CH];                                { Read time clock }
   MOV AX, SI;                                        { Reload PIC imr }
   OUT 21H, AL;                                       { Restore interrupts }
   STI;                                               { Enable interrupts }
   MOV AX, DI;                                        { Retreive old irr }
   TEST AL, 01H;                                      { Counter hit 0 }
   JZ @@Done;                                         { Count complete }
   CMP BX, 0FF00H;                                    { Counter > $FFxx }
   JA @@Done;                                         { Counter complete }
   INC DX;                                            { Count irq request }
@@Done:
   MOV AX, BX;                                        { Return time pulses }
END;
{$ELSE}                                               { OS2 version }
FUNCTION ReadMicroTimer: LongInt;
VAR Value: LongInt;
BEGIN
   DosQuerySysInfo(qsv_Ms_Count, qsv_Ms_Count,
       Value, SizeOf(Value));                         { Issue query }
   ReadMicroTimer := Value;                           { Return timer }
END;
{$ENDIF}

Longer delays can be done with code like

CONST
   DelayCount : LongInt = 0;                          { Delay cycle counts }
   HrtimerRate: Longint = 1193182;                    { RTC Timer rate }

{$IFNDEF OS2}                                         { Non OS2 version }
PROCEDURE Delay (MilliSecs: Word); ASSEMBLER;
ASM
   CMP WORD PTR [DelayCount], 0;
   JNZ @@AlreadyInstalled;                            { Delay installed }
   MOV AX, [Seg0040];
   MOV ES, AX;                                        { DOS Data segment }
   MOV SI, 006CH;
   MOV AX, ES:[SI];                                   { Read DOS clock }
@@DifferWait:
   CMP AX, ES:[SI];
   JZ @@DifferWait;                                   { Wait for change }
   MOV AX, ES:[SI];
   MOV CX, 0FFFFH;                                    { Preset count }
@@DifferWait1:
   CMP AX, ES:[SI];
   JNZ @@Differs;                                     { Wait for tick }
   LOOP @@DifferWait1;
@@Differs:
   MOV AX, 0037H;
   XCHG CX, AX;                                       { Calculate delay }
   NOT AX;
   XOR DX, DX;
   DIV CX;
   MOV WORD PTR [DelayCount], AX;                     { Hold delay count }
@@AlreadyInstalled:
   MOV DX, [MilliSecs];                               { Retreive delay }
@@CountLoop:
   OR DX, DX;
   JZ @@Exit;                                         { Zero delay exit }
   XOR SI, SI;
   MOV AX, [Seg0040];                                 { Load address }
   MOV ES, AX;
   MOV AX, ES:[SI];
   MOV CX, WORD PTR [DelayCount];                     { Load delay count }
@@Wait2:
   CMP AX, ES:[SI];
   JNZ @@Over;
   LOOP @@Wait2;                                      { Wait 1ms }
@@Over:
   DEC DX;
   JNZ @@CountLoop;                                   { Repeat 1ms delay }
@@Exit:
END;
{$ELSE}                                               { OS2 version }

{ Waits for next timer tick or delays 1ms }

FUNCTION DelayLoop (Count: Longint; Var StartValue: LongInt): Longint;
VAR Value: LongInt;
BEGIN
   Repeat
     DosQuerySysInfo(qsv_Ms_Count, qsv_Ms_Count,
       Value, SizeOf(Value));                         { Get timer count }
     Dec(Count);                                      { Count down }
   Until (Value <> StartValue) OR (Count = -1);
   StartValue := Value;                               { Update start }
   DelayLoop := Count;                                { Return result }
END;

{ Calculates 1ms delay count for DelayLoop routine. }
{ CalcDelayCount is called once at startup.         }

PROCEDURE CalcDelayCount;
VAR Interval, StartValue, Value: LongInt;
BEGIN
   DosQuerySysInfo(qsv_Timer_Interval, qsv_Timer_Interval,
    Interval, SizeOf(Interval));                      {  Get timer interval }
   DosQuerySysInfo(qsv_Ms_Count, qsv_Ms_Count,
    StartValue, SizeOf(StartValue));                  { Get timer count }
   Repeat
     DosQuerySysInfo(qsv_Ms_Count, qsv_Ms_Count,
       Value, SizeOf(Value));                         { Get timer timer }
   Until (Value <> StartValue);
   TenthsCount := -DelayLoop(-1, Value) DIV Interval; { Tenths count}
   DelayCount := TenthsCount * 10;                    { Delay count }
END;

PROCEDURE Delay (MilliSecs: Word);
VAR StartValue, Value: LongInt; Count: Longint;
BEGIN
   If (DelayCount=0) Then CalcDelayCount;             { Calc delay count }
   If (MilliSecs >= (5*31)) Then DosSleep(MilliSecs)  { Long delay sleep }
   Else Begin
     DosQuerySysInfo(qsv_Ms_Count, qsv_Ms_Count,
     StartValue, SizeOf(StartValue));                 { Issue query }
     Value := StartValue;                             { Hold start value }
     Count := MilliSecs;                              { Load count }
     Repeat
       DelayLoop(DelayCount, Value);                  { Call delay loop }
       Dec(Count);                                    { 1 millisec down }
     Until (Value-StartValue >= MilliSecs) OR
     (Count <= 0);                                    { Delay complete }
   End;
END;
{$ENDIF}
