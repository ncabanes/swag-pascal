(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0225.PAS
  Description: Critters Graphics Display
  Author: RON NOSSAMAN
  Date: 08-30-96  09:36
*)

Program BBBBB;         {yep, B's}
{Cheap thrills from the WookieWare Home Defense Series}
{Ron Nossaman August 1995}
{Critters follow each other about in a controlled but random appearing
 manner. Periodically, the big'un takes off in a random direction and
 the rest of the swarm straggles after her. This started out as an
 experiment in orbital mechanics but typically collapsed into something
 even less useful but a lot more fun. Sort of 'a life simulation for
 the easily impressed'. Enjoy }
uses crt,graph,
     bgiDRIV; { Wherever your have the BGI drivers compiled }

const radcon:real=0.017453292;     {radian/degree conversion value}
      totalbodies=22;              {whatever you think looks right}
      speedfactor:real=30;         {lower= more frantic, higher= more sedate}
type debris=record
               mass,dir,speed,x,y:real;  {stuff swarms are made of}
               oldx,oldy:integer;
            end;
var b:array[1..totalbodies]of debris;
    grdriver,grmode,errcode: integer;
    ch:char;
    i,countdown,walls,delayfactor:integer;
    stampede:boolean;
    bait:debris;

function theta(p1x,p1y,p2x,p2y:real):real;
{Given two sets of point coordinates, returns the angle
 between them in degrees. I've found this to be very handy}
var t,lx,ly:real;
begin
   lx:=p2x-p1x; ly:=p2y-p1y;
   if((lx=0)and(ly=0))then theta:=0 else
   begin
      if lx=0 then t:=arctan(ly/0.0000000001)/radcon else
         t:=arctan(ly/lx)/radcon;       {divide by zero duck}
      if lx<0 then t:=t+180;             {vector adjustments}
      if((lx>=0)and(ly<0))then t:=t+360; {back into range}
      theta:=abs(t);
   end;
end;


function hypotenuse(x1,y1,x2,y2:real):real;
{just what it says}
var h1,h2:real;
begin
   hypotenuse:=sqrt(sqr(abs(x1-x2))+sqr(abs(y1-y2)));
end;



procedure init; {Gentlemen, start your b's}
var i:integer;
    g:real;
begin
   for i:=1 to totalbodies do
   begin
      b[i].x:=random(600)+20;
      b[i].y:=random(440)+20;
      b[i].dir:=random(359)+1;
      b[i].speed:=(random(100)+50)/speedfactor;
      b[i].mass:=random(50)+100;
      bait.x:=random(600)+20;
      bait.y:=random(440)+20;
      bait.mass:=100;
   end;
   delayfactor:=round(500/b[1].speed);
end;


procedure orbit(a:integer);
var i,a2,min,xmax,ymax:integer;
    t,m1,m2,ax,ay,newdir,rate:real;
begin
   if a=1 then a2:=totalbodies else a2:=a-1;           {a=1 is the queen}
   if (stampede and (a=1)) then
   begin                                               {beeline toward bait}
      t:=theta(b[a].x,b[a].y,bait.x,bait.y);           {target vector}
      m2:=hypotenuse(b[a].x,b[a].y,bait.x,bait.y);   {distance}
      m1:=bait.mass;        {attraction factor}
      rate:=10;             {queen's cornering ability}
   end else                 {smooths abrupt directional changes}
   begin
      t:=theta(b[a].x,b[a].y,b[a2].x,b[a2].y);  {follow last in line instead}
      m2:=hypotenuse(b[a].x,b[a].y,b[a2].x,b[a2].y);
      m1:=b[a2].mass;
      rate:=4;
   end;
   ax:=b[a].x+(m1*cos(b[a].dir*radcon))+(m2*cos(t*radcon)); {new position}
   ay:=b[a].y+(m1*sin(b[a].dir*radcon))+(m2*sin(t*radcon));
   newdir:=theta(b[a].x,b[a].y,ax,ay);   {resulting direction deflection}
    {this is not a very efficient way of doing this, but when I got
      it to do what I wanted, I quit dinking with it}
   if a=1 then
   begin
      if abs(newdir-b[a].dir)>=180 then
      begin
         if newdir>b[a].dir then newdir:=newdir-360
           else newdir:=newdir+360;
      end;                           {smooth direction change rate}
      if newdir>b[a].dir then b[a].dir:=b[a].dir+((newdir-b[a].dir)/rate);
      if newdir<b[a].dir then b[a].dir:=b[a].dir-((b[a].dir-newdir)/rate);
      if round(newdir)=round(b[a].dir)
          then b[a].dir:=b[a].dir+random(10)-5;
   end else b[a].dir:=newdir;
   if b[a].dir>359 then b[a].dir:=b[a].dir-360;   {fix direction overflow}
   if b[a].dir<0 then b[a].dir:=b[a].dir+360;
   b[a].x:=b[a].x+(b[a].speed*cos(b[a].dir*radcon));
   b[a].y:=b[a].y+(b[a].speed*sin(b[a].dir*radcon));
   if b[a].x<3 then b[a].x:=3;
   if b[a].x>637 then b[a].x:=637;
   if b[a].y<3 then b[a].y:=3;
   if b[a].y>477 then b[a].y:=477;
   if(b[a].x=637)or(b[a].x=3)or(b[a].y=477)or(b[a].y=3) then
   begin
      b[a].speed:=(random(100)+50)/speedfactor;
      if a=1 then delayfactor:=round(500/b[1].speed);
   end;
   if (b[a].oldx<>round(b[a].x))or(b[a].oldy<>round(b[a].y)) then
   begin
      setcolor(black);
      circle(b[a].oldx,b[a].oldy,1);             {erase old position}
      if a=1 then circle(b[a].oldx,b[a].oldy,2);
      setcolor(white);
      circle(round(b[a].x),round(b[a].y),1);     {draw new position}
      if a=1 then
      begin
         setcolor(lightgray);
         circle(round(b[a].x),round(b[a].y),2);  {queen's bigger}
      end;
   end;
   b[a].oldx:=round(b[a].x);
   b[a].oldy:=round(b[a].y);
end;

procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;

Begin
  if RegisterBGIdriver(@EGAVGADriverProc)<0 then abort('EGA/VGA');
  countdown:=100;
  stampede:=false;
  randomize;
  ch:=#0;
  grDriver := Detect;
  InitGraph(grDriver,grmode,'');
  setgraphmode(2);
  ErrCode := GraphResult;
  if ErrCode <> grOk then
    begin
      CloseGraph;
      Writeln('Graphics error:', GraphErrorMsg(ErrCode));
      exit;
    end;
   init;
   while keypressed do ch:=readkey;
   repeat
      for i:=1 to totalbodies do orbit(i);
      dec(countdown);
      if countdown<0 then
      begin
         stampede:=not stampede;
         if stampede then
         begin
          {de-bracket to c-d-bait}
{            setcolor(black);
            circle(round(bait.x),round(bait.y),2);}
            walls:=random(4);
            countdown:=random(delayfactor)+delayfactor*2;
            case walls of          {the bait always goes on a wall because}
            0:begin                {it makes the migrations more dramatic}
                 bait.x:=20;       {and I like the effect. that's why}
                 bait.y:=random(480);
              end;
            1:begin
                 bait.x:=619;
                 bait.y:=random(480);
              end;
            2:begin
                 bait.y:=20;
                 bait.x:=random(640);
              end;
            3:begin
                 bait.y:=459;
                 bait.x:=random(640);
              end;
            end;
              {de-bracket to c-d-bait}
{            setcolor(lightblue);
            circle(round(bait.x),round(bait.y),2);}
         end  else countdown:=random(delayfactor)+delayfactor*2;
      end;
      if keypressed then ch:=readkey;
   until ch=#27;
   closegraph;
end.
