(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0011.PAS
  Description: LOCKFILE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{
> Does anyone have any multi-tasking/File sharing Units (preferably
> With well documented code).  Specifically, I need to Write a Program
> that _may_ be active on one node, and I'd like to open the Files in
> read-only Form, amung other things, so that I can load that in
> multi-node (shared) environment.

}

Function LockFile(f : File) : Boolean;  { returns True if lock achieved. }
                                        { if not, File locked by other   }
                                        { application running.           }

Var
  r : Registers;   {Defined in Dos Unit}
  l : LongInt;

begin
  r.ah := $5C;
  r.al := 0;
  Move(f,r.bx,2);   {Places File handle into BX register.}
  r.cx := 0;  {Most significant, region offset (0 - beginning of File)}
  r.dx := 0;  {Least significant, region offset (0 - beginning of File)}
  l := FileSize(f);         { Get File size }
  r.di := l and $ffff;      { Devide File size to most/least parts }
  r.si := l div $10000;     { For locking the entire File.         }
  MsDos(r);
  LockFile := ((r.flags and 1)=0);
  { if carry flag is set File locking failed, reason in AX }
end;

{
BTW: to unlock it use the same routine, but change the  r.al to 1.

if this routine fails, it means that the File is locked in the other
task, and cannot be used.
}
