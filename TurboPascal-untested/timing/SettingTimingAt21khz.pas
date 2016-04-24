(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0013.PAS
  Description: Setting Timing at 21Khz
  Author: CEES BINKHORST
  Date: 11-02-93  06:29
*)

{
CEES BINKHORST

>  Has anyone ever succeeded in setting the timer rate at a higher frequency
> than 21KHz in protected mode? I've tried every possible thing, and it
Could you give details on that 21KHz? Sounds rather a high rate.

> don't know whether I have enough IOPL as to make CLI and STI to work, but
Try the following:
}

{dr. dobb's 80286/386 #185}
Function SensitiveOK : Boolean; Assembler; {sensitive instructions are: }
                                    {IN    read a port           }
                                    {OUT   Write to a port       }
                                    {INS   read a String from a port}
                                    {OUTS  Write a String to a port}
                                    {CLI   disable interrupts    }
                                    {STI   enable interrupts     }
Asm
  push  ax
  push  bx
  pushf                             {put flags 'I/O privilege level' (IOPL)}
  pop   ax                          { into ax }
  and   ax, 3000h                   {00110000 00000000 - mask all but iopl}
                                    {ax = 00??0000 00000000 now}
  shr   ax, 12                      {ax -> 00000000 000000??}
                                    {compile With 286 instructions enabled!!}
  mov   iopl, al
  mov   bx, cs                      {current privilege level (cpl) is in cs}
  and   bx, 3                       {00000000 00000011 - mask all but cpl}
  mov   cpl, bl
  cmp   bx, ax                      {compare cpl and iopl}
  ja    @not_sensitive              {jump  if cpl > iopl}
  clc
  mov   @result, True               {sensitive instructions ok}
  jmp   @exit
 @not_sensitive:
  stc
  mov   @result, False              {sensitive instructions not ok}
 @exit:
  pop   bx
  pop   ax
end;

Function PrivilegeOK: Boolean; Assembler; {privileged instructions are:}
                                    {HLT   halt the processor    }
                                    {LGDT  load the GDT register }
                                    {LIDT  load the interrupt-descriptor-}
                                    {      table register        }
                                    {LLDT  load the LDT register  }
                                    {CLTS  clear the task-switched flag}
                                    {LMSW  load the MSW          }
                                    {LTR   load the task register}
Asm
  push  ax
  mov   ax, cs                    {cpl resides in cs}
  and   ax, 3                     {00000000 00000011 - mask all but cpl}
                                  {ax = 00000000 000000?? now}
  jnz   @lbl1
  mov   @result, True             {privileged}
  jmp   @exit
 @lbl1:
  mov   @result, False            {not privileged}
 @exit:
  pop   ax
end;

