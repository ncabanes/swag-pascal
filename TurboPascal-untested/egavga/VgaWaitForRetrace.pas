(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0057.PAS
  Description: VGA Wait for retrace
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  21:51
*)

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
