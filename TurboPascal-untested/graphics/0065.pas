
{
ANDREW FORT
> That's fast, but that's just one bitmap. I really need to sit down and
> optimize my texture mapper...

> You have to use 386 instructions cuz 32-bit division is way too slow
> otherwise. I'd have to see the code to tell if it's efficient or not. It's
> a simple algorithm, just figuring out where in the bitmap to start and
> what the step value is for each scan line is the hard part. Then just do
> 320 pixels real quick... don't worry, cuz with 256x256 bitmaps, everything
> just works itself out real nice.

yes i realize it works out real nice with 256x256 bitmaps, because you can
shift/carry or whatever to get the particular point in the bitmap you want
easily.

yes it uses 32 bit instructions, but since it's so short, it's not a problem
coding it in BASM.. and here it is:

** this code was written by The Faker of Aardvark **
}

PROCEDURE PutTexture(IncX, IncY : Integer; P : Pointer);
VAR
  Y, PosX,
  PosY,
  PX, PY : Integer;
BEGIN
  PosX := -(ScreenX SHR 1) * IncX;   { ScreenX,-Y are size of screen    }
  PosY := -(ScreenY SHR 1) * IncY;   { PosX,y set so rotation is around }
  FOR Y := 0 TO ScreenY-1 DO       { the middle (of 'p')              }
  BEGIN
    PX := PosX;   { PosX,-Y is updated every line, PX,-y derived   }
    PY := PosY;
    ASM
      push ds
      mov  ax, 0a000h
      mov  es, ax
      mov  ax, y
      xchg al, ah
      mov  di, ax
      shr  di, 2
      add  di, ax
      lds  si, p   { in P there should be a 256x256 bitmap }
      mov  cx, screenx shr 1
      cld
      mov  ax, incx
      shl  eax, 16
      mov  ax, incy
      mov  esi, eax
      mov  dx, px
      shl  edx, 16
      mov  dx, py
     @1:
      add  edx, esi
      mov  ebx, edx
      shr  ebx, 16
      mov  bl, dh
      mov  al, [bx]
      add  edx, esi
      mov  ebx, edx
      shr  ebx, 16
      mov  bl, dh
      mov  ah, [bx]
      stosw
      dec  cx
      jnz  @1
      pop  ds
    END;
    Inc(PosX, IncY);
    Inc(PosY, -IncX);
  END;
END;

{
as you can see, very methodical coding, but it's quite fast, and does the
job....

>> It was coded before 2nd reality was released, but didn't get released
>> till after because of distribution problems..

> Second Reality was ok, but they coulda done better. I did like the
> bubbling landscape demo (voxel stuff)

try, although i was disappointed that they didn't really do much new (those
blue bolls were nice though, although they flickered quite alot.. but hey! i'm
hardly paying for the demo, am i!)

but yeah, the voxel stuff was nice.. after reciving email from Lord Logics (of
Avalanche), he says that he's been working on some voxel stuff, although he
didn't get it finished because of getting a job, although he intends to finish
it and release it in a demo for avalanche.. so that'd be nice to see..

tell me if the code is efficent or not! :-)
}

(*
SEAN PALMER

> yes i realize it works out real nice with 256x256 bitmaps, because you
> can shift/carry or whatever to get the particular point in the
> bitmap you want easily.

No, you don't have to do diddly squat to extract it. Just move the byte out.
Since one's in the hi byte of a 32-bit register though, it's harder to extract.

> yes it uses 32 bit instructions, but since it's so short, it's not a
> problem coding it in BASM.. and here it is:

Of course you know that BP 7.0 won't do 386 instructions. So this wouldn't
compile as is. Needs a lot of DB $66's, etc.

> ** this code was written by The Faker of Aardvark **

Hi Faker! Sorry to botch your code below. 8)

> PROCEDURE PutTexture(IncX,IncY:Integer; P:Pointer);
> VAR
> Y,PosX,PosY,PX,PY:Integer;
> BEGIN
> PosX:=-(ScreenX SHR 1)*IncX;   { ScreenX,-Y are size of screen}
> PosY:=-(ScreenY SHR 1)*IncY;   { PosX,y set so rotation is around}
> FOR Y:=0 TO ScreenY-1 DO       { the middle (of 'p')}
> BEGIN
> PX:=PosX;   { PosX,-Y is updated every line, PX,-y derived}
> PY:=PosY;
> ASM
> push ds
> mov ax,0a000h
> mov es,ax
> mov ax,y
     shl ax,8    {this is same speed, but cleaner}
> mov di,ax      {lessee... ends up y*320. Faster than MUL. But should}
> shr di,2       {be incrementally calculated instead.}
> add di,ax
> lds si,p       { in P there should be a 256x256 bitmap }
> mov cx,screenx shr 1
> cld
                        {cleaned out the intermediate use of eax}
     mov si,incx
     shl esi,16
     mov si,incy
> mov dx,px
> shl edx,16
> mov dx,py
> @1: add edx,esi
     shld ebx,edx,16    {do move and shift all at once. Save 2 cycles}
> mov bl,dh
> mov al,[bx]
> add edx,esi
     shld ebx,edx,16    {ditto. I like this unrolled loop! 8) }
> mov bl,dh
> mov ah,[bx]
> stosw              {word access. Sweet.}
> dec cx             {better than LOOP on a 386+}
> jnz @1
> pop ds
> END;
> Inc(PosX,IncY);
     Dec(PosY,IncX);    {avoid neg operation}
> END;
> END;

> as you can see, very methodical coding, but it's quite fast, and does
> the job....

Yep. I haven't coded it up where it'll compile and run it yet, but Should Be
Pretty Darn Quick. Seems like it's gonna have a problem with the carry from dx
to the hi word of edx (your position will be off, barely, every time it
wraps.... shouldn't matter much)

> but yeah, the voxel stuff was nice.. after reciving email from Lord
> Logics (of Avalanche), he says that he's been working on some
> voxel stuff, although he didn't get it finished because of
> getting a job, although he intends to finish it and release it
> in a demo for avalanche.. so that'd be nice to see..

I'm gonna have to code something like that up for a BattleTech type game. Best
idea I've seen so far for terrain... If you see any code to get me started,
please route it my way.

> tell me if the code is efficent or not! :-)

Only one optimization I can spot right now (aside from coding the outer loop in
ASM as well...) Is that he has to shift the 32-bit registers around to get at
the upper word. (the 386 needs more data registers!!!!!! ARE YOU LISTENING
INTEL!!!) So using the SHLD instruction like I re-coded above should speed it
up some. Avoid the intermediate register move.

I've commented above. You could put alot of the setup stuff outside the loop if
you wrote it all in BASM. Wouldn't have to push/pop for each scan line, etc.
But that's a minor speedup.

In the future, try to gain access to the FIDO 80XXX echo. It's a much better
place to talk about (mostly) assembly stuff.

*)