{
 OK, Sean! I hope this will help you to understand
  my explanation!

 Copper-BAR with 1000 lines (c) Aki Tikkala,1995
}

uses crt;
const
     lines = 1000; delays =30; start = 15; endo = 115;

var
   x,y,p1,p2,z,r,g,b,gr,gm,ss,red_p,blue_p,green_p,green2_p:integer;
   blue2_p,red2_p,max : integer;
   x1,x2,red_pnt : pointer;
   red_s,blue_s,green_s,green2_s,red2_s,capu :byte;
   cup : boolean;
   cloop:array[1..127] of integer;
   colors:array[1..lines,1..3] of integer;
   clear:array[1..lines,1..3] of integer;
   stab:array[0..255] of word;

procedure setpalette(c,r,g,b:byte);assembler;
asm;mov dx,3c8h;mov al,c;mov ah,r;out dx,ax;inc dx;
mov al,g;out dx,al;mov al,b;out dx,al;end;

procedure init2;
begin
      x1 := ptr(seg(colors),ofs(colors)); x2 := ptr(seg(clear),ofs(clear));
      blue_s := 20;green_S := 10;green2_s := 0; red_S := 30;
      max := lines-127; for x := 1 to lines do for z := 1 to 3 do begin
      clear[x,z] := 0; colors[x,z] := 0; end;
      for x := 1 to 63 do begin cloop[x] := x; cloop[x+63] := 63-x;
      end;
end;

procedure draw;
begin
   move(x2^,x1^,sizeof(colors));
   for x := start to endo do
        begin
             colors[x+green2_p,1] := cloop[x];colors[x+green2_p,2] := 0;
             colors[x+green2_p,3] := cloop[x];end;
    for x := start to endo do
        begin
              colors[x+green_p,1] := 0; colors[x+green_p,2] := cloop[x];
              colors[x+green_p,3] := 0;  end;
    for x := start to endo do
        begin
             colors[x+blue_p,1] := 0;colors[x+blue_p,2] := 0;
             colors[x+blue_p,3] := cloop[x];  end;
    for x := start to endo  do
        begin
              colors[x+red_p,1] := cloop[x];colors[x+red_p,2] := 0;
              colors[x+red_p,3] := 0; end;
end;

procedure main;
begin
     blue_p := stab[blue_s];inc(blue_s);
     green_p := stab[green_s];inc(green_s);
     green2_p := stab[green2_s];inc(green2_s);
     red_p := stab[red_s];inc(red_s);draw;
end;

procedure wait;assembler;
asm;mov dx,3dah;@w1:in al,dx;test al,8;jnz @w1;
@w2:in al,dx;test al,8;jz @w2;end;

procedure waitline;assembler;
asm;mov dx,3dah;@a1:in al,dx;and al,01;jne @a1;@a2:in al,dx;
and al,9;cmp al,1;jne @a2;end;

begin
    for x:=0 to 255 do stab[x]:=round((round(sin(2*pi*x/255)*127)+128)*3.35);
    init2; cup := true; capu := 1;asm; mov ax,0013h;int 10h; end;
    repeat
         wait;
         for b := 1 to delays do waitline; {Do some delay}
    for b := 1 to lines do setpalette(0,colors[b,1],colors[b,2],colors[b,3]);
         main;
    until keypressed;
end.

