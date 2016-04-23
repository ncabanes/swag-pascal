{*************************************************************}
PROGRAM BlinkBitDemo;           { Aug 31/93, Greg Estabrooks. }
USES CRT;                       { Clrscr,TextAttr.            }
VAR
   Loop1, Loop2, TextA : BYTE;

PROCEDURE SetBlinkBit( OffOn :BOOLEAN ); ASSEMBLER;
                       { Routine to turn the blink bit on/off.}
ASM
  Push AX                       { Save AX.                    }
  Mov AX,$1003                  { Video routine to toggle bit.}
  Mov BL,OffOn                  { Move OffOn value in BL.     }
  Int $10                       { Call video Interrupt.       }
  Pop AX                        { Restore AX.                 }
END;{SetBlinkBit}

BEGIN
  ClrScr;                       { Clear up screen clutter.    }
  TextA := 0;                   { Initiate color number.      }
  FOR Loop1 := 0 TO 15 DO       { Now draw color chart.       }
   BEGIN
    FOR Loop2 := 0 TO 15 DO
     BEGIN
       TextAttr := TextA;       { Set new color.              }
       Write(TextA:4);          { Write new color number.     }
       Inc(TextA);              { Move to next color.         }
     END;
     Writeln;                   { Move to the next line.      }
   END;
   Readln;                      { Pause for user.             }
   SetBlinkBit(FALSE);          { Turn off blink bit.         }
   Readln;                      { Pause for user.             }
   SetBlinkBit(TRUE);           { Turn blinkbit back on.      }
END.{BlinkBitDemo}
{*************************************************************}