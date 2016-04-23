
UNIT HTkb;

{ Complete set of all keyboard scan codes.
  Part of the Heartware Toolkit v2.00 (HTkb.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

INTERFACE

const

{ letters ······························································ }

  kb_AA                  = $1E61;     { a                                }
  kb_A                   = $1E41;     { A                                }
  kb_CtrlA               = $1E01;     { ^A                               }
                                      { SOH - Start Of Header            }
  kb_AltA                = $1E00;     { ALT A                            }

  kb_BB                  = $3062;     { b                                }
  kb_B                   = $3042;     { B                                }
  kb_CtrlB               = $3002;     { ^B                               }
                                      { STX - Start Of Text              }
  kb_AltB                = $3000;     { ALT B                            }

  kb_CC                  = $2E63;     { c                                }
  kb_C                   = $2E43;     { C                                }
  kb_CtrlC               = $2E03;     { ^C                               }
                                      { ETX - End Of Text                }
  kb_AltC                = $2E00;     { ALT C                            }

  kb_DD                  = $2064;     { d                                }
  kb_D                   = $2044;     { D                                }
  kb_CtrlD               = $2004;     { ^D                               }
                                      { EOT - End Of Transmission        }
  kb_AltD                = $2000;     { ALT D                            }

  kb_EE                  = $1265;     { e                                }
  kb_E                   = $1245;     { E                                }
  kb_CtrlE               = $1205;     { ^E                               }
                                      { ENQ - Enquire                    }
  kb_AltE                = $1200;     { ALT E                            }

  kb_FF                  = $2166;     { f                                }
  kb_F                   = $2146;     { F                                }
  kb_CtrlF               = $2106;     { ^F                               }
                                      { ACK - Acknowledge                }
  kb_AltF                = $2100;     { ALT F                            }

  kb_GG                  = $2267;     { g                                }
  kb_G                   = $2247;     { G                                }
  kb_CtrlG               = $2207;     { ^G                               }
                                      { BEL - Bell                       }
  kb_AltG                = $2200;     { ALT G                            }

  kb_HH                  = $2368;     { h                                }
  kb_H                   = $2348;     { H                                }
  kb_CtrlH               = $2308;     { ^H                               }
                                      { BS - BackSpace                   }
  kb_AltH                = $2300;     { ALT H                            }

  kb_II                  = $1769;     { i                                }
  kb_I                   = $1749;     { I                                }
  kb_CtrlI               = $1709;     { ^I                               }
                                      { HT - Horizontal Tab              }
  kb_AltI                = $1700;     { ALT I                            }

  kb_JJ                  = $246A;     { j                                }
  kb_J                   = $244A;     { J                                }
  kb_CtrlJ               = $240A;     { ^J                               }
                                      { LF - Line Feed                   }
  kb_AltJ                = $2400;     { ALT J                            }

  kb_KK                  = $256B;     { k                                }
  kb_K                   = $254B;     { K                                }
  kb_CtrlK               = $250B;     { ^K                               }
                                      { VT - Vertical Tab                }
  kb_AltK                = $2500;     { ALT K                            }

  kb_LL                  = $266C;     { l                                }
  kb_L                   = $264C;     { L                                }
  kb_CtrlL               = $260C;     { ^L                               }
                                      { FF - Form Feed (new page)        }
  kb_AltL                = $2600;     { ALT L                            }

  kb_MM                  = $326D;     { m                                }
  kb_M                   = $324D;     { M                                }
  kb_CtrlM               = $320D;     { ^M                               }
                                      { CR - Carriage Return             }
  kb_AltM                = $3200;     { ALT M                            }

  kb_NN                  = $316E;     { n                                }
  kb_N                   = $314E;     { N                                }
  kb_CtrlN               = $310E;     { ^N                               }
                                      { SO - Shift Out (numbers)         }
  kb_AltN                = $3100;     { ALT N                            }

  kb_OO                  = $186F;     { o                                }
  kb_O                   = $184F;     { O                                }
  kb_CtrlO               = $180F;     { ^O                               }
                                      { SI - Shift In (letters)          }
  kb_AltO                = $1800;     { ALT O                            }

  kb_PP                  = $1970;     { p                                }
  kb_P                   = $1950;     { P                                }
  kb_CtrlP               = $1910;     { ^P                               }
                                      { DEL - Delete                     }
  kb_AltP                = $1900;     { ALT P                            }

  kb_QQ                  = $1071;     { q                                }
  kb_Q                   = $1051;     { Q                                }
  kb_CtrlQ               = $1011;     { ^Q                               }
                                      { DC1 - Device Control 1           }
  kb_AltQ                = $1000;     { ALT Q                            }

  kb_RR                  = $1372;     { r                                }
  kb_R                   = $1352;     { R                                }
  kb_CtrlR               = $1312;     { ^R                               }
                                      { DC2 - Device Control 2           }
  kb_AltR                = $1300;     { ALT R                            }

  kb_SS                  = $1F73;     { s                                }
  kb_S                   = $1F53;     { S                                }
  kb_CtrlS               = $1F13;     { ^S                               }
                                      { DC3 - Device Control 3           }
  kb_AltS                = $1F00;     { ALT S                            }

  kb_TT                  = $1474;     { t                                }
  kb_T                   = $1454;     { T                                }
  kb_CtrlT               = $1414;     { ^T                               }
                                      { DC4 - Device Control 4           }
  kb_AltT                = $1400;     { ALT T                            }

  kb_UU                  = $1675;     { u                                }
  kb_U                   = $1655;     { U                                }
  kb_CtrlU               = $1615;     { ^U                               }
                                      { NAK - Negative Acknowlegde       }
  kb_AltU                = $1600;     { ALT U                            }

  kb_VV                  = $2F76;     { v                                }
  kb_V                   = $2F56;     { V                                }
  kb_CtrlV               = $2F16;     { ^V                               }
                                      { SYN - Syncronize                 }
  kb_AltV                = $2F00;     { ALT V                            }

  kb_WW                  = $1177;     { w                                }
  kb_W                   = $1157;     { W                                }
  kb_CtrlW               = $1117;     { ^W                               }
                                      { ETB - End of Text Block          }
  kb_AltW                = $1100;     { ALT W                            }

  kb_XX                  = $2D78;     { x                                }
  kb_X                   = $2D58;     { X                                }
  kb_CtrlX               = $2D18;     { ^X -                             }
                                      { CAN - Cancel                     }
  kb_AltX                = $2D00;     { ALT X                            }

  kb_YY                  = $1579;     { y                                }
  kb_Y                   = $1559;     { Y                                }
  kb_CtrlY               = $1519;     { ^Y                               }
                                      { EM - End of Medium               }
  kb_AltY                = $1500;     { ALT Y                            }

  kb_ZZ                  = $2C7A;     { z                                }
  kb_Z                   = $2C5A;     { Z                                }
  kb_CtrlZ               = $2C1A;     { ^Z                               }
                                      { SUB - Substitute                 }
  kb_AltZ                = $2C00;     { ALT Z                            }

{ numbers ······························································ }

  kb_1                   = $0231;     { 1                                }
  kb_Pad1                = $4F31;     { SHIFT 1      number pad          }
  kb_Alt1                = $7800;     { ALT 1                            }

  kb_2                   = $0332;     { 2                                }
  kb_Pad2                = $5032;     { SHIFT 2      number pad          }
  kb_Alt2                = $7900;     { ALT 2                            }
  kb_Ctrl2               = $0300;     { ^1 (NUL)                         }

  kb_3                   = $0433;     { 3                                }
  kb_Pad3                = $5133;     { SHIFT 3      number pad          }
  kb_Alt3                = $7A00;     { ALT 3                            }

  kb_4                   = $0534;     { 4                                }
  kb_Pad4                = $4B34;     { SHIFT 4      number pad          }
  kb_Alt4                = $7B00;     { ALT 4                            }

  kb_5                   = $0635;     { 5                                }
  kb_Pad5                = $4C35;     { SHIFT 5      number pad          }
  kb_Alt5                = $7C00;     { ALT 5                            }

  kb_6                   = $0736;     { 6                                }
  kb_Pad6                = $4D36;     { SHIFT 6      number pad          }
  kb_Ctrl6               = $071E;     { ^6 (RS)                          }
  kb_Alt6                = $7D00;     { ALT 6                            }

  kb_7                   = $0837;     { 7                                }
  kb_Pad7                = $4737;     { SHIFT 7      number pad          }
  kb_Alt7                = $7E00;     { ALT 7                            }

  kb_8                   = $0938;     { 8                                }
  kb_Pad8                = $4838;     { SHIFT 8      number pad          }
  kb_Alt8                = $7F00;     { ALT 8                            }

  kb_9                   = $0A39;     { 9                                }
  kb_Pad9                = $4939;     { SHIFT 9      number pad          }
  kb_Alt9                = $8000;     { ALT 9                            }

  kb_0                   = $0B30;     { 0                                }
  kb_Pad0                = $5230;     { SHIFT 0      number pad          }
  kb_Alt0                = $8100;     { ALT 0                            }

{ etc: characters ······················································ }

  kb_Less                = $333C;     { <                                }
  kb_Great               = $343E;     { >                                }

  kb_Minus               = $352D;     { -                                }
  kb_GrayMinus           = $4A2D;     { -                                }
  kb_CtrlMinus           = $0C1F;     { ^-                               }
  kb_AltMinus            = $8200;     { ALT -                            }
  kb_ShiftGrayMinus      = $4A2D;     { SHIFT -                          }

  kb_Plus                = $1A2B;     { +                                }
  kb_GrayPlus            = $4E2B;     { +                                }
  kb_WhitePlus           = $0D2B;     { +                                }
  kb_ShiftGrayPlus       = $4E2B;     { SHIFT +                          }

  kb_Equal               = $0D3D;     { =                                }
  kb_AltEqual            = $8300;     { ALT =                            }

  kb_Slash               = $352F;     { /                                }

  kb_BackSlash           = $2B5C;     { \                                }
  kb_CtrlBackSlash       = $2B1C;     { ^\                               }
                                      { FS - File Separator              }

  kb_OpenBracket         = $1A5B;     { [                                }
  kb_CtrlOpenBracket     = $1A1B;     { ^[                               }
                                      { ESC - Escape                     }

  kb_CloseBracket        = $1B5D;     { ]                                }
  kb_CtrlCloseBracket    = $1B1D;     { ^]                               }
                                      { GS - Group Separator             }

  kb_OpenParenthesis     = $0A28;     { (                                }

  kb_CloseParenthesis    = $0B29;     { )                                }

  kb_OpenBrace           = $1A7B;     { can't write it                   }

  kb_CloseBrace          = $1B7D;     { can't write it                   }

  kb_Apostrophe          = $2827;     { '                                }
  kb_Grave               = $2960;     { `                                }

  kb_Quote               = $2822;     { "                                }

  kb_Tilde               = $297E;     { ~                                }

  kb_Cater               = $075E;     { ^                                }

  kb_Semicolon           = $273B;     { ;                                }

  kb_Comma               = $332C;     { ,                                }

  kb_Colon               = $273A;     { :                                }

  kb_Period              = $342E;     { .                                }
  kb_ShiftPeriod         = $532E;     { SHIFT .      number pad          }

  kb_GrayAsterisk        = $372A;     { *                                }
  kb_WhiteAsterisk       = $1A2A;     { *                                }

  kb_ExclamationPoint    = $0221;     { !                                }

  kb_QuestionMark        = $353F;     { ?                                }

  kb_NumberSign          = $0423;     { #                                }

  kb_Dollar              = $0524;     { $                                }

  kb_Percent             = $0625;     { %                                }

  kb_AmpersAnd           = $0826;     { &                                }

  kb_At                  = $0340;     { @                                }
                                      { ^@  = 00h                        }
                                      { NUL - Null Character             }
  kb_UnitSeparator       = $0C5F;     { _                                }
                                      { ^_  = 1Fh                        }
                                      { US  - Unit Separator             }

  kb_Vertical            = $2B7C;     { |                                }

  kb_Space               = $3920;     { SPACE BAR                        }

{ functions ···························································· }

  kb_F1                  = $3B00;     { F1                               }
  kb_ShiftF1             = $5400;     { SHIFT F1                         }
  kb_CtrlF1              = $5E00;     { ^F1                              }
  kb_AltF1               = $6800;     { ALT F1                           }

  kb_F2                  = $3C00;     { F2                               }
  kb_ShiftF2             = $5500;     { SHIFT F2                         }
  kb_CtrlF2              = $5F00;     { ^F2                              }
  kb_AltF2               = $6900;     { ALT F2                           }

  kb_F3                  = $3D00;     { F3                               }
  kb_ShiftF3             = $5600;     { SHIFT F3                         }
  kb_CtrlF3              = $6000;     { ^F3                              }
  kb_AltF3               = $6A00;     { ALT F3                           }

  kb_F4                  = $3E00;     { F4                               }
  kb_ShiftF4             = $5700;     { SHIFT F4                         }
  kb_CtrlF4              = $6100;     { ^F4                              }
  kb_AltF4               = $6B00;     { ALT F4                           }

  kb_F5                  = $3F00;     { F5                               }
  kb_ShiftF5             = $5800;     { SHIFT F5                         }
  kb_CtrlF5              = $6200;     { ^F5                              }
  kb_AltF5               = $6C00;     { ALT F5                           }

  kb_F6                  = $4000;     { F6                               }
  kb_ShiftF6             = $5900;     { SHIFT F6                         }
  kb_CtrlF6              = $6300;     { ^F6                              }
  kb_AltF6               = $6D00;     { ALT F6                           }

  kb_F7                  = $4100;     { F7                               }
  kb_ShiftF7             = $5A00;     { SHIFT F7                         }
  kb_CtrlF7              = $6400;     { ^F7                              }
  kb_AltF7               = $6E00;     { ALT F7                           }

  kb_F8                  = $4200;     { F8                               }
  kb_ShiftF8             = $5B00;     { SHIFT F8                         }
  kb_CtrlF8              = $6500;     { ^F8                              }
  kb_AltF8               = $6F00;     { ALT F8                           }

  kb_F9                  = $4300;     { F9                               }
  kb_ShiftF9             = $5C00;     { SHIFT F9                         }
  kb_CtrlF9              = $6600;     { ^F9                              }
  kb_AltF9               = $7000;     { ALT F9                           }

  kb_F10                 = $4400;     { F10                              }
  kb_ShiftF10            = $5D00;     { SHIFT F10                        }
  kb_CtrlF10             = $6700;     { ^F10                             }
  kb_AltF10              = $7100;     { ALT F1\0                         }

{ cursors ······························································ }

  kb_Up                  = $4800;     { UP                               }

  kb_Down                = $5000;     { DOWN                             }

  kb_Left                = $4B00;     { LEFT                             }
  kb_CtrlLeft            = $7300;     { ^LEFT                            }

  kb_Right               = $4D00;     { RIGHT                            }
  kb_CtrlRight           = $7400;     { ^RIGHT                           }

  kb_Home                = $4700;     { HOME                             }
  kb_CtrlHome            = $7700;     { ^HOME                            }

  kb_End                 = $4F00;     { END                              }
  kb_CtrlEnd             = $7500;     { ^END                             }

  kb_PgUp                = $4900;     { PG UP                            }
  kb_CtrlPgUp            = $8400;     { ^PG UP                           }

  kb_PgDown              = $5100;     { PG DN                            }
  kb_CtrlPgDown          = $7600;     { ^PG DN                           }

{ etc: keys ···························································· }

  kb_Esc                 = $011B;     { ESC                              }

  kb_Enter               = $1C0D;     { RETURN                           }
  kb_CtrlEnter           = $1C0A;     { ^ENTER                           }
                                      { LF - Line Feed                   }

  kb_BackSpace           = $0E08;     { BACKSPACE                        }
  kb_CtrlBackspace       = $0E7F;     { ^BACKSPACE                       }
                                      { DEL - Delete                     }

  kb_Tab                 = $0F09;     { TAB                              }
  kb_Shift_Tab           = $0F00;     { SHIFT TAB                        }

  kb_Ins                 = $5200;     { INSERT                           }

  kb_Del                 = $5300;     { DELETE                           }

  kb_45                  = $565C;     { Key 45                       [2] }
  kb_Shift45             = $567C;     { SHIFT KEY 45                 [2] }

  kb_CtrlPrtSc           = $7200;     { ^PRTSC                       [2] }

  kb_CtrlBreak           = $0000;     { ^BREAK                       [2] }



{ footnotes ······························································

  [1] All key codes refers to Interrupt 16h Services 0 and 1,
      the "Standard Function", that works with all keyboards types.

  [2] These key codes are only availlable in the 101/102-key keyboard,
      the current IBM standard ("Enhanced") keyboard.

··········································································

INT 16h,  00h (0)        Keyboard Read                                   all

    Returns the next character in the keyboard buffer; if no character is
    available, this service waits until one is available.

       On entry:      AH         00h

       Returns:       AL         ASCII character code
                      AH         Scan code

  ──────────────────────────────────────────────────────────────────────────

       Notes:         The scan codes are the numbers representing the
                      location of the key on the keyboard. As new keys
                      have been added and the keyboard layout rearranged,
                      this numbering scheme has not been consistent with
                      its original purpose.

                      If the character is a special character, then AL
                      will be 0 and the value in AH will be the extended
                      scan code for the key.

                      Use the scan codes to differentiate between keys
                      representing the same ASCII code, such as the plus
                      key across the top of the keyboard and the gray plus
                      key.

                      After the character has been removed from the
                      keyboard buffer, the keyboard buffer start pointer
                      (at 0:041Ah) is increased by 2. If the start pointer
                      is beyond the end of the buffer, the start pointer
                      is reset to the start of the keyboard buffer.

                      If no character is available at the keyboard, then
                      the AT, XT-286, and PC Convertible issue an INT 15h,
                      Service 90h (Device Busy), for the keyboard,
                      informing the operating system that there is a
                      keyboard loop taking place and thereby allowing the
                      operating system to perform another task.

                      After every character is typed, the AT, XT-286, and
                      PC Convertible issue an INT 15h, Service 91h
                      (Interrupt Complete). This allows the operating
                      system to switch back to a task that is waiting for
                      a character at the keyboard.

                      See Service 10h for an equivalent service that
                      supports the enhanced (101/102-key) keyboard.

··········································································

INT 16h,  01h (1)        Keyboard Status                                 all
    Checks to see if a character is available in the buffer.

       On entry:      AH         01h

       Returns:       Zero       0, if character is available
                                 1, if character is not available
                      AL         ASCII character code (if character is
                                 available)
                      AH         Scan code (if character is available)

  ──────────────────────────────────────────────────────────────────────────

       Notes:         If a character is available, the Zero Flag is
                      cleared and AX contains the ASCII value in AL and
                      the scan code in AH. The character is not removed
                      from the buffer. Use Service 00h to remove the
                      character from the buffer. See Service 00h for a
                      complete description of the meaning of AX if a
                      character is available.

                      This service is excellent for clearing the keyboard
                      or allowing a program to be interruptable by a
                      specific key sequence.

                      See Service 11h for an equivalent service that
                      supports the enhanced (101/102-key) keyboard.

········································································ }



IMPLEMENTATION


END. { HTkb.PAS }


