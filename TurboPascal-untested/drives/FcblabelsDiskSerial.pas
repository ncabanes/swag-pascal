(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0026.PAS
  Description: FCBLABELS - Disk Serial
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:42
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

{ ---------------    TEST PROGRAM -------------------}


PROGRAM TestFCB;

{ test FCBLabel UNIT}

USES  CRT,FCBLabel;

VAR
   Choice      : Byte;
   Drive       : DriveType;
   DiskID      : DiskIDType;
   NewDiskID   : DiskIDType;

BEGIN
  REPEAT {Endless loop - select option 5 to Exit}
    ClrScr;
    GotoXY(25,1);  WriteLn('Volume Functions');
    GotoXY(25,9);  WriteLn('1) SET LABEL');
    GotoXY(25,10); WriteLn('2) DELETE LABEL');
    GotoXY(25,11); WriteLn('3) RENAME LABEL');
    GotoXY(25,12); WriteLn('4) GET LABEL');
    GotoXY(25,13); WriteLn('5) Exit');
    GotoXY(20,15);
    Write('Type number and press Enter > ');
    ReadLn(Choice); WriteLn;
    Drive := 'C';   { use drive C: as test drive }

    CASE Choice OF
    1: BEGIN  {Set volume LABEL}
        DiskID := GetDiskID(Drive);
          IF DiskID <> '' THEN
            BEGIN
              WriteLn('Label not null: ',DiskID);
              WriteLn('Use RENAME instead');
              WriteLn('Press Enter to continue');
              ReadLn
            END
          ELSE
            BEGIN
              Write('Enter new label > ');
              ReadLn(DiskID);
              IF NOT SetDiskID(Drive,DiskID) THEN
                BEGIN
                  WriteLn('System Error');
                  WriteLn
                     ('Press Enter to continue');
                  ReadLn
                END
            END
          END;
     2: BEGIN {Delete Volume LABEL}
          IF DeleteDiskID(Drive) THEN
            WriteLn('Volume label deleted')
          ELSE
            WriteLn('System Error');
          WriteLn('Press Enter to continue');
          ReadLn
        END;
     3: BEGIN {Rename Volume LABEL}
          DiskID := GetDiskID(Drive);
          IF DiskID = '' THEN
            BEGIN
              WriteLn('Current label is null:');
              WriteLn('Use SET option instead');
              WriteLn('Press Enter to continue');
              ReadLn
            END
          ELSE
            BEGIN
              Write('Enter new name of label > ');
              ReadLn(NewDiskID);
              IF NOT ReNameDiskID
                     (Drive,DiskID,NewDiskID) THEN
                BEGIN
                  WriteLn('System Error');
                  WriteLn
                     ('Press Enter to continue');
                  ReadLn
                END
            END
        END;
     4: BEGIN {Get Volume LABEL}
          DiskID := GetDiskID(Drive);
          Write('The current label is ');
          IF DiskID = '' THEN
            WriteLn('null')
          ELSE
            WriteLn(DiskID);
            WriteLn('Press Enter to continue');
            ReadLn
        END;
     5: Halt;
     ELSE   { continue }
    END     { case }
  UNTIL FALSE
END.

