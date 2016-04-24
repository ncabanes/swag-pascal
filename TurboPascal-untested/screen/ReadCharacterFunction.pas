(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0065.PAS
  Description: Read Character Function
  Author: JENS LARSSON
  Date: 05-25-94  08:20
*)


(*
 IL> Use the memw array to read one word. The low byte is the attribute
 IL> (color) and the other is the character.
 IL>
 IL> var ch:word; x,y:byte;
 IL> begin
 IL>  {get x,y then read}
 IL>  ch:=MEMW[$b800:y*25+x-1];
 IL> end.
 IL>
 IL> The numbers might be off, but that's the idea.

Ouch. You screwed up there... This should do it:

(and I DON'T want some optimizations as 'shl ax,5' is faster than 'mov cl,5;
shl ax,cl'. It is coded in this way to ensure downward compatiblity. Replace
TextVidMem with either 0b000h or 0b800h, depending on your screen.)
*)

      Function ReadCharThingy(x, y : Word) : Word; Assembler;
       Asm
        dec   x
        dec   y

        mov   ax,y
        mov   cl,5
        shl   ax,cl
        mov   si,ax
        mov   cl,2
        shl   ax,cl
        add   si,ax
        shl   x,1
        add   si,x

        mov   ax,TextVideoMem
        push  ds
        mov   ds,ax
        lodsw
        pop   ds
       End;


