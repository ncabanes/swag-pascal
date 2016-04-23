==============================================================================
 BBS: -=- Edge of the Century -=-
  To: DANIEL KEMPTON               Date: 01-20-93 (05:13)
From: GREG VIGNEAULT             Number: 3196   [140] Pascal
Subj: CRITICAL ERROR HANDLER     Status: Public
------------------------------------------------------------------------------
DK> Can anyone PLEASE give me information on how to write a critical
  > error handler.

 Below is a quick'n-dirty critical error handler, written without
 any Asm (so is usable from TP v4.0+).  To test it, put a write-
 protected diskette in drive A:, then run the program.  It should
 report error #19 (13 hex, disk write-protected).

 It'll need to be modified & trimmed to your purpose.  You might
 code your handler to simply ignore errors, then let your main
 program take appropriate action, depending on the error, etc.

 DOS functions $00..$0C, $30, and $59 should be safe calls from the
 handler.  Function $59 will return the extended error information
 code that you'll need to check (eg. #32 = share violation), as well
 as other data - which you can read up on, in a Dos reference text.

 I've used one byte of the DOS intra-process communication area (at
 $40:$F0) to return the value needed to tell Dos what to do about
 the error, rather than juggle registers.  This should be okay.

 This code is cramped, to fit into a single message ...

{*******************************************************************}
 PROGRAM Example;                       { Critical Error Handler    }
 USES Dos,      { import MsDos, GetIntVec, SetIntVec, Registers     }
      Crt;      { import CheckBreak                                 }
 VAR OldISR     : POINTER;              { to save original ISR ptr  }
     Reg        : Registers;            { to access CPU registers   }
     errNumber  : WORD;                 { extended error code       }
     errClass,                          { error class               }
     errAction,                         { recommended action        }
     errLocus   : BYTE;                 { error locus               }
     FileName   : String[13];           { for ASCIIZ file name      }
{-------------------------------------------------------------------}
 PROCEDURE cErrorISR( AX,BX,CX,DX,SI,DI,DS,ES,BP : WORD); Interrupt;
    BEGIN  { This is it! ...                                        }
    InLine($FB);                        { STI (allow interrupts)    }
    Reg.AX := $3000;  MsDos(Reg);       { fn: get Dos version       }
    IF (Reg.AH < 3) THEN Reg.AL := 3    { if less than Dos 3+ :FAIL }
        ELSE BEGIN                      { else take a closer look.. }
        Reg.AH := $59;  Reg.BX := 0;    { fn: get extended info     }
        MsDos( Reg );                   { call Dos                  }
        errNumber := Reg.AX;            { set|clear error number    }
        errClass := Reg.BH; errAction := Reg.BL; errLocus := Reg.CH;
        WriteLn;  Write( 'Critical error (#', errNumber, ') ' );
        REPEAT WriteLn;                 { loop for user response    }
          Write( 'Abort, Retry, Ignore, Fail (A|R|I|F) ? ',#7);
          Reg.AH := 1;  MsDos(Reg);     { get user input, via Dos   }
        UNTIL UpCase(CHR(Reg.AL)) IN ['A','R','I','F'];
        CASE CHR(Reg.AL) OF             { ... depending on input    }
            'i','I' : Reg.AL := 0;      { = ignore error            }
            'r','R' : Reg.AL := 1;      { = retry the action        }
            'a','A' : Reg.AL := 2;      { = abort                   }
            'f','F' : Reg.AL := 3;      { = fail                    }
            END; {case}
        END; {if Reg.AH}
    Mem[$40:$F0] := Reg.AL;             { to tell Dos what to think }
    InLine( $8B/$E5/                    { mov   sp,bp               }
            $5D/$07/$1F/$5F/$5E/        { pop   bp,es,ds,di,si      }
            $5A/$59/$5B/$58/            { pop   dx,cx,bx,ax         }
            $06/                        { push  es                  }
            $2B/$C0/                    { sub   ax,ax               }
            $8E/$C0/                    { mov   es,ax               }
            $26/$A0/$F0/$04/            { mov   al,es:[4F0h]        }
            $07/                        { pop   es                  }
            $CF);                       { iret                      }
    END {cErrorISR};
{-------------------------------------------------------------------}
 BEGIN  { the main program...                                       }
    CheckBreak := FALSE;                { don't allow Ctrl-Break!   }
    errNumber := 0;                     { clear the error code      }
    GetIntVec( $24, OldISR );           { save current ISR vector   }
    SetIntVec( $24, @cErrorISR );       { set our ISR               }
        {===========================================================}
        { insert your test code here ...                            }
        FileName := 'A:TEST.TXT' + CHR(0);  { ASCIIZ file name      }
        Reg.DS := SEG( FileName );          { file name segment     }
        Reg.DX := OFS( FileName[1] );       { file name offset      }
        Reg.CX := 0;                        { normal attribute      }
        Reg.AH := $3C;                      { fn: create file       }
        MsDos( Reg );                       { via Dos               }
        {===========================================================}
    IF (errNumber <> 0) THEN BEGIN
        Write(#13#10#10,'For error #',errNumber,', user requested ');
        CASE Mem[$40:$F0] OF
            0   : WriteLn('IGNORE');    { just your imagination     }
            1   : WriteLn('RETRY');     { ... endless futility ?    }
            2   : WriteLn('ABORT');     { DOS won't come back here! }
            3   : WriteLn('FAIL');      { call technical support    }
            END; {case}
        END; {if errNumber<>0}
    SetIntVec( $24, OldISR );           { must restore original ISR }
 END.
{*******************************************************************}

 Greg_

 Jan.20.1993.Toronto.Canada.        greg.vigneault@bville.gts.org
---
 * Baudeville BBS Toronto CANADA 416-283-0114 2200+ confs
 * PostLink(tm) v1.04  BAUDEVILLE (#1412) : RelayNet(tm)
