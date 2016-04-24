(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0077.PAS
  Description: Drive Detection
  Author: ANDREW EIGUS
  Date: 08-24-94  13:32
*)

{
 SA> Does anyone have any idea of how I can check the system hardware and
 SA> identify available hard drives and disk drives?
}



const
  { GetDriveType return values.  REQUIRES DOS 3.x or greater}

  dtError     = 0; { Drive physically isn't available }
  dtRemote    = 1; { Remote (network) disk drive }
  dtFixed     = 2; { Fixed (hard) disk drive }
  dtRemovable = 3; { Removable (floppy) disk drive }
  dtBadVer    = $FF; { Invalid DOS version (DOS 3.x required) }


Function GetDriveType(Drive : byte) : byte; assembler;
Asm
  MOV AH,30h
  INT 21h
  CMP AL,3
  JGE @@1
  MOV AL,dtBadVer
  JMP @@4
@@1:
  MOV BL,Drive
  MOV AX,4409h
  INT 21h
  JNC @@2
  MOV AL,dtError
  JMP @@5
@@2:
  CMP AL,True
  JNE @@3
  MOV AL,dtRemote
  JMP @@5
@@3:
  MOV AX,4408h
  INT 21h
  CMP AL,True
  JNE @@4
  MOV AL,dtFixed
  JMP @@5
@@4:
  MOV AL,dtRemovable
@@5:
End; { GetDriveType }

var
  Drive : byte;
  DT : byte;

Begin
  for Drive := 1 to 25 do
  begin
    DT := GetDriveType(Drive);
    if DT <> dtError then
    begin
      Write('Drive ', Chr(Drive + 64), ': ');
      case DT of
        dtRemote: WriteLn('Network drive');
        dtFixed: WriteLn('Hard disk');
        dtRemovable: WriteLn('Floppy drive')
      end
    end
  end
End.


