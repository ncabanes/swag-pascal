{
> I don't think I need two seperate read and write-windows. With one
> write-window I could still write to off-screen memory while the
> display start is determing what is visible on the screen?
> With one window, you can only access off-screen memory which is within
> the bounds of the window granularity.  A typical example is a 64k
> granularity and the bank set to have a window at the top of screen,
> then you can't put data off-screen or at the bottom of a high
> resolution screen without switching banks.  I don't understand how you
> could write to off-screen memory outside the window (if that is what
> you intend).

I know I can't do that, never mind about the rest. At the moment I'm
working on some scrolling in xmode 320x200 resolution. Things are going
pretty good so far, and I'm planning to port it to the vesa 640x480
resolution later. For my algorithm I would have to set the virtual
screen size to approx. 1300 pixels wide. That could result in as much as
480 / (64k / 1300) = 10 bank-switches per frame. (That's 700
bank-switches per second in a worst case situation)

I did some simple testing:
}

program TestBank;

uses
  Dos, crt;

const
  gran = 64;

var
  clock : longint absolute $0:$046c;
  counter, ticks : longint;
  rp : registers;

procedure vio(ax:word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}
begin
  rp.ax:=ax;
  intr($10,rp);
end;

procedure viop(ax,bx,cx,dx:word;p:pointer);
begin                            {INT 10h reg AX-DX, ES:DI = p}
  rp.ax:=ax;
  rp.bx:=bx;
  rp.cx:=cx;
  rp.dx:=dx;
  rp.di:=ofs(p^);
  rp.es:=seg(p^);
  intr($10,rp);
end;

procedure SetBank( bank : word);
begin
  rp.bx:=0;
  bank:=bank*longint(64) div gran;
  rp.dx:=bank;
  vio($4f05);
  rp.bx:=1;
  rp.dx:=bank;
  vio($4f05);
end;

begin
  viop($4f02, $101, 0, 0, nil); { 640x480x256 }

  for counter := 0 to 15 do
  begin
    setbank( counter);
    fillchar( mem[$a000:0], 65535, counter+1);
  end;

  counter := 0;
  ticks := clock;
  repeat
    setbank( counter mod 16);
    inc( counter);
  until clock = ticks+90;

  viop($4f02, 3, 0, 0, nil);

  writeln(counter div 5, ' bank-switches/sec.');
  writeln('= ', 5000/counter : 6 : 4, ' msec / switch');
end.

{
and I get 0.0642 msec/switch with TLIVESA
and 0.0622 msec/switch with Univesa 3.2 (both vesa 1.2)

I think that's fast enough not to make me worry too much. That is,
unless you know of some cards that do bank-switching extremely slow.

> VGA/VESA modes.  Scrolls and VESA text modes were added.  The approach
> I've used is to tailor multiple versions for each drawing routine.  The
> VGI library assigns the correct procedures whenever the video mode has
> changed.  That way, there is a polymorphic mechanism of switching
> drivers but without any execution speed penalties.  This allows me to
> be able to plug-n-play drivers during testing.

All sounds good to me. I would like to see a demo and/or the interface
section of some units!
}
