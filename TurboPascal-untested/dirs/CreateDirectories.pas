(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0035.PAS
  Description: Create Directories
  Author: NEIL GORIN
  Date: 08-25-94  09:06
*)

(*
RF>   Has anyone written a function for creating a pathname ?
RF>   I'm having a problem with putting together a function that you
RF>   can pass a pathname to, such as: C:\WINDOWS\SYSTEM\STUFF
RF>   and have it create the path if it's at all possible.

Try the following, taken from a couple (one DOS, one Windows) of
install programs I am working on.  Lines beginning {} should
be replaced with your preferred error reporting methods (they
currently use my UNIXGUI package).  This is not guaranteed to
trap all possible errors.

LEGALDIR will return true if the path is legal.  You *must* specify
the drive in the path as in C:\WINDOWS\SYSTEM\STUFF
*)
Function LegalDir(path:string):boolean;
    var flag:boolean;
    begin
         path:=short(path);
         flag:=true;
         if path[1]<'A' then flag:=false;
         if path[1]>'Z' then flag:=false;
         if path[2]<>':' then flag:=false;
         if path[3]<>'\' then flag:=false;
         delete(path,1,3);
         While path<>'' do
         begin
              if pos('\',path)>9 then flag:=false;
              if ((length(path)>1) and (path[1]='\') and (path[2]='\'))
                 then flag:=false;
              if path[1]=' ' then flag:=false;
              if  not (path[1] in
                 ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                  'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                  '1','2','3','4','5','6','7','8','9','0','_','^','$',
                  '~','!','#','%','&','-','{','}','(',')','\'])
                 then flag:=false;

              delete(path,1,1);
         end;
         if not flag then
         begin
{}             WinOkDialogue('Cannot Install',
                             'Illegal Directory name!',
                             'Please re-edit and',
                             'try again.');
         end;
         LegalDir:=flag;
    end;
{
MAKEDIRECTORY will make the directory structure you pass to it.  Best
to call LEGALDIR first, for obvious reasons.
}
    Procedure MakeDirectory(st:string);
    var ns:string;
        ior:word;
    begin
        Chdir(st);
        if ioresult=0 then exit;
        MKDIR(st);
        ior:=ioresult;
        if ior=3 then
        begin
            ns:=st;
            while ns[length(ns)]<>'\' do delete(ns,length(ns),1);
            delete(ns,length(ns),1);
            MakeDirectory(ns);
            MakeDirectory(st);
        end;
        if ((ior<>0) and (ior<>3)) then
        begin
{}             Popdialogue;
{}             WinOkDialogue('Error',
                             'Illegal Directory',
                             'or drive error!',
                             'Halting...');
{}             closegui;
             halt;
        end;
    end;

