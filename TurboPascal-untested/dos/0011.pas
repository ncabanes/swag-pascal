===========================================================================
 BBS: Canada Remote Systems
Date: 06-17-93 (20:44)             Number: 8849
From: GREG VIGNEAULT               Refer#: NONE
  To: KURT TAN                      Recvd: NO  
Subj: WARM & COLD TP REBOOT...       Conf: (58) PASCAL
---------------------------------------------------------------------------
KT> Can anybody tell me how to reboot with Turbo Pascal?

 Hi Kurt,

 You may find that using interrupt $19 doesn't work on many systems.

 The following cold and warm boot procedures should work under most
 PC/MS-DOS environments.  It doesn't use either ASM or INLINE ...

(*******************************************************************)
PROGRAM DemoReboot;             { force a Cold or Warm Reboot       }

USES    Crt,                    { import ClrScr, ReadKey            }
        Dos;                    { import Intr(), Registers          }

PROCEDURE Reboot;               { <- only call from Cold & WarmBoot }
    VAR     dummy : Registers;  { Intr() needs Register TYPE        }
    BEGIN
        MemW[0:0] := 0;         { modify an interrupt vector (eg.0) }
        MemW[0:2] := $FFFF;     {  to point to $FFFF:$0000          }
        Intr(0,dummy);          {   and force a call to it          }
    END {Reboot};

PROCEDURE ColdBoot;             { like a system power-up or reset   }
    BEGIN
        MemW[0:$472] := $7F7F;  { tell the system it's a Cold boot  }
        Reboot;                 { ...we don't return from here      }
    END {ColdBoot};

PROCEDURE WarmBoot;             { same as Ctrl-Alt-Del reboot       }
    BEGIN
        MemW[0:$472] := $1234;  { tell the system it's a Warm boot  }
        Reboot;                 { ...bye-bye                        }
    END {WarmBoot};

BEGIN
        ClrScr;
        Write('Do you want a Warm or Cold reboot (W/C) ? ');
        IF UpCase(ReadKey) = 'W' THEN WarmBoot ELSE ColdBoot;

END {DemoReboot}.
(*******************************************************************)


 Greg_

 Jun.17.1993.Toronto UUCP greg.vigneault@bville.gts.org FIDO 1:250/304
---
 ■ RoseMail 2.10ß: NANET 41-62-24 Baudeville -Toronto ON - 416-283-0114
