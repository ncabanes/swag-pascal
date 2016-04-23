{
I recently made a SCROLLBAR object. it's pretty good and draws it's strings
directly to videomemory so no flashing etc.
}

UNIT scroller;

{ scrolbar.init(left, top, maxright, maxbottom, startvalue)
 if maxright and maxbottom are high enough
 the windowsize will be adjusted automatically to
 the longest string in the data-array.
 Mind that the scroller stops counting as soon as
 an empty string is encountered, and everything below
 it will not be displayed.
 in order to save memory your application may write
 directly to scrollbar.data.

 scrollbar.return contains the return value, i.e. the index
 of the chosen element in the data-array.

  scroll.bar.incr/decr take an integer and increases/decreases
 scrollbar.return

  scrollbar.update should be called after each scrollbar.incr/decr
 to display the changes.

  scrollbar.borderhit is a boolean that becomes true
 when the user attempts to go past the first/last item in
 the list. This should be used BEFORE scrollbar.update, as
 that procedure sets both booleans to False.
  scrollbar.stop closes the window and restores the screen.

  willem van de vis
  s0730076@let.rug.nl

}

Interface

const max = 200;
      maxwidth = 20;
type
   scrolldata = array[1..max] of string[maxwidth];

type Scrollbar =
  object
   private {erase private and public for tp6.0}
    top,
    bottom,
    left,
    right,
    total,
    width,
    len,
    y,
    b  : integer;
    public
    data : scrolldata;
    return : integer;
    borderhit: boolean;
                constructor init(ileft,itop, iright,ibottom,iq: integer);

    destructor  stop;
    procedure   update;
    procedure   incr(i : integer);
    procedure   decr(d : integer);
   end;

Implementation
uses win, crt;

constructor scrollbar.init;
var q : integer;
begin

 if ibottom > 24 then ibottom := 24;
 if itop < 2 then itop := 1;
 if ileft < 2 then ileft := 1;
 if iright > 78 then iright := 78;

    return := 1;
    b      := 1;
    y      := 1;
 bottom := ibottom;
 top    := itop;
 len    := (bottom - top)+1;
 left   := ileft-1;
 right  := iright;
 borderhit := false;
 total := 1;
 width := 1;

 while (total <= max) and (data[total] <> '') do
 begin
  if length(data[total]) > width then width := length(data[total]);
  data[total] := data[total] +
 '                                                                   ';
  inc(total);
 end;
 dec(total);
 if total = 0 then total := 1;
    if width < right - ileft then right := left + width
      else width := right-ileft;
      dec(right);
      if total < bottom - itop then bottom := itop + total-1;
      open_win(ileft, itop, right, bottom, lightgray, blue);
    if iq > 1 then
    scrollbar.incr(iq-1);
end;

destructor scrollbar.stop;
begin
 close_win;
end;

procedure scrollbar.decr;
begin
 if return - d < 1 then
  d := return-1;
  dec(return,d);
  if (y - d < 1) then
  begin
   b := return;
   y := 1;
  end
  else
    dec(y,d);

  if d = 0 then borderhit := true;
end;

procedure scrollbar.incr;
begin
 if return + i > total then
 i := total - return;

  inc(return,i);
  if (y + i > len) then
  begin
  b := 1 + return - len;
   y := len;
  end
  else
    inc(y,i);
 if i = 0 then borderhit := true;
end;


procedure scrollbar.update;
var i : integer;
begin
 borderhit := false;
 for i := b  to b + len-1 do
  if i <= total then

   if i - b + 1 = y then
     writeline(data[i],left, top+i-b, width, white,black)
    else
     writeline(data[i],left, top+i-b, width, lightgray,blue);

end;

end.

Mind that no pointers are used so there IS a max to the number of lines
displayed. It may be neccesary to adjust width en right etc.

an example of an application:

uses scroller,ill,crt,win;

var scrol  : scrollbar;
 r   : char;
 chosen : string;
 F  : TEXT;
 q  : integer;

begin

assign(f, paramstr(1));
reset(f);
q := 1;

while (not eof(f)) and (q < 500) do
begin
 readln(f,scrol.data[q]);
 if scrol.data[q] <> '' then
 inc(q);
end;
close(f);

ini_win;

scrol.init(2,2,80,18,1);

r := '!';



while (r <> chr(13)) and (r <> chr(27)) do
begin

 if scrol.borderhit then brom;
 scrol.update;
 r := readkey;
 case r of
  chr(72) : scrol.decr(1);
  chr(80) : scrol.incr(1);
  chr(73) : scrol.decr(10);
  chr(81) : scrol.incr(10);

 end;


end;

chosen := scrol.data[scrol.return];
scrol.stop;
if r <> chr(27) then
begin
 writeln(chosen);
end;
end.
