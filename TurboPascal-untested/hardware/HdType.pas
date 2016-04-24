(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0022.PAS
  Description: HD Type
  Author: HELGE HELGESEN
  Date: 01-27-94  11:58
*)

{
> Does anyone know how to get the hard drive type(s) from CMOS ?
}

Function GetFixedDrive(DriveNum : Byte) : Byte; Assembler;
Asm
  mov  al, DriveNum
  and  al, 1
  add  al, $19
  out  $70, al
  in   al, $71
end;

{
You specify what drive you want (0/1) and you'll get the
disk type as specified in CMOS.
}

begin
  Writeln(GetFixedDrive(3));
end.
