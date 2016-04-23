{
> Does anybody know how to do a "fast" move of a File?
> ie: not copying it but just moving the FAT Record

  Yup.  In Pascal you can do it With the Rename command.  The Format is:

   Rename (Var F; NewName : String)

where F is a File Variable of any Type.

to move a File Really fast, and to avoid having to copy it somewhere first and
then deleting the original, do this:
}

Procedure MoveIt;  {No error checking done}
Var
   F : File;
   FName : String;
   NName : String;
begin
   Assign (F, FName);
   NName:= {new directory / File name}
   Rename (F, NName);
End.