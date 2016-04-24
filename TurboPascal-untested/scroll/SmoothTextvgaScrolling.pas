(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0018.PAS
  Description: Smooth Text/VGA Scrolling
  Author: WIM VAN DER VEGT
  Date: 11-26-94  05:05
*)

{
>I want to write a routine to scroll text smoothly i.e. pixel wise. This
>might be ambitious as I know almost nothing about pogramming the display
>card, but I have two theories. The one will work, but is very long
>winded. Please advise me on a course of action.

>BTW, can anyone recommend any good books on topics such as the above,
>i.e. advanced graphics programming etc. When giving advice please
>remember my coding ability is way behind the ability to figure
>algorithms.


One of the best books I've read is PC and PS/2 video systems by
microsoft press (if I/'m correct). It deals with a lot of great topics
like graphs in textmode and the differences between video cards.

The best way to start it is to re-program the starting line of the
display. This way you've got hardware scrolling in textmode. Only
program is when & were to insert a new line.

I know that PC-magazine once published a smooth scrolling routine in
textmode. This one should contain all info you need.

Btw here's a small demo of how to re-program the starting line of a
E/VGA card. Once re-programmed you see the second text page of the E/VGA
card.


{---------------------------------------------------------}
{  Project : Split screen for EGA & VGA                   }
{  Auteur  : Wim van der Vegt                             }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  910505.1645  Creatie.                                  }
{---------------------------------------------------------}

Program split(INPUT,OUPUT);

{----Source of information :

     Programmer's Guide to PC & PS/2 Video Systems, by Microsoft press

}

uses
  crt,
  dos,
  graph;

VAR
  vgacard  : BOOLEAN;
  gvmax,
  tvmax    : INTEGER;
  r        : Registers;
  grmode,
  grdriver : INTEGER;

{---------------------------------------------------------}

var
  v,i,j    : integer;

const
  CRTC_adr = $3D4;
  CRTC_dat = $3D5;

{---------------------------------------------------------}
{----Wait for vertical retrace                            }
{---------------------------------------------------------}

procedure V_retrace; inline($BA/$DA/$03/ { mov dx,$03DA   }
                            $EC/         { in al,dx   <-\ }
                            $A8/$08/     { test al,8    | }
                            $75/$FB/     { jnz >--------/ }
                            $EC/         { in al,dx   <-\ }
                            $A8/$08/     { test al,8    | }
                            $74/$FB);    { jz >---------/ }

{---------------------------------------------------------}
{----Sets re-start line for CRTC controller               }
{---------------------------------------------------------}

procedure CRTC_split(i : WORD);

VAR
  b : BYTE;

begin
  V_retrace;
  IF vgacard
    THEN
      BEGIN
        port[CRTC_adr]:=$09; b:=port[CRTC_dat];
        port[CRTC_adr]:=$09; port[CRTC_dat]:=BYTE(b AND $BF)+(BYTE(i DIV 512)) ;
        port[CRTC_adr]:=$18; port[CRTC_dat]:=BYTE(i MOD 256);
        port[CRTC_adr]:=$07; b:=port[CRTC_dat];
        port[CRTC_adr]:=$07; port[CRTC_dat]:=BYTE(b AND $ef)+BYTE((i DIV 256)) ;
      END
    ELSE
      BEGIN
        port[CRTC_adr]:=$18; port[CRTC_dat]:=i MOD 256;
        port[CRTC_adr]:=$07; port[CRTC_dat]:=$ef+((BYTE(i DIV 256) MOD 2) SHL 4)
       END;
end; {of CRTC_split}

{---------------------------------------------------------}
{----Sets display start address for CRTC controller       }
{---------------------------------------------------------}

procedure CRTC_start(i : word);

begin
  port[CRTC_adr]:=$0d; port[CRTC_dat]:=i mod 256;
  port[CRTC_adr]:=$0c; port[CRTC_dat]:=i div 256;
end; {of CRTC_start}

{---------------------------------------------------------}
{----Resets the screen split                              }
{---------------------------------------------------------}

PROCEDURE Unsplit;

BEGIN
  CRTC_start(0);
  CRTC_split($1ff);
END;

{---------------------------------------------------------}
{----Graphic mode, mouse controlled screen split          }
{---------------------------------------------------------}

Procedure do_graph_split;

begin
{----get motion count from mouse}
  r.ax:=$000B;
  INTR($33,r);
  v:=v+INTEGER(r.dx);

  if v>gvmax THEN v:=gvmax;
  if v<0     THEN v:=0;
  IF v>0
    THEN
    {----By adjusting this value according to v,
         the two EGA/VGA graphic screens will be linked}
      begin
      {----Second Graph Screen 32K after start of First Screen}
        CRTC_start($8000);
        CRTC_split(v);
      end
    ELSE Unsplit;
end;

{---------------------------------------------------------}
{----Text mode, mouse controlled screen split             }
{---------------------------------------------------------}

Procedure do_text_split;

begin
{----get motion count from mouse}
  r.ax:=$000B;
  INTR($33,r);
  v:=v+INTEGER(r.dx);

  if v>tvmax THEN v:=tvmax;
  if v<0     THEN v:=0;
  IF v>0
    THEN
      begin
      {----Second text Screen 4K after start of First Screen}
        CRTC_start($1000);
        CRTC_split(v);
      end
    ELSE Unsplit;
end;

{=========================================================}

BEGIN
{----Screen must be EGA or VGA}
  grdriver:=detect;
  Detectgraph(grdriver,grmode);
  vgacard:=(grdriver=vga);

{----Graphics Mode, watch out,
     VGA hasn'got two pages in 640x480 graphics mode,
     switch to EGA 640x350 mode if you want two full pages,
     and change gvmax below from 479 to 349}

  IF vgacard
    THEN gvmax:=479
    ELSE gvmax:=349;

{----Text Mode, VGA in text mode has 400 lines (So NOT 480 lines !!) }
  IF vgacard
    THEN tvmax:=399
    ELSE tvmax:=349;

  IF (grdriver<>vga) AND (grdriver<>ega)
    THEN
      BEGIN
        Writeln('Ega or Vga Card NOT Found');
        Halt;
      END;

{----Text mode demo #1}
  FOR i:=0 TO 80*25 DO
    BEGIN
      MEMW[$B800:i*2]:=$0F30;
      MEMW[$B900:i*2]:=$3031;
    END;

{----Oscillating Screen Split}
  CRTC_start($1000);
  for i:=8 to 192 do CRTC_split( round(175-175*cos(i/30*pi)*(8/i)) );
  Delay(1000);

{----Accelerating screen split}
  for i:=3*175 downto 16 do CRTC_split( Trunc(175-(175/i)*16) );
  Delay(1000);
  Unsplit;

{----Text mode demo #2 & Graphics demo #1 need a mouse}
  r.ax:=$0000;
  INTR($33,r);
  IF (r.ax=0)
    THEN
      BEGIN
        Writeln('Microsoft mouse NOT Found');
        Halt;
      END;

{----Text mode demo #2}
  GotoXY(10,09);
  Write('                                                           ');
  GotoXY(10,10);
  Write('  Now Move your mouse up and down and see text page 0 & 1  ');
  GotoXY(10,11);
  Write('            Press SPACE key to exit this demo              ');
  GotoXY(10,12);
  Write('                                                           ');

  v:=50;
  WHILE NOT(keypressed AND (Readkey=#32)) DO Do_text_split;
  Unsplit;

{----Graphic Mode Demo #1, works best on EGA and VGA in EGA mode}
  grdriver:=ega;
  grmode:=egahi;
  Initgraph(grdriver,grmode,'e:\bp\bgi');
  Setcolor(blue);
  FOR i:=0 TO gvmax DO
    FOR j:=0 TO 39 DO
      memw[$a000:WORD(i*80)+2*j]:=$1000;
  Setcolor(red);
  FOR i:=0 TO gvmax DO
    FOR j:=0 TO 39 DO
      memw[$a800:WORD(i*80)+2*j]:=$0010;
  Setcolor(white);
  Outtextxy(10,10,'  This is Graphic page 0, Move your mouse & press space to e');
  Rectangle(0,0,639,gvmax);
  Setactivepage(1);
  Outtextxy(10,10,'  This is Graphic page 1  ');
  Rectangle(0,0,639,gvmax);

  v:=50;

  WHILE NOT(keypressed AND (Readkey=#32)) DO Do_graph_split;
  Unsplit;

  Closegraph;
END.

