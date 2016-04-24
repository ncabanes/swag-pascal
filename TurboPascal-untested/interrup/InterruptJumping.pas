(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0014.PAS
  Description: Interrupt Jumping
  Author: DOUGLAS WEBB
  Date: 01-27-94  12:09
*)

{
 If you have an interrupt handler and you want to jump to the original
 interrupt handler and NOT return to your handler.

Call the following procedure with a pointer to the old interrupt handler
(which you'd better have saved :-).
}

PROCEDURE JumpToInterrupt(oldvector : Pointer);
INLINE(                        { Jump to old Intr from local ISR  }
   $5B/                        { POP  BX IP part of vector     }
   $58/                        { POP  AX CS part of vector     }
   $87/$5E/$0E/                { XCHG BX,[BP+14] switch ofs/bx }
   $87/$46/$10/                { XCHG AX,[BP+16] switch seg/ax }
   $8B/$E5/                    { MOV  SP,BP                    }
   $5D/                        { POP  BP                       }
   $07/                        { POP  ES                       }
   $1F/                        { POP  DS                       }
   $5F/                        { POP  DI                       }
   $5E/                        { POP  SI                       }
   $5A/                        { POP  DX                       }
   $59/                        { POP  CX                       }
   $CB                         { RETF      Jump [ToOldVector]  }
   );                          { to original timer vector      }
{end JumpToInterrupt}


