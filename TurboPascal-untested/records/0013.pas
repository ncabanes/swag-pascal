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