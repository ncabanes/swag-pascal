{
I am in need of a very fast LCASE or UCASE routine.
A general translation utility could come in handy:
}

USES CRT;

type
  t_table=array [char] of char;

procedure translate(var buffer; var table:t_table; len:word);
assembler;
asm
  mov     cx,[len]
  JCXZ    @@end
  les     bx,[table]
  push    ds
  cld
  lds     si,[buffer]
@@redo:
  lodsb
  seges
  xlat
  mov     [si-1],al
  LOOP    @@redo
  pop     ds
@@end:
  end;

var
  uptable : t_table;
  lotable : t_table;
  s: string;
  c: char;
begin
  ClrScr;
  (* convert every letter to its uppercase pendant *)
  for c:=#0 to #255 do  uptable[c]:=upcase(c);
  (* convert every letter to its lowercase pendant *)
  for c:=#0 to #255 do  lotable[c]:= CHR(ORD(c) OR $20);
  readln(s);
  translate(s[1],uptable,length(s));
  writeln(s);
  translate(s[1],lotable,length(s));
  writeln(s);
  end.
