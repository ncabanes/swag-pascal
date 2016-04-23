(*
  System reset via software...

  Using a jump to address $FFFF:0000 doesn't always work to reboot
  a system, particularly under multi-taskers. In a Windows 3.1 DOS-
  session I get a dialog box, about a system violation, that tells
  me to shut down all applications and restart the system -- but my
  PC is certainly not reset by the software reboot attempt.

  AT-class systems ('286+) have a system controller IC which can be
  instructed to reset the system. This will force a reboot even under
  Windows.  The following TP code illustrates this process.

  Since this type of reset will interrupt all other processes, it's
  important that an application first close all files and flush all
  buffers. It would also be a good idea to ask the user if a entire
  system reset is okay. Use this "power reset" prudently! ...
*)
(*******************************************************************)

PROGRAM Reboot;     { TP system reboot: Jul.19.94 Greg Vigneault    }

PROCEDURE SoftReset;                    { software reset for PC/XTs }
  BEGIN                                 { invalid for multi-taskers }
    InLine( $2B/$C0/                    {   sub   ax, ax            }
            $8E/$C0/                    {   mov   es, ax            }
            $26/$C7/6/$72/4/$34/$12/    {   mov   es:[472h],1234h   }
            $EA/0/0/$FF/$FF);           {   jmp   0FFFFh:0000h      }
  END {SoftReset};

PROCEDURE HardReset;                    { hardware reset for '286+  }
  BEGIN                                 { (uses system controller)  }
    InLine( $B0/$FE/                    {   mov   al, 0FEh          }
            $E6/$64);                   {   out   64h, al           }
  END {HardReset};


BEGIN {Reboot}

  WriteLn; WriteLn('POWER RESET courtesy Greg Vigneault...');
  HardReset;
  { if we're still running then the system is probably a PC/XT...   }
  SoftReset;

END {Reboot}.
{       Internet(Greg.Vigneault@westonia.com) Fido(1:250/636)       }
(*******************************************************************)
