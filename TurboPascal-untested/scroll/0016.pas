
program heavily_tweaked_textscroll;
uses crt;
const sseg : word = $b800; hi = 16; grd = 3; wideness = 1;
  grade : string = '.:|X#';
  txt : string = 'This simple old text scroll is really getting tweaked!'
               + '      In fact, it''s not so simple anymore...         ';

var fseg, fofs : word; idx : word; i, cur, line, bitpos : byte;
    jcol : byte; ch : char; widecount : byte;

procedure getfont; assembler; asm
  mov ax,1130h; mov bh,3; int 10h; mov fseg,es; mov fofs,bp; end;

procedure retrace; assembler; asm
  mov dx,3dah;
  @l1: in al,dx; test al,8; jnz @l1;
  @l2: in al,dx; test al,8; jz @l2; end;

procedure moverowleft(startingrow : word); assembler;
asm  { sorry, I had to smush it a bit }
  push  ds;  push  es  { do I really need to save es? }
  mov   ax,$b800;  mov   es,ax;  mov   ds,ax;  mov   cx,0003
  @@MoveByte:
    add   cx,startingrow;  mov   di,cx;       mov   al,[es:di]
    sub   cx,startingrow;  sub   cx,2;        add   cx,startingrow
    mov   si,cx;           mov   [ds:si],al;  sub   cx,startingrow
    add   cx,4;            cmp   cx,160
  jl    @@MoveByte
  pop   es;  pop   ds
end;


begin
  getfont; textattr := 15; clrscr;
  fillchar(mem[$b800:0],4000,0);
  for idx := hi to (hi+7) do for jcol := 0 to length(grade)-1 do begin
    for i := grd*jcol to 79-(grd*jcol) do
      mem[sseg:idx*160+i*2] := Ord(grade[jcol+1]);
  end;
  idx := 1; jcol := 15;
  repeat
    cur := ord(txt[idx]);
    inc(jcol); if (jcol > 15) then jcol := 1;
    bitpos := 0;
    repeat
      for widecount := 1 to wideness do begin
        for line := 0 to 7 do begin
          (* jcol := random(14) + 1; *)
          if ((mem[fseg:fofs+cur*8+line] shl bitpos) and 128) <> 0 then
            mem[sseg:158+(line+hi)*160+1] := jcol
          else
            mem[sseg:158+(line+hi)*160+1] := 0;
        end;
        retrace;
        for line := 0 to 7 do moverowleft((line+hi)*160);
      end;
      inc(bitpos);
    until (bitpos > 7) or keypressed;
    if not keypressed then idx := 1 + idx mod length(txt);
  until keypressed;
  while keypressed do ch := readkey;
  textattr := 7; clrscr;
end.

