(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0002.PAS
  Description: Change File Attribute #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{
JOE DICKSON

> I was wondering if someone could tell me how to change the Time and Date
> and maybe the Attribute of a File? Lets say I want to Change:
> FileNAME.EXT 1024 01-24-93 12:33p A  to:
> FileNAME.EXT 1024 01-01-93 01:00a AR
}

Program change_sample_Files_attribs;

Uses
  Dos;

Var
  f    : File;
  attr : Word;
  time : LongInt;
  DT   : datetime;

begin
  assign(f, 'FileNAME.EXT');
  DT.year  := 93;
  DT.month := 1;
  DT.day   := 1;
  dt.hour  := 1;
  dt.min   := 0;
  dt.sec   := 0;
  packtime(dt, time);
  attr     := ReadOnly;
  setftime(f, time);
  setfattr(f, attr);
end.

