(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0080.PAS
  Description: Quarterdeck Approved Reboot Method
  Author: RICH VERAA
  Date: 11-26-94  05:08
*)

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
