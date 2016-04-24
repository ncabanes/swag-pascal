(*
  Category: SWAG Title: DESQVIEW ROUTINES
  Original name: 0002.PAS
  Description: DV-VIDEO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
> Has anyone done any work With DV's virtual screen?  Someplace I
> used to have the address For it, but I seem to have lost it.  Does
> anybody know what it is?

> What I'm trying to do is bypass TJT's direct screen Writes by
> replacing the BaseOfScreen Pointer With the one For DV's virtual
> screen. if I can't do that then I'm going to have to make another
> attempt at rewriting the assembly level screen routines.
}

Function DV_Video_Buffer;
begin
  Reg.AH := $0F;
  INTR($10, Reg);
  if Reg.AL = 7 then
    Reg.ES := $B000
  else
    Reg.ES := $B800;
  if DV_Loaded then
  begin
    Reg.DI := 0;
    Reg.AX := $FE00;
    INTR($10, Reg);
  end;
  DV_Video_Buffer := Reg.ES;
end;

