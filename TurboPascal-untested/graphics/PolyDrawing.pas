(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0060.PAS
  Description: Poly Drawing
  Author: SEAN PALMER
  Date: 01-27-94  12:18
*)

(*
> It's not that slow. I can get about 60 good-sized
> poly's in a second on my dinky 386sx-20. It also does
> ^ ^ ^^ ^^ ^^^^^^^^^^^^^^^^^^^^^^^^
> I don't know what a good speed is for polyfills, but this sounds quite
> good! Thanks heaps (and stacks?  :^) for the post!

You're welcome. I just now converted it to 99% assembler, 386+, just gotta
test it out.

> One question to follow:

> {  fillWord(mem[$A000:0],64000,0);  {clear}
> ^^^                                ^stick closer ("}") here

> You'll probably recognize the above as the main routine of the polygon
> fill snippet (the tester part).  Please note the part I under-careted
> (or -caretted).  There is no closing comment before the next opening
> comment. Should the closer be placed where indicated by me?  Or
> was the opener a typo?
> Not a big deal, but I want this to work so I can be impressed!  :^)

It works like that, at least in TP/BP. The open comment in effect keeps the
compiler from ever seeing the next open brace. So the second brace's closing
brace actually closes the first one. A trick I learned since I started at
deltaComm. No, I actually wanted that commented out, because clearing the
screen between each one slows it down.

Actually, I noticed a strange behaviour in the fill, where if you have one
vertex = (x,y) and the next vertex = (x+40,y+1) then you'll end up with a dot
on one line and the next line entirely filled. Not what was intended. I came up
with a fix for it:

It basically just centers the stairstep zigzag by adding half a step before it
starts.
*)

function lSar(L:longint):longint;assembler;asm
 db $66; mov ax,L       {mov eax,L}
 db $66; sar ax,1       {sar eax,1}
 db $66,$0F,$A4,$C2,$10 {shld edx,eax,16}
 end;


procedure draw(color:byte);
var i,l,r,lv,rv,top,bottom,topVert:integer; var lstep,lpos,rstep,rpos:fixed;
var ldest,rdest:tPoint; begin
 {find top and bottom vertices}
 topVert:=numVerts-1;
 top:=vertex[topVert].y; bottom:=top;
 for i:=numVerts-2 downto 0 do
   if (vertex[i].Y < top) then begin
    top:=vertex[i].Y;
    topVert:=i;
    end
   else if (vertex[i].Y > bottom) then
    bottom:=vertex[i].Y;
 if bottom>maxY then bottom:=maxY;       {clip bottom}
 if top>bottom then exit;
 lv:=topVert; rv:=topVert;
 ldest:=vertex[topVert]; rdest:=ldest;
 i:=top;
 repeat
  if i<bottom then begin

{
^^^^^^^^^^^^^^^^^^^^^^^^^ keep from getting wierd effects from the
                          adjustment on the last row.
}
   if i>=ldest.y then begin
    lpos.f:=0; lpos.i:=ldest.x;
    dec(lv); if lv<0 then lv:=numVerts-1;
    ldest:=vertex[lv];
    if ldest.y=i then begin
      if ldest.x<lpos.i then lpos.i:=ldest.x;
      lstep.l:=0;
      end
    else begin
      lstep.l:=fixedDiv(ldest.x-lpos.i,ldest.y-i);
      inc(lpos.l,lSar(lstep.l));

      ^^^^^^^^^^^^^^^^^^^^^^^^^^  Center the stairstep pattern

      end;
    end;
   if i>=rdest.y then begin
    rpos.f:=0; rpos.i:=rdest.x;
    inc(rv); if rv>=numVerts then rv:=0;
    rdest:=vertex[rv];
    if rdest.y=i then begin
      if rdest.x>rpos.i then rpos.i:=rdest.x;
      rstep.l:=0;
      end
    else begin
      rstep.l:=fixedDiv(rdest.x-rpos.i,rdest.y-i);
      inc(rpos.l,lSar(rStep.l));

      ^^^^^^^^^^^^^^^^^^^^^^^^^^  Center the stairstep pattern

      end;
    end;
   end;
  if i>=minY then begin                             {clip top}
   if lpos.i>minX then l:=lpos.i else l:=minX;      {clip left}
   if rpos.i<maxX then r:=rpos.i else r:=maxX;      {clip right}
   if (l<=r) then
    fillWord(mem[$A000:i*320+l],r-l+1,color);
   end;
  inc(lpos.l,lstep.l);
  inc(rpos.l,rstep.l);
  inc(i);
  until i>bottom;
 end;

