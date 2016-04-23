{
>> You are using THREE different screens (no problem in x-mode).
>> One (A) is displayed, second (B) is waiting, third (C) is
>> being drawn. After third C is ready B is being displayed
>> and A is being drawn. No flickering, no waiting, no
>> problem...

> That makes sense.  Is there anyway to hook an interrupt
> to the vertical retrace to keep it automatic?

Yes, and no - it depends on VGA card. In theory it should be able to generate
IRQ 2 on retrace, but in fact one nevr now what's going on in a particular
computer. Sometimes it can be changed by a jumper on a VGA card, sometimes
not...

> (By the way, it still would be limited to the Vert retrace because you
> can't change from a to b until there is a Retrace, so you would just
> allow more variety in speed of drawing screens with triple buffering
> (ie. you can draw one fast and one really slow (alternating) if the total
> of both is less than two vertical retraces)).

One program is worth a thousand words ;-)
}

program buffexm;

{ Example of a double and tripple buffering in video memory.
  (c) by Borek (Marcin Borkowski), 2:480/25. Program is
  slow because of primitive drawbox procedure, but precisely
  shows how to use dbl and trpl buffering to achieve perfect,
  non-flickering screen displays. }

uses crt;

const
  speed = 40; { Speed of a program - lover values, faster action.
                As effect depends on your computer speed, try to
                experiment with this value. }

var
  scrofs,time : word;

procedure Enter4PlaneMode; { so called x-mode }
begin
  Port[$3CE]:=5;   Port[$3CF]:=Port[$3CF] and $FB;
  Port[$3CE]:=6;   Port[$3CF]:=Port[$3CF] and $FD;
  Port[$3C4]:=4;   Port[$3C5]:=(Port[$3C5] and $F7) or 4;
  Port[$3D4]:=$14; Port[$3D5]:=Port[$3D5] and $BF;
  Port[$3D4]:=$17; Port[$3D5]:=Port[$3D5] or $40;
end;

procedure SetStartAddress(w : word);
begin
{ Sets start address of displayed video memory. }
  Port[$3D4]:=$0C; Port[$3D5]:=Hi(w);
  Port[$3D4]:=$0D; Port[$3D5]:=Lo(w);
end;

procedure WaitForRetrace;
begin
  repeat until (port[$03DA] and 8)=8;
  repeat until (port[$03DA] and 8)=0
end;

procedure clrscreen(a : word);
begin
{ Fills all bitplanes at once with zeros, but only in
  a part of video memory. }
  Port[$3C4]:=2;  Port[$3C5]:=$0F;
  fillchar(mem[$A000:a],16384,#0);
end;

procedure drawbox(x,y : word;c : byte);
var
  i,j,a : word;
begin
{ Port writes are used to define which bitplane is used. }
  Port[$3C4]:=2;
  for i:=x to x+10 do
  begin
    Port[$3C5]:=1 shl (i and 3);
    a:=scrofs+i div 4+80*y;
    for j:=y to y+10 do
    begin
      mem[$A000:a]:=c;
      inc(a,80)
    end;
  end;
end;

procedure animate1;
{ No buffering example. }
var
  x,y : integer;
begin
  repeat
    clrscreen(0);
    drawbox(round(150+60*cos(time/speed)),
            round(90+60*sin(time/speed)),7);
{   WaitForRetrace;  Try with and without. Effect depends }
    inc(time)       { on your computer speed. }
  until keypressed;
end;

procedure animate2;
{ Double buffering example. There are two virtual screens -
  one at $A000:0, second at $A000:$4000 }
var
  x,y  : integer;
begin
  repeat
    clrscreen(scrofs);
    drawbox(round(150+60*cos(time/speed)),
            round(90+60*sin(time/speed)),15);
    inc(time);
    setstartaddress(scrofs);
    WaitForRetrace; { Screen is flickering without this. }
    scrofs:=$4000-scrofs;
  until keypressed;
end;

procedure animate3;
{ Triple buffering example. In fact there are four virtual screens,
  at $A000:0, $A000:$4000, $A000:$8000 and at $A000:$C000, but if you
  use three screens the effect will remain the same.
  No waiting for retrace, no flickering. Speed of rectangle moves
  depends _only_ on a computer speed. You may add WaitForRetrace to
  allow synchronization. }
var
  x,y  : integer;
begin
  repeat
    clrscreen(scrofs);
    drawbox(round(150+60*cos(time/speed)),
            round(90+60*sin(time/speed)),13);
    inc(time);
    setstartaddress(scrofs);
    inc(scrofs,$4000);
  until keypressed;
end;

begin
  asm mov ax,13h; int 10h end;
  enter4planemode;
  time:=0;
  animate1; readkey; { Fast, but always flickers }
  animate2; readkey; { No flickering but slow - must wait for retrace }
  animate3; readkey; { Same speed as in animate1, no flickering }
  asm mov ax,03h; int 10h end;
end.

