(*
  Category: SWAG Title: RECORD RELATED ROUTINES
  Original name: 0013.PAS
  Description: Getting Record Offsets
  Author: ARNE DE.BRUIJN
  Date: 11-26-94  05:09
*)

{
> Does anyone know how I can find and use the offset of
> a given field in a record?

AFAIK, you can only use BASM for that. example:
}

type
 XXX=record
  A,B,C:byte;
 end;
var
 W:word;
begin
 asm
  mov ax,XXX.A
  mov W,ax
 end;
 { W holds now the offset of A in XXX }
end.

