(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0015.PAS
  Description: Move File with Rename
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
│ I am interested in the source in Asm or TP to move a File from one
│ directory to another by means of the FAT table.

All you have to do is use the Rename Procedure.  It isn't done via the
FAT table, but via Dos Function 56h.  The only restrictions are (1)
you must be running on Dos 2.0 or greater, and (2) the original and
target directories must be on the same drive.  The code might look
something like this:
}

Function MoveFile( FileName, NewDir: Dos.PathStr ): Boolean;
Var
  f:      File;
  OldDir: Dos.DirStr;
  Nam:    Dos.NameStr;
  Ext:    Dos.ExtStr;
begin
  Dos.FSplit( FileName, OldDir, Nam, Ext );
  if NewDir[ Length(NewDir) ] <> '\' then
    NewDir := NewDir + '\';
  {$I-}
  Assign( f, FileName );
  FileName := NewDir + Nam + Ext;
  Rename( f, FileName );
  MoveFile := (Ioresult=0);
  {$I+}
end; { MoveFile }

