{
> >If anyone wants to see my "improved" move() and fillchar() which I put
> >into a unit which I almost always link in I'd be happy to post it.  (I
> >know that TCA has an even better one though, in case he'd like to post
> >his version as well)
>
> Oh, fine.  Now that the world knows, I suppose I have to post it ;)
>
Thank you for so graciously accepting the terms before anyone wanted me
to post my much more elementary 16-bit version as below:
}
procedure move (var src, dest; count : word); assembler;

asm
  push ds
    mov bx, count
    mov cx, bx
    shr cx, 1

    les di, src
    lds si, dest
    rep movsw

    and bx, 1
    jz @NoMovsB
    movsb
   @NoMovsB: 

  pop ds
end;

> This is a 32bit move() replacement.  Just throw the procedure in at the 
> top of your program, and all your move() calls will work a little faster
> (about 4 times faster for counts above 128 bytes).
> 
> procedure move(var Source,Dest; Count:word); assembler;
> asm
> 	push	ds
> 	les	di,Dest
> 	lds	si,Source
> 	mov	cx,count
> 	mov	bx,cx
> 	shr	cx,2
> 	db 66h;	rep movsw
> 	and	bx,3
> 	mov	cx,bx
> 	rep	movsb
> 	pop	ds
> end;
>
I remember yours looking a little different then that, maybe I'm thinking 
of fillchar (later on)... but not to be picky, since dx isn't used, 
couldn't you use mov dx, ds and mov ds, dx instead of push and pop 
respectively?

> The fillchar() replacement isn't as nice, since with fillchar you can do 
> things like: fillchar(foo,128,'H'); or fillchar(foo,128,TRUE);  
> That makes conversions more difficult.  Still, for those of you who don't 
> do that:
> 
> procedure fillchar(var X; Count:word; Value:byte); assembler;
> asm
> 	les	di,X
> 	mov	cx,count
> 	mov	al,value
> 	mov	ah,al
> 	mov	bx,ax
> 	db 66h;	shl ax,16
> 	mov	ax,bx
> 	mov	bx,cx
> 	shr	cx,2
> 	db 66h; rep stosw
> 	and	bx,3
> 	mov	cx,bx
> 	rep	stosb
> end;
> 
Hmmm... you must have rewritten both of them since I last saw them, as I 
remember something utilizing adc in one of those... oh well, thse look 
more logical anyway :)

> To get around the character or boolean types, do ord('H') or ord(TRUE).
> (It all compiles to the same code).
> 
> This procedure will only increase the speed of fillchar() calls when the 
> Count is above 128 or so.  It will also fillchar to pointers faster than 
> arrays (since pointers are aligned, and arrays are [usually] not).  I 
> just wrote the fillchar() procedure, so it is not as optimized as it
> could be.
> 
How about I put up my fillchar as well, just for comparison's sake (it's, 
once again, only 16-bit, but it seems to work just fine anyway :)

procedure FillChar (var src, dest; count : word; value : byte); assembler;

asm
  mov bx, count
  mov cx, bx
  shr cx, 1

  mov al, value
  mov ah, al

  les di, dest
  rep stosw

  and bx, 1
  jz @NoStosB
  stosb
 @NoStosB:
end;

In other words it's my move() only with ax = 257*value and, well, a fill
instead of a move. :)

