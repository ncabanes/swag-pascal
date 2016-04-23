(*
===========================================================================
 BBS: Canada Remote Systems
Date: 09-20-93 (01:47)             Number: 8840
From: CHRIS PRIEDE                 Refer#: NONE
  To: WIM VAN.VOLLENHOVEN           Recvd: NO
Subj: Disk & Drives                  Conf: (1617) L-Pascal
---------------------------------------------------------------------------
WV>  - I can't figure out how to determain if the drive is a ramdisk
WV>    or a fixed disk.

    RAM disks have only one copy of FAT, while floppies and hard disks
should have at least two. Use DOS function 1Fh or 32h to get this
information for current/specified drive. The following program uses
function 1F:

===========================================================
*)

program TellMeAllAboutMyDrive;
(* Released to public domain, K. Priede, 1993 *)

uses Dos;

type
  (* record matching DOS (2.0+) Drive Parameter Block.
   * defined only interesting items, DOS structure is bigger *)
  DosDPB = record
    Drive, UnitNo: byte;
    BytesPerSector: word;
    LastSectorInCluster: byte;
    ShiftCount: byte;
    ReservedSectors: word;
    FATCount: byte;
    RootDirEntries, FirstDataSector, LastCluster: word;
  end;

var
  Regs: Registers;

begin
  (* func. 1Fh -- Get DPB
   * returns: AL = 0 if successful, DS:BX -> DBP *)
  Regs.AH := $1F;
  MsDos(Regs);
  (* now show what we got ... *)
  if Regs.AL = 0 then
    with DosDPB(Ptr(Regs.DS, Regs.BX)^) do
    begin
      Writeln(#10#13'Parameters for drive ',
        Chr(Ord('A') + Drive), ':'#13#10);
      Writeln('Sector size: ':24, BytesPerSector, ' bytes');
      Writeln('Sectors per cluster: ':24, LastSectorInCluster +1);
      Writeln('Clusters on drive: ':24, LastCluster -1);
      Writeln('Total drive space: ':24, longint(BytesPerSector) *
        (LastSectorInCluster +1) * (LastCluster -1),' bytes'#13#10);
      Writeln('Number of FATs: ':24, FATCount);
      Writeln('Root directory size: ':24, RootDirEntries, ' entries');
    end
   else Writeln('Error!');
end.
===========================================================
---
 ■ RNET 2.00m: ILink: Faster-Than-Light ■ Atlanta GA ■ 404-296-3120 / 299-3930
