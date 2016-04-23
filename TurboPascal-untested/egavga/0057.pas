{
> Does anybody know how to wait for the retrace before drawing a new
> screen to eliminate flicker?

Here's the procedure from a PD unit called SuperVGA (by Steve Madsen):

Waits for a verticle retrace to complete before exiting.  Useful
for reducing flicker in video intensive operations, like color cycling.
}

PROCEDURE WaitRetrace;
begin
  while ((Port[$3DA] AND 8) > 0) do;
  while ((Port[$3DA] AND 8) = 0) do;
end;
