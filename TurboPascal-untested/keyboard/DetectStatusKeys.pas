(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0066.PAS
  Description: Detect Status Keys
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:32
*)

{***********************************************************************}
PROGRAM KeyStatDemo;            { Dec 09/93, Greg Estabrooks.           }
USES CRT;                       { Import Clrscr,Writeln,GotXY.          }

FUNCTION CapsOn :BOOLEAN;
                {  Routine to determine if Caps Lock is on.             }
BEGIN                           { Test the keyboard status bit for Caps.}
  CapsOn := (Mem[$0040:$0017] AND $40) <> 0;
END;{CapsOn}

FUNCTION NumLockOn :BOOLEAN;
                 {  Routine to determine if Num Lock is on.             }
BEGIN                           { Test keyboard status bit for NumLock. }
  NumLockon := (Mem[$0040:$0017] AND $20) <>0
END;{NumLockOn}

FUNCTION ScrollOn :BOOLEAN;
                 {  Routine to determine if Scroll Lock is on.          }
BEGIN                           { Test keyboard status bit for S_Lock.  }
    ScrollOn := (Mem[$0040:$0017] AND $10) <> 0;
END;{ScrollOn}

FUNCTION AltPressed :BOOLEAN;
                 {  Routine to determine if ALT key is being held down. }
BEGIN                           { Test keyboard status bit for ALT.     }
  AltPressed := (Mem[$0040:$0017] AND $08) <> 0;
END;{AltPressed}

FUNCTION CtrlPressed :BOOLEAN;
                 {  Routine to determine if Ctrl key is being held down.}
BEGIN                           { Test keyboard status bit for Ctrl.    }
  CtrlPressed := (Mem[$0040:$0017] AND $04) <> 0;
END;{CtrlPressed}

FUNCTION LeftShift :BOOLEAN;
                 {  Routine to determine if L_Shift is being held down. }
BEGIN                           { Test keyboard status bit for L_Shift. }
  LeftShift := (Mem[$0040:$0017] AND $02) <>  0;
END;{LeftShift}

FUNCTION RightShift :BOOLEAN;
                 {  Routine to determine if R_Shift is being held down. }
BEGIN                           { Test keyboard status bit for R_Shift. }
  RightShift := (Mem[$0040:$0017] AND $1) <> 0;
END;{RightShift}

BEGIN
  Clrscr;                       { Clear the screen of clutter.       }
  REPEAT
    GotoXY(1,1);                { Move Back to top of screen.        }
    Writeln('CapsLock   : ',Capson,' ');
    Writeln('NumLock    : ',NumLockOn,' ');
    Writeln('Scroll Lock: ',ScrollOn,' ');
    Writeln('Alt Key    : ',AltPressed,' ');
    Writeln('Ctrl Key   : ',CtrlPressed,' ');
    Writeln('Right Shift: ',RightShift,' ');
    Writeln('Left Shift : ',LeftShift,' ');
  UNTIL KeyPressed;             { Loop until a key is pressed.       }
END.{KeyStatDemo}
{********************************************************************}
