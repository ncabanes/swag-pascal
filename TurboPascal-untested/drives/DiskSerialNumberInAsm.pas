(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0054.PAS
  Description: Disk Serial Number in ASM
  Author: JIMISOLA LAURSEN
  Date: 11-02-93  06:17
*)

{
jimisola.laursen@cindy.ct.se (jimisola laursen)

> Anybody know how to read the Volume Serial Number from a (hard) disk??
> No problem getting the Volume Label, but this seemsa to be another matter...
}

Unit Serial;

Interface

Uses
  Dos;

Function Get_Serial_number(Drive : Byte) : String;

Implementation

Asm
  mov  ax, w
  mov  bx, b
  xor  cx, cx
  les  di, @result
  xor  si, si
  jcxz @@@20
 @@@10:
  xor  dx, dx
  div  bx
  cmp  dl, 10
  jb   @h10
  add  dl, 'A'-10
  jmp  @h20
 @h10:
   or  dl, '0'
 @h20:
  push dx
  inc  si
  loop @@@10
 @@@20:
  inc  cx
  or   ax, ax
  jnz  @@@10
  mov  cx, si
  jcxz @@@40
  cld
  mov  al, cl
  stosb
 @@@30:
  pop  ax
  stosb
  loop @@@30
 @@@40:
end;

Function Get_Serial_number(Drive : Byte) : String;
(* "Drive" is 0=current, 1=A:, 2=B: osv.. *)
Type
  Disk_info = Record
    RES     : Word;                 (* reserverad ska Vara 0 *)
    SER_NR1 : Word;                 (* Serinummer (bin{rt) *)
    SER_NR2 : Word;                 (* Serinummer (bin{rt) *)
    VOL     : Array [1..11] of Char;(* Volume Label *)
    TYP     : Array [1..8] of Char; (* tex 'FAT12' eller 'FAT16' *)
  end;
Var
   D_I    : Disk_Info;
   s1, s2 : String[5];
begin
  Asm
    push ds
    mov ax,ss
    mov ds,ax
    lea dx,D_I
    mov bl,drive
    mov ax,6900h
    int 21h
    pop ds
  end;
  s1 := NumAscii(D_I.SER_NR2, 16);
  s2 := NumAscii(D_I.SER_NR1, 16);
  While length(s1) < 4 do
    s1 := '0' + s1;
  While length(s2) < 4 do
    s2 := '0' + s2;
  Get_Serial_number := s1 + '-' + s2;
end;

end.

