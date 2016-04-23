{

The two Units below give you a millisecond timer. Use the global variable
TimerTick for the timing e.g.
}

program Test;

uses timer;  {or timer2}

procedure TestIt;
begin
  ...
  {put code here}
  ...
end;

var Time: LongInt;
begin
  TimerTick := 0;
  TestIt;
  Time := TimerTick;    :Te amount of ms. used by the procedure TestIt;
end.


Use Timer if your max. time < $FFFF (65535) Ms, else use Timer2.



======================================================================

{CUT HERE}

Unit Timer;

{ 1 Ms timer Unit }

InterFace

var TimerTick: Word;               { Global Ms counter }


procedure TDelay(Ms: Integer);     { Ms dealy procedure }
                                   { Resets the global TimerTick variable 
!! }


Implementation


const SaveInt = $67;               { Private constants and variables }
      Base = 55;

var OldExitProc: Pointer;
    Counter: Word;



procedure TDelay(Ms: Integer);
begin
  if Ms <= 0 then Exit;
  TimerTick := 0;
  repeat until TimerTick >= Ms;
end;



procedure NewTimer; INTERRUPT; Assembler;
asm                                 
  Dec Counter                      { Decrement counter }
  CMP Counter, $00                 { Call old INT ? }
  JNZ @@2                          
  Int SaveInt                      { Yes } 
  MOV Counter, Base;               { Restore counter }
  JMP @@3
@@2:
  MOV AL, $20                      
  OUT $20, AL
@@3:
  Inc TimerTick                    { Increment Ticker }
end;


procedure InitTimer;
const Freq = 1000;
var InitialCount: Word;
    OldVector: Pointer;
begin
  TimerTick := 0;
  Inline($FA);                             { Disable Interrrupts }
  InitialCount := 1193180 div Freq;        { Calculate base for counter }
  Port[$43] := $36;                        { Setl mode for timerchip }
  Port[$40] := Lo(InitialCount);           { Write LSB }
  Port[$40] := Hi(InitialCount);           { Write MSB }
  GetIntVec(8, OldVector);                 { Get Old IntVec }
  SetIntVec(SaveInt,OldVector);            { Int 8 now saved in OldVector }
  SetIntVec(8, @NewTimer);                 { New Int Handler }
  Inline($FB);                             { Enable Interrupts }
end;




procedure SaveExitProc; Far;
var OldVector: Pointer;
begin
  Inline($FA);                             
  Port[$43] := $36;                        { Restore old interrupts and }
  Port[$40] := $FF;
  Port[$40] := $FF;
  GetIntVec(SaveInt, OldVector);
  SetIntVec(8, OldVector);
  Inline($FA);
  ExitProc := OldExitProc;                 { Restore old ExitProc }
end;


begin
  OldExitProc :=ExitProc;                  { Save ExitProcedure }
  ExitProc := @SaveExitProc;               { Install our ExitProcedure }
  InitTimer;                               { Install new Int Handler }
end.



======================================================================

Unit Timer2;

{ 1 Ms timer Unit }

InterFace

var TimerTick: LongInt;    


procedure TDelay(Ms: LongInt); 


Implementation

Uses Dos;                 { For the Registers type used in NewTimer }

const SaveInt = $67;     
      Base = 55;

var OldExitProc: Pointer;
    Counter: Word;
    DTick: LongInt;     


procedure TDelay(Ms: LongInt);
begin
  if Ms <= 0 then Exit;
  DTick := 0;
  repeat until DTick >= Ms;
end;



procedure NewTimer; INTERRUPT;
var R: Registers;                    
begin
  Dec(Counter);                  
  if (Counter = 0) then
  begin                
    Intr(SaveInt,R);   
    Counter := Base;
  end
  Else Port[$20] := $20;
  Inc(TimerTick);       
  Inc(DTick);           
end;


procedure InitTimer;
const Freq = 1000;
var InitialCount: Word;
    OldVector: Pointer;
begin
  TimerTick := 0;
  DTick := 0;
  Inline($FA);
  InitialCount := 1193180 div Freq;     
  Port[$43] := $36;                     
  Port[$40] := Lo(InitialCount);        
  Port[$40] := Hi(InitialCount);        
  GetIntVec(8, OldVector);              
  SetIntVec(SaveInt,OldVector);         
  SetIntVec(8, @NewTimer);              
  Inline($FB);                          
end;




procedure SaveExitProc; Far;
var OldVector: Pointer;
begin
  Inline($FA);                        
  Port[$43] := $36;                   
  Port[$40] := $FF;                   
  Port[$40] := $FF;                   
  GetIntVec(SaveInt, OldVector);      
  SetIntVec(8, OldVector);            
  Inline($FA);                        
  ExitProc := OldExitProc;            
ExitProc }
end;


begin
  OldExitProc :=ExitProc;
  ExitProc := @SaveExitProc;
  InitTimer;
end.

