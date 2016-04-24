(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0010.PAS
  Description: Get Drive Parameters
  Author: MARCO MILTENBURG
  Date: 05-28-93  13:38
*)

{
Author : MARCO MILTENBURG

Here's an overview of INT13h, Function 8 :

Name  : Get drive parameters

Input : AH = 08h
        DL = <drive>   00h - 7Fh : Floppy disk
                       80h - FFh : Harddisk

Output: if succesfull
        -------------
        Carry is cleared
        BL = <driveType>    01 : 360 KBytes, 40 tracks, 5.25 Inch
                            02 : 1,2 MBytes, 80 tracks, 5.25 Inch
                            03 : 720 KBytes, 80 tracks, 3.5 Inch
                            04 : 1,44 MBytes, 80 tracks, 3,5 Inch
        CH = Lower 8 bits of maximum cylindernumber
        CL = bits 6-7 : Highest 2 bits of maximum cylindernumber
             bits 0-5 : Maximum sectornumber
        DH = Maximum headnumber
        DL = Number of connected drives
        ES:DI = Pointer to disk drive parameter table

        if failed
        ---------
        Carry is set
        AH = errorstatus

As you can see, you must do more to get the cylindernumber. Here's a little
pascal code :
}

Uses
  Dos;

Const
  DriveTypes : Array[0..4] of String[18] = ('Harddisk          ',
                                            '360 kB - 5.25 Inch',
                                            '1.2 MB - 5.25 Inch',
                                            '720 kB - 3.5 Inch ',
                                            '1.44 MB - 3.5 Inch');
Var
  Regs      : Registers;
begin
  Regs.AH := $08;
  Regs.DL := $80;
  Intr($13, Regs);

  WriteLn ('DriveType : ', DriveTypes[Regs.BL]);
  WriteLn ('Cylinders : ', 256 * (Regs.CL SHR 6) + Regs.CH + 1);
  WriteLn ('Sectors   : ', Regs.CL and $3F);
  WriteLn ('Heads     : ', Regs.DH + 1);

end.
{
This will give you the right information from your diskdrives. I noticed that
my harddisks will always be reported as driveType 0 (zero). I don't know for
sure if that is documented, but it seems to be logical ;-).
}
