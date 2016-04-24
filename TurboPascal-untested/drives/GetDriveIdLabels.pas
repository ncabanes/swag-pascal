(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0023.PAS
  Description: Get Drive ID & Labels
  Author: SWAG SUPPORT TEAM
  Date: 06-22-93  09:16
*)

UNIT FCBLabel;
{Turbo Pascal unit for manipulating volume labels}

INTERFACE
USES
    DOS;
TYPE
    DriveType   = String[1];
    DiskIDType  = String[11];

FUNCTION GetDiskID(Drive:DriveType): DiskIDType;
FUNCTION SetDiskID(Drive:DriveType;
                    DiskID:DiskIDType): Boolean;
FUNCTION ReNameDiskID(Drive:DriveType;
                   OldDiskID:DiskIDType;
                   NewDiskID:DiskIDType): Boolean;
FUNCTION DeleteDiskID(Drive:DriveType): Boolean;

IMPLEMENTATION
TYPE
    ExtendedFCBRecord = RECORD
               ExtFCB : Byte;
               Res1   : ARRAY[1..5] OF Byte;
               Attr   : Byte;
               Drive  : Byte;
               Name1  : ARRAY[1..11] OF Char;
               Unused1: ARRAY[1..5] OF Char;
               Name2  : ARRAY[1..11] OF Char;
               Unused2: ARRAY[1..9] OF Byte;
           END;

FUNCTION GetDiskID(Drive:DriveType): DiskIDType;
VAR
   DirInfo     : SearchRec;
   DirDiskID   : String[12];
   I,PosPeriod : Byte;
BEGIN
   FindFirst(Drive+':\'+'*.*',VolumeID,DirInfo);
   IF DosError = 0 THEN
      BEGIN
         DirDiskID := DirInfo.Name;
         PosPeriod := POS('.',DirDiskID);
         IF PosPeriod > 0 THEN
            Delete(DirDiskID,PosPeriod,1);
         GetDiskID := DirDiskID
      END
   ELSE
      GetDiskID := ''
END;

{Use MsDos service 16H to SET a volume label }
FUNCTION SetDiskID(Drive:DriveType;
                    DiskID:DiskIDType): Boolean;
VAR
   FCB  : ExtendedFCBRecord;
   Regs : Registers;
   Temp : String[1];
   I    : Integer;
BEGIN
   Temp := Drive;
   WITH FCB DO
     BEGIN
       ExtFCB := $FF;
       Attr   := $8;
       Drive  := Ord(UpCase(Temp[1])) - 64;
       FOR I := 1 TO Length(DiskID) DO
         Name1[I] := DiskID[I];
         IF Length(DiskID) < 11 THEN
           FOR I := (Length(DiskID) + 1) TO 11 DO
             Name1[I] := ' '
     END;
   Regs.ah := $16;
   Regs.ds := Seg(FCB);
   Regs.dx := Ofs(FCB);
   MsDos(Regs);
   IF Regs.AL = 0 THEN
      SetDiskID := TRUE
   ELSE
      SetDiskID := FALSE
END;

{use MsDOS service 17H to RENAME a volume label }
FUNCTION ReNameDiskID(Drive:DriveType;
                   OldDiskID:DiskIDType ;
                   NewDiskID:DiskIDType): Boolean;
VAR
   FCB  : ExtendedFCBRecord;
   Regs : Registers;
   Temp : String[1];
   I    : Integer;
BEGIN
  Temp := Drive;
  WITH FCB DO
    BEGIN
      ExtFCB := $FF;
      Attr   := $8;
      Drive  := Ord(UpCase(Temp[1])) - 64;

      {Set old disk id}

      FOR I := 1 TO Length(OldDiskID) DO
        Name1[I] := OldDiskID[I];
      FOR I := (Length(OldDiskID) + 1) TO 11 DO
        Name1[I] := ' ';

      {Set new disk id}

      FOR I := 1 TO Length(NewDiskID) DO
        Name2[I] := NewDiskID[I];
      FOR I := (Length(NewDiskID) + 1) TO 11 DO
        Name2[I] := ' '
    END;
  Regs.ah := $17;
  Regs.ds := Seg(FCB);
  Regs.dx := Ofs(FCB);
  MsDos(Regs);
  IF Regs.AL = 0 THEN
     ReNameDiskID := TRUE
  ELSE
     ReNameDiskID := FALSE
END;

{Use MsDos service 13H DELETE a volume label }

FUNCTION DeleteDiskID(Drive:DriveType): Boolean;
VAR
  FCB  : ExtendedFCBRecord;
  Regs : Registers;
  Temp : String[1];
  I    : Integer;
BEGIN
  Temp := Drive;
  WITH FCB DO
    BEGIN
      ExtFCB := $FF;
      Attr   := $8;
      Drive  := Ord(UpCase(Temp[1])) - 64;
      Name1[1] := '*';
      Name1[2] := '.';
      Name1[3] := '*';
      FOR I := 4 TO 11 DO Name1[I] := ' '
    END;
  Regs.ah := $13;
  Regs.ds := Seg(FCB);
  Regs.dx := Ofs(FCB);
  MsDos(Regs);
  IF Regs.AL = 0 THEN
     DeleteDiskID := TRUE
  ELSE
     DeleteDiskID := FALSE
END;

END.

