(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0183.PAS
  Description: Another Quick PutImage
  Author: DAVID CORDER
  Date: 05-26-95  23:25
*)

{ ╔══════════════════════════════════════════════════════════════════════╗
  ║ ░░Proc░░░░░░░░░░░░░░░░ PutPic ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ║
  ╚══════════════════════════════════════════════════════════════════════╝}
Procedure PutPic(X: Word;Y:Byte;VAR sprt;W,H:Byte;Where:Word); ASSEMBLER;
  {W=Width of sprite, H=Height Sprt=an array of pixels}
  { This puts an sprite, EXCEPT it's color 0 (black) pixels, onto the screen
    "where"(VAddr1/VGA etc.), at position X,Y }
label
  _Redraw, _DrawLoop, _Exit, _LineLoop, _NextLine, _Ignore;

asm
    push  ds     { Save DS for later }
    and   bl, 0
    mov   es, where   {Move segment address of Where into ES:DI's segment}
    lds   si, Sprt    { loads the address of Sprt into DS:SI }
    mov   di, x       { Move x location into DI }

    {Work out (y*320)+x}
    mov   bh, y       { bx = y*256 }
    mov   ax, bx      { make another copy of y in ax}
    shr   ax, 2       { y2 = y2 * 64}
    add   bx, ax      { Work out y location : y = y1+y2 (y=y*320) }
    add   di, bx      { finalise location  (Y*320)+X }

    mov   ah, H       { ah = Height of sprite }
    cld               {Clear direction flag (DI inc's)}
    and   ch, 0
    mov   al, W       {Move in width }
    {Register usage:
           AX = HHWW
           BX = Comparison of byte
           CX = Across counter
           DX = 'Pushed' DI}
_DrawLoop:
    mov   dx,di        { Store offset for later }
    mov   cl,al       { move width into CX }
_LineLoop:
    mov   bl,byte ptr [si]
    or    bl,bl       { checks if zero }
    jz    _Ignore     {if Color=0 then ignore it}
    movsb
    loop   _LineLoop   {Repeat CX times (Repeat for the width of sprite)}
    jmp    _NextLine   {Then go on to next line}

_Ignore:
    inc    si          {DS:SI = Sprite Array (inc SI = Next pixel)}
    inc    di          {Inc Mem locs ES:DI = incr. target location}
    loop  _LineLoop    {Continues reading the line}

_NextLine:
    mov   di,dx        {Restore x/y Vid.mem loc.}
    dec   ah           {Decrease height (Move down a line)}
    jz    _Exit        {If Height=0(Reached end of sprite) then exit }
    add   di,140h      {else : di = Move to next line in Vid.Mem }
    jmp   _DrawLoop    {Jump back to the draw loop}

_Exit:
    pop   ds     { Restore DS }
end;


