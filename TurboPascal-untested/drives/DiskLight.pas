(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0045.PAS
  Description: DISK Light
  Author: DJ MURDOCK
  Date: 10-28-93  11:30
*)

(*
=========================================================================
Date: 10-02-93 (19:15)
From: D.J. Murdoch
Subj: Flashing The Disk Light
=========================================================================

THIS IS SAFE !!!!  All it does is turn the disk light ON/OFF.  Should
only be used on Floppy drives.

*)

USES Crt;

procedure turn_on_motor(drive:byte);
{ Remember to wait about a half second before trying to read! }
begin
     port[$3F2] := 12 + drive + 1 SHL (4 + drive);
end;

procedure turn_off_motor(drive:byte);
{ drive A = 0, drive B = 1 }
begin
     port[$3F2] := 12 + drive;
end;

VAR I : BYTE;

BEGIN

FOR I := 1 TO 10 DO  { let's make 'A' and 'B' flash for awhile }
    BEGIn
    Turn_On_Motor(0);
    Delay(100);
    Turn_Off_Motor(0);
    Delay(100);
    Turn_On_Motor(1);
    Delay(100);
    Turn_Off_Motor(1);
    Delay(100);
    END;
END.


