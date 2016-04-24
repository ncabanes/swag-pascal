(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0136.PAS
  Description: Stars AGAIN!!!!
  Author: MIKE CHURCH
  Date: 08-25-94  09:11
*)

{
Ok...  Here goes.  You will have to figure out how to TSR this if you
want...  But you can navigate in this one too!  TP v6.0
}

program stars;
{$R-}
{$S-}    {dangerous, but it's pretty well debugged}
{$G+}
uses crt;
const MaxStars=1000;         { OK for 486-33. Decrease for slower computers}
      xltsin:integer=0;
      xltcos:integer=round((1-(640/32767)*(640/32767))*32767);
      yltsin:integer=0;
      yltcos:integer=round((1-(640/32767)*(640/32767))*32767);
      zltsin:integer=0;
      zltcos:integer=round((1-(640/32767)*(640/32767))*32767);
                {rotation parameters, 16-bit.}
      speed:word=264;    {speed of movement thru starfield}
const XWIDTH = 320;  { basic screen size stuff used for star animation.}
const YWIDTH = 200;
const XCENTER = ( XWIDTH div 2 );
const YCENTER = ( YWIDTH div 2 );
type STARtype=record
                x,y,z:integer; {The x, y and z coordinates}
                xz,yz:integer; { screen coords}
              end;
var star:array[1..maxstars] of startype;
    i:integer;
    ch:char;
    rotx,roty,rotz:boolean;
    rotxv,rotyv,rotzv:integer;
procedure setmode13;    {sets 320*200 256-colour mode}
assembler;
asm
  mov ax,13h
  int 10h
end;
procedure settextmode;   {returns to text mode}
assembler;
asm
  mov ax,03h
  int 10h
end;
procedure setpix(x,y:integer;c:byte);  {NO BOUNDARY CHECKING!}
begin   {Sets a pixel in mode 13h}
asm
  mov ax,0a000h
  mov es,ax
  mov ax,y
  mov bx,320
  mul bx
  mov di,x
  add di,ax
  mov al,c
  mov es:[di],al
end;
end;
procedure initstar(i:integer);  {initialise stars at random positions}
begin
  with star[i] do
  begin
    x := longint(-32767)+random(65535);
    y := longint(-32767)+random(65535);             {at rear}
    z := random(16000)+256;
    xz:=xcenter;
    yz:=ycenter;
  end;
end;
procedure newstar(i:integer);   {create new star at either front or}
begin                            {rear of starfield}
  with star[i] do
  begin
    x := longint(-32767)+random(65535);
    y := longint(-32767)+random(65535);
    if z<256 then z := random(1256)+14500     {kludgy, huh?}
      else z:=random(256)+256;
    xz:=xcenter;
    yz:=ycenter;
  end;
end;

{$L update.obj}
procedure update(var star:startype;i:integer);external;




begin
   {gets ~100 frames/sec on a 486-33 with 500 stars,
       rotating on 1 axis, speed 256}
  clrscr;
  checkbreak:=false;                      { for speed?}
  randomize;
  for i:=1 to maxstars do initstar(i);    {initialise stars}
  setmode13;
  rotx:=true;roty:=true;rotz:=true;
  ch:=' ';
  repeat
    for i:=1 to maxstars do update(star[i],i);  {update star positions}
    if keypressed then
    begin
      ch:=readkey;                       { change parameters according to }
      if ch='+' then speed:=speed+32;    {  key pressed}
      if ch='-' then speed:=speed-32;
      if ch=#13 then
         begin
              xltsin:=0;
              yltsin:=0;
              zltsin:=0;
              speed:=256;
         end;
      if ch=#80 then dec(xltsin,96);
      if ch=#72 then inc(xltsin,96);
      if ch=#77 then dec(yltsin,96);
      if ch=#75 then inc(yltsin,96);
      if ch=#81 then
         begin
              dec(yltsin,96);
              if xltsin<0 then inc(zltsin,96);
              if xltsin>0 then dec(zltsin,96);
         end;
      if ch=#79 then
         begin
              inc(yltsin,96);
              if xltsin<0 then dec(zltsin,96);
              if xltsin>0 then inc(zltsin,96);
         end;
      if ch=#71 then dec(zltsin,96);
      if ch=#73 then inc(zltsin,96);
      end;
    xltcos:=round((1-sqr(xltsin/32767))*32767);
    yltcos:=round((1-sqr(yltsin/32767))*32767);    { evaluate cos values}
    zltcos:=round((1-sqr(zltsin/32767))*32767);
  until ch=#27;       {hit ESC to exit}
  settextmode;
  writeln;
end.

