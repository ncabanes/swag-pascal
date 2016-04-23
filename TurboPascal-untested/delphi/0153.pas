{
> >I've got code to do this in Turbo Pascal, using the DOS Services interrupt
> >(21), function number 69H.  But this does not work in Delphi.  I'm sure this
> >can be done using the DOS3CALL function, but I've tried and tried, and I can't
> >seem to get it to work.  Any ideas?
>
> >Mike
> >m.d.bews@swansea.ac.uk
>
> This will do it !
}
 unit Procs;

 interface

 uses
   Forms, DB, DBGrids, DBTables, Graphics, Classes, Dialogs;

 Type
      TRWBlock = Record
         rwSpecFunc: Byte;
         rwHead: Word;
         rwCylinder: Word;
         rwFirstSector: Word;
         rwSectors: Word;
         rwBufPtr: Pointer;
      End;

      TBootSector = Record
          bsJump: Array[0..2] of Byte;
          bsOemName: Array[0..7] of Char;
          bsBytesPerSec: Word;
          bsSecPerClust: Byte;
          bsResSectors: Word;
          bsFATs: Byte;
          bsRootDirEnts: Word;
          bsSectors: Word;
          bsMedia: Byte;
          bsFATSecs: Word;
          bsSecPerTrack: Word;
          bsHeads: Word;
          bsHiddensecs: Longint;
          bsHugeSectors: LongInt;
          bsDriveNumber: Byte;
          bsReserved: Byte;
          bsBootsignature: Byte;
          bsVolumeID: Array[0..3] of Byte;
          bsVolumeLabel: Array[0..10] of Char;
          bsFileSysType: Array[0..7] of Char;
      End;

 Const RWBlock: TRWBlock = (rwSpecFunc: 0;
                            rwHead: 0;
                            rwCylinder: 0;
                            rwfirstSector: 0;
                            rwSectors: 1;
                            rwBufPtr: nil);

 Function ReadBootSector(Drive: Word; Var BootSector: TBootsector): Boolean;

 implementation

 Uses MsgForm;

 Function ReadBootSector(Drive: Word; Var BootSector: TBootsector): Boolean;
 Var Buffer: Array[0..1023] of Byte; Status: Word;
 Begin
    RWBlock.rwBufPtr := addr(Buffer);
    asm
         mov         bx, Drive
         mov         ch, 08h
         mov         cl, 61h
         mov         dx, seg RWBlock
         mov         ds, dx
         mov         dx, offset RWBlock
         mov         ax, 440dh
         int         21h
         jc          @Error_handler
         jmp         @ok
      @Error_handler:
         mov         Status, ax
         jmp         @exit
      @ok:
         mov         status, 0
      @exit:
    End;
    ReadBootSector := Status = 0;
    If Status = 0 Then Move(Buffer, BootSector, SizeOf(TBootSector));
 End;

 end.

{ -------------  ANOTHER WAY TO DO IT -------------------- }

Type
  InfoBuffer = RECORD
    InfoLevel : WORD;
    Serial : DWord;
    VolLabel : ARRAY [0..10]OF CHAR;
    FileSystem : ARRAY [0..7]OF CHAR;
End;

Function TFMain.GetDiskSerNo(Drive : Byte) : String;
Const
  HexDigits : ARRAY [0..15]OF CHAR = '0123456789ABCDEF';
Var
  IB   : InfoBuffer;
  N    : WORD;

  Function SerialStr (L : LONGINT) : String;
  Var
    Temp : String;
  Begin
    {Temp [0] := #9; }
    Temp [1] := HexDigits [L SHR 28];
    Temp [2] := HexDigits [ (L SHR 24) AND $F];
    Temp [3] := HexDigits [ (L SHR 20) AND $F];
    Temp [4] := HexDigits [ (L SHR 16) AND $F];
    Temp [5] := '-';
    Temp [6] := HexDigits [ (L SHR 12) AND $F];
    Temp [7] := HexDigits [ (L SHR 8) AND $F];
    Temp [8] := HexDigits [ (L SHR 4) AND $F];
    Temp [9] := HexDigits [L AND $F];
    SerialStr := Temp;
  End;

  Function GetSerial (DiskNum : BYTE; VAR I : InfoBuffer) : WORD; assembler;
    asm
      MOV AH, 69h
      MOV AL, 00h
      MOV BL, DiskNum
      PUSH DS
      LDS DX, I  {error here "Operand Size Mismatch I"}
      INT 21h
      POP DS
      JC @Bad
      XOR AX, AX
      @Bad :
    end;

Begin
  N := GetSerial (Drive, IB);
  If N = 0 then
    Result := SerialStr (IB.Serial)
  else
    Result := 'Error Reading Disk';
End;

