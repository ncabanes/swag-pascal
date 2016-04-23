{ Someone asked for the routines for hardware scrolling. So here it is: }

procedure setaddress(ad:word); assembler;
asm
  mov dx,3d4h
  mov al,0ch
  mov ah,[byte(ad)+1]
  out dx,ax
  mov al,0dh
  mov ah,[byte(ad)]
  out dx,ax
end;

procedure setlinecomp(ad:word); assembler;
asm
  mov dx,3d4h
  mov al,18h
  mov ah,[byte(ad)]
  out dx,ax
  mov al,7
  out dx,al
  inc dx
  in al,dx
  dec dx
  mov ah,[byte(ad)+1]
  and ah,00000001b
  shl ah,4
  and al,11101111b
  or al,ah
  mov ah,al
  mov al,7
  out dx,ax
  mov al,9
  out dx,al
  inc dx
  in al,dx
  dec dx
  mov ah,[byte(ad)+1]
  and ah,00000010b
  shl ah,5
  and al,10111111b
  or al,ah
  mov ah,al
  mov al,9
  out dx,ax
end;

procedure retrace; assembler;
asm
  mov dx,3dah
 @vert1:
  in al,dx
  test al,8
  jz @vert1
 @vert2:
  in al,dx
  test al,8
  jnz @vert2
end;

{
There you go. Should also work in non-modex modes. Don't forget to include a
retrace.
}
