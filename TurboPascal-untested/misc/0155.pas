
{
  unit Arit:  routine di calcolo numerico.
}
unit Arit;

{$D-,L-,G+,N+}

interface

function Max(X,Y : integer) : integer;
  {- Restituisce il massimo tra A e B.}

function Min(X,Y : integer) : integer;
  {- Restituisce il minimo tra A e B.}

function LongMax(A,B : longint) : longint;
  {- Restituisce il massimo tra A e B (longint).}

function LongMin(A,B : longint) : longint;
  {- Restituisce il minimo tra A e B (longint).}

function InRange(V,A,B : integer) : boolean;
  {- Restituisce true se V è compreso tra A e B (estrami inclusi).}

function OutRange(V,A,B : integer) : boolean;
  {- Restituisce true se V non è compreso tra A e B.}

function LongInRange(V,A,B : longint) : boolean;
  {- Restituisce true se V è compreso tra A e B (estrami inclusi).}

function LongOutRange(V,A,B : longint) : boolean;
  {- Restituisce true se V non è compreso tra A e B.}

function LongToInt(V : longint) : integer;
  {- Converte da longinteger ad integer, restituendo MaxInt o -MaxInt nel caso
     V sia fuori dal range degli interi.}

function IntToShort(V : integer) : shortint;
  {- Converte da integer ad shortint, restituendo 127 o -128 nel caso
     V sia fuori dal range degli shortint.}

function CompToLongInt(V : Comp):longint;
  {- Converte da comp ad longint, restituendo MaxLongint o -MaxLongInt nel caso
     V sia fuori dal range dei longint.}

function CompToInt(V : Comp):integer;
  {- Converte da comp ad longint, restituendo Maxint o -MaxInt nel caso
     V sia fuori dal range degli interi.}

implementation {==============================================================}

function Min(X,Y : integer) : integer; assembler;
asm
  mov	ax,X
  cmp	ax,Y
  jle	@@1
  mov	ax,Y
@@1:
end;  { Min }

function Max(X,Y : integer) : integer; assembler;
asm
  mov	ax,X
  cmp	ax,Y
  jge	@@1
  mov	ax,Y
@@1:
end;  { Max }

function LongMin(A,B : longint) : longint; assembler;
asm
  mov   ax, word ptr [A]
  mov   dx, word ptr [A+2]
  mov   bx, word ptr [B]
  mov   cx, word ptr [B+2]
  cmp   dx,cx
  jl    @@1
  jg    @@2
  cmp   ax,bx
  jbe   @@1
@@2:
  mov   ax,bx
  mov   dx,cx
@@1:
end;  { LongMin }

function LongMax(A,B : longint) : longint; assembler;
asm
  mov   ax, word ptr [A]
  mov   dx, word ptr [A+2]
  mov   bx, word ptr [B]
  mov   cx, word ptr [B+2]
  cmp   dx,cx
  jg    @@1
  jl    @@2
  cmp   ax,bx
  jae   @@1
@@2:
  mov   ax,bx
  mov   dx,cx
@@1:
end;  { LongMax }

function InRange(V,A,B : integer) : boolean; assembler;
asm
  mov   ax,V
  cmp   ax,A
  jl    @1
  cmp   ax,B
  jg    @1
  mov   ax,1
  jmp   @2
@1:
  xor   ax,ax
@2:
end; { InRange }

function OutRange(V,A,B : integer) : boolean; assembler;
asm
  mov   ax,V
  cmp   ax,A
  jl    @1
  cmp   ax,B
  jg    @1
  xor   ax,ax
  jmp   @2
@1:
  mov   ax,1
@2:
end; { OutRange }

function LongInRange(V,A,B : longint) : boolean;
begin
  LongInRange := (V >= A) and (V <= B);
end; { LongInRange }

function LongOutRange(V,A,B : longint) : boolean;
begin
  LongOutRange := (V < A) or (V > B);
end; { LongOutRange }

function LongToInt(V : longint) : integer;
begin
  if V < -MaxInt then LongToInt := -MaxInt
  else if V > MaxInt then LongToInt := MaxInt
  else LongToInt := V;
end; { LongToInt }

function IntToShort(V : integer) : shortint;
begin
  if V > 127 then IntToShort := 127
  else if V < -128 then IntToShort := -128
  else IntToShort := V;
end; { IntToShort }

function CompToLongInt(V : Comp):longint;
var
  s : string[20];
  l : longint;
  e : integer;
begin
  if V > MaxLongInt then l := MaxLongInt
  else if V < -MaxLongInt then l := -MaxLongInt
  else begin
    Str(V:20:0, S);
    val(s, l, e);
  end;
  CompToLongInt := l;
end; { CompToLongInt }

function CompToInt(V : Comp):integer;
var
  s : string[20];
  i, e : integer;
begin
  if V > MaxInt then i := MaxInt
  else if V < -MaxInt then i := -MaxInt
  else begin
    Str(V:20:0, S);
    val(s, i, e);
  end;
  CompToInt := i;
end; { CompToInt }


end. { unit Arit }