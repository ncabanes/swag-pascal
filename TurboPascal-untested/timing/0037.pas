{The problem:  repeat
                 ...
               until SomeEvent;
 If SomeEvent (external hardware signals etc.) never comes, the program
 hangs. So I did this code to avoid hangup's. Look below for example.

 GetTimeWord returns the actual timer value.
 SetTimeOutTicks sets a timeout-value to a word variable TimeVar.
 IsTimeOut returns true when TimeVar >= actual time or false if lower.

 All 3 functions/procedures are very fast. The function IsTimeOut runs
 about 2.000.000!/second on a P90-machine.

 Dec. 12, 1995, Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]}

uses
  Crt;
{---------------------------------------------------------------------------}

var
  Time  : Word;
  Count : LongInt;
{---------------------------------------------------------------------------}

function GetTimeWord:Word; assembler;
asm
           mov   es,Seg0040
           mov   di,6Ch
           mov   ax,word ptr es:[di]
end;
{---------------------------------------------------------------------------}

procedure SetTimeOutTicks(Ticks:Word; var TimeVar:Word); assembler;
asm
           call  GetTimeWord
           add   ax,Ticks
           les   di,TimeVar
           stosw
end;
{---------------------------------------------------------------------------}


function IsTimeOut(TimeVar:Word):Boolean; assembler;
asm
           mov   bx,TimeVar
           call  GetTimeWord
           cmp   ax,bx
           mov   al,0
           jl    @End
           mov   al,1
@End:
end;
{---------------------------------------------------------------------------}

begin
  ClrScr;
  Count:=0;
  SetTimeOutTicks(18,Time);               {1 second equals ~18.2 timer ticks}
  Writeln('Waiting for 1 second and counting IsTimeOut query...');
  repeat
    Inc(Count);
  until IsTimeOut(Time);
  Writeln('IsTimeOut query = ',Count:8,' times/sec.');
  ReadKey;
end.