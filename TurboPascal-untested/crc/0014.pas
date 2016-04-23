(* ===========================================================================
Date: 09-29-93 (11:16)
From: HELGE HELGESEN
Subj: Checksums?

       How does one compute simple checksums? For example for a byte
       sequence $8A $05 $7E $1C, what would the checksum be? Where
       could I get some info on this?

Here's one that simply adds each byte together and sends back the
result:
===========================================================================*)

function MakeCheckSum(p: pointer; length: word): byte; assembler;
asm
  cld
  push ds
  xor  ah, ah
  mov  cx, length
  jcxz @x
  lds  si, p
@1:
  lodsb
  add  ah, al
  loop @1
@x:
  pop  ds
  mov  al, ah
end;

So you call this like this:

x:=MakeCheckSum(@myvar, length_of_var);

