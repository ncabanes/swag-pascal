{
-> I am searching for information on how to access the Fat table and
-> boot sectors through Turbo Pascal v6.0.  If anyone knows a book that
-> could point me in the right direction, or would be willing to share
-> some knowledge with me I'd appreciate it. Thanx.

Here's some source to help you out:
}

(*** BEGINS HERE ***)
(***********************************************************************
***
*   This is a simple source to demonstrate how to read the File
Allocation
   Table (FAT) and get some information on the current drive.  This was
   written by David Mart, using TP7.0
   NOTE: DOS 2.0 or higher is required.

   If you have any questions, you can contact me by calling Programmers
   Online Systems at 416-512-1928 or simply send me a netmail via
FidoNet
   to: 1:250/738.
************************************************************************
**)

Program ReadFAT;
Uses DOS,CRT;
Var
  MyRegs   : Registers;
  ClusterSize : Real;
  DiskSize    : Real;

Begin
  LowVideo;
  ClrScr;

  Fillchar (MyRegs, sizeof(Registers), 00);
  MyRegs.AH := $30;
  MyRegs.DS := DSeg;
  MsDOS (MyRegs);
  Fillchar (MyRegs, sizeof(Registers), 00);
  MyRegs.AH := $1B;
  MyRegs.DS := DSeg;
  MsDOS (MyRegs);
  WriteLn;
  WriteLn ('Information for current drive: ');
  WriteLn;

  With MyRegs Do
       Begin
         WriteLn ('Clusters on disk    : ', DX);
         WriteLn ('Sectors p/Cluster   : ', AL);
         WriteLn ('Sector Size (Bytes) : ', CX);
         WriteLn;
         ClusterSize := (AL * CX);
         DiskSize    := (ClusterSize * DX);
         WriteLn ('Cluster Size (Bytes): ', Round(ClusterSize));
         WriteLn ('Disk Space (Bytes)  : ', Round(DiskSize));
       End;
End.

