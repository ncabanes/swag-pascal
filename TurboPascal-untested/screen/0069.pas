{
Ok, without even going back to my compiler I can improve yer design.  i
forgot that on 386 and up that a mov [addr],al is faster than a single
stosb etc, so that was likely my largest time deficit.  Yours is the
Imul.  I'll add the color into mine, but I thought that passing up one
less param MIGHT increase the speed slightly.
}
procedure Putstr(x,y:integer;s:string;attr:byte);assembler;
asm
  push ds {that's all you really need}

  mov bx,y
  shl bx,1
  mov ax,bx
  shl bx,2
  add ax,bx
  add ax,$b800
  mov es,ax     { es:=$B800 + (Yx$80 + Yx$20) shr 4 or $B800+Y*$A }
  mov di,x
  shl di,1      { di:=x shl 1 }

  lds si,s
  mov cl,byte ptr [si]
  inc si
  mov ah,attr
@1:
  mov al,byte ptr [si]
  mov word ptr es:[di],ax
  inc si
  add di,2
  dec cl
  jnz @1

  pop ds
end;
(*
  |    Mov AX,Col                  { Load Column to write to.              }
  |    Shl AX,1                    { Column = Column * 2.                  }
  |    Mov BX,AX                   { Copy AX to BX.                        }
  |    Mov AX,Row                  { Load Row to write to.                 }
  |    Mov CX,160                  { Row = Row * 160.                      }
  |    IMul CX
  |    Add AX,BX                   { Offset = (Col * 2) + (Row * 160).     }
  |    Mov DI,AX


ugh, comments.  You freaking PD coder, you.  You probably like windows
too huh?  This is the only section that I have improved on yer design.
I only discovered the optimize cause I was writing a faster putpixel.


Questions/comments:

    Xor CH,CH

You don't need this line at all.  that's 2 opcode tiks for me.
(ahhhh, obsessed)


Is "mov cl, byte ptr ds:[si]" any slower than "mov cl,[si]" ?

I know that "add di,2" is faster than "inc di;inc di" and
"dec cl" is better than "dec cx" and
"xor cx,cx" is faster than "mov cx,0"

GE|BEGIN
  |  Start := ReadTimer;
  |   FOR X := -MaxInt TO MaxInt DO
  |    FastWr(40,5,2,'Greg Estabrooks!');
                       ^^^^^^^^^^^^^^,
see that's the problem right there.  It should read: 'Jamie - coder god'

The only differences between our code:
  I used lodsb/stosw out of lasyness.
  You used xor ch,ch
  You used imul where I did shifts ( faster, but not the slowest part of
                                     the code, so not a big deal )
*)