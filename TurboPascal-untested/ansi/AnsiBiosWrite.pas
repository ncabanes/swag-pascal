(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0037.PAS
  Description: Ansi BIOS Write
  Author: ROBERT LONG
  Date: 02-28-95  09:47
*)

{
You can use this routine with or without the CRT unit. All output will
be routed through the BIOS. You must have the ANSI.SYS driver loaded in
your config.sys file.

}
procedure awrite(c : byte);

begin
 asm
mov ah,2;
mov dl,c;
int $21;
 end;
end;

