
{All of these procedures work in any screen mode, so do not require
 Pascal's annoying BGI and INITGRAPH stuff, which I've never used,
 anyway.

LOCATE -- Move text cursor to desired point on screen (x,y).
PRINT  -- Print SR (string) in color COL. Will work from the
           current cursor location. May be slow, but it works
           well. Haven't really optimized it.
SETSCREENMODE -- Returns true or false whether it was successful in
                  setting the screen mode. Use $13 for VGA, or any
                  of the standard INT 10h numbers.
PSET -- Put a pixel on X,Y in color COL in any screen mode. Slower
         than direct memory writes, but a procedure using direct
         memory writing for any screen mode would be enormous.
POINT -- Returns pixel value for (x,y). Such as if there is a color
          15 pixel at 100,100 and you do X:=POINT(100,100), it will
          return 15.

Any questions? E-mail me:

Sean O'Malley
frog@star2.opsys.com

Author of the Shareware Base64 programs available on FTP sites
worldwide. (Especially SimTel.)
}

Function Point(x,y:word):byte; assembler;
asm
 mov ah,$d
 xor bh,bh
 mov cx,[x]
 mov dx,[y]
 int $10
end;
procedure pset(x,y:word;col:byte); assembler;
asm
 mov ah,$c
 xor bh,bh
 mov al,[col]
 mov cx,[x]
 mov dx,[y]
 int $10
end;
Procedure print(sr:string;col:byte); assembler;
asm
 les di,sr
 mov cl,es:[di]
 xor ch,ch
 jcxz @ender
 inc di
 mov ah,$e
 mov bl,[col]
 xor bh,bh
@loop1:
 mov al,es:[di]
 inc di
 int $10
 loop @loop1
 mov al,13
 int $10
 mov al,10
 int $10
@ender:
end;
function setscreenmode(mode:byte):boolean; assembler;
asm
 mov al,[mode]
 xor ah,ah
 int $10
 mov ah,$f
 int $10
 cmp al,[mode]
 je @itworked
 xor al,al
 jmp @end
@itworked:
 mov al,1
@end:
end;
Procedure Locate(x,y:byte); assembler;
asm
 xor bh,bh
 mov ah,2
 mov dh,[y]
 mov dl,[x]
 int $10
end;
