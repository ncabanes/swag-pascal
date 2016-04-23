{$S-,R-,V-,I-,B-,F+,O+,A-,X+}

unit DDisk;
  {-Read and write absolute sectors using DOS int $25 and $26
    in protected mode under DOS or Windows. Does not support real mode.
    Requires BP7 or TPW 1.5.

    Based on the code in the OPDOS unit from Object Professional.

    Thanks to Maynard Riley and Mark Boler for work done on this unit.

    Notes:
      The calling parameters correspond to those in OPDOS.
      Drive = 0 corresponds to drive A.
      Sectors are typically 512 bytes each. NumSects*SectorSize must be
        less than 64K.
      Buf may be any buffer in a protected mode program. DDISK
        temporarily allocates a DOS real mode buffer, then copies
        the result into or out of Buf.
      If the function returns False, the DosError variable from the
        DOS or WINDOS unit may have a non-zero value with more information
        about the failure.

      Use DPMIWriteDiskSectors with caution!

    Version 1.0 (first public release) 7/19/94

    For more information, contact TurboPower Software
    CompuServe 76004,2611
  }

interface

function DPMIReadDiskSectors(Drive : Word;
                             FirstSect : LongInt; NumSects : Word;
                             var Buf) : Boolean;
  {-Read sectors using int $25}

function DPMIWriteDiskSectors(Drive : Word;
                              FirstSect : LongInt; NumSects : Word;
                              var Buf) : Boolean;
  {-Write sectors using int $26}

  {====================================================================}

implementation

uses
{$IFDEF DPMI}
  DOS,
{$ELSE}
  WinDOS,
{$ENDIF}
  WinAPI;

type
  DpmiRealBuf =
    object

    private
      Bytes   : LongInt;
      BufBase : LongInt;

    public
      constructor Init(BufBytes : LongInt);
      destructor Done;
      function Size : LongInt;
      function Segment : Word;
      function Selector : Word;
      function RealPtr : Pointer;
      function ProtPtr : Pointer;
    end;

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

  PacketPtr = ^PacketRec;
  PacketRec =
    record
      StartLo : Word;
      StartHi : Word;
      Count : Word;
      BufOfs : Word;
      BufSeg : Word;
    end;

  procedure GetRealModeIntVector(IntNo : Byte; var Vector : Pointer); assembler;
  asm
    mov     ax,0200h
    mov     bl,IntNo
    int     31h
    les     di,Vector
    mov     word ptr es:[di],dx
    mov     word ptr es:[di+2],cx
  end;

  function CallFarRealModeProc(var Regs : DPMIRegisters) : Word; assembler;
  asm
    mov     ax,0301h
    xor     bx,bx
    xor     cx,cx
    les     di,Regs
    int     31h
    jc      @@9
    xor     ax,ax
@@9:
  end;

  function DpmiRealBuf.Segment : Word;
  begin
    Segment := BufBase shr 16;
  end;

  function DpmiRealBuf.Selector : Word;
  begin
    Selector := BufBase and $FFFF;
  end;

  function DpmiRealBuf.RealPtr : Pointer;
  begin
    RealPtr := Ptr(BufBase shr 16, 0);
  end;

  function DpmiRealBuf.ProtPtr : Pointer;
  begin
    ProtPtr := Ptr(BufBase and $FFFF, 0);
  end;

  function DpmiRealBuf.Size : LongInt;
  begin
    Size := Bytes;
  end;

  constructor DpmiRealBuf.Init(BufBytes : LongInt);
  begin
    BufBase := GlobalDosAlloc(BufBytes);
    if BufBase = 0 then
      Fail;
    Bytes := BufBytes;
  end;

  destructor DpmiRealBuf.Done;
  begin
    GlobalDosFree(Selector);
  end;

type
  DiskInfoRec =
    object
      DriveNumber : Byte;
      ClustersAvailable : Word;
      TotalClusters : Word;
      BytesPerSector : Word;
      SectorsPerCluster : Word;
      constructor Init(d : Byte);
    end;

  constructor DiskInfoRec.Init(d : Byte);
  var
    Ok : Boolean;
  begin
    DriveNumber := d; { 0 = default ; 1 = 'A' }

    asm
      mov     dl,d
      mov     ah,$36
      int     $21
      cmp     ax,$FFFF
      je      @8

      les     di,Self
      mov     es:[di].SectorsPerCluster,ax
      mov     es:[di].ClustersAvailable,bx
      mov     es:[di].BytesPerSector,cx
      mov     es:[di].TotalClusters,dx
      mov     al,True
      jmp     @9

@8:   mov     al,False
@9:   mov     Ok,al
    end;

    if not Ok then
      Fail;
  end;

  function DPMIReadWrite(Drive : Word;
                         FirstSect : LongInt; NumSects : Word;
                         var Buf; Vector : Byte) : Boolean;
  var
    SaveInt : Pointer;
    Status : Word;
    BufBytes : LongInt;
    DiskInfo : DiskInfoRec;
    InterimBuf : DpmiRealBuf;
    PacketBuf : DpmiRealBuf;
    Regs : DPMIRegisters;
  begin
    DosError := 0;
    DPMIReadWrite := False;

    if not DiskInfo.Init(Drive+1) then
      Exit;

    BufBytes := LongInt(NumSects)*DiskInfo.BytesPerSector;
    if BufBytes > 65535 then
      Exit;
    if not InterimBuf.Init(BufBytes) then
      Exit;

    if not PacketBuf.Init(SizeOf(PacketRec)) then begin
      InterimBuf.Done;
      Exit;
    end;

    if Vector = $26 then
      Move(Buf, InterimBuf.ProtPtr^, BufBytes);

    FillChar(Regs, SizeOf(Regs), 0);
    with PacketPtr(PacketBuf.ProtPtr)^ do begin
      StartLo := FirstSect and $FFFF;
      StartHi := FirstSect shr 16;
      Count := NumSects;
      BufOfs := 0;
      BufSeg := InterimBuf.Segment;
    end;

    GetRealModeIntVector(Vector, SaveInt); { returns real mode seg:ofs }
    with Regs do begin
      CX := $FFFF;
      AX := Drive;
      BX := 0;
      DS := PacketBuf.Segment;
      CS := LongInt(SaveInt) shr 16;
      IP := LongInt(SaveInt) and $FFFF;
    end;
    Status := CallFarRealModeProc(Regs);

    if Status = 0 then
      if Odd(Regs.Flags) then
        DosError := Regs.AX
      else begin
        if Vector = $25 then
          Move(InterimBuf.ProtPtr^, Buf, BufBytes);
        DPMIReadWrite := True;
      end;

    PacketBuf.Done;
    InterimBuf.Done;
  end;

  function DPMIReadDiskSectors(Drive : Word;
                               FirstSect : LongInt; NumSects : Word;
                               var Buf) : Boolean;
  begin
    DPMIReadDiskSectors := DPMIReadWrite(Drive, FirstSect, NumSects, Buf, $25);
  end;

  function DPMIWriteDiskSectors(Drive : Word;
                                FirstSect : LongInt; NumSects : Word;
                                var Buf) : Boolean;
  begin
    DPMIWriteDiskSectors := DPMIReadWrite(Drive, FirstSect, NumSects, Buf, $26);
  end;

end.
