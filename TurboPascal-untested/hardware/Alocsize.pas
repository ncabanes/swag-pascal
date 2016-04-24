(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0002.PAS
  Description: ALOCSIZE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

*--*  03-31-93  -  21:47:03  *--*
/. Date: 03-30-93 (23:45)              Number: 24023 of 24035
  To: PEDRO PACHECO                 Refer#: 23957
From: ERIC LU                         Read: NO
Subj: allocation Units              Status: PUBLIC MESSAGE
Conf: R-TP (552)                 Read Type: GENERAL (A) (+)

PP>> Is there any way to find (in Pascal) what's de size of each allocation uni
PP>> in a Hard drive?

Pedro,
     See if the following is what you wanted...

-------------------------------- Cut  ----------------------------------

Program Int21_36;
Uses Crt,Dos;
Procedure DiskfreeSpace( DriveCode: Byte);
Var
   Regs: Registers;
   SectorsPerCluster,
   AvailableClusters,
   BytesPerSector,
   ClustersPerDrive,
(63 min left), (H)elp, More?    AllocationSize,
   Capacity,
   Free:  LongInt;
begin
   Regs.AH := $36;
   Regs.DL := DriveCode;
   MSDos(Regs);

   {************* Obtaining Infos ******************}
   SectorsPerCLuster:= Regs.AX;
   AvailableClusters:= Regs.BX;
   BytesPerSEctor   := Regs.CX;
   ClustersPerDrive := Regs.DX;

   {************* Calculations ********************)
   AllocationSize   := BytesPerSector * SectorsPerCluster;
   Capacity := SectorsPerCluster * BytesPerSector * ClustersPerDrive;
   Free     := SectorsPerCLuster * AvailableClusters * BytesPerSector;

   {************* Display *************************}
   Writeln(' Sectors Per Cluster   = ',SectorsPerCluster:15,'');
   Writeln(' Available Clusters    = ',AvailableClusters:15,'');
   Writeln(' Bytes Per Sector      = ',BytesPerSector:15,'');
(63 min left), (H)elp, More?    Writeln(' Clusters Per Drive    = ',ClustersPerDrive:15,'');
   Writeln(' Allocation Size       = ',AllocationSize:15,' Bytes');
   Writeln(' Drive Capacity        = ',Capacity:15,' Bytes');
   Writeln(' Free Space            = ',Free:15,' Bytes');
end;

begin
   ClrScr;
   DiskFreeSpace(0);   {Get Current Drive Info}
   readln;
end.


----------------------------- Cut ----------------------------------

 The above should be ready to run as I have tested on my computer..
 It's got more infos..  I was learning it as I was typing it in so I
 made it more than what you need.
 hope this is what you wanted to know...

                                                        Eric

---
(63 min left), (H)elp, More?  ■ OLX 2.1 TD ■ It's only a hobby ... only a hobby ... only a
 * Casino Bulletin Board * Hammonton/Atlantic City NJ U.S.A. 1-609-561-3377
 * PostLink(tm) v1.05  CASINO (#18) : RelayNet(tm)

(63 min left), (H)elp, end of Message Command? 
