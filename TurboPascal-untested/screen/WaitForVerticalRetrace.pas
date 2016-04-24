(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0040.PAS
  Description: Wait for Vertical Retrace
  Author: SANTERI SALMINEN
  Date: 11-02-93  06:12
*)

{
SANTERI SALMINEN

> how can i wait For the vertical retrace, in Pascal.

Some routines For retraces:
As you can see, $3DA reveals all of them.
}

 Repeat Until Port[$3DA] And 8 = 8; { Wait For Vertical retrace              }
 Repeat Until Port[$3DA] And 8 = 0; { Wait For the end of Vertical retrace   }
 Repeat Until Port[$3DA] And 1 = 1; { Wait For Horizontal retrace            }
 Repeat Until Port[$3DA] And 1 = 0; { Wait For the end of Horizontal retrace }


