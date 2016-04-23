(*
        Extended GetDriveType for Windows 3.0/3.1.

        Code ported the C in Microsoft PSS document Q105922.

        Doug Wegscheid 3/22/94.
*)

{$DEFINE TEST}        { undefine to make a unit }

{$IFDEF TEST}
program drivetyp;
uses wincrt, windos, winprocs, wintypes;
{$ELSE TEST}
unit drivetyp;

interface
{$ENDIF}

{ Return values of GetDriveTypeEx(). }
const
 EX_DRIVE_INVALID    = 0;
 EX_DRIVE_REMOVABLE  = 1;
 EX_DRIVE_FIXED      = 2;
 EX_DRIVE_REMOTE     = 3;
 EX_DRIVE_CDROM      = 4;
 EX_DRIVE_FLOPPY     = 5;
 EX_DRIVE_RAMDISK    = 6;

{$IFNDEF TEST}
function GetDriveTypeEx (nDrive : integer) : integer;

implementation
uses windos, winprocs, wintypes;
{$ENDIF}

{
 See the "MS-DOS Programmer's Reference" for further information
 about this structure. It is the structure returned with an IOCTL
 $0D function, $60 subfunction (get device parameters).
}
type
 DeviceParams = record
  bSpecFunc        : byte;                { Special functions }
  bDevType        : byte;                { Device type }
  wDevAttr        : word;         { Device attributes }
  wCylinders        : word;                { Number of cylinders }
  bMediaType        : byte;                { Media type }
  { Beginning of BIOS parameter block (BPB) }
  wBytesPerSec        : word;                { Bytes per sector }
  bSecPerClust        : byte;                { Sectors per cluster }
  wResSectors        : word;              { Number of reserved sectors }
  bFATs                : byte;         { Number of FATs }
  wRootDirEnts        : word;             { Number of root-directory entries }
  wSectors        : word;         { Total number of sectors }
  bMedia        : byte;         { Media descriptor }
  wFATsecs        : word;         { Number of sectors per FAT }
  wSecPerTrack        : word;             { Number of sectors per track }
  wHeads        : word;         { Number of heads }
  dwHiddenSecs        : longint;             { Number of hidden sectors }
  dwHugeSectors        : longint;            { Number of sectors if wSectors == 0 }
  { End of BIOS parameter block (BPB) }
 end;

function GetDeviceParameters (nDrive : integer; var dp : DeviceParams) : boolean;
(*
 //-----------------------------------------------------------------
 // GetDeviceParameters()
 //
 // Fills a DeviceParams struct with info about the given drive.
 // Calls DOS IOCTL Get Device Parameters (440Dh, 60h) function.
 //
 // Parameters
 //   nDrive   Drive number  0 = A, 1 = B, 2 = C, and so on.
 //   dp       A structure that will contain the drive's parameters.
 //
 // Returns TRUE if it succeeded, FALSE if it failed.
 //-----------------------------------------------------------------
*)
var
 r                : TRegisters;
begin
 fillchar(r,sizeof(r),#0);        { clean up registers to avoid GPF }
 r.ax := $440d;                        { IOCTL }
 r.ch := $08;                        { block device }
 r.cl := $60;                        { get device parameters }
 r.bx := nDrive + 1;                { 1 = A:, 2 = B:, etc... }
 r.ds := seg(dp); r.dx := ofs(dp);        { where... }
 msdos(r);
 GetDeviceParameters := (r.flags and fCarry) = 0
end;

function IsCDRomDrive (nDrive : integer) : boolean;
(*
 //-----------------------------------------------------------------
 // IsCDRomDrive()
 //
 // Determines if a drive is a CD-ROM. Calls MSCDEX and checks
 // that MSCDEX is loaded, and that MSCDEX reports the drive is a
 // CD-ROM.
 //
 // Parameters
 //    nDrive    Drive number  0 = A, 1 = B, 2 = C, and so forth.
 //
 // Returns TRUE if nDrive is a CD-ROM drive, FALSE if it isn't.
 //-----------------------------------------------------------------
*)
var
 r        : TRegisters;
begin
 fillchar(r,sizeof(r),#0);        { clean up registers to avoid GPF and
                                  to ensure that BX = $ADAD would not
                                  be by accident }
 r.ax := $150b;                        { MSCDEX installation check }
 {
   This function returns whether or not a drive letter is a CD-ROM
   drive supported by MSCDEX. If the extensions are installed, BX
   will be set to ADADh. If the drive letter is supported by
   MSCDEX, then AX is set to a non-zero value. AX is set to zero
   if the drive is not supported. One must be sure to check the
   signature word to know that MSCDEX is installed and that AX
   has not been modified by another INT 2Fh handler.
 }
 r.cx := nDrive;                { 0 = A:, 1 = B:, etc... }
 intr ($2f, r);                        { do it }
 IsCDRomDrive := (r.bx = $adad) and (r.ax <> 0)
end;

(*
 //-----------------------------------------------------------------
 // GetDriveTypeEx()
 //
 // Determines the type of a drive. Calls Windows's GetDriveType
 // to determine if a drive is valid, fixed, remote, or removeable,
 // then breaks down these categories further to specific device
 // types.
 //
 // Parameters
 //    nDrive    Drive number  0 = A, 1 = B, 2 = C, etc.
 //
 // Returns one of:
 //    EX_DRIVE_INVALID         -- Drive not detected
 //    EX_DRIVE_REMOVABLE       -- Unknown removable-media type drive
 //    EX_DRIVE_FIXED           -- Hard disk drive
 //    EX_DRIVE_REMOTE          -- Remote drive on a network
 //    EX_DRIVE_CDROM           -- CD-ROM drive
 //    EX_DRIVE_FLOPPY          -- Floppy disk drive
 //    EX_DRIVE_RAMDISK         -- RAM disk
 //-----------------------------------------------------------------
*)
function GetDriveTypeEx (nDrive : Integer) : integer;
var
 dp        : DeviceParams;
 utype        : integer;
begin
 fillchar (dp, sizeof(dp), #0);        { clear the DPB }
 uType := GetDriveType(nDrive);        { make a rough guess }
 case uType of

  DRIVE_REMOTE:
   { GetDriveType() reports CD-ROMs as Remote drives. Need
     to see if the drive is a CD-ROM or a network drive. }
   if IsCDRomDrive (nDrive)
    then GetDriveTypeEx := EX_DRIVE_CDROM
    else GetDriveTypeEx := EX_DRIVE_REMOTE;

  DRIVE_REMOVABLE:
   {
     Check for a floppy disk drive. If it isn't, then we
     don't know what kind of removable media it is.
     For example, could be a Bernoulli box or something new...

     DOS 6.0 Reference says devicetype 0=320/360kb floppy,
     1=1.2Mb, 2=720kb, 3=8" single density, 4=8" double density,
     7=1.44Mb, 8=optical, 9=2.88Mb. Code in Q105922 didn't pick
     up bDevType=9.
   }
   if GetDeviceParameters (nDrive, dp) and (dp.bDevType in [0..4,7..9])
    then GetDriveTypeEx := EX_DRIVE_FLOPPY
    else GetDriveTypeEx := EX_DRIVE_REMOVABLE;

  DRIVE_FIXED:
   {
     GetDeviceParameters returns a device type of 0x05 for
     hard disks. Because hard disks and RAM disks are the two
     types of fixed-media drives, we assume that any fixed-
     media drive that isn't a hard disk is a RAM disk.
   }
   if GetDeviceParameters (nDrive, dp) and (dp.bDevType = 5)
    then GetDriveTypeEx := EX_DRIVE_FIXED
    else GetDriveTypeEx := EX_DRIVE_RAMDISK;

  else
   GetDriveTypeEx := EX_DRIVE_INVALID
 end
end;

{$IFDEF TEST}
var
 i, d        : integer;
begin
 for i := 0 to 25
  do begin
   d := GetDriveTypeEx(i);
   if d <> EX_DRIVE_INVALID
    then begin
     write (chr(i + ord('A')), ': ');
     case GetDriveTypeEx(i) of
      EX_DRIVE_REMOVABLE:        Writeln ('Removable');
      EX_DRIVE_FIXED:                Writeln ('Harddisk');
      EX_DRIVE_REMOTE:                Writeln ('Network');
      EX_DRIVE_CDROM:                Writeln ('CDROM');
      EX_DRIVE_FLOPPY:                Writeln ('Floppy');
      EX_DRIVE_RAMDISK:                Writeln ('RAMdisk')
     end
    end
  end
{$ENDIF}
end.