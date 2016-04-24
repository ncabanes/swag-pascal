(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0053.PAS
  Description: Flood Filling
  Author: SEAN PALMER
  Date: 01-27-94  12:11
*)

{
> Does anyone have any code to flood fill an area? I need the code to do
> both, a fill to a certain border colour, or a fill to ANY
> colour other then the one the fill started on.
}

var fillVal:byte;
{This routine only called by fill}
function lineFill(x,y,d,prevXL,prevXR:integer):integer;
 var xl,xr,i:integer;
begin
 xl:=x;xr:=x;
 repeat dec(xl); until(scrn(xl,y)<>fillVal)or(xl<0); inc(xl);
 repeat inc(xr); until(scrn(xr,y)<>fillVal)or(xr>xMax); dec(xr);
 hLin(xl,xr,y);
 inc(y,d);
 if word(y)<=yMax then
  for x:=xl to xr do
   if(scrn(x,y)=fillVal)then begin
    x:=lineFill(x,y,d,xl,xr);
    if word(x)>xr then break;
    end;
 dec(y,d+d); asm neg d;end;
 if word(y)<=yMax then begin
  for x:=xl to prevXL do
   if(scrn(x,y)=fillVal)then begin
    i:=lineFill(x,y,d,xl,xr);
    if word(x)>prevXL then break;
    end;
  for x:=prevXR to xr do
   if(scrn(x,y)=fillVal)then begin
    i:=lineFill(x,y,d,xl,xr);
    if word(x)>xr then break;
    end;
  end;
 lineFill:=xr;
 end;

procedure fill(x,y:integer);begin
 fillVal:=scrn(x,y);if fillVal<>color then lineFill(x,y,1,x,x);
 end;

{
This one's too recursive for anything really complicated (blows the stack). But
it works. You'll find that making it do a border fill instead isn't hard at
all. You'll need to provide your own hLin and scrn routines.

hLin draws a horizontal line from X,to X2,at Y scrn reads the pixel at X,Y and
returns its color color is a global byte variable in this incarnation. The fill
happens in this color.
}

