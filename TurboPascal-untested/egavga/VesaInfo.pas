(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0190.PAS
  Description: VESA Info
  Author: PEDRO MIGUEL BORGES
  Date: 05-26-95  22:58
*)


{ Updated EGAVGA.SWG on May 26, 1995 }

{
  From: Pedro Miguel Borges

> Wow.  You sent me a lot of stuff there - thanks!
> Now I know how to get into to VESA modes, but I still can't seem to
> draw anywhere but the first 64k of memory. I don't understand how you
> would, say, draw a pixel at the way bottom, which when you calculate
> the offset, is much higher than 65536.  I greatly appreciate all the
> work you did putting in that code.

 One card with 1MB = 1024KB = 64h*16.
 Witch means that you have 16 Pages of 64Kb in RAM video.
 Your card, for example has 2 MB, so, you have 32 Pages of 64Kb.

 You code in Pascal, so see this code:
}
   case memmode of
     _p8:begin    { 256 Colors }
    l:=y*bytes+x;
    setbank(l shr 16);
    mem[vseg:word(l)]:=col;
  end;


   _p15,_p16:    { 32K, 64K Colors }
  begin
    l:=y*bytes+(x shl 1);
    setbank(l shr 16);
    memw[vseg:word(l)]:=col;
  end;

    _p24:begin    { 16M Colors }
    l:=y*bytes+(x*3);
    z:=word(l);
    m:=l shr 16;
    setbank(m);
    if z<$fffe then move(col,mem[vseg:z],3)
    else begin
      mem[vseg:z]:=lo(col);
      if z=$ffff then setbank(m+1);
      mem[vseg:z+1]:=lo(col shr 8);
      if z=$fffe then setbank(m+1);
      mem[vseg:z+2]:=col shr 16;
    end;
  end;

    _p32:begin    { 16M Colors + Brigth }
    l:=y*bytes+(x shl 2);
    setbank(l shr 16);
    meml[vseg:word(l)]:=col;
  end;

{
This way you can call a procedure that change your PAG RAM.

like this:
==========
}
        rp.bx:=0;
        bank:=bank*longint(64) div vgran;
        rp.dx:=bank;
        vio($4f05);
        rp.bx:=1;
        rp.dx:=bank;
        vio($4f05);
{

 JW> I did a call to interrupt 10h with AX set to 4F00h, to get the VESA
 JW> information. It worked and all <from what it says, I have VESA version
 1.2>, and the initialization worked <I could get into all those VESA
 JW> modes okay>, too, but I just can't draw outside the first 64k window.
 JW> How do you change pages <I think you change pages> to draw there?

 Yes thats it.

 You can use this code to change MODE:
 =====================================
}
  rp.bx:=md;
                vio($4f02);
  if rp.ax<>$4f then setmode:=false
                else begin
                  vesamodeinfo(md,NIL);
    chip:=__vesa;
  end;
{
whwre VIO is:
=============
}
procedure vio(ax:word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}
begin
  rp.ax:=ax;
  intr($10,rp);
end;
{
You can see info on that by:
============================
}
procedure vesamodeinfo(md:word;vbe1:_vbe1p);
const
  width :array[$100..$11b] of word=
      (640,640,800,800,1024,1024,1280,1280,80,132,132,132,132
      ,320,320,320,640,640,640,800,800,800,1024,1024,1024,1280,1280,1280);
  height:array[$100..$11b] of word=
      (400,480,600,600, 768, 768,1024,1024,60, 25, 43, 50, 60
      ,200,200,200,480,480,480,600,600,600, 768, 768, 768,1024,1024,1024);
  bits  :array[$100..$11b] of byte=
      (  8,  8,  4,  8,   4,   8,   4,   8, 0,  0,  0,  0,  0
      , 15, 16, 24, 15, 16, 24, 15, 16, 24,  15,  16,  24,  15,  16,  24);


var
  vbxx:_vbe1;
begin
  if vbe1=NIL then vbe1:=@vbxx;
  fillchar(vbe1^,sizeof(_vbe1),0);
  viop($4f01,0,md,0,vbe1);
  if ((vbe1^.attr and 2)=0) and (md>=$100) and (md<=$11b)
   then  (* optional info missing *)
  begin
    vbe1^.width :=width[md];
    vbe1^.height:=height[md];
    vbe1^.bits  :=bits[md];
  end;

  vgran :=vbe1^.gran;
  bytes :=vbe1^.bytes;
  pixels:=vbe1^.width;
  lins  :=vbe1^.height;
end;


Here is the TYPES:
==================

type
  intarr=array[1..100] of word;

  _vbe0=record
          sign  :longint;       {Must be 'VESA'}
          vers  :word;          {VBE version.}
          oemadr:chptr;
          capab :longint;
          model :^intarr;       {Ptr to list of modes}
          mem   :byte;          {#64k blocks}
          xx:array[0..499] of byte;   {Buffer is too large, as some cards
                                         can return more than 256 bytes}

l;

    case memmode of
       _pk2,
       _pl2:for x:=0 to 63 do
              for y:=0 to 63 do
                setpix(30+x,yst+y+50,y shr 3);
      _pk4,
       _pl4:for x:=0 to 127 do
              if lins<250 then
                for y:=0 to 63 do
                  setpix(30+x,yst+y+50,y shr 2)
              else
                for y:=0 to 127 do
                  setpix(30+x,yst+y+50,y shr 3);
        _p8:for x:=0 to 127 do
              if lins<250 then
                for y:=0 to 63 do
                  setpix(30+x,yst+50+y,((y shl 2) and 240) +(x shr 3))
              else
                for y:=0 to 127 do
                  setpix(30+x,yst+50+y,((y shl 1) and 240)+(x shr 3));
 
      _p15,_p16,_p24,_p32:
            if pixels<600 then
            begin
              for x:=0 to 63 do
              begin
                for y:=0 to 63 do
                begin
                  setpix(30+x,100+y,rgb(x*4,y*4,0));
                  setpix(110+x,100+y,rgb(x*4,0,y*4));
                  setpix(190+x,100+y,rgb(0,x*4,y*4));
                end;
              end;
              for x:=0 to 255 do
                for y:=170 to 179 do
                begin
                  setpix(x,y   ,rgb(x,0,0));
                  setpix(x,y+10,rgb(0,x,0));
                  setpix(x,y+20,rgb(0,0,x));
                end;
            end
            else begin
              for x:=0 to 127 do
                for y:=0 to 127 do
                begin
                  setpix( 30+x,120+y,rgb(x*2,y*2,0));
                  setpix(200+x,120+y,rgb(x*2,0,y*2));
                  setpix(370+x,120+y,rgb(0,x*2,y*2));
                end;
              for x:=0 to 511 do
                for y:=260 to 269 do
                begin
                  setpix(x,y   ,rgb(x shr 1,0,0));
                  setpix(x,y+10,rgb(0,x shr 1,0));
                  setpix(x,y+20,rgb(0,0,x shr 1));
                end;
            end;
 
    end;
end;

{░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}
Procedure InitVesa;
{░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}
var
vesarec:_vbe0;

begin
  viop($4f00,0,0,0,@vesarec);
  if (rp.ax=$4f) and (vesarec.sign=$41534556) then
  begin
    mm:=vesarec.mem*longint(64);
    name:=gtstr(vesarec.oemadr);
    version:=vesarec.vers
  end;
end;

{░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

