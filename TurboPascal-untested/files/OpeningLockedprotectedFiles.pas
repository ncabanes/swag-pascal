(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0087.PAS
  Description: Opening Locked/Protected files
  Author: PHIL NICKELL
  Date: 05-31-96  09:17
*)

(*
MH│Anyone have any suggestions on protecting source code against this sort
  │of piracy? I have tried using a CRC calculation on the .EXE but run
  │into "FILE ACCESS DENIED" if the game is running on a network (the
  │program is meant for networks...)
MH│Any suggestions would be appreciated.

 You are probably opening the .exe file with RESET command using the
 default file open mode of read/write which tries to open it with
 read/write access privileges.  Normal access to network programs is
 probably set to read-only access.  Below is how I open a binary file in
 read-only mode in Turbo Pascal v6.  The filemode variable is located in
 the TP system unit. 0=read/only 1=write/only 2=read/write 64=shared-r/o
 65=shared-w/o 66=shared-r/w.  In your case there may be no need to test
 the file attribute first, as the r/o attribute may not be set. But you
 could attempt to always open it with file mode 2 and then try mode 0 or
 64 if mode 2 wasn't successful. Remember to set the file mode back to
 'normal' before opening normal r/w files.
 *)

 Function  OpenF(name:pathstr):boolean;
     var
       readonly : boolean;
       goodfile : boolean;
       attrword  : word;
   begin
     Assign(f,name);  { f is global untyped file ie.  var f:file; }
     GetFAttr(f,attrword);
     readonly := odd(attrword);  { if file read-only attribute is set }
     if readonly then
       filemode := 0   { allows open of untyped file r/o }
      else
       filemode := 2;  { normal readwrite untyped file }
     {$I-}
     Reset(f,1);   { recordsize = 1 byte }
     {$I+}
     goodfile := (ioresult = 0);
     if goodfile then goodfile := (not eof(f));  {protect against
                                                  0 byte files}
     OpenF := goodfile;
   end; {openf}

