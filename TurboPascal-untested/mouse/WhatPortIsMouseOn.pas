(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0014.PAS
  Description: What PORT is Mouse on
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:32
*)

{************************************************************}
PROGRAM WhatPortIsTheMouseOn;   { Sept 18/93, Greg Estabrooks}
TYPE
    MouseParamTable = RECORD
                        BaudRate   :WORD; { Baud Rate Div 100}
                        Emulation  :WORD;
                        ReportRate :WORD; { Report Rate.     }
                        FirmRev    :WORD;
                        ZeroWord   :WORD; { Should be zero.  }
                        PortLoc    :WORD; { Com Port Used.   }
                        PhysButtons:WORD; { Physical Buttons.}
                        LogButtons :WORD; { Logical Buttons. }
                      END;
VAR
   MouseInf :MouseParamTable;

PROCEDURE GetMouseInf( VAR MouseTable ); ASSEMBLER;
                       { Routine to Get info about mouse.   }
                       { NOTE Doesn't check to see if a     }
                       {  a mouse is installed.             }
ASM
  Push AX                      { Save Registers Used.       }
  Push ES
  Push DX
  Mov AX,$246C                 { Get Mouse Parameters.      }
  LES DX,MouseTable            { Point ES:DX to Param Table.}
  Int $33                      { Call Mouse Interrupt.      }
  Pop DX                       { Restore Registers used.    }
  Pop ES
  Pop AX
END;{GetMouseInf}

BEGIN
  GetMouseInf(MouseInf);        { Get mouse info.            }
  Writeln('     ___Mouse Info___'); { Show a title.          }
  Writeln;
  WITH MouseInf DO              { Display Mouse Info.        }
    BEGIN
      Writeln('Baud Rate     : ',BaudRate * 100);
      Writeln('Emulation     : ',Emulation);
      Writeln('Report Rate   : ',ReportRate);
      Writeln('FirmWare Rev  : ',FirmRev);
      Writeln('Com Port      : ',PortLoc);
      Writeln('Physical Butns: ',PhysButtons);
      Writeln('Logical Buttns: ',LogButtons);
    END;
  Readln;                       { Wait for user to have a look.}
END.{WhatPortIsTheMouseOn}
{************************************************************}

