{
 GK> I have a slight problem.  I have written a program that runs in
 GK> graphics mode ($13).  I use the following routine to get what
 GK> colour is at that pixel :-
 GK>     PixelColor := MEM[$A000:X + (Y*320)];
 GK> This works fine, but it is rather slow.  I was wondering if
 GK> anybody knew how to do this faster?
}

   Function PixColor(x, y : Word) : Byte; Assembler;
    Asm
     push  ds
     mov   ax,0a000h
     mov   ds,ax
     mov   ax,y
     shl   ax,6
     mov   si,ax
     shl   ax,2
     add   si,ax
     add   si,x
     lodsb
     pop   ds
    End;
