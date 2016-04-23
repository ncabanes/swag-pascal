
unit DOSMem;  (* By Mitch Davis *)

interface

function Alloc (paras:word):word;
procedure Free (p:word);
function Largest:word;

implementation

function Alloc; assembler;
asm
  mov  ah, $48
  mov  bx, paras
  int  $21
  jnc  @1
  xor  ax, ax
  @1:
end;

procedure Free; assembler;
asm
  mov  ah, $49
  mov  es, p
  int  $21
end;

function Largest; assembler;
asm
  mov  ah, $48
  mov  bx, -1
  int  $21
  mov  ax, bx
end;

end.
