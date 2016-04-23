Function ModemRinging(Port : Word) : Boolean;  { through the BIOS }
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
  ModemRinging := (Dummy and RI) = RI       { ring indicated }
end;

or

Function ModemRinging(Port : Byte) : Boolean;  { direct port access }
Const
  RI = $40;
begin
  Case Port of
    1 : ModemRinging := ($3FE and RI) = RI;   { com 1 }
    2 : ModemRinging := ($2FE and RI) = RI    { com 2 }
  end
end;

Function PhoneRinging(ComPort: Integer): Boolean;
begin
    Case ComPort Of
        1: PhoneRinging := (Port[$3FE] And 64) = 64;
        2: PhoneRinging := (Port[$2FE] And 64) = 64;
        3: PhoneRinging := (Port[$3EE] And 64) = 64;
        4: PhoneRinging := (Port[$2EE] And 64) = 64;
        Else
            PhoneRinging := False;
    end;
end;

Function returns True if phone is ringing. Hope it helps.

{
> Function returns True if phone is ringing. Hope it helps.

Just nitpicking but...

 PhoneRinging:=(Port[$3FE] and 64)<>0

is more efficient, as is

 PhoneRinging:=Boolean(Port[$3FE] and 64)
}