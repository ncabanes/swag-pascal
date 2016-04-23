{
│ In the SWAG archive, there is one good unit to do all that. But ther
│ is one MAJOR bug: you have to know the device name (e.g. MSCD001, sa
│ to access the information on the CD, like tracks, durations, etc. I
│ not found a way to know it by software. If someone knows, well... le
│ me know.
From: magnush@programmers.bbs.no (Magnus Holm)
}
procedure initcd;assembler;
asm
  mov cd_installed,false
  mov ax,1100h
  int 2fh
  mov cd_initresult,al
  cmp al,$ff
ne @@1
  mov cd_installed,true

{ MSCDEX version? }

  mov ax,150ch
  int 2fh
  mov mscdex_version,BX

{ How many players? }

  mov ax,1500h
  mov bx,0000h
  int 2fh
  mov cd_drivecount,bx
  mov cd_startch,cx     { Starts on drive nr }

@@1:
end;
