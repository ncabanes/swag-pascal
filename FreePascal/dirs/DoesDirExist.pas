(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0008.PAS
  Description: Does DIR Exist ?
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
  re: Finding a directory

>Obviously that's not the quickest routine in the world, and though
>it works, I was wondering if you have anything easier/faster?

  ...I don't know how much better this routine is, but you may
  want to give it a try:
}

{ Determine if a directory exists. }

uses Dos;

Function DirExist(st_Dir : DirStr) : Boolean;
Var
  wo_Fattr : Word;
  fi_Temp  : File;
begin
  assign(fi_Temp, (st_Dir + '.'));
  getfattr(fi_Temp, wo_Fattr);
  if (Doserror <> 0) then
    DirExist := False
  else
    DirExist := ((wo_Fattr and directory) <> 0)
end; { DirExist. }

{
notE: The "DirStr" Type definition is found in the standard TP
      Dos Unit. Add this Unit to your Program's "Uses" statement
      to use this routine.
}

begin
  if DirExist('dirs\') then
    WriteLn('Directory DIRS found')
  else
    WriteLn('Directory DIRS not found');
end.
