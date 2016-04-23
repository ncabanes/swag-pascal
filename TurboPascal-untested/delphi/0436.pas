

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