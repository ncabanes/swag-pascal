{
> HELP!!!  I cannot figure out how to throw Borland's Turbo Pascal
> v4.0 into VGA 50linesx80columns mode!

You just have to use the Textmode procedure that is in the CRT
unit. The following is an example of how to use it.
}

PROGRAM TextMode_Demo;          {  June 14/93, Greg Estabrooks  }
USES
  CRT;                          {  TextMode, LastMode           }
VAR
  SavedMode : BYTE;             {  Holds Initial Text mode      }

BEGIN
  SavedMode := LastMode;        {  Save Current Mode for later  }
  TextMode(Font8x8 + Co80);     {  Set to Color 43/50 line mode }
  Writeln('This is 43/50 line mode!');
  Readln;                       {  Wait for user to have a look }
  TextMode(SavedMode);          {  Restore to original textmode }
END.
