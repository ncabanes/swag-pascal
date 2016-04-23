{ Gets the device type.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE dpDevType(Drive : byte;
          var Device_Type : byte;
           var Error_Code : byte);

{ DESCRIPTION:
    Gets the device type.
  SAMPLE CALL:
    dpDevType(1,Device_Type,Error_Code);
  ON ENTRY:
    Drive:
      1 : drive A:
      2 : drive B:
      and so on...
  RETURNS:
    Device_Type :
      0 : 320/360 KBytes floppy
      1 : 1.2 MBytes floppy
      2 : 720 KBytes floppy
      3 : 8" single density floppy
      4 : 8" double density floppy
      5 : hard disk
      6 : tape drive
      7 : 1.44 MBytes floppy
      8 : read/write optiocal disk
      9 : 2.88 MBytes floppy
      else : unknown device type
    Error_Code:
      0 : no error
      else : error number (see The PC Programmers Source Book 3.191)
  NOTES:
    Applies to all DOS versions beginning with v3.3.
    See dpDevType_Text() in order to get a string text. }

var
  TmpA   : array[0..31] of byte;
  HTregs : registers;

BEGIN { dpDevType }
  HTregs.AX := $440D;
  HTregs.BX := word(Drive);
  HTregs.CX := $0860;
  HTregs.DX := Ofs(TmpA);
  HTregs.DS := Seg(TmpA);
  MsDos(HTregs);
  if HTregs.Flags and FCarry <> 0 then
    begin
      Device_Type := $FF;          { on error returns unknown device type }
      Error_Code := HTregs.AL
    end
  else
    begin
      Device_Type := TmpA[1];
      Error_Code := 0;
    end;
END; { dpDevType }
