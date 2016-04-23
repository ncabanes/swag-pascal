{
> I've got all kinds of routines by now, from fire to plasma, etc.
> But what I need is a screen in graphics mode 13h (or mode-x),
> where text scrolls from the bottom of the screen to the top of
> the screen.

The address is a000:0000 -  now all you should do is:
}
x : array[1..320] of byte;
asm
mov ax,$a000
mov es,ax
mov ds,ax
cld
mov cx,160
xor si,si
mov di,offset x[1]
rep movsw
mov si,320
xor di,di
mov cx,160*199
rep movsw
mov si,offset x[1]
mov di,320*199
mov cx,160
rep movsw
end;

{
That should do it - A simple move operation.
Note: This will only scroll one line. I think it's fast enough - although I
tested it on a 386-dx40. The drawback of it is that you get this nasty line on
the screen.
}