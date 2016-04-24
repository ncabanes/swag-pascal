(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0173.PAS
  Description: Set Secondary Page Position
  Author: BAS VAN GAALEN
  Date: 11-26-94  04:59
*)

{
> What I need to know is how I can use that information  as well
> as which registers to use (ax,dx etc) to  write or read from a
> specific field of a register without affecting other fields.

Well, get a VGADOC, number three is the latest: VGADOC3.???. Then you know
which ports can do what..Secondly: get my graphics package (for instance),
called GFXFX.???, in which you can see how to play with these ports
}

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
{
These procedure sets the position of the secondary page. Try it out. As far
as I know it should work in every mode, not only mode-x, though it was
designed
}
