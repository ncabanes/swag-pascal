(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0013.PAS
  Description: Rename File #1
  Author: SWAG SUPPORT TEAM, minor changes by Nacho
  Date: 05-28-93  13:35
*)

{
> Does anybody know how to do a "fast" move of a File?
> ie: not copying it but just moving the FAT Record

  Yup.  In Pascal you can do it With the Rename command.  The Format is:

   Rename (Var F; NewName : String)

where F is a File Variable of any Type.

to move a File Really fast, and to avoid having to copy it somewhere first and
then deleting the original, do this:
}

Program MoveIt;  {No error checking done}
Var
   F : File;
   FName : String;
   NName : String;
begin
   FName := '1.pas';
   NName := '2.pas';

   Assign (F, FName);
   {NName:= new directory / File name}
   Rename (F, NName);
End.
