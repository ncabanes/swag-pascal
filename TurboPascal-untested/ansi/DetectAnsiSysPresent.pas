(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0016.PAS
  Description: Detect ANSI.SYS Present
  Author: STEVE CONNET
  Date: 08-27-93  20:37
*)

{
STEVE CONNET

determine whether ansi.sys is installed
}

Function LocalAnsiDetected : Boolean;
Var
  Dummy : Byte;
begin
  Asm
    mov ah,1ah                { detect ANSI.SYS device driver }
    mov al,00h
    int 2fh
    mov dummy,al
  end;
  LocalAnsiDetected := Dummy = $FF;
end;

