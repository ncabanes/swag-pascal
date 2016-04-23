{
===========================================================================
 BBS: Canada Remote Systems
Date: 05-26-93 (00:24)             Number: 24154
From: SEAN PALMER                  Refer#: NONE
  To: ALL                           Recvd: NO
Subj: SCALING BITMAPS                Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
Don't know if anyone is interested, but here is some code to scale
bitmaps. I JUST now wrote it, and it's tested, but it hasn't even begun
to be optimized yet (that's why it's still postable in the Pascal Echo,
no .ASM stuff yet)  8)

works with VGA mode $13. }

type
 fixed=record case boolean of
        true:(l:longint);
        false:(f:word;i:integer);
        end;

procedure scaleBitmap(var bitmap;x,y:word;x1,y1,x2,y2:word);
var
 a,i:word;
 sx,sy,cy,s:fixed;
 map:array[0..65521]of byte absolute bitmap;
begin
 sx.l:=(x*$10000)div succ(x2-x1); sy.l:=(y*$10000)div succ(y2-y1);
 cy.i:=pred(y); cy.f:=$FFFF;
 while cy.i>=0 do begin
  a:=y2*320+x1;
  s.l:=(cy.i*x)*$10000;
  for i:=x2-x1 downto 0 do begin
   mem[$A000:a]:=map[s.i];
   inc(a);
   inc(s.l,sx.l);
   end;
  dec(cy.l,sy.l); dec(y2);
  end;
 end;

const
 bmp:array[0..3,0..3]of byte=
  ((0,1,2,3),
   (1,2,3,4),
   (2,3,4,5),
   (3,4,5,6));
var i:integer;

begin
 asm mov ax,$13; int $10; end;
 for i:=1 to 99 do
  scaleBitMap(bmp,4,4,0,0,i*2,i*2);
 asm mov ax,$3; int $10; end;
 end.
