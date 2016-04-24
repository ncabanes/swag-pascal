(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0038.PAS
  Description: Getting BIG Drive Size
  Author: BO BENDTSEN
  Date: 08-27-93  20:16
*)

{
BO BENDTSEN

Many people don't think about it, but DOS is limited to report more than
1 gigabyte. I have a 1.3 and a 1.0 gig, and made these routines for my
programs for knowing if the drive size is more than 1 gig. Using the normal
DiskSize and DiskFree could get you strange result, sometimes it could report
maybe 100MB when it is really 1 gig.

If the size of free space is 1 you can assume that the drive is more than 1
gigabyte.
}

Function DriveSize(d : byte) : Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah := $36;
    dl := d;
    Intr($21, R);
    If AX = $FFFF Then
      DriveSize := -1 { Drive not found }
    Else
    If (DX = $FFFF) or (Longint(ax) * cx * dx = 1073725440) Then
      DriveSize := 1
    Else
      DriveSize := Longint(ax) * cx * dx;
  End;
End;

Function DriveFree(d : byte) : Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah := $36;
    dl := d;
    Intr($21, R);
    If AX = $FFFF Then
    DriveFree := -1 { Drive not found }
    Else
    If (BX = $FFFF) or (Longint(ax) * bx * cx = 1073725440) Then
      DriveFree := 1
    Else
      DriveFree := Longint(ax) * bx * cx;
  End;
End;

