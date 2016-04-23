UNIT KeyIO;                {  Key I/O Unit, Last Updated Dec 08/93                }
                        {  Copyright (C) 1993 Greg Estabrooks                 }
                        {  Requires TP 6.0+ to compile.                 }
INTERFACE
{***********************************************************************}
CONST                   { Define some keys to make later detection easy.}
        Enter  = #13;   Esc    = #27;   HomeKey   = #0#71;
        EndKey = #0#79; PgUp   = #0#73; PgDn      = #0#81;
        InsKey = #0#82; DelKey = #0#83; BackSpace = #8;
        Space = #32;

        UpArrow = #0#72;  DnArrow = #0#80;  LfArrow = #0#75;
        RtArrow = #0#77;

        Alt_A =        #0#30;        Alt_B =        #0#48;        Alt_C = #0#46;        Alt_D = #0#32;
        Alt_E =        #0#18;        Alt_F = #0#33;        Alt_G = #0#34;        Alt_H = #0#35;
        Alt_I = #0#23;  Alt_J = #0#36;  Alt_K = #0#37;        Alt_L = #0#38;
        Alt_M = #0#50;        Alt_N = #0#49;        Alt_O = #0#24;        Alt_P = #0#25;
        Alt_Q =        #0#16;        Alt_R = #0#19;        Alt_S = #0#31;  Alt_T = #0#20;
        Alt_U = #0#22;        Alt_V = #0#47;        Alt_W = #0#17;        Alt_X = #0#45;
        Alt_Y = #0#21;  Alt_Z = #0#44;

        Alt_1 = #0#120; Alt_2 = #0#121; Alt_3 = #0#122; Alt_4 = #0#123;
        Alt_5 = #0#124; Alt_6 = #0#125; Alt_7 = #0#126; Alt_8 = #0#127;
        Alt_9 = #0#128; Alt_0 = #0#129;

        Alt_F1 =#0#104; Alt_F2 =#0#105; Alt_F3 =#0#106; Alt_F4 =#0#107;
        Alt_F5 =#0#108; Alt_F6 =#0#109; Alt_F7 =#0#110; Alt_F8 =#0#111;
        Alt_F9 =#0#112; Alt_F10=#0#113; Alt_F11=#0#139;
        Alt_F12=#0#140;

        F1 = #0#59;  F2 = #0#60;  F3 = #0#61;  F4 = #0#62;  F5 = #0#63;
        F6 = #0#64;  F7 = #0#65;  F8 = #0#66;  F9 = #0#67;  F10= #0#68;
        F11= #0#133; F12= #0#134;

        Shift_F11 = #0#135; Shift_F12 = #0#136;
              Ctrl_F11  = #0#137; Ctrl_F12  = #0#138;
TYPE
        Str02    = STRING[2];
VAR
        KeyHPtr  :WORD Absolute $40:$1A;    {  Ptr to front of key buf. }
        KeyTPtr  :WORD Absolute $40:$1C;    {  Ptr to end of key buf.   }

FUNCTION CapsOn :BOOLEAN;
                 {  Routine to determine if Caps Lock is on.            }
FUNCTION NumLockOn :BOOLEAN;
                 {  Routine to determine if Num Lock is on.             }
FUNCTION InsertOn :BOOLEAN;
                 {  Routine to determine if Insert is on.               }
FUNCTION AltPressed :BOOLEAN;
                 {  Routine to determine if ALT key is being held down. }
FUNCTION CtrlPressed :BOOLEAN;
                 {  Routine to determine if Ctrl key is being held down.}
FUNCTION LeftShift :BOOLEAN;
                 {  Routine to determine if L_Shift is being held down. }
FUNCTION RightShift :BOOLEAN;
                 {  Routine to determine if R_Shift is being held down. }
FUNCTION ScrollOn :BOOLEAN;
                 {  Routine to determine if Scroll Lock is on.          }
PROCEDURE NumLock( Enable :BOOLEAN );
                 {  Routine to Set/Unset the Numlock key.               }
PROCEDURE CapsLock( Enable :BOOLEAN );
                 {  Routine to Set/Unset the Capslock key.              }
PROCEDURE ScrollLock( Enable :BOOLEAN );
                 {  Routine to Set/Unset the Scrolllock key.            }
FUNCTION EnhancedKeyBoard :BOOLEAN;
                 { Test Bit 4 of byte at 0040:0096 to check for enhanced}
                 { Keyboard.                                                }
FUNCTION EKeyPressed :BOOLEAN;
                 { Function to determine if a key was pressed. The      }
                 { routine in the CRT Unit to do this didn't detect F11 }
                 { or F12 keys.                                         }
FUNCTION GetKey :STR02;
                 {  Routine to Read Key Presses. Including F11 and F12. }
PROCEDURE ClearKeyBuffer;
                 { Routine to Clear Keyboard buffer.                    }
PROCEDURE PauseKey;
                 { Routine to wait for a keypress and then continue.    }

IMPLEMENTATION
{***********************************************************************}
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

FUNCTION InsertOn :BOOLEAN;
                 {  Routine to determine if Insert is on.               }
BEGIN                           { Test keyboard status bit for insert.  }
  InsertOn := (Mem[$0040:$0017] AND $80) <> 0;
END;{InsertOn}

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

FUNCTION ScrollOn :BOOLEAN;
                 {  Routine to determine if Scroll Lock is on.          }
BEGIN                           { Test keyboard status bit for S_Lock.  }
    ScrollOn := (Mem[$0040:$0017] AND $10) <> 0;
END;{ScrollOn}

PROCEDURE NumLock( Enable :BOOLEAN );
                 {  Routine to Set/Unset the Numlock key.               }
BEGIN
  IF Enable THEN                                {  Turn on Bit 5        }
      Mem[$40:$17] := Mem[$40:$17] OR $20
  ELSE                                                {  Turn it Off 5        }
      Mem[$40:$17] := Mem[$40:$17] AND $DF;
END;{NumLock}

PROCEDURE CapsLock( Enable :BOOLEAN );
                 {  Routine to Set/Unset the Capslock key.              }
BEGIN
 IF Enable THEN                                        {  Turn on Bit          }
     Mem[$40:$17] := Mem[$40:$17] OR $40
 ELSE                                                {  Turn it Off          }
     Mem[$40:$17] := Mem[$40:$17] AND $BF;
END;{CapsLock}

PROCEDURE ScrollLock( Enable :BOOLEAN );
                 {  Routine to Set/Unset the Scrolllock key.            }
BEGIN
 IF Enable THEN                                        {  Turn on Bit          }
     Mem[$40:$17] := Mem[$40:$17] OR $10
 ELSE                                                {  Turn it Off          }
     Mem[$40:$17] := Mem[$40:$17] AND $EF;
END;{ScrollLock}

FUNCTION EnhancedKeyBoard :BOOLEAN;
                {  Test Bit 4 of byte at 0040:0096 to check for enhanced}
                {  Keyboard.                                                }
BEGIN
  EnhancedKeyBoard := (Mem[$40:$96] AND $10) = $10;
END;{EnhancedKeyBoard}

FUNCTION EKeyPressed :BOOLEAN; ASSEMBLER;
                 { Function to determine if a key was pressed. The      }
                 { routine in the CRT Unit to do this didn't detect F11 }
                 { or F12 keys.                                         }
ASM
  Mov AH,$11                    { Function to check for Enhanced key.   }
  Int $16                       { Call keyboard INT.                    }
  Jz @NoKey                     { If ZF not set then nothing pressed.   }
  Mov AL,1                      { Otherwise return TRUE.                }
  Jmp @Exit                     { Now goto Exit.                        }
@NoKey:
  Mov AL,0                      { Return a FALSE result.                }
@Exit:
END;{EKeyPressed}

FUNCTION GetKey :STR02;
                {  Routine to Read Key Presses. Including F11 and F12         }
VAR
        TKey :STR02;            { Hold key press info.                  }
BEGIN
  ASM
    Call EnhancedKeyBoard       { Test for an Enhanced keyboard.        }
    Cmp AL,1                    { If AL=1 THEN Enhanced Keyboard= TRUE. }
    Je @Enhanced                { If it was TRUE then Get Enhanced key. }
    Mov AH,0                    { If not TRUE get normal key.           }
    Jmp @ReadKeyb
@Enhanced:
    Mov AH,$10                  { Function to get key from enhanced board.}
@ReadKeyb:
    Int $16                     { Call Int keyboard INT.                }
    Mov TKey[1].BYTE,AL         { Load both Ascii code and scan code    }
    Mov TKey[2].BYTE,AH         { into TKey.                            }
  END;
  IF (TKey[1] = #224) AND EnhancedKeyBoard THEN
    BEGIN
      IF KeyHPtr = $1E THEN
         TKey := #0 + CHR(Mem[$40:$3D])
      ELSE
         TKey := #0 + CHR(Mem[$40:KeyHPtr-1]);
    END;
  IF TKey[1] <> #0 THEN         { If it wasn't an extended key then     }
    TKey := TKey[1];            { return only Ascii code.               }
  GeTKey := TKey;               { Return proper key result to user.     }
END;{GetKey}

PROCEDURE ClearKeyBuffer;
                 { Routine to Clear Keyboard buffer.                    }
VAR
   DKey :Str02;                 { Hold unwanted keystrokes.             }
BEGIN
  WHILE EKeyPressed DO
    DKey := GetKey;             { Read in unwanted key press.           }
END;{ClearKeyBuffer}

PROCEDURE PauseKey;
                 { Routine to wait for a keypress and then continue.    }
VAR
        Ch :STR02;              { Holds dummy key press.                }
BEGIN
  ClearKeyBuffer;               { Clear buffer of any previous keys.    }
  Ch := GetKey;                 { Call for a key.                       }
END;{PauseKey}

BEGIN
END.
{***********************************************************************}