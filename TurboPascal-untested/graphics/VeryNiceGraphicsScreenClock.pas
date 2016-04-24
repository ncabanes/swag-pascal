(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0229.PAS
  Description: Very nice Graphics screen clock
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)

program clock7;

{ The SVGA driver "Svga256.bgi" is on my Pascal Page }
{ http://www.universal.nl/users/dickmann/pascal.htm }


uses crt,dos,graph;

const
  cijfers :array[0..9,0..6,1..2] of byte =
     (((128,60),(140,11),(134,60),(146,60),(152,60),(158,60),(164,60)),  {0}
      ((128,11),(140,11),(134,11),(146,11),(152,11),(158,60),(164,60)),  {1}
      ((128,60),(140,60),(134,60),(146,11),(152,60),(158,60),(164,11)),  {2}
      ((128,60),(140,60),(134,60),(146,11),(152,11),(158,60),(164,60)),  {3}
      ((128,11),(140,60),(134,11),(146,60),(152,11),(158,60),(164,60)),  {4}
      ((128,60),(140,60),(134,60),(146,60),(152,11),(158,11),(164,60)),  {5}
      ((128,60),(140,60),(134,60),(146,60),(152,60),(158,11),(164,60)),  {6}
      ((128,60),(140,11),(134,11),(146,11),(152,11),(158,60),(164,60)),  {7}
      ((128,60),(140,60),(134,60),(146,60),(152,60),(158,60),(164,60)),  {8}
      ((128,60),(140,60),(134,60),(146,60),(152,11),(158,60),(164,60))); {9}


var
  p,pp,q            :integer;
  ch                :char;
  dis               :array[1..6] of string[1];
  d                 :array[1..6] of byte;
  cx,cy             :integer;
  start             :boolean;

Procedure RGB(Color,wr,wg,wb : Byte);{**************************************}

begin
  Port[$3C8]:=Color;
  Port[$3C9]:=wr;
  Port[$3C9]:=wg;
  Port[$3C9]:=wb;
end;

procedure run_klok;{********************************************************}

var h,m,sec,hund :word;
  st :string[10];

function leading(w :word) :string;

begin
  str(w:0,st);
  if length(st) =1 then st :='0' +st;
  leading :=st;
end;

begin
  gettime(h,m,sec,hund);

  dis[1] :=copy(leading(h),1,1);val(dis[1],d[1],q);
  dis[2] :=copy(leading(h),2,1);val(dis[2],d[2],q);
  dis[3] :=copy(leading(m),1,1);val(dis[3],d[3],q);
  dis[4] :=copy(leading(m),2,1);val(dis[4],d[4],q);
  dis[5] :=copy(leading(sec),1,1);val(dis[5],d[5],q);
  dis[6] :=copy(leading(sec),2,1);val(dis[6],d[6],q);

  { SET CLOCK ON TIME }
  if start =false then for p :=0 to 6 do begin
    setrgbpalette(cijfers[d[1],p,1],cijfers[d[1],p,2],0,0);
    setrgbpalette(cijfers[d[2],p,1]+1,cijfers[d[2],p,2],0,0);
    setrgbpalette(cijfers[d[3],p,1]+2,cijfers[d[3],p,2],0,0);
    setrgbpalette(cijfers[d[4],p,1]+3,cijfers[d[4],p,2],0,0);
    setrgbpalette(cijfers[d[5],p,1]+4,cijfers[d[5],p,2],0,0);
    setrgbpalette(cijfers[d[6],p,1]+5,cijfers[d[6],p,2],0,0);
    start :=true;
  end;

  if (d[3]=0) and (d[4]=0) and (d[5]=0) and (d[6]=0) then
    for p :=0 to 6 do begin
    setrgbpalette(cijfers[d[1],p,1],cijfers[d[1],p,2],0,0);      { uren }
    setrgbpalette(cijfers[d[2],p,1]+1,cijfers[d[2],p,2],0,0);
  end;

  if (d[4]=0) and (d[5]=0) and (d[6]=0) then for p :=0 to 6 do
      setrgbpalette(cijfers[d[3],p,1]+2,cijfers[d[3],p,2],0,0);

  if (d[5] =0) and (d[6]=0) then for p :=0 to 6 do
      setrgbpalette(cijfers[d[4],p,1]+3,cijfers[d[4],p,2],0,0);
  if d[6] =0 then for p :=0 to 6 do
      setrgbpalette(cijfers[d[5],p,1]+4,cijfers[d[5],p,2],0,0);

  for p :=0 to 6 do
      setrgbpalette(cijfers[d[6],p,1]+5,cijfers[d[6],p,2],0,0);
end;

procedure draw_display;{****************************************************}

const
  Gray50 : FillPatternType = ($AA,$55,$AA,$55,$AA,$55,$AA,$55);
  black  : FillPatternType = ($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF);

begin
  cx :=100;cy :=100;
  setfillpattern(black,0);bar(cx-10,cy-8,cx+410,cy+109);
  for pp :=0 to 5 do begin
    if pp in[2,4] then inc(cx,20);

    setcolor(19);rectangle(cx-7+(pp*70),cy-5,cx+57+(pp*70),cy+106);
    setfillpattern(gray50,19);
    bar(cx-6+(pp*70),cy-4,cx+56+(pp*70),cy+105);

    { BOVENSTE SEGMENT }
    setcolor(128+pp);
    line(cx+(pp*70),cy,cx+50+(pp*70),cy);
    line(cx+1+(pp*70),cy-1,cx+49+(pp*70),cy-1);
    line(cx+2+(pp*70),cy-2,cx+48+(pp*70),cy-2);
    for p :=1 to 4 do line(cx+p+(pp*70),cy+p,cx+50-p+(pp*70),cy+p);

    { MIDDELSTE SEGMENT }
    setcolor(140+pp);
    for p :=2 to 5 do line(cx+p+(pp*70),cy+52-p,cx+50-p+(pp*70),cy+52-p);
    for p :=2 to 5 do line(cx+p+(pp*70),cy+49+p,cx+50-p+(pp*70),cy+49+p);

    { ONDERSTE SEGMENT }
    setcolor(134+pp);
    line(cx+(pp*70),cy+100,cx+50+(pp*70),cy+100);
    line(cx+1+(pp*70),cy+101,cx+49+(pp*70),cy+101);
    line(cx+2+(pp*70),cy+102,cx+48+(pp*70),cy+102);
    for p :=1 to 4 do line(cx+p+(pp*70),cy+100-p,cx+50-p+(pp*70),cy+100-p);

    { SEGMENT LINKSBOVEN }
    setcolor(146+pp);
    line(cx+(pp*70),cy+5,cx+(pp*70),cy+47);
    for p :=1 to 2 do line(cx+p+(pp*70),cy+5+p,cx+p+(pp*70),cy+47-p);
    line(cx-1+(pp*70),cy+4,cx-1+(pp*70),cy+46);
    line(cx-2+(pp*70),cy+3,cx-2+(pp*70),cy+45);
    line(cx-3+(pp*70),cy+4,cx-3+(pp*70),cy+44);

    { SEGMENT LINKSONDER }
    setcolor(152+pp);
    line(cx+(pp*70),cy+54,cx+(pp*70),cy+96);
    for p :=1 to 2 do line(cx+p+(pp*70),cy+54+p,cx+p+(pp*70),cy+96-p);
    line(cx-1+(pp*70),cy+55,cx-1+(pp*70),cy+97);
    line(cx-2+(pp*70),cy+56,cx-2+(pp*70),cy+98);
    line(cx-3+(pp*70),cy+57,cx-3+(pp*70),cy+97);

    { SEGMENT RECHTSBOVEN }
    setcolor(158+pp);
    line(cx+50+(pp*70),cy+5,cx+50+(pp*70),cy+47);
    for p :=1 to 2 do line(cx+50-p+(pp*70),cy+5+p,cx+50-p+(pp*70),cy+47-p);
    line(cx+50+1+(pp*70),cy+4,cx+50+1+(pp*70),cy+46);
    line(cx+50+2+(pp*70),cy+3,cx+50+2+(pp*70),cy+45);
    line(cx+50+3+(pp*70),cy+4,cx+50+3+(pp*70),cy+44);

    { SEGMENT RECHTSONDER }
    setcolor(164+pp);
    line(cx+50+(pp*70),cy+54,cx+50+(pp*70),cy+96);
    for p :=1 to 2 do line(cx+50-p+(pp*70),cy+54+p,cx+50-p+(pp*70),cy+96-p);
    line(cx+50+1+(pp*70),cy+55,cx+50+1+(pp*70),cy+97);
    line(cx+50+2+(pp*70),cy+56,cx+50+2+(pp*70),cy+98);
    line(cx+50+3+(pp*70),cy+57,cx+50+3+(pp*70),cy+97);
  end;

  { DUBBELE PUNTEN }
  setcolor(7);
  outtextxy(237,120,chr(219));outtextxy(237,173,chr(219));
  outtextxy(397,120,chr(219));outtextxy(397,173,chr(219));
end;

procedure screen(scherm :byte);{********************************************}

var  AutoDetect : pointer;  GrMd,GrDr  : integer;

{$F+}
function DetectVGA0 : Integer;
begin detectvga0 :=0;end;
function DetectVGA1 : Integer;
begin detectvga1 :=1;end;
function DetectVGA2 : Integer;
begin detectvga2 :=2;end;
function DetectVGA3 : Integer;
begin detectvga3 :=3;end;
function DetectVGA4 : Integer;
begin detectvga4 :=4;end;
{$F-}

begin
  AutoDetect := @DetectVGA2;
  case scherm of
    0:AutoDetect := @DetectVGA0;
    1:AutoDetect := @DetectVGA1;
    2:AutoDetect := @DetectVGA2;
    3:AutoDetect := @DetectVGA3;
    4:AutoDetect := @DetectVGA4;
  end;
  GrDr := InstallUserDriver('SVGA256',AutoDetect);
  GrDr := Detect;
  InitGraph(GrDr,GrMd,'');
end;

begin
  screen(2);                                           { screen 640x480x256 }
  start :=false;
  for p :=128 to 169 do setrgbpalette(p,15,0,0);    { set colors 128 to 169 }
                                                               { in darkred }

  for p :=1 to 1000 do putpixel(random(638),random(479),random(12)+20);

  settextstyle(0,0,2);
  setcolor(9);outtextxy(164,260,'ESCAPE IS STOP CLOCK');
  setcolor(1);outtextxy(165,261,'ESCAPE IS STOP CLOCK');
  settextstyle(0,0,0);

  draw_display;
  repeat
    repeat
      run_klok;
    until keypressed;
    ch :=readkey;
  until ch in[#27];
  closegraph;
  halt;
end.

