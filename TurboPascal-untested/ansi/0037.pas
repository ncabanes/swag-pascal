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