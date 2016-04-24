(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0117.PAS
  Description: How can I detect a CD drive?
  Author: JOHN NEWLIN
  Date: 08-30-96  09:35
*)


unit DetectCD;

(*
  Detects whether or not a system drive is a CD-ROM or
  not.  Use with either version of Delphi.

  by John Newlin CIS 71535,665
*)

interface
uses
  {$IFDEF VER80}
  WinProcs, WinTypes,
  {$ELSE}
  Windows,
  {$ENDIF}
  SysUtils, Messages, Classes, Graphics, Controls;

function IsCdRom(DriveLetter:char):boolean;

implementation

{$IFDEF VER80}

function IsCdRom(DriveLetter:char):boolean;
var
  DriveNum:integer;
begin
  result := false;
  DriveNum := ord(UpCase(DriveLetter))-65;
  ASM
  MOV   AX,1500h { look for MSCDEX }
  XOR   BX,BX
  INT   2fh
  OR    BX,BX
  JZ    @Finish
  MOV   AX,150Bh { check for using CD driver }
  MOV   CX,DriveNum

  INT   2fh
  OR    AX,AX
  @Finish:
  mov   Result,Al
  END;
end;

{$ELSE}

function IsCdRom(DriveLetter:char):boolean;
Const
  RootPath : pAnsiChar = 'X:\';
begin
  RootPath[0] := DriveLetter;
  Result := IsCdRom(RootPath) = DRIVE_CDROM; {5}
end;

{$ENDIF}
end.

