(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0011.PAS
  Description: Move File #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
> How would I move a File from within my Program.

if the File is to moved from & to the same partition,
all you have to do is:

  Assign(F,OldPath);
  Rename(F,NewPath);

On the other hand, if the File is to be moved to a different
partition, you will have to copy / erase the File.
Example:
}
Program MoveFile;

Var
  fin,fout  : File;
  p         : Pointer;
  w         : Word;

begin
  GetMem(p,64000);
  Assign(fin,ParamStr(1));               { Assumes command line parameter. }
  Assign(fout,ParamStr(2));
  Reset(fin);
  ReWrite(fout);
  While not Eof(fin) do
  begin
    BlockRead(fin,p^,64000,w);
    BlockWrite(fout,p^,w);
  end;
  Close(fin);
  Close(fout);
  Erase(fin);
  FreeMem(p,64000);
end.

{
This Program has NO error control.
}
