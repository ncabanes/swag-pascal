
{This is my procedure for drawing DOOM-like floors for the game I am working
on. It uses the similar triangle method, but does not work as fast as I
would like. The problem is probably that I am using Turbo Pascal.  I tried to 
optimize using assembler, but have never used it before.   If anyone could 
help me speed it up, I would really appreciate it. I think this procedure runs 
at about 11-12 fps without my wall,objects procedures, at about 8 fps with 
them.  The wall,objects procedures run at about 20 fps without the floor 
procedure.  My goal is for a nice 15 fps with everything.  All speeds are on a 
486 DX2/66.



Sorry for the sloppy code. I'll try to explain.}



procedure floorcast(var player1:player);
var
   xp,yp:integer;       {some of these variables might not be needed}
   z:word;
   i:byte;
   dd:longint;
   xstep,ystep:longint;
   scrd:integer;
   finx1,finy1:longint;
   finx2,finy2:integer;
   finxd,finyd:longint;
   distance:longint;
   cc,colour:byte;
   ssofs:word;
   s3,o3,o4,s4:word;
   mapx,mapy,bmapx,bmapy:byte;
   ang:integer;
   v1,v2:longint;
   lookm:integer;
   flm:byte;
   loop:integer;
   ssinc:byte;
   zinc:word;
   hh:word;
   shade:byte;
   cos2,sin2,cos1,sin1:longint;
   sf:byte;
begin
v1:=viewcos^[0];                {to fix the fishbowl effect}
v2:=viewcos^[319];
lookm:=(player1.look-100); {to find out if the player is looking up or down}
loop:=(player1.look+1);    {number of h-lines to draw}
hh:=(vdis)*player1.height;  {viewer distance * player height}
ang:=dangle(0,-dangle(player1.angle,(-160)));  {angle for left most pixel}
cos1:=cost^[ang]; {trig values for angle}
sin1:=sint^[ang];
ang:=dangle(0,-dangle(player1.angle,(160)));  {angle for right most pixel}
cos2:=cost^[ang]; {trig values for angle}
sin2:=sint^[ang];
ssofs:=320*loop+o1+xmin;  {screen offset at start of loop}
ssinc:=xmin+320-xmax;     {screen offset increment to start each h-line}
zinc:=xmax-xmin;          {size of h-viewport}
emsmap(handle,0,0);       {ems routines for graphics}
emsmap(handle,1,1);
emsmap(handle,2,2);
emsmap(handle,3,3);
for i:=loop to toomax do  {loop from horizon to bottom of screen}
begin
     dd:=(hh div (i-player1.look)); {temp distance variable used twice}
     distance:=(dd*v1) shr 16;      {fishbowl adjust}
     distance:=(distance*5) shr 2;  {This fixes a strange floor shift for me}
     distance:=distance-lookm;      {adjust for looking up or down}
     finx1:=((distance*cos1)) shr 16; {rotate to player angle}
     finy1:=(-(distance*sin1)) shr 16;

     distance:=(dd*v2) shr 16;         {same as above for right most pixel}
     distance:=(distance*5) shr 2;
     distance:=distance-lookm;
     finx2:=((distance*cos2)) shr 16;
     finy2:=(-(distance*sin2)) shr 16;

     finxd:=(finx2-finx1);  {x-distance}
     finyd:=(finy2-finy1);  {y-distance}
     finx1:=finx1+player1.x; {translate to player position}
     finy1:=finy1+player1.y;
     xstep:=(finxd shl 16) div 320;  {x-step along map for each pixel}
     ystep:=(finyd shl 16) div 320;  {x-step along map for each pixel}
     finx1:=finx1 shl 16;
     finy1:=finy1 shl 16;
     z:=ssofs+zinc;  {value for end of loop}
     finx1:=(finx1+xstep*xmin); { adjust for variable screen size}
     finy1:=(finy1+ystep*xmin);
     repeat
          if mem[s1:o1+ssofs]=0 then {if a wall or object has not been drawn}
          begin
          xp:=finx1 shr 16;  {fixed point shift}
          yp:=finy1 shr 16;
          asm
             mov ax,xp       {map position}
             shr ax,6
             mov mapx,al
             mov ax,yp
             shr ax,6
             mov mapy,al
             mov ax,xp       {bitmap position}
             and ax,3Fh
             mov bmapx,al
             mov ax,yp
             and ax,3Fh
             mov bmapy,al
          end;
          if (mapx>25) or (mapx<=0) or (mapy>25) or (mapy<=0) then
          colour:=8   {check if out of bounds, I have a small map}
          else
          begin
          colour:=floormap^[mapx,mapy]; {else find colour in map}
          flm:=flipmap^[mapx,mapy];     {check if I should flip the bitmap}
          if flm=0 then
          begin
          end
          else if flm=1 then bmapx:=63-bmapx
          else if flm=2 then bmapy:=63-bmapy
          else if flm=3 then
          begin
               bmapx:=63-bmapx;
               bmapy:=63-bmapy;
          end;
          end;
          if bmapy>62 then bmapy:=62;
          o4:=bmapx+((bmapy) shl 6)+ctable[colour];  {find the offset of the}
          asm                                        {pixel in the bitmap}
             mov es,[segment]
             mov bx,[o4]
             mov dl,byte ptr [es:bx]                {put it on the screen}
             mov es,[s1]
             mov bx,[ssofs]
             mov byte ptr [es:bx],dl
          end;
          end;
          ssofs:=ssofs+1;                     {increment screen offset}
          finx1:=finx1+xstep;                 {step along map}
          finy1:=finy1+ystep;
     until ssofs=z;                             {until end of h-line}
     ssofs:=ssofs+ssinc;                        {move down one h-line}
     end;
end;
