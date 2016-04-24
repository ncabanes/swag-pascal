(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0157.PAS
  Description: Travling Salesman Problem
  Author: PIERRE TOURIGNY
  Date: 09-04-95  10:29
*)


program citytour;
{modified anneal.pas in nrpas13.zip from the book Numerical Recipes}
{95-06-23 by Pierre Tourigny, pierre@panpan.synapse.net}
{solves the traveling salesman's problem by simulated annealing}
uses graph;
const
  title = 'Tour of 48 US Capitals';
  maxcity = 99; {maximum city index}
  maxstep = 100; {maximum number of temperature steps}
  tfactor = 0.9; {temperature step is 90% of previous step}
  radius = 3956.67; {average radius of the earth in miles}
  bgidir = 'c:\bp\bgi'; {directory of bgi drivers; change at need}
type
  city = record name: string[80]; lat,long: real; gx,gy: integer end;
  tdistances = array[0..maxcity,0..maxcity] of real;
var
  cities: array[0..maxcity] of city;
  tour: array[0..maxcity] of integer;
  path,delta,temperature,lowerbound: real;
  count,success,maxpath,maxsuccess,offcut,offlast,offsplice,
    first,last,cutafter,cutbefore,spliceafter,splicebefore,
    mx,my,grdriver,grmode: integer;
  distance: ^tdistances;

procedure usage;
begin
writeln;
writeln('Usage:   citytour <data file> <solution file>');
writeln;
writeln('Example: citytour us_cptl.dat us_cptl.sol');
writeln;
writeln('Data File Format:');
writeln('   at most 100 cities, one city per line;');
writeln('   line format: <city name>,<latitude>,'+
  '<longitude>,<other info (not used)>');
writeln('   latitude and longitude: degrees, minutes and hemisphere');
writeln('   Example: Salt Lake City,40 45 n,111 58 w,Utah,US');
halt;
end;

function dmc2r(degree,minute: real; hemi: string): real;
{degrees, minutes, hemisphere to radians}
begin
if hemi[1] in ['s','S','w','W'] then
  dmc2r := -(degree + minute/60.0)*pi/180.0
else dmc2r := (degree + minute/60.0)*pi/180.0;
end;

function gcd(i1,i2: integer): real;
{approximate great-circle distance in miles}
var
  dlat,dlong: real;
begin
with cities[i1] do begin
  dlat := abs(lat-cities[i2].lat);
  if dlat > pi then dlat := 2*pi-dlat;
  dlong := abs(long-cities[i2].long);
  if dlong > pi then dlong := 2*pi-dlong;
  gcd := radius*sqrt(sqr(dlat)+
    abs(sqr(dlong)*cos(lat)*cos(cities[i2].lat)));
  end;
end;

function split(var s : string; d : string) : string;
var
  i,minpos,dpos : byte;
  maxs : byte absolute s;  maxd : byte absolute d;

begin
minpos := succ(maxs);
for i := 1 to maxd do begin
  dpos := pos(d[i],s);
  if (dpos > 0) and (dpos < minpos) then minpos := dpos;
  end;
split := copy(s,1,pred(minpos));
s := copy(s,minpos+1,255);
end;

function fval(s: string): integer;
var i,code: integer;
begin val(s,i,code); fval := i end;

procedure findlow; {find lower bound for optimal solution}
{note: the lower bound is not the optimal length; it only
means that the best tour cannot be shorter}
var
  i,j: integer; mind1,mind2: real;
begin
lowerbound := 0.0;
for i := 0 to count-1 do begin
  mind1 := 1.0e38; mind2 := mind1;
  for j := 0 to count-1 do begin
    if i = j then continue;
    if distance^[i,j] < mind1 then begin
      mind2 := mind1;
      mind1 := distance^[i,j];
      end
    else if distance^[i,j] < mind2
      then mind2 := distance^[i,j];
    end;
  lowerbound := lowerbound+mind1+mind2;
  end;
lowerbound := lowerbound/2;
end;

procedure drawtour;
var
  i,j: integer;  s,sn: string;
begin
cleardevice;
outtext(title);
setcolor(white);
with cities[0] do moveto(gx,gy);
j := 0;
for i := 0 to count-1 do begin
  j := tour[j];
  with cities[j] do lineto(gx,gy);
  end;
setcolor(red); setfillstyle(solidfill,red);
j := 0;
for i := 0 to count-1 do begin
  with cities[j] do fillellipse(gx,gy,2,2);
  j := tour[j];
  end;
setcolor(white);
str(path:8:0,sn);        s := 'Path Length:'+sn;
str(temperature:8:0,sn); s := s+'      Temperature:'+sn;
str(success:6,sn);       s := s+'      Successful Moves:'+sn;
outtextxy(10,my-15,s);
end;

procedure init;
var
  i,j: integer; data: text; s: string;
  gxscale,gxmax,gyscale,gymax: real;
begin
if paramcount <> 2 then usage;
randomize;
fillchar(cities,sizeof(cities),0);
fillchar(tour,sizeof(tour),0);
assign(data,paramstr(1));
{$I-} reset(data); {$I+}
if ioresult <> 0 then begin
  writeln('Data file not found'); halt; end;
grdriver := detect;
initgraph(grdriver,grmode,bgidir);
mx := getmaxx; my := getmaxy;
gyscale := my*180.0/(25.0*pi); {map is 25 degrees tall}
gxscale := mx*180.0/(60.0*pi); {map is 60 degrees wide}
gymax := 50.0*pi/180.0; gxmax := 125.0*pi/180.0; {graph point 0,0}
count := 0;
while not eof(data) do begin
  readln(data,s);
  with cities[count] do begin
    name := split(s,',');
    lat := dmc2r(fval(split(s,' ')),fval(split(s,' ')),split(s,','));
    long := dmc2r(fval(split(s,' ')),fval(split(s,' ')),split(s,','));
    gx := trunc((gxmax+long)*gxscale);
    gy := trunc((gymax-lat)*gyscale);
    end;
  inc(count);
  end;
close(data);

if (count = 0) or (count > 100) then usage;
for i := 0 to count-1 do tour[i] := (i+1) mod count; {following city}
maxpath := 100*count; maxsuccess := 10*count; path := 0.0;
temperature := 1500.0 {miles};
new(distance); fillchar(distance^,sizeof(distance^),0);
for i := 0 to count-2 do for j := i+1 to count-1 do begin
  distance^[i,j] := gcd(i,j); distance^[j,i] := distance^[i,j];
  end;
findlow;
for i := 0 to (count-1) do path := path+distance^[i,(i+1) mod count];
drawtour;
end;

procedure findedges;
begin
offcut := random(count); {offset from 0}
offlast := random(count-2); {offset from first}
offsplice := random(count-offlast-2); {offset from cutbefore}
cutafter := 0;
while offcut > 0 do begin
  cutafter := tour[cutafter];
  dec(offcut);
  end;
first := tour[cutafter]; {first city of segment}
last := first; {last city of segment}
while offlast > 0 do begin
  last := tour[last];
  dec(offlast);
  end;
cutbefore := tour[last];
end;

procedure revcost; {difference in path length if segment reversed}
begin
delta := -distance^[cutafter,first]-distance^[last,cutbefore]
  +distance^[cutafter,last]+distance^[first,cutbefore];
end;

procedure reverse;
var
  i,next,after: integer;
begin
tour[cutafter] := last;
i := first; after := cutbefore;
repeat
  next := tour[i];
  tour[i] := after;
  after := i;
  i := next;
  until i = cutbefore;
end;

procedure transcost; {difference due to transporting segment}
begin
delta :=
  -distance^[cutafter,first]-distance^[last,cutbefore]
  -distance^[spliceafter,splicebefore]+distance^[cutafter,cutbefore]
  +distance^[spliceafter,first]+distance^[last,splicebefore];
end;

procedure transport;
begin
tour[cutafter] := cutbefore;
tour[spliceafter] := first;
tour[last] := splicebefore;
end;

function metropolis: boolean;
begin
if delta < 0 then metropolis := true
else metropolis := random < exp(-delta/temperature);
end;

procedure anneal;
var
  i,j,k: integer;
begin
for j := 1 to maxstep do begin
  success := 0;
  for k := 1 to maxpath do begin
    findedges;
    if random(2) = 1 then begin {reverse segment}
      revcost;
      if metropolis then begin
        inc(success); path := path+delta; reverse;
        end
      end
    else begin {transport segment somewhere else}
      spliceafter := cutbefore;
      while offsplice > 0 do begin
        spliceafter := tour[spliceafter];
        dec(offsplice);
        end;
      splicebefore := tour[spliceafter];
      transcost;

      if metropolis then begin
        inc(success); path := path+delta; transport;
        end;
      end;
    if success >= maxsuccess then break;
    end;
  drawtour;
  temperature := temperature*tfactor;
  if success = 0 then break;
  end;
end;

procedure report;
var
  i: integer;  d,p: real;  solution: text;
begin
assign(solution,paramstr(2));
rewrite(solution);
i := 0; p := 0.0;
writeln('City':20,'Distance (miles)':20,'Cumulative':20);
writeln(solution,'City':20,'Distance (miles)':20,'Cumulative':20);
writeln(solution);
repeat
  d := distance^[i,tour[i]]; p := p + d;
  writeln(cities[i].name:20,d:20:0,p:20:0);
  writeln(solution,cities[i].name:20,d:20:0,p:20:0);
  i := tour[i];
  until i = 0;
writeln('Lower bound on optimal solution: ',lowerbound:8:0);
writeln(solution,'Lower bound on optimal solution: ',lowerbound:8:0);
close(solution);
end;

begin
init;
anneal;
closegraph;
report;
dispose(distance);
end.

