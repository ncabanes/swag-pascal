(*
===========================================================================
 BBS: The Beta Connection
Date: 06-05-93 (12:54)             Number: 67
From: BRENDEN WALKER               Refer#: NONE
  To: WAYNE DOYLE                   Recvd: NO
Subj: DIR. SEARCH                    Conf: (321) Pascal___U
---------------------------------------------------------------------------
 WD│ Hi Everyone,
   │     I'm interested in finding out how to have the computer search and
   │ find all of the available directories on a disk.  I have a program which
   │ deletes all of *.BAK files on a disk and I'd like to know how it finds
   │ all of the directories.

  The below example code, will kill a directory and all of it's
sub-directories.  This could be modified to delete all of the .BAK files in
all directories on the hard-drive.

  Of course, this may not help much, but I rarely use pseudo-code.
*)

procedure Kill_Dir(p : pathstr);
var Od, Rd : pathstr;
    Sr : SearchRec;
    t : file;

begin
  getdir(0,Od);
  ChDir(p);
  if length(p) > 4 then p := p + '\';
  FindFirst('*.*', anyfile, Sr);
  while DosError = 0 do
  begin
    temp := p + Sr.Name;
    if (Sr.Attr and Directory > 0) then
    begin
       if (Sr.Name <> '.') and (Sr.Name <> '..') then
       begin
         Rd := temp;
         Kill_Dir(temp);
         RmDir(Rd);
       end;
    end
      else
      begin
        assign(t,sr.name);
        erase(t);
      end;
    FindNext(Sr);
  end;
  ChDir(Od);
end;
