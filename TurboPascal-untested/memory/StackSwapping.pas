(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0045.PAS
  Description: Stack Swapping
  Author: BOB SWART
  Date: 01-27-94  12:23
*)

{
> Also, can you tell me what the opro procedure SwapStackAndCallNear()
> does?  Does it save registers, swap SP and do a near call, or what?

From the description DJ gave, I reconstructed it for you:
}

procedure SwapStackAndCallNear(Routine: Word;
                               SP: Pointer;
                               var Regs);
{
  Flags are saved (unchanged during routine),
  Stack is restored after completion,
  Registers AX,BX,CX,DX,SI,DI and ES destroyed.
}
InLine(
  $9C/     {      PUSHF                              }
  $07/     {      pop   ES    ; ES := flags          }
  $58/     {      pop   AX    ; AX := Regs ofs       }
  $5B/     {      pop   BX    ; BX := Regs seg       }
  $59/     {      pop   CX    ; CX := SP ofs         }
  $5A/     {      pop   DX    ; DX := SP seg         }
  $5F/     {      pop   DI    ; DI := near routine   }
           { @SwapStack                              }
  $8C/$D6/ {      mov   SI,SS ; SI := SS = stack seg }
  $FA/     {      cli         ; disable interrupts   }
  $8E/$D2/ {      mov   SS,DX ; SS := DX = SP seg    }
  $87/$CC/ {      xchg  SP,CX ; CX := SP = stack ofs }
           {                  ; SP := SP = SP ofs    }
  $06/     {      PUSH  ES    ; push ES (= flags)    }
  $9D/     {      POPF        ; set flags again      }
  $9C/     {      PUSHF       ; push flags           }
  $56/     {      PUSH  SI    ; SI = old stackseg SS }
  $51/     {      PUSH  CX    ; CX = old stackofs SP }
           { @CallNear:                              }
  $53/     {      PUSH  BX    ; BX = ofs Regs var    }
  $50/     {      PUSH  AX    ; AX = seg Regs var    }
  $FF/$15/ {      CALL  WORD PTR [DI]  ; near call   }
           { @SwapBackStack:                         }
  $FA/     {      CLI         ; disable interrupts   }
  $59/     {      pop   CX    ; CX := old stackofs SP}
  $5E/     {      pop   SI    ; SI := old stackseg SS}
  $07/     {      pop   ES    ; pop flags in ES      }
  $8E/$D6/ {      mov   SS,SI ; stack seg back in SS }
  $89/$CC/ {      mov   SP,CX ; stack ofs back in SP }
           { @Exit:                                  }
  $06/     {      PUSH  ES    ; push values of flags }
  $9D);    {      POPF        ; pop unchanged flags  }

{
> I would like to write my own code to do this because I don't have
> opro, and I'm not going to buy it for one procedure... :)
Please test my InLine macro, and tell me if this works. Sometime soon I'll
try to experiment with PAUSEDEV myself (if I can find it again, that is ;-)
}

