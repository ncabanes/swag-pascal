
This document contains the source code for a unit that is useful for
getting, setting, and deleting volume labels from a floppy or hard disk.
The code for getting a volume label uses the Delphi FindFirst function,
and the code for setting and deleting volume labels involves calling DOS
interrupt 21h, functions 16h and 13h respectively.  Since function 16h
isn't supported by Windows, it must be called through DPMI interrupt 31h,
function 300h.

{ *** BEGIN CODE FOR VOLLABEL UNIT *** }

unit VolLabel;

interface

uses Classes, SysUtils, WinProcs;

type
  EInterruptError = class(Exception);
  EDPMIError = class(EInterruptError);
  Str11 = String[11];

procedure SetVolumeLabel(NewLabel: Str11; Drive: Char);
function GetVolumeLabel(Drive: Char): Str11;
procedure DeleteVolumeLabel(Drv: Char);

implementation

type
  PRealModeRegs = ^TRealModeRegs;
  TRealModeRegs = record
    case Integer of
      0: (
        EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;

        Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word);
      1: (
        DI, DIH, SI, SIH, BP, BPH, XX, XXH: Word;
        case Integer of
          0: (
            BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
          1: (
            BL, BH, BLH, BHH, DL, DH, DLH, DHH,
            CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
  end;

  PExtendedFCB = ^TExtendedFCB;
  TExtendedFCB = Record
    ExtendedFCBflag : Byte;
    Reserved1       : array[1..5] of Byte;

    Attr            : Byte;
    DriveID         : Byte;
    FileName        : array[1..8] of Char;
    FileExt         : array[1..3] of Char;
    CurrentBlockNum : Word;
    RecordSize      : Word;
    FileSize        : LongInt;
    PackedDate      : Word;
    PackedTime      : Word;
    Reserved2       : array[1..8] of Byte;
    CurrentRecNum   : Byte;
    RandomRecNum    : LongInt;
  end;

procedure RealModeInt(Int: Byte; var Regs: TRealModeRegs);
{ procedure invokes int 31h function 0300h to simulate a real mode }

{ interrupt  from protected mode. }
var
  ErrorFlag: Boolean;
begin
  asm
    mov ErrorFlag, 0       { assume success }
    mov ax, 0300h          { function 300h }
    mov bl, Int            { real mode interrupt to execute }
    mov bh, 0              { required }
    mov cx, 0              { stack words to copy, assume zero }
    les di, Regs           { es:di = Regs }
    int 31h                { DPMI int 31h }
    jnc @@End              { carry flag set on error }

  @@Error:
    mov ErrorFlag, 1       { return false on error }
  @@End:
  end;
  if ErrorFlag then
    raise EDPMIError.Create('Failed to execute DPMI interrupt');
end;

function DriveLetterToNumber(DriveLet: Char): Byte;
{ function converts a character drive letter into its numerical equiv. }
begin
  if DriveLet in ['a'..'z'] then
    DriveLet := Chr(Ord(DriveLet) -32);
  if not (DriveLet in ['A'..'Z']) then
    raise EConvertError.CreateFmt('Cannot convert %s to drive number',

                                  [DriveLet]);
  Result := Ord(DriveLet) - 64;
end;

procedure PadVolumeLabel(var Name: Str11);
{ procedure pads Volume Label string with spaces }
var
  i: integer;
begin
  for i := Length(Name) + 1 to 11 do
    Name := Name + ' ';
end;

function GetVolumeLabel(Drive: Char): Str11;
{ function returns volume label of a disk }
var
  SR: TSearchRec;
  DriveLetter: Char;
  SearchString: String[7];
  P: Byte;
begin
  SearchString := Drive + ':\*.*';

  { find vol label }
  if FindFirst(SearchString, faVolumeID, SR) = 0 then begin
    P := Pos('.', SR.Name);
    if P > 0 then begin                      { if it has a dot... }
      Result := '           ';               { pad spaces between name }
      Move(SR.Name[1], Result[1], P - 1);    { and extension }
      Move(SR.Name[P + 1], Result[9], 3);
    end
    else begin
      Result := SR.Name;                     { otherwise, pad to end }
      PadVolumeLabel(Result);

    end;
  end
  else
    Result := '';
end;

procedure DeleteVolumeLabel(Drv: Char);
{ procedure deletes volume label from given drive }
var
  CurName: Str11;
  FCB: TExtendedFCB;
  ErrorFlag: WordBool;
begin
  ErrorFlag := False;
  CurName := GetVolumeLabel(Drv);        { get current volume label }
  FillChar(FCB, SizeOf(FCB), 0);         { initialize FCB with zeros }
  with FCB do begin
    ExtendedFCBflag := $FF;              { always }
    Attr := faVolumeID;                  { Volume ID attribute }

    DriveID := DriveLetterToNumber(Drv); { Drive number }
    Move(CurName[1], FileName, 8);       { must enter volume label }
    Move(CurName[9], FileExt, 3);
  end;
  asm
    push ds                              { preserve ds }
    mov ax, ss                           { put seg of FCB (ss) in ds }
    mov ds, ax
    lea dx, FCB                          { put offset of FCB in dx }
    mov ax, 1300h                        { function 13h }
    Call DOS3Call                        { invoke int 21h }

    pop ds                               { restore ds }
    cmp al, 00h                          { check for success }
    je @@End
  @@Error:                               { set flag on error }
    mov ErrorFlag, 1
  @@End:
  end;
  if ErrorFlag then
    raise EInterruptError.Create('Failed to delete volume name');
end;

procedure SetVolumeLabel(NewLabel: Str11; Drive: Char);
{ procedure sets volume label of a disk.  Note that this procedure }
{ deletes the current label before setting the new one.  This is }

{ required for the set function to work. }
var
  Regs: TRealModeRegs;
  FCB: PExtendedFCB;
  Buf: Longint;
begin
  PadVolumeLabel(NewLabel);
  if GetVolumeLabel(Drive) <> '' then           { if has label... }
    DeleteVolumeLabel(Drive);                   { delete label }
  Buf := GlobalDOSAlloc(SizeOf(PExtendedFCB));  { allocate real buffer }
  FCB := Ptr(LoWord(Buf), 0);
  FillChar(FCB^, SizeOf(FCB), 0);               { init FCB with zeros }
  with FCB^ do begin

    ExtendedFCBflag := $FF;                     { required }
    Attr := faVolumeID;                         { Volume ID attribute }
    DriveID := DriveLetterToNumber(Drive);      { Drive number }
    Move(NewLabel[1], FileName, 8);             { set new label }
    Move(NewLabel[9], FileExt, 3);
  end;
  FillChar(Regs, SizeOf(Regs), 0);
  with Regs do begin                            { SEGMENT of FCB }
    ds := HiWord(Buf);                          { offset = zero }

    dx := 0;
    ax := $1600;                                { function 16h }
  end;
  RealModeInt($21, Regs);                       { create file }
  if (Regs.al <> 0) then                        { check for success }
    raise EInterruptError.Create('Failed to create volume label');
end;

end.
{ *** END CODE FOR VOLLABEL UNIT *** }


