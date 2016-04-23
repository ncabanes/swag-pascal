procedure ToggleBlink(OnOff:boolean);
assembler;
asm
  mov ax,1003h
  mov bl,OnOff
  int 10h
end;
