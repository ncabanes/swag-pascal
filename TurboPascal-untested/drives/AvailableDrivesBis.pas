(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0049.PAS
  Description: Available Drives
  Author: KENT BRIGGS
  Date: 11-02-93  04:52
*)

{
KENT BRIGGS

> Does anyone know how to check if a drive is valid Without accessing
> it to see? For example, if the available drives on a system are: A, B,
> C, E. How do you check if drive A is installed Without having the
> floppy drive lights go on. I use TP6, so if you include a sample code,
> could you make it compatible With it.
}

Program Show_drives;

Uses
  Dos;

Var
  Drv : Array [1..3] of Byte;

Procedure ReportDrives;
Var
  Regs    : Registers;
  Count   : Integer;
  DrvList : String[26];
  Fcb     : Array [1..37] of Byte;
begin
  DrvList := '';
  For Count := 1 to 26 do         {Try drives A..Z}
  begin
    Drv[1]  := Count + 64;         {A=ASCII 65, etc}
    Drv[2]  := Ord(':');
    Drv[3]  := 0;
    Regs.AX := $2906;          {Dos Function 29h = Parse Filename}
    Regs.SI := Ofs(Drv[1]);    {Point to drive String}
    Regs.DI := Ofs(Fcb[1]);    {Point to File Control Block}
    Regs.DS := DSeg;
    Regs.ES := DSeg;
    MsDos(Regs);               {Dos Interrupt}
    if Regs.AL <> $FF then
      DrvList := DrvList + Chr(Count + 64);
  end;
  Writeln('Available drives = ', DrvList);
end;

begin
  ReportDrives;
end.


