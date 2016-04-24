(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0080.PAS
  Description: Getting Disk Type
  Author: MARTIN RICHARDSON
  Date: 08-25-94  09:06
*)

{
MR│ How do you tell the difference between a fixed hard drive, and a
  │ removable drive or network drive?  Why? I have a program which reports

This little demo program contains the answers for most of your
questions.


{ uses int $21, service $44, subservices 8 & 9  to get drive
  existence, removeable/non-removeable, and local/remote status }

uses dos;

var drive   : word;
    ts      : string[30];
    r       : registers;
    drexist : boolean;

begin
      for drive := 1 to 26 do
        begin
          drexist := false;
          ts := 'unkn';

          r.ax := $4408;      { check for dos floppy/hard drv }
          r.bl := drive;
          msdos(r);
          if not odd(r.flags) then   { if not carry then ... }
            begin
              drexist := true;
              if (r.ax = 0) then ts := 'floppy' else ts := 'hard';
            end;

          r.ax := $4409;      { check for local/remote (lan) drv }
          r.bl := drive;
          msdos(r);
          if not odd(r.flags) then
            begin
              drexist := true;
              if ((r.dh and $10) <> 0) then ts := 'remote';
            end;

          If DrExist then
            begin
              ts := chr(ord('A')+pred(drive))+':   ' + ts;
              writeln(ts);
            end;
        end;
end.

