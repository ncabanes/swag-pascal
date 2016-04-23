{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                 S.Perevoznik                     ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}

Unit NetFile;


Interface

Uses NetConv;





Const
  TA_NONE       =  $00;
  TA_READ       =  $01;
  TA_WRITE      =  $02;
  TA_OPEN       =  $04;
  TA_CREATE     =  $08;
  TA_DELETE     =  $10;
  TA_OWNERSHIP  =  $20;
  TA_SEARCH     =  $40;
  TA_MODIFY     =  $80;
  TA_ALL        =  $FF;

Const

 FA_NORMAL           = $00;
 FA_READ_ONLY        = $01;
 FA_HIDDEN           = $02;
 FA_SYSTEM           = $04;
 FA_EXECUTE_ONLY     = $08;
 FA_DIRECTORY        = $10;
 FA_NEEDS_ARCHIVED   = $20;
 FA_SHAREABLE        = $80;


Const

 FA_TRANSACTIONAL    = $10;
 FA_INDEXED          = $20;
 FA_READ_AUDIT       = $40;
 FA_WRITE_AUDIT      = $80;

Function CreateDirectory( DirectoryHandle    : byte;
                          DirectoryPath      : string;
                          MaximumRightsMask  : byte) : byte;


Function DeleteDirectory( DirectoryHandle    : byte;
                          DirectoryPath      : string) : byte;


Function RenameDirectory( DirectoryHandle  : byte;
                          DirectoryPath    : string;
                          NewDirectoryName : string):byte;


Function SetDirectoryInformation( DirectoryHandle : byte;
                                  DirectoryPath   : string;
                                  NewCreationDateAndTime : longint;
                                  NewOwnerObjectID : LongInt;
                                  NewMaximumRightsMask : byte) : byte;


Function GetDirectoryPath(DirectoryHandle     : byte;
                          Var directoryPath   : string) : byte;


Function GetVolumeNumber(VolumeName : string;
                         Var VolumeNumber : integer) : byte;


Function GetVolumeName(VolumeNumber : integer;
                       Var VolumeName  : string) : byte;



Function PurgeErasedFiles : byte;



Function RestoreErasedFile(DriveHandle : byte;
                           VolumeName  : string;
                           Var ErasedFileName ,
                               RestoredFileName : string) : byte;


Function GetDirectoryHandle(Drive : byte;
                            Var Handle : byte) : byte;








Function SaveDirectoryHandle(DirectoryHandle : byte;
                             Var SaveBuffer  : String) : byte;


Function RestoreDirectoryHandle(SaveBuffer : string;
                                 Var newDirectoryHandle : byte;
                                 Var EffectiveRigthMask : Byte) : byte;



Function SetFileInformation( driveHandle            : byte;
                             filePath               : string;
                             searchAttributes       : byte;
                             fileAttributes         : byte;
                             extendedFileAttributes : byte;
                             creationDate           : integer;
                             lastAccessDate         : integer;
                             lastUpdateDateAndTime  : LongInt;
                             lastArchiveDateAndTime : LongInt;
                             fileOwnerID            : LongInt) : byte;


Function GetExtendedFileAttributes(FilePath : string;
                                   Var Attr : byte) : byte;



Function SetExtendedFileAttributes(FilePath : string;
                                   attr : byte) : byte;



Function AllocPermanentDirectoryHandle(DirectoryHandle:Byte;
                                         DirectoryPath  :string;
                                         DriveLetter    :char;
                                         Var NewDirectoryHandle,
                                         EffectiveRigthMask : byte):byte;


Function AllocTemporaryDirectoryHandle(DirectoryHandle:Byte;
                                         DirectoryPath  :string;
                                         DriveLetter    :char;
                                         Var NewDirectoryHandle,
                                         EffectiveRigthMask : byte):byte;


Procedure DeallocateDirectoryHandle(DirectoryHandle : byte);



Implementation

Uses Dos;

Function CreateDirectory( DirectoryHandle    : byte;
                          DirectoryPath      : string;
                          MaximumRightsMask  : byte) : byte;

 var
   r : registers;
   SendPacket  : array[0..261] of byte;
   ReplyPacket : array[0..2] of byte;
   WordPtr     : ^word;
begin
    SendPacket[2] := 10;
    SendPacket[3] := directoryHandle;
    SendPacket[4] := maximumRightsMask;
    SendPacket[5] := Length(DirectoryPath);
    Move(DirectoryPath[1],SendPacket[6],Length(DirectoryPath));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(DirectoryPath)+4;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    CreateDirectory := r.AL;
end;

Function DeleteDirectory( DirectoryHandle    : byte;
                          DirectoryPath      : string) : byte;

 var
   r : registers;
   SendPacket  : array[0..261] of byte;
   ReplyPacket : array[0..2] of byte;
   WordPtr     : ^word;
begin
    SendPacket[2] := 11;
    SendPacket[3] := directoryHandle;
    SendPacket[4] := 0;
    SendPacket[5] := Length(DirectoryPath);
    Move(DirectoryPath[1],SendPacket[6],Length(DirectoryPath));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(DirectoryPath)+4;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    DeleteDirectory := r.AL;
end;

Function RenameDirectory( DirectoryHandle  : byte;
                          DirectoryPath    : string;
                          NewDirectoryName : string):byte;


 var
   r : registers;
   SendPacket  : array[0..275] of byte;
   ReplyPacket : array[0..2] of byte;
   WordPtr     : ^word;
begin
    SendPacket[2] := 15;
    SendPacket[3] := directoryHandle;
    SendPacket[4] := Length(DirectoryPath);
    Move(DirectoryPath[1],SendPacket[5],Length(DirectoryPath));
    SendPacket[Length(DirectoryPath)+5] := Length(NewDirectoryName);
    move(NewDirectoryName[1],SendPacket[6+Length(DirectoryPath)],Length(NewDirectoryName));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(DirectoryPath)+4 + Length(NewDirectoryName);
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    REnameDirectory := r.AL;
end;

Function SetDirectoryInformation( DirectoryHandle : byte;
                                  DirectoryPath   : string;
                                  NewCreationDateAndTime : longint;
                                  NewOwnerObjectID : LongInt;
                                  NewMaximumRightsMask : byte) : byte;

 var
   r : registers;
   SendPacket  : array[0..270] of byte;
   ReplyPacket : array[0..2] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := 25;
  SendPacket[3] := DirectoryHandle;
  move(NewCreationDateAndTime,SendPacket[4],4);
  NewOwnerObjectID := GetLong(addr(NewOwnerObjectID));
  move(NewOwnerObjectID,SendPacket[8],4);
  SendPacket[12] := newMaximumRightsMask;
  SendPacket[13] := Length(DirectoryPath);
  move(DirectoryPath[1],SendPacket[14],Length(DirectoryPath));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(DirectoryPath)+12;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    SetDirectoryInformation := r.AL;
end;

Function GetDirectoryPath(DirectoryHandle     : byte;
                          Var directoryPath   : string) : byte;

 var
   r : registers;
   SendPacket  : array[0..4] of byte;
   ReplyPacket : array[0..258] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := 1;
  SendPacket[3] := DirectoryHandle;
    WordPtr  := addr(SendPacket);
    WordPtr^ := 2;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 256;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    GetDirectoryPath := r.AL;
    if r.AL = 0 then
      begin
        move(ReplyPacket[3],DirectoryPath[1],ReplyPacket[2]);
        move(ReplyPacket[2],DirectoryPath[0],1);
      end;
end;

Function GetVolumeNumber(VolumeName : string;
                         Var VolumeNumber : integer) : byte;

 var
   r : registers;
   SendPacket  : array[0..19] of byte;
   ReplyPacket : array[0..3] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := 5;
  SendPacket[3] := Length(VolumeName);
  move(VolumeName[1],SendPacket[4],Length(VolumeName));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(VolumeName)+2;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 1;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    GetVolumeNumber := r.AL;
    if r.AL = 0 then
      VolumeNumber := ReplyPacket[2];
 end;


Function GetVolumeName(VolumeNumber : integer;
                       Var VolumeName  : string) : byte;


 var
   r : registers;
   SendPacket  : array[0..4] of byte;
   ReplyPacket : array[0..18] of byte;
   WordPtr     : ^word;

begin
   SendPacket[2] := 6;
   SendPacket[3] := VolumeNumber;
    WordPtr  := addr(SendPacket);
    WordPtr^ := 2;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 18;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    GetVolumeName := r.AL;
    if r.AL = 0 then
      begin
        move(ReplyPacket[3],VolumeName[1],ReplyPacket[2]);
        move(ReplyPacket[2],VolumeName[0],1);
      end;
end;

Function PurgeErasedFiles : byte;

 var
   r : registers;
   SendPacket  : array[0..2] of byte;
   ReplyPacket : array[0..1] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := $10;
    WordPtr  := addr(SendPacket);
    WordPtr^ := 1;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
    r.BX := r.DS;
    r.AH := $0E2;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    PurgeErasedFiles := r.AL;
 end;

Function RestoreErasedFile(DriveHandle : byte;
                           VolumeName  : string;
                           Var ErasedFileName ,
                               RestoredFileName : string) : byte;

 var
   r : registers;
   SendPacket  : array[0..21] of byte;
   ReplyPacket : array[0..32] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := $11;
  SendPacket[3] := DriveHandle;
  SendPacket[4] := Length(VolumeName);
  move(VolumeName[1],SendPacket[5],Length(VolumeName));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(VolumeName)+3;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 30;
    r.BX := r.DS;
    r.AH := 226;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    RestoreErasedFile := r.AL;
    if r.AL = 0 then
      begin
        move(ReplyPacket[2],ErasedFileName[1],15);
        ErasedFileName[0] := chr(15);
        move(ReplyPacket[17],RestoredFileName[1],15);
        RestoredFileName[0] := chr(15);
      end;
 end;

Function GetDirectoryHandle(Drive : byte;
                            Var Handle : byte) : byte;
var r : registers;
begin
  r.AH := $E9;
  r.AL := 0;
  r.DH := 0;
  r.DL := Drive;
  intr($21,r);
  Handle := r.AL;
  GetDirectoryHandle := r.AH;
end;

Function SaveDirectoryHandle(DirectoryHandle : byte;
                             Var SaveBuffer  : String) : byte;


 var
   r : registers;
   SendPacket  : array[0..4] of byte;
   ReplyPacket : array[0..16] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := 23;
  SendPacket[3] := DirectoryHandle;
    WordPtr  := addr(SendPacket);
    WordPtr^ := 2;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 14;
    r.BX := r.DS;
    r.AH := 226;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    SaveDirectoryHandle := r.AL;
    if r.AL = 0 then
      begin
        move(ReplyPacket[2],SaveBuffer,14);
      end;
 end;

Function RestoreDirectoryHandle(SaveBuffer : string;
                                 Var newDirectoryHandle : byte;
                                 Var EffectiveRigthMask : Byte) : byte;


 var
   r : registers;
   SendPacket  : array[0..19] of byte;
   ReplyPacket : array[0..4] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := 24;
  SendPacket[3] := Length(SaveBuffer);
  move(SaveBuffer[1],SendPacket[4],Length(SaveBuffer));
    WordPtr  := addr(SendPacket);
    WordPtr^ := 17;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 2;
    r.BX := r.DS;
    r.AH := 226;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    RestoreDirectoryHandle := r.AL;
    if r.AL = 0 then
      begin
        NewDirectoryHandle := ReplyPacket[2];
        EffectiveRigthMask := ReplyPacket[3];
      end;
 end;

Function SetFileInformation( driveHandle            : byte;
                             filePath               : string;
                             searchAttributes       : byte;
                             fileAttributes         : byte;
                             extendedFileAttributes : byte;
                             creationDate           : integer;
                             lastAccessDate         : integer;
                             lastUpdateDateAndTime  : LongInt;
                             lastArchiveDateAndTime : LongInt;
                             fileOwnerID            : LongInt) : byte;


 var
   r : registers;
   SendPacket  : array[0..339] of byte;
   ReplyPacket : array[0..2] of byte;
   WordPtr     : ^word;
   i           : integer;

begin
  SendPacket[2] := 16;
  SendPacket[3] := FileAttributes;
  SendPacket[4] := ExtendedFileAttributes;
  SendPacket[5] := 0;
  SendPacket[6] := 0;
  SendPacket[7] := 0;
  SendPacket[8] := 0;
  move(CreationDate,SendPacket[9],2);
  move(LastAccessDate,SendPacket[11],2);
  move(LastUpdateDateAndTime,SendPacket[13],4);
  FileOwnerID := GetLong(addr(FileOwnerID));
  move(FileOwnerID,SendPacket[17],4);
  move(lastArchiveDateAndTime,SendPacket[21],4);
  for i :=  25 to 80 do
    SendPacket[i] := 0;
  SendPacket[81] := DriveHandle;
  SendPacket[82] := searchAttributes;
  SendPacket[83] := Length(FilePath);
  move(FilePath[1],SendPacket[84],Length(FilePath));
    WordPtr  := addr(SendPacket);
    WordPtr^ := Length(FilePath)+ 82;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
    r.BX := r.DS;
    r.AH := 227;
    r.DS := SEG(SendPacket);
    r.SI := OFS(SendPacket);
    r.ES := SEG(ReplyPacket);
    r.DI := OFS(ReplyPacket);
    intr($21,r);
    r.DS := r.BX;
    SetFileInformation:= r.AL;
 end;

Function GetExtendedFileAttributes(FilePath : string;
                                   Var Attr : byte) : byte;


var r : registers;
begin
  FilePath[Length(FilePath)+1] := chr(0);
  r.BX := r.DS;
  r.AH := $B6;
  r.AL := 0;
  r.DS := SEG(FilePath[1]);
  r.DX := OFS(FilePath[1]);
  intr($21,r);
  r.DS := r.BX;
  Attr := r.CL;
  if (r.Flags and FCARRY ) = 0 then
  GetExtendedFileAttributes := 0 else
  GetExtendedFileAttributes := r.AL;
end;


Function SetExtendedFileAttributes(FilePath : string;
                                   attr : byte) : byte;


var r : registers;
begin
  FilePath[Length(FilePath)+1] := chr(0);
  r.BX := r.DS;
  r.AH := $B6;
  r.AL := $01;
  r.CL := Attr;
  r.DS := SEG(FilePath[1]);
  r.DX := OFS(FilePath[1]);
  intr($21,r);
  r.DS := r.BX;
  if (r.Flags and FCARRY ) = 0 then
  SetExtendedFileAttributes := 0 else
  SetExtendedFileAttributes := r.AL;
end;

Function AllocPermanentDirectoryHandle(DirectoryHandle:Byte;
                                         DirectoryPath  :string;
                                         DriveLetter    :char;
                                         Var NewDirectoryHandle,
                                         EffectiveRigthMask : byte):byte;


Var
  r : registers;
  SendPacket  : array[0..261] of byte;
  ReplyPacket : array[0..004] of byte;
  WordPtr     : ^Word;
begin
  SendPacket[2] := $12;
  SendPacket[3] := DirectoryHandle;
  SendPacket[4] := Ord(DriveLetter);
  move(DirectoryPath,SendPacket[5],Length(DirectoryPath)+1);
  WordPtr  := addr(SendPacket);
  WordPtr^ := Length(DirectoryPath)+4;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 2;
  r.BX := r.DS;
  r.AH := $E2;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  AllocPermanentDirectoryHandle := r.AL;
  if r.AL = 0 then
    begin
      NewDirectoryHandle := ReplyPacket[2];
      EffectiveRigthMask := ReplyPacket[3];
    end;
end;



Function AllocTemporaryDirectoryHandle(DirectoryHandle:Byte;
                                         DirectoryPath  :string;
                                         DriveLetter    :char;
                                         Var NewDirectoryHandle,
                                         EffectiveRigthMask : byte):byte;

Var
  r : registers;
  SendPacket  : array[0..261] of byte;
  ReplyPacket : array[0..004] of byte;
  WordPtr     : ^Word;
begin
  SendPacket[2] := $13;
  SendPacket[3] := DirectoryHandle;
  SendPacket[4] := Ord(DriveLetter);
  move(DirectoryPath,SendPacket[5],Length(DirectoryPath)+1);
  WordPtr  := addr(SendPacket);
  WordPtr^ := Length(DirectoryPath)+4;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 2;
  r.BX := r.DS;
  r.AH := $E2;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  AllocTemporaryDirectoryHandle := r.AL;
  if r.AL = 0 then
    begin
      NewDirectoryHandle := ReplyPacket[2];
      EffectiveRigthMask := ReplyPacket[3];
    end;
end;

Procedure DeallocateDirectoryHandle(DirectoryHandle : byte);

Var
  r : registers;
  SendPacket  : array[0..4] of byte;
  ReplyPacket : array[0..2] of byte;
  WordPtr     : ^Word;
begin
  SendPacket[2] := $14;
  SendPacket[3] := DirectoryHandle;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 2;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 0;
  r.BX := r.DS;
  r.AH := $E2;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
end;


End.
