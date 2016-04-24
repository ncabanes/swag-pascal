(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0008.PAS
  Description: Write String in ASM
  Author: BRIAN PAPE
  Date: 08-27-93  22:12
*)

{
BRIAN PAPE

Ok, I was writing a little program that I was trying to make as small as
possible, so I wrote this little WriteString function.  Since I'm not an
assembly language mogul by any stretch of the imagination, could one of
you assembly wizards out there tell me if this is Ok.  I mean, it works
fine (and saves almost 1k over linking in the writeln code), but I want
to make sure that I'm not trashing a register or something that needs to
be preserved.  Thanks...  BTW, anybody, go ahead and use it if it
doesn't crash!
}

procedure WriteString(s : string); assembler;
asm
  push ds
  mov  ah, 40h    { DOS fcn call 40h write string to file handle }

  mov  dx, seg s
  mov  ds, dx
  mov  bx, offset s

  mov  dx, bx     { now put the offset into dx for the fcn call }
  inc  dx         { plus 1, to avoid the length byte }
  mov  cl, [bx]   { cl is length to write }
  xor  ch, ch

  mov  bx, 1      { file handle to write to }
  int  21h
  pop  ds
end;


