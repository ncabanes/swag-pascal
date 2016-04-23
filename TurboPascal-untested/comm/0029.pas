{-------------------------------------------------------------------------
 !                                                                       !
 !  UARD.PAS   : Uart Detection Program        Ver 1.0                   !
 !                                                                       !
 !  Created    : 09-23-93        Changed: 09-23-93                       !
 !                                                                       !
 !  Converted To Turbo Pascal 6.0 By: David D. Cruger                    !
 !                                                                       !
 !  Original Program By:      National Semiconductor Corporation         !
 !  NS1655.ZIP                Microcomputer Systems Division             !
 !                            Microcontroller Applications Group         !
 !                            Written By: Louis Shay / 01/11/89          !
 !                            Originaly Written in some form of 'C'.     !
 !                            This program only does the 'detection'.    !
 !                            The original program ran some tests on     !
 !                            the Uarts.                                 !
 !                                                                       !
 !  SAVE/RESTORE Uart Registers Routines from Form Message #195739       !
 !  by Michael Day (TeamB)                                               !
 !                                                                       !
 !  *NOTE*  This program is just an example of how to detect Uarts and   !
 !          is not intended to be a stand alone program.  I here by      !
 !          release this program to the public domain.  Use at your own  !
 !          risk.                                                        !
 !                                                                       !
 !   0: No Uart at Port Address                                          !
 !   1: INS8250, INS8250-B                                               !
 !   2: INS8250A, INS82C50A, NS16450, NS16C450                           !
 !   3: NS16550A                                                         !
 !   4: NS16C552                                                         !
 !                                                                       !
 !------------------------------------------------------------------------}

Program UartD;

  {
     A =  Align Data
     B =  Boolean Short
     D =  Debug On
     E =  Emulate 80287
     F =  Far Calls
     G =  Generate 286 Code
     L =  Local Symbol Information
     N =  Numeric Processing Switch
     O =  Overlay
     R =  Range Checking On
     S =  Stack-Overflow
     V =  Var-String Checking
  }

{$a+,b-,d-,e-,f-,g-,l-,n-,o-,r-,s-,v-}                                 {}
{$M 2500,0,0}

Uses Dos;

Type Uart_Registers=Array[0..9] OF Byte;  { Uart Registers              }

Var  URegs: Uart_Registers;      { Uart Register Array                  }
     PA   : Word;                { Port Address Com1=$3F8  Com2=$2F8..  }

     RBR,THR,IER,IIR,FCR,LCR,MCR,LSR,MSR,SCR,DLL,DLM,AFR: Word;

{-------- Save Uart Registers --------}
Procedure Save_Uart_Registers(BaseAdd: Word; Var URegs: Uart_Registers);
Var I: Byte;
Begin
  ASM CLI; END;
  For I:=1 to 6 Do URegs[I]:=Port[BaseAdd+I];
  Port[BaseAdd+3]:=Port[BaseAdd+3] or $80;
  URegs[7]:=Port[BaseAdd+0];
  URegs[8]:=Port[BaseAdd+1];
  Port[BaseAdd+3]:=Port[BaseAdd+3] and $7F;
  ASM STI; END;
End; { End Procedure }

{------ Restore Uart Registers --------}
Procedure Restore_Uart_Registers(BaseAdd: Word; URegs: Uart_Registers);
Var I: Byte;
Begin
  ASM CLI; END;
  Port[BaseAdd+3]:=Port[BaseAdd+3] or $80;
  Port[BaseAdd+0]:=URegs[7];
  Port[BaseAdd+1]:=URegs[8];
  Port[BaseAdd+3]:=Port[BaseAdd+3] and $7F;
  For I:=1 to 6 Do Port[BaseAdd+I]:=URegs[I];
  ASM STI; END;
End; { End Procedure }

Procedure Return_Code(C: Byte);
Begin

  Case C of
   0:Writeln('No Uart at Port Address');
   1:Writeln('INS8250, INS8250-B');
   2:Writeln('INS8250A, INS82C50A, NS16450, NS16C450');
   3:Writeln('NS16550A');
   4:Writeln('NS16C552');
   End;

   Restore_Uart_Registers(PA,URegs);

   Halt(C);  { Halt with Errorlevel of Uart }

End; { End Procedure }

Procedure Set_Uart_Register_Values(PA: Word);
Begin

RBR:=PA+0;         { Receive Buffer Registers          (R  ) (DLAB=0)     }
THR:=PA+0;         { Transmitter Holding Register      (  W) (DLAB=0)     }
IER:=PA+1;         { Interrupt Enable Register         (R/W) (DLAB=0)     }
IIR:=PA+2;         { Interrupt Ident. Register         (R  )              }
FCR:=PA+2;         { FIFO Control Register             (  W)              }
LCR:=PA+3;         { Line Control Register             (R/W)              }
MCR:=PA+4;         { MODEM Control Register            (R/W)              }
LSR:=PA+5;         { Line Status Register              (R  )              }
MSR:=PA+6;         { MODEM Status Register             (R/W)              }
SCR:=PA+7;         { Scratch Register                  (R/W)              }
DLL:=PA+0;         { Divisor Latch (LSB)               (R/W) (DLAB=1)     }
DLM:=PA+1;         { Divisor Latch (MSB)               (R/W) (DLAB=1)     }
AFR:=PA+2;         { Alternate Function Register       (R/W)              }

End; { End Procedure }

Begin  { Main Section of Program }

PA:=$3F8; { Com1/ This can be changed to any port address you want }
Write('Com1: $3F8 : Uart:=');

Save_Uart_Registers(PA,URegs);  { Saves State of Current Uart Registers    }
Set_Uart_Register_Values(PA);   { Return_Code() Restores Uart Registers    }

Port[LCR]:=$AA;                         { Test LCR Registers               }
If $AA<>Port[LCR] Then Return_Code(0);

Port[DLM]:=$55;                         { Test DLM Present 8-bits          }
If $55<>Port[DLM] Then Return_Code(0);

Port[LCR]:=$55;                         { LCR/ DLAB=0                      }
If $55<>Port[LCR] Then Return_Code(0);

Port[IER]:=$55;                         { Test IER Present 4-bits          }
If $05<>Port[IER] Then Return_Code(0);

Port[FCR]:=$0;                          { FIFO's Off, If Present           }
Port[IER]:=$0;                          { Interrupts Off, IIR Should be 01 }
If $1<>Port[IIR] Then Return_Code(0);

{----- Test Modem Control Register Address. Should be 5-bits Wide -----}
Port[MCR]:=$F5;                         { 8-bit Write                      }
If $15<>Port[MCR] Then Return_Code(0);

{------ Test MCR/MSR Loopback Functions ------}

Port[MCR]:=$10;                         { Set Loop Mode                    }
Port[MSR]:=$0;                          { Clear out Delta Bits             }
If ($F0 and Port[MSR])<>0 Then Return_Code(0); { Check State Bits          }

Port[MCR]:=$1F;                         { Toggle Modem Control Lines       }
If ($F0 and Port[MSR])<>$F0 Then Return_Code(0); { Check State Bits        }

Port[MCR]:=$03;                         { Exit Loop Mode, DTR, RTS Active  }

{---- Port Id Successful at this point. determine port type ----}

Port[SCR]:=$55;                         { Is There a Scratch Register?    }
If $55<>Port[SCR] Then Return_Code(1);  { No SCR, Type = INS8250          }

Port[FCR]:=$CF;                         { Enable FIFO's, If Present       }
If ($C0 and Port[IIR])<>$C0 Then Return_Code(2); { Check FIFO ID bits     }
Port[FCR]:=$0;                          { Turn Off FIFO's                 }

Port[LCR]:=$80;                         { Set DLAB                        }
Port[AFR]:=$07;                         { Write to AFR                    }
If $07<>Port[AFR] Then                  { Read AFR                        }
  Begin
    Port[LCR]:=$0;                      { Reset DLAB                      }
    Return_Code(3);                     { If Not Type=NS16550A            }
  End;

Port[AFR]:=$0;                          { Clear AFR                       }
Port[LCR]:=$0;                          { Reset DLAB                      }
Return_Code(4);

End.
