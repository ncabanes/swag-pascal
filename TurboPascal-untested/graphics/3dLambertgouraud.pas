(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0278.PAS
  Description: 3D LAMBERT/GOURAUD
  Author: PAVEL STRATIL
  Date: 08-30-97  10:08
*)


{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O+,P-,Q+,R+,S+,T+,V+,X+,Y+}
{$M 16384,0,655360}

{
  Please,

     Go through the code, and optimize. There is a frame counter so..
     If something is wrong plase correct it.
     If you change something, please preserve the former code as a comment.

     Please Email me the changed code ASAP on:

     stratil@feniz.cz


     -you may add anything, you thing to be interresting

     Thanks, Pavel
}

{  Below the code is an other file, you need for running this }

type
    VirtualArray = array[1..64000] of byte;
    VPointer = ^VirtualArray;
var
    define : array [ 1..255 ] of record   {used by pallette setup}
                                   color:byte;
                                   shading:byte;
                                 end;
    base : array [ 1..500 ] of record     {non rotated coords}
                                 x,y,z:integer;
                                end;
    rpoint : array [ 1..500 ] of record   {rotated/2d transformed coords}
                                   rx,ry,rz:single;
                                   px,py:integer;
                                  end;
    poly : array [ 1..500 ] of record     {selection of points for triangle}
                                 p1,p2,p3:word;
                                end;
    normal : array [ 1..500 ] of record   { normalized normals non rotated}
                                   x,y,z:single;
                                  end;
    rnormal : array [ 1..500 ] of record  { norm. normals rotated }
                                   x,y,z:single;
                                  end;
    rvertex : array [ 1..500 ] of record  { rotated vertexes for points }
                                   x,y,z:single;
                                  end;
    vmul : array [ 1..500 ] of single;
    sinb : array [ 0..255 ] of single;
    cosb : array [ 0..255 ] of single;
    cbound : array [0..255] of record
                                lower,mul:byte;
                               end;
    lx,ly,lz:single;
    lalfa,lbeta,lgama:byte;
    polycount,pointcount:word;
    origox,origoy,dist:integer;

    singles : array [1..10] of single;

function KeyPressed:boolean;
begin
  asm
    mov	ah,1
    int	16h
    jnz	@true
    mov	[@result],false
    jmp	@end
@true:
    mov	[@result],true
@end:
  end;
end;

function ReadKey:char;assembler;
asm
  mov ah,0h
  int 16h
end;
{virtual screen}
function VSetup(VScreen:VPointer):word;
begin
  new(Vscreen);
  VSetup:=seg(vscreen^);
end;

procedure VDispose(Va:word);
var vscreen:pointer absolute va;
begin
  dispose(Vscreen);
end;
{pregenerate}
procedure psinb;
var w:byte;
begin
  for w:=0 to 255 do
  sinb[w]:=sin(w*pi/128);
end;

procedure pcosb;
var w:byte;
begin
  for w:=0 to 255 do
  cosb[w]:=cos(w*pi/128);
end;

procedure SetRGB(color,r,g,b:Byte);assembler;
asm
  mov dx,3c8h
  mov al,[Color]
  out dx,al
  inc dx
  mov al,[r]
  out dx,al
  mov al,[g]
  out dx,al
  mov al,[b]
  out dx,al
end;
{ load coords from file}
procedure LoadCoords(filename:string);
var s1,s2,s3:string;
    souradnice,i,i1,i2,i3,i4:integer;
    soubor:text;
label MainLoop;
begin
  assign(soubor,filename);
  reset(soubor);
  readln(soubor,pointcount);
  readln(soubor,polycount);
MainLoop:
     readln(soubor,s1);
     readln(soubor,s1);
     i:=0;
     s2:='';
     repeat
        inc(i);
        s3:=copy(s1,i,1);
        if s3=',' then s3:='';
        s2:=s2+s3;
     until s3='';
     val(s2,i1,i2);
     s2:='';
     repeat
        inc(i);
        s3:=copy(s1,i,1);
        if s3='' then s3:='';
        s2:=s2+s3;
     until s3='';
     val(s2,i4,i2);
     i:=0;
     repeat
        inc(i);
        readln(soubor,s1);
        i2:=0;
        s2:='';
        repeat
           inc(i2);
           s3:=copy(s1,i2,1);
           if s3='=' then s3:='';
           s2:=s2+s3;
        until s3='';
        val(s2,souradnice,i3);
        s2:='';
        repeat
          inc(i2);
          s3:=copy(s1,i2,1);
          if s3=',' then s3:='';
          s2:=s2+s3;
        until s3='';
        val(s2,base[souradnice].x,i3);
        s2:='';
        repeat
           inc(i2);
           s3:=copy(s1,i2,1);
           if s3=',' then s3:='';
           s2:=s2+s3;
        until s3='';
        val(s2,base[souradnice].y,i3);
        s2:='';
        repeat
           inc(i2);
           s3:=copy(s1,i2,1);
           if s3='' then s3:='';
           s2:=s2+s3;
        until s3='';
        val(s2,base[souradnice].z,i3);
     until i=i1;
     readln(soubor,s1);
     i:=0;
     repeat
        inc(i);
        readln(soubor,s1);
        i2:=0;
        s2:='';
        repeat
           inc(i2);
           s3:=copy(s1,i2,1);
           if s3='=' then s3:='';
           s2:=s2+s3;
       until s3='';
       val(s2,souradnice,i3);
       s2:='';
       repeat
          inc(i2);
          s3:=copy(s1,i2,1);
          if s3=',' then s3:='';
          s2:=s2+s3;
       until s3='';
       val(s2,poly[souradnice].p1,i3);
       s2:='';
       repeat
          inc(i2);
          s3:=copy(s1,i2,1);
          if s3=',' then s3:='';
          s2:=s2+s3;
       until s3='';
       val(s2,poly[souradnice].p2,i3);
       s2:='';
       repeat
          inc(i2);
          s3:=copy(s1,i2,1);
          if s3='-' then s3:='';
          s2:=s2+s3;
       until s3='';
       val(s2,poly[souradnice].p3,i3);
       s2:='';
       repeat
          inc(i2);
          s3:=copy(s1,i2,1);
          if s3='' then s3:='';
          s2:=s2+s3;
       until s3='';
       val(s2,define[souradnice].color,i3);
    until i=i4;
    readln(soubor,s1);
    if s1<>'' then goto MainLoop;
  close(soubor);
end;

procedure Flip(source,target:word);assembler;
asm
  push ds
  mov ax,target
  mov es,ax
  mov ax,Source
  mov ds,ax
  xor si,si
  xor di,di
  mov cx,16000
  db $f3,66h,$a5
  pop ds
end;

procedure Cls(target:word);assembler;
asm
  mov ax,[bp+offset target]
  mov es,ax
  xor di,di
  db 66h; xor ax,ax
  mov cx,16000
  db 0f3h,66h,0abh
end;

procedure PPix(x,y: Integer;color:byte;target:word); assembler;
asm
  mov ax,target
  mov es,ax
  mov ax,y
  mov di,ax
  shl ax,6
  shl di,8
  add di,ax
  add di,x
  mov al,color
  mov es:[di],al
end;

procedure xchgi(var x1,x2:integer);
var z:integer;
begin
z:=x1;
x1:=x2;
x2:=z;
end;

procedure xchgb(var x1,x2:byte);
var z:byte;
begin
z:=x1;
x1:=x2;
x2:=z;
end;

procedure Striangle(num,target:word); {simple - nonshaded triangle}
var
 pcolor:byte; {visualization}
 x1,y1,x2,y2,x3,y3:integer;
 x,minY,mxaY,xa,xb,yy,p1,q1,p2,q2,p3,q3:integer; {triangle}
begin
 if rnormal[num].z>0 then {is it visible?}
 begin
  begin
   pcolor:=define[num].color+cbound[define[num].color].lower; {choose the color}
   x1:=rpoint[poly[num].p1].px; {for simplicity}
   y1:=rpoint[poly[num].p1].py;
   x2:=rpoint[poly[num].p2].px;
   y2:=rpoint[poly[num].p2].py;
   x3:=rpoint[poly[num].p3].px;
   y3:=rpoint[poly[num].p3].py;
  end;
  {triangle}
  minY:=y1; mxaY:=y1;
  if y2<minY then minY:=y2;
  if y2>mxaY then mxaY:=y2;
  if y3<minY then minY:=y3;
  if y3>mxaY then mxaY:=y3;
  p1:=x1-x3; q1:=y1-y3;
  p2:=x2-x1; q2:=y2-y1;
  p3:=x3-x2; q3:=y3-y2;
  for yy:=minY to mxaY do
    begin
      xa:=320;
      xb:=-1;
      if (y3>=yy) or (y1>=yy) then
        if (y3<=yy) or (y1<=yy) then
          if not(y3=y1) then begin
              x:=(yy-y3)*p1 div q1+x3;
              if x<xa then xa:=x;
              if x>xb then xb:=x;
            end;
      if (y1>=yy) or (y2>=yy) then
        if (y1<=yy) or (y2<=yy) then
          if not(y1=y2) then begin
              x:=(yy-y1)*p2 div q2+x1;
              if x<xa then xa:=x;
              if x>xb then xb:=x;
            end;
      if (y2>=yy) or (y3>=yy) then
        if (y2<=yy) or (y3<=yy) then
          if not(y2=y3) then begin
              x:=(yy-y2)*p3 div q3+x2;
              if x<xa then xa:=x;
              if x>xb then xb:=x;
            end;
      if xa<=xb then
                 asm {horizontal line}
                  mov ax,[target]
                  mov es,ax
                  mov ax,yy
                  mov di,ax
                  shl ax,8
                  shl di,6
                  add di,ax
                  add di,xa
                  mov al,pcolor
                  mov ah,al
                  mov cx,xb
                  sub cx,xa
                  inc cx
                  shr cx,1
                  jnc @1
                  stosb
                  @1:
                  rep stosw
                 end;
    end;
  end;
end;


procedure Ltriangle(num,target:word); { lambert - l. shaded triangle}
var
 x1,y1,x2,y2,x3,y3:integer; {shading}
 pcolor:byte;
 dot:single;
 x,minY,mxaY,xa,xb,yy,p1,q1,p2,q2,p3,q3:integer; {triangle}
begin
 if rnormal[num].z>0 then {visible?}
 begin
  begin  {color}
   dot:=rnormal[num].x*lx+rnormal[num].y*ly+rnormal[num].z*lz;
   {normalized normal.light = nx*lx+xy*xy+xz*lz}
   dot:=dot*cbound[define[num].color].mul+cbound[define[num].color].lower;
   {choose color}
   pcolor:=round(dot);
   x1:=rpoint[poly[num].p1].px; {siplifying}
   y1:=rpoint[poly[num].p1].py;
   x2:=rpoint[poly[num].p2].px;
   y2:=rpoint[poly[num].p2].py;
   x3:=rpoint[poly[num].p3].px;
   y3:=rpoint[poly[num].p3].py;
  end;
  {triangle of color pcolor}
  minY:=y1; mxaY:=y1;
  if y2<minY then minY:=y2;
  if y2>mxaY then mxaY:=y2;
  if y3<minY then minY:=y3;
  if y3>mxaY then mxaY:=y3;
  p1:=x1-x3; q1:=y1-y3;
  p2:=x2-x1; q2:=y2-y1;
  p3:=x3-x2; q3:=y3-y2;
  for yy:=minY to mxaY do
    begin
      xa:=320;
      xb:=-1;
      if (y3>=yy) or (y1>=yy) then
        if (y3<=yy) or (y1<=yy) then
          if not(y3=y1) then begin
              x:=(yy-y3)*p1 div q1+x3;
              if x<xa then xa:=x;
              if x>xb then xb:=x;
            end;
      if (y1>=yy) or (y2>=yy) then
        if (y1<=yy) or (y2<=yy) then
          if not(y1=y2) then begin
              x:=(yy-y1)*p2 div q2+x1;
              if x<xa then xa:=x;
              if x>xb then xb:=x;
            end;
      if (y2>=yy) or (y3>=yy) then
        if (y2<=yy) or (y3<=yy) then
          if not(y2=y3) then begin
              x:=(yy-y2)*p3 div q3+x2;
              if x<xa then xa:=x;
              if x>xb then xb:=x;
            end;
      if xa<=xb then       {horiz. line}
                 asm
                  mov ax,[target]
                  mov es,ax
                  mov ax,yy
                  mov di,ax
                  shl ax,8
                  shl di,6
                  add di,ax
                  add di,xa
                  mov al,pcolor
                  mov ah,al
                  mov cx,xb
                  sub cx,xa
                  inc cx
                  shr cx,1
                  jnc @1
                  stosb
                  @1:
                  rep stosw
                 end;
    end;
  end;
end;

procedure GTriangle(num,target:word);   {gouraud - gour. shaded triangle}
var
 inc,i13,i12,i23,dot1,dot2,dot3,test,color,c1,c2:single; {shading}
 x1,x2,x3,y1,y2,y3:integer;
 col1,col2,col3:byte;
 ideal:boolean;
 x,ax,bx,yy,p1,q1,p2,q2,p3,q3:integer; {triangle}
begin
  if rnormal[num].z>0 then {visible?}
  begin
   dot1:=(rvertex[poly[num].p1].x*lx+rvertex[poly[num].p1].y*ly+rvertex[poly[num].p1].z*lz);
   { normalized dot product for vertex 1 = light.vertex1}
   dot2:=(rvertex[poly[num].p2].x*lx+rvertex[poly[num].p2].y*ly+rvertex[poly[num].p2].z*lz);
   { normalized dot product for vertex 2 = light.vertex2}
   dot3:=(rvertex[poly[num].p3].x*lx+rvertex[poly[num].p3].y*ly+rvertex[poly[num].p3].z*lz);
   { normalized dot product for vertex 3 = light.vertex3}
   col1:=round((dot1*cbound[define[num].color].mul)+cbound[define[num].color].lower);
   { choose color for vertex1}
   col2:=round((dot2*cbound[define[num].color].mul)+cbound[define[num].color].lower);
   { choose color for vertex2}
   col3:=round((dot3*cbound[define[num].color].mul)+cbound[define[num].color].lower);
   { choose color for vertex3}
   x1:=rpoint[poly[num].p1].px; {symplifying}
   y1:=rpoint[poly[num].p1].py;
   x2:=rpoint[poly[num].p2].px;
   y2:=rpoint[poly[num].p2].py;
   x3:=rpoint[poly[num].p3].px;
   y3:=rpoint[poly[num].p3].py;
   if not (y1<=y2) then {sort = y1<y2<y3 - imlicitely are the x and color
                         of the vertext exchanged}
   begin
    xchgi(y1,y2);
    xchgi(x1,x2);
    xchgb(col1,col2);
   end;
   if not (y1<=y3) then
   begin
    xchgi(y1,y3);
    xchgi(x1,x3);
    xchgb(col1,col3);
   end;
   if not (y2<=y3) then
   begin
    xchgi(y2,y3);
    xchgi(x2,x3);
    xchgb(col2,col3);
   end;
   if (y3-y1+1<>0) then i13:=(col3-col1)/(y3-y1+1) else i13:=0;
   { itnterpolating the color between vertex 1 and 3}
   if (y3-y2+1<>0) then i23:=(col3-col2)/(y3-y2+1) else i23:=0;
   { itnterpolating the color between vertex 2 and 3}
   if (y2-y1+1<>0) then i12:=(col2-col1)/(y2-y1+1) else i12:=0;
   { itnterpolating the color between vertex 1 and 2}


   if (y3-y1)<>0 then test:=(x3-x1)/(y3-y1) else test:=0;
   test:=test*(y2-y1);
   test:=test+x1;
   if x2>=test then ideal:=true else ideal:=false;
   { the above is my speciality. I don't know any other way of solving
     this problem. If someone knows..:
     In the loop there are 2 colors defined: c1,c2: c1 for the left side
     of the line, c2 for the right side.
     There are two ways a triangle can look like,
     ideal: where on the left side the line between point 1 and 3,
     on the right side between point 1 and 2, 2 and three.
     I have 3 increments for y:=y+1 inc between 1..3,1..2,2..3 (inc12,inc13,
     inc23). By the thing above I decide to which color (left-c1 or right-c2)
     I should add which increment
     if ideal=false then the line between 1..3 is on the right side }

   c1:=col1; {left color}
   c2:=col1; {right color}
   {triangle}
   p1:=x1-x3; q1:=y1-y3;
   p2:=x2-x1; q2:=y2-y1;
   p3:=x3-x2; q3:=y3-y2;
  for yy:=y1-1 to y2 do
    begin
      ax:=320;
      bx:=-1;
      if (y3>=yy) or (y1>=yy) then
        if (y3<=yy) or (y1<=yy) then
          if not(y3=y1) then begin
              x:=(yy-y3)*p1 div q1+x3;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y1>=yy) or (y2>=yy) then
        if (y1<=yy) or (y2<=yy) then
          if not(y1=y2) then begin
              x:=(yy-y1)*p2 div q2+x1;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y2>=yy) or (y3>=yy) then
        if (y2<=yy) or (y3<=yy) then
          if not(y2=y3) then begin
              x:=(yy-y2)*p3 div q3+x2;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      inc:=(c2-c1)/(bx-ax+1); {inc is the increment for every pixel}
      color:=c1; {we start with the left color - c1}
      for ax:=ax to bx do{for ax to bx draw point, add the pixel_color_inc
                          to the color}
      begin
       ppix(ax,yy,round(color),target);
       color:=color+inc;
      end;
      if ax<=bx then begin
      if ideal=false then  { add increment for y:=y+1 to the left and right
                             color, depending on the 'ideality' of the triangle}
        begin {noideal}
         c1:=c1+i12;
         c2:=c2+i13;
        end
        else
        begin {ideal}
         c1:=c1+i13;
         c2:=c2+i12;
        end;
     end;
  end;

  {this was from y1..y2-1 (I don't like this wery much but..), the same
   as in the loop above is in the loop below, just the color increment
   for inc(y) is on one of the sides inc23 insted of inc12}

  for yy:=y2 to y3 do
    begin
      ax:=320;
      bx:=-1;
      if (y3>=yy) or (y1>=yy) then
        if (y3<=yy) or (y1<=yy) then
          if not(y3=y1) then begin
              x:=(yy-y3)*p1 div q1+x3;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y1>=yy) or (y2>=yy) then
        if (y1<=yy) or (y2<=yy) then
          if not(y1=y2) then begin
              x:=(yy-y1)*p2 div q2+x1;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if (y2>=yy) or (y3>=yy) then
        if (y2<=yy) or (y3<=yy) then
          if not(y2=y3) then begin
              x:=(yy-y2)*p3 div q3+x2;
              if x<ax then ax:=x;
              if x>bx then bx:=x;
            end;
      if ax<=bx then
      begin
       inc:=(c2-c1)/(bx-ax+1);
       color:=c1;
       for ax:=ax to bx do
       begin
        ppix(ax,yy,round(color),target);
        color:=color+inc;
       end;
       if ideal=false then
       begin{noideal}
        c1:=c1+i23;
        c2:=c2+i13;
       end
       else
       begin{ideal}
        c1:=c1+i13;
        c2:=c2+i23;
       end;
      end;
    end;
  end;
end;

procedure GCoords(alfa,beta,gama:byte);
var c:word;
    s:single;
begin
 for c:=1 to pointcount do
 begin
   singles[1]:=cosb[alfa]*base[c].y-sinb[alfa]*base[c].z;
   singles[2]:=sinb[alfa]*base[c].y+cosb[alfa]*base[c].z;
   singles[3]:=cosb[beta]*base[c].x+sinb[beta]*singles[2];
   rpoint[c].rx:=cosb[gama]*singles[3]-sinb[gama]*singles[1];
   rpoint[c].ry:=sinb[gama]*singles[3]+cosb[gama]*singles[1];
   rpoint[c].rz:=cosb[beta]*singles[2]-sinb[beta]*base[c].x;
   rvertex[c].x:=rpoint[c].rx*vmul[c];
   rvertex[c].y:=rpoint[c].ry*vmul[c];
   rvertex[c].z:=rpoint[c].rz*vmul[c];
   s:=(dist+rpoint[c].rz)/dist;
   rpoint[c].px:=round(origoX+s*rpoint[c].rx);
   rpoint[c].py:=round(origoY+s*rpoint[c].ry);
 end;
 for c:=1 to polycount do
 begin
   singles[2]:=sinb[alfa]*normal[c].y+cosb[alfa]*normal[c].z;
   rnormal[c].z:=cosb[beta]*singles[2]-sinb[beta]*normal[c].x;
   if rnormal[c].z>=0 then
   begin
     singles[1]:=cosb[alfa]*normal[c].y-sinb[alfa]*normal[c].z;
     singles[3]:=cosb[beta]*normal[c].x+sinb[beta]*singles[2];
     rnormal[c].x:=cosb[gama]*singles[3]-sinb[gama]*singles[1];
     rnormal[c].y:=sinb[gama]*singles[3]+cosb[gama]*singles[1];
   end;
 end;
end;

procedure rot(var a,b,c,inca,incb,incc:byte;target:word);
var cnt:word;
begin
  a:=byte(a+inca);
  b:=byte(b+incb);
  c:=byte(c+incc);
  GCoords(a,b,c);
  for cnt:=1 to polycount do
  case define[cnt].shading of
   0:Gtriangle(cnt,target);
   1:Ltriangle(cnt,target);
   2:Striangle(cnt,target);
  end;
  flip(target,$0a000);
  cls(target);
end;

procedure prepare;
var vl,light,z,x,y,norm:extended;
c:word;
begin
 for c:=1 to polycount do
 begin
  x:=(base[poly[c].p2].y-base[poly[c].p1].y)*(base[poly[c].p1].z-base[poly[c].p3].z)-
     (base[poly[c].p2].z-base[poly[c].p1].z)*(base[poly[c].p1].y-base[poly[c].p3].y);
  y:=(base[poly[c].p2].z-base[poly[c].p1].z)*(base[poly[c].p1].x-base[poly[c].p3].x)-
     (base[poly[c].p2].x-base[poly[c].p1].x)*(base[poly[c].p1].z-base[poly[c].p3].z);
  z:=(base[poly[c].p2].x-base[poly[c].p1].x)*(base[poly[c].p1].y-base[poly[c].p3].y)-
     (base[poly[c].p2].y-base[poly[c].p1].y)*(base[poly[c].p1].x-base[poly[c].p3].x);
  norm:=sqrt(sqr(x)+sqr(y)+sqr(z));
  normal[c].x:=x/norm;
  normal[c].y:=y/norm;
  normal[c].z:=z/norm;
 end;
 for c:=1 to pointcount do
 begin
  vl:=sqrt(sqr(base[c].y)+sqr(base[c].z)+sqr(base[c].x));
  vmul[c]:=1/vl;
 end;
 light:=sqrt(sqr(lx)+sqr(ly)+sqr(lz));
 lx:=lx/light;
 ly:=ly/light;
 lz:=lz/light;
end;

procedure setshades(rh,gh,bh,rl,gl,bl,col1,col2,color:byte);
var rr,gg,bb,r,g,b,incr,incg,incb:single;
    count,cto:byte;
begin
 incr:=(rh-rl)/abs(col2-col1);
 incg:=(gh-gl)/abs(col2-col1);
 incb:=(bh-bl)/abs(col2-col1);
 if col1<col2 then
 begin
   count:=col1;
   cto:=col2;
 end else
 begin
   count:=col2;
   cto:=col1;
 end;
 r:=rl; g:=gl; b:=bl;
 rr:=rl; gg:=gl; bb:=bl;
 for count:=count to cto do
 begin
   setrgb(count,round(r),round(g),round(b));
   rr:=rr+incr;
   gg:=gg+incg;
   bb:=bb+incb;
   r:=rr; g:=gg; b:=bb;
 end;
 setrgb(count,round(r),round(g),round(b));
 cbound[color].mul:=(abs(col2-col1) div 2);
 cbound[color].lower:=(abs(col2-col1) div 2)+col1-1;
end;


var
aa,bb,cc,incaa,incbb,inccc:byte;
vp:vpointer;
adr:word;
rd:char;
time:longint absolute $0:$046c;
frame,etime,stime:longint;

begin
 asm  mov ax,13h; int 10h end;
 psinb;
 pcosb;
 LoadCoords('star2.x');
 setshades(63,63,0,23,0,0,1,63,1);
 setshades(30,30,63,0,0,2,64,128,2);
 setshades(43,00,0,23,0,0,129,135,3);
 setshades(20,60,20,20,60,20,136,140,4);
{ define[2].color:=4;
 define[3].color:=4;
 define[2].shading:=2;
 define[3].shading:=2;
 define[1].color:=3;
 define[4].color:=3;
 define[1].shading:=1;
 define[4].shading:=1;
 define[7].color:=2;
 define[8].color:=2;
 define[9].color:=2;
 define[10].color:=2;
 define[7].shading:=0;
 define[8].shading:=0;
 define[9].shading:=0;
 define[10].shading:=0;
 define[17].color:=2;
 define[18].color:=2;
 define[19].color:=2;
 define[20].color:=2;
{ for adr:= 1 to 20 do begin
 define[adr].shading:=0;
 end;}
 incaa:=0;
 incbb:=0;
 inccc:=0;
 aa:=00;
 bb:=00;
 cc:=00;
 lx:=-10;
 ly:=10;
 lz:=10;
 origox:=160;
 origoy:=100;
 dist:=32678;
 adr:=vsetup(vp);
 cls(adr);
 prepare;
 stime:=time;
repeat
 inc(frame);
 rot(aa,bb,cc,incaa,incbb,inccc,adr);
 if keypressed then
  begin rd:=readkey;
   case rd of
         'z':inc(incaa);
         'x':dec(incaa);
         'c':inc(incbb);
         'v':dec(incbb);
         'b':inc(inccc);
         'n':dec(inccc);
         't':begin lx:=lx+0.01;
                   ly:=ly+0.01;
                   lz:=lz-0.02; end;
         's':begin aa:=0;
                   bb:=0;
                   cc:=0;
                   incaa:=0;
                   incbb:=0;
                   inccc:=0; end;
      'a':begin
           incaa:=0;
           incbb:=0;
           inccc:=0;
          end;
     end;
   end;
 until rd=#27;
 etime:=time;
 asm  mov ax,3 ; int 10h end;
 writeln((Frame*18.2)/(ETime-STime):5:2, ' fps');
end.

save this as star2.x
****************cut****************
12
20
;triangle
12,20
1=-20,-5,0
2=-50,0,0
3=-20,5,0
4=0,-5,0
5=0,5,0
6=30,0,0
7=22,0,-25
8=5,0,-40
9=-2,0,-70
10=-17,0,-70
11=-25,0,-40
12=-42,0,-25
;coords,done
1=2,3,1-1
2=1,3,4-1
3=4,3,5-1
4=4,5,6-1
5=7,4,6-1
6=8,4,7-1
7=9,4,8-1
8=9,1,4-1
9=10,1,9-1
10=10,11,1-1
11=12,1,11-1
12=12,2,1-1
13=8,7,5-1
14=5,7,6-1
15=12,3,2-1
16=12,11,3-1
17=9,8,5-1
18=10,3,11-1
19=10,9,3-1
20=9,5,3-1


