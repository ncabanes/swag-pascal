(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0189.PAS
  Description: Graphics Cube Rotations
  Author: KISZLEY LASZLO
  Date: 09-04-95  10:27
*)


{ NOTE : Units needed are included at the end of this code }

program		the_4d_experiment;
{version	1.1}
{ Kiszely Laszlo 1995
kiszely@bmeik.eik.bme.hu}
{--------------------------------------------------------------------------}
uses    crt,mygraf;
const   end_seq:real=237;       {the end of a data-stream,
				 it is a 'φ' sign, indicates
				 the end of a kind of stream}

{---------------------------------------------------------------------------}
var	data:file of real;	{the file of the generated object}
	j:integer;		{indexes}
        a:real;                 {for temporary storage}
        chrt:char;              {readkey at the end}

        vertex: array[1..100,1..4] of real;
                                {let's store the vertex-values!}

        vertex_number:integer;  {the number of vertexes}

	edges: array[1..200,1..3] of byte;
				{let's store the edges' start-
				and end-points plus the color of the edge}

	edge_number:integer;	{yes, the number of edges}

        xy,xz,xw,yz,yw,zw:integer;

	sine: array[0..359] of real; {sine-table}

	cosine: array[0..359] of real; {cosine-table}

        FileName:string;  {the name of the 4d-object file}
{---------------------------------------------------------------------------}
{Input/Output procedures}

procedure Open_And_Check;       {Checks whether the requested file is
                                 in the directory or not}
begin
{$I-}
     reset(data);
{$I+}
     if IOResult<>0 then
                    begin
                         writeln(FileName,' not found!');
                         halt;
                    end;
end;


function CheckFlag(flag:real): Boolean;

begin
        read(data,a);
        if a=flag then CheckFlag:=true else CheckFlag:=False;
end;


procedure GetVertex_And_Write;  {Reads the vertexes and puts them
                                 into an an array}
begin
     for j:=1 to 4 do
         read(data,vertex[vertex_number,j]);
end;


procedure GetEdge_And_Write;	{Reads the edge-data-stream and
				puts them into an array}
var real_edge:real;
begin
     for j:=1 to 3 do
        begin
	read(data,real_edge);
        edges[edge_number,j]:=round(real_edge);
        end;
end;
{--------------------------------------------------------------------------}
procedure CmdLineFileName;

begin
     if ParamCount<>1 then begin
                          writeln('No Parameter/Too much Parameters Found!');
                          writeln('Usage: 4dexp object.4d');
                          halt(1);
                          end;
     FileName:=ParamStr(1);
end;

procedure MainScreenOut;

begin
	writeln;writeln;writeln;
	writeln('                          THE       4D      EXPERIMENT');
	writeln;writeln;writeln;
	writeln('                A little program to rotate a 4 dimensional cube');
	writeln;writeln;
	writeln('                           programmed by Kiszely László');
	writeln;writeln;writeln;
	writeln('                                  Control Keys');
	writeln('                4 - 6       Rotation around the YW-plane');
	writeln('                8 - 2       Rotation around the XW-plane');
	writeln('                1 - 9       Rotation around the ZW-plane');
	writeln('                3 - 7       Rotation around the XY-plane');
	writeln('                a - s       Rotation around the XZ-plane');
	writeln('                z - x       Rotation around the YZ-plane');
	writeln('                  q         Quit');
	writeln;
	writeln('                                  Hit any key!');

	writeln;writeln;


	asm
@again:
	in	AL,60h
	and	AL,128
	jnz	@again
	end;
end;

procedure BuildSineTable;

var	index:integer;
begin
	for index:=0 to 359 do
		sine[index]:=sin(index*3.14/180);
end;


procedure BuildCosineTable;

var	index:integer;
begin
	for index:=0 to 359 do
		cosine[index]:=cos(index*3.14/180);
end;
{--------------------------------------------------------------------------}
{Graphical procedures}

procedure ShowThePixel(x1:real;y1:real);{Transform the relative coords}

var	x1tmp,y1tmp:integer;
begin
	x1tmp:=160+round(x1);	{160 - origin-translation}

	y1tmp:=100+round(y1);

	point(x1tmp,y1tmp,10);
end;


procedure ShowTheLine(startpoint:integer;endpoint:integer;color:byte);

var	x1tmp,y1tmp,x2tmp,y2tmp,colour:integer;
begin
	x1tmp:=160+round(vertex[startpoint,1]);
	y1tmp:=100+round(vertex[startpoint,2]);
	x2tmp:=160+round(vertex[endpoint,1]);
	y2tmp:=100+round(vertex[endpoint,2]);

	colour:=round(color);
	myline(x1tmp,y1tmp,x2tmp,y2tmp,colour);
end;


procedure ShowTheObject;

var       o:integer;
begin
	cls;
	for o:=1 to vertex_number do 
		ShowThePixel(vertex[o,1],vertex[o,2]);

        for o:=1 to edge_number do 
		ShowTheLine(edges[o,1],edges[o,2],edges[o,3]);
end;

{--------------------------------------------------------------------------}
{The functions of rotation}

procedure RotateAroundXW(alfa:integer);		{alfa - angle of rotating}
						{in degrees, of course}
var	ytmp,ztmp:real;
        i:integer;
begin
	for i:=1 to vertex_number do
	begin
	ytmp:=vertex[i,2]*cosine[alfa]+vertex[i,3]*sine[alfa];
	ztmp:=-vertex[i,2]*sine[alfa]+vertex[i,3]*cosine[alfa];
	vertex[i,2]:=ytmp;
	vertex[i,3]:=ztmp;
	end;
end;


procedure RotateAroundZW(alfa:integer);

var       xtmp,ytmp:real;
          index:integer;
begin
         for index:=1 to vertex_number do
 	 begin
          xtmp:=vertex[index,1]*cosine[alfa]+vertex[index,2]*sine[alfa];
	  ytmp:=-(vertex[index,1]*sine[alfa])+vertex[index,2]*cosine[alfa];
	  vertex[index,1]:=xtmp;
	  vertex[index,2]:=ytmp;
	 end;
end;


procedure RotateAroundYW(alfa:integer);

var       xtmp,ztmp:real;
          index:integer;
begin
         for index:=1 to vertex_number do
	begin
         xtmp:=vertex[index,1]*cosine[alfa]+vertex[index,3]*sine[alfa];
	 ztmp:=-(vertex[index,1]*sine[alfa])+vertex[index,3]*cosine[alfa];
	 vertex[index,1]:=xtmp;
	 vertex[index,3]:=ztmp;
	end;
end;


procedure RotateAroundXY(alfa:integer);

var       ztmp,wtmp:real;
          index:integer;
begin
         for index:=1 to vertex_number do
	begin
         ztmp:=vertex[index,3]*cosine[alfa]+vertex[index,4]*sine[alfa];
	 wtmp:=-(vertex[index,3]*sine[alfa])+vertex[index,4]*cosine[alfa];
	 vertex[index,3]:=ztmp;
	 vertex[index,4]:=wtmp;
	end;
end;


procedure RotateAroundXZ(alfa:integer);

var       ytmp,wtmp:real;
          index:integer;
begin
         for index:=1 to vertex_number do
	begin
         ytmp:=vertex[index,2]*cosine[alfa]+vertex[index,4]*sine[alfa];
	 wtmp:=-(vertex[index,2]*sine[alfa])+vertex[index,4]*cosine[alfa];
	 vertex[index,2]:=ytmp;
	 vertex[index,4]:=wtmp;
	end;
end;


procedure RotateAroundYZ(alfa:integer);

var       ytmp,ztmp:real;
          index:integer;
begin
         for index:=1 to vertex_number do
	begin
         ytmp:=vertex[index,2]*cosine[alfa]+vertex[index,3]*sine[alfa];
 	 ztmp:=-(vertex[index,2]*sine[alfa])+vertex[index,3]*cosine[alfa];
	 vertex[index,2]:=ytmp;
	 vertex[index,3]:=ztmp;
	end;
end;
{---------------------------------------------------------------------------}
begin
     CmdLineFileName;
     MainScreenOut;
     assign(data,FileName);
     Open_And_Check;

     vertex_number:=0;
     edge_number:=0;

     while CheckFlag(47) do
          begin
          vertex_number:=vertex_number+1;
          GetVertex_And_Write;
          end;

     while CheckFlag(92) do
	  begin
	  edge_number:=edge_number+1;
	  GetEdge_And_Write;
	  end;

	if a<>237 then begin
			writeln('This 4d file is not a valid one!');
			halt(2);
		       end;

     close(data);

vga320;
BuildSineTable;
BuildCosineTable;
ShowTheObject;
repeat

repeat
        RotateAroundYW(yw);
        RotateAroundZW(zw);
        RotateAroundXW(xw);
        RotateAroundXY(xy);
        RotateAroundXZ(xz);
        RotateAroundYZ(yz);
        ShowTheObject;
until keypressed;
chrt:=readkey;

case chrt of
     '4': begin;inc(yw);if yw>359 then yw:=yw-360;end;
     '6': begin;dec(yw);if yw<0 then yw:=yw+360;end;

     '1': begin;inc(zw);if zw>359 then zw:=zw-360;end;
     '9': begin;dec(zw);if zw<0 then zw:=zw+360;end;

     '8': begin;inc(xw);if xw>359 then xw:=xw-360;end;
     '2': begin;dec(xw);if xw<0 then xw:=xw+360;end;

     '7': begin;inc(xy);if xy>359 then xy:=xy-360;end;
     '3': begin;dec(xy);if xy<0 then xy:=xy+360;end;

     'a': begin;inc(xz);if xz>359 then xz:=xz-360;end;
     's': begin;dec(xz);if xz<0 then xz:=xz+360;end;

     'z': begin;inc(yz);if yz>359 then yz:=yz-360;end;
     'x': begin;dec(yz);if yz<0 then yz:=yz+360;end;

     'q': break;
end;

until j=0;

vga_out;
end.
{ -----------------------    CUT HERE ---------------------}

unit mygraf;
{Author: Kiszely Laszlo 1995
kiszely@bmeik.eik.bme.hu
Credits: Thanx to Bas van Gaalen for his 3dpas package}

interface

  const vidseg: word=$a000;

  procedure vga320;
  procedure retrace;
  procedure point(x,y:word;color:byte);
  procedure vga_out;
  procedure cls;
  procedure myline(xk,yk,xv,yv:word; color:byte);

implementation

 procedure vga320; assembler;
   asm
   mov ax,13h;
   int 10h;
   end;

procedure retrace; assembler; asm
  mov dx,03dah; @vert1: in al,dx; test al,8; jnz @vert1
  @vert2: in al,dx; test al,8; jz @vert2; end;

procedure point(x,y:word;color:byte);
   begin
  {if (y<200) and (x<320) then}
	   mem[vidseg:y*320+x]:=color;
   end;

procedure vga_out; assembler;
   asm
   mov  ax,03h
   int  10h
   end;

procedure cls; assembler;
      asm
      mov es,[vidseg];xor di,di;xor ax,ax;mov cx,320*100;
      rep stosw;
      end;

procedure myline(xk,yk,xv,yv:word; color:byte);
var
  sgnx,sgny:byte;
  eltx,elty,x,y,pp,qq,count,nn:word;
begin
  asm
  mov ax,xv
  mov bx,xk
  sub ax,bx
  js @h1
  mov cl,1
  mov  sgnx,cl
  mov  eltx,ax
  jmp @h3
@h1:
  mov cl,0
  mov  sgnx,cl
  mov  eltx,ax
  neg  eltx
@h3:
  mov ax,yv
  mov bx,yk
  sub ax,bx
  js @h4
  mov cl,1
  mov  sgny,cl
  mov  elty,ax
  jmp @h5
@h4:
  mov cl,0
  mov  sgny,cl
  mov  elty,ax
  neg  elty
@h5:
  mov ax, eltx
  mov bx, elty
  cmp ax,bx
  ja @j1
  mov ax, elty
  mov  nn,ax
  jmp @j2
@j1:
  mov ax, eltx
  mov  nn,ax
@j2:
  mov ax, nn
  mov dx,0
  mov bx,2
  div bx
  cmp ax,0
  je @gy1
  mov ax,0
  mov  pp,ax
  mov  qq,ax
  inc  pp
  inc  qq
  jmp @gy2
@gy1:
  mov  pp,ax
  mov  qq,ax
@gy2:
  mov ax,xk
  mov x,ax
  mov ax,yk
  mov y,ax
  mov ax,1
  mov  count,ax
@next :
  push x
  push y
  mov al,color
  push ax
  call point
  mov ax, pp
  add ax, eltx
  mov  pp,ax
  mov bx, nn
  cmp ax,bx
  jb @t1
  mov ax, pp
  sub ax, nn
  mov  pp,ax
  mov al, sgnx
  cmp al,1
  je @nn1
  dec x
  jmp @t1
@nn1:
   inc x
@t1:
  mov ax, qq
  add ax, elty
  mov  qq,ax
  mov bx, nn
  cmp ax,bx
  jb @t2
  mov ax, qq
  sub ax, nn
  mov  qq,ax

  mov al, sgny
  cmp al,1
  je @nn3
  dec y
  jmp @t2
@nn3:
  inc y
@t2:
  inc  count
  mov ax, count
  cmp  nn,ax
  jae @next

  end;
end;

end.

{ -----------------------    CUT HERE ---------------------}
{ CODE TO GENERATE THE CUBE FILE }

program		generate_the_4d_cube;
{this little util generates a 4d_object}
{Author:Kiszely Laszlo 1995
kiszely@bmeik.eik.bme.hu}

const   end_seq:real=237;        {the end of a data-stream,
				  it is a 'φ' sign, indicates
				  the end of a kind of stream}

        vertex_number:integer=16;  {the number of the vertexes}

     the_object: array[1..16,1..5] of real=((47,40,40,40,40),(47,40,40,40,-40),
    (47,40,40,-40,40),(47,40,40,-40,-40),(47,40,-40,40,40),(47,40,-40,40,-40),
    (47,40,-40,-40,40),(47,40,-40,-40,-40),(47,-40,40,40,40),(47,-40,40,40,-40),
    (47,-40,40,-40,40),(47,-40,40,-40,-40),(47,-40,-40,40,40),
    (47,-40,-40,40,-40),(47,-40,-40,-40,40),(47,-40,-40,-40,-40));
                                {an array of vertexes,where:
				47 - a flag, here starts 4 data members
                                     of the vertex-stream
				of course, it can be anything else,too}

        edge_number:integer=32;    {the number of edges in the object}

        the_edges: array[1..32,1..4] of real=( (92,1,3,10),(92,3,7,10),
		      (92,7,5,10),(92,5,1,10),(92,9,11,10),(92,11,15,10),
		      (92,15,13,10),(92,13,9,10),(92,11,3,10),(92,15,7,10),
		      (92,13,5,10),(92,9,1,10),
		      (92,2,10,3),(92,10,14,3),(92,14,6,3),(92,6,2,3),
		      (92,12,4,3),(92,4,8,3),(92,8,16,3),(92,16,12,3),
		      (92,10,12,3),(92,14,16,3),(92,6,8,3),(92,2,4,3),
		      (92,9,10,5),(92,13,14,5),(92,5,6,5),(92,1,2,5),
		      (92,11,12,5),(92,3,4,5),(92,7,8,5),(92,15,16,5));
                                {an array of edges,where:
                                92 - a flag to separate the 2 data members
                                first value - starting point of the edge
                                second value - endpoint of the edge
				third value - the color of the edge}

var	data:file of real;	{the file of the generated object}
	i,j:integer;		{indexes}


begin
     assign(data,'cube.4d');
     rewrite(data);

        for i:=1 to vertex_number do
                 begin
                 for j:=1 to 5 do
                     begin
                     write(data,the_object[i,j]);
                     end;
                 end;                           {the vertexes' coords}
        write(data,end_seq);

        for i:=1 to edge_number do
                 begin
                 for j:=1 to 4 do
                     begin
                     write(data,the_edges[i,j]);
                     end;
                 end;                           {which v-s are on one edge}
        write(data,end_seq);

{Right now, the file of the 4d_object is ready. Be careful at the reading!}

     close(data);
end.


