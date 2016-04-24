(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0122.PAS
  Description: Moving Poligon
  Author: LUIS MEZQUITA
  Date: 08-24-94  13:51
*)

{
PS> I see that a lot of people around here have polygon, texture mapping and
PS> 3D routines so why don't you all post them here, even if you already
PS> have done in the past cause there are people who didn't get them
PS> and want them :)
}

{$G+,R-}
Program Polygoned_and_shaded_objects;

{ Mode-x version of polygoned objects          }
{ Originally by Bas van Gaalen & Sven van Heel }
{ Optimized by Luis Mezquita Raya              }

uses Crt,x3Dunit2;
         { ^^^^^  Contained in GRAPHICS.SWG file }
{$DEFINE Object1}                       { Try an object between 1..4 }

const

{$IFDEF Object1}                        { Octagon }
 nofpolys=9;                            { Number of poligons-1 }

 nofpoints=11;                          { Number of points-1 }

 polypoints=4;                          { Number of points for each poly }

 sc=5;                                  { Number of visible planes }

 cr=23;                                 { RGB components }
 cg=8;
 cb=3;

 point:array[0..nofpoints,0..2] of integer=(
    (-20,-20, 30),( 20,-20, 30),( 40,-40,  0),( 20,-20,-30),
    (-20,-20,-30),(-40,-40,  0),(-20, 20, 30),( 20, 20, 30),
    ( 40, 40,  0),( 20, 20,-30),(-20, 20,-30),(-40, 40,  0));

 planes:array[0..nofpolys,0..3] of byte=(
    (0,1,7,6),(1,2,8,7),(9,8,2,3),(10,9,3,4),(10,4,5,11),
    (6,11,5,0),(0,1,2,5),(5,2,3,4),(6,7,8,11),(11,8,9,10));
{$ENDIF}

{$IFDEF Object2}                        { Cube }
 nofpolys=5;                            { Number of poligons-1 }

 nofpoints=7;                           { Number of points-1 }

 polypoints=4;                          { Number of points for each poly }

 sc=3;                                  { Number of visible planes }

 cr=0;                                  { RGB components }
 cg=13;
 cb=23;

 point:array[0..nofpoints,0..2] of integer=(
    (-40,-40, 40),( 40,-40, 40),( 40,-40,-40),(-40,-40,-40),
    (-40, 40, 40),( 40, 40, 40),( 40, 40,-40),(-40, 40,-40));

 planes:array[0..nofpolys,0..3] of byte=(
    (0,1,5,4),(1,5,6,2),(6,7,3,2),
    (7,3,0,4),(0,1,2,3),(6,5,4,7));
{$ENDIF}

{$IFDEF Object3}                        { Octahedron }
 nofpolys=7;                            { Number of poligons-1 }

 nofpoints=5;                           { Number of points-1 }

 polypoints=3;                          { Number of points for each poly }

 sc=4;                                  { Number of visible planes }

 cr=0;                                  { RGB components }
 cg=3;
 cb=23;

 point:array[0..nofpoints,0..2] of integer=(
    (  0, 0,  45),(-40,-40,  0),(-40, 40,  0),( 40, 40,  0),
    ( 40,-40,  0),(  0,  0,-45));

 planes:array[0..nofpolys,0..3] of byte=(
    (0,1,2,0),(0,2,3,0),(0,3,4,0),(0,4,1,0),
    (5,1,2,5),(5,2,3,5),(5,3,4,5),(5,4,1,5));

{$ENDIF}

{$IFDEF Object4}                        { Spiky }
 nofpolys=15;                           { Number of poligons-1 }

 nofpoints=19;                          { Number of points-1 }

 polypoints=4;                          { Number of points for each poly }

 sc=5;                                  { Number of visible planes }

 cr=23;                                 { RGB components }
 cg=5;
 cb=5;

 point:array[0..nofpoints,0..2] of integer=(
    (-10,-10, 30),( 10,-10, 30),( 30,-30,  0),( 10,-10,-30),
    (-10,-10,-30),(-30,-30,  0),(-10, 10, 30),( 10, 10, 30),
    ( 30, 30,  0),( 10, 10,-30),(-10, 10,-30),(-30, 30,  0),
    ( -2, -2, 60),( -2,  2, 60),(  2, -2, 60),(  2,  2, 60),
    ( -2, -2,-60),( -2,  2,-60),(  2, -2,-60),(  2,  2,-60));

 planes:array[0..nofpolys,0..3] of byte=(
    (0,1,14,12),(7,15,13,6),(1,14,15,7),(6,13,12,0),
    (1,2,8,7),(9,8,2,3),
    (10,9,19,17),(10,4,16,17),(3,4,16,18),(3,9,19,18),
    (10,4,5,11),
    (6,11,5,0),(0,1,2,5),(5,2,3,4),(6,7,8,11),(11,8,9,10));
{$ENDIF}

type  polytype=array[0..nofpolys] of integer;
      pointype=array[0..nofpoints] of integer;

      ptnode=word;
      stack=ptnode;

const soplt=SizeOf(polytype);
      sopit=SizeOf(pointype);
      xst:integer=1;
      yst:integer=1;
      zst:integer=-2;

var   polyz,pind:array[byte] of polytype;
      xp,yp:array[byte] of pointype;
      phix:byte;

Procedure QuickSort(lo,hi:integer); assembler; { Iterative QuickSort }
var i,j,x,y:integer;                           { NON RECURSIVE }
asm
        mov ah,48h                      { Init stack }
        mov bx,1
        int 21h
        jc @exit
        mov es,ax
        xor ax,ax
        mov es:[4],ax

        mov cx,lo                       { Push(lo,hi) }
        mov dx,hi
        call @Push

@QS:    mov ax,es:[4]                   { ¿Stack empty? }
        and ax,ax
        jz @Empty

        mov cx,es:[0]                   { Top(lo,hi) }
        mov dx,es:[2]
        mov lo,cx
        mov hi,dx

        mov bx,es:[4]                   { Pop }
        mov ah,49h
        int 21h
        jc @exit
        mov es,bx

        mov ax,cx                       { ax:=(i+j) div 2 }
        mov bx,dx
        add ax,bx
        shr ax,1

        lea bx,polyz                    { ax:=polyz[ax] }
        call @index
        mov x,ax

@Rep:   mov ax,cx                       { repeat ... }
        lea bx,polyz                    { while polyz[i]<x do ... }
        call @index
        cmp ax,x
        jge @Rep2
        inc cx                          { inc(i); }
        jmp @Rep

@Rep2:  mov ax,dx                       { while x<polyz[j] do ... }
        call @index
        cmp x,ax
        jge @EndR
        dec dx                          { dec(j); }
        jmp @Rep2

@EndR:  cmp cx,dx                       { if i>j ==> @NSwap}
        jg @NBl

        je @NSwap
        push cx

        mov ax,cx
        call @index
        mov cx,ax                       { cx:=polyz[i] }
        mov si,di

        mov ax,dx                       { polyz[i]:=polyz[j] }
        call @index
        mov [si],ax

        mov [di],cx                     { polyz[j]:=cx }
        pop ax

        push ax
        lea bx,pind
        call @index
        mov cx,ax                       { cx:=pind[i] }
        mov si,di

        mov ax,dx                       { pind[i]:=pind[j] }
        call @index
        mov [si],ax

        mov [di],cx                     { pind[j]:=cx }

        pop cx
@NSwap: inc cx
        dec dx

@NBl:   cmp cx,dx                       { ... until i>j; }
        jle @Rep

        mov i,cx
        mov j,dx

        mov dx,hi                       { if i>=hi ==> @ChkLo }
        cmp cx,dx
        jge @ChkLo

        call @Push                      { Push(i,hi) }

@ChkLo: mov cx,lo                       { if lo>=j ==> @QSend }
        mov dx,j
        cmp cx,dx
        jge @QSend

        call @Push                      { Push(lo,j) }

@QSend: jmp @QS                         { loop while stack isn't empty }

@Empty: mov ah,49h
        int 21h
        jmp @exit

@index: shl ax,1                        { ax:=2*ax }
        add ax,bx
        mov di,ax
        push bx
        mov bl,soplt
        mov al,phix
        xor ah,ah
        mul bl
        add di,ax                       { di=2*index+SizeOf(polytype)+polyz }
        pop bx
        mov ax,[di]
        ret

@Push:  mov ah,48h                      { Push into stack }
        mov bx,1
        int 21h
        jc @exit
        mov bx,es
        mov es,ax
        mov es:[0],cx
        mov es:[2],dx
        mov es:[4],bx
        mov di,ax
        ret

@exit:
end;

Procedure Calc;
var z:pointype;
    spx,spy,spz,
    cpx,cpy,cpz,
    zd,x,y,i,j,k:integer;
    n,key,phiy,phiz:byte;
begin
 phix:=0;
 phiy:=0;
 phiz:=0;
 FillChar(xp,sizeof(xp),0);
 FillChar(yp,sizeof(yp),0);

 repeat

  spx:=sinus(phix);                     { 'Precookied' constanst }
  spy:=sinus(phiy);
  spz:=sinus(phiz);

  cpx:=cosinus(phix);
  cpy:=cosinus(phiy);
  cpz:=cosinus(phiz);

  for n:=0 to nofpoints do
   begin
    i:=(cpy*point[n,0]-spy*point[n,2]) div divd;
    j:=(cpz*point[n,1]-spz*i) div divd;
    k:=(cpy*point[n,2]+spy*point[n,0]) div divd;
    x:=(cpz*i+spz*point[n,1]) div divd;
    y:=(cpx*j+spx*k) div divd;
    z[n]:=(cpx*k-spx*j) div divd;
    zd:=z[n]-dist;
    xp[phix,n]:=(160+cpx)-(x*dist) div zd;
    yp[phix,n]:=(200+spz) div 2-(y*dist) div zd;
   end;

  for n:=0 to nofpolys do
   begin
    polyz[phix,n]:=(z[planes[n,0]]+z[planes[n,1]]+
                    z[planes[n,2]]+z[planes[n,3]]) div 4;
    pind[phix,n]:=n;
   end;

  QuickSort(0,nofpolys);
  inc(phix,xst);
  inc(phiy,yst);
  inc(phiz,zst);
 until phix=0;
end;

Procedure ShowObject;
var n:byte; pim:integer;
begin
 retrace;
 if address=0
 then address:=16000
 else address:=0;
 setaddress(address);
 cls;
 for n:=sc to nofpolys do
  begin
   pim:=pind[phix,n];
   polygon(xp[phix,planes[pim,0]],yp[phix,planes[pim,0]],
           xp[phix,planes[pim,1]],yp[phix,planes[pim,1]],
           xp[phix,planes[pim,2]],yp[phix,planes[pim,2]],
           xp[phix,planes[pim,3]],yp[phix,planes[pim,3]],
           polyz[phix,n]+30);
  end;
end;

Procedure Rotate;
var i:byte;
begin
 setmodex;
 address:=0;
 Triangles:=polypoints=3;
 for i:=1 to 80 do setpal(i,cr+i shr 1,cg+i shr 1,cb+i shr 1);
 setborder(63);
 repeat
  ShowObject;
  inc(phix,xst);
 until KeyPressed;
 setborder(0);
end;

var i:byte;
    s:stack;
    x,y:integer;

begin
 {border:=True;}
 if ParamCount=1
 then begin
       Val(ParamStr(1),xst,yst);
       if yst<>0 then Halt;
       zst:=-2*xst;
       yst:=xst;
      end;
 WriteLn('Wait a moment ...');
 Calc;
 Rotate;
 TextMode(LastMode);
end.

        But ... wait a moment ... you also need x3dUnit2.pas
        which is also included in the SWAG files

