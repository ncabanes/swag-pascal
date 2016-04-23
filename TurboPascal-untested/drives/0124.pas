unit Drives;

{ see TEST program below !! }

{ Unit Drives, written by Salvatore Besso   }
{ mc8505@mclink.it                          }

{ This unit is freeware and is donated to   }
{ the SWAG archival group.                  }

{ Finally, a Drives unit that correctly     }
{ works in both real and protected mode,    }
{ in a Windows 95 DOS box, and that doesn't }
{ require a media to be present in the      }
{ removable drive.                          }

{ This unit is still not able to correctly  }
{ recognize Iomega Zip drives in a Windows  }
{ 95 DOS box for now (they are recognized   }
{ as removable media). As soon as new       }
{ informations will be available from the   }
{ interrupt list of Ralph Brown, the unit   }
{ will be modified. Actually informations   }
{ about Iomega interrupt are very scarce.   }

{ A new Dpmi unit is beyond the end of this }
{ unit                                      }

{ Test program is beyond the end of the     }
{ Drives and Dpmi units                     }

{ If you have any feedback, feel free to    }
{ e-mail me                                 }

interface

uses
  {$IFDEF DPMI}
  Dpmi,
  {$ENDIF}
  Dos;

const

  { dtXXXX constants - Drive Type }

  dtInvalid   = $0;
  dtUnknown   = $1;

  { Floppy disk }

  dt8Single   = $2;
  dt8Double   = $4;
  dt360       = $8;
  dt1200      = $10;
  dt720       = $20;
  dt1440      = $40;
  dt2880      = $80;
  dtAnyFloppy = $FE;

  { Other media }

  dtTape      = $100;
  dtFloptical = $200;
  dtRamDisk   = $400;
  dtCdRom     = $800;
  dtIomegaZip = $1000;

  dtHardDisk  = $80000;

  { Other attributes }

  dtRemovable = $100000;
  dtRemote    = $200000;

type

  PParamBlock = ^TParamBlock;
  TParamBlock = record
    SpecialFunctions: Byte;     { Special functions }
    DeviceType      : Byte;     { Device type }
    DeviceAttributes: Word;     { Device attributes }
    MaxCylinders    : Word;     { Number of cylinders }
    MediaType       : Byte;     { Media type }
    { Beginning of BIOS parameter block (BPB) }
    BytesPerSector  : Word;     { Bytes per sector }
    SectPerCluster  : Byte;     { Sectors per cluster }
    ReservedSectors : Word;     { Number of reserved sectors }
    NumberFats      : Byte;     { Number of FATs }
    RootDirEntries  : Word;     { Number of root-directory entries }
    TotalSectors    : Word;     { Total number of sectors }
    MediaDescriptor : Byte;     { Media descriptor }
    SectorsPerFat   : Word;     { Number of sectors per FAT }
    SectorsPerTrack : Word;     { Number of sectors per track }
    NumberHeads     : Word;     { Number of heads }
    HiddenSectors   : LongInt;  { Number of hidden sectors }
    HugeSectors     : LongInt   { Number of sectors if TotalSectors = 0 }
    { End of BIOS parameter block (BPB) }
  end;

  PtrRec = record   { replicated from OBJECTS.PAS to avoid using the unit }
    Ofs,Seg: Word
  end;

  DriveLetters = 'A'..'Z';
  DriveSet     = Set of DriveLetters;

{ returns all available drives in a DriveSet type variable }

procedure GetDrives (var Drive: DriveSet);

{ returns drive type }

function GetDriveType (Drive: Char): LongInt;

implementation

procedure GetDrives (var Drive: DriveSet);

var
  DriveName: array[1..2] of Char;
  FCB      : array[0..43] of Char;
  Dr       : LongInt;

begin
  asm
        PUSH    SI
        PUSH    DI
        PUSH    ES
        PUSH    DS
        MOV     SI,SS     { Stack points to local variables }
        MOV     DS,SI     { also DS ... }
        PUSH    DS
        POP     ES        { ...and ES }
        MOV     BYTE PTR [DriveName],'A'
        MOV     BYTE PTR [DriveName + 1],':'
        MOV     WORD PTR [Dr],0
        MOV     WORD PTR [Dr + 2],0
        MOV     DX,1
        XOR     CX,CX
  @@1:  LEA     SI,DriveName
        LEA     DI,FCB
        MOV     AX,290EH  { Function 29H - Parse Filename - AL = options }
        INT     21H
        CMP     AL,0FFH
        JE      @@2
        PUSH    DX
        PUSH    CX
        MOV     AX,4409H  { SUBST drives are ignored }
        MOV     BL,BYTE PTR [DriveName]
        SUB     BL,'@'
        INT     21H
        JC      @@2
        TEST    DH,10000000B
        POP     CX
        POP     DX
        JNZ     @@2
        OR      WORD PTR [Dr],DX
        OR      WORD PTR [Dr + 2],CX
  @@2:  SHL     DX,1
        RCL     CX,1
        INC     BYTE PTR [DriveName]
        CMP     BYTE PTR [DriveName],'Z'
        JBE     @@1
        SHL     WORD PTR [Dr],1
        RCL     WORD PTR [Dr + 2],1
        POP     DS
        POP     ES
        POP     DI
        POP     SI
  end;
  Drive := DriveSet (Dr)
end;

function GetDriveType (Drive: Char): LongInt;

var
  DPB    : PParamBlock;
  SegInfo: Word;
  Regs   : Registers;
  Temp   : Byte;
  Result : LongInt;
  {$IFDEF DPMI}
  Size   : LongInt;
  {$ENDIF}

function GetDevParms (Drive: Char; var DPB: PParamBlock; Segm: Word): Boolean;

var
  Regs: Registers;

begin
  GetDevParms := False;
  FillChar (Regs,SizeOf (Registers),0);
  Regs.AX := $440D;
  Regs.BL := Byte (Drive) - 64;
  Regs.CH := $08;                       { category: disk drive }
  Regs.CL := $60;                       { device parameters    }
  {$IFNDEF DPMI}
  Regs.DS := PtrRec (DPB).Seg;
  Regs.DX := PtrRec (DPB).Ofs;
  MsDos (Regs);
  {$ELSE}
  Regs.DS := Segm;
  Regs.DX := 0;
  if NOT DpmiMsDos (Regs) then Exit;
  {$ENDIF}
  GetDevParms := Regs.Flags and fCarry = 0
end;

function IsDriveRemote (Drive: Char): Boolean; assembler;

asm
        MOV     AX,4409H  { IOCTL - Check if block device remote }
        MOV     BL,Drive  { BL = drive                           }
        SUB     BL,'@'    { 1 = A:, 2 = B:, etc...               }
        INT     21H
        XOR     AX,AX
        JC      @@1
        AND     DH,00010000B
        JZ      @@1
        INC     AX
  @@1:
end;

function IsCDRomDrive (Drive: Char): Boolean; assembler;

asm
        MOV     AX,150BH  { MSCDEX.EXE installation test }
        XOR     CH,CH     { CX = drive                   }
        MOV     CL,Drive
        SUB     CL,'A'    { 0 = A:, 1 = B:, etc...       }
        INT     2FH
        PUSH    AX
        POP     CX
        XOR     AX,AX
        JCXZ    @@1
        TEST    BX,0ADADH
        JZ      @@1
        INC     AX
  @@1:
end;

function IsIomegaZip: Boolean;

var
  Regs  : Registers;
  Result: Boolean;

begin
  { Find first GUEST.EXE... }
  FillChar (Regs,SizeOf (Registers),0);
  Regs.AX := $5700;                      { GUEST.EXE installation test }
  Regs.BX := $0201;                      { Iomega ID ???               }
  Regs.DX := $496F;                      { 'Io'                        }
  {$IFNDEF DPMI}
  Intr ($2F,Regs);
  {$ELSE}
  if NOT DpmiIntr ($2F,Regs) then Exit;
  {$ENDIF}
  Result := Regs.AL = $FF;
  if NOT Result then
  begin
    { ...GUEST.EXE not found: Find GUEST95.EXE...  }
    { Interrupt informations for GUEST95.EXE still }
    { not available                                }
  end;
  IsIomegaZip := Result
end;

begin { GetDriveType }
  GetDriveType := dtInvalid;
  {$IFNDEF DPMI}
  New (DPB);
  SegInfo := 0;
  {$ELSE}
  Size := SizeOf (TParamBlock);
  if NOT DpmiGetMem (Pointer (DPB),SegInfo,Size) then Exit;
  {$ENDIF}
  FillChar (DPB^,SizeOf (TParamBlock),0);
  FillChar (Regs,SizeOf (Regs),0);
  Regs.AX := $4408;                     { removable media ? }
  Regs.BL := Byte (Drive) - 64;
  {$IFNDEF DPMI}
  MsDos (Regs);
  {$ELSE}
  if NOT DpmiMsDos (Regs) then
  begin
    DpmiFreeMem (Pointer (DPB));
    Exit
  end;
  {$ENDIF}
  Temp := 0;
  if Regs.Flags and fCarry <> 0 then  { error, check error code in AX }
  begin
    { Driver does NOT support this call, so guess as a hard disk }
    if Regs.AX = 1 then Temp := 3
  end
  else begin
    if Regs.AX = 0 then
      Temp := 2          { removable media, floppy, WORM, Floptical, ZIP }
    else Temp := 3       { or hard disk, ramdisk or CD-ROM               }
  end;
  Result := dtInvalid;
  case Temp of
    { Removable }
    2: if GetDevParms (Drive,DPB,SegInfo) then
    begin
      case DPB^.DeviceType of
        0: Result := dt360;
        1: Result := dt1200;
        2: Result := dt720;
        3: Result := dt8Single;
        4: Result := dt8Double;
        5: if IsIomegaZip then Result := dtIomegaZip else Result := dtHardDisk;
        6: Result := dtTape;
        7: Result := dt1440;
        8: Result := dtFloptical;
        9: begin
          if (DPB^.MaxCylinders = 80) and (DPB^.NumberHeads = 2) then
            Result := dt2880
          else if IsIomegaZip then
            Result := dtIomegaZip
          else Result := dtUnknown
        end
        else Result := dtUnknown
      end;
      if Result > dtUnknown then Result := Result or dtRemovable
    end;
    { Fixed }
    3: if GetDevParms (Drive,DPB,SegInfo) then
      if DPB^.DeviceType = 5 then
        Result := dtHardDisk
      else Result := dtUnknown
    else Result := dtRamDisk
  end;
  if IsDriveRemote (Drive) then
    if IsCDRomDrive (Drive) then
      Result := dtCdRom or dtRemovable
    else Result := Result or dtRemote;
  {$IFNDEF DPMI}
  Dispose (DPB);
  {$ELSE}
  if NOT DpmiFreeMem (Pointer (DPB)) then Exit;
  {$ENDIF}
  GetDriveType := Result
end;

end.

(*

unit Dpmi;

{$IFNDEF DPMI}
  Error ! this code works in Protected Mode only
{$ENDIF}

{$G+,S-}

interface

uses
  Dos;

{ Virtual interrupt state values for use with the SetInterruptState and
  GetInterruptState functions. }

const
  intDisabled = False;
  intEnabled  = True;

{ Return values for MemInitSwapFile and MemCloseSwapFile }

const
  rtmOK          = $0;
  rtmNoMemory    = $1;
  rtmFileIOError = $22;

{ TRealModeRegs is a real mode registers data structure for use with the
  RealModeInt, RealModeCall, RealModeIntCall, and AllocRealCallback
  functions. }

type
  PRealModeRegs = ^TRealModeRegs;
  TRealModeRegs = record
    case Integer of
      0: (
        EDI,ESI,EBP,EXX,EBX,EDX,ECX,EAX: LongInt;
        Flags,ES,DS,FS,GS,IP,CS,SP,SS  : Word
      );
      1: (
        DI,DIH,SI,SIH,BP,BPH,XX,XXH: Word;
        case Integer of
          0: (
            BX,BXH,DX,DXH,CX,CXH,AX,AXH: Word
          );
          1: (
            BL,BH,BLH,BHH,DL,DH,DLH,DHH,CL,CH,CLH,CHH,AL,AH,ALH,AHH: Byte
          )
      )
  end;

{ TDescriptor is an 8-byte structure for use with the GetDescriptor and
  SetDescriptor procedures. }

type
  PDescriptor = ^TDescriptor;
  TDescriptor = array[0..7] of Byte;

{ TVersionInfo is a DPMI version information structure for use with the
  GetVersionInfo procedure. }

type
  PVersionInfo = ^TVersionInfo;
  TVersionInfo = record
    MinorVersion : Byte;          { AL }
    MajorVersion : Byte;          { AH }
    Flags        : Word;          { BX }
    ProcessorType: Byte;          { CL }
    Reserved     : Byte;          { CH }
    SlaveBaseInt : Byte;          { DL }
    MasterBaseInt: Byte           { DH }
  end;

{ Corresponds to procedure Intr but uses Registers instead of TRealModeRegs }

function DpmiIntr (IntNo: Byte; var Regs: Registers): Boolean;

{ Corresponds to procedure MsDos but uses Registers instead of TRealModeRegs }

function DpmiMsDos (var Regs: Registers): Boolean;

{ Corresponds to procedure GetMem; allocates memory in the first }
{ megabyte, accessible in both protected - through P - and real  }
{ mode - through Segment:$0000                                   }

function DpmiGetMem (var P: Pointer; var Segment: Word;
  var Size: Longint): Boolean;

{ Corresponds to procedure FreeMem; you must use it to deallocate }
{ memory allocated with DpmiGetMem                                }

function DpmiFreeMem (var P: Pointer): Boolean;

{ IncSelector returns the value to add to the first selector, and to    }
{ the next ones, to access the descriptor array allocated by DpmiGetMem }
{ when blocks greater than 64 K are requested                           }

procedure IncSelector (var Selector: Word);

{ AllocSelectors allocates one or more selectors using Dpmi function  }
{ 0000H. The return value is the base selector of the allocated block }
{ of selectors, or zero if the function is unsuccessful               }

function AllocSelectors (Count: Word): Word;

{ FreeSelector frees a selector using Dpmi function 0001H. }

function FreeSelector (Selector: Word): Boolean;

{ SegmentToSelector maps a real mode segment onto a selector using Dpmi    }
{ function 0002H. The return value is a selector, or zero if the function  }
{ is unsuccessful. Selectors allocated with this function are permanent    }
{ and can never be freed. If you need a temporary selector or pointer, use }
{ the AllocRealSelector or AllocRealPtr functions instead                  }

function SegmentToSelector (Segment: Word): Word;

{ SelectorToSegment returns the real mode segment address (paragraph) that }
{ corresponds to the base address of the given selector. The selector is   }
{ assumed to be a valid selector that references real mode memory. If this }
{ is not the case, the return value is undefined                           }

function SelectorToSegment (Selector: Word): Word;

{ GetSelectorBase returns the 32-bit linear base address of a selector }
{ using Dpmi function 0006H. The return value is zero if the function  }
{ is unsuccessful                                                      }

function GetSelectorBase (Selector: Word): LongInt;

{ SetSelectorBase sets the 32-bit linear base address of a selector }
{ using Dpmi function 0007H                                         }

function SetSelectorBase (Selector: Word; Base: LongInt): Boolean;

{ GetSelectorLimit returns the limit of the specified selector. The }
{ return value is zero if the selector is invalid                   }

function GetSelectorLimit (Selector: Word): LongInt;

{ SetSelectorLimit sets the limit of a selector using Dpmi function 0008H }

function SetSelectorLimit (Selector: Word; Limit: LongInt): Boolean;

{ GetAccessRights returns the access rights for a selector. The return }
{ value is zero if the selector is invalid                             }

function GetAccessRights (Selector: Word): Word;

{ SetAccessRights sets the access rights for a selector using Dpmi }
{ function 0009H                                                   }

function SetAccessRights (Selector: Word; AccessRights: Word): Boolean;

{ AllocSelectorAlias creates an aliased selector using Dpmi function }
{ 000AH. The return value is a selector, or zero if the function is  }
{ unsuccessful                                                       }

function AllocSelectorAlias (Selector: Word): Word;

{ GetDescriptor copies the LDT entry for the given selector into the }
{ given descriptor record using Dpmi function 000BH                  }

function GetDescriptor (Selector: Word; var Descriptor: TDescriptor): Boolean;

{ SetDescriptor copies the given descriptor record into the LDT entry }
{ for the given selector using Dpmi function 000CH                    }

function SetDescriptor (Selector: Word; var Descriptor: TDescriptor): Boolean;

{ AllocSpecificSelector allocates a specific selector using Dpmi function  }
{ 000DH. The return value is True if the selector was allocated. Otherwise }
{ the return value is False                                                }

function AllocSpecificSelector (Selector: Word): Boolean;

{ GetRealModeInt returns the contents of the given real mode interrupt }
{ vector using Dpmi function 0200H                                     }

function GetRealModeInt (Int: Byte): Pointer;

{ SetRealModeInt sets the interrupt vector for the specified real mode }
{ interrupt using Dpmi function 0201H                                  }

function SetRealModeInt (Int: Byte; Vector: Pointer): Boolean;

{ GetException returns the contents of the given exception vector using }
{ Dpmi function 0202H                                                   }

function GetException (Exception: Byte): Pointer;

{ SetException sets the exception vector for the specified exception }
{ using Dpmi function 0203H                                          }

function SetException (Exception: Byte; Vector: Pointer): Boolean;

{ GetProtModeInt returns the contents of the given protected mode }
{ interrupt vector using Dpmi function 0204H                      }

function GetProtModeInt (Int: Byte): Pointer;

{ SetProtModeInt sets the interrupt vector for the specified protected }
{ mode interrupt using Dpmi function 0205H                             }

function SetProtModeInt (Int: Byte; Vector: Pointer): Boolean;

{ RealModeInt simulates a software interrupt instruction in real mode }
{ using Dpmi function 0300H                                           }

function RealModeInt (Int: Byte; var Regs: TRealModeRegs): Boolean;

{ RealModeCall calls a real mode procedure with a far return frame using }
{ Dpmi function 0301H                                                    }

function RealModeCall (Proc: Pointer; var Regs: TRealModeRegs): Boolean;

{ RealModeIntCall calls a real mode procedure with an interrupt return }
{ frame using Dpmi function 0302H                                      }

function RealModeIntCall (Proc: Pointer; var Regs: TRealModeRegs): Boolean;

{ AllocCallback allocates a real mode callback using Dpmi function 0303H. }
{ The return value is the real mode address of the callback, or zero if   }
{ the function is unsuccessful                                            }

function AllocCallback (Proc: Pointer; var Regs: TRealModeRegs): Pointer;

{ FreeCallback frees a real mode callback using DPMI function 0304H }

function FreeCallback (Callback: Pointer): Boolean;

{ GetVersionInfo returns Dpmi version information in the specified version }
{ information record using Dpmi function 0400H                             }

procedure GetVersionInfo (var Info: TVersionInfo);

{ SetInterruptState sets the virtual interrupt state to the specified   }
{ value and returns the previous virtual interrupt state, corresponding }
{ to Dpmi functions 0900H and 0901H                                     }

function SetInterruptState (Enable: Boolean): Boolean;

{ GetInterruptState returns the current virtual interrupt state using }
{ Dpmi function 0902H                                                 }

function GetInterruptState: Boolean;

{ AllocRealSelector allocates a new selector and maps it onto the given    }
{ real mode segment address. The return value is a selector, or zero if    }
{ the function is unsuccessful. This function corresponds to Dpmi function }
{ 0002H, except that the resulting selector can be freed (using Dpmi       }
{ function 0001H) if required                                              }

function AllocRealSelector (Segment: Word): Word;

{ AllocRealPtr corresponds to AllocRealSelector, except that it works on  }
{ pointers instead of segments and selectors. The return value is a       }
{ protected mode pointer that points to the same physical memory location }
{ as the specified real mode pointer. If the function is unsuccessful the }
{ return value is NIL                                                     }

function AllocRealPtr (RealAddr: Pointer): Pointer;

{ FreeRealPtr frees the selector used in a pointer that was allocated by }
{ AllocRealPtr                                                           }

function FreeRealPtr (RealPtr: Pointer): Boolean;

{ MemInitSwapFile opens a swapfile of size FileSize. If file exists and }
{ new size is larger, this function will grow the swap file, otherwise  }
{ the call has no effect. File size is limited to 2 gigabytes.          }
{                                                                       }
{                                                                       }
{ Returns:                                                              }
{     rtmOK           - Successful                                      }
{     rtmNoMemory     - Not enough disk space                           }
{     rtmFileIOError  - Could not open/grow file                        }

function MemInitSwapFile (FileName: PChar; FileSize: LongInt): Integer;

{ MemCloseSwapFile closes the swapfile if it was created by the current }
{ task. If Delete is non 0, the swap file is deleted.                   }
{                                                                       }
{                                                                       }
{ Returns:                                                              }
{     rtmOK           - Successful                                      }
{     rtmNoMemory     - Not enough physical memory to run without       }
{                       swap file                                       }
{     rtmFileIOError  - Could not close/delete the file                 }

function MemCloseSwapFile (Delete: Integer): Integer;

implementation

var
  VersionInfo : TVersionInfo;
  Regs        : Registers;
  RealModeRegs: TRealModeRegs;
  DPMIBits    : Integer;
  SelIncr     : Integer;

function DpmiIntr (IntNo: Byte; var Regs: Registers): Boolean;

var
  Err: Integer;

begin
  FillChar (RealModeRegs,SizeOf (TRealModeRegs),0);
  RealModeRegs.AX := Regs.AX;
  RealModeRegs.BX := Regs.BX;
  RealModeRegs.CX := Regs.CX;
  RealModeRegs.DX := Regs.DX;
  RealModeRegs.DI := Regs.DI;
  RealModeRegs.SI := Regs.SI;
  RealModeRegs.BP := Regs.BP;
  RealModeRegs.DS := Regs.DS;
  RealModeRegs.ES := Regs.ES;
  asm
        MOV     AX,SEG RealModeRegs
        MOV     ES,AX
        CMP     DPMIBits,16
        JE      @@1
        DB      66H
        MOV     DI,OFFSET RealModeRegs
        DW      0000H
        JMP     @@2
  @@1:  MOV     DI,OFFSET RealModeRegs
  @@2:  MOV     BL,IntNo
        XOR     BH,BH
        XOR     CX,CX
        MOV     AX,0300H
        INT     31H
        XOR     AX,AX
        JNC     @@3
        MOV     AX,-31
  @@3:  MOV     Err,AX
  end;
  if Err = 0 then
  begin
    Regs.AX := RealModeRegs.AX;
    Regs.BX := RealModeRegs.BX;
    Regs.CX := RealModeRegs.CX;
    Regs.DX := RealModeRegs.DX;
    Regs.DI := RealModeRegs.DI;
    Regs.SI := RealModeRegs.SI;
    Regs.BP := RealModeRegs.BP;
    Regs.DS := RealModeRegs.DS;
    Regs.ES := RealModeRegs.ES;
    Regs.Flags := RealModeRegs.Flags
  end;
  DpmiIntr := Err = 0
end;

function DpmiMsDos (var Regs: Registers): Boolean;

begin
  DpmiMsDos := DpmiIntr ($21,Regs)
end;

function DpmiGetMem (var P: Pointer; var Segment: Word;
  var Size: Longint): Boolean;

begin
  Regs.AX := $0100;
  Regs.BX := (Size + 15) div 16;
  if Regs.BX = 0 then Regs.BX := $FFFF;     { Size > $000FFFF0      }
  Size := Regs.BX;                          { calculates memory     }
  Size := Size * 16;                        { effectively allocated }
  Intr ($31,Regs);
  DpmiGetMem := Regs.Flags and fCarry = 0;
  if Regs.Flags and fCarry = 0 then
  begin
    P := Ptr (Regs.DX,0);                   { selector:offset pointer }
    Segment := Regs.AX                      { segment for real mode   }
  end
  else begin
    Size := Regs.BX;                        { size of the largest }
    Size := Size * 16                       { available block     }
  end
end;

function DpmiFreeMem (var P: Pointer): Boolean;

begin
  Regs.AX := $0101;
  Regs.DX := Seg (P^);
  Intr ($31,Regs);
  P := NIL;
  DpmiFreeMem := Regs.Flags and fCarry = 0
end;

procedure IncSelector (var Selector: Word);

begin
  Inc (Selector,SelIncr)
end;

function AllocSelectors (Count: Word): Word; assembler;

asm
      MOV     CX,Count
      MOV     AX,0000H
      INT     31H
      JNC     @@1
      XOR     AX,AX
@@1:
end;

function FreeSelector (Selector: Word): Boolean; assembler;

asm
      MOV     BX,Selector
      MOV     AX,0001H
      INT     31H
      SBB     AX, AX
      INC     AX
end;

function SegmentToSelector (Segment: Word): Word; assembler;

asm
      MOV     BX,Segment
      MOV     AX,0002H
      INT     31H
      JNC     @@1
      XOR     AX,AX
@@1:
end;

function SelectorToSegment (Selector: Word): Word; assembler;

asm
      MOV     BX,Selector
      MOV     AX,0006H
      INT     31H
      MOV     AX,DX
      OR      AX,CX
      ROR     AX,4
end;

function GetSelectorBase (Selector: Word): LongInt; assembler;

asm
      MOV     BX,Selector
      MOV     AX,0006H
      INT     31H
      JNC     @@1
      XCHG    AX,CX
      XCHG    AX,DX
      JNC     @@1
      XOR     AX,AX
      CWD
@@1:
end;

function SetSelectorBase (Selector: Word; Base: LongInt): Boolean; assembler;

asm
      MOV     BX,Selector
      MOV     DX,Base.Word[0]
      MOV     CX,Base.Word[2]
      MOV     AX,0007H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function GetSelectorLimit (Selector: Word): LongInt; assembler;

asm
      XOR     AX,AX
      LSL     AX,Selector
      XOR     DX,DX
end;

function SetSelectorLimit (Selector: Word; Limit: LongInt): Boolean; assembler;

asm
      MOV     BX,Selector
      MOV     DX,Limit.Word[0]
      MOV     CX,Limit.Word[2]
      MOV     AX,0008H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function GetAccessRights (Selector: Word): Word; assembler;

asm
      XOR     AX,AX
      LAR     AX,Selector
      XCHG    AL,AH
end;

function SetAccessRights (Selector: Word; AccessRights: Word): Boolean;
  assembler;

asm
      MOV     BX,Selector
      MOV     CX,AccessRights
      MOV     AX,0009H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function AllocSelectorAlias (Selector: Word): Word; assembler;

asm
      MOV     BX,Selector
      MOV     AX,000AH
      INT     31H
      JNC     @@1
      XOR     AX,AX
@@1:
end;

function GetDescriptor (Selector: Word; var Descriptor: TDescriptor): Boolean;
  assembler;

asm
      MOV     BX,Selector
      LES     DI,Descriptor
      MOV     AX,000BH
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function SetDescriptor (Selector: Word; var Descriptor: TDescriptor): Boolean;
  assembler;

asm
      MOV     BX,Selector
      LES     DI,Descriptor
      MOV     AX,000CH
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function AllocSpecificSelector (Selector: Word): Boolean; assembler;

asm
      MOV     BX,Selector
      MOV     AX,000DH
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function GetRealModeInt (Int: Byte): Pointer; assembler;

asm
      MOV     BL,Int
      MOV     AX,0200H
      INT     31H
      XCHG    AX,CX
      XCHG    AX,DX
      JNC     @@1
      XOR     AX,AX
      CWD
@@1:
end;

function SetRealModeInt (Int: Byte; Vector: Pointer): Boolean; assembler;

asm
      MOV     BL,Int
      MOV     DX,Vector.Word[0]
      MOV     CX,Vector.Word[2]
      MOV     AX,0201H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function GetException (Exception: Byte): Pointer; assembler;

asm
      MOV     BL,Exception
      MOV     AX,0202H
      INT     31H
      XCHG    AX,CX
      XCHG    AX,DX
      JNC     @@1
      XOR     AX,AX
      CWD
@@1:
end;

function SetException (Exception: Byte; Vector: Pointer): Boolean; assembler;

asm
      MOV     BL,Exception
      MOV     DX,Vector.Word[0]
      MOV     CX,Vector.Word[2]
      MOV     AX,0203H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function GetProtModeInt (Int: Byte): Pointer; assembler;

asm
      MOV     BL,Int
      MOV     AX,0204H
      INT     31H
      MOV     AX,DX
      MOV     DX,CX
end;

function SetProtModeInt (Int: Byte; Vector: Pointer): Boolean; assembler;

asm
      MOV     BL,Int
      MOV     DX,Vector.Word[0]
      MOV     CX,Vector.Word[2]
      MOV     AX,0205H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function RealModeInt (Int: Byte; var Regs: TRealModeRegs): Boolean; assembler;

asm
      MOV     BL,Int
      XOR     BH,BH
      XOR     CX,CX
      LES     DI,Regs
      MOV     AX,0300H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function RealModeCall (Proc: Pointer; var Regs: TRealModeRegs): Boolean;
  assembler;

asm
      XOR     BH,BH
      XOR     CX,CX
      LES     DI,Regs
      MOV     AX,Proc.Word[0]
      MOV     ES:[DI].TRealModeRegs.&IP,AX
      MOV     AX,Proc.Word[2]
      MOV     ES:[DI].TRealModeRegs.&CS,AX
      MOV     AX,0301H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function RealModeIntCall (Proc: Pointer; var Regs: TRealModeRegs): Boolean;
  assembler;

asm
      XOR     BH,BH
      XOR     CX,CX
      LES     DI,Regs
      MOV     AX,Proc.Word[0]
      MOV     ES:[DI].TRealModeRegs.&IP,AX
      MOV     AX,Proc.Word[2]
      MOV     ES:[DI].TRealModeRegs.&CS,AX
      MOV     AX,0302H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

function AllocCallback (Proc: Pointer; var Regs: TRealModeRegs): Pointer;
  assembler;

asm
      PUSH    DS
      LDS     SI,Proc
      LES     DI,Regs
      MOV     AX,0303H
      INT     31H
      POP     DS
      XCHG    AX,CX
      XCHG    AX,DX
      JNC     @@1
      XOR     AX,AX
      CWD
@@1:
end;

function FreeCallback (Callback: Pointer): Boolean; assembler;

asm
      MOV     DX,Callback.Word[0]
      MOV     CX,Callback.Word[2]
      MOV     AX,0304H
      INT     31H
      SBB     AX,AX
      INC     AX
end;

procedure GetVersionInfo (var Info: TVersionInfo); assembler;

asm
      MOV     AX,0400H
      INT     31H
      LES     DI,Info
      CLD
      STOSW
      XCHG    AX,BX
      STOSW
      XCHG    AX,CX
      STOSW
      XCHG    AX,DX
      STOSW
end;

function SetInterruptState (Enable: Boolean): Boolean; assembler;

asm
      MOV     AL,Enable
      MOV     AH,09H
      INT     31H
end;

function GetInterruptState: Boolean; assembler;

asm
      MOV     AX,0902H
      INT     31H
end;

function AllocRealSelector (Segment: Word): Word; assembler;

asm
      XOR     BX,BX
      MOV     AX,0000H
      MOV     CX,1
      INT     31H
      JC      @@1
      MOV     BX,AX
      MOV     DX,Segment
      ROL     DX,4
      MOV     CX,DX
      AND     DL,0F0H
      AND     CX,0FH
      MOV     AX,0007H
      INT     31H
      MOV     DX,0FFFFH
      XOR     CX,CX
      MOV     AX,0008H
      INT     31H
@@1:  MOV     AX,BX
end;

function AllocRealPtr (RealAddr: Pointer): Pointer; assembler;

asm
      PUSH    RealAddr.Word[2]
      CALL    AllocRealSelector
      MOV     DX,AX
      OR      AX,AX
      JE      @@1
      MOV     AX,RealAddr.Word[0]
@@1:
end;

function FreeRealPtr (RealPtr: Pointer): Boolean; assembler;

asm
      PUSH    RealPtr.Word[2]
      CALL    FreeSelector
end;

function MemInitSwapFile;  external 'RTM' index 35;
function MemCloseSwapFile; external 'RTM' index 36;

begin
  GetVersionInfo (VersionInfo);          { info on Dpmi services }
  if VersionInfo.Flags and 1 <> 0 then   { 16 or 32 bit implementation }
    DPMIBits := 32
  else DPMIBits := 16;
  Regs.AX := $0003;              { calculates the value to add to a }
  Intr ($31,Regs);               { selector if memory allocation is }
  SelIncr := Regs.AX             { greater than 64 K                }
end.

*)

{ ---------------------------- }
{ Test program for Drives unit }
{ ---------------------------- }

(*

program Test;

uses
  Dos,
  Drives;

var
  AllDrives: DriveSet;
  D        : DriveLetters;
  DriveType: LongInt;
  S        : String;

function GetVolumeLabel (Drive: Char): String;

var
  SR: SearchRec;

begin
  GetVolumeLabel := '';
  FindFirst (Drive + ':\*.*',VolumeID,SR);
  if DosError = 0 then GetVolumeLabel := SR.Name
end;

begin
  GetDrives (AllDrives);
  for D := 'A' to 'Z' do
  begin
    if NOT (D in AllDrives) then Continue;
    DriveType := GetDriveType (D);
    if DriveType = dtInvalid then Continue;
    if DriveType and dtUnknown = dtUnknown then
    begin
      S := 'unknown drive';
      if DriveType and dtRemote = dtRemote then
        S := 'remote ' + S
      else S := 'local ' + S
    end
    else if DriveType and dtAnyFloppy <> 0 then
    begin
      S := ' floppy disk';
      case DriveType and dtAnyFloppy of
        dt8Single: S := '8" single density' + S;
        dt8Double: S := '8" double density' + S;
        dt360    : S := '320/360 KB' + S;
        dt720    : S := '720 KB' + S;
        dt1200   : S := '1.2 MB' + S;
        dt1440   : S := '1.44 MB' + S;
        dt2880   : S := '2.88 MB' + S
      end
    end
    else if DriveType and dtTape = dtTape then
    begin
      S := ' tape drive';
      if DriveType and dtRemote = dtRemote then
        S := 'remote' + S
      else S := 'local' + S
    end
    else if DriveType and dtFloptical = dtFloptical then
    begin
      S := ' floptical drive';
      if DriveType and dtRemote = dtRemote then
        S := 'remote' + S
      else S := 'local' + S
    end
    else if DriveType and dtCDRom = dtCDRom then
    begin
      S := ' CD-ROM drive';
      if DriveType and dtRemote = dtRemote then
        S := 'remote' + S
      else S := 'local' + S
    end
    else if DriveType and dtIomegaZip = dtIomegaZip then
    begin
      S := ' Iomega Zip drive';
      if DriveType and dtRemote = dtRemote then
        S := 'remote' + S
      else S := 'local' + S
    end
    else begin
      if DriveType and dtRemovable = dtRemovable then
      begin
        S := ' removable media';
        if DriveType and dtRemote = dtRemote then
          S := 'remote' + S
        else S := 'local' + S
      end
      else begin
        S := 'volume ' + GetVolumeLabel (D) + ' (';
        if DriveType and dtRemote = dtRemote then
          S := S + 'remote '
        else S := S + 'local ';
        if DriveType and dtRamDisk = dtRamDisk then
        begin
          S := S + 'ram';
          if Pos ('.',S) > 0 then Delete (S,Pos ('.',S),1)
        end
        else S := S + 'hard';
        S := S + ' disk)'
      end
    end;
    S := D + ': ' + S;
    WriteLn (S)
  end
end.

*)
