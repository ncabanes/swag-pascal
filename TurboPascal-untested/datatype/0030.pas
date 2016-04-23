{
From: ae723@FreeNet.Carleton.CA (Brent Beach)

>>> I am looking for a *fast* routine that can move more than 64k on any
>>> 80x86.
>> A loop using movsb is limited to 64K, but movsw can move 128K at a time.
>> 2 movsb loops can move 128K.  3 can do 196K, see where I'm going?
>
>MOVSW cannot move more than 64k. It is limited to 64k by the segmented
>architecture. So, to move more than 64k, several MOVSW are necessary. My
>problem is to find a routine in which this is done in a clever way.  In fact,
>I know that I would not come up with a clever coding, so I hope that an asm
>guru somewhere has already done it...

You can never move 64KB in a single REP MOVSx instruction.
First, the MOVSx instructions only update the offsets, not the
segment registers, so 64KB is a maximu. Second, you run into
problems when the offset is $FFFF. Third, you can move even
less if the original addresses do not both have offset 0.

To handle all cases, you should try for moving a little less.
The following moves only 63KB. You could move 64K-16 bytes. I
tested this routine with the longtype array upperbound 16 (it
works with any multiple of 16).

By using a fast move for 63KB you gain almost all the speed you
can; it is probably not worth writing the glue code in ASM.

The speed gain over the builtin MOVE procedure is around 38% on
my machine (486/33). A test program ran for 2.58 seconds with
ASM, 4.17 seconds with MOVE.
}

procedure
   movelong(    fromp   : pointer;
                top     : pointer;
                len     : longint);
  {--------
   long mover
   - assumes from and to do not overlap (to not in from) }
type
   longtype        = array[1 .. 63 * 1024] of char;
   longtypeptr     = ^ longtype;
   ptrrec          = record
      ofs, seg     : word; end;
const
   longtypelen     = sizeof(longtype);
begin
   { fix the pointers: offsets between 0 and 15 }
   inc(ptrrec(fromp).seg, ptrrec(fromp).ofs div 16);
   ptrrec(fromp).ofs := ptrrec(fromp).ofs and 15;
   inc(ptrrec(top).seg, ptrrec(top).ofs div 16);
   ptrrec(top).ofs := ptrrec(top).ofs and 15;

   { move pieces }
   while len > sizeof(longtype) do begin
      { faster than: move(fromp^, top^, sizeof(longtype)); }
      asm
         push    ds
         lds     si,fromp
         les     di,top
         mov     cx,(longtypelen / 2)
         cld
         rep     movsw
         pop     ds
      end;
      dec(len, sizeof(longtype));
      inc(ptrrec(fromp).seg, sizeof(longtype) div 16);
      inc(ptrrec(top).seg, sizeof(longtype) div 16);
   end;
   if len <> 0 then
      { faster than: move(fromp^, top^, len); }
      asm
         push    ds
         lds     si,fromp
         les     di,top
         mov     cx,word(len)
         shr     cx, 1
         cld
         jnc     @wordmove
         movsb
      @wordmove:
         rep     movsw
         pop     ds
      end;
end;

