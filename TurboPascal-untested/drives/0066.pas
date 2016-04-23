{
From: BO BENDTSEN
Subj: Diskfree...

 MT> Has anyone noticed the problem with TP returning the wrong values from the
 MT> DISKFREE function on large size HD's? We have a 2 gig drive at work
 MT> (actual total is like 1900000000 bytes free), and pascal returns something
 MT> like 576009491. All variables are longint.


Many people does not think about it, but DOS is limited to report more than
1 gigabyte. Myself I have a 1.3 giga and a 1.0 giga, and made these routines
for my programs for knowing if the size is more than 1 giga. Using the normal
DiskSize and DiskFree could get you strange result, sometimes it could report
maybe 100MB when it is really 1 giga.

If the size og free space is 1 you can assume that the drive is more than 1
gigabyte.}

Function DriveSize(d:byte):Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah:=$36; dl:=d; Intr($21,R);
    If AX=$FFFF Then DriveSize:=-1 { Drive not found }
    Else If (DX=$FFFF) or (Longint(ax)*cx*dx=1073725440) Then DriveSize:=1
    Else DriveSize:=Longint(ax)*cx*dx;
  End;
End;

Function DriveFree(d:byte):Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah:=$36; dl:=d; Intr($21,R);
    If AX=$FFFF Then DriveFree:=-1 { Drive not found }
    Else If (BX=$FFFF) or (Longint(ax)*bx*cx=1073725440) Then DriveFree:=1
    Else DriveFree:=Longint(ax)*bx*cx;
  End;
End;
