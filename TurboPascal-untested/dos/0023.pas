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