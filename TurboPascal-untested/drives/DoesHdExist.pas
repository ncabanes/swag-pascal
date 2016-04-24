(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0013.PAS
  Description: Does HD Exist
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

Program CheckForHDExistence;
Uses
  Dos;

Function checkdsk(drive:Char):Boolean;
begin
  checkdsk:=disksize(Byte(upcase(drive))-64)>0;
end;

begin
   { Doesn't work For Floppies unless a disk is present }
   if checkdsk('A') then Writeln('Valid! A')
   else Writeln('Not Valid A');
   if checkdsk('B') then Writeln('Valid! B')
   else Writeln('Not Valid B');
   if checkdsk('C') then Writeln('Valid! C')
   else Writeln('Not Valid C');
   if checkdsk('D') then Writeln('Valid! D')
   else Writeln('Not Valid D');
   if checkdsk('E') then Writeln('Valid! E')
   else Writeln('Not Valid E');
   if checkdsk('F') then Writeln('Valid! F')
   else Writeln('Not Valid F');
end.


