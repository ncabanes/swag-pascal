(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0005.PAS
  Description: CPU Delay
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

{
> does anyone have an accurate BAsm Delay routine that is
> compatible With the one in the Crt Unit? please post it...
}

Procedure Delay(ms : Word); Assembler;
Asm {machine independent Delay Function}
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  int $15;
end;

