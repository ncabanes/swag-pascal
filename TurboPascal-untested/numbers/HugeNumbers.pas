(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0062.PAS
  Description: Huge Numbers!
  Author: BJ�RN FELTEN
  Date: 11-26-94  05:09
*)

unit HugeUtil;

interface

const HugeMax = $8000-16;

type  Huge = record
              len : word;
              dat : array[1..HugeMax] of word;
            end;
      HugePtr = ^Huge;

procedure AddHuge  (var Answer, Add : Huge);
procedure MulHuge  (var A : Huge; Mul : integer; var Answer : Huge);
procedure DivHuge  (var A : Huge; Del : integer; var Answer : Huge;
                    var Remainder : integer);
procedure SubHuge  (var Answer, Sub : Huge);
procedure ZeroHuge (var L : Huge; Size : word);
procedure CopyHuge (var Fra,Til : Huge);
procedure GetHuge  (var P : HugePtr; Size : word);
procedure WriteHuge(var L : Huge; Size: word);

implementation

procedure AddHuge; assembler; asm
  cld
  push  ds
  lds   di,Answer
  les   si,Add
  seges lodsw
  mov   cx,ax
  clc
@l1:
  seges lodsw
  adc   [si-2],ax
  loop  @l1
  jnb   @done
@l2:
  add   word [si],1
  inc   si
  inc   si
  jc    @l2
@done:
  mov   si,di
  lodsw
  shl   ax,1
  add   si,ax
  lodsw
  or    ax,ax
  je    @d2
  inc   word [di]
@d2:
  pop   ds
end;

procedure MulHuge; assembler; asm
  cld
  push  ds
  lds   si,A
  mov   bx,Mul
  les   di,Answer
  mov   cx,[si]
  mov   dx,si
  inc   di
  inc   di
  clc
@l1:
  mov   ax,[di]
  pushf
  mul   bx
  popf
  adc   ax,si
  stosw
  mov   si,dx
  loop  @l1
  adc   si,0
  mov   es:[di],si
  lds   di,A
  mov   di,[di]
  mov   ax,[di+2]
  or    ax,ax
  je    @l2
  inc   di
  inc   di
@l2:
  lds   si,Answer
  mov   [si],di
  pop   ds
end;

procedure DivHuge; assembler; asm
  std
  push  ds
  lds   si,A
  mov   bx,Del
  les   di,Answer
  mov   cx,[si]
  mov   di,cx
  add   di,cx
  xor   dx,dx
@l1:
  mov   ax,[di]
  div   bx
  stosw
  loop  @l1
  lds   si,Remainder
  mov   [si],dx
  lds   si,A
  mov   ax,[si]
  lds   di,Answer
  mov   [di],ax
  mov   si,[di]
  shl   si,1
@d3:
  lodsw
  or    ax,ax
  jne   @d2
  dec   word [di]
  jne   @d3
  inc   word [di]
@d2:
  pop   ds
end;

procedure SubHuge; assembler; asm
  cld
  push  ds
  lds   di,Answer
  les   si,Sub
  seges lodsw
  mov   cx,ax
  clc
@l1:
  seges lodsw
  sbb   [si-2],ax
  loop  @l1
  jnb   @done
@l2:
  sub   word [si],1
  inc   si
  inc   si
  jc    @l2
@done:
  mov   si,[di]
  shl   si,1
  std
@d3:
  lodsw
  or    ax,ax
  jne   @d2
  dec   word [di]
  jne   @d3
  inc   word [di]
@d2:
  pop   ds
end;


procedure WriteHuge;
var L1, L2, I, R, R1, X : integer;
begin
  with L do begin
    L1 := Len;
    L2 := L1 - 1;
    I := 1;
    write(dat[L1],'.');
    X := 0;
    for I := 1 to Size div 4 do begin
      Dat[L1] := 0;
      Len := L2;
      MulHuge(L,10000,L);
      R := dat[L1];
      R1 := R div 100;
      R  := R mod 100;
      write(chr(R1 div 10+48), chr(R1 mod 10+48),
            chr(R  div 10+48), chr(R  mod 10+48));
      inc(X);
      write(' ');
      if X > 14 then begin
        writeln; write('  ');
        X := 0
      end
    end
  end;
  writeln
end;                            { WriteHuge }

procedure ZeroHuge;
begin
  fillchar(L.Dat, Size * 2, #0);
  L.Len := Size
end;

procedure CopyHuge;
begin
  move(Fra, Til, Fra.Len * 2 + 2)
end;

procedure GetHuge;
var D : ^byte;
    Tries,
    Bytes : word;
begin
  Bytes := 2 * (Size + 1);
  Tries:=0;
  repeat
    getmem(P,Bytes);

{ To make it possible to use maximally large arrays, and to increase
  the speed of the computations, all records of type Huge MUST start
  at a segment boundary! }

    if ofs(P^) = 0 then begin
      ZeroHuge(P^,Size);
      exit
    end;
    inc(Tries);
    freemem(P,Bytes);
    new(D)
  until Tries>10;   { if not done yet, it's not likely we ever will be }
  writeln('Couldn''t get memory for array');
  halt(1)
end;                                   { GetHuge }

end.

