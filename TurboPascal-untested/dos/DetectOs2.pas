(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0023.PAS
  Description: Detect OS2
  Author: BJOERN JOENSSON
  Date: 08-27-93  21:43
*)

{
BJOERN JOENSSON

BTW, OS/2 is easy to detect because the major Dos
version # is greater than 10:
}

Function DetectOs2 : Boolean;
begin
  { if you use Tpro, then Write Hi(TpDos.DosVersion) }
  DetectOs2 := (Lo(Dos.DosVersion) > 10);
end;

