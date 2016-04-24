(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0223.PAS
  Description: 100% Pascal Plasma
  Author: STEVEN MCLEOD
  Date: 05-26-95  23:24
*)

{
> Howdy, I am looking for some Pascal (no ASM please :) plasma or fire
> psudocode..

 well i guess this is better than psuedocode... it creates plasma.img in
 your current directory, so delete it for a new random pattern, also
 change the delay at the end to your liking. l8r! btw I must have posted
 this at least 4 times now to various people in the last two weeks!
}

{$I-}
program plasma;

  uses
    Crt,Dos;

  const
    F = 0.0000000000000000001; { the "roughness" of the image }

  type
    ColorValue = record Rvalue,Gvalue,Bvalue: byte; end;
    PaletteType = array [0..255] of ColorValue;

  var
    ch: char;
    i: integer;
    p: PaletteType;
    image: file;
    ok: boolean;

  procedure SetVGApalette(var tp: PaletteType);
    var regs: Registers;
  begin { procedure SetVGApalette }
    with regs do
      begin
        AX:=$1012;
        BX:=0; { first register to set }
        CX:=256; { number of registers to set }
        ES:=Seg(tp); DX:=Ofs(tp);
      end;
    Intr($10,regs);
  end; { procedure SetVGApalette }

  procedure PutPixel(x,y: integer; c: byte);
  begin { procedure PutPixel }
    mem[$A000:word(320*y+x)]:=c;
  end; { procedure PutPixel }

  function GetPixel(x,y: integer): byte;
  begin { function GetPixel }
    GetPixel:=mem[$A000:word(320*y+x)];
  end; { function GetPixel }

  procedure adjust(xa,ya,x,y,xb,yb: integer);
    var
      d: integer;
      v: real;
  begin { procedure adjust }
    if GetPixel(x,y)<>0 then exit;
    d:=Abs(xa-xb)+Abs(ya-yb);
    v:=(GetPixel(xa,ya)+GetPixel(xb,yb))/2+(random-0.5)*d*F;
    if v<1 then v:=1;
    if v>=193 then v:=192;
    PutPixel(x,y,Trunc(v));
  end; { procedure adjust }

  procedure subDivide(x1,y1,x2,y2: integer);
    var
      x,y: integer;
      v: real;
  begin { procedure subDivide }
    if KeyPressed then exit;
    if (x2-x1<2) and (y2-y1<2) then exit;

    x:=(x1+x2) div 2;
    y:=(y1+y2) div 2;

    adjust(x1,y1,x,y1,x2,y1);
    adjust(x2,y1,x2,y,x2,y2);
    adjust(x1,y2,x,y2,x2,y2);
    adjust(x1,y1,x1,y,x1,y2);

    if GetPixel(x,y)=0 then
      begin
        v:=(GetPixel(x1,y1)+GetPixel(x2,y1)+GetPixel(x2,y2)+GetPixel(x1,y2))/4;
        PutPixel(x,y,Trunc(v));
      end;

    subDivide(x1,y1,x,y);
    subDivide(x,y1,x2,y);
    subDivide(x,y,x2,y2);
    subDivide(x1,y,x,y2);
  end; { procedure subDivide }

  procedure rotatePalette(var p: PaletteType; n1,n2,d: integer);
    var
      q: PaletteType;
  begin { procedure rotatePalette }
    q:=p;
    for i:=n1 to n2 do
      p[i]:=q[n1+(i+d) mod (n2-n1+1)];
    SetVGApalette(p);
  end; { procedure rotatePalette }

begin
  Inline($B8/$13/0/$CD/$10); { select video mode 13h (320x200 with 256 colors)
}
  with p[0] do               { set background palette entry to grey }
    begin
      Rvalue:=32;
      Gvalue:=32;
      Bvalue:=32;
    end;

  for i:=0 to 63 do { create the color wheel }
    begin
      with p[i+1] do begin Rvalue:=i; Gvalue:=63-i; Bvalue:=0; end;
      with p[i+65] do begin Rvalue:=63-i; Gvalue:=0; Bvalue:=i; end;
      with p[i+129] do begin Rvalue:=0; Gvalue:=i; Bvalue:=63-i; end;
    end;

  SetVGApalette(p);

  Assign(image,'PLASMA.IMG');
  Reset(image,1);
  ok:=(ioResult=0);

  if not ok or (ParamCount<>0) then { create a new image }
    begin
      Randomize;

      PutPixel(0,0,1+Random(192));
      PutPixel(319,0,1+Random(192));
      PutPixel(319,199,1+Random(192));
      PutPixel(0,199,1+Random(192));

      subDivide(0,0,319,199);

      Rewrite(image,1);
      BlockWrite(image,mem[$A000:0],$FA00);
    end
  else { use the previous image }
    BlockRead(image,mem[$A000:0],$FA00);

  Close(image);

  repeat
    rotatePalette(p,1,192,+1);
  delay(50);
  until KeyPressed;

  ch:=ReadKey; if ch=#0 then ch:=ReadKey;

  TextMode(LastMode);
end.

