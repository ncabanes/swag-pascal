(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0211.PAS
  Description: Mode-X one row pixel move
  Author: JONAS MAEBE
  Date: 05-31-96  09:16
*)

{
A couple of months ago, I posted an unfinished procedure to move a row of
pixels one pixel to the left and asked for help. Didn't get any response
(pretty normal, since it's really a lot of work to figure out someone else's
assembler code :), but in the meantime I've been able to finish it. Don't know
whether there's still anybody out there who can use it (the original
requester, Fabian Thylman(n?), seems to have left Fidonet), but here it is
anyway...
}

PROCEDURE MoveRow1PixelLeft(x,y, length: WORD; VAR tempbuf);
{For Mode-X, 320*200*4. Moves length pixels at (x,y) one position to the
left.}{Tempbuf should be an array of byte/char, with size = length div 4.
}{Public domain by Jonas Maebe (2:292/624.7). SWAG, you can include this if
}{you guys feel like it :)
}ASSEMBLER;
VAR sisav, disav: word;
    planecount: byte;
ASM
   cld
   push ds
   mov ax, $a000
   mov di, x
   mov ds, ax           {ds = videosegment}
   mov bx, di           {bx = di = x}
   mov ax, y
   shr di, 2
   shl ax, 5
   add di, ax
   shl ax, 2
   add di, ax           {di = y * 160 + x div 4}
   mov si, di           {source = destination = (x,y)}
   and bl, 11b
   mov bh, bl           {bh holds value for read plane}
   dec bl               {write plane points to previous plane}
   cmp bl, $ff          {bl = -1?}
   jne @bl_ok
   mov bl, 3            {set bl so it points to plane four (write plane)}
   dec di               {and di to point to the previous memlocation}
  @bl_ok:
   mov cl, bl
   mov bl, 1
   shl bl, cl           {bl holds value to set the write plane}
   mov cx, length       {cx holds the length of the row that has to be}
                        {moved}
   mov sisav, si
   mov disav, di        {save si and di for later}
   mov planecount, 3    {and initialize the plane counter}
   mov dx, grac
   mov ah, bl           {set read plane to value of writeplane, first save}
   dec ah               {all pixels that'll be overwritten by the first move}
   jns @ok
   xor ah, ah           {the next few adjustments are still a mystery to me}
  @ok:                  {and I've have found them out by trial and error.}
   cmp ah, 3            {If anyone can explain *WHY* the read plane has to}
   jne @ok2             {set this way, please do tell me...}
   dec ah
  @ok2:
   mov al, 4
   out dx, ax
   mov si, di
   sub cx, 3
   inc si
   les di, tempbuf
   shr cx, 3
   jnc @even
   movsb
  @even:                {all pixels that are to be overwritten are saved in}
   rep movsw            {tempbuf}
   mov si, sisav
   mov di, disav
   mov ax, $a000
   mov cx, length
   mov es, ax
  @newplane:
   mov dx, grac
   mov ah, bh
   mov al, 4
   out dx, ax           {select read plane}
  @writeplane:
   mov dx, sequ
   mov ah, bl
   mov al, 2
   out dx, ax           {select write plane}
   shr cx, 3            {shr 2 because there are 4 planes + shr 1 because}
   jnc @counter_even    {we're doing movsw's, only the last shifted-out}
   movsb                {bit is kept in the carry flag}
  @counter_even:
   rep movsw            {move pixels}
   cmp planecount, 0
   je @end
   mov cx, length       {reload the counter}
   mov si, sisav        {restore si}
   dec cx               {decrease the length by one; because we move on to}
                        {the next pixel, the length of the row becomes one}
                        {less}
   mov di, disav        {restore di}
   mov length, cx       {and save the length}
   inc bh               {increase the read plane}
   cmp bh, 4            {if it's four, wrap around since there are only 4}
                        {planes to read from (and with 4 it would point to 5)}
   jne @noreset_bh
   mov bh, 0            {reset bh}
   inc si               {next pixel because we reset bh}
   mov sisav, si        {plane zero}
  @noreset_bh:
   cmp bl, 1000b        {test if it points to the 4th plane}
   je @reset_bl
   add bl, bl           {increase write plane (same as shl bl, 1)}
   dec planecount
   jnz @newplane        {planecounter 0 -> finish him! :)}
   lds si, tempbuf
   jmp @writeplane        {it doesn't -> don't reset}
  @reset_bl:
   mov bl, 1            {select plane 0}
   inc di               {and point to the next pixel, same reason as with}
   mov disav, di        {read plane}
   dec planecount
   jnz @newplane        {planecounter 0 -> finish him! :)}
   lds si, tempbuf
   jmp @writeplane
  @end:
   mov ah, 1
   mov cl, bh
   shl ah, cl
   mov al, 2            {let the write plane point to the last pixel}
   out dx, ax           {we've read (write plane = read plane)}
   mov si, sisav
   mov cx, length
   shr cx, 2
   jnc @even2
   inc si
  @even2:
   add si, cx
   xor bl, bl
   mov es:[si], bl      {and zero the last pixel (erase it)}
   pop ds               {restore data segment}
END;

