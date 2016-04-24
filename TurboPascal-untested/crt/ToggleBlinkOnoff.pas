(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0016.PAS
  Description: Toggle Blink On/Off
  Author: SWAG SUPPORT GROUP
  Date: 11-26-93  18:16
*)

procedure ToggleBlink(OnOff:boolean);
assembler;
asm
  mov ax,1003h
  mov bl,OnOff
  int 10h
end;

