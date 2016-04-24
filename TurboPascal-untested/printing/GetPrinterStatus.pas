(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0043.PAS
  Description: Get PRINTER Status
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:05
*)

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
