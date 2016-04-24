(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0031.PAS
  Description: CPU Independent Delay
  Author: ANDREW EIGUS
  Date: 05-26-95  23:24
*)

{
  From: Andrew Eigus                                 Read: Yes    Replied: No
}

Procedure Pause(HS : longint); assembler;
Asm
        mov     es,Seg0040
        mov     si,006Ch
        mov     dx,word ptr es:[si+2]
        mov     ax,word ptr es:[si]
        add     ax,word ptr [HS]
        adc     dx,word ptr [HS+2]
@@1:
        mov     bx,word ptr es:[si+2]
        cmp     word ptr es:[si+2],dx
        jl      @@1
        mov     cx,word ptr es:[si]
        cmp     word ptr es:[si],ax
        jl      @@1
End; { Pause }
{
The above routine does not depend on a CPU speed.
}

