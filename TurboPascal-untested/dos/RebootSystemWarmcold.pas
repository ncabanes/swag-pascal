(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0010.PAS
  Description: Reboot System Warm/Cold
  Author: GREG ESTABROOKS
  Date: 06-22-93  07:51
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-15-93 (11:09)             Number: 8831
From: GREG ESTABROOKS              Refer#: NONE
  To: KURT TAN                      Recvd: NO  
Subj: REBOOT                         Conf: (58) PASCAL
---------------------------------------------------------------------------
KT>Can anybody tell me how to reboot with Turbo Pascal?

        Below are the routines I use to reboot the system.
        Hope they help ya.

{********************************************************************}
PROGRAM RebootSys;              { June 15/93, Greg Estabrooks        }
USES CRT;                       { Writeln,Readkey,Clrscr             }
VAR
   CH :CHAR;                    { Hold Boot Choice                   }

PROCEDURE WarmBoot;
                 { Routine to cause system to do a WARM Boot         }


BEGIN
  Inline(
        $FB/                  { STI                                  }
        $B8/00/00/            { MOV   AX,0000                        }
        $8E/$D8/              { MOV   DS,AX                          }
        $B8/$34/$12/          { MOV   AX,1234                        }
        $A3/$72/$04/          { MOV   [0472],AX                      }
        $EA/$00/$00/$FF/$FF); { JMP   FFFF:0000                      }
END;

PROCEDURE ColdBoot;
                     { Routine to cause system to do a COLD Boot     }
BEGIN
  Inline(
        $FB/                  { STI                                  }
        $B8/01/00/            { MOV   AX,0001                        }
        $8E/$D8/              { MOV   DS,AX                          }
        $B8/$34/$12/          { MOV   AX,1234                        }
        $A3/$72/$04/          { MOV   [0472],AX                      }
        $EA/$00/$00/$FF/$FF); { JMP   FFFF:0000                      }
END;

BEGIN
  Clrscr;                       { Clear the screen                      }
                                { Ask for which type of boot to be used }
  Writeln('Would You like to do a [W]arm or [C]old Boot? ');
  CH := Readkey;                { Get Users Choice,                     }

  CASE UpCase( CH ) OF
     'W'    : BEGIN
                Writeln('Doing a Warm Boot ');
                WarmBoot;      { Call warm Reboot procedure             }
              END;
     'C'    : BEGIN
                Writeln('Doing a Cold Boot ');
                ColdBoot;      { Call cold reboot procedure             }
              END;
  Else                         { Else don't reboot at all               }
    Writeln('Not Rebooting!');
  END;
END.
{***********************************************************************}

Greg Estabrooks <<Message Entered on 06-15-93 at 09am>>
---
 ■ OLX 2.1 TD ■ Beer. It's not just for breakfast anymore!
 ■ RoseMail 2.10ß: NANET: VE1EI BBS, Halifax NS, (902)-868-2475

