{
From: PHIL NICKELL
Subj: Disk Ready Function

 Here are a couple of ways that are about equivalent.  Which you use
 depends on the info you might want about the drive.  These calls
 actually spin up the disk and get info from the boot sector or the fat
 table, so they also incidentally check if the disk is ready and ok.
 Unfortunately, DOS doesn't really have a reasonable way to tell you if
 the disk is ready without it actually spinning up the drive.
}
  var r:registers;

    Get Allocation Table Info
  ...on entry
         r.ah := $1ch;
         r.dl := drivenum;  { 0=default, 1=A, 2=B etc}
         msdos(r);
  ...on return
         r.al = sectors per cluster
         r.cx = bytes per physical sector
         r.dx = clusters per disk
         ds:bx = pointer to media descriptor byte

     Get Free Disk Space Info
  ...on entry
         r.ah := $36;
         r.dl := drivenum;  { 0=default, 1=A, 2=B etc}
         msdos(r);
  ...on return
         r.ax = sectors per cluster /or/
              = $ffff if error.
         r.bx = number of available clusters
         r.cx = bytes per sector
           dx = clusters on the drive

