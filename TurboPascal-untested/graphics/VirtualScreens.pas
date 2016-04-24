(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0085.PAS
  Description: Virtual Screens
  Author: RYAN PETRIE
  Date: 05-25-94  08:02
*)

{

WS>Hello! I've thought about writing my own 3D games or just any high graphics
WS>program and am in the process of writing a unit that handles virtual screens
WS>have 6 virtual screens (0..5, where 0 will be MOVEd to $A000:0000) that are
WS>type pointer with 64000 bytes each. They are designed for Mode 13h, of cours
WS>I have a procedure called CopyScreen. Basically,

Just FYI:  You might want to consider using Mode-X.  Matt Pritchard has
written a great freeware library for such (MODEX10?.ZIP) with a Pascal
example.  With Mode-X, you can use the VGA's memory instead of precious
conventional (if in real mode) memory, and the page switching is a lot
faster than copying 64k from memory.
}

procedure copyscreen(source,dest : pointer; mask : byte); assembler;

asm
  push  ds
  lds   si,source
  les   di,dest
  mov   cx,64000
  cld
@loop:
  lodsb
  cmp   mask,al
  je    @nodraw
  mov   es:[di],al
@nodraw:
  inc   di
  loop  @loop
  pop   ds
end;

You need to call it like this (note the '@'):

  copyscreen(@virtualscreen[first],@virtualscreen[second],mask);

