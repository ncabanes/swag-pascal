program SinusScroll;
{ Enhanced sinus-scroll, by Bas van Gaalen, Holland, PD }
const
  GSeg = $a000;
  Sofs = 140; Samp = 40; Slen = 255;
  Size = 2; Curve = 3;
  Xmax = 279 div Size; Ymax = 7;
  ScrSpd = -1;
  ScrText : string =
    ' Hai world... This looks a bit like the scroll of the second part'+
    ' of Future Crew''s Unreal demo (part one)...     It''s not filled'+
    ' but it sure looks nicer (imho)...                               ';
type SinArray = array[0..Slen] of word;
var Stab : SinArray; Fseg,Fofs : word;

procedure CalcSinus; var I : word; begin
  for I := 0 to Slen do Stab[I] := round(sin(I*4*pi/Slen)*Samp)+Sofs; end;

procedure GetFont; assembler; asm
  mov ax,1130h; mov bh,1; int 10h; mov Fseg,es; mov Fofs,bp; end;

procedure SetGraphics(Mode : word); assembler; asm
  mov ax,Mode; int 10h end;

function keypressed : boolean; assembler; asm
  mov ah,0bh; int 21h; and al,0feh; end;

procedure Scroll;
type
  ScrArray = array[0..Xmax,0..Ymax] of byte;
  PosArray = array[0..Xmax,0..Ymax] of word;
var
  PosTab : PosArray;
  BitMap : ScrArray;
  X,I,SinIdx : word;
  Y,ScrIdx,CurChar : byte;
begin
  fillchar(BitMap,sizeof(BitMap),0);
  fillchar(PosTab,sizeof(PosTab),0);
  ScrIdx := 1; SinIdx := 0;
  repeat
    Curchar := ord(ScrText[ScrIdx]);
    inc(ScrIdx); if ScrIdx = length(ScrText) then ScrIdx := 1;
    for I := 0 to 7 do begin
      move(BitMap[1,0],BitMap[0,0],(Ymax+1)*Xmax);
      for Y := 0 to Ymax do
        if ((mem[Fseg:Fofs+8*CurChar+Y] shl I) and 128) <> 0 then
          BitMap[Xmax,Y] := ((ScrIdx+Y-I) mod 60)+32 else BitMap[Xmax,Y] := 0;
      while (port[$3da] and 8) <> 0 do;
      while (port[$3da] and 8) = 0 do;
      for X := 0 to Xmax do
        for Y := 0 to Ymax do begin
          mem[GSeg:PosTab[X,Y]] := 0;
          PosTab[X,Y] := (Size*Y+STab[(SinIdx+X+Curve*Y) mod
SLen])*320+Size*X+STab[(X+Y) mod SLen]-SOfs;          mem[GSeg:PosTab[X,Y]] :=
BitMap[X,Y];
        end;
      SinIdx := (SinIdx+ScrSpd) mod SLen;
    end;
  until keypressed;
end;

begin
  CalcSinus;
  GetFont;
  SetGraphics($13);
  Scroll;
  SetGraphics(3);
end.
