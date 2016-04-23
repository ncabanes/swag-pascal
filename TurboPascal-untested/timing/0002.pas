Unit tctimer;

Interface
Uses tptimer;

  Var
    start : LongInt;

Procedure StartTimer;

Procedure WriteElapsedTime;



Implementation

Procedure StartTimer;
  begin
    start := ReadTimer;
  end;

Procedure  WriteElapsedTime;
  Var stop : LongInt;
  begin
    stop := ReadTimer;
    Writeln('Elapsed time = ',(ElapsedTime(start,stop) / 1000):10:6,' seconds');
  end;


end.
