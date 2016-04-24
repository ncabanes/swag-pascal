(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0168.PAS
  Description: ANIVGA Wormhole
  Author: JOHN HOWARD
  Date: 11-26-94  04:59
*)


{$A+,B-,D+,L+,N-,E-,O-,Q-,R-,S-,V-,G-,F-,I-,X-}   {Borland Pascal 7.0}
{$M 16384,0,655360}
{ File: HI_Worm.pas
  Version: 1.0
  Date: 27-AUGUST-94
  Author: John Howard  jh
  ANIVGA v1.2 implementation of Wormhole from Bas van Gaalen.  Demonstrates
  Pascal routines needed for 320x200x256x4.  I have modified ANIVGA v1.2 to
  provide 320x240x256x4 (not shown here).  The TeleGame (tm) software
  development kit (SDK) utilizes both modes.  TeleGame SDK combines enhanced
  ANIVGA with a multi-user communication protocol and some utilities.  The SDK
  provides a Turbo Pascal development system for VGA game developers.  Release
  date is October 1.

  TeleGame (tm) products are available exclusively via:
                            Howard International
                            P.O. BOX 34633
                            North Kansas City, Missouri 64116  USA
}
program Hi_Worm;
USES
    ANIVGA,                       {v1.2}
    CRT;

const
    divd=128;
    astep=5;
    xst=3;
    yst=5;

var
  sintab : array[0..449] of integer;
  stab,ctab : array[0..255] of integer;
  lstep : byte;


procedure drawpolar(xo,yo,r,a : word; c : byte);
var x,y : word;
begin
  x:=160+xo+(r*sintab[90+a]) div (divd-20);
  y:=100+yo+(r*sintab[a]) div divd;
  PutPixel(x,y,c);
  { if (x<320) and (y<200) then mem[lvseg:320*y+x] := c; }
end;


VAR
    x,y,i,j : word;
    c : byte;
    ch : char;

BEGIN  {PROGRAM}
  InitGraph;
  Animate; {just to initialize pages, eventually placed sprites}

  for i:=0 to 255 do begin
    ctab[i]:=round(cos(pi*i/128)*60);
    stab[i]:=round(sin(pi*i/128)*45);
  end;
  for i:=0 to 449 do sintab[i]:=round(sin(2*pi*i/360)*divd);

  {clearscreen(page);}
  x:=30; y:=90;
  repeat
    c:=19; lstep:=2; j:=10;
    while j<220 do begin
      i:=0;
      while i<360 do begin
        drawpolar(ctab[(x+(200-j)) mod 255],stab[(y+(200-j)) mod 255],j,i,c);
        inc(i,astep);
      end;
      inc(j,lstep);
      if (j mod 3)=0 then
      begin
        inc(lstep);
        inc(c);
        if c>31 then c:=31;
      end;
    end;
    x:=xst+x mod 255;
    y:=yst+y mod 255;
    ANIMATE;
  until keypressed;
  while keypressed do ch:=readkey;
  CloseRoutines;
END.   {PROGRAM}

