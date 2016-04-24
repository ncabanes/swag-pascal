(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0002.PAS
  Description: MOUSPIC2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{
>Hey Programmers,
>        I'm trying to change the way my mouse cursor looks in one of my
>Programs from the standard block to an arrow.  I looked up the inFormation
>in my interrupt list and found that I need to use Interrupt 33h (Big
>surprise) With AX = 0009h.  I'm ok up to this point, but the inFormation
>lost me when is says that ES:DX->bitmap With 16 Words screen mask and 16
>Words cursor mask.  Now I know what it means and have already defined the
>code For my curse, but how do I assign ES:DX to its value? (Source example
>below).  Any help would be great and please E-MAIL it to me.  Thanks
}

Const
   ArrowCursor: Array [0..31] of Word = (
            $3fff,$1fff,$fff,$7ff,$3ff,$1ff,$ff,$7f,
           $3f,$1f,$f,$7,$1847,$387f,$fc3f,$fe7f,
           $0,$4000,$6000,$7000,$7800,$7c00,$7e00,$7f00,
           $7f80,$7fc0,$7fe0,$6730,$4300,$300,$180,$0);
   HotSpotX : Word = 1;
   HotSpotY : Word = 0;


Procedure ArrowMouse;
Var regs : Registers;
begin
   Regs.AX := $000A;
   Regs.BX := HotSpotX;
   Regs.CX := HotSpotY;

   { ES:DX -> bitmap  16 Words screen mask  16 Words cusor mask }
   Regs.ES := Seg(ArrowCursor); { Answer :) }
   Regs.DX := ofs(ArrorCursor); { Answer :) }

   intr($33,Regs);
end;


