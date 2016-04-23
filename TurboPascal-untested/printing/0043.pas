function GetPrinterStatus (LPT: Word): Byte;
{Pass 1 in LPT to see if the printer is hooked up.} 
begin
  asm
    mov ah,2
    mov dx,LPT
    dec dx
    int $17
    mov @Result,ah
  end;
end;  {GetPrinterStatus}
