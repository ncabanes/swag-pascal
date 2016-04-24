(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0063.PAS
  Description: 3 Fast Write Routines
  Author: VARIOUS
  Date: 02-18-94  06:59
*)

{
From: ALEX CHALFIN
Subj: fast write
}

Procedure FastWrite(WX, WY : Integer; Var s); Assembler;

Asm
  PUSH  DS
  MOV   AX,$B800
  MOV   ES,AX
  XOR   DI,DI
  LDS   SI,s
  { CALL WhereY }
  MOV  AX,WY
  DEC  AX
  MOV  DX,160
  IMUL DX
  PUSH AX
  XOR  CX,CX
  {CALL WhereY }
  MOV   AX,WY
  MOV   BX,AX
  POP    AX
  DEC   BX
  SHL   BX,1
  ADD   AX,BX
  MOV   DI,AX
  XOR   AX,AX
  LODSB
  MOV   CX,AX
  MOV   AH,TextAttr
 @Top:
  LODSB
  STOSW
  LOOP @Top
  POP  DS
End;

{
From: BOB SWART
Subj: fast write
}

 procedure FastWrite(Col,Row,Attr: Byte; Str: String); Assembler;
 ASM
       push  DS                    { Save DS                            }
       mov   CH,Row                { CH = Row                           }
       mov   BL,Col                { BL = Column                        }
                                   { Set up ES:DI for LDS               }
       xor   AX,AX                 { AX = 0                             }
       mov   CL,AL                 { CL = 0                             }
       mov   BH,AL                 { BH = 0                             }
       dec   CH                    { convert to DOS 0..24 coords        }
       shr   CX,1                  { CX = Row * 128                     }
       mov   DI,CX                 { Store in DI                        }
       shr   DI,1                  { DI = Row * 64                      }
       shr   DI,1                  { DI = Row * 32                      }
       add   DI,CX                 { DI = (Row * 160)                   }
       dec   BX                    { convert to DOS 0..79 coords        }
       shl   BX,1                  { Account for attribute bytes        }
       add   DI,BX                 { DI = (Row * 160) + (Col * 2)       }
       add   DI,0                  { Add base address                   }
       mov   ES,BaseOfScreen       { ES:DI points to first Row,Col Attr }
       mov   CL,CheckSnow          { Need to wait?                      }
       lds   SI,Str                { DS:SI points to Str[0]             }
       cld                         { Set direction to forward           }
       lodsb                       { AX = Length(St); DS:SI -> Str[1]   }
       xchg  AX,CX                 { CX = Length; AL = CheckSnow        }
       jcxz  @Exit                 { exit if string empty               }
       mov   AH,Attr               { AH = display attribute             }
       rcr   AL,1                  { If CheckSnow is False...           }
       jnc   @NoWait               {  use "NoWait" routine              }
       mov   DX,CGAInfo            { Point DX to CGA status port        }
  @GetNext:
       lodsb                       { Load next character into AL        }
       mov   BX,AX                 { Store video word in BX             }
       cli                         { hold interrupts                    }
  @WaitNoH:
       in    AL,DX                 { get retrace situation              }
       test  AL,8                  { retracing?                         }
       jnz   @Go                   { If so, go                          }
       rcr   AL,1                  { Else, wait for end of              }
       jc    @WaitNoH              {  horizontal retrace                }
  @WaitH:
       in    AL,DX                 { get retrace situation              }
       rcr   AL,1                  { Wait for horizontal                }
       jnc   @WaitH                {  retrace                           }
  @Go:
       mov   AX,BX                 { Move word back to AX...            }
       stosw                       {  and then to screen                }
       sti                         { OK to interrupt now                }
       loop  @GetNext              { Get next character                 }
       jmp   @Exit                 { wind up                            }
  @NoWait:
       lodsb                       { Load next character into AL        }
       stosw                       { Move video word into place         }
       loop  @NoWait               { Get next character                 }
  @Exit:
       pop   DS                    { clean up and go home               }
 end {FastWrite};

{
From: JENS LARSSON
Subj: fast write
}

      Procedure WriteXY(x, y : Word; MsgText : String; ColorAttr : Byte);
Assembler;
       Asm
        dec   x
        dec   y

        mov   ax,y
        mov   cl,5
        shl   ax,cl
        mov   di,ax
        mov   cl,2
        shl   ax,cl
        add   di,ax
        shl   x,1
        add   di,x

        mov   ax,0b800h     { 0b000h for mono }
        mov   es,ax
        xor   ch,ch
        push  ds
        lds   si,MsgText
        lodsb
        mov   cl,al
        mov   ah,ColorAttr
        jcxz  @@End
@@L1:
        lodsb
        stosw
        loop  @@L1
@@End:
        pop   ds
       End;


