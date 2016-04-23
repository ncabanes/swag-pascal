{
> Can someone please post some code on how to read a disk
> label/serial number from a disk. I plan to use it as a copy
> protection method (read the label/serial number on installation
> and only the program to install on a drive the same
> label/serial number) Thanks!
}

const BSize    = 4096; { I/O Buffer Size }
      HexDigits: array[0..15] of char = '0123456789ABCDEF';
type  InfoBuffer = record
                     InfoLevel  : word;  {should be zero}
                     Serial     : Longint;
                     VolLabel   : array[0..10] of Char;
                     FileSystem : array[0..7] of Char
                   end;
      SerString = String[9];
      DTA_Type          = record
                            Flag   : byte;
                            Res1   : array [1..5] of byte;
                            Mask   : Byte;
                            Drive  : Byte;
                            Name   : array [1..8] of Char;
                            Ext    : array [1..3] of char;
                            Attrx  : byte;
                            Filler : array [12..21] of byte;
                            Time,
                            Date,
                            Cluster,
                            Size1,
                            Size2  : integer;
                          end;
      FCB_Type          = record
                            Flag   : byte;
                            Res1   : array [1..5] of byte;
                            Mask   : Byte;
                            Drive  : Byte;
                            Name   : array [1..8] of Char;
                            Ext    : array [1..3] of char;
                            Current_Block,
                            Record_Size,
                            Size1,
                            Size2,
                            Date   : integer;
                            Filler : array [22..31] of byte;
                            Record_No : byte;
                            File_No_1,
                            File_No_2 : integer
                          end;
      DiskIDType        = String[11];
      STR12             = string[12];
      STR8              = string[8];
      STR4              = string[4];
      MEDBUF       = array[1..4096] of char;
var   Drive_Mask   : byte;
      CH, CH1      : char;
      DEVICE       : char;                                      { Disk Device }
      BIN,BOUT,
      BWORK        : ^MEDBUF;
      F            : File;
      SNAME        : String;
      DATE         : string[8];                  { formatted date as YY/MM/DD }
      TIME         : string[5];                  {     "     time as HH:MM    }
      DISKNAME     : string[15];
      GARB         : string[6];                        { extraneous device id }
      DirInfo      : SearchRec;                       { File name search type }
      SR           : SearchRec;
      DT           : DateTime;
      PATH         : PathStr;
      DIR          : DirStr;
      FNAME        : NameStr;
      EXT          : ExtStr;
      FCB          : FCB_Type;
      DTA          : DTA_Type;
      Regs         : Registers;
      Temp         : String[1];
      DiskID       : DiskIDType;
      NewDiskID    : DiskIDType;
      BUFF         : array[1..BSize] of Byte;
      IB           : InfoBuffer;
      S            : string[11];

function SerialStr(L : longint) : SerString;
var Temp : SerString;
begin
  Temp[0] := #9;
  Temp[1] := HexDigits[L shr 28];
  Temp[2] := HexDigits[(L shr 24) and $F];
  Temp[3] := HexDigits[(L shr 20) and $F];
  Temp[4] := HexDigits[(L shr 16) and $F];
  Temp[5] := '-';
  Temp[6] := HexDigits[(L shr 12) and $F];
  Temp[7] := HexDigits[(L shr 8) and $F];
  Temp[8] := HexDigits[(L shr 4) and $F];
  Temp[9] := HexDigits[L and $F];
  SerialStr :=Temp;
end;

procedure INITS;                              { basic FCB, DTA initialization }
begin
  Drive_Mask := Ord(DEVICE) - 64;
  with Regs do
    begin
      AH := $1A; DS := Seg(DTA); DX := Ofs(DTA); MSDOS (Regs);
    end;
  with FCB do
    begin
      Flag := $FF; Mask := $08;
      for I := 1 to 5 do
        Res1[I] := 0;
      Drive := Drive_Mask; Name := '????????'; Ext := '???';
    end;
end;  { INITS }

function GetSerial(DiskNum : byte; var I : InfoBuffer) : word;
assembler;
  asm
    MOV AH, 69h
    MOV AL, 00h
    MOV BL, DiskNum
    PUSH DS
    LDS DX, I
    INT 21h
    POP DS
    JC @Bad
    XOR AX, AX
  @Bad:
end;

function SetSerial(DiskNum : byte; var I : InfoBuffer) : word;
Assembler;
  asm
    MOV AH, 69h
    MOV AL, 00h
    MOV BL, DiskNum
    PUSH DS
    LDS DX, I
    INT 21h
    POP DS
    JC @Bad
    XOR AX, AX
  @Bad:
end;

function GetDiskID (Drive : char): DiskIDType;
var DirDiskID : STR12;
    PosPeriod : Byte;
begin
  FindFirst (DEVICE+':\*.*',VolumeID,DirInfo);
  if DosError = 0 then
    begin
      DirDiskID := DirInfo.Name; PosPeriod := Pos('.',DirDiskID);
      if PosPeriod > 0 then System.Delete(DirDiskID,PosPeriod,1);
      GetDiskID := DirDiskID;
      GetSerial (Drive_Mask,IB);                           { Get Disk Serial# }
    end
  else GetDiskID := '';
end;  { GetDiskID }

function SetDiskID (DiskID : DiskIDType): Boolean;       { SET a volume label }
begin
  with FCB do
    begin
      FillChar (Name[1],11,' ');                             { blank out name }
      Move (DiskID[1],Name[1],Length(DiskID));
    end;
  with Regs do
    begin
      AH := $16; DS := Seg(FCB); DX := Ofs(FCB);
      MsDos(Regs); SetDiskID := AL = 0
    end
end;  { SetDiskID }

function DeleteDiskID : boolean;                      { DELETE a volume label }
begin
  with Regs do
    begin
      AH := $13; DS := Seg(FCB); DX := Ofs(FCB);
      MsDos(Regs); DeleteDiskID := AL = 0;
    end
end;  { DeleteDiskID }

function ReNameDiskID (NewDiskID : DiskIDType): Boolean;    { RENAME a volume }
begin
  if not DeleteDiskID then writeln ('Delete Error: ',Regs.AL);
  if not SetDiskID (NewDiskID) then writeln ('Rename error: ',Regs.AL);
end;  { RenameDiskID }

procedure SetDiskInfo;
begin
  with Regs do
    begin
      AH := $36; DL := Drive_Mask; MsDos(Regs);
      ASZ := LongInt(CX * AX) * DX; FSZ := LongInt(AX * CX) * BX;
      USZ := ASZ - FSZ;                                         { amount free }
    end;
end;  { SetDiskInfo }

