{
 JM> ex. pixel in screen is x = 160, y = 100 and ground level = 190.
 JM> Then that pixel has to drop down like a gravity affect to
 JM> pixel.. then it would look that there were an gravity..

>--- cut here
}
program cannonball;
uses crt;
const vidseg:word=$a000; g=-9.81; x0=0; y0=100; v0=50; phi=50; dt=0.1;
var t:real; px,py,xt,yt,v:integer;

procedure retrace; assembler; asm
  mov dx,03dah; @vert1: in al,dx; test al,8; jnz @vert1
  @vert2: in al,dx; test al,8; jz @vert2; end;

function rad(alpha:integer):real; begin
  rad:=(alpha/180)*pi; end;

begin
  asm mov ax,13h; int 10h; end;
  px:=0; py:=0;
  t:=0; v:=v0; yt:=1;
  while (not keypressed) and (yt>=0) do begin
    retrace;
    mem[vidseg:(199-py)*320+px]:=0;
    xt:=x0+round(v0*cos(rad(phi))*t);
    yt:=y0+round(v*sin(rad(phi))*t+0.5*g*t*t);
    mem[vidseg:(199-yt)*320+xt]:=15;
    px:=xt; py:=yt;
    t:=t+dt;
  end;
  while keypressed do readkey;
  while not keypressed do;
  textmode(lastmode);
end.

>--- cut here

This is the only correct physical approuch (I should know, I study Physics).
