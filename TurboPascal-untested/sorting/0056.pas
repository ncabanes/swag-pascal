{
From: pierre.tourigny@bbs.synapse.net (Pierre Tourigny)

> I'm looking for an external sort procedure in TP 6 / 7 which allows me
> to sort a file containing 20,000 records of the following type:
> RECORD
>   Phone : String[8];
>   L_Name : String[27];
>   F_Name : String[27];
> END;
> It must sort on Phone#. I could write it myself but I really need it
> in a hurry, so if anyone out there has an old sort procedure that I
> could modify to my own needs, I'd really apriciate it. Speed is of no
> importance.

Here's a modified merge sort that I used to sort a list of 260,000
words. It takes little memory and it's a fast O(NlogN) procedure. The
modification is that it goes external at k=1024 instead of at k=1.
}
program dictri;
{94-11-10, Pierre Tourigny, pierre.tourigny@bbs.synapse.net}
uses strings;

const
  k1 = 1024;
  strentree : string = 'c:\bp\bin\pas\diko2.dpt';
  strsortie : string = 'c:\bp\bin\pas\diko2.new';
type
  tmot = array[0..62] of char;
var
  source,ff1,ff2,fg1,fg2 : text;
  sourcebuf,ff1buf,ff2buf,fg1buf,fg2buf : array[0..4095] of char;
  k,maxmot : longint;
  fini : boolean;

procedure init;
begin
assign(source,strentree); settextbuf(source,sourcebuf); reset(source);
assign(ff1,'$f1$'); settextbuf(ff1,ff1buf); rewrite(ff1);
assign(ff2,'$f2$'); settextbuf(ff2,ff2buf); rewrite(ff2);
assign(fg1,'$g1$'); settextbuf(fg1,fg1buf); rewrite(fg1);
assign(fg2,'$g2$'); settextbuf(fg2,fg2buf); rewrite(fg2);
maxmot := 0;
fini := false;
end;

procedure passe1;
type
  tmots = array[0..k1] of tmot;
  pmots = ^tmots;
var
  i,j : integer;
  item : pmots;
  switch : boolean;

  Procedure inSort(item : pmots; last : integer);
  var
    i,j,span : integer;
  begin
  span := last shr 1;
  while span > 0 do begin
    for i := span to last-1 do begin
      for j := (i-span+1) downto 1 do
        if strcomp(item^[j],item^[j+span]) <= 0 then break
        else begin
          strcopy(item^[0],item^[j]);
          strcopy(item^[j],item^[j+span]);
          strcopy(item^[j+span],item^[0]);
          end;
      end;
    span := span shr 1;
    end;
  end;

begin
new(item);
fillchar(item^,sizeof(item^),0);
switch := true;
while not eof(source) do begin
  j := 0;
  for i := 1 to k1 do begin
    inc(j);
    readln(source,item^[i]);
    if eof(source) then break;
    end;
  inc(maxmot,j);
  insort(item,j);
  for i := 1 to j do if switch then writeln(ff1,item^[i])
    else writeln(ff2,item^[i]);
  switch := not switch;
  end;
dispose(item);
close(source);
writeln('Passe  1 termin,e    Nombre de mots: ',maxmot);
end;

procedure merge (lek : longint; var f1,f2,g1,g2 : text);
var
  outswitch : boolean;
  winner : integer;
  used : array[1..2] of longint;
  fin : array[1..2] of boolean;
  current : array[1..2] of tmot;
  numg1,numg2 : longint;

  procedure getrecord (i : integer);
  begin
  if (used[i] = lek) or ((i = 1) and eof(f1)) or
    ((i = 2) and eof(f2)) then fin[i] := true
  else begin
    inc(used[i]);
    if i = 1 then readln(f1,current[1])
    else readln(f2,current[2]);
    end;
  end;

begin
outswitch := true;
flush(g1); rewrite(g1);
flush(g2); rewrite(g2);
flush(f1); reset(f1);
flush(f2); reset(f2);
numg1 := 0; numg2 := 0;
while not eof(f1) or not  eof(f2) do begin
  fillchar(used,sizeof(used),0);
  fillchar(fin,sizeof(fin),false);
  fillchar(current,sizeof(current),0);
  getrecord(1); getrecord(2);
  while not fin[1] or not fin[2] do begin
    if fin[1] then winner := 2
    else if fin[2] then winner := 1
    else if strcomp(current[1],current[2]) < 0 then winner := 1
    else winner := 2;
    if outswitch then begin
      writeln(g1,current[winner]);
      inc(numg1);
      end
    else begin
      writeln(g2,current[winner]);
      inc(numg2);
      end;
    getrecord(winner);
    end;
  outswitch := not outswitch;
  end;
fini := numg2 = 0;
end;

procedure externe;
var
  i : integer;
  switch : boolean;
begin
i := 1;
k := k1;
switch := true;
while not fini {maxmot > k} do begin
  inc(i);
  write('Passe ',i:2,'  (k = ',k:7,')');
  if switch then merge(k,ff1,ff2,fg1,fg2)
  else merge(k,fg1,fg2,ff1,ff2);
  writeln(' termin,e');
  switch := not switch;
  k := k * 2;
  end;
close(ff2); erase(ff2);
close(fg2); erase(fg2);
close(ff1);
close(fg1);
assign(ff2,strsortie);
{$I-}
reset(ff2);
{$I+}
if ioresult = 0 then erase(ff2);
if switch then begin
  rename(ff1,strsortie);
  erase(fg1);
  end
else begin
  rename(fg1,strsortie);
  erase(ff1);
  end;
end;

begin {main}
init;
passe1;
externe;
end.
