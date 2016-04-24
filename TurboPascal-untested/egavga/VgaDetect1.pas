(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0041.PAS
  Description: VGA Detect #1
  Author: SEAN PALMBER
  Date: 05-28-93  13:39
*)

{
SEAN PALMER

Well, here are routines to detect a VGA and an EGA adapter...
}
Uses
  Crt;

Var
  OldMode : Byte;

function EGAInstalled : boolean; assembler;
asm
  mov ax, $1200
  mov bx, $10
  mov cx, $FFFF
  int $10
  inc cx
  mov al, cl
  or  al, ch
end;

function VgaPresent : boolean; assembler;
asm
  mov ah, $F
  int $10
  mov oldMode, al   {save old Gr mode}
  mov ax, $1A00
  int $10           {check for VGA/MCGA}
  cmp al, $1A
  jne @ERR          {no VGA Bios}
  cmp bl, 7
  jb  @ERR          {is VGA or better?}
  cmp bl, $FF
  jnz @OK
 @ERR:
  xor al, al
  jmp @EXIT
 @OK:
  mov al, 1
 @EXIT:
end;

begin
  OldMode := LastMode;
  Writeln(EGAInstalled);
  Writeln(VGAPresent);
end.
