(*
  Category: SWAG Title: RECORD RELATED ROUTINES
  Original name: 0009.PAS
  Description: Delete Record Routine
  Author: DANIEL HEFLEY
  Date: 08-27-93  21:14
*)

{
DANIEL HEFLEY

> according to all references I've read, the only way to delete Records
> in ANY File is to copy the good Records to a new File, skipping over
> the ones you want deleted, delete the original File, and rename the new
> one to the original name.  A long way of doing it, but I don't know of
> any other.

 No.....You could:
}

Procedure DelRec(RecIdx : LongInt);
Var
  Count,
  RecNo : LongInt;
  IFile : File of ItemRec;
  Item : ItemRec;

begin
  Assign(IFile,'Tmp.Dat'); Reset(f);   { assuming it exists }
  Seek(IFile,idx);                     { assuming recidx exists }
  RecNo := FileSize(f) - idx - 1;
  For Count := idx to RecNo do
  begin
    Seek(IFile,Count+1);
    Read(IFile,Item);        { read next rec }
    Seek(IFile,Count);
    Write(IFile,Item);       { overide prev rec }
  end;
  Seek(IFile,RecNo);                       { seek to last Record }
  Truncate(IFile);                     { truncate rest of File }
  Close(IFile);
end;

{
> Of course, you could cheat like I do...when I create a File With
> Records, every one of them has one Boolean field called ACTIVE_REC,
> which is forced to True when the Record is created.  if the user wants
> to delete the Record, ACTIVE_REC becomes False and the Program ignores
> the Record.  Eventually, you'll have to use the above
> copy-delete-rename Procedure, but it sure saves time if you're just
> deleting one Record!

When you initialize new Variables....find the Non Active Record and assign
your File index Variable to that record!
}
