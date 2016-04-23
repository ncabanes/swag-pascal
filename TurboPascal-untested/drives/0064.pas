unit GetDrive;

interface
uses
  Crt;

type
  TFCB = Record
    Drive: Byte;
    Name: array[0..7] of Char;
    Ext: array[0..2] of Char;
    CurBlock: Word;
    RecSize: Word;
    FileSize: LongInt;
    FileDate: Word;
    FileTime: Word;
    Reserved: array[0..7] of Char;
    CurRec: Byte;
    RandRec: LongInt;
  end;

  TDBP = Record
    Drive: Byte;
    AUnit: Byte;
    SectorSize: Word;
    Rest: array[0..28] of Byte;
  end;
  PDBP = ^TDBP;


procedure GetDrives;

implementation
var
  Sx: array[0..80] of Char;
  FCBx: TFCB;
  DBP: PDBP;

function ISOK(Drive: Byte): Boolean; assembler;
asm
  push ds
  mov dl, Drive
  mov ah, 32h
  int 21h
  cmp al, $FF
  jz  @error
  mov cx, ds
  mov es, cx
  pop ds
  mov word ptr DBP, bx
  mov word ptr DBP + 2, es
  mov al, 1
  jmp @Ok
@error:
  pop ds
  mov al, 0
@Ok:
end;


function GetInfo: Boolean; assembler;
asm
  push bp
  push ds
  mov si, seg Sx
  mov ds, si
  mov si, offset sx
  mov di, seg FCBx
  mov es, di
  mov di, offset fcbx
  mov al, 1
  mov ah, 29h
  int 21h
  mov bl, al
  mov ax, 1
  cmp bl, $FF
  jnz @Done
  mov ax, 0
@Done:
  pop ds
  pop bp
end;

procedure GetDrives;
var
  S1: String;
  i: Integer;
  bad: Boolean;
  S: PChar;

begin
  GetMem(S, 80);
  S1 := 'c:*.*';
  FillChar(FCBx, SizeOf(TFCB), #0);
  for i := 0 to 25 do begin
    S1[1] := Chr(i + 65);
    move(S1[1], Sx, Length(S1));
    S[Length(S1)] := #0;
    Bad := GetInfo;
    if bad then begin
      Write(S1);
      if (i = 0) or (i = 1) then
        WriteLn(' -> Normal')
      else
        if IsOk(i+1) then WriteLn(' -> Normal')
        else WriteLn(' -> Special');
    end;
  end;
  FreeMem(S, 80);
end;
end.

{ -------------------------------   DEMO  --------------------------- }

{
  This code shows how to find information about which drives
  exist on the system. It returns the information without
  ever causing an error message to appear on screen.

}
program Drives;
uses
  GetDrive,
  Crt;

begin
  ClrScr;
  GetDrives;
  ReadLn;
end.