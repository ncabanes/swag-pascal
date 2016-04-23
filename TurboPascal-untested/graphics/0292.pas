{ Frequency Domain Simulation to prove Fourier Transform
  Features:
  A friendly GUI with mouse and Help

  By  : Roby Johanes
  http://www.geocities.com/SiliconValley/Park/3230
  Finished in 1996

  Final Update: December 1997 for submission to SWAG

  Note from the author:
* In unit Images there contains all images of this program. They are
  in RAW format, you should convert them all into OBJ using BINOBJ.EXE
* In addition, you should convert the existing EGAVGA.BGI driver into
  OBJ file using BINOBJ.EXE (supplied in BP package) in order to make
  this code fully functional.
}
{ NOTE FROM SWAG :
  The OBJ files needed for this program in included in an XX34 module at
  the end.

{$A+,G+,N+,E-,R-,S-}
uses crt, graph, images;
var
  xm, ym, b : word;
  digit     : array[0..9] of pointer;
  mouseok   : boolean;

{ Far mouse handler to get (x,y) coordinate and button pressed }
procedure mousehand; far; assembler;
asm
  push    ds
  mov     ax,seg @data
  mov     ds,ax
  mov     [xm],cx
  mov     [ym],dx
  and     bx,3
  mov     [b],bx
  pop     ds
end;

{ Initialize douse driver }
procedure initmouse; assembler;
asm
  mov ax,3533h      { Check for the existence of mouse driver }
  int 21h
  mov dx,es
  or  dx,dx
  jnz @@1
  or  bx,bx
  jz  @@2
@@1:
  xor ax,ax         { Reset mouse driver and install handler }
  int 33h
  mov [mouseok],al
  or  ax,ax
  jz  @@2
  mov ax,cs
  mov es,ax
  mov dx,offset mousehand
  mov ax,12
  mov cx,1fh
  int 33h
@@2:
end;

procedure hidemouse; assembler;
asm
  cmp [mouseok],0
  je  @@1
  mov ax,2
  int 33h
@@1:
end;

procedure showmouse; assembler;
asm
  cmp [mouseok],0
  je  @@1
  mov ax,1
  int 33h
@@1:
end;

function inside(x1,y1,x2,y2 : word):boolean;
begin
  if (xm>=x1) and (xm<=x2) and (ym>=y1) and (ym<=y2) then inside:=true
     else inside:=false;
end;

procedure init;
type tfix = record
              x, y : word;
            end;
var gd, gm : integer; p:^tfix;
begin
  gd:=VGA; gm:=VGAHi;
  initgraph(gd,gm,'');
  if graphresult<>grok then
  begin
    writeln('Sorry, you have no compatible VGA cards.'); halt;
  end; mouseok:=false; initmouse;
  digit[0]:=@Digit0; digit[1]:=@Digit1; digit[2]:=@Digit2;
  digit[3]:=@Digit3; digit[4]:=@Digit4; digit[5]:=@Digit5;
  digit[6]:=@Digit6; digit[7]:=@Digit7; digit[8]:=@Digit8;
  digit[9]:=@Digit9; randomize; settextjustify(0,2);
  p:=@scrolldown; p^.y:=p^.y-1;
end;

procedure shade(x,y : word; c : byte; s : string);
begin
  setcolor(0);
  outtextxy(x+1,y+1,s);
  outtextxy(x+2,y+2,s);
  setcolor(c);
  outtextxy(x,y,s);
end;

procedure setupscreen;
var i : word; p : pointer; f : file;
begin
  setrgbpalette(3,0,0,0);
  setrgbpalette(20,0,0,0);
  setrgbpalette(57,0,0,0);
  setrgbpalette(59,0,0,0);
  setrgbpalette(5,0,0,0);
  setrgbpalette(2,0,0,0);

  for i:=0 to 7 do
  begin
    putimage(i*80,0,@pcb^,0);
    putimage(i*80,160,@pcb^,0);
    putimage(i*80,320,@pcb^,0);
  end;

  setfillstyle(1,0);
  bar(6,26,633,399);
  setrgbpalette(3,0,10,0);
  setrgbpalette(20,60,50,10);
  setrgbpalette(57,10,20,10);
  setrgbpalette(59,20,40,10);
  setrgbpalette(5,10,30,10);
  setrgbpalette(2,0,20,0);
  shade(34,416,6,'AMPLITUDE');
  shade(207,416,6,'PERIOD');
  shade(367,416,6,'DOMAIN');
  putimage(460,400,@about^,0);
  putimage(210,0,@title^,0);
  setcolor(11);
  rectangle(0,0,639,479);
  rectangle(5,25,634,400);
  settextstyle(0,0,1);
  settextjustify(2,2);
  shade(630,10,15,'F1 = Help');
end;

procedure drawaxis;
var i : word;
begin
  setcolor(2);
  setlinestyle(1,0,1);
  i:=33;
  repeat
    line(i,26,i,399); i:=i+30;
  until i>630;
  i:=32;
  repeat
    line(6,i,633,i); i:=i+30;
  until i>399;
  setcolor(10);
  setlinestyle(0,0,1);
  line(6,212,633,212);
end;

procedure plot(a,n : word; f : real);
var
  y     : array[0..629] of word;
  i, j  : word;
  t, at : real;
begin
   fillchar(y,1260,0);
   i:=1;
   repeat
      j:=0;
      repeat
         t:=2*pi*f*i; at:=a/i;
         y[j]  :=y[j]  +round(at*sin(t*j));
         y[j+1]:=y[j+1]+round(at*sin(t*(j+1)));
         y[j+2]:=y[j+2]+round(at*sin(t*(j+2)));
         y[j+3]:=y[j+3]+round(at*sin(t*(j+3)));
         y[j+4]:=y[j+4]+round(at*sin(t*(j+4)));
         y[j+5]:=y[j+5]+round(at*sin(t*(j+5)));
         y[j+6]:=y[j+6]+round(at*sin(t*(j+6)));
         j:=j+7;
      until j>=629;
      i:=i+2;
   until i>n;
   setcolor(14);
   moveto(6,y[0]+212);
   for j:=0 to 627 do lineto(j+6,y[j]+212);
end;

procedure drawdigit(x, y, n : word);
begin
  putimage(x,y,digit[n div 100]^,copyput); n:=n mod 100;
  putimage(x+15,y,digit[n div 10]^,copyput); n:=n mod 10;
  putimage(x+30,y,digit[n]^,copyput);
end;

procedure showstatus(a,n,f : word);
begin
  putimage(40,430,@scroller^,copyput);
  drawdigit(42,432,a);
  putimage(200,430,@scroller^,copyput);
  drawdigit(202,432,f);
  putimage(360,430,@scroller^,copyput);
  drawdigit(362,432,n);
end;

procedure help;
var p : pointer; s: word;
begin
  s:=imagesize(220,130,420,350);
  getmem(p,s);
  hidemouse;
  getimage(220,130,420,350,p^);
  putimage(220,130,@helppic^,0);
  showmouse;
  repeat until (keypressed) or (b>0);
  hidemouse;
  putimage(220,130,p^,0);
  showmouse;
  freemem(p,s);
end;

function quit : boolean;
var
  c : char;
  p : pointer;
  s : word;
  u : boolean;
begin
  s:=imagesize(180,190,460,290);
  getmem(p,s); u:=true;
  hidemouse;
  getimage(180,190,460,290,p^);
  showmouse;
  repeat
    if u then
    begin
      hidemouse;
      putimage(180,190,@quitpic^,copyput);
      showmouse;
      if mouseok then while b and 2 = 2 do;
    end;
    repeat until (keypressed) or (b>0);
    u:=false;
    if keypressed then c:=upcase(readkey) else
    if b and 2 = 2 then
    begin
      c:='N'; while b and 2 = 2 do ; break;
    end else
    if b and 1 = 1 then
    begin
      if not inside(180,190,460,290) then begin c:='N'; break; end;
      if inside(260,260,335,280) then
      begin
        hidemouse;
        putimage(260,260,@yesclicked^,copyput);
        showmouse; u:=true;
        while (inside(260,260,335,280)) and (b and 1 = 1) do ;
        if inside(260,260,335,280) then c:='Y';
      end;
      if inside(355,260,435,280) then
      begin
        hidemouse;
        putimage(355,260,@noclicked^,copyput);
        showmouse; u:=true;
        while (inside(355,260,435,280)) and (b and 1 = 1) do ;
        if inside(355,260,435,280) then c:='N';
      end;
    end;
    if c=#27 then c:='N';
  until c in ['Y','N'];
  if c='Y' then quit:=true else quit:=false;
  hidemouse;
  putimage(180,190,p^,copyput);
  showmouse;
  freemem(p,s);
end;

procedure main;
var
  a, n, f, bt : word;
  c           : char;
  update      : boolean;
  action      : byte;
begin
  a:=160; n:=1; f:=630; update:=true;
  setfillstyle(1,0); settextstyle(0,0,1);
  showmouse; action:=0;
  repeat
     if update then
     begin
        hidemouse;
        setfillstyle(1,0);
        bar(6,26,633,399);
        showstatus(a,n,f);
        drawaxis;
        plot(a,n,(1/f));
        showmouse;
     end;
     update:=false; c:=#0;
     while keypressed do readkey;
     repeat bt:=b; until (keypressed) or (bt>0);
     if bt and 2 = 2 then action:=7 else
     if bt and 1 = 1 then
     begin
       if inside(88,430,103,445)  then action:=1;
       if inside(88,446,103,471)  then action:=2;
       if inside(248,430,263,445) then action:=3;
       if inside(248,446,263,471) then action:=4;
       if inside(408,430,423,445) then action:=5;
       if inside(408,446,423,471) then action:=6;
     end else
     begin
       c:=readkey;
       case c of
          #0: case readkey of
                #59: help;
                #72: action:=1;
                #75: action:=4;
                #77: action:=3;
                #80: action:=2;
              end;
         '+': action:=5;
         '-': action:=6;
         #27: action:=7;
       end;
     end;

     case action of
       1 : if a<180 then
           begin
             inc(a); update:=true;
             hidemouse;
             putimage(88,430,@scrollup^,copyput);
             showmouse;
           end;
       2 : if a>50  then
           begin
             dec(a);  update:=true;
             hidemouse;
             putimage(88,446,@scrolldown^,copyput);
             showmouse;
           end;
       3 : if f<990 then
           begin
             f:=f+30; update:=true;
             hidemouse;
             putimage(248,430,@scrollup^,copyput);
             showmouse;
           end;
       4 : if f>30  then
           begin
             f:=f-30; update:=true;
             hidemouse;
             putimage(248,446,@scrolldown^,copyput);
             showmouse;
           end;
       5 : if n<399 then
           begin
             n:=n+2;  update:=true;
             hidemouse;
             putimage(408,430,@scrollup^,copyput);
             showmouse;
           end;
       6 : if n>1   then
           begin
             n:=n-2;  update:=true;
             hidemouse;
             putimage(408,446,@scrolldown^,copyput);
             showmouse;
           end;
       7 : if quit then exit;
     end;
     action:=0;
  until false;
end;

procedure done;
begin
  closegraph;
  writeln('Roby Johanes says : "See you next time !"'#10#13);
end;

begin
  init;
  setupscreen;
  drawaxis;
  main;
  done;
end.

{ ---------------------  IMAGES.PAS --------------------- }

{  By  : Roby Johanes
  http://www.geocities.com/SiliconValley/Park/3230
  Finished in 1996
}
unit images;
interface
uses graph;

procedure VGADriver;
procedure QuitPic;
procedure YesClicked;
procedure NoClicked;
procedure Digit0;
procedure Digit1;
procedure Digit2;
procedure Digit3;
procedure Digit4;
procedure Digit5;
procedure Digit6;
procedure Digit7;
procedure Digit8;
procedure Digit9;
procedure Scroller;
procedure ScrollUp;
procedure ScrollDown;
procedure PCB;
procedure HelpPic;
procedure About;
procedure Title;
implementation

{ VGA graphic driver routines (BGI) }
procedure VGADriver; external;  {$L EGAVGA.OBJ}
{ Pictures in object files }
procedure QuitPic; external;    {$L QUIT.OBJ}
procedure YesClicked; external; {$L YES.OBJ}
procedure NoClicked; external;  {$L NO.OBJ}
procedure Digit0; external;     {$L 0.OBJ}
procedure Digit1; external;     {$L 1.OBJ}
procedure Digit2; external;     {$L 2.OBJ}
procedure Digit3; external;     {$L 3.OBJ}
procedure Digit4; external;     {$L 4.OBJ}
procedure Digit5; external;     {$L 5.OBJ}
procedure Digit6; external;     {$L 6.OBJ}
procedure Digit7; external;     {$L 7.OBJ}
procedure Digit8; external;     {$L 8.OBJ}
procedure Digit9; external;     {$L 9.OBJ}
procedure Scroller; external;   {$L SCROLL.OBJ}
procedure ScrollUp; external;   {$L SCROLLUP.OBJ}
procedure ScrollDown; external; {$L SCROLLDN.OBJ}
procedure PCB; external;        {$L PCB.OBJ}
procedure HelpPic; external;    {$L HELP.OBJ}
procedure About; external;      {$L ABOUT.OBJ}
procedure Title; external;      {$L TITLE.OBJ}

begin
  if registerbgidriver(@VGADriver)<0 then halt;
end.

{ ---------------------  CUT ----------------- }

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-017095-301297--72--85-05341----OBJFILES.ZIP--1-OF--4
I2g1--E++U+6+DUvbWDkRG3bb+A++52t+++6++++IJJ7J0tDEYfhagxfoq+MlxyYNRZVC32D
-ETPERUCcVr6Y0boA1rgd88SZGbiu3W25HkYA52UEbSG5MONzwXOsO3uQLXls8I-1npqgsRh
hArfYnRh2aSGxppsxl8vxpr9Tj1VSHxtYrrnjaxXtd2uCnjoMFWVzBmxCrTFr6O4dbvQJ-JZ
QjoQEcfqsD5wczjnQkWVKpjtj67EELaCF1NAPuPoYHsQTL6qqe2tdaNGy+kJYI9f8nJnIdxh
2UBthxnAx4SPpaJO7goknFGddmEp6rqsyyFyvRioOmApYmO4WcXSoX813hDLG+kA6rbrY1vG
Nu-wHg8w712kkeiQN0EXaTyDiItWsDkN4E65NMjNlyD0a1p2NrNlElVHFFeJ8S2XMEngaR2M
Vvk2APFvDX-Ry4NkMPuE49V2FniUFKDO5KFI-145s3CWA+REdmu6qECTQEfHV1dBEMkBDeAI
dUtp1UElJT1F4CgsUPU3LquiK5WI9xDrGK6eI8ThAcj54KmFjr3Yr1J3XfKCfXbuY+tjHQDk
IjKmFc6rBTCBl21VLxHLGWVbE1YrPNlZrJa4hztPhz-5y3a5cRnZmvUf6iI2RFPUzJ+BAFNT
7il1fTB0llS+INQxNg3ZA3z4xsZb5AVmkm4LjcNPKUtDebcBpnFwAPRKunZnMzd9K7MuPUh5
F0i6-atAS2bBIWQaefUlp0KyI7xR2UBXKRCGDh9bp5rwS-L-x4AugEvq7j2Wa9xxtYYAHAGJ
KqLcYUz1AYkJfC0q68Mz4oeg+yjzhW04lGSfYzmgy4FhINORFShr2UBLgfaqvw8zVm46MRbv
Q910gDr1WK5M6g8ZpGBV1AAKKiOq49qhIwTzb2oXdvbL19uAhkKPn5XPlg4tDkXT5KCMFcVl
C1Cxrn0yHK7U8Y59Frih3a6udwmky8m3aADHMSnyqJn-rOdzaeKDx45q8HkByHm9xaZMcHeP
oLplMQ-bP0bYctjSsoBLuJfj4PdAms1K00uPjhPfvIWTJb57wCiwqMbgWkhXipZSfzcy-cvo
CJmQ16tfTHCm9msAyCHenK-wJZdaZ2z59UP5hF5R3lT4xP2OkTXcAHsBy8HCjllXyi9-i1vZ
iVrsJ87xxWO0sxeAjXOsA40Wf1K1wNaqgVu9LoYA3CLR6ogy99CVk-BrnSCHHwsAWswNecBW
uj-WK5kG7yS1nOFsjgNvWj04TAd8Ad6tiwnPfNx6EHQ5wT+yDPbwHYLcpFxEGkA23++0++U+
y1iS6n-gLOXO++++WUA+++Q+++-NFJAiHo78nRAzOw7+5APltt8EWcBzc3CLf6s3hklaG186
dMIuCTcC3BnjL7qQl24AfoHXvchEw+IIidOa7xkjEiuE3-mwuEjD7lb0FHWkTBxRJ++bz6VW
VAgbhBthWv5nj+akuW1iVqzRg-R5+0OPHtg-DHkXczA3CUpH4RmfeEliN8dXLZvyV8bysMO0
r7fHedJosvGQOzxqZ1jgxqfJGXcjsweRJcZOhN8infT8TEhuWpPGpLV09jaVhJUL3r0VL1eZ
hJXGiRvifhztcRrpzUIruyfsnQd83j+mgyGTxEREGkA23++0++U+y1iS6y2QXkX-++++rEA+
++M+++-CHmtDEYfJoe2CUZ+Ily5z-OPG1-dAnaMpEh-k6HWRy+uyUh2BBdi7t6nCs8AMT+cP
oKUHRkbbg-oMAlUwuFSygtrhrgG-tTihMkRkR-G2o8QqlVTPIWdBis-mJt3SnjIW1+1QnpRP
+KjoYBAYc8b78eheggfOBTbU5D7ORLtfPqkx-X8BnRUC4AUoxfIXuys7m1EqTtARSEFY4jjA
m2sMm0niNSglY3bMa0oT8RDMnTErPz3DhjFzNopNgb3HtZwYo1xMkDM1I2g1--E++U+6+DUv
bWBBNPsdP++++-M-+++3++++A0tDEYdfM43Ugf7WawP-kA1WvCzWmi+wUtp-sls12mBXy+FS
-UN4BVRDRwwE+kM4Vho95X2kAX1kAYUlzDz-+APp5m-szkg6DW+-kEwgmAAkzEoQ2DB++4Ey
W1zz-DLAVvYLtbuMTuvDCh93lA-E+U-EGkA23++0++U+yHiS6xLul4dg++++3U2+++I++++l
9Yx0GahUMK0mga8Plg5+kC9gvy98s1m1bI5X5UAH6qDs-3s4-YMq3oxrnl-1-UO4LEgSAH+m
AD+mG14+kDwTM6eVzUCE+4fTzk76Gn+k5+-W-Ug4VUQKNB+kzH1nYAmTTs84tYDxcyv9rQL2
k3+0+3-9+kEI++6+0+1tCtsXh4lBrro++++K+E++-E+++16iHo78Oq-VM98mMdj4kQ1+sinj
sgfUD6CRESAS+lAXMzU2LUM4FXMLHrTD20A4-cOR0lslA16kw176ATnzkE14xFwUqDs3+wBy
64OEM4+s+AEA3UkA1mn6c85uMSP-n7xz+6VD+CIM6D6D401eGOJVyjQzE1ITtVx5xFBRH+kA
7E-EGkA23++0++U+yHiS6mCOV+dk++++3U2+++I++++n9Yx0GahUMK0mga8Plg5+kC9gvy98
s1m1bI5X5UAH6qDs-3s4-YMq3oxrnl-X-UO45EgSAH+mAD+mG15wzw2+ljIT6BXy-ED1TW-a
Y4-UC+121-MA1+wgm80Vya5akQmLDw5+ADw2vQm5ySTufCZRH+kA7E-EGkA23++0++U+yHiS
6zyqnpxv++++3U2+++I++++o9Yx0GahUMK0mga8Plg5+kC9gvy98s1m1bI5X5UAH6qDs-3s4
-YMq3oxrnl+H-UO4vEgSAH+mAD+mG14+kDwTM6eVzUA1EkBEyzsL1+k5701sUEJt48MTN-M6
Uwk4MTYH1+nnUNU-8gw+JIwm1RADRGzAzH1z-1D6Rn2lA7E++3-9+kEI++6+0+1tCtsXWw0w
4Ls++++K+E++-E+++1IiHo78Oq-VM98mMdj4kQ1+sinjsgfUD6CRESAS+lAXMzU2LUM4FXML
HrTD23A4-cNh0lslA16kw176ATnzkE14xFwUSDw165v-k5++eCm+-+A1YAjkk67o4eMTNVvA
TDYH1+nnUNV-+W9DM+3FHn6BpKzz+hJwa5wQpIxoAH2kZ+++I2g1--E++U+6+DYvbWACB5km
S++++-M-+++3++++BWtDEYdfM43Ugf7WawP-kA1WvCzWmi+wUtp-sls12mBXy+FS-UN4BVRD
RwwEAkM4Veo95X2kAX1kAYUlzDz-+APp5m-szkAUTg5+Q+0cv6+2+kCEmz1+UbEOdVxa5gnw
yGQU40E5Bhy0D+nH1n6PqLmMTpkXDbQlAH0I++-EGkA23++0++U+yHiS6m-McMZl++++3U2+
++I++++r9Yx0GahUMK0mga8Plg5+kC9gvy98s1m1bI5X5UAH6qDs-3s4-YMq3oxrnl-n-UO4
9EgSAH+mAD+mG15wzw2+ljIT6BXy-ED1TW-aY4-UC+121-MA1+wgm8-VyXaUtX3+n+TlttyU
cTYA2DwQY31eMa7U8+2+I2g1--E++U+6+DYvbWCgtMCbMk+++-M-+++3++++C0tDEYdfM43U
gf7WawP-kA1WvCzWmi+wUtp-sls12mBXy+FS-UN4BVRDRwwE0kM4Vgo95X2kAX1kAYUlzDz-
+APp5m-szkg6DW+-kEwgmAAkzH1nMCPDDk5-h16TtVw4VVBRH+kA7E-EGkA23++0++U+yHiS
6wV6sipl++++3U2+++I++++t9Yx0GahUMK0mga8Plg5+kC9gvy98s1m1bI5X5UAH6qDs-3s4
-YMq3oxrnl-9-UO4HEgSAH+mAD+mG15wzw2+ljIT65Xz0kUy6+5-1mn6kn1xADBUtgiTM40M
1wEAI5Y4e5eGOOVySnHnMTst614VWsa-cEE+I2g1--E++U+6+DYvbWD4WX9aiU+++0+2+++8
++++IoBGHolA9Yx0GgqHcEv0A-F3PvS3pK3FO1u-n018L7AZEz+X0CEo0YKET+eTUY6UIFD9
Ff8yjNQi6HIHenbdDO7BvqiJ6AemlIo1WGbqCQkxlSMRFofNul7Eya18khew-D-xT463v9-4
FkjxuZfOAjhMgKwehqSCT2otozZLCd2zIwvoTPhpiR1rnQfZEhzLqiL0WSzzlkzjxsH9VPuj
8-Tu5dE9FzqoR0tnNjo4T8WTI9yVyEXBpznv5runzCfX7E7CDp-9+kEI++6+0+1tCtsXQAL-
i5g+++0s++++1++++3B1IYxAH3JE9Yx0GahUMK0mga8Plg5+kC9gvy98s1m1bI4XXc47YL5v
-5s4-YOCMCQUTlyTo++4-cMb0tcM4-YMy-bs4Dvz-v8+22UnUm0ENUT--ynmzo5k+PjQTl-w
k0tH1s6Dq0LgET+-is+w009IMOTzzvQ5kzzzuw2E-VEQ4viM4-V8+3-9+kEI++6+0+1tCtsX
8QsxmLg+++10++++1++++3B1IYxAH2FC9Yx0GahUMK0mga8Plg5+kC9gvy98s1m1bI4XXM47
YL5x-224-YOiMCQUTlwT3zxkDkM4-hw3LEmA1+nwEDXzDt+3V20O4EG-B1g6Da0Lzky003d+
5UETg2jMUy+1RdZu25n+9jQT-15Jcx9zzxi1sTzzxK+6+lYZSveM4-V8+3-9+kEI++6+0+1t
CtsXpPf89HU0++-Z4E++-k+++3-1EWtDEYfha93eso+EVaQhYHL-Y-H5QE4-qnm14oBwuEtm
r2hQam8xLES0ItZowODs+T6E+Y3eZpg6vQqCJrC0S1TfG9N-pVO48-zmzwjvnylc3YBjB1dP
x+5WmRrDKtWwG9Uyiyc7wTrt52-2jmQr+D0oX4A-Q+SjcCTOf2lfi+Sn2eUgzLyR5eTkMwB7
U5grhtteiS2iNe+QbDZfL20IovKJo5aYTNlWHjcsmNnOnZZxOAPeAqPQTXSQwSjaO8bmyLLQ
TXX7bD7lFJFm6hyJyohZ68tnqp0NdSrph9GBSr2PNpQu9jwrL-qGEroEcYxlq-ly1J64hMdw
t10SZehytIQiBLQWPaXiviIWtj9ObB4LgPs2T5snxijaB5Bk+hkwgBp6tdGDgvZ2niOm+SsD
ZM3y03v8t9UbrfVb5DT22GT9MHkhtsXbL+xBBmMiBRrMlFIL876sgEPglUtiVZ509cjudVUZ
v96CTNN1jtNny+rZf1tHzHTubAyDz38L69zytwnRdCCCnELyPa5vU2dyMOyNTOKprVTrWwf+
cBiirLPxQhZeiZmqf8kqq+vrkVZx-NK-ml0NcPMDDfgTwH0pmmbeArr-Thhne+sR6Y85YfHV
MMUslNnoueBVYjEtVoZZsqbxScTHX6TMVXUSRfTcKp+Ny3P3SSNBdDRbPck99HC-EoYNHrub
QG-ipu4dCpJgDELU7Lg8e7thOr00iQ8fHvAywDfJv-ROwqfwRbYi-DlcWtourC1xvP25wD+D
I2g1--E++U+6+DYvbWDusMqQaF6++83O+++6++++G2JAI0tDEYfhb3pg5BRplyxkWFoqKCyi
8uDSE8hQBUpU3GWEbP8cBj4OgscJKkLImYNPc5omMEBx8ckZa9FPUx+RKgr8A+XFSYYNECPa
AGq8UUgV2E6Pr72IK5sE78FxQ-w2QDG-C2ITB3CqsF+OniqtLvCnAvAJGOWoMr3XGGRvCDwT
tyiQQwyxAxMs4jjaBzDTbo-czALH7vuBLZnKoR4PTnaaOQLrWUVdygZjbrfZZHxu2G5otnwQ
5xQEyVXRFiMG3NwkMJZq0saDZa4ByB-F5kgozIUxPX4C5eYbfPpkL89IslPXZ0mZbfHqkb3A
dFur4+TPGXpd5L1qvzngpzLqOwhtVcS-wGTaw5aIya502Vm6XveKgDPCQGVpnmEgkQ26ZFMG
pdsse2FxV+VpIB8W9h9N1q0Og8nDBER5uUY918IyPCq7+s3BbNJVms7kdgv8g6Lqn-3LqP+Z
CC6e4vPqnV3rnP-ZFNdOVXLoCQv1kAHiQB3r0Jld0ouAaMIfyN3bltm5RuRByc-YQ57rpY+m
***** END OF BLOCK 1 *****



*XX3402-017095-301297--72--85-13441----OBJFILES.ZIP--2-OF--4
WtBnddIbkLZsPoqd7HXPRVLHHHC1cpqtDS9kOLMpQHWJvDOJqochSRkyOU1yQL5cxI0d7HYr
4zElQas3x6-nKrDpoepAXj9gWcDdwpiN59qetnkvWuAw4FmdZiM2CbrVNmG9IwV1t7a7CDz-
ko+VVZAzYAMdoGGC-c37nKgNioK1egsHOqer-dtIK6XIYVmvuZBWrhdAQyleVObJgUuTwWEt
+vIgXabSSdX3eHCpSVN5SP6sEWrfggjaL9ZhoZ2QtQauv2NlT+GSfGlC5MrQ5nG8cxEyCktw
yFUtGaq6goGr78QrbAIFZ4xLPZRYkNVljO5guopmj+F5dxvBlXPnn+tL7QV5dGireleciOae
-1XQowfWP0QsD5PYu-qvQKBAptkrc7+GrxYwGUI6rkds40XTTU3iWEQC33jQNQL1+hho7Vg5
qxkPs0m-iyRARkeZ-SQOkz5jP07l1w6nMPzzk4MQ2iR+3gynPH8WrMAkNBh2QQ2WYjD+dkii
SKQx-lnlbOIsY7Gr03rzSv0g6It7PdBNZT-hnYIQiWFCYtinWiBCmRPN+7MLxuUZHVAIIHnm
b4H1pcnWLfDH51xbHHCpokYCz8LNdPCizb37zZz3OO3lVAdAfGOjkdpk+gr4HApAQDW5KPQW
8zuvmmgPvNWXfUPud5+SXC9Yb32QuQbWD-X7cOAs7LwIFrcSIKoDezgtNenmAD-A3WtZvK1A
6YGnQ62qOfTqkd3eindwSy4ADbnzflnFA8A7Wr3Iamn9qXr5ANJur46QpTP9gUssyrByxCUe
4vMgm21eqgemRgY7sNtxbcS-WVneFnQlhmkhWC7aVfJfb2NNtSK3TlTaBhUrrhN4C2MM7oFt
q9GcRPG+Xoy8yM8qnExSLbYEIVuYAExcGHJ8ZFcBaJe6y23nkYOMsuKF5rXVaAYsZ8gRpWn7
mGD38GaDt6-5QZmZFeZGswKcFF5lWIrhaT8T66QuBqmzBLCH5E+9IGgDbF0XSxuU4C2dApz2
-iomLFltid4bmnnIWRFa6fINdUNpZYwQMeD8FuV3r4OnrLNTMVoo0zoBzuqBLgRMVJyrryjY
0oOjNoL59QB1rJ3epAQCQIjUyFOeaN1+uirK426aQD9kSwBrcBMh6DlXcRML5D0U16xEAnDI
e1w5ryjAIqtF4spJqeqff-Y6b267aPtleKAg9A6jzpCaRaaJbkzaEFYScIMnp6Uz0vw1qrU4
pOYnleoltf5m-HUulCiis1to+biLAG5RxvhwTkfwi9rTYNtGGQTQEvYOgQQeIerQOXhQnEla
+hBZuXJI7Gvbp7siaumsfs-hrbiuoSGrHerGbaz8yuEWzaa6Tqe1ysSfkHMEDo+hVq0P3ZQn
kpN6EjMnxT8ouTwahmf9a+wWq1VvMxYGb9QPXKboW+xZOdFhokOpTy-VcCcTMdg8INDTLx0E
RIJ2nMYl47Isl0cDMPb1RRK6g0-5LOvsNsD4lYMwX2fpUKKd8UtdGKiDbRF-EnBiKLOuCXnU
T-ssh-zb39JnhUfCktl-SgW9c9o1nYDucIarSIYNQEce0RWeHGPJI04F5Z00+qcocKNiIROU
wSW8v4P+vRMJMrvc4sUYABj3icYDbwQgWCcw8iE4uG5mW5F5VNegCsGOqVy5S9qJMujnfJYj
bDMww9+7JtCDo027S8i3IexrAKyk1A0eYgX1ocCVDCXTS-WMZ9j3FHRLtsabF-bCByx-T88x
ZOZiMx9czzEfgnrkg5ZYxgjnL11P9K0jjml2KP2JSJWKA7G5FqyZBhRha7tGMtk+zk911ZxO
aPcECAyjJg8tGt7H8DmKm+Kn0shsOvKGBmt7He4E5qG7PmUDXufsJo7hvY7+5mcpTdeq5RBV
iQ1gawslz+B8gCGUEZLYUhTuChv2mmJwF592FG0nl15ZsORdCl-ed4zGHOL4C6iyGpVQPo0K
O9L8VhweMnYjLWa8L+1FiwGnbOO8lrWKeAJjcw+DVFfD2YnhOGksiggiBcXfRHFRjpjzQZ0j
MpswqZ4Vq0kfmrdYwQXXhQkGEYrgnrFiGtGavbGCyXmQVwmWpdJ+OIOKBjVi7yZV6rOvQYoy
jNOk-6RDfmKgDMITfgab0lCKsD1dkcGphn0beybDdALCXtXyH3UKqiB2hJFDK8mL8RK5fMUX
kg1LxUirVzZrnqqPGlhyC7COTmyKnhahUetpIzDjAYikk7oTtgV--8i5hVHb99zM59xV9bZy
OAHK2wnnWyqkPb5CSJWCdRMHWBEUgsEKqnxtFQh--2hkUS6gU0Mjysj6wFpokr4PAMv62VHf
i1i3WqOAAlV2Q6zYg-58M-1-pJGf3fvbNLwShRcqOg7TYYDsd8r62XcIvkgREr7AtF3NUbZY
a9CJ4Vh201IWCIGKzKCcJcRECJZLyzDLT3CF5c1nsmuclMyPGUz06nUCWEoWd7fYHAamTkmp
T-i8vgerg1li-GHHksJ3TOfLukosmgDGUzE6XXgJ5oE6BQ3tlzAd9zgbIRqzWu1iJlksyp3u
o6xoXSuGsUmZ-yaFuQuXB-d2G1KN5VmTwf6ToYDP8yT8ZRQJdu75uI44IxJX4Vt2lBA1Wpxe
2A5Jrd0QdLVuw7SbZeizXsTLsoHdMM45UOBk7PRqYmKsu7HASYgeGslQzcBqgzlbS--lg7nd
pqMt2zzkFHw7Ov+y845h8Hq6uGREnlSmCHW16uOgAAcLRgudQLLDEGYC5mtPFXTMHb9sBUV0
EMcXVhUSZRj2ngwerxffVSbnUn29NjrnfmLDHopsSiRlWWDIyW37Qjfi9+GaXRtOctGsrgUz
wH1kSnIKksn9bFj7mwsIbZsbTTW2uCKpU0FrWxGUvByshA7lEvQFfcaQQueKi6pemdAyT2dh
rYlm1-Q02SCYPZTh2Xx6bJD7qvKafEdDaaBg09LtpC41JG+CcPWP0UiYnoNk40yxbCGMmeCb
9nidZXdBpaENxhFvft6uPXBeJBfA1XxOybuWXZ8PHtsTepm5GwKjJuRHtmTOj9PXACR4OaNq
CCoypb1OdES9VFwztlUD+vK1fDTt5-FxoHXvRLvqvLfvUcG3fz2kw+SeZG2VkxOUpOFZK5hf
nEkOH3ah7aorfOOF5CHlFGJPMJ4oU4-yIb7cIKTZKpvnF+g6tWQZ-lTnr6BeVS2WYXfS3ZSX
hxXcbuZ3b9NDfoAD6AlfPDFDM5tGQfnCC0wH-MSJWcdXR4E5Y5BWFGGpqk3LcxTtu-zIpCK+
ueoNaxtjnMUFSv2pcwuDpmbW8EHhNIdZeOXCXu2wzIEFGKqZpbGYKhEfePHh7fb9VjgkLfyO
fkxiprnSy+aeEfwrY9JPJ4J3bgLVectSWxFOIcp6nfLZRVCNRmdBlCexeqCJpfFQFERehEPo
BeMWBPJO9yq7C0YpIr8ihhgjEVz1Trqg15j8D4dJcB57pzsEp6u+aXb2GLgI7uqaXdhHUsB7
vvWhgEffR8-mKr3keMEjcId7utp1cYNIb9EbihtGOcfXJZehfl9DbwZ-fxVomtJthjeEhNuF
T0k+FnIWswHL9S-YxIVRa45xuazkA3+T2ZKbmKxApUyNKo5ho6fda8ngMuS7RxFFRG-gekaX
zrgtVhxcF4fl6h9Wabl4LZVRALIYC+DBbL8WZInaQ-2ts6E7Ow1FvBpngWOarCV7W9VZFOR2
mv+yYoR8biU7GX5-3yS673-2yUoKZe5Db5z83bAuYKRFSEecy+WC3kNo2tv+0JvUIscTgaLm
6SS677-bXQm0i0aTgYIjCyoFItPE2YudPTCbSs0nRcPkfXTas-IG2dCjc9332gVXO0Gkzwv1
zxMJNwXn0ls44ik5gAGZFQKm55DX8qSwLtL0qO--UZbebTTK+YDUS0tctMr3IuVUKAPrXIvV
S2SAALaK+2y-SnfUoHeWcwvI08XBQvIJI7iJb7InfMMSYUwPNa1ojQsQh+LK38TKeCRBePMm
pGbUW+BN6j7o6UzZOaOYhV8daFjVaHbsrKe3-UoqiViR6tq0gG6D5yE02fOeBtXOp+dNaTQu
wj0l9+5PQAsIroNma-fP7i-eT-ii-Yx6298-GbWFLKmM9aZ9ihbZ57s980ILfmAREuBthYjK
ZwFZlvA2P8Bn1xg49sb9XealPGVLMxhEfaNO98vnRb6dO44LFTvO-6YS30RyewshfI6ewx+X
njfUsGn-hUY6e5ZgapO3Ql+9u5c+UJkDuuMzLehCpwRBmeh4heG3hMHtsjrZK6jv2SY-p28H
eJpYOZJHJ6pmBMaoT3BMf4eIeoaGpWv0UYkHWYAXHaFNYOOKMSqZ0hsL1ZG6B8fZstMwDv8K
5v9aSFVcvb5AgZzj7xUz1ejozkggCOwMsv0ew0akt3lYX3CETu8p9-3bEzu7ZXf4lutWNYLC
8kv4SceXKseX7nZKYiD7Dx3GFx28RCmasxkbniGGswVtlTC2JGI2EkgH5vPkCjGWlJkYbPJ8
j8Zd0+z92g7XwWYkuXUrVFf6G1LvdUUznGNeBJy5ZLEZhmYK7o7+NZLKPCxmPx4sW+enfWML
B5eSlOcgKB6cD6OZD49t6vKP9kap7Z3enNRAxQl81Toq-9WG2mpClDkx0AOZre8t14efK0tc
v3rWb-e+VAS8SHU5tj02aVZHssCWhx3MqMN+C3O8tVL5-dlO-FKwxu63XSwDCAk1CKXUsMCJ
hwS2qZIQIyDvAkBf5VoMG2umzN492n2zDprQCsSLYPtSlZqtcD40C1z8+mR49LJQ2CR5eHbM
IIgRms7H8ySe9MA4hN7PJcgHwJ-9y5Rt41U-iI3fe5mE8VsPgIl-LGI80GROwQVlvpHeVpPe
LuNVjSFLl9nW6EgbCx1eIrt2YSd5OaOYxVtChIlQMPpXDdOKWHj63+QHZ+TjKp0QQ0GbB77H
F9hzro6swbo9yN5jKwWDt6EX-oJwAX5yjcIzta5Ud4eNRDAg+KGwRY3ugb2Y4vTN0zyqtt8A
pmsMg1eZhtfpqULdmS-6hEnCFbRhfUx9yB7XN+BKdzGvKKBYtIZnZ3eOwx-MaJhxCaggTVV4
CuiEdBAQtIZnZ3eO2w7YMXRnTsds0LTvKTiXD-ZfluJOaiDL8erm7Avg9O-RxlOIKdcHh0jp
GhbAt6njaVCoepnhgymJTC2sunkAb1csT+SQ+wuHmzZ55UNSGSCKJCsSK6DL9aV7Oyyv-Izl
byZ5Zi8Il4gL3hE942t5fppEflOmt9zBsJKCw051TK19h0Qgxbs0-zJhxiCtx4gLe9Ea-ixP
a9+W1YBA1DNbYoEQVhUQXAIbzbbqovDoZpPzMyiSpTWITbdVu5o9Qyjoty7b9utHboUCP4DB
TKlR2BhQj5uVfXVzSft03cyFBsyF8fZKSODytbLtjcK7pLQbQg0VDv7CB6wzGyyzCjGyVGyN
x8ukHft4TuMsg+ruoZ5fvZ4qnHAbHvluEb3CTrSHzgwbtAUbt6DyqbxSzi-TDVVurs9Dbce5
3R5DojyCrfRESavfijzKpuqnjjJmwrVkwjHDtqJlLtfQicvSCaeRzOLWn8jngtujoyxxEiOT
JNmnRCVx0ymjUArhw9wsNy6tOx7xxyjKrHPXTCTYmuwSrv6sNq9GafHSVTqNI7nXDv12zemH
RT7Rq7xBlJbv8n9wcDUhyX-OXGEtQvTEKwxN3nOhtun4zFDrHrwXsYXDRShrd0TW9BPcxzuR
j3YbhwapklwQLjocmFbpE1dMJjM1uRPUmYvQDqFkNSzokLRsf4Qiyw5r5Dxjw5aBVs2zWvqi
6Zc2zkJybjy+Qz0yVMDr9QEsqnzwJop1Tz4YjrNVLxurg2yQhyNyx0swATCRzkJEGkA23++0
++U+yHiS6mJc+N-o-U++9Vo+++Y+++--EYxJJ0tDEYfhqQxjoyMT-z15QP-nS2cwJ4b73780
dbovWICeHZi5+8REpAg2Vn3dhmLOcIRGRFdk6HNAHMga0VT2+RG8js075R5e83oWXIfRgMR7
dDEfqYt6C+heLIXnvDZVawQVt-Rguk3LWXtu7rftsT4HXtwMnExwVkx9Bk6+y2yQ5XY7HhmI
***** END OF BLOCK 2 *****



*XX3402-017095-301297--72--85-24907----OBJFILES.ZIP--3-OF--4
ELwVsVC29ux-+6ExkwRDTrI4+9+utzQ9+Bk1dk3eS7WUwR5kknLZBMUuUmnq0PsmXHGEeGNs
egP5CrjLq0xgQObCFW06lGInu9334cCU2Kn5rbvBi5BYk26y9LhgUQN+hDwprRdOMpjfm0sX
N15PfdVxJEMmgzQ0L5JbDoNcWxYv01qvuBUlSELZwhz9tsNI6sZoltPYZGp1ZCHoo32XyOm3
bEwXR7Sq+Ty8dguWOW4OEIy+QoZFJgaUz6Lg929Zqn3Ybm6TnWcdHElbPlKWsvRVWpDIsVZI
-icweiMX4THzZrMFMXgx4YHcLcxfpy8XQ-m6y1IT4Snlhv+LL3j2RiaZjENJP6xFyu3X9wH5
s+0qlu06PODJh7g6DPx6PDm5eguo3xEleCf2JaC1Cyuo3v-uaBdeN50bqgNmSJuXBfuYJKSt
36uBkNVEkTNeR-0c+aRz++PluqdY2-ldPtYHapzayPj3G+HPlG0SKA5jq1H4RV5Gi5gP0djA
riCl6TWIqLiOqf9PJa9CvIGJHQA0wgdgpUc6BHEnXqcvqpI-NyGvEqBk94P5HSlXcjC3tmgn
JqJTjs1UJ6-InV3celoqhsJf1KrVqhiktlfPQyqpQRZhUavpDxc4+jOoooscq-Kd9TQIlbxz
3o8im3Ia5dXg1Z3iBBXRN0Cj9JdygMkiaudcedlBMZBpsiOqaL5gAaw5BLw6Gi4e31cv4Idd
9qoGVst6cFGBaxgZpP3LtXYvNV+VL770aM95db-TFrOaUEqZ5cDOGMCrcEEHp2sOPRgZt92-
gFQZa0Z+rWMlz280GFerBRzspTHCBv0kLN5UqHcPlr0WDRhS7tZLpq+QGjiBGHVKU0bSlb2Y
AIbgJ0gPBJu1dCh-wIzO-i-yco0g+TsIyBo6QC7iHk4VgA5g89RQG9kCb9UhCzC89I5c0tQ8
USFYs+0z352QGXdlxvMQLdYYOqvQOwhoXRCsKnh2v2j8+NzWgID2Ri6CtbiSgoJ9jJl46iYT
4IxPgLh84qo35v7fmzmph3nFuf6RMcpwUeyM9N0YfhcpxckfQdJ7PqBAx3MRqP6vmplZghij
tRu69QwhiIoPvmDkAQBq34tZghp1qhp5o4e6hU4ZqhIdY5g8l7z0gpLVBphjOCC4Stu7CfuK
UVL9IRiCwK55FehdFyuoilhEr50LuPry-I3244LHPgQsgSBKmwLN0G3i7mE1URYHtCghEcLh
VCkM7rPQdKpkhhHbqUNbGrpRqITnNivlJYzlr4cizvgcTKHP96OmPATBvFcfwLC24az5ljDl
qcL8QYIjTVULdQzN1mktmi7ELWzEK4heJpaHbLxeJsvxIm5kC7pPbh0LTZP2jLr1n6sAoDXa
hzfW7mFCB9RJlruWwbOt+2jdb14VDxk0kZKEQaoGOxXyXAH7Bv093TpVoEHDuingefscYzVB
v1zki+pHU54jTMOqURtPSDW+j7jgQhd1q3cSptRyIAETsnbr30GyaR6LzGEqahj6hHr9NQ0q
dtRu4xbHWvqhvJdRlinUD3chamyqY3JNKnBlzq-9ATV9LOmxSsHMgRrsQNbvYAnni8lH4qzo
nMhwlSkMjbGudyfA-Y42CnxtmgFL7bs1rn2o22CSeZjvD8aa5BjGFV4uFAFBVPA14atFDimR
Zz1BMOe35LDgYNVflomofV3FkS6XY9Lh2f2d-g061qWCTMeqUJ0HnJOJ97A8qxliY-yUN9AJ
i3wwxQraoBDQkeC-6dVx2239tCsHi9xkuijBcJJXVAHH1m9ZdOMPiSRYYJHNPu3hgZnaWLpb
xDdNbz8ywCgy7OjJ1jZaDePqbSDLInuZ3tnQdqWORQUrpOwphygqtPMxarWYJDHhjv+xjFuR
rf-h4agLb5WxePpRzljChdL2jjSIsNlDaR4ix-ywMcxvaAO7MNwmFSDyBapirD9-hPr1Os2h
rJUP4WI19BBlmkRLO8kZb9XtiBhvze2prj-fPyDNmXxdvyNbEfjQjX5r4l-+tBwOzZjsHwbL
6UWBLA2Rx9iz+J-9+kEI++6+0+1tCtsXm8RSSi62++-10k++0E+++3F7J2l39Yx0GfqKHsjP
FVW5LqYIGGpHGPYoKX0KZlvGGsYKSX-VgPDRde3Eu0ITMBo2qYA7ndy1GRmpRhoaIBcYdx71
GTBB6ep0xV0H55761kjFMhUxB9HX3ZchJHlxdN3Z8ot08OI1AXzD8nqD7NZtlpB+DbtQzIs5
I3MzTjwYf5ujkRjXpqJ7SiQa-N+CbTvkx2Qb+K1bhe76+6xV+TUBngRBbcvb2vHl4VzGwO9o
Yg3TATt5JpBkVzXlTD63hs6TnuRztk6nskPvWLAXUXFlHC6CKQNhq0FeCnlBU0aPOn6-hj3k
SAbZak8wXoRIBcAa9Vj4M6f27yad9GunBQtIoghCtWmPczPIdN8G8x62SAXH5xgfiIWIbH70
EpGsgdFE7zwtb3KZNdumCIebQ3IeiFUFs-2SAHF9fgD0Q-01IvV2GbsdL34pZvgWsH7SvVc7
w25eKWyt91PYyJjWoPZ4bf8tdoM3wfQ2pQCHZAqJL6T99XO3lyR89XRSWxSKC9Z4annup4Uo
VupciJjXpu2zI-rhlkSER5vrcKeB+fxmmkbvHy+wvp7JoqsNkB8GadR6zm4oSpoKRy9KW7gd
AAu-GRTZBvkyWxSK9PrH1nRB5epyiO1RRBY3+lfjkEdJ8y3kR8pGvvOVuZuwJnxnLOAoKkOI
wkT-hngqJSrW1BKx6AssDkeyeRUgDZhksxKjQevSKDJLK0lLROKygVjU8m3Pg8bP5IY1ipOf
IPLRqUWi4PPfUgCKRlO0epfRjPih1OnNYZOIz4qJKfD+i++exa7IMv5oE7JhRxQDoSL1aadr
60EunZ-pPKYXq2NU5KxjmJvMi8etffybdetdGLLROGZpHM2l0ON+hghWQey8zsJK83lUM6YE
jJtz76-y6rBNvdA1-1PNM2zxc1NPIWrL2GJoePJNM2lwLk-BjRttV8Khea5IKa5+cnBPBOVa
9iXKvpDp9+81-w8px7CIzbUMvA527IfcgYL7rsDIdFL+y2kM0O+7rQtxlZ8LPaKiWpDLSjoc
BQtCbm5Ai2uRcAPAAsENZrO0AOo+lVSbfjLCoRk3aSj8pi6MGsGXOzY6iVMrUbhn9WZALIKd
t06HJkOAfsGv+aV09na0fYogiNafhvLsFvLG7fzWApkq8PrIab5hj-NgabJfg2x0Xx7qOwNJ
2GJzLmMSiUdUr+hr-R029l8HFOhLgTFNvZfuiJ7djzKM87QPluXxvUcye1Rnpw+8yuNR4kmJ
k8CqKtHEFIL75meGlu7H-F-R6k2oZQjXMnt2cCjMoGK7Foqk1rYJQ5I2J7oaQvPzlA55Mr-w
jgxuTTtkm+yShO-Q4aiWxBR-6Y2N8AI6h4v9F+6RiMcefHiF333E33nKD3lZDIfw8hWeHA-k
+0lEwXLDkaID72xw4QrrmoZ7UYVWJAa-nD4G+XVq46YAY4INs2EjAbq1F+tEHN8wBtddgt8V
O3jh+jXPmpomRdXMY5BUPDff-T-NAqplgHZdRdX4XYXo1i+8bzRJYH6UdZSsDdbT2Ml3by6z
r2atWHBlMIe28t3v8HTjem8ZeoiObguvG9sXyLnSBO3jMgQC7bgdYP8Pl0GVep5gOf8IrGEa
BiyOr5xvrXJtOVjcwcfN90KOG5Rl+xAfK0x8zr-LZSHPYPhwnXIa6Urz8xSMHBsEPX8yljzA
dPw-I2g1--E++U+6+7QwbWCTCmw4l+w++DIJ+++8++++FIR-JYR-9Yx0Gdos0rFIFNOrrehy
rMFw4Ukl6xf7WR+1FBnMC0mEBbm0WS6lt8A-CcQYnekmi+WMR4RU-aBbAYSurlgFRpnob7on
2b6wuv8QAso00qEKCfvE2EXMGHEUbmEY+JvPoUZ2wuDdhvRSBsenvfSeupLRKrJjrLjfrjje
hNA0hqWFgAg+E5BL9bwGQhzHkulrdr42i5QO+QWYojmZmsiT9bqm4+1qvOOI+CEhmpxik96g
zybotGzKfDz3Wyb9exPLj3WJDij7z8J6A1hxreBNKSZnopQsBeEzxfDollMih0H2tKvOj9Je
zPdTqhBbzK6qsVPwvGBg6brNdecB9qnwizGbBxdTfBfsUbrxdcojP2W6UkRq+s386kwwDhyZ
w3rt6Ju6vjbxB7USrK2mEjVtxNooK7hq4X2mEwjOgx3Dr8MCsYvwb9VHicXwu+v-02qz+TYk
VRBFGgh+skKW5CLHHVzEbH54Y1t-+ZJdEqEIJgvl1+JddqC64KHDA2681s59SiaaB45aYr7n
nTnxiPam2Z61HlaY6SbqFyfiXsWJesunR4FsvJFAiELWHQj3kAEYwPNsDaBUuyGFZWLq-Ah3
JwsrMD2SA7slmi8cFFI1seb1FUNtC8YnSBqeCeMSAQ1lGgsguZquzBmyoQDlwMd6XVoWlrwD
X8x7XkjqWST3jYDIsjKrJLCWj1RmpX5QxtJQV3DyLjyZjUalNMogBMyOlo2u9mLS-dZ7eElk
mXS4EaKMgqakAkQphTC-9cDsWT6d7zeJBcDGlQZKMYxiAg8F751ax-4k0ooIXj+UazFByq1r
2808mIoxMCLh0Irz5Zj1Bto34MKSYPHb4l-BEy0wHOiH9OezLrpr9l2phGoLBQKJhRnFnrWD
4hcVH+2dwF7djw9eD8woliQAYD1kjmd3H+W5HYdA69WfZLDQrqEZndkVsCrlbeGF8y7tWpcb
7l5NCQvPRQsvj0CiJIUU-DPnEMBskX8kd14-h+cLo8pRWIAUTibjhuXGysLc77C7HlV4htaN
ZAEYJlrwH7tjj+ZmsvTUBcq0L3EgTGdpPVSyVSo6sg5Po7HnPs8IQsk2VYXXFoEorE9BkQ7K
fWfZ2Qsmg7zjv1patDWVssT62Ef15u1s5hLCKPkAMM1VjP6n7k92kTBTDcBKEUjC2Ie87BCr
O+1QN13RIuOLIgMViYdDIYPVaO0Cd5k9iLqTmFY1KyPiiEAiQkHeygREn54cis6x5al7oSuP
s+xeBQ0esiDLZAZKOcyn1DVvwTHTzkGpDcOVsGLmDS42KrKHKLOizPfIgtzfjAuToh6+jFpd
vfkiRLS4y2VxjpvwwkEFHv3XMMQZ5qo3Ho8fU6Fk59VU7cAHXkABHXyuZbWAkGagGkf45SoV
beb58mQ3ySBUMCg9MIwzCT6uNopkw2QKTlSbvdHnS-ncDxMYSv9Ju7Uav-0Gc4Yvc6roAmcR
CXOdibAi2QI+izi7NE1xdy2G4HJT6DhdNqzX+9e+tbz42WihsXkwwkllynJG7WhLpQ9WcqRt
XmuonAC3JbUA6RheCMel1AGwphZW51nAky-VUndsa2guqg6Dqd+XCcUxDYfB5oURF9dRmWtp
pufGse8GEcJ0TIiwz9noRTrLpBEkEBlt2SKIigAo-FU-V7O7ST4s5w3xpN-I2tRN6qlBZj82
vLZlvXl-meDPwkniD1fOXPXqraWJlhWH5tB8eLX8SILTzVKfz+FT4q3A1QX9qO36tMPAQfeJ
1zkCgfifbd3C9qqztes7nmsDhzRb1jDRMiwQPrh-MXILpp7T26OhCZ6S1YsBjO4Psupj9GEp
MLxPzHY6la5O2-0PDwTPtwQyQ-WYgojPyxrZsRYpsTNfaRrwQ2XXwwPA47yOQ50GzpAY1W39
tBLL4uW5oMjzHmZOubiM30qO30hXIUHbvTlTGS33siyYG3ASWO0JBKjDwMOYeqjZvCMewbPq
VGdiykKKtHkwyb4RT6VYbZjaHi4s2eZPOWv0W3IuUqgmtP90oe6GNGkQ9VRDZn4DZwIzrm8l
oT4jW5VNyPQvOrTT+iITvsWx7Ojq8OZEIJMLCIOeSAn8D2OFagVlXei-lXjG4Ilg7K8DCBMz
KNYA5uhDxzD8R3WHwOLMaW45l-Pn4nelRQGDMsgLlzYmWftcn82HKn-138qmS6TrJekFKuAf
wzj4A4-RtWcisu81WwUioqMismGCaZq7fr6SkoXzL+sOexbc0VgtC1bPt0TPleKQnoZaHXKL
***** END OF BLOCK 3 *****



*XX3402-017095-301297--72--85-25580----OBJFILES.ZIP--4-OF--4
rJBx6nilUqmv9iJo6QP-NLxKTJ5nqnVHGN4m5Wf8HQeRqtV-35xMGBCXxC7o9EoMSgIHlwPI
UsMWgzXcepnFeY9Z+JVRMKPefcaQQMHmq9AjHHYMNWML5z1ZXFXAMi7a9WEyAG6vvNlfdjzH
1CxKYVwtuEXutIX-W8B5haMtCAx8ms-ojfqTJSjG8afxHRJgevBeSgBoa0kw-DOYiW-ErXER
RW+IHBvN-8FCrXWlEvUTUc67Hz7La9eeC9+jBohugvGGaeJJUZaes39oPxOCAHbwGbiLzqhg
EKm1q+9MPa1v0ZicjKjLrZpAbDBGyNWAGa90FYti9WwjBvTjqpWCX2NrtZbaB8KFVasAwb0F
I87oHO0VdB28DLe9p8ag7R3fUjXy9N6KXRa1h8WsJ3Z-Z1Echn2f1T2pMPIUsfUaxKVfGlHb
vH7ahLpWvntFuSlxiAAymSmOaGxSLF2ANTGnMHGv43ltMzQ6A84tPePgmVhjJpVRIcNG0Qlz
3oxczeiQ+QpvZFAExRootEi6tcy1h8F6fEajIWs15fCG+FJjtMLLZ83wpzbO0GPTNOYv7Zzj
V0NTmHup64kN2-KldpANnEifMAwESoLamAvOASfUFjlaQOPNdThMFRZF3JkSzC8ELWkRnyWO
QqjFHRhf1lQnbzcl4ViGK9mRmgRelcLzOcqgFO3QLAVIcC9JGBjUOdgAeIM1Z2GHgpUyNZ2T
3TztxeF-KtZAC4cckFnisQH9YRDOl9GsELkJn-sD7WYNsw2s7Kowa8mY6eU7RW7Y3bJaJs7B
reyTQpfPtE-zY5FQhJkQB6hDNBnd4DHrlzJ2qZsPWfskYYRPwQbtUu9gv0QTIbm1bAM9a3kE
CPYpMPxyNSmpcanJWQrb78NMGCdgyXKJZRzdL0YjINRd7qpwavcHzo1XCfPkmWPeBVRHbz+m
-SbfiVhC25r8syDWID3VJLrqKLQS8CzFVjAYgpI14aqoJGX5CrD1tuHltlFlBLW1LIx-eKF+
9RUI1nJbu-ldZVj-KKJiYsoqZB94Qhfk5ALpIU2wyKHxiCd6I07X2iuvyqLezpGKOV2hpP-5
CHt8r8NpJ4nHoY1wWI6I5ZJFzYXFQFEFJbz6qMIDeGAly-Bb1ivgG38GcJeb96HU9iKbIAIf
TkB85UHR1HOu73hMFloDBNHHdlM8dPHqjcOTomI9VSScX7BDgIZvjwIfBvl83y8sqeXWAlAH
XD6NRt+4rWSmwWxQkneO9KmWReCOi6umv8Bwl3Zi-5t9tCntTa7DJuE6WgRobWMqIwAtoKxq
HRCaRAfaG9+z9x9g51Qs2WkbwyySnE1zkvBlnmyZUIQsNHObZ56lNhNvaLpCLbjYFzXwwOzs
M4tiJi6Uy7Q0xznbOC+4AHiT+5jgUi961FQfAq1SmMNLu0cqsNWQDJGhfzQNwdQ4-mjkDK45
gCKY9H10TLRdAIFrseUlNDCcUNzklIeTmWPp6Mp1FzPwJqVp4ls+MyC7Mvu7yJL57+dSpi6+
iN-EUoEla-1+nC8VcMMrBR1+E1bwTCYD3YeXIa-sfrF4WW0CjNOW-+m-MoC61FWuT0qyitEr
cg7m6Njn8UrCnYOxekGoGi+J9aOkOTQMP-orQe6CSzFmnQdsQvwe-2yBb00C2lPj+Y4YxjU3
kYswv+L0KrW-RNvVa5SfETD60ORX1l7VZcWSGxHgtcmNvyDPIfDyblldnXCYzYtWpEDcApes
OD4VlEIy0W-EcP7+IkBfJQpw0siXhZkaaNuXxI41VbkkSvUuZNYn8bHkSui4UhoSPYL6le9N
DPyOsWuB1ifCyFJp7KuZy6a+8+RhL2QZF6a6iegqig1iZuVJhTD-Lywg8aPVX6syfoB8D20K
pXRnvM5qkCXBxfvqjePT+rx-Gd7KQR3D2o5w+fwEPvYH7SdCSFAzxv6HruMCErP85n-7ShEx
Pp5dYwbBQPoigoWPTYgD4D01gAjjxrRUyk7PixzjoiR4qVnLPKhEv9g0xMBQj8cINRcXIiLA
Bq6joffpvbnCbIzRyI8HF+xEjp8hwybJBvIoM+nmDXokFcD6dfm0LN5vGE84q8LV68xwCGmS
ZZi3wuG5ADmIujgMg3M1Yec3-fF0Utzc1B1sxlFnppkxB9uWtHKVWnFiWcsuGCCf3CzbAKxA
0hoBUvVvkY1oFJw4i47pu8sy1s-BP2P-nVK9jP59ghUGggY5i0-rk-+vtSwDQVbXf0pkHeWC
-oi80h5iv11u7piwQTfQjhgNLURbuJWBrp4lPmJx+d1drrwu9K5zJbXUA+l-7+rVER76Hd9v
cN9v7PSBakdH6IBUnuZk09dV7HQ+QzbPr55iAH6JrcAQIY1akajk1z+Ej6lIzrpR0FKk0Shw
K+EfM1DwXwI6VCCdHh+Pdomx9rZOmjolF97ykQ73qRMbQVMX+jwMoiDOK4w2z8QcBFIFq2Ae
9+PwZBO8EQDwgD0EADzlfDEhuFPwBkXzdfY9njjN1w153qGZgrxkdX7kxRrNx4RL3em2pKE1
QN7rQ7DLiJOhnLdsxTFrdVUACrQmr3f04gDZaSvWSUVf14TwuMyj6reWTtBzZzy+zlBDGDdr
+egekRPKhWIwBjOx4ckmCde3gt1+B6hDIZxTb7OYtsbHqngo3cucnWLdFUDZW8PrDFmXXJos
XCZ9b9rBxTf2-lRg5hdWBGJhZuxwo95yU4rifaRIZwj3Khqm4OadAtPJhQq9JWSOZHILN4VB
XNKvz4DaHsm-0nPsT-4T1w6y5zj-BdzDuzJhUv2qbwzLBUMFfnTgxINWjFTbjKRxjZfkOKEy
q793mVMk0M9UEndTqzaVwqoyw4cZ+ftEd6ihwpoPuIN0lhz5pf5BB5vrvTsb30YtWVOWMW1P
hgegp9Mh2BPMNs2jFeNp4lOkjWgGEfM6c+PsJxp9pZFogoVwOZMZPajJm8nUFHPl+UzKS3Og
afvry7iOZNIO4qsHOZ2hpB9birO7kKW5KV+EunhPcw2FV2pNqnFt+4cF9KnHpiDyeP++hvT4
yhEVfpSnElF0D2+PgkDqoTKU4K7P39tqmQjsAMM+4nRLJZOmSGxO+v8ozFt2a75JFbjIbzJR
YEqgrl-JGGB5Va2oE-Xy1yISBznDtGwWVzxLz+REGk203++I++6+0+1sCtsXw5IVNtk1++-l
CE++0++++++++++++0++++++++++IJJ7J0tDEYdEGk203++I++6+0+1sCtsXA4lReBc+++08
+k++-k+++++++++++0++++10+k++KIJH9Yx0GZ-9+E6I+-E++U+6+DUvbWDV56w6kE+++Bo1
+++4++++++++++++6++++A22++-CHmtDEYdEGk203++I++6+0+1sCtsXHKKy8Kk++++K+E++
-E+++++++++-+0++++0a-E++A0tDEYdEGk203++I++6+0+1tCtsXpTf2Oak++++K+E++-E++
+++++++-+0+++++p-U++AGtDEYdEGk203++I++6+0+1tCtsXh4lBrro++++K+E++-E++++++
+++-+0++++12-U++AWtDEYdEGk203++I++6+0+1tCtsX6te20b+++++K+E++-E+++++++++-
+0++++-Y-k++AmtDEYdEGk203++I++6+0+1tCtsXzvPDLrg++++K+E++-E+++++++++-+0++
++1r-k++B0tDEYdEGk203++I++6+0+1tCtsXWw0w4Ls++++K+E++-E+++++++++-+0++++0J
0+++BGtDEYdEGk203++I++6+0+1tCtsX1XFwAbU++++K+E++-E+++++++++-+0+++++q0E++
BWtDEYdEGk203++I++6+0+1tCtsX63WVWL2++++K+E++-E+++++++++-+0++++1F0E++BmtD
EYdEGk203++I++6+0+1tCtsXfCK1dqA++++K+E++-E+++++++++-+0++++-Z0U++C0tDEYdE
Gk203++I++6+0+1tCtsXm2XWvL2++++K+E++-E+++++++++-+0++++1f0U++CGtDEYdEGk20
3++I++6+0+1tCtsXlccmtfc++++U-+++0U+++++++++++0++++-z0k++IoBGHolA9Yx0GZ-9
+E6I+-E++U+6+DYvbWBklQ4sSk+++9U++++A++++++++++2+6++++42A++-HEp7DH2lJI0tD
EYdEGk203++I++6+0+1tCtsX8QsxmLg+++10++++1++++++++++-+0+++++41E++IoBGHolA
F2siHo78I2g-+VE+3++0++U+yHiS6xKumWos+U++NFY+++Q++++++++++++U++++eko++3-1
EWtDEYdEGk203++I++6+0+1tCtsXyi4Bb7YG++0VKU++0++++++++++++0+++++62+++G2JA
I0tDEYdEGk203++I++6+0+1tCtsX7KU-Y5E4+++i5E++0E+++++++++++0++++156U++EI7D
JJEiHo78I2g-+VE+3++0++U+yHiS6wWbLbfW-+++Ekg+++Y++++++++++++U++++MWY++3F7
J2l39Yx0GZ-9+E6I+-E++U+6+7QwbWCTCmw4l+w++DIJ+++8++++++++++++6++++4gi++-3
Fo3KFo2iHo78I2g3-U+++++J+-I+KUE++3Qy++++++++
***** END OF BLOCK 4 *****

