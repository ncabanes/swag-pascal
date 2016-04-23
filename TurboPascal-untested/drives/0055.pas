{$R-,S-,I-,B-,F-,O+}

{---------------------------------------------------------
 BIOS disk I/O routines for floppy drives. Supports DOS
 real mode, DOS protected mode, and Windows. Requires
 TP6, TPW, or BP7.

 All functions are for floppy disks only; no hard drives.

 See the individual types and functions in the interface of
 this unit for more information. See the FMT.PAS sample
 program for an example of formatting disks.

 For status code definitions, see the implementation of
 function GetStatusStr.

 ---------------------------------------------------------
 Based on a unit provided by Henning Jorgensen of Denmark.
 Modified and cleaned up by TurboPower Software for pmode
 and Windows operation.

 TurboPower Software
 P.O. Box 49009
 Colorado Springs, CO 80949-9009

 CompuServe: 76004,2611

 Version 1.0  10/25/93
 Version 1.1  10/29/93
   fix a dumb bug in the MediaArray check
 ---------------------------------------------------------}

unit BDisk;
  {-BIOS disk I/O routines for floppy drives}

interface

const
  MaxRetries : Byte = 3;          {Number of automatic retries for
                                   read, write, verify, format}

type
  DriveNumber = 0..7;             {Acceptable floppy drive numbers}
                                  {Generally, 0 = A, 1 = B}

  DriveType = 0..4;               {Floppy drive or disk types}
                                  {0 = unknown or error
                                   1 = 360K
                                   2 = 1.2M
                                   3 = 720K
                                   4 = 1.44M}

  VolumeStr = String[11];         {String for volume labels}

  FormatAbortFunc =               {Prototype for format abort func}
    function (Track : Byte;       {Track number being formatted, 0..MaxTrack}
              MaxTrack : Byte;    {Maximum track number for this format}
              Kind : Byte         {0 = format beginning}
                                  {1 = formatting Track}
                                  {2 = verifying Track}
                                  {3 = writing boot and FAT}
                                  {4 = format ending, Track = format status}
              ) : Boolean;        {Return True to abort format}


procedure ResetDrive(Drive : DriveNumber);
  {-Reset drive system (function $00). Call after any other
    disk function fails}


function GetDiskStatus : Byte;
  {-Get status of last int $13 operation (function $01)}


function GetStatusStr(ErrNum : Byte) : String;
  {-Return message string for any of the status codes used by
    this unit.}


function GetDriveType(Drive : DriveNumber) : DriveType;
  {-Get drive type (function $08). Note that this returns the
    type of the *drive*, not the type of the diskette in it.
    GetDriveType returns 0 for an invalid drive.}


function AllocBuffer(var P : Pointer; Size : Word) : Boolean;
  {-Allocate a buffer useable in real and protected mode.
    Buffers passed to ReadSectors and WriteSectors in pmode
    *MUST* be allocated by using this function. AllocBuffer returns
    False if sufficient memory is not available. P is also set to
    nil in that case.}


procedure FreeBuffer(P : Pointer; Size : Word);
  {-Free buffer allocated by AllocBuffer. Size must match the
    size originally passed to AllocBuffer. FreeBuffer does
    nothing if P is nil.}


function ReadSectors(Drive : DriveNumber;
                     Track, Side, SSect, NSect : Byte;
                     var Buffer) : Byte;
  {-Read absolute disk sectors (function $02). Track, Side,
    and SSect specify the location of the first sector to
    read. NSect is the number of sectors to read. Buffer
    must be large enough to hold these sectors. ReadSectors
    returns a status code, 0 for success.}


function WriteSectors(Drive : DriveNumber;
                      Track, Side, SSect, NSect : Byte;
                      var Buffer) : Byte;
  {-Write absolute disk sectors (function $03). Track, Side,
    and SSect specify the location of the first sector to
    write. NSect is the number of sectors to write. Buffer
    must contain all the data to write. WriteSectors
    returns a status code, 0 for success.}


function VerifySectors(Drive : DriveNumber;
                       Track, Side, SSect, NSect : Byte) : Byte;
  {-Verify absolute disk sectors (function $04). This
    tests a computed CRC with the CRC stored along with the
    sector. Track, Side, and SSect specify the location of
    the first sector to verify. NSect is the number of
    sectors to verify. VerifySectors returns a status code,
    0 for success. Don't call VerifySectors on PC/XTs and
    PC/ATs with a BIOS from 1985. It will overwrite the
    stack.}


function FormatDisk(Drive : DriveNumber; DType : DriveType;
                    Verify : Boolean; MaxBadSects : Byte;
                    VLabel : VolumeStr;
                    FAF : FormatAbortFunc) : Byte;
  {-Format drive that contains a disk of type DType. If Verify
    is True, each track is verified after it is formatted.
    MaxBadSects specifies the number of sectors that can be
    bad before the format is halted. If VLabel is not an
    empty string, FormatDisk puts the BIOS-level volume
    label onto the diskette. It does *not* add a DOS-level
    volume label. FAF is a user function hook that can be
    used to display status during the format, and to abort
    the format if the user so chooses. Parameters passed to
    this function are described in FormatAbortFunc above.
    FormatDisk also writes a boot sector and empty File
    Allocation Tables for the disk. FormatDisk returns a
    status code, 0 for success.}


function EmptyAbortFunc(Track : Byte; MaxTrack : Byte; Kind : Byte) : Boolean;
  {-Do-nothing abort function for FormatDisk}

  {========================================================================}

implementation

uses
{$IFDEF DPMI}
  WinApi,
  Dos;
  {$DEFINE pmode}
{$ELSE}
{$IFDEF Windows}
  WinApi,
  WinDos;
  {$DEFINE pmode}
{$ELSE}
  Dos;
  {$UNDEF pmode}
{$ENDIF}
{$ENDIF}

{$IFDEF Windows}
type
  Registers = TRegisters;
  DateTime = TDateTime;
{$ENDIF}

type
  DiskRec =
    record
      SSZ : Byte;                 {Sector size}
      SPT : Byte;                 {Sectors/track}
      TPD : Byte;                 {Tracks/disk}
      SPF : Byte;                 {Sectors/FAT}
      DSC : Byte;                 {Directory sectors}
      FID : Byte;                 {Format id for FAT}
      BRD : array[0..13] of Byte; {Variable boot record data}
    end;
  DiskRecs = array[1..4] of DiskRec;
  SectorArray = array[0..511] of Byte;

const
  DData : DiskRecs =              {BRD starts at offset 13 of FAT}
  ((SSZ : $02; SPT : $09; TPD : $27; SPF : $02; DSC : $07; FID : $FD; {5.25" - 360K}
    BRD : ($02, $01, $00, $02, $70, $00, $D0, $02, $FD, $02, $00, $09, $00, $02)),
   (SSZ : $02; SPT : $0F; TPD : $4F; SPF : $07; DSC : $0E; FID : $F9; {5.25" - 1.2M}
    BRD : ($01, $01, $00, $02, $E0, $00, $60, $09, $F9, $07, $00, $0F, $00, $02)),
   (SSZ : $02; SPT : $09; TPD : $4F; SPF : $03; DSC : $07; FID : $F9; {3.50" - 720K}
    BRD : ($02, $01, $00, $02, $70, $00, $A0, $05, $F9, $03, $00, $09, $00, $02)),
   (SSZ : $02; SPT : $12; TPD : $4F; SPF : $09; DSC : $0E; FID : $F0; {3.50" - 1.44M}
    BRD : ($01, $01, $00, $02, $E0, $00, $40, $0B, $F0, $09, $00, $12, $00, $02)));

  BootRecord : SectorArray = {Standard boot program}
  ($EB, $34, $90, $41, $4D, $53, $54, $20, $33, $2E, $30, $00, $02, $01, $01, $00, $02, $E0, $00, $40, $0B, $F0, $09, $00,
   $12, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $12,
   $00, $00, $00, $00, $01, $00, $FA, $33, $C0, $8E, $D0, $BC, $00, $7C, $16, $07, $BB, $78, $00, $36, $C5, $37, $1E, $56,
   $16, $53, $BF, $2B, $7C, $B9, $0B, $00, $FC, $AC, $26, $80, $3D, $00, $74, $03, $26, $8A, $05, $AA, $8A, $C4, $E2, $F1,
   $06, $1F, $89, $47, $02, $C7, $07, $2B, $7C, $FB, $CD, $13, $72, $67, $A0, $10, $7C, $98, $F7, $26, $16, $7C, $03, $06,
   $1C, $7C, $03, $06, $0E, $7C, $A3, $3F, $7C, $A3, $37, $7C, $B8, $20, $00, $F7, $26, $11, $7C, $8B, $1E, $0B, $7C, $03,
   $C3, $48, $F7, $F3, $01, $06, $37, $7C, $BB, $00, $05, $A1, $3F, $7C, $E8, $9F, $00, $B8, $01, $02, $E8, $B3, $00, $72,
   $19, $8B, $FB, $B9, $0B, $00, $BE, $D6, $7D, $F3, $A6, $75, $0D, $8D, $7F, $20, $BE, $E1, $7D, $B9, $0B, $00, $F3, $A6,
   $74, $18, $BE, $77, $7D, $E8, $6A, $00, $32, $E4, $CD, $16, $5E, $1F, $8F, $04, $8F, $44, $02, $CD, $19, $BE, $C0, $7D,
   $EB, $EB, $A1, $1C, $05, $33, $D2, $F7, $36, $0B, $7C, $FE, $C0, $A2, $3C, $7C, $A1, $37, $7C, $A3, $3D, $7C, $BB, $00,
   $07, $A1, $37, $7C, $E8, $49, $00, $A1, $18, $7C, $2A, $06, $3B, $7C, $40, $38, $06, $3C, $7C, $73, $03, $A0, $3C, $7C,
   $50, $E8, $4E, $00, $58, $72, $C6, $28, $06, $3C, $7C, $74, $0C, $01, $06, $37, $7C, $F7, $26, $0B, $7C, $03, $D8, $EB,
   $D0, $8A, $2E, $15, $7C, $8A, $16, $FD, $7D, $8B, $1E, $3D, $7C, $EA, $00, $00, $70, $00, $AC, $0A, $C0, $74, $22, $B4,
   $0E, $BB, $07, $00, $CD, $10, $EB, $F2, $33, $D2, $F7, $36, $18, $7C, $FE, $C2, $88, $16, $3B, $7C, $33, $D2, $F7, $36,
   $1A, $7C, $88, $16, $2A, $7C, $A3, $39, $7C, $C3, $B4, $02, $8B, $16, $39, $7C, $B1, $06, $D2, $E6, $0A, $36, $3B, $7C,
   $8B, $CA, $86, $E9, $8A, $16, $FD, $7D, $8A, $36, $2A, $7C, $CD, $13, $C3, $0D, $0A, $4E, $6F, $6E, $2D, $53, $79, $73,
   $74, $65, $6D, $20, $64, $69, $73, $6B, $20, $6F, $72, $20, $64, $69, $73, $6B, $20, $65, $72, $72, $6F, $72, $0D, $0A,
   $52, $65, $70, $6C, $61, $63, $65, $20, $61, $6E, $64, $20, $73, $74, $72, $69, $6B, $65, $20, $61, $6E, $79, $20, $6B,
   $65, $79, $20, $77, $68, $65, $6E, $20, $72, $65, $61, $64, $79, $0D, $0A, $00, $0D, $0A, $44, $69, $73, $6B, $20, $42,
   $6F, $6F, $74, $20, $66, $61, $69, $6C, $75, $72, $65, $0D, $0A, $00, $49, $4F, $20, $20, $20, $20, $20, $20, $53, $59,
   $53, $4D, $53, $44, $4F, $53, $20, $20, $20, $53, $59, $53, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
   $00, $00, $00, $00, $00, $00, $55, $AA);

  MediaArray : array[DriveType, 1..2] of Byte =
    (($00, $00),     {Unknown disk}
     ($01, $02),     {360K disk}
     ($00, $03),     {1.2M disk}
     ($00, $04),     {720K disk}
     ($00, $04));    {1.44M disk}

{$IFDEF pmode}
type
  DPMIRegisters =
    record
      DI : LongInt;
      SI : LongInt;
      BP : LongInt;
      Reserved : LongInt;
      BX : LongInt;
      DX : LongInt;
      CX : LongInt;
      AX : LongInt;
      Flags : Word;
      ES : Word;
      DS : Word;
      FS : Word;
      GS : Word;
      IP : Word;
      CS : Word;
      SP : Word;
      SS : Word;
    end;

  function GetRealSelector(RealPtr : Pointer; Limit : Word) : Word;
    {-Set up a selector to point to RealPtr memory}
  type
    OS =
      record
        O, S : Word;
      end;
  var
    Status : Word;
    Selector : Word;
    Base : LongInt;
  begin
    GetRealSelector := 0;
    Selector := AllocSelector(0);
    if Selector = 0 then
      Exit;
    {Assure a read/write selector}
    Status := ChangeSelector(CSeg, Selector);
    Base := (LongInt(OS(RealPtr).S) shl 4)+LongInt(OS(RealPtr).O);
    if SetSelectorBase(Selector, Base) = 0 then begin
      Selector := FreeSelector(Selector);
      Exit;
    end;
    Status := SetSelectorLimit(Selector, Limit);
    GetRealSelector := Selector;
  end;

  procedure GetRealIntVec(IntNo : Byte; var Vector : Pointer); Assembler;
  asm
    mov     ax,0200h
    mov     bl,IntNo
    int     31h
    les     di,Vector
    mov     word ptr es:[di],dx
    mov     word ptr es:[di+2],cx
  end;

  function RealIntr(IntNo : Byte; var Regs : DPMIRegisters) : Word; Assembler;
  asm
    xor     bx,bx
    mov     bl,IntNo
    xor     cx,cx        {StackWords = 0}
    les     di,Regs
    mov     ax,0300h
    int     31h
    jc      @@ExitPoint
    xor     ax,ax
  @@ExitPoint:
  end;
{$ENDIF}

  procedure Int13Call(var Regs : Registers);
    {-Call int $13 for real or protected mode}
{$IFDEF pmode}
  var
    Base : LongInt;
    DRegs : DPMIRegisters;
{$ENDIF}
  begin
{$IFDEF pmode}
    {This pmode code is valid only for the AH values used in this unit}
    FillChar(DRegs, SizeOf(DPMIRegisters), 0);
    DRegs.AX := Regs.AX;
    DRegs.BX := Regs.BX;
    DRegs.CX := Regs.CX;
    DRegs.DX := Regs.DX;
    case Regs.AH of
      2, 3, 5 :
        {Calls that use ES as a buffer segment}
        begin
          Base := GetSelectorBase(Regs.ES);
          if (Base <= 0) or (Base > $FFFF0) then begin
            Regs.Flags := 1;
            Regs.AX := 1;
            Exit;
          end;
          DRegs.ES := Base shr 4;
        end;
    end;
    if RealIntr($13, DRegs) <> 0 then begin
      Regs.Flags := 1;
      Regs.AX := 1;
    end else begin
      Regs.Flags := DRegs.Flags;
      Regs.AX := DRegs.AX;
      Regs.BX := DRegs.BX; {BX is returned by GetDriveType function only}
    end;

{$ELSE}
    Intr($13, Regs);
{$ENDIF}
  end;

  function GetDriveType(Drive : DriveNumber) : DriveType;
  var
    Regs : Registers;
  begin
    Regs.AH := $08;
    Regs.DL := Drive;
    Int13Call(Regs);
    if Regs.AH = 0 then
      GetDriveType := Regs.BL
    else
      GetDriveType := 0;
  end;

  function GetDiskStatus : Byte;
  var
    Regs : Registers;
  begin
    Regs.AH := $01;
    Int13Call(Regs);
    GetDiskStatus := Regs.AL;
  end;

  function GetStatusStr(ErrNum : Byte) : String;
  var
    NumStr : string[3];
  begin
    case ErrNum of
      {Following codes are defined by the floppy BIOS}
      $00 : GetStatusStr := '';
      $01 : GetStatusStr := 'Invalid command';
      $02 : GetStatusStr := 'Address mark not found';
      $03 : GetStatusStr := 'Disk write protected';
      $04 : GetStatusStr := 'Sector not found';
      $06 : GetStatusStr := 'Floppy disk removed';
      $08 : GetStatusStr := 'DMA overrun';
      $09 : GetStatusStr := 'DMA crossed 64KB boundary';
      $0C : GetStatusStr := 'Media type not found';
      $10 : GetStatusStr := 'Uncorrectable CRC error';
      $20 : GetStatusStr := 'Controller failed';
      $40 : GetStatusStr := 'Seek failed';
      $80 : GetStatusStr := 'Disk timed out';

      {Following codes are added by this unit}
      $FA : GetStatusStr := 'Format aborted';
      $FB : GetStatusStr := 'Invalid media type';
      $FC : GetStatusStr := 'Too many bad sectors';
      $FD : GetStatusStr := 'Disk bad';
      $FE : GetStatusStr := 'Invalid drive or type';
      $FF : GetStatusStr := 'Insufficient memory';
    else
      Str(ErrNum, NumStr);
      GetStatusStr := 'Unknown error '+NumStr;
    end;
  end;

  procedure ResetDrive(Drive : DriveNumber);
  var
    Regs : Registers;
  begin
    Regs.AH := $00;
    Regs.DL := Drive;
    Int13Call(Regs);
  end;

  function AllocBuffer(var P : Pointer; Size : Word) : Boolean;
  var
    L : LongInt;
  begin
{$IFDEF pmode}
    L := GlobalDosAlloc(Size);
    if L <> 0 then begin
      P := Ptr(Word(L and $FFFF), 0);
      AllocBuffer := True;
    end else begin
      P := nil;
      AllocBuffer := False
    end;
{$ELSE}
    if MaxAvail >= Size then begin
      GetMem(P, Size);
      AllocBuffer := True;
    end else begin
      P := nil;
      AllocBuffer := False;
    end;
{$ENDIF}
  end;

  procedure FreeBuffer(P : Pointer; Size : Word);
  begin
    if P = nil then
      Exit;
{$IFDEF pmode}
    Size := GlobalDosFree(LongInt(P) shr 16);
{$ELSE}
    FreeMem(P, Size);
{$ENDIF}
  end;

  function CheckParms(DType : DriveType; Drive : DriveNumber) : Boolean;
    {-Make sure drive and type are within range}
  begin
    CheckParms := False;
    if (DType < 1) or (DType > 4) then
      Exit;
    if (Drive > 7) then
      Exit;
    CheckParms := True;
  end;

  function SubfSectors(SubFunc : Byte;
                       Drive : DriveNumber;
                       Track, Side, SSect, NSect : Byte;
                       var Buffer) : Byte;
    {-Code shared by ReadSectors, WriteSectors, VerifySectors, FormatTrack}
  var
    Tries : Byte;
    Done : Boolean;
    Regs : Registers;
  begin
    Tries := 1;
    Done := False;
    repeat
      Regs.AH := SubFunc;
      Regs.AL := NSect;
      Regs.CH := Track;
      Regs.CL := SSect;
      Regs.DH := Side;
      Regs.DL := Drive;
      Regs.ES := Seg(Buffer);
      Regs.BX := Ofs(Buffer);
      Int13Call(Regs);

      if Regs.AH <> 0 then begin
        ResetDrive(Drive);
        Inc(Tries);
        if Tries > MaxRetries then
          Done := True;
      end else
        Done := True;
    until Done;

    SubfSectors := Regs.AH;
  end;

  function ReadSectors(Drive : DriveNumber;
                       Track, Side, SSect, NSect : Byte;
                       var Buffer) : Byte;
  begin
    ReadSectors := SubfSectors($02, Drive, Track, Side, SSect, NSect, Buffer);
  end;

  function WriteSectors(Drive : DriveNumber;
                        Track, Side, SSect, NSect : Byte;
                        var Buffer) : Byte;
  begin
    WriteSectors := SubfSectors($03, Drive, Track, Side, SSect, NSect, Buffer);
  end;

  function VerifySectors(Drive : DriveNumber;
                         Track, Side, SSect, NSect : Byte) : Byte;
  var
    Dummy : Byte;
  begin
    VerifySectors := SubfSectors($04, Drive, Track, Side, SSect, NSect, Dummy);
  end;

  function SetDriveTable(DType : DriveType) : Boolean;
    {-Set drive table parameters for formatting}
  var
    P : Pointer;
    DBSeg : Word;
    DBOfs : Word;
  begin
    SetDriveTable := False;

{$IFDEF pmode}
    GetRealIntVec($1E, P);
    DBSeg := GetRealSelector(P, $FFFF);
    if DBSeg = 0 then
      Exit;
    DBOfs := 0;
{$ELSE}
    GetIntVec($1E, P);
    DBSeg := LongInt(P) shr 16;
    DBOfs := LongInt(P) and $FFFF;
{$ENDIF}

    {Set gap length for formatting}
    case DType of
      1 : Mem[DBSeg:DBOfs+7] := $50; {360K}
      2 : Mem[DBSeg:DBOfs+7] := $54; {1.2M}
      3,
      4 : Mem[DBSeg:DBOfs+7] := $6C; {720K or 1.44M}
    end;

    {Set max sectors/track}
    Mem[DBSeg:DBOfs+4] := DData[DType].SPT;

{$IFDEF pmode}
    DBSeg := FreeSelector(DBSeg);
{$ENDIF}

    SetDriveTable := True;
  end;

  function GetMachineID : Byte;
    {-Return machine ID code}
{$IFDEF pmode}
  var
    SegFFFF : Word;
{$ENDIF}
  begin
{$IFDEF pmode}
    SegFFFF := GetRealSelector(Ptr($FFFF, $0000), $FFFF);
    if SegFFFF = 0 then
      GetMachineID := 0
    else begin
      GetMachineID := Mem[SegFFFF:$000E];
      SegFFFF := FreeSelector(SegFFFF);
    end;
{$ELSE}
    GetMachineID := Mem[$FFFF:$000E];
{$ENDIF}
  end;

  function IsATMachine : Boolean;
    {-Return True if AT or better machine}
  begin
    IsATMachine := False;
    if Lo(DosVersion) >= 3 then
      case GetMachineId of
        $FC, $F8 :  {AT or PS/2}
          IsATMachine := True;
      end;
  end;

  function GetChangeLineType(Drive : DriveNumber; var CLT : Byte) : Byte;
    {-Return change line type of drive}
  var
    Regs : Registers;
  begin
    Regs.AH := $15;
    Regs.DL := Drive;
    Int13Call(Regs);
    if (Regs.Flags and FCarry) <> 0 then begin
      GetChangeLineType := Regs.AH;
      CLT := 0;
    end else begin
      GetChangeLineType := 0;
      CLT := Regs.AH;
    end;
  end;

  function SetFloppyType(Drive : DriveNumber; FType : Byte) : Byte;
    {-Set floppy type for formatting}
  var
    Tries : Byte;
    Done : Boolean;
    Regs : Registers;
  begin
    Tries := 1;
    Done := False;
    repeat
      Regs.AH := $17;
      Regs.AL := FType;
      Regs.DL := Drive;
      Int13Call(Regs);
      if Regs.AH <> 0 then begin
        ResetDrive(Drive);
        Inc(Tries);
        if Tries > MaxRetries then
          Done := True;
      end else
        Done := True;
    until Done;

    SetFloppyType := Regs.AH;
  end;

  function SetMediaType(Drive : DriveType; TPD : Byte; SPT : Byte) : Byte;
    {-Set media type for formatting}
  var
    Regs : Registers;
  begin
    Regs.AH := $18;
    Regs.DL := Drive;
    Regs.CH := TPD;
    Regs.CL := SPT;
    Int13Call(Regs);
    SetMediaType := Regs.AH;
  end;

  function FormatDisk(Drive : DriveNumber; DType : DriveType;
                      Verify : Boolean; MaxBadSects : Byte;
                      VLabel : VolumeStr;
                      FAF : FormatAbortFunc) : Byte;
  label
    ExitPoint;
  type
    CHRNRec =
      record
        CTrack : Byte;            {Track  0..?}
        CSide : Byte;             {Side   0..1}
        CSect : Byte;             {Sector 1..?}
        CSize : Byte;             {Size   0..?}
      end;
    CHRNArray = array[1..18] of CHRNRec;
    FATArray = array[0..4607] of Byte;
  var
    Tries : Byte;
    Track : Byte;
    Side : Byte;
    Sector : Byte;
    RWritten : Byte;
    RTotal : Byte;
    FatNum : Byte;
    BadSects : Byte;
    ChangeLine : Byte;
    DiskType : Byte;
    Status : Byte;
    Done : Boolean;
    Trash : Word;
    DT : DateTime;
    VDate : LongInt;
    Regs : Registers;
    BootPtr : ^SectorArray;
    CHRN : ^CHRNArray;
    FATs : ^FATArray;

    procedure MarkBadSector(Track, Side, Sector : Byte);
    const
      BadMark = $FF7;             {Bad cluster mark}
    var
      CNum : Integer;             {Cluster number}
      FOfs : Word;                {Offset into fat for this cluster}
      FVal : Word;                {FAT value for this cluster}
      OFVal : Word;               {Old FAT value for this cluster}
    begin
      CNum := (((((Track*2)+Side)*DData[DType].SPT)+Sector-RTotal-2) div
              DData[DType].BRD[0])+2;
      if CNum > 1 then begin
        {Sector is in data space}
        FOfs := (CNum*3) div 2;
        Move(FATs^[FOfs], FVal, 2);
        if Odd(CNum) then
          OFVal := (FVal and (BadMark shl 4))
        else
          OFVal := (FVal and BadMark);
        if OFVal = 0 then begin
          {Not already marked bad, mark it}
          if Odd(CNum) then
            FVal := (FVal or (BadMark shl 4))
          else
            FVal := (FVal or BadMark);
          Move(FVal, FATs^[FOfs], 2);
          {Add to bad sector count}
          Inc(BadSects, DData[DType].BRD[0]);
        end;
      end;
    end;

  begin
    {Validate parameters. Can't do anything unless these are reasonable}
    if not CheckParms(DType, Drive) then
      Exit;

    {Initialize buffer pointers in case of failure}
    FATs := nil;
    CHRN := nil;
    BootPtr := nil;

    {Status proc: starting format}
    if FAF(0, DData[DType].TPD, 0) then begin
      Status := $FA;
      goto ExitPoint;
    end;

    {Error code for invalid drive or media type}
    Status := $FE;

    case GetDriveType(Drive) of
      1 : {360K drive formats only 360K disks}
        if DType <> 1 then
          goto ExitPoint;
      2 : {1.2M drive formats 360K or 1.2M disk}
        if DType > 2 then
          goto ExitPoint;
      3 : {720K drive formats only 720K disks}
        if DType <> 3 then
          goto ExitPoint;
      4 : {1.44M drive formats 720K or 1.44M disks}
        if Dtype < 3 then
          goto ExitPoint;
    else
      goto ExitPoint;
    end;

    {Error code for out-of-memory or DPMI error}
    Status := $FF;

    {Allocate buffers}
    if not AllocBuffer(Pointer(FATs), SizeOf(FATArray)) then
      goto ExitPoint;
    if not AllocBuffer(Pointer(CHRN), SizeOf(CHRNArray)) then
      goto ExitPoint;
    if not AllocBuffer(Pointer(BootPtr), SizeOf(BootRecord)) then
      goto ExitPoint;

    {Initialize boot record}
    Move(BootRecord, BootPtr^, SizeOf(BootRecord));
    Move(DData[DType].BRD, BootPtr^[13], 14);

    {Initialize the FAT table}
    FillChar(FATs^, SizeOf(FATArray), 0);
    FATs^[0] := DData[DType].FID;
    FATs^[1] := $FF;
    FATs^[2] := $FF;

    {Set drive table parameters by patching drive table in memory}
    if not SetDriveTable(DType) then
      goto ExitPoint;

    {On AT class machines, set format parameters via BIOS}
    if IsATMachine then begin
      {Get change line type: 1 -> 360K drive, 2 -> 1.2M or 3.5" drive}
      Status := GetChangeLineType(Drive, ChangeLine);
      if Status <> 0 then
        goto ExitPoint;
      if (ChangeLine < 1) or (ChangeLine > 2) then begin
        Status := 1;
        goto ExitPoint;
      end;

      {Determine floppy type for SetFloppyType call}
      DiskType := MediaArray[DType, ChangeLine];
      if DiskType = 0 then begin
        Status := $FB;
        goto ExitPoint;
      end;

      {Set floppy type for drive}
      Status := SetFloppyType(Drive, DiskType);
      if Status <> 0 then
        goto ExitPoint;

      {Set media type for format}
      Status := SetMediaType(Drive, DData[DType].TPD, DData[DType].SPT);
      if Status <> 0 then
        goto ExitPoint;
    end;

    {Format each sector}
    ResetDrive(Drive);
    BadSects := 0;

    for Track := 0 to DData[DType].TPD do begin
      {Status proc: formatting track}
      if FAF(Track, DData[DType].TPD, 1) then begin
        Status := $FA;
        goto ExitPoint;
      end;

      for Side := 0 to 1 do begin
        {Initialize CHRN for this sector}
        for Sector := 1 to DData[DType].SPT do
          with CHRN^[Sector] do begin
            CTrack := Track;
            CSide := Side;
            CSect := Sector;
            CSize := DData[DType].SSZ;
          end;

        {Format this sector, with retries}
        Status := SubfSectors($05, Drive, Track, Side,
                              1, DData[DType].SPT, CHRN^);
        if Status <> 0 then
          goto ExitPoint;
      end;

      if Verify then begin
        {Status proc: verifying track}
        if FAF(Track, DData[DType].TPD, 2) then begin
          Status := $FA;
          goto ExitPoint;
        end;

        for Side := 0 to 1 do
          {Verify the entire track}
          if VerifySectors(Drive, Track, Side,
                           1, DData[DType].SPT) <> 0 then begin
            if Track = 0 then begin
              {Disk bad}
              Status := $FD;
              goto ExitPoint;
            end;

            for Sector := 1 to DData[DType].SPT do
              if VerifySectors(Drive, Track, Side,
                               Sector, 1) <> 0 then begin
                MarkBadSector(Track, Side, Sector);
                if BadSects > MaxBadSects then begin
                  Status := $FC;
                  goto ExitPoint;
                end;
              end;
          end;
      end;
    end;

    {Status proc: writing boot and FAT}
    if FAF(0, DData[DType].TPD, 3) then begin
      Status := $FA;
      goto ExitPoint;
    end;

    {Write boot record}
    Status := WriteSectors(Drive, 0, 0, 1, 1, BootPtr^);
    if Status <> 0 then begin
      Status := $FD;
      goto ExitPoint;
    end;

    {Write FATs and volume label}
    Track := 0;
    Side := 0;
    Sector := 2;
    FatNum := 0;
    RTotal := (2*DData[DType].SPF)+DData[DType].DSC;
    for RWritten := 0 to RTotal-1 do begin
      if Sector > DData[DType].SPT then begin
        Sector := 1;
        Inc(Side);
      end;

      if RWritten < (2*DData[DType].SPF) then begin
        if FatNum > DData[DType].SPF-1 then
          FatNum := 0;
      end else begin
        FillChar(FATs^, 512, 0);
        if ((VLabel <> '') and (RWritten = 2*DData[DType].SPF)) then begin
          {Put in volume label}
          for Trash := 1 to Length(VLabel) do
            VLabel[Trash] := Upcase(VLabel[Trash]);
          while Length(VLabel) < 11 do
            VLabel := VLabel+' ';
          Move(VLabel[1], FATs^, 11);
          FATs^[11] := 8;
          GetDate(DT.Year, DT.Month, DT.Day, Trash);
          GetTime(DT.Hour, DT.Min, DT.Sec, Trash);
          PackTime(DT, VDate);
          Move(VDate, FATs^[22], 4);
        end;
        FatNum := 0;
      end;

      if WriteSectors(Drive, Track, Side,
                      Sector, 1, FATs^[FatNum*512]) <> 0 then begin
        Status := $FD;
        goto ExitPoint;
      end;

      Inc(Sector);
      Inc(FatNum);
    end;

    {Success}
    Status := 0;

ExitPoint:
    FreeBuffer(BootPtr, SizeOf(BootRecord));
    FreeBuffer(CHRN, SizeOf(CHRNArray));
    FreeBuffer(FATs, SizeOf(FATArray));

    {Status proc: ending format}
    Done := FAF(Status, DData[DType].TPD, 4);
    FormatDisk := Status;
  end;

  function EmptyAbortFunc(Track, MaxTrack : Byte; Kind : Byte) : Boolean;
  begin
    EmptyAbortFunc := False;
  end;

end.

{ -------------------------------    DEMO PROGRAM   -------------------- }
{ -------------------------------     CUT HERE      ---------------------}

{$R-,S-,I-}

program Fmt;
  {-Simple formatting program to demonstate DISKB unit}

uses
{$IFDEF Windows}
  WinCrt,
{$ENDIF}
  BDisk;

const
  ESC = #27;
  CR = #13;

type
  CharSet = set of Char;

var
  DLet : Char;
  DTyp : Char;
  Verf : Char;
  GLet : Char;
  DNum : Byte;
  Status : Byte;
  VStr : VolumeStr;

const
  DriveTypeName : array[DriveType] of string[5] =
    ('other', '360K', '1.2M', '720K', '1.44M');

{$IFNDEF Windows}
  function ReadKey : Char; assembler;
    {-Low budget readkey routine}
  asm
    xor ah,ah
    int 16h
  end;
{$ENDIF}

  function GetKey(Prompt : String; OKSet : CharSet) : Char;
    {-Get and return a key in the OKSet}
  var
    Ch : Char;
  begin
    Write(Prompt);
    repeat
      Ch := Upcase(ReadKey);
      if Ch = ESC then begin
        WriteLn;
        Halt;
      end;
    until (Ch in OKSet);
    if Ch <> CR then
      Write(Ch);
    WriteLn;
    GetKey := Ch;
  end;

  function AbortFunc(Track, MaxTrack : Byte; Kind : Byte) : Boolean; far;
    {-Display formatting status. Could check for abort here too}
  begin
    case Kind of
      0 : {Format beginning}
        Write('Formatting     ');
      1 : {Formatting track}
        Write(^H^H^H^H, ((Track*100) div MaxTrack):3, '%');
      2 : {Verifying track}
        Write(^H, 'V');
      3 : {Writing boot and FAT}
        Write(^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H, 'Writing boot and FAT');
      4 : {Format ending}
        begin
          Write(^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H^H);
          {Track returns final status code in this case}
          if Track = 0 then
            WriteLn('Formatted successfully')
          else
            WriteLn('Format failed: ', GetStatusStr(Track));
        end;
    end;
    AbortFunc := False;
  end;

begin
  WriteLn('Floppy Formatter: <Esc> to exit');

  {Get formatting parameters}
  DLet := GetKey('Drive to format? (A or B): ', ['A'..'B']);
  DTyp := GetKey('Disk type? (1=360K, 2=1.2M, 3=720K, 4=1.44M): ', ['1'..'4']);
  Verf := GetKey('Verify? (Y or N) ', ['N', 'Y']);
  Write('Volume label? ');
  ReadLn(VStr);
  GLet := GetKey('Insert disk and press <Enter> ', [#13]);

  {Compute drive number}
  DNum := Byte(DLet)-Byte('A');

  WriteLn('Drive type is ', DriveTypeName[GetDriveType(DNum)]);

  Status := FormatDisk(DNum,                    {drive number}
                       Byte(DTyp)-Byte('0'),    {format type}
                       (Verf = 'Y'),            {verify?}
                       10,                      {max bad sectors}
                       VStr,                    {volume label}
                       AbortFunc);              {abort function}
  {AbortFunc reports the status}
end.
