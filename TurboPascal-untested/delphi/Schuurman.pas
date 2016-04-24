(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0367.PAS
  Description: Schuurman
  Author: A
  Date: 01-02-98  07:33
*)


>Does anyone know of a good component package for building instrumentation
>applications?  I would like to build an app that tracks equipment status
>(real time) and stores the data output for charting.  Communications is via
>an ISA RS 232 I/O card through a RS 485 - RS 232 converter.

Another possibility is:

function InPort(PortAddr:word): byte;
{$IFDEF WIN32}
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

procedure OutPort(PortAddr:
          word; Databyte: byte);
{$IFDEF WIN32}
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

Just fill in the right port address (parallel or serial)

Good luck,

Arjan


