{
I'm not sure if there're people who are still searching for a _big_ scroll
(meaning bigger than just one line). If so, here's some source:

{ --- cut here --- }

program Simple_Old_TextScroll;

uses crt;
const Sseg : word = $b800; Hi = 17; Txt : string = 'Hello world...      ';
var Fseg,Fofs : word; I,Cur,Idx,Line,BitPos : byte;

procedure Getfont; assembler; asm
  mov ax,1130h; mov bh,3; int 10h; mov Fseg,es; mov Fofs,bp; end;

procedure Retrace; assembler; asm
  mov dx,3dah;
  @l1: in al,dx; test al,8; jnz @l1;
  @l2: in al,dx; test al,8; jz @l2; end;

begin
  GetFont;
  Idx := 1;
  repeat
    Cur := ord(Txt[Idx]);
    for BitPos := 0 to 7 do begin
      for Line := 0 to 7 do begin
        if ((mem[Fseg:Fofs+Cur*8+Line] shl BitPos) and 128) <> 0 then
          mem[Sseg:158+(Line+Hi)*160] := 219
        else
          mem[Sseg:158+(Line+Hi)*160] := 32;
      end;
      Retrace;
      for Line := 0 to 7 do
        for I := 0 to 78 do
          mem[Sseg:(Line+Hi)*160+I+I] := mem[Sseg:(Line+Hi)*160+I+I+2];

    end;
    Idx := 1+Idx mod length(Txt);
  until keypressed;
end.

{ --- cut here --- }

Keep in mind this thing expects a VGA card with the textmemory at $b800.

