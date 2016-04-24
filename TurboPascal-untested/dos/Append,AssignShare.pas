(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0031.PAS
  Description: APPEND, ASSIGN & SHARE
  Author: GREG VIGNEAULT
  Date: 10-28-93  11:34
*)

{===========================================================================
Date: 09-22-93 (08:41)
From: GREG VIGNEAULT
Subj: APPEND, ASSIGN, & SHARE
---------------------------------------------------------------------------
JS> How could I determine if DOS extension utilities (eg. Append,
  > Assign, and Share) are installed, using Turbo Pascal? }

(* Turbo/Quick/StonyBrook Pascal: Determine if extensions installed *)
PROGRAM DosExt;               { DOSEXT.PAS: Greg Vigneault 93.10.02  }

USES Dos;                     { Import Intr(), MsDos(), Registers    }

TYPE Extension = (Append, Assign, Share); { the PC/MS-DOS extensions }

VAR  Reg        : Registers;  { to access Intel 80x86 CPU registers  }
     Status     : WORD;       { to return system extension status    }
     Installed  : Extension;  { DOS extension (Append|Assign|Share)  }
     Okay       : BOOLEAN;    { success or failure (TRUE|FALSE)      }
     Func       : BYTE;       { the multiplex function number        }

(*------------------------------------------------------------------*)
FUNCTION DosVersion : WORD;                 { to check DOS version   }
  BEGIN
    Reg.AH := $30;                          { function:get DOS ver   }
    MsDos (Reg);                            { call DOS services      }
    DosVersion := Reg.AL * 100 + Reg.AH;    { ...version times 100   }
  END {DosVersion};

(*------------------------------------------------------------------*)
FUNCTION Multiplex (Func : WORD; VAR Status : WORD) : BOOLEAN;
  BEGIN
      Reg.AH := Func;                       { function number        }
      Reg.AL := 0;                          { subfunction:get status }
      Intr ($2F,Reg);                       { do multiplex interrupt }
      IF (Reg.Flags AND 1) <> 0 THEN BEGIN  { an error condition?    }
        Status := Reg.AX;                   { the DOS error code     }
        Multiplex := FALSE; END             { and flag the error     }
      ELSE BEGIN
        Status := WORD(Reg.AL);             { the function status    }
        Multiplex := TRUE;                  { and flag success       }
      END;
  END {Multiplex};

(*------------------------------------------------------------------*)
BEGIN {DosExt}

  WriteLn;
  IF DosVersion < 330 THEN BEGIN
    WriteLn ('PC/MS-DOS version is too low, sorry.');
    Halt (1);
  END;

  FOR Installed := Append TO Share DO BEGIN
    CASE Installed OF
      Append : BEGIN Write ('APPEND '); Func := $B7; END;
      Assign : BEGIN Write ('ASSIGN '); Func := $02; END;
      Share  : BEGIN Write ('SHARE  '); Func := $10; END;
    END; {CASE}
    IF NOT Multiplex (Func,Status) THEN
      WriteLn ('status unknown (MS-DOS error #',Status,').')
    ELSE
      CASE Status OF
        0,1 : BEGIN
                Write ('not installed: ');
                IF Status = 1 THEN Write ('and NOT ');
                WriteLn ('okay to install.');
              END;
        255 : WriteLn ('is installed.');
     END; {CASE & IF}
  END; {FOR}

END {DosExt}.
(********************************************************************)

