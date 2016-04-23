{
>> add a WAIT procedure in your program to wait for the
>> vertical retrace then your image will slide smoothly

> I thought this was only a problem with CGA cards .. is that still
> true?

>> It's no longer a PROBLEM per se. It doesn't cause snow anymore, but you
>> still get a jitter/flicker problem if you move an image
>> without waiting for retrace. Problem is that the memory
>> gets updated while the retrace is halfway down the

> Where can I get source for such a wait procedure? Do you or JB? have
> one?
}
var
 addr6845:word absolute $40:$63; {bios's crtc ptr}
  {CRT Controller=+0}
  {CRT Status=+6}
  {Mode Control=+4}

procedure syncRetrace;assembler;asm
 mov ax,seg addr6845; mov es,ax;
 mov dx,es:[addr6845]; add dx,6; {find crt status reg}
 {@LOOP1: in al,dx; test al,8; jnz @LOOP1;}
 @LOOP2: in al,dx; test al,8; jz @LOOP2;
 end;
{
some people like to make sure the current retrace (if any) has ended before
waiting for one to begin. I find it unnecessary in practice. But if you wanna
do that, uncomment LOOP1.
}
