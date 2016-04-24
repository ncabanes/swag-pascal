(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0182.PAS
  Description: Fast Get/PutImage
  Author: GERALD GUTIERREZ
  Date: 05-26-95  23:25
*)

{
From: gutier@unixg.ubc.ca (Gerald Gutierrez)

: If I am going to be writing a large number of pixels to the screen, would
: it be faster to do a direct memory write to the video buffer at $A000
: (assuming I'm using 320x200x256 mode) or use an assembly language routine
: to do this?
}
Procedure Z_0GetImage( ImgPtr : pointer; XOfs,YOfs,XSize,YSize : Word );
Assembler;
 
  asm
     PUSH DS
     MOV AX,0A000h
     MOV DS,AX
     LES DI,Imgptr
 
     MOV BX,YOfs
     XCHG BH,BL
     MOV DX,BX
     SHR BX,1
     SHR BX,1
     ADD DX,BX
     ADD DX,XOfs
 
     MOV AX,xsize
     STOSW
     MOV BX,AX
     MOV AX,ysize
     STOSW
 
    @JP1:
     MOV SI,DX
     MOV CX,BX
     shr cx,1
     jnc @Jp2
     movsb
    @Jp2:
     repz movsw
     ADD DX,0140h
     DEC AX
     JNZ @JP1
     POP DS
end;

Procedure Z_0PutImage( ImgPtr : pointer; XOfs,YOfs  : Word );
Assembler;

  asm
     PUSH DS
     MOV AX,0A000h
     MOV ES,AX
     LDS SI,ImgPtr
 
     MOV BX,YOfs
     XCHG BH,BL
     MOV CX,BX
     SHR BX,1
     SHR BX,1
     ADD CX,BX
     ADD CX,XOfs
 
     lodsw
     or ax,ax
     jz @Exit
     mov dx,ax
     lodsw
     or ax,ax
     jz @Exit
     mov bx,ax
 
     mov ax,cx
 
    @JP1:
     MOV DI,AX
     MOV CX,DX
     SHR CX,1
     JNC @JP2
     MOVSB
    @JP2:
     REPZ MOVSW
     ADD AX,140h
     DEC BX
     JNZ @JP1
 
    @Exit:
     POP DS
  end;
 
Procedure Z_0PutPixel ( X,Y : Word; Color: Byte );
Assembler;
  asm
     mov ax,0a000h
     mov es,ax
     mov di,x
     mov ax,y
     xchg ah,al          { multiply Y by 320 }
     add di,ax
     shr ax,1
     shr ax,1
     add di,ax
     mov al,color
     stosb
  end;

Function  Z_0GetPixel ( X,Y : Word ): Byte;
Assembler;

  asm
    push ds
    mov ax,0a000h
    mov ds,ax
    mov si,x
    mov ax,y
    xchg ah,al          { multiply Y by 320 }
    add si,ax
    shr ax,1
    shr ax,1
    add si,ax
    lodsb
    pop ds
  end;

