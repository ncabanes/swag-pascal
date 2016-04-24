(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0011.PAS
  Description: Another IS DRIVE READY
  Author: GAYLE DAVIS
  Date: 05-28-93  13:38
*)

{
Author : GAYLE DAVIS

> It will check For example, drive A:, and if there is no disk in the
>drive it will return False, if it is ready it will return True..

There is a problem that you will have to deal With here from the beginning.
First of all Dos can't easily tell if the problem is that you drive door is
open, say in drive 'A', or if the disk is unformatted or unreadable.  Here
is some code that I use to solve the problem using INT25.  do not TRY THIS
ON A HARD DRIVE.
}
Uses
  Dos;

Function DisketteDrives : Integer;
Var
  Regs : Registers;
begin
  FILLChar (Regs, SIZEOF (Regs), #0);
  INTR ($11, Regs);
  if Regs.AX and $0001 = 0 then
    DisketteDrives := 0
  else
    DisketteDrives := ( (Regs.AX SHL 8) SHR 14) + 1;
end;

Function IsDriveReady (DriveSpec : Char) : Boolean; {A,B,etc}
Var
  result : Word;
  Drive,
  number,
  logical : Word;
  buf    : Array [1..512] of Byte;
  Regs   : Registers;
begin
  IsDriveReady := True;     { Assume True to start }
  Drive   := ORD (UPCASE (DriveSpec) ) - 65;  { 0=a, 1=b, etc }

  if Drive > DisketteDrives then
    Exit;  { do not CHECK HARD DRIVES }

  number  := 1;
  logical := 1;

  Inline (
    $55 /                       { PUSH BP         ; Interrupt 25 trashes all}
    $1E /                       { PUSH DS         ; Store DS                }
    $33 / $C0 /                 { xor  AX,AX      ; set AX to zero          }
    $89 / $86 / result /        { MOV  Result, AX ; Move AX to Result       }
    $8A / $86 / Drive /         { MOV  AL, Drive  ; Move Drive to AL        }
    $8B / $8E / number /        { MOV  CX, Number ; Move Number to CX       }
    $8B / $96 / logical /       { MOV  DX, Logical; Move Logical to DX      }
    $C5 / $9e / buf /           { LDS  BX, Buf    ; Move Buf to DS:BX       }
    $CD / $25 /                 { INT  25h        ; Call interrupt $25      }
    $5B /                       { POP  BX         ; Remove the flags valu fr}
    $1F /                       { POP  DS         ; Restore DS              }
    $5D /                       { POP  BP         ; Restore BP              }
    $73 / $04 /                 { JNB  Done       ; Jump ...                }
    $89 / $86 / result);        { MOV  Result, AX ; move error code to AX   }
  { Done: }

  IsDriveReady := (result = 0);
end;

(*
Also, you could change the ISDRIVEREADY Function if you wanted to find out
WHY the drive isn't ready by checking the LO(result). Like this :

  if result <> 0 then
  begin
    Case LO (result) OF
      0     : FloppyState := WritePROTECT; { should not ever happen }
      1..4  : FloppyState := DOOROPEN;
      5..12 : FloppyState := NOFORMAT;
      else
        FloppyState := DOOROPEN;
    end
  end
  else
    FloppyState := DRIVEREADY;
*)

