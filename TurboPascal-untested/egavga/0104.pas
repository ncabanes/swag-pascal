{
 SG> ok.. how do you switch from 50 line mode to 25 line mode in assembly,
 SG> and vice versa? I've tried many ways, which crash every now and then...
}
To 25 lines:

Uses crt;
begin
textmode(co80); {co80=3}
end.

To 50 lines:
procedure vga50;
assembler;
asm
 mov ax,1202h
 mov bl,30h
 int 10h
 mov ax,3
 int 10h
 mov ax,1112h
 mov bl,0
 int 10h
end;
begin
 vga50
end.

