(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0060.PAS
  Description: Change the Screen Border
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:30
*)

(***********************************************************************)
PROGRAM Border_Color;           {  Program to change the Screen Border  }
USES                            {  March 22/93, Greg Estabrooks         }
    CRT;                                 {  For Writeln                 }
VAR
        Err,
        Color :INTEGER;

PROCEDURE BorderColor( Color :BYTE ); ASSEMBLER;
                       { Routine to change Screen border Color         }
ASM
  Mov AH,$0B                    { SubFunction to change screen border  }
  Mov BL,Color                  { Load Color to set border to          }
  Mov BH,0                      { Set Video Page to 0                  }
  Int $10                       { Call Dos                             }
END;{BorderColor}

BEGIN
  IF ParamCount <> 1 THEN       { First Check for parameters           }
   BEGIN                        { If there were none then Syntax Error }
     WriteLn(' Usage : Border <Color> ');
     WriteLn('   Color = Value 0-15');
   END
  ELSE
   BEGIN
     Val(ParamStr(1),Color,Err);{ Convert from a STRING to a INTEGER    }
     IF (Color > 15) OR (Err <> 0) THEN
                                { If it is not in the range of 0..15    }
                                { it is invalid                         }
       Writeln(' Invalid Color Value : ',ParamStr(1))
     ELSE                       { If its ok then lets change the border }
       BorderColor(Color);
   END;
END.
(**********************************************************************)
