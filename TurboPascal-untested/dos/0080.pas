(*
I asked Quarterdeck's tech support about the reboot sequence I use, which
flushes buffers before booting, and they recommended also setting the stack
to non-mappable memory when booting from a DESQview window (the lines below
marked by {*}
*)

program boot;
procedure ReBoot; far; assembler;
asm
  mov   ah, 0Dh
  int   21h
  xor   cx, cx
@1:
  push  cx
  int   28h
  pop   cx
  loop  @1
  mov   ds, cx
  mov   word ptr [472h], 1234h
  mov   ss, cx          {*}
  mov   sp, 700h        {*}
  dec   cx
  push  cx
  push  ds
end;
begin
  ReBoot;
end.
