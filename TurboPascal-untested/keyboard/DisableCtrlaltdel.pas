(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0068.PAS
  Description: Disable Ctrl-Alt-Del
  Author: GREG VIGNEAULT
  Date: 01-27-94  13:30
*)

(*******************************************************************)
 PROGRAM CtrlCAD;   { CTRLCAD.PAS  Disable Ctrl-Alt-Del             }
                    { Oct.1992 Greg Vigneault                       }

 USES   Crt,        { import ClrScr, KeyPressed, ReadKey            }
        Dos;        { import GetIntVec, SetIntVec                   }

 VAR    old09Vector : POINTER;  { to save/restore original ISR      }
        ch          : CHAR;
        presses     : WORD;

 { the following mask & count Ctrl-Alt-Del|Ins|Enter keystrokes     }
 {$L CTRLCAD.OBJ}   { assembly, near calls                          }
 PROCEDURE InitTrapCAD( oldVector : POINTER );  EXTERNAL;
 PROCEDURE TrapCAD; Interrupt;                  EXTERNAL;
 FUNCTION  TriedCAD : WORD;                     EXTERNAL;
 PROCEDURE ForgetCAD;                           EXTERNAL;
 PROCEDURE WarmBoot;                            EXTERNAL;
 PROCEDURE ColdBoot;                            EXTERNAL;

 BEGIN
    (* NEVER allow Ctrl-Break while TrapCAD is active ...          *)
    CheckBreak := FALSE;            { disable Ctrl-Break            }

    GetIntVec( 9, old09Vector );    { get current keyboard ISR      }
    InitTrapCAD( old09Vector );     { pass vector to TrapCAD        }
    SetIntVec( 9, @TrapCAD );       { enable TrapCAD ISR            }

    ForgetCAD;                      { reset TriedCAD count to 0     }
    presses := 99;                  { any unlikely value            }

    { we'll just count the Ctrl-Alt-Del taps ...                    }
    REPEAT
        IF (presses <> TriedCAD)    { update only when changed      }
        THEN BEGIN
             presses := TriedCAD;
             ClrScr;
             Write('Ctrl-Alt-Del pressed ',presses,' times ');
             Write('[Press ESC to exit]');
        END;
        IF KeyPressed THEN ch := ReadKey;
    UNTIL (ch = #27);

    WriteLn; WriteLn;
    REPEAT
        Write('Would you like to warm boot the system? [Y/N] ',#7);
        ReadLn( ch );   ch := UpCase( ch );
    UNTIL ch IN ['Y','N'];
    IF ch = 'Y' THEN WarmBoot;      { emulate Ctrl-Alt-Del          }

    SetIntVec( 9, old09Vector );    { unload TrapCAD                }
    WriteLn; WriteLn('Ctrl-Alt-Del is now re-enabled!');
    CheckBreak := TRUE;             { restore Ctrl-Break            }
END.
(*******************************************************************)

 Put all of this remaining message into a text file named CTRLCAD.SCR,
 then type "DEBUG < CTRLCAD.SCR" (no quotes) to create CTRLCAD.ARC,
 and extract CTRLCAD.OBJ using PKUNPAK or PAK ...
======================= Start of DEBUG script =========================
 nCTRLCAD.ARC
 e100 FC BB 03 00 BF A5 01 BE 85 01 8A EF AD 86 CC AA FE C0 E2 FB 4B 75
 e116 F5 B9 FF FD BA 00 02 52 B4 3F CD 21 5F 72 66 8B F7 50 8B C8 B0 2A
 e12C F2 AE 75 5B B0 0D F2 AE 87 F7 BB 00 01 B2 04 AC 3C 2A 72 FB 74 4C
 e142 57 BF A3 01 B9 40 00 8A E1 F2 AE 5F 75 3B FE C1 2A E1 88 27 43 FE
 e158 CA 75 E0 56 BE 00 01 AD 86 C4 8B D0 AD 86 C4 5E B1 02 D2 E0 D3 E0
 e16E D2 E2 D3 EA D0 E1 D1 EA D1 D8 E2 FA 86 C2 AA 8A C4 AA 8A C2 AA EB
 e184 B1 30 0A 41 1A 61 1A BF 00 02 58 F7 D8 99 33 DB 8B CA 8B D0 B8 01
 e19A 42 57 CD 21 59 80 ED 02 CC 2B 2D
 g=100
 w200
 q GXD v3.3a: XX34-to-DEBUG script code by Greg Vigneault

*XX3401-000345-041092--72--85-16010-E---CTRLCAD.ARC--1-OF--1
4UV1J37AEo329Yx0GU-SCU2++2EN28fLRqA-+++AU-c+K104XVkqMw8EQF3YGVAyZUs++2-U
m-AWFMVUYcXY2k+-+U9IUEH+mQE+-uV60E7ZG-+WDmMWI7YYcogWSKFON272m7AbJ-H7j-72
GVCTE+hBH41YWNEXFOXQx1BlEF6bGOWcN5Zn6c-nW+VA3-IU4eVF++7ALAHBle6X+ZmU-S1q
0+4t2qQ+kkh+aBUVPy1YYNDa1-cu649Ym021l-2LIplM8SmaH7UuPCWk+12YX-i3MHXhUy7-
fmBgc0sE6A4+-sAu1gW-sH431UESIiWotY+5kEQgbJnwQn3Fi647g20M+z4vonA+Y+ms01Jl
a3uykrPFY9-ik8szTok1At56Utmvkvo0yDTD4eQQ+6UVG-hUHbk6xCj2ho1zHbkmxBZ5H-fx
lPR5UQE6Ua+ax4o0+0O801+F5Fc+
***** END OF XX-BLOCK *****

======================== End of DEBUG script ==========================

