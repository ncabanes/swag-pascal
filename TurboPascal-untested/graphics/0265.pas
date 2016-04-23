{
I am sending a unit which I have made that lets you get an image off the
screen, put an image on the screen, save an image to disk, load it off
the disk, and scale the object as well.  I would like to contribute this
unit to swag.

thanks

}
{Landon Rabern 1997
{This unit has procedures for getting an image, putting an image, saving an
image to disk, and scaling an image 
It works pretty well but it isn't optimised, so if you optimise it please
send me a copy}
unit picunit;

interface

uses crt;

type
    Tpic=record
               xs,ys:word;
    end;
    Upic=record
               xs,ys:word;
               data:pointer;
    end;

procedure getpic(x1,y1,x2,y2:integer;var bitmap:Upic;where:word);
procedure putpic(x,y:word;pic:Upic;where:word);
procedure putcpic(x,y:word;pic:Upic;where:word);
procedure savetopic(x1,y1,x2,y2:word;fn:string;where:word);
procedure savepic(pic:Upic;fn:string);
procedure loadpic(var pic:Upic;fn:string);
procedure scalepic(ox,oy:word;pic:Upic;sc:real;where:word);
procedure disposepic(var pic:Upic);


implementation


procedure getpic(x1,y1,x2,y2:integer;var bitmap:Upic;where:word);
var
   i,line,off:word;
begin
     line:=x1+y1*320;
     off:=0;
     bitmap.xs:=abs(x1-x2);
     bitmap.ys:=abs(y1-y2);
     getmem(bitmap.data,bitmap.xs*bitmap.ys);
     for i:=1 to bitmap.ys do begin
         move(mem[where:line],mem[seg(bitmap.data^):off],bitmap.xs);
         inc(line,320);
         inc(off,bitmap.xs);
     end;
end;

procedure putpic(x,y:word;pic:Upic;where:word);
var
   i,off,line:word;

begin
     line:=x+320*y;
     off:=0;
     for i:=1 to pic.ys do begin
         move(mem[seg(pic.data^):ofs(pic.data^)+off],mem[where:line],pic.xs);
         inc(line,320);
         inc(off,pic.xs);
     end;
end;

procedure putcpic(x,y:word;pic:Upic;where:word);
var
   i,j,off,line:word;
   c:byte;
begin
     line:=x+320*y;
     off:=0;
     for i:=1 to pic.ys do begin
         for j:=0 to pic.xs-1 do begin
             c:=mem[seg(pic.data^):ofs(pic.data^)+off];
             if c<>0 then
                mem[where:line+j]:=c;
             inc(off);
         end;
         inc(line,320);
     end;
end;

procedure savetopic(x1,y1,x2,y2:word;fn:string;where:word);
var
   f:file of Tpic;
   f2:file;
   a:Upic;
   b:Tpic;
begin
     getpic(x1,y1,x2,y2,a,where);
     b.xs:=a.xs;
     b.ys:=a.ys;
     assign(f,fn);
     assign(f2,fn);
     rewrite(f);
     write(f,b);
     close(f);
     reset(f2,1);
     seek(f2,4);
     blockwrite(f2,a.data^,a.xs*a.ys);
     close(f2);
     disposepic(a);
end;

procedure savepic(pic:Upic;fn:string);
var
   f:file of Tpic;
   f2:file;
   b:Tpic;
begin
     assign(f,fn);
     assign(f2,fn);
     b.xs:=pic.xs;
     b.ys:=pic.ys;
     rewrite(f);
     write(f,b);
     close(f);
     reset(f2,1);
     seek(f2,4);
     blockwrite(f2,pic.data^,pic.xs*pic.ys);
     close(f2);
end;

procedure loadpic(var pic:Upic;fn:string);
var
   f:file of Tpic;
   f2:file;
   b:Tpic;
begin
     assign(f,fn);
     assign(f2,fn);
     reset(f);
     read(f,b);
     close(f);
     pic.xs:=b.xs;
     pic.ys:=b.ys;
     getmem(pic.data,pic.xs*pic.ys);
     reset(f2,1);
     seek(f2,4);
     blockread(f2,pic.data^,pic.xs*pic.ys);
     close(f2);
end;

procedure scalepic(ox,oy:word;pic:Upic;sc:real;where:word);
var
   x,y,wo,off:integer;
   yscalei,xscales,yscales,xscalei,sc2,sc3:real;
   data:byte;
begin
     off:=ox+oy*320;
     wo:=0;
     data:=0;
     yscalei:=0;
     sc2:=sc*pic.xs;
     sc3:=sc*pic.ys;
     yscales:=pic.ys/sc3;
     xscales:=pic.xs/sc2;
     for y:=0 to trunc(sc3)-1 do begin
         xscalei:=0;
         for x:=0 to trunc(sc2)-1 do begin
             data:=mem[seg(pic.data^):ofs(pic.data^)+wo+trunc(xscalei)];
             if data<>0 then mem[where:off+x]:=data;
             xscalei:=xscalei+xscales;
         end;
         yscalei:=yscalei+yscales;
         inc(off,320);
         wo:=pic.xs*trunc(yscalei);
     end;
end;


procedure disposepic(var pic:Upic);
begin
     if pic.data=nil then exit
     else freemem(pic.data,pic.xs*pic.ys);
end;


end.
