(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0002.PAS
  Description: Carrier Detect
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
>Does anyone know how to detect when the modem connects?? Thanks.

Through the BIOS:
}

Function CarrierDetected(Port : Word) : Boolean;
Const
  DCD = $80;
Var
  Dummy : Byte;
begin
  Asm
    dec port
    mov ah,03h
    mov dx,port
    int 14h
    mov dummy,al
  end;
  CarrierDetected := (Dummy and DCD) = DCD       { carrier detected }
end;

{ Or directly: }

Function CarrierDetected(Port : Byte) : Boolean;
begin
  Case Port of
    1: CarrierDetected := ($3FE and $80) = $80;   { com 1 cd }
    2: CarrierDetected := ($2FE and $80) = $80    { com 2 cd }
  end
end;

