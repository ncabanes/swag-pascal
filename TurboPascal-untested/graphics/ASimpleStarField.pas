(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0004.PAS
  Description: A simple Star Field
  Author: SWAG SUPPORT TEAM
  Date: 07-16-93  06:47
*)


program stars;

const
  maxstars = 200;

var star  : array[0..maxstars] of word;
    speed : array[0..maxstars] of byte;
    i     : word;

procedure create;
begin
  for i := 0 to maxstars do
    begin
    star[i] := random(320) + random(200) * 320;
    speed[i] := random(3) + 1;
    if mem[$a000:star[i]] = 0 then
      mem[$a000:star[i]] := 100;
  end;
end;

Procedure moveit; assembler;
asm
     xor   bp,bp
     mov   ax,0a000h
     mov   es,ax
     lea   bx,star
     lea   si,speed
     mov   cx,320

@l1: mov   di,[bx]
     mov   al,es:[di]
     cmp   al,100
     jne   @j1
     xor   al,al
     stosb
@j1: mov   al,[si]
     xor   ah,ah
     add   [bx],ax
     mov   ax,bx
     xor   dx,dx
     div   cx
     mul   cx
     mov   dx,bx
     sub   dx,ax
     cmp   dx,319
     jle   @j3
     sub   [bx],cx
@j3: mov   di,[bx]
     mov   al,es:[di]
     or    al,al
     jnz   @j2
     mov   al,100
     stosb
@j2: add   bx,2
     inc   si
     inc   bp
     cmp   bp,maxstars
     jle   @l1
end;

begin
  asm
    mov   ax,13h
    int   10h
    call  create
@l1:
    mov   dx,3dah
@r1:
    in    al,dx
    test  al,8
    je    @r1
    call moveit
    in   al,60h
    cmp  al,1
    jne  @l1;
  end;
end.


