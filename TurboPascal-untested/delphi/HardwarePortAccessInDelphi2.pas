(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0436.PAS
  Description: Hardware port access in DELPHI 2
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:34
*)



--------------------------------------------------------------------------------

function InPort(PortAddr: word): byte;
{$IFDEF VER90}
assembler; stdcall;
asm
        mov dx,PortAddr
        in al,dx
end;
{$ELSE}
begin
Result := Port[PortAddr];
end;
{$ENDIF}

procedure OutPort(PortAddr: word; Databyte: byte);
{$IFDEF VER90}
assembler; stdcall;
asm
   mov al,Databyte
   mov dx,PortAddr
   out dx,al
end;
{$ELSE}
begin
Port[PortAddr] := DataByte;
end;
{$ENDIF}

