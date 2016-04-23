{
From: SEAN PALMER
Subj: transparent putimage
}

Procedure PutImg(x,y : integer;Var Img);
type
 AList = array[1..$FFFF] of Byte; {1-based arrays are slower than 0-based}
var
 APtr : AList;                   {I found a very fast way to do this: WITH}
 j,i,Width,Height,Counter : Word;
begin
 Aptr:=@Img;
 Width:=(Aptr[2] SHL 8) + Aptr[1]+1;  {these +1's that 1-based arrays }
 Height:=(Aptr[4] SHL 8) + Aptr[3]+1;  { require make for slower code}
 Counter:=5;
 For j:=y to (y+height-1) do begin  {try pre-calculating the offset instead}
  for i:=x to (x+width-1) do begin
   case Aptr[Counter] of          {CASE is probably not the way to do this}
    0:; (* do nothing *)
    else _mcgaScreen[j,i]:=Aptr[Counter]; (* plot it *)
    end;
   Inc(Counter);
   end;
  end;
 end;

ok, here's my try:

type pWord=word;

procedure putImg(x,y:integer;var image);
var
 anImg:record img:array[0..$FFF7]of byte; end absolute image;
 aScrn:record scrn:array[0..$FFF7]of byte; end absolute $A000:0000;
 width,height,counter,offs,src:word;
begin
 width:=pWord(@anImg[0]);
 height:=pWord(@anImg[2]);
 offs:=y*320+x;
 src:=4;   {skip width, height}
 with aScrn,anImg do repeat
  counter:=width;
  repeat
   if img[src]<>0 then scrn[offs]:=img[src];
   inc(src);
   inc(offs);
   dec(counter);
   until counter=0;
  inc(offs,320-width);
  dec(height);
  until height=0;
 end;


Those arrays-pretending-to-be-records above so they'll work with the WITH
statement should end up making BP keep the address in registers, making it
faster. In any case it won't be slower than yours. I'd appreciate you
timing them and letting me know the results. Actually, let me know if it
even compiles and works... 8)
