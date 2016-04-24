(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0070.PAS
  Description: Wait for RETRACE
  Author: SWAG SUPPORT GROUP
  Date: 11-26-93  17:39
*)

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
