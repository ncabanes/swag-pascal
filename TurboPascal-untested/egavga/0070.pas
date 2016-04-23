  {
  *  PROCEDURE WaitRetrace
  *
  *  Waits for a verticle retrace to complete before exiting.  Useful
  *  for reducing flicker in video intensive operations, like color
  *  cycling.
  }
 
PROCEDURE WaitRetrace;
 begin
   while ((Port[$3DA] AND 8) > 0) do;
   while ((Port[$3DA] AND 8) = 0) do;
 end;
