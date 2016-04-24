(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0030.PAS
  Description: Object Checking
  Author: DJ MURDOCH
  Date: 01-27-94  12:16
*)

{
> But it's not bad if they DON'T have them, is it? Defining what is good or
> bad from reading the manual is the single most difficult problem I have
> with them for anything (not just TP). I wouldn't suppose
> it would be if you can do it.

I'm not sure what you mean by good or bad.  If you want to use virtual methods,
you need a VMT.  Not having one would be very bad.  If you don't want to use
virtual methods, then you probably don't need a VMT.  The only reason you might
want one is for debugging:  you can check whether an object has been
initialized by checking whether its VMT is valid.  Here's the check I use:
}

Function ObjCheck(o:PObject;msg:string):boolean;
type
  VMT = record
          size, negsize : integer;
        end; var
  PVmt : ^VMT;
begin
  PVmt := Ptr(DSeg, word(Pointer(o)^));
  with PVmt^ do
    if (size = 0) or (size + negsize <> 0) then
    begin
      write(msg,':  Not initialized');
      ObjCheck := false;
    end
    else
      ObjCheck := true; end;

{ This is pretty close to the same check that $R+ does. }

