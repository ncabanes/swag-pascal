unit screens;

{
  Written by Kevin Epstein

  I was recently working on an assignment for school and I needed to come
  up with a way to save a portion of the screen so I could over write that
  piece of screen and then restore it later.

  Generally simple code is good code so the following code for saving and
  restoring portions of the screen is reasonably simple to understand.

  The following unit allows you to save a portion of screen to memory and
  then later restore that screen. NOTE. The size of the image should not
  be larger than 64K since GETIMAGE cannot handle anything that requires
  64K or more. If you do try to save a screen too large your system will
  probably hang. Rememmber that all the screens are saved to memory, so 
  be sure to restore screens as soon as possible to free up memory.

  This code may be used and distributed freely.
  If you would like to contact me, you can either E - Mail me at KEP@USA.NET
  or write to me at :

  P.O.Box 2896
  Edenvale
  1610
  South Africa

P.S works better than Edelmans saving to file, ha ha ha }

interface

uses graph;

var memarr : array[1..10] of word;
    parr   : array[1..10] of pointer;

function checkmem(index : integer) : boolean;
procedure savexy(x,y,x1,y1,index : integer);
procedure restorexy(x,y,index : integer);

implementation

function checkmem;
var result : word;
    i      : integer;
begin
     result := 0;
     for i := 1 to index do
         result := result + memarr[index];
     if result < (memavail - 65536) then checkmem := true {reserve 64K}
     else
     checkmem := false;
end;

procedure savexy;
begin
     memarr[index] := imagesize(x,y,x1,y1);
     if not checkmem(memarr[index]) then exit; {trap for no memory}
     getmem(parr[index],memarr[index]);
     getimage(x,y,x1,y1,parr[index]^);
end;


procedure restorexy;
begin
     putimage(x,y,parr[index]^,normalput);
     release(parr[index]);
     parr[index] := nil;
     memarr[index] := 0;
end;

end.
