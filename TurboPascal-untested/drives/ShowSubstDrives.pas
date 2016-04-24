(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0012.PAS
  Description: Show SUBST drives
  Author: BO BENDTSEN
  Date: 05-28-93  13:38
*)

{
BO BendTSEN

> There's already a methode For finding all available drives without
> accessing them - I'd like to have one to get the volume Labels of the
> harddisks, SUBST- and network-drives without waiting seconds While the
> Program accesses all the 20 drives available in my system ... ;-)

Try this, it will show any SUBST drives, if a \\ first in the name is returned
you will have a network server name following.
}
Uses
  Dos;

Function ResolvePath(Var s : String) : Boolean;
Var
  r : Registers;
  x : Byte;
begin
  ResolvePath := False;
  s := s + #0;
  r.ds := Seg(S);
  r.si := Ofs(S) + 1;
  r.es := Seg(S);
  r.di := Ofs(S) + 1;
  r.ah := $60;
  Intr($21, R);
  If r.flags and 1 = 1 Then
    Exit; { if ZF set then error }
  ResolvePath := True;
  x := 0;
  While (s[x + 1] <> #0) And (x < 128) Do
    Inc(x);
  s[0] := Chr(x);
end;

Var
  DriveName : String;

begin
  DriveName := 'C';
  Writeln(ResolvePath(DriveName));
  Writeln(DriveName);
end.

