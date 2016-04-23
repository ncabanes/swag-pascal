 (*-------------------------------------------------------------------------
 little orbit simulator I just wrote (I guess thats what you could call it)
 I was going to add more use with the mouse.. and maybe make it into a
 starcontrol 2 type game, but ..I should really do that in c :) I hate using
 C tho! :) Borland, please come out with BP 8 !

 code is.. freeware

 mail me if you have any comments/questions/suggestions
 I dont know if the math is 100% correct, but I'd like it to be as correct
 as possible.. if you add anything to this, mail it to me

 ryan@emiko.igcom.net
 (or if that fails, ryan@ripco.com)
 --------------------------------------------------------------------------*)

 {$G+,N+,E+}
 Uses mymouse, {stuff,} Crt;  { mymouse is in MOUSE.SWG !! }

 Type
   Thing=record
     mass: real;
     x,y, Oldx,Oldy: real; {position}
     vx, vy : real; {x and y velocity}
   end;

 Var
   ch:char;
   st,s:string;
   ok:boolean;
   loops:longint;
   i:integer;
   ob,test:thing;
   oba:array[1..20] of thing;
   {--config stuff--}
   B,trail:byte;
   thedelay:word;
   do1,mouseshown:boolean;
   scale,maxspeed:integer;
   lastmouseuse:word;
   TotalThings,constant,gr:integer;

   {can you tell I wrote this in 2 hours?}

   procedure config;
   var t:text;
       i:integer;
   begin
     gr:= -1;            {if -1, gravity, if 1, repluse }
     constant:=1;        {constant of the universe "or something", 1}
     do1:=false;         {false=obj 1 is center of universe}
     trail:=0;           {0=none 1=grey 2=color}
     scale:=10;          {drawing scale (pixles=mass/scale) not at all accurate, just for show}
     maxspeed:=5;        {speed of light? :) fastest anything can go. 5. }

     {you might not have a pentium 90.. :) if so lower this}
     {*******}
     thedelay:=80;       {milisecond delay in main loop.. 80 on my pentium90}
     {********}

     mouseshown:=true;   {is mouse cursor shown on screen right now}
     lastmouseuse:=0000; {not used now}

 {assign(t,'data.dat');
 reset(t);}
 i:=0;
 {totalthings:=0;
 repeat
   inc(i);
   inc(totalthings);
   with oba[i] do begin
     readln(t,mass);
     readln(t,x);
     readln(t,y);
     readln(t,vx);
     readln(t,vy);
     oldx:=0;
     oldy:=0;
   end;
 until eof(t);
 close(t);
 }
     totalthings:=3;
     with oba[1] do begin
       oldx:=10; oldy:=10;
       mass:=70;
       x:=150;
       y:=100;
       vx:=1;
       vy:=1;
     end;
     with oba[2] do begin
       mass:=4;
       x:=21;
       y:=84;
       vx:=2;
       vy:=0;
     end;
     with oba[3] do begin
       mass:=18;
       x:=122;
       y:=122;
       vx:=0;
       vy:=1;
     end;
   end;

 { ---------------------------------------------------------------------- }
   procedure SETMODE(mode : byte); assembler;
   asm
     MOV AH,0
     MOV AL,MODE
     INT $10
   end;
   (*
   begin
       regs.ah := 0;
       regs.al := mode;
       intr($10, regs)
   end;
   *)

   function i2s(i: Longint): string; {integer to string}
   var
     s: string[11];
   begin
     Str(i, s);
     I2s := s;
   end;

   Procedure plot286(x,y:integer; c:byte);
   {very fast putpixel that uses 286 instructions}
   Inline(
      $58/$B9/$00/$A0/$8E/$C1/
      $5B/$88/$DD/$5F/$01/$CF/
      $C1/$E9/$02/$01/$CF/$AA);

 { ---------------------------------------------------------------------- }

   function update(var it:thing):string;
   var
    t,ax,ay,x2,y2,k:real;
    a,dist,tempreal:real;
    sx,sy,tempi:integer;
    ret:string;
   begin
     with it do begin
       Oldx:=x;
       Oldy:=y;
       ax:=0;
       ay:=0;

       x:=x+vx;
       y:=y+vy;
       for tempi:= 1 to totalthings do begin
         x2:=oba[tempi].x;
         y2:=oba[tempi].y;
         if (x<>x2) and (y<>y2) then begin
           tempreal:=((sqr(x-x2)+sqr(y-y2)));
           if tempreal<1 then tempreal:=1;{they touched..}
           {do this later:                 so add everything and kill one }
           k:=(oba[tempi].mass){ * mass)} * constant ;
           dist:=gr* (k / tempreal);
           a:=arctan((y-y2) / (x-x2));
           if x<x2 then a:=PI-a;
         end;
         ax:=( dist*cos(a) )+ax;
         if x>=x2 then ay:=( dist*sin(a) )+ay else ay:=( dist * -sin(a) )+ay;
       end;
       vx:=vx+ax;
       vy:=vy+ay;
       {---}
       if vy>maxspeed then vy:=maxspeed;
       if vx>maxspeed then vx:=maxspeed;
       if vy<-maxspeed then vy:=-maxspeed;
       if vx<-maxspeed then vx:=-maxspeed;
       {gotoxy(1,24); write(a);}
       ret:=' ax: '+i2s(trunc(ax))+' ay: '+i2s(trunc(ay))+' ';
       {--screen edge stuff, more realistic without these 4 lines:----}
       if x<1 then x:=299;
       if x>299 then x:=1;
       if y<1 then y:=199;
       if y>199 then y:=1;
       update:=ret;
     end;
   end;

   procedure draw(it:thing; color:integer);
   var c,i,i2:integer;
   begin
     {this won't let it draw off screen}
     for i:=0 to trunc(it.mass / scale) do with it do begin
       for i2:=0 to trunc(mass / scale) do if ((oldy+i<200) and (oldx+i2<300)) then begin
         if trail=0 then c:=0 else
         if trail=1 then c:=8 else
         c:=color;
         plot286(trunc(Oldx+i2),trunc(Oldy+i),c);
       end;
     end;

     for i:=0 to trunc(it.mass / scale) do with it do
       for i2:=0 to trunc(mass / scale) do if ((y+i<200) and (x+i2<300)) then plot286(trunc(x+i2),trunc(y+i),color);
   end;
 { ---------------------------------------------------------------------- }

 begin
   config;

   loops:=0;
   initmouse(b,ok);
   if ok=false then begin
      writeln('no mouse found!');
      halt;
   end else writeln('mouse found, ',b,' buttons.');
   setmode($13);
   directvideo:=false;
   showmouse;
   repeat

     if mouseleftpressed then begin
       mouseshown:=not mouseshown;
       if mouseshown then showmouse else begin
         {gotoxy(1,1); for i:=1 to 38 do write(' ');}
         fillchar(ptr($A000,0)^,64000,0);
         hidemouse;
       end;
     end else
     if mouserightDOWN{pressed} then begin
       if totalthings<20 then begin
         inc(totalthings);
         oba[totalthings].mass:=RANDOM(5)+1;
         oba[totalthings].x:=mousex div 2;
         oba[totalthings].y:=mousey;
         oba[totalthings].vx:=1;
         oba[totalthings].vy:=1;
       end;
       {BEEP;}
     end;
     if mouseshown then begin
       getmousexy;
       gotoxy(1,1); write('mouseX:',mousex,' mouseY:',mousey,'    ');
     end;

     inc(loops);
     s:='Loop:'+i2s(loops);
     for i:=1 to TotalThings do
       if (i<>1) or ((i=1) and (do1=true)) then st:=update(oba[i]);
     s:=s+st;
     for i:=1 to TotalThings do draw(oba[i],i);
     {gotoxy(1,25); write(s);}
     delay(thedelay);
   until keypressed;
   ch:=readkey;
   textmode(co80);
 end.

