
{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O+,P-,Q+,R-,S+,T+,V+,X+,Y+}
{$M 4096,0,655360}

{
  Please,

     Go through the code, and find the bugs. Optimize. There is a frame
     counter so..
     If something is wrong plase correct it.
     If you change something, please preserve the former code as a comment.

     Please Email me the changed code ASAP on:

     stratil@feniz.cz


     -you may add anything, you thing to be interresting

     Thanks, Pavel
}


{ check the info below the code. Something is explained there.
  There is also another file, you need for running this}

type
    VirtualArray = array[1..64000] of byte;
    VPointer = ^VirtualArray;
var
    define : array [ 1..255 ] of record
                                  color:byte;
                                 end;
    base : array [ 1..1000 ] of record
                                 x,y,z:integer;
                                end;
    rpoint : array [ 1..1000 ] of record
                                   rx,ry,rz:single;
                                   px,py:integer;
                                  end;
    poly : array [ 1..1000 ] of record
                                 p1,p2,p3:word;
                                end;
    normal : array [ 1..1000 ] of record
                                   x,y,z:single;
                                  end;
    rnormal : array [ 1..1000 ] of record
                                   x,y,z:single;
                                  end;

    sinb : array [ 0..255 ] of single;
    cosb : array [ 0..255 ] of single;
    cbound : array [0..255] of record
                                llower,glower,lmul,gmul:byte;
                               end;
    lx,ly,lz:single; {light x,y,z}
    lalfa,lbeta,lgama:byte; {light alfa beta gama}
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

procedure WaitRet; assembler;
asm
  mov dx,3dah
  @1:
    in al,dx
    test al,08h
    jnz @1
  @2:
    in al,dx
    test al,08h
    jz @2
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


procedure Cls(target:word);assembler;
asm
  mov ax,[bp+offset target]
  mov es,ax
  xor di,di
  db 66h; xor ax,ax
  mov cx,16000
  db 0f3h,66h,0abh
end;

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

const map:array[0..11,0..20] of byte=(
(15,07,15,07,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07),
(07,15,07,15,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15),
(15,07,15,07,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07),
(07,15,07,15,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15),
(15,07,15,07,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07),
(07,15,07,15,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15),
(15,07,15,07,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07),
(07,15,07,15,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15),
(15,07,15,07,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07),
(07,15,07,15,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15),
(15,07,15,07,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07),
(07,15,07,15,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15,07,15));

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


procedure Ttriangle(num,target:word);
var
 u,v,incu,incv,test,u1,v1,u2,v2,inc12u,inc13u,inc23u,inc12v,inc13v,inc23v:single;
 x1,y1,x2,y2,x3,y3:integer; {shading}
 tx1,ty1,tx2,ty2,tx3,ty3:integer; {shading}
 color:byte;
 gu,gv,width:word;
 cnt,x,minY,maxY,midY,xa,xb,yy,p1,q1,p2,q2,p3,q3:integer;
 ideal:boolean;
begin
  tx1:=0;
  ty1:=0;
  tx2:=20;
  ty2:=0;
  tx3:=20;
  ty3:=11;

 {width:=x2-x1+1;}
 if rnormal[num].z>=0 then
 begin
  begin  {color}
   x1:=rpoint[poly[num].p1].px;
   y1:=rpoint[poly[num].p1].py;
   x2:=rpoint[poly[num].p2].px;
   y2:=rpoint[poly[num].p2].py;
   x3:=rpoint[poly[num].p3].px;
   y3:=rpoint[poly[num].p3].py;
  end;

 if (y1>y2) then
 begin
  xchgi(y1,y2);
  xchgi(x1,x2);
  xchgi(ty1,ty2);
  xchgi(tx1,tx2);
 end;
 if (y1>y3) then
 begin
  xchgi(y1,y3);
  xchgi(x1,x3);
  xchgi(ty1,ty3);
  xchgi(tx1,tx3);
 end;
 if (y2>y3) then
 begin
  xchgi(y2,y3);
  xchgi(x2,x3);
  xchgi(ty2,ty3);
  xchgi(tx2,tx3);
 end;
 if (y2-y1)<>0 then inc12u:=(tx2-tx1)/(y2-y1) else inc12u:=0;
 if (y3-y2)<>0 then inc23u:=(tx3-tx2)/(y3-y2) else inc23u:=0;
 if (y3-y1)<>0 then inc13u:=(tx3-tx1)/(y3-y1) else inc13u:=0;
 if (y2-y1)<>0 then inc12v:=(ty2-ty1)/(y2-y1) else inc12v:=0;
 if (y3-y2)<>0 then inc23v:=(ty3-ty2)/(y3-y2) else inc23v:=0;
 if (y3-y1)<>0 then inc13v:=(ty3-ty1)/(y3-y1) else inc13v:=0;

 if (y3-y1)<>0 then test:=(x3-x1)/(y3-y1) else test:=0;
 test:=test*(y2-y1);
 test:=test+x1;
 if x2>=test then ideal:=true else ideal:=false;

 u1:=tx1;v1:=ty1;
 if y1<>y2 then
 begin
 u2:=tx1;v2:=ty1;
 end else begin
 u2:=tx2;v2:=ty2;
 end;


 p1:=x1-x3; q1:=y1-y3;
 p2:=x2-x1; q2:=y2-y1;
 p3:=x3-x2; q3:=y3-y2;

  for yy:=Y1 to (Y2-1) do
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
      begin
        incu:=(u2-u1)/(xb-xa+1);
        incv:=(v2-v1)/(xb-xa+1);
        u:=u1;
        v:=v1;
        for cnt:=xa to xb do
        begin
          {gv:=round(v);
          gu:=round(u);}
          color:=map[round(v),round(u)];  {*}
          {asm
           mov di,offset bitmap
           mov ax,gv
           mul width
           add ax,gu
           add di,ax
           mov al,byte ptr ds:[di]
           mov color,al
          end;}
          ppix(cnt,yy,color,target);
          u:=u+incu;
          v:=v+incv;
        end;
        if ideal=false then
        begin
          u1:=u1+inc12u;
          u2:=u2+inc13u;
          v1:=v1+inc12v;
          v2:=v2+inc13v;
        end else
        begin
          u1:=u1+inc13u;
          u2:=u2+inc12u;
          v1:=v1+inc13v;
          v2:=v2+inc12v;
        end;
      end;
   end;

  for yy:=Y2 to Y3 do
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
      begin
        incu:=(u2-u1)/(xb-xa+1);
        incv:=(v2-v1)/(xb-xa+1);
        u:=u1;
        v:=v1;
        for cnt:=xa to xb do
        begin
          {gv:=round(v);
          gu:=round(u);}
          color:=map[round(v),round(u)];  {*}
          {asm
           mov di,offset bitmap
           mov ax,gv
           mul width
           add ax,gu
           add di,ax
           mov al,byte ptr ds:[di]
           mov color,al
          end;}
          ppix(cnt,yy,color,target);
          u:=u+incu;
          v:=v+incv;
        end;
        if ideal=false then
        begin
          u1:=u1+inc23u;
          u2:=u2+inc13u;
          v1:=v1+inc23v;
          v2:=v2+inc13v;
        end else
        begin
          u1:=u1+inc13u;
          u2:=u2+inc23u;
          v1:=v1+inc13v;
          v2:=v2+inc23v;
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
  for cnt:=1 to polycount do Ttriangle(cnt,target);
  flip(target,$0a000);
  cls(target);
end;

procedure prepare;
var light,z,x,y,norm:extended;
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
 cbound[color].lmul:=abs(col2-col1);
 cbound[color].llower:=col1-1;
end;


var
aa,bb,cc,incaa,incbb,inccc:byte;
rd:char;
vp:vpointer;
adr:word;

var  Time : Longint ABSOLUTE $0:$046c;
  frame,etime,stime:longint;

begin
 asm  mov ax,13h; int 10h end;
 psinb;
 pcosb;
 LoadCoords('star2.x');
 incaa:=0;
 incbb:=0;
 inccc:=0;
 aa:=00;
 bb:=00;
 cc:=00;
 lx:=0;
 ly:=0;
 lz:=1;
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
         't':begin
              inc(lalfa);
              singles[1]:=cosb[lalfa]*ly-sinb[lalfa]*lz;
              singles[2]:=sinb[lalfa]*ly+cosb[lalfa]*lz;
              singles[3]:=cosb[lbeta]*lx+sinb[lbeta]*singles[2];
              lx:=cosb[lgama]*singles[3]-sinb[lgama]*singles[1];
              ly:=sinb[lgama]*singles[3]+cosb[lgama]*singles[1];
              lz:=cosb[lbeta]*singles[2]-sinb[lbeta]*lx;
             end;
         's':begin aa:=0;
                   bb:=0;
                   cc:=0;
                   incaa:=0;
                   incbb:=0;
                   inccc:=0;
                   end;
      'a':begin
           incaa:=0;
           incbb:=0;
           inccc:=0;
          end;
     end;
   end;

 until port[$60]=1;
  etime:=time;
asm  mov ax,3 ; int 10h end;
   Writeln((Frame*18.2)/(ETime-STime):5:2, ' fps');
end.

{ The achievment:
  1) Have a perspective not correct texturemapped
     object rotating correctly -> see bug in textrot.pas
  2) Turn on the range check in textrot without an error
  3) Optimize it
  4) Use any texture (see below)
  5) Fix the bug in this file for y1=y2 somewhat intelligently
  -for even better understanding, see how I made the gouraud
  triangle, in 3dfi.pas }


{ANYTHING I'M REFERING TO CAN BE FOUND IN 3DFI.PAS}

procedure Ttriangle(x1,y1,x2,y2,x3,y3,tx1,ty1,tx2,ty2,tx3,ty3:integer;
                    var bitmap;target:word);
var
 u,v,incu,incv,test,u1,v1,u2,v2,inc12u,inc13u,inc23u,inc12v,inc13v,inc23v:single;
 color:byte;
 gu,gv,width:word;
 cnt,x,minY,maxY,midY,xa,xb,yy,p1,q1,p2,q2,p3,q3:integer;
 ideal:boolean;
 {the things in brackets shoud have been used, but.. se below at ASM}
begin
 width:=x2-x1+1;
 if (y1>y2) then  {sort to have y1<=y2<=y3, implicitly x,tx,ty are chnged}
 begin
  xchgi(y1,y2);
  xchgi(x1,x2);
  xchgi(ty1,ty2);
  xchgi(tx1,tx2);
 end;
 if (y1>y3) then
 begin
  xchgi(y1,y3);
  xchgi(x1,x3);
  xchgi(ty1,ty3);
  xchgi(tx1,tx3);
 end;
 if (y2>y3) then
 begin
  xchgi(y2,y3);
  xchgi(x2,x3);
  xchgi(ty2,ty3);
  xchgi(tx2,tx3);
 end;
 if (y2-y1)<>0 then inc12u:=(tx2-tx1)/(y2-y1) else inc12u:=0;
 if (y3-y2)<>0 then inc23u:=(tx3-tx2)/(y3-y2) else inc23u:=0;
 if (y3-y1)<>0 then inc13u:=(tx3-tx1)/(y3-y1) else inc13u:=0;
 if (y2-y1)<>0 then inc12v:=(ty2-ty1)/(y2-y1) else inc12v:=0;
 if (y3-y2)<>0 then inc23v:=(ty3-ty2)/(y3-y2) else inc23v:=0;
 if (y3-y1)<>0 then inc13v:=(ty3-ty1)/(y3-y1) else inc13v:=0;
 {get the increasing u,v along the inc(y) between points 1..2,1..3,2..3
  (inc12,inc13,inc23)}

 if (y3-y1)<>0 then test:=(x3-x1)/(y3-y1) else test:=0;
 test:=test*(y2-y1);
 test:=test+x1;
 if x2>=test then ideal:=true else ideal:=false;
 { the above is my speciality. I don't know any other way of solving
   this problem. If someone knows..:
   In the loop there are 2 'u' and 'v' defined: u1,u2,v1,v2:
   u1,v1 for the left side of the line, u2,v2 for the right side.
   There are two ways a triangle can look like,
   ideal: where on the left side the line between point 1 and 3,
   on the right side between point 1 and 2, 2 and three.
   I have 3 increments for y:=y+1 inc between 1..3,1..2,2..3 (inc12,inc13,
   inc23). Using the thing above,I decide to which u,v
   (left-u1,v1 or right-u2,v2) I should add which increment
   if ideal=false then the line between 1..3 is on the right side }

 u1:=tx1;v1:=ty1;u2:=tx1;v2:=ty1; {we're on the begining of the texture}
 gu:=tx1;gv:=ty1;

 p1:=x1-x3; q1:=y1-y3;
 p2:=x2-x1; q2:=y2-y1;
 p3:=x3-x2; q3:=y3-y2;

  for yy:=Y1 to Y2-1 do
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
      begin
       incu:=(u2-u1)/(xb-xa+1);
       incv:=(v2-v1)/(xb-xa+1);{inc for u,v for evry pixel along the scanline}
        u:=u1;
        v:=v1;
        for cnt:=xa to xb do
        begin
         {well here should heve been the things in brackets, but when I use
          the assembly routine to get my color, it doesn't do well in the
          2nd part. Please have a look at it. Just put away the brackets
          round gv:=.. and asm..end in this, and the 2nd part otf the triangle
          and you'll see what I mean (!) you have to put the color:=map[..
          into brackets}

          {gv:=round(v);
          gu:=round(u);}
          color:=map[round(v),round(u)];  {*} {choose the color of the pix}
          {asm
           mov di,offset bitmap
           mov ax,gv
           mul width
           add ax,gu
           add di,ax
           mov al,byte ptr ds:[di]
           mov color,al
          end;}
          ppix(cnt,yy,color,target);
          u:=u+incu;
          v:=v+incv; {putpixel and increment}
        end;
        if ideal=false then
        begin
          u1:=u1+inc12u;     {inc along the y:=y+1}
          u2:=u2+inc13u;
          v1:=v1+inc12v;
          v2:=v2+inc13v;
        end else
        begin
          u1:=u1+inc13u;
          u2:=u2+inc12u;
          v1:=v1+inc13v;
          v2:=v2+inc12v;
        end;
      end;
   end;

  {the same you saw above, is down here (below), only the inc(y) increments
   are insted of inc12 changed to inc23   (more details in gouraud)}
  for yy:=Y2 to Y3 do
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
      begin
        incu:=(u2-u1)/(xb-xa+1);
        incv:=(v2-v1)/(xb-xa+1);
        u:=u1;
        v:=v1;
        for cnt:=xa to xb do
        begin
          {gv:=round(v);
          gu:=round(u);}
          color:=map[round(v),round(u)];  {*}
          {asm
           mov di,offset bitmap
           mov ax,gv
           mul width
           add ax,gu
           add di,ax
           mov al,byte ptr ds:[di]
           mov color,al
          end;}
          ppix(cnt,yy,color,target);
          u:=u+incu;
          v:=v+incv;
        end;
        if ideal=false then
        begin
          u1:=u1+inc23u;
          u2:=u2+inc13u;
          v1:=v1+inc23v;
          v2:=v2+inc13v;
        end else
        begin
          u1:=u1+inc13u;
          u2:=u2+inc23u;
          v1:=v1+inc13v;
          v2:=v2+inc23v;
        end;
      end;
   end;


end;


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