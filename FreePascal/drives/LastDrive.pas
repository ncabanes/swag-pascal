(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0039.PAS
  Description: Last Drive
  Author: ROB GREEN
  Date: 08-27-93  20:50
*)

{
ROB GREEN

> do any of you guys know how to figure out which drive is the last drive
> on someone's system?  I was think of making a drive With Dos's
}

Uses
  Dos;

Function driveexist(ch : Char) : Boolean;
begin
  DriveExist := disksize(ord(upcase(ch)) - 64) <> - 1;
end;


{ Kerry Sokalsky }

Const
  exist : Boolean  = True;
  ch    : Integer  = 67;   { 'C' - Skip floppy Drives (A&B) }
  lastdrive : Char = ' ';

begin
  While LastDrive = ' ' do
  begin
    if driveexist(Chr(ch)) then
      Inc(Ch)
    else
      LastDrive := Chr(Ch - 1);
  end;

  Writeln(LastDrive);
end.
