{ ***** FIRST OFF!  The credits and such *****                               }
{  Written in Turbo Pascal (TM) v6.0 on 10 May 1991 ( yes, one day) by       }
{  Robert L. Edwards.  The idea was to make it a little simpler to generate  }
{  both ANSI and ASCI bulletins for DOOR programs.  I was in the final stages}
{  of a DOOR developement and needed this tool.  The idea is to set up a     }
{  string with the text you want saved weaved in with your ANSI calls.  I    }
{  got this idea from the Pheonix Software Group PSG (tm) collection of DOOR }
{  routines named PSGIO(tm).  In that collection a routine is called PRINT   }
{  and PRINTLN that handle calls from a routine ANSIColor to set the         }
{  attributes.  This function was not flexible enough for me to use in file  }
{  writes (or I am just too stupid?!?).                                      }
{                                                                            }
{  !!! THIS CODE IS CONSIDERED PUBLIC DOMAIN !!!                             }
{  -  Please, if you improve on it, upload a copy to my board.  I used only  }
{     one afternoon to produce this and the code is quite shakey.            }
{                                                                            }
{  If you find this program usefull (no, I am not going to ask for money     }
{  Please call me and let me know (VIA BBS).  If enough support and interest }
{  is shown, I will further clean and enhance this program.  As it is now    }
{  it fits my needs.  Any recomendations are greatly appreciated.            }
{     Respectfully,                                                          }
{                                                                            }
{                  Robert L. Edwards                                         }
{                  RaJE Computer Emirates (RJE)                              }
{                  Box 6725 NSGA                                             }
{                  Winter Harbor, ME 04693                                   }
{                                                                            }
{     Call The Force! Demon-Sion BBS @ 1(207)963-2683  USR HST 14400         }
{          or Voice @ 1(207)963-7056                                         }

Unit Bulletin;
Interface
Uses tpCRT;

Function A_St(FG, BG : Word) : String;

{ - DESCRIPTION:  This function takes the WORDs input and translates them    }
{                 if possible, to ANSI escape sequences.  The global         }
{                 variable ANS (Record type) is checked for repeat requests  }
{                 and will not duplicate ANSI code.  IE:  A call to set      }
{                 colors to YELLOW foreground and BLUE background when       }
{                 the background (ANS.BG) is already blue will produce       }
{                 only the YELLOW escapes sequences.  If the global ANS.ON   }
{                 is FALSE, the function will return a NUL string.           }
{ - CALLING:  YourString := A_St(Yellow + Bold + Blink, Blue);               }
{                                                                            }
{             Will yield the escape sequence for a bold blinking yellow      }
{             foreground on a blue background.  Global variable are set for  }
{             the allowable ANSI colors.  This variables are Mnemonics and   }
{             are in no way related to their ANSI escape sequences.  For ease}
{             non-conflict the values are duplicate of the TURBO PASCAL      }
{             UNIT CRT global declarations.                                  }
{ - RESULTS:  This function returns a string of characters equal to the      }
{             escape sequences need to reproduce the called foreground       }
{             and background collors.  If global ANS.ON is FALSE, a NUL      }
{             string will be returned.                                       }
{ - CALLED FROM:  Your routines.                                             }
{ - VARIABLES:                                                               }
{     Type                                                                   }
{       CAns = Record                                                        }
{         Att : Word;     Current Attribute                                  }
{                         Valid values:                                      }
{                            OFF                                             }
{                            Blink                                           }
{                            Bold                                            }
{                            Blink + Bold                                    }
{         FG  : Word;     Current ForeGround                                 }
{                         Valid Values                                       }
{                         Black,   [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         Red,     [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         Green,   [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         Yellow,  [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         Blue,    [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         Magenta, [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         Cyan,    [+ Blink], [+ Bold], [+ Blink + Bold]     }
{                         White,   [+ Blink], [+ Bold], [+ Blink + Bold]     }
{         BG  : WOrd;     Current BackGround                                 }
{                         Valid Values:                                      }
{                          Black                                             }
{                          Red                                               }
{                          Green                                             }
{                          Yellow                                            }
{                          Blue                                              }
{                          Magenta                                           }
{                          Cyan                                              }
{                          White                                             }
{         ON  : Boolean;  Generate ANSI codes?                               }
{                         Valid Values:                                      }
{                           True                                             }
{                           False                                            }
{       End;                                                                 }
{                                                                            }
{   var                                                                      }
{     Ans : CAns;         Holds current attributes, described above          }
{   Const                                                                    }
{     Esc      = #27 + '[';     Escape sequence                              }
{     Off      =  50;           Off Mnemonic                                 }
{     Bold     =  51;           Bold Mnemonic                                }
{     Black    =   0;           Black Mnemonic, CRT Constant                 }
{     Red      =   4;           Red Mnemonic, CRT Constant                   }
{     Green    =   2;           Green Mnemonic, CRT Constant                 }
{     Yellow   =  14;           Yellow Mnemonic, CRT Constant                }
{     Blue     =   1;           Blue Mnemonic, CRT Constant                  }
{     Magenta  =   5;           Magenta Mnemonic, CRT Constant               }
{     Cyan     =   3;           Cyan Mnemonic, CRT Constant                  }
{     White    =  15;           White Mnemonic, CRT Constant                 }
{     Blink    = 128;           Blink Mnemonic, CRT Constant                 }

Type
  CAns = Record
    Att : Word;
    FG  : Word;
    BG  : WOrd;
    ON  : Boolean;
  End;

var
  Ans : CAns;              { Holds Current Information on      }
                           { Attribute ( Off, Bold, Blink, ETC }
                           { ForeGround Color                  }
                           { BackGround Color                  }
Const
  Esc      = #27 + '[';    { Escape sequence                }
  Off      =  50;          { Off Mnemonic                   }
  Bold     =  51;          { Bold Mnemonic                  }
  Black    =   0;          { Black Mnemonic, CRT Constant   }
  Red      =   4;          { Red Mnemonic, CRT Constant     }
  Green    =   2;          { Green Mnemonic, CRT Constant   }
  Yellow   =  14;          { Yellow Mnemonic, CRT Constant  }
  Blue     =   1;          { Blue Mnemonic, CRT Constant    }
  Magenta  =   5;          { Magenta Mnemonic, CRT Constant }
  Cyan     =   3;          { Cyan Mnemonic, CRT Constant    }
  White    =  15;          { White Mnemonic, CRT Constant   }
  Blink    = 128;          { Blink Mnemonic, CRT Constant   }
  Nul      = 100;          { No Change Mnemonic             }
Implementation

Function SetATT(A : Word) : String;
  Begin
    SetAtt := '';
    Case A of
      Off : If Ans.ATT <> Off then
              Begin
                SetAtt := '0';
                Ans.Att := Off;
                Ans.FG  := 255;
                Ans.BG  := 255;
              End;
      Bold  : Case Ans.Att of
                Off,
                Blink : Begin
                          SetATT := '1';
                          Inc(Ans.Att,Bold);
                        End;
                Bold, Bold +
                Blink  : Begin
                         End;
                Else Begin
                       SetATT := '1';
                       Ans.Att := Bold;
                     End;
              End;
      Blink : Case Ans.Att of
                Off   : Begin
                          SetAtt := '5';
                           Ans.Att := Blink;
                         End;
                Bold  : Begin
                          SetAtt := '5';
                          Inc(Ans.Att,Blink);
                        End;
                Blink,
                Bold +
                Blink : Begin
                        End;
                Else Begin
                       SetAtt := '5';
                       Ans.Att := Blink;
                     End;
              End;
      Blink +
      Bold  : Case Ans.ATT of
                Off   : Begin
                          SetAtt := '1;5';
                          Ans.ATT := Blink + Bold;
                        End;
                Blink : Begin
                          SetAtt := '1';
                          Ans.ATT := Blink + Bold;
                        End;
                 Bold : Begin
                          SetAtt := '5';
                          Ans.Att := Blink + Bold;
                        End;
                Blink +
                Bold   : Begin
                         End;
                Else Begin
                       SetAtt := '1;5';
                       Ans.Att := Blink + Bold;
                     End;
               End; { Ans.ATT }
    End; { Case A }
  End;  { SetATT }

Function SetFG(f : word) : string;
  Begin
    SetFg := '';
    If Ans.FG = F then Exit;
    Case F of
      Black  :  SetFG := '30';
      Red    :  SetFG := '31';
      Green  :  SetFG := '32';
      Yellow :  SetFG := '33';
      Blue   :  SetFG := '34';
      Magenta:  SetFG := '35';
      Cyan   :  SetFG := '36';
      White  :  SetFG := '37';
      Else Exit;
    End;
  Ans.FG := F;
  End;

Function SetBG(f : word) : string;
  Begin
    SetBg := '';
    If Ans.BG = F then Exit;
    Case F of
      Black  :  SetBG := '40';
      Red    :  SetBG := '41';
      Green  :  SetBG := '42';
      Yellow :  SetBG := '43';
      Blue   :  SetBG := '44';
      Magenta:  SetBG := '45';
      Cyan   :  SetBG := '46';
      White  :  SetBG := '47';
      Else Exit;
    End;
  Ans.BG := F;
  End;

Function A_St(FG, BG : Word) : String;
Var
  T  : String;
  T2 : String;
  T3 : String;
  Begin
    A_ST := '';
    If NOT ANS.ON then Exit;
    t    := '';
    t2   := '';
    T3   := '';
    Case FG of
      100   : Begin; End;           { No Change to FG go on to BG }
      Off, Bold, Blink, Bold +
      Blink : T := SetAtt(FG);
      Black, Bold + Black, Blink + Black, Bold + Blink +
      Black : Begin
                T := SetATT(FG - Black);
                T2 := SetFG(Black);
              End;
      Red, Bold + Red, Blink + Red, Bold + Blink +
      Red : Begin
              T := SetATT(FG - Red);
              T2 := SetFG(Red);
            End;
      Green, Bold + Green, Blink + Green, Bold + Blink +
      Green : Begin
                T := SetATT(FG - Green);
                T2 := SetFG(Green);
              End;
      Yellow, Bold + Yellow, Blink + Yellow, Bold + Blink +
      Yellow : Begin
                 T := SetATT(FG - Yellow);
                 T2 := SetFG(Yellow);
               End;
      Blue, Bold + Blue, Blink + Blue, Bold + Blink +
      Blue : Begin
               T := SetATT(FG - Blue);
               T2 := SetFG(Blue);
             End;
      Magenta, Bold + Magenta, Blink + Magenta, Bold + Blink +
      Magenta : Begin
                  T := SetATT(FG - Magenta);
                  T2 := SetFG(Magenta);
                End;
      Cyan, Bold + Cyan, Blink + Cyan, Bold + Blink +
      Cyan : Begin
               T := SetATT(FG - Cyan);
               T2 := SetFG(Cyan);
             End;
      White, Bold + White, Blink + White, Bold + Blink +
      White : Begin
                T := SetATT(FG - White);
                T2 := SetFG(White);
              End;
    End;

    Case BG of
      100     : T3 := '';
      Black   : T3 := SetBG(Black);
      Red     : T3 := SetBG(Red);
      Green   : T3 := SetBG(Green);
      Yellow  : T3 := SetBG(Yellow);
      Blue    : T3 := SetBG(Blue);
      Magenta : T3 := SetBG(Magenta);
      Cyan    : T3 := SetBG(Cyan);
      White   : T3 := SetBG(White);
    End;

    If T + T2 + T3 = '' Then Exit;
    If T <> '' Then
      Begin
        If T2 <> '' Then T := T + ';' + T2;
        if T3 <> '' Then T := T + ';' + T3;
      End Else
        Begin
          If T2 <> '' Then
            Begin
              T := T2;
              if T3 <> '' Then T := T + ';' + T3;
            End Else
            T := T3;
        End;
    A_ST := Esc + T +'m';
  End;

Begin
  Ans.Att := 255;  { These Values set invalidly on purpose.  When the first  }
  Ans.FG  := 255;  { call is made, this will FORCE! (pun for Jim and Guy)    }
  Ans.BG  := 255;  { them to be set.  If I set them at say 0, and the user   }
  Ans.ON  := True; { Called wanting a black backgroun, the function would not}
end.               { Return the 40m required because it would think it was   }
                   { already in black background                             }