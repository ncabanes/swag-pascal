(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0111.PAS
  Description: Disk free space
  Author: RAY BERNARD
  Date: 02-21-96  21:03
*)

program FREE;  { show free disk space and other info }
{$M 32000,0,100000}


{$IFDEF Windows}
  This program is intended for DOS real mode only!
{$ELSE}
  {$IFDEF DPMI}
    Compile for real mode so program does not need RTM.EXE and DPMI16BI.OVL!
  {$ENDIF}
{$ENDIF}

   {-------------------------------------------------------------------------}
   {                                                                         }
   {                              FREE.PAS                                   }
   {                              ========                                   }
   {     Display drive information and handle phantom floppy drives so       }
   {     that you don't get the annoying 'insert disk in drive' message.     }
   {     That means when a non-active phantom floppy drive letter is         }
   {     listed on the command line, list it's mapped drive and show the     }
   {     info for the mapped drive, like this:                               }
   {                                                                         }
   {             Free A:   ----------- - same drive as B                     }
   {             Free B:             0 - drive not ready                     }
   {                                                                         }
   {     See the program Usage display (FREE /?) for more information.       }
   {                                                                         }
   {-------------------------------------------------------------------------}
   {           This program uses the Object Professional library by          }
   {                          TurboPower Software.                           }
   {-------------------------------------------------------------------------}
   {   (c) 1995 by Ray Bernard Consulting and Design. All Rights Reserved.   }
   {   Portions (c) 1995 by TurboPower Software. All Rights Reserved.        }
   {-------------------------------------------------------------------------}


   {-------------------------------------------------------------------------}
   {  ABOUT THIS PROGRAM                                                     }
   {  ==================                                                     }
   {  We developed this program to show drive information because it seemed  }
   {  like we were always adding new drives to our computers, then changing  }
   {  around the drive contents to optimize their usage. Most of the 1 gig   }
   {  drives are partitioned into 4 drives for maximum utilization (to make  }
   {  16K sectors instead of 32K sectors). Whenever we would rearrange       }
   {  drive contents, it was helpful to have a utility that would identify   }
   {  all of a computers local and networked drives, and display the drive   }
   {  volume label and type of drive.                                        }
   {                                                                         }
   {  Now that most of the kinks are worked out of this program, it seemed   }
   {  fitting to upload the source code to TurboPower's BBS and CIS forum,   }
   {  in case others would find it handy.                                    }
   {                                                                         }
   {  This program is provided "AS-IS" without any warranty. Although it is  }
   {  copyrighted, free use may be made of the source code by any registered }
   {  TurboPower software customers. Free use may be made of the compiled    }
   {  version regardless of TurboPower customer status.                      }
   {                                                                         }
   {  -Ray Bernard                                                           }
   {   Ray Bernard Consulting and Design      CIS: [73354,3325]              }
   {   June 17, 995                                                          }
   {-------------------------------------------------------------------------}

Uses
  DOS,
  OpDOS,
  OpCrt,
  OpString,
  OpInline;


type
  TPhantomRec = record
                  DrvLtr,
                  MapDrvLtr : Char;
                end;

var
  DriveList      : String[26];  { drive letters extracted from command line }
  HighDriveSpace,
  LowDriveSpace  : LongInt;     { to hold LOW and HIGH options space values }
  ReportOptions  : Word;        { set per command line options }
  PhantomList    : array['A'..'Z'] of TPhantomRec; { phantom drive global list }

const
 { Report Options for ShowFreeSpaceAllDrives }

  ShowAtOrAbove   = $00000001;   { /H }
  ShowAtOrBelow   = $00000002;   { /L }
  ShowAndPause    = $00000004;   { /P }
  ShowAllDrives   = $00000008;   { /A }
  ShowSize        = $00000010;   { /C }
  ShowType        = $00000020;   { /T }
  ShowVolumeLabel = $00000040;   { /V }
  ShowFloppies    = $00000080;   { /F }

  MsPerSec       = 1000;
  Kbyte          = 1024;
  Megabyte       = 1024*Kbyte;
  Gigabyte       = 1024*Megabyte;
  FreeSpacePad   = 11;   { pad free space number string to 11 spaces }

 { global declarations }
  DriveLetterSet     : set of Char = ['A'..'Z'];  { for parameter checking }
  CommandDelimiters  : set of char = ['-','/'];   { for parameter checking }

  PauseDelaySecs     : Word = 5;  { default seconds to pause after display }
  Debug              : Boolean = True;

  DosVer300 = $0300; {for DOS 3.00}
  DosVer320 = $0314; {for DOS 3.20, $14 = 20}

procedure ShowUsageAndHalt;
{-Show the usage information for this program }
begin
  HighVideo;
  Writeln('FREE.EXE - Display drive free space and other information.');
  LowVideo;
  Writeln('(c) 1995 by Ray Bernard Consulting and Design, CompuServe: 73354,3325.');
  Writeln('Portions (c) 1987-1995 by TurboPower Software. All Rights Reserved.');
  Writeln('FREE.EXE is "freeware", distributed "as is" and without warranty.');
  Writeln;
  HighVideo;
  Write('Usage: ');
  LowVideo;
  Writeln('FREE [Drives] [Options]');
  Writeln;
  HighVideo;
  Write('Drives: ');
  LowVideo;
  Writeln('One or more drive letters, with or without spaces');
  Writeln('separating them. If no drives are listed the default drive is assumed.');
  Writeln;
  HighVideo;
  Write('Options: ');
  LowVideo;
  Writeln('One or more options, separated by spaces. You may');
  Writeln('also use the first letter of the option, such as /A for /ALL.');
  Writeln('/ALL       show all drives (A and B)');
  Writeln('/FLOPPY    show all drives including A and B');
  Writeln('/HIGH n    all drives with n or more free space');
  Writeln('/LOW n     all drives with n or less free space');
  Writeln('/PAUSE     pause 5 seconds after display or until key pressed');
  Writeln('/PAUSE n   pause n seconds after the display or until key pressed');
  Writeln('/SIZE      drive size (formatted capacity)');
  Writeln('/TYPE      type of drive');
  Writeln('/VOLUME    show volume label');
  Writeln;
  Write('Press a key to continue . . .');
  if ReadKey <> #0 then
   {do nothing} ;
  ClrScr;
  Writeln('FREE.EXE - Usage information, page 2.');
  Writeln;
  Writeln('High and Low free space amounts can be specified in bytes, kbytes, ');
  Writeln('megabytes or gigabytes using (K, M or G), with or without commas to separate');
  Writeln('thousands. Example: 52,428,800 or 52428800 or 50M for fifty megabytes.');
  Writeln;
  Writeln('EXAMPLE PROGRAM OUTPUT:');
  Writeln;
  Writeln('C:>FREE /f /t /v /s');
  Writeln('Free A:             0 (Size 0.0MB) - drive not ready');
  Writeln('Free B:             0 (Size 0.0MB) - drive not ready');
  Writeln('Free C:    48,283,648 (Size 515MB) - local hard drive  IDE#1_V1');
  Writeln('Free D:    47,218,688 (Size 251MB) - local hard drive  IDE#2_V1');
  Writeln('Free E:   162,906,112 (Size 519MB) - local hard drive  SCSI#1_V1');
  Writeln('Free F:    72,351,744 (Size 257MB) - local hard drive  IDE#1_V3');
  Writeln('Free G:    34,570,240 (Size 257MB) - local hard drive  IDE#1_V4');
  Writeln('Free H:    35,274,752 (Size 251MB) - local hard drive  IDE#2_V2');
  Writeln('Free K:   203,807,616 (Size   2GB) - remote or network drive  AT_SERV_C');
  Writeln('Free O:   ----------- - same drive as B');
  Writeln('Free N:    34,570,240 (Size 257MB) - logical SUBST or ASSIGN on G  IDE#1_V4');
  Writeln('Free R:             0 (Size 127MB) - CD-ROM Drive      MFCDISC');
  Writeln;
  Halt;
end;

function IsDriveLocal(Drive : Byte) : Boolean;
{ -Returns TRUE if drive is local.
   Drive is the drive number (0 for default, 1 for A:, 2 for B: ...).
   NOTE: If DOS 3 or greater is not loaded, it is assumed that the Drive is
   local (since DOS has no standard way of knowing under DOS 2).
   IsDriveLocal is taken from SHARE.PAS, a unit supplied with TurboPower's
   B-Tree Filer. }
var
  Regs : Registers;
begin
  if OpDos.DosVersion >= DosVer300 then   {DOS 3 or greater required}
    begin  
      with Regs do
        begin
          AX := $4409;
          BL := Drive;
          MsDos(Regs);
          if Odd(Flags) then
            IsDriveLocal := True  {if error, then assume drive is local}
          else
            {the drive is local if bit 12 of DX is clear}
            IsDriveLocal := not FlagIsSet(DX,$1000);
        end;
    end
  else
    IsDriveLocal := True;     {assume it's local for DOS < 3}
end;


function DrvNumToLtr(DriveNum : Byte) : Char;
{-Return Drive Letter for 1-based Drive Number (A=1, B=2, etc.)}
begin
  DrvNumToLtr := Chr(DriveNum+64);
end;

function DrvLtrToNum(DriveLetter : Char) : Byte;
{-Return 1-based Drive Number (A=1, B=2, etc.) for DriveLetter}
begin
  DrvLtrToNum := Ord(Upcase(DriveLetter))-64;
end;


function IsDrivePhantom(DriveLetter : Char; var MappedTo : Char) : Boolean;
{-Return True if Phantom drive and pass back original drive mapped to. }
{ Will recognize floppy drives drives reassigned using DRIVER.SYS.     }
var
  Regs : Registers;
  IsPhantom : Boolean;
  DriveNum : Byte;
begin
  IsPhantom := False;
  DriveNum := DrvLtrToNum(DriveLetter);
  if OpDos.DosVersion > DosVer320 then
    begin  {DOS 3.2 or greater required}
      with Regs do
        begin
          AX := $440E;
          BL := DriveNum;
          MsDos(Regs);
          if Odd(Flags) then
            begin
              IsPhantom := False;  {if error, then assume drive not phantom }
            end
          else
            begin
              if AL = 0 then       {the drive is not phantom drive if AL = 0}
                IsPhantom := False
              else
                begin
                  IsPhantom := (AL <> DriveNum);
                  if IsPhantom then
                    MappedTo := DrvNumToLtr(AL);
                end;
            end;
        end;
    end;
  IsDrivePhantom := IsPhantom;
end; { IsDrivePhantom }


function IsListedAsPhantom(DriveLetter : Char) : Boolean;
{-Refer to this program's global PhantomList variable }
begin
  IsListedAsPhantom := PhantomList[DriveLetter].DrvLtr = DriveLetter;
end;


procedure RestoreOutputRedirection;
{-Return Write and Writeln to Standard I/O to allow }
{ redirection of program output to file or printer  }
begin
  { undo OpCrt's assignment of Output to CRT }
  Close(Output);
  Assign(Output,'');
  Rewrite(Output);
end;


function NumFloppies : Byte;
{-Return the number of floppy drives installed per DOS "List of Lists" }
var
  Equipment : Byte;
begin
  Equipment := mem[$0040:$0010];
  if (equipment and $0001) = 1 then
    NumFloppies := ((Equipment shr 6) and $0003)+1
  else
    NumFloppies := 0;
end;


procedure HaltWithMessage(Message : String);
{-Display Message and halt }
begin
  Writeln(Message);
  Halt;
end;


function InsertCommas(S : String) : String;
{-Add commas to string for thousands. Work from the end  }
{ of the string exit on the first space encountered, to  }
{ be able to handle strings like: 'TOTAL: 1,000'.        }
var
  I : Word;
  Len : Word;
begin
  Len := Length(S);
  I := Len;
  while I > 1 do begin
    if (Len+1-I) mod 3 = 0 then
      if S[I-1] = ' ' then
        Break
      else
        insert(',', S, I);
    dec(I);
  end;
  InsertCommas := S;
end;


procedure GetAndSavePhantomInfo(DriveLetter : Char);
{-If DriveLetter is a Phantom drive, set data in PhantomList }
var
  MapCh : Char;
begin
  if IsDrivePhantom(DriveLetter,MapCh) then
    with PhantomList[DriveLetter] do
      begin
        DrvLtr := DriveLetter;
        MapDrvLtr := MapCh;
      end;
end;

function DiskTypeString(DriveLetter : Char) : String;
{-Return the disk class information as a string with leading space & dash. }
{ Checks the global variable PhantomList for phantom drive info, and exit  }
{ for phantom drive without calling GetDiskClass to avoid disk hit.        }
var
  DiskType   : DiskClass;
  DriveNum   : Byte;
  SubDriveCh : Char;
  DTStr      : String;
begin
  DriveNum := DrvLtrToNum(DriveLetter);
  if IsListedAsPhantom(DriveLetter) then
    begin
      DiskTypeString := ' - same drive as '+PhantomList[DriveLetter].MapDrvLtr;
      Exit;
    end;
  DiskType := GetDiskClass(DriveLetter,SubDriveCh);
  case DiskType of
    Floppy360    : DTStr := ' - 360KB,  5.25" diskette';
    Floppy720    : DTStr := ' - 720KB,  3.50" diskette';
    Floppy12     : DTStr := ' - 1.2MB,  5.25" diskette';
    Floppy144    : DTStr := ' - 1.44MB, 3.50" diskette';
    OtherFloppy  : DTStr := ' - unlised diskette type';
    Bernoulli    : DTStr := ' - Bernouli drive';
    HardDisk     : DTStr := ' - local hard drive';
    RamDisk      : DTStr := ' - RAM drive';
    SubstDrive   : DTStr := ' - logical SUBST or ASSIGN on '+
                                       SubDriveCh;
    UnknownDisk  : DTStr := ' - unlisted disk type';
    InvalidDrive : if not IsDriveLocal(DriveNum) then
                     DTStr := ' - remote or network drive'
                   else
                     DTStr := ' - drive not ready';
    NovellDrive  : DTStr := ' - Novelle network drive';
    CDRomDisk    : DTStr := ' - CD-ROM drive';
  else
    { Trap for GetDiskClass update to include new types}
    { before this routine is revised, and ensure that  }
    { a function result is always assigned.            }
    DTStr := 'unrecognized disk type';
  end; {case}
  DiskTypeString := DTStr;
end;



function DiskCapacity(DriveLetter : char) : longint;
{-Return the disk capacity in number of bytes for the specified drive. }
var
  DriveNum          : byte;
  BytesPerCluster,
  AvailClusters,
  TotalClusters,
  SectorsPerCluster,
  BytesPerSector    : word;
  TotalBytes        : longint;
begin
  DiskCapacity := 0;
  if IsListedAsPhantom(DriveLetter) then
    Exit;
  DriveNum := DrvLtrToNum(DriveLetter);
  if GetDiskInfo(DriveNum,AvailClusters,TotalClusters,
                 BytesPerSector,SectorsPerCluster) then
    begin
      BytesPerCluster := LongInt(SectorsPerCluster) * BytesPerSector;
      DiskCapacity := LongInt(TotalClusters) * BytesPerCluster;
    end;
end; { DiskCapacity }


function DiskCapacityString(DriveLetter : Char) : String;
{-Return disk capacity info in megabytes or gigabytes formatted with commas }
var
  DiskCap : LongInt;
  TempStr : String;
begin
  DiskCap := DiskCapacity(DriveLetter);
  if DiskCap >= Gigabyte then
    TempStr := Long2Str(DiskCap div Gigabyte)+'GB'
  else
    if DiskCap > 9*Megabyte then
      TempStr := InsertCommas(Long2Str(DiskCap div Megabyte))+'MB'
    else
      TempStr := Long2Str(DiskCap div Megabyte)+'.'+
           copy(Long2Str(DiskCap mod Megabyte),1,1)+'MB';
  DiskCapacityString := TempStr;
end;

function AvailableDriveSpace(DriveLetter : char) : longint;
{-Return the number of bytes free on specified drive}
var
  DriveNum            : byte;
  BytesPerCluster,
  AvailClusters,
  TotalClusters,
  SectorsPerCluster,
  BytesPerSector      : word;
  TotalBytes          : longint;
begin
  AvailableDriveSpace := 0;
  if IsListedAsPhantom(DriveLetter) then
    Exit;
  DriveNum := DrvLtrToNum(DriveLetter);
  if GetDiskInfo(DriveNum,AvailClusters,TotalClusters,
                 BytesPerSector,SectorsPerCluster) then
    begin
      BytesPerCluster := LongInt(SectorsPerCluster) * BytesPerSector;
      AvailableDriveSpace := LongInt(AvailClusters) * BytesPerCluster;
    end;
end; { AvailableDriveSpace }


function DriveInfoString(DriveLetter : Char) : String;
{-Return the formatted drive information for DriveLetter.  }
{ Use global variable ReportOptions to determine what data }
{ should be inlcuded in returned string. Return a nul      }
{ string if the drive's infor should not be displayed      }
{ per high or low options.                                 }
var
  N  : Byte;
  InfoStr : String;
  ProcResult : Word;
  VolumeStr : VolumeNameStr;
  FreeSpace : LongInt;
  ShowThisDrive : Boolean;
const
  SpacePadWidth = 13;
begin
  InfoStr := 'Free '+DriveLetter+': ';
  if not IsListedAsPhantom(DriveLetter) then
    begin
      FreeSpace := AvailableDriveSpace(DriveLetter);
      InfoStr := InfoStr +
                  LeftPad(InsertCommas(Long2Str(FreeSpace)),SpacePadWidth);
    end
  else
    begin
      InfoStr := InfoStr + '  -----------';
      FreeSpace := 0;
    end;
  if FlagIsSet(ReportOptions,ShowSize) then
    if not IsListedAsPhantom(DriveLetter) then
      InfoStr := InfoStr + ' (Size '+ DiskCapacityString(DriveLetter) + ')'
    else
      InfoStr := InfoStr + ' (Size -----)';
  if FlagIsSet(ReportOptions,ShowType) then
    InfoStr := InfoStr + DiskTypeString(DriveLetter);
  if FlagIsSet(ReportOptions,ShowVolumeLabel) then
    if not IsListedAsPhantom(DriveLetter) then
      begin
        ProcResult := GetVolumeLabel(DriveLetter,VolumeStr);
        if ProcResult = 0 then
          if Length(VolumeStr) > 0 then
            InfoStr := InfoStr + '  '+VolumeStr
          else
            InfoStr := InfoStr + '  no label';
      end;

 { handle high and low disk space options }
  if FlagIsSet(ReportOptions,ShowAtOrAbove) or
     FlagIsSet(ReportOptions,ShowAtOrBelow) then
    begin  { allow both settings combined }
      ShowThisDrive := ( (FlagIsSet(ReportOptions,ShowAtOrAbove) and
                             (FreeSpace >= HighDriveSpace)) or
                         (FlagIsSet(ReportOptions,ShowAtOrBelow) and
                             (FreeSpace <= LowDriveSpace)) );
    end
  else
    ShowThisDrive := True;
  if not ShowThisDrive then
    DriveInfoString := ''
  else
    DriveInfoString := InfoStr;
end;


procedure DisplayDriveInfoString(DriveLetter : Char);
{-Writeln DriveInfoString's result for DriveLetter if not a nul string }
var
  DisplayStr : String;
begin
  DisplayStr := DriveInfoString(DriveLetter);
  if Length(DisplayStr) > 0 then
    Writeln(DisplayStr);
end;

procedure DisplayDrivesInfo;
{-Display the info for all drives in DriveList, checking ReportOptions   }
{ for display settings.                                                  }
{ Before calling DriveInfoString, make all calls to GetPhantomInfo.      }
{ DriveInfoString's call to GetDiskInfo will cause a disk in each drive, }
{ making any phantom drive current and thus undetectable by our methods. }
{ If a single drive was specified on the command line, and it turns out  }
{ to be a phantom drive, show the drive info for the mapped drive, too.  }
var
  N : Byte;
begin
 { build global list of phantom drive maps }
  for N := 1 to Length(DriveList) do
    GetAndSavePhantomInfo(DriveList[N]);

 { now get and display drive information }
 if (Length(DriveList) = 1) then
   begin  { hangle single specified phantom drive }
     DisplayDriveInfoString(DriveList[1]);
     if IsListedAsPhantom(DriveList[1]) then
       DisplayDriveInfoString(PhantomList[DriveList[1]].MapDrvLtr);
   end
 else    { show drive info for all listed drives }
  for N := 1 to Length(DriveList) do
    DisplayDriveInfoString(DriveList[N]);
 { pause if option enabled }
  if FlagIsSet(ReportOptions,ShowAndPause) then
    Delay(PauseDelaySecs*MsPerSec);
end;



function AllValidDrivesList : String;
{-Return a string containing drive letters of all valid drives}
var
  DriveLetter : Char;
  TempDrivesList : String;
  FirstDrive : Char;
const
  LastDrive = 'Z';
begin
  TempDrivesList := '';
  if FlagIsSet(ReportOptions,ShowFloppies) then
    FirstDrive := 'A'
  else
    FirstDrive := 'C';
  for DriveLetter := FirstDrive to LastDrive do
    if ValidDrive(DriveLetter) then
      TempDrivesList := TempDrivesList + DriveLetter
    else
  { primary floppies show invalid when last access was via the the Phantom }
  { drive, so check DOS equipment list for floppies by calling NumFloppies }
      if (DriveLetter in ['A','B']) and (NumFloppies > 0) then
        TempDrivesList := TempDrivesList + DriveLetter;
  AllValidDrivesList := TempDrivesList;
end;


function StripCommas(S : String) : String;
{-Remove any commas from S and return as result }
var
  LenS : Byte absolute S;
  P : Byte;
begin
  for P := LenS downto 1 do
    if S[P] = ',' then
      Delete(S,P,1);
  StripCommas := S;
end;

procedure ParseCommandLine;
{-Parse command line to get drive list and options }
{ First, check to see if a parameter is a drive letter or list of them.   }
{ If so, put the letter or letters in the drive list.                     }
{ If not a drive letter, the parameter should be a command option.        }
{ Process the command option, or ignore if not a valid option (could be   }
{ an option parameter or an invalid option).                              }
var
  ChPos,Count   : Byte;
  TempDelaySecs : Word;
  Param,Param2  : String;
  ParamLen      : Byte absolute Param;
  Param2Len     : Byte absolute Param2;
  HLChar        : Char; { /HIGH, /LOW: K = Kbytes, M = Megabytes, G = Gig }
const
  HLCharSet     : set of Char = ['G','K','M'];
begin
 { initialize variables }
  FillChar(PhantomList, SizeOf(PhantomList), #0);
  ReportOptions := 0;
  HighDriveSpace := 0;
  LowDriveSpace := 0;
  for Count := 1 to ParamCount do
    begin
      Param := StUpCase(ParamStr(Count));
      if Param[1] in DriveLetterSet then
        begin
          for ChPos := 1 to ParamLen do  { for drives listed w/no spacing }
            if Pos(Param[ChPos],DriveList) = 0 then  { correct user error }
              if ValidDrive(Param[ChPos]) then
                DriveList := DriveList + Param[ChPos]
              else
  { primary floppies show invalid when last access was via the the Phantom }
  { drive, so check DOS equipment list for floppies by calling NumFloppies }
                if (Param[ChPos] in ['A','B']) and (NumFloppies > 0) then
                  DriveList := DriveList + Param[ChPos];
        end
      else
       { 1st char should be command delimiter }
       { 2nd char should indicate option      }
        if Param[1] in CommandDelimiters then
          begin
            case Param[2] of
              'A' : SetFlag(ReportOptions,ShowAllDrives);
              'F' : SetFlag(ReportOptions,ShowFloppies);
              'H' : begin
                      HLChar := #255;  { to check if set }
                      if ParamCount <= Count then
                        HaltWithMessage('specify drive space with /HIGH option');
                      { check for G, K or M }
                      Param2 := StUpCase(ParamStr(Count+1));
                      if Param2[Param2Len] in HLCharSet then
                        begin
                          HLChar := Param2[Param2Len];
                          Delete(Param2,Param2Len,1);
                        end;
                      { validate free space number }
                      if not Str2Long(StripCommas(Param2),HighDriveSpace) then
                        HaltWithMessage('specify amount of drive space with /HIGH option')
                      else  { handle G, K or M }
                        if HLChar <> #255 then
                          begin
                            case HLChar of
                              'G' : HighDriveSpace := HighDriveSpace * Gigabyte;
                              'K' : HighDriveSpace := HighDriveSpace * Kbyte;
                              'M' : HighDriveSpace := HighDriveSpace * Megabyte;
                            end; {case}
                          end;
                      SetFlag(ReportOptions,ShowAtOrAbove);
                      SetFlag(ReportOptions,ShowAllDrives);
                    end;
              'L' : begin
                      HLChar := #255;  { to check if set }
                      if ParamCount <= Count then
                        HaltWithMessage('specify drive space with /LOW option');
                      { check for G, K or M }
                      Param2 := StUpCase(ParamStr(Count+1));
                      if Param2[Param2Len] in HLCharSet then
                        begin
                          HLChar := Param2[Param2Len];
                          Delete(Param2,Param2Len,1);
                        end;
                      { validate free space number }
                      if not Str2Long(StripCommas(Param2),LowDriveSpace) then
                        HaltWithMessage('specify amount of drive space with /LOW option')
                      else  { handle G, K or M }
                        if HLChar <> #255 then
                          begin
                            case HLChar of
                              'G' : LowDriveSpace := LowDriveSpace * Gigabyte;
                              'K' : LowDriveSpace := LowDriveSpace * Kbyte;
                              'M' : LowDriveSpace := LowDriveSpace * Megabyte;
                            end; {case}
                          end;
                      SetFlag(ReportOptions,ShowAtOrBelow);
                      SetFlag(ReportOptions,ShowAllDrives);
                    end;
              'P' : begin
                      SetFlag(ReportOptions,ShowAndPause);
                      if Count < ParamCount then  { next param could be delay }
                        if Str2Word(ParamStr(Count+1),TempDelaySecs) then
                            PauseDelaySecs := TempDelaySecs;
                    end;
              'S' : SetFlag(ReportOptions,ShowSize);
              'T' : SetFlag(ReportOptions,ShowType);
              'V' : SetFlag(ReportOptions,ShowVolumeLabel);
              '?' : ShowUsageAndHalt;
            end; { case }
          end;  { if Param[1] in CommandDelimiters }
    end; { for Count := 1 to ParamCount }
  if FlagIsSet(ReportOptions,ShowAllDrives) or
     FlagIsSet(ReportOptions,ShowFloppies) then
       DriveList := AllValidDrivesList;
end; { ParseCommandLine }


begin { FREE }
  RestoreOutputRedirection;
  if ParamCount > 0 then
    ParseCommandLine;
  if Length(DriveList) = 0 then  { if no drives on command line }
    DriveList := DefaultDrive;   { default to current the drive }
  DisplayDrivesInfo;
end. { FREE }

