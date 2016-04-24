(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0083.PAS
  Description: Available Drive Lister
  Author: ANDREW EIGUS
  Date: 11-26-94  04:56
*)

{
> What I need is a routine that will give back the letters of the active
> drives on a system.  Can anyone help me.
}
Program ListAvailableDrives;
(*
  Public Domain, (c) 1994 by Andrew Eigus   Fidonet: 2:5100/33 }
  These routines are taken from my EnhDOS unit where are lot of useful
  stuff.

  MATERIAL RELEASED FOR SWAG
*)

const
  { GetDriveType return values }

  dtError      = $00; { Bad drive }
  dtFixed      = $01; { Fixed drive }
  dtRemovable  = $02; { Removable (floppy) drive }
  dtRemote     = $03; { Remote (network) drive }
  dtCDROM      = $04; { CD-ROM V2.00+ drive }
  dtDblSpace   = $05; { DoubleSpace compressed drive }

Function GetDriveType(Drive : byte) : byte; assembler;
{ 0=current (default) drive,1=A,2=B,3=C... }
Asm
  cmp Drive,0
  jne @@1
  mov ah,19h
  int 21h
  mov Drive,al
  inc Drive
@@1:
  mov ax,1500h
  xor bx,bx
  int 2Fh
  or  bx,0      { works with CD-ROM v2.00+ }
  jz  @@2
  mov ax,150Bh
  xor ch,ch
  mov cl,Drive
  int 2Fh
  cmp bx,0ADADh
  jne @@2
  or  ax,0
  jz  @@2
  mov bl,dtCDROM
  jmp @@7
@@2:
  mov ax,4A11h
  mov bx,1
  mov dl,Drive
  dec dl
  int 2Fh
  xor cl,cl     { mov cl,False }
  or  ax,0      { is DoubleSpace loaded? }
  jnz @@3
  cmp dl,bl     { if a host drive equal to compressed, then get out... }
  je  @@3
  test bl,10000000b { bit 7=1: DL=compressed,BL=host
                           =0: DL=host,BL=compressed }
  jz  @@3       { so avoid host drives, assume host=fixed :) }
  inc dl
  cmp Drive,dl
  jne @@3
  mov bl,dtDblSpace
  jmp @@7
@@3:
  mov ax,4409h
  mov bl,Drive
  int 21h
  jc  @@5
  or  al,False
  jz  @@4
  mov bl,dtRemote
  jmp @@7
@@4:
  mov ax,4408h
  mov bl,Drive
  int 21h
  jc  @@5
  or  al,False
  jz  @@6
  mov bl,dtFixed
  jmp @@7
@@5:
  xor bl,bl     { mov bl,dtError cuz dtError=0 }
  jmp @@7
@@6:
  mov bl,dtRemovable
@@7:
  mov al,bl
End; { GetDriveType }

var
  Drive : byte;
  DriveType : byte;

Begin
  WriteLn(#13#10'Drives available:');
  WriteLn('-----------------------------');
  for Drive := (Ord('A') - Ord('A') + 1) to (Ord('Z') - Ord('A') + 1) do
  begin
    DriveType := GetDriveType(Drive);
    if DriveType <> dtError then
    begin
      Write('Drive ', Chr(Drive + Ord('A') - 1), ': ');
      case DriveType of
        dtRemovable: WriteLn('Removable (floppy)');
        dtFixed: WriteLn('Fixed (hard disk)');
        dtRemote: WriteLn('Remote (network)');
        dtCDROM: WriteLn('CD-ROM');
        dtDblSpace: WriteLn('DoubleSpace')
      end
    end
  end;
  WriteLn('-----------------------------')
End.

