(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0004.PAS
  Description: Detect Non-DOS drives
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{│o│  How do I detect active drives in Pascal?  My Program would │o║
│o│  crash if you Typed in a non-existent drive as either       │o║
│o│  source or destination.                                     │o║
}
Uses Dos;
Var sr : SearchRec;
begin
  findfirst('k:\*.*',AnyFile,sr);
  if Doserror=0
  then Writeln('It is there all right!')
  else Writeln('Sorry, could not find it.');
end.


