
interface

procedure InitRandomGenerator(InitValue : longint);
function Random:real;

implementation
type
  Lint = record
           a,b,c,d : word;
         end;
var
  yWertZufall : Lint;
  Modul       : Lint;
  Faktor      : integer;
procedure LintMUL(var p1: Lint; p2: integer);
begin
  asm
         mov cx,4
         les di,p1
         xor bx,bx
         cld
  @mull: mov ax,es:[di]
         mov dx,p2
         mul dx
         add ax,bx
         adc dx,0
         mov bx,dx
         stosw
         loop @mull
  end;
end;
procedure LintSub(var p1, p2: Lint);
var
  result : longint;
  carry : word;
begin
  result := p1.a;
  dec(result, p2.a);
  if result < 0 then
  begin
    carry := 1;
    inc(result, 65536);
  end
  else
    carry := 0;
  p1.a := result;
  result := p1.b;
  dec(result, carry);
  dec(result, p2.b);
  if result < 0 then
  begin
    carry := 1;
    inc(result, 65536);
  end
  else
    carry := 0;
  p1.b := result;
  result := p1.c;
  dec(result, carry);
  dec(result, p2.c);
  if result < 0 then
  begin
    carry := 1;
    inc(result, 65536);
  end
  else
    carry := 0;
  p1.c := result;
  dec(p1.d, carry);
  dec(p1.d, p2.d);
end;

procedure InitRandomGenerator(InitValue : longint);
begin
  with yWertZufall do
  begin
    b := InitWert div 65536;
    a := InitWert - b*65536;
    c := 0;
    d := 0;
  end;
end;  (* InitRandomGenerator *)

function Random:real;
var
  Wert : longint;
begin
  LintMul(yWertZufall , Faktor);
  if yWertZufall.b >32767 then
    LintSub(yWertZufall,Modul);

  Wert := 2*yWertZufall.c + 65536*yWertZufall.b+yWertZufall.a;
  with yWertZufall do  begin
    d := 0;
    c := 0;
    b := Wert shr 16;
    a := Wert - (b*65536);
  end;
  Zufall := Wert / 2147483647;

end; (* Zufall *)
begin
  with yWertZufall do
  begin
    a := 0;
    b := 0;
    c := 0;
    d := 0;
  end;
  Faktor := 16807;
  with Modul do
  begin
    a := 65535;
    b := 32767;
    c := 0;
    d := 0;
  end;
end. (* _Zufall *)
