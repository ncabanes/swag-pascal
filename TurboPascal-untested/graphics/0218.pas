uses crt,gru,lines;  { GRU in GRAPHICS.SWG .. see end for lines }

const
  col=1;
  dc1=10;

var
  vseg:word;
  virt:pointer;
  work,grav,dist:coords;
  timer:longint absolute $0040:$006c;
  frame,t1,t2:longint;

procedure plotem(c0:coords);
begin
  with c0 do
  begin
    line2(a1,a2,d1,d2,vseg,col);
    line2(d1,d2,c1,c2,vseg,col);
    line2(c1,c2,b1,b2,vseg,col);
    line2(b1,b2,a1,a2,vseg,col);
  end;
end;

procedure animate;
begin
  clear386(vseg,0);
  plotem(work);
  flip386(vseg,vidseg);
end;

procedure morfun;
var
  cnt:longint;
  d:boolean;
begin
  repeat
    mutate(work);
    distort(work);
    morphit(work,grav);
    mutate(work);
    distort(work);
    morphit(work,dist);
    animate;
    inc(frame);
  until(keypressed);
  readkey;
end;

var
  y:word;

begin
  clipon:=true;
  randomize;
  randfig(work);
  randfig(dist);
  with grav do
  begin
    a1:=160; a2:=99; b1:=165; b2:=105;
    c1:=180; c2:=115; d1:=150; d2:=85;
  end;
  setmode($13);
  getmem(virt,64000);
  vseg:=seg(virt^);
  frame:=0;
  t1:=timer;
  morfun;
  t2:=(timer-t1);
  setmode($03);
  writeln(round((frame*18.2)/t2),' fps.');
end.

{ -----------------------  LINES ---------------------- }
unit lines;

INTERFACE

type
  coords=record
           a1,a2,b1,b2,c1,c2,d1,d2:word;
         end;

function morphit(var c0:coords;c02:coords):boolean;
procedure distort(var c0:coords);
procedure mutate(var c0:coords);
procedure randfig(var c0:coords);

IMPLEMENTATION

function figure(var a,b:word):boolean;
begin
  figure:=false;
  if(a<>b)then
  begin
    if(a>b)then dec(a)else inc(a);
    exit;
  end;
  { We'll end up here if a=b. }
  figure:=true;
end;

function morphit(var c0:coords;c02:coords):boolean;
begin
  morphit:=false;
  with c0 do
  begin
    {$b+}  { We need FULL boolean evalution for this little trick :-) }
    if(figure(a1,c02.a1))and
    (figure(a2,c02.a2))and
    (figure(b1,c02.b1))and
    (figure(b2,c02.b2))and
    (figure(c1,c02.c1))and
    (figure(c2,c02.c2))and
    (figure(d1,c02.d1))and
    (figure(d2,c02.d2))then morphit:=true;
    {$b-}
  end;
end;

procedure distort(var c0:coords);
var amount:byte;
begin
  amount:=random(3);
  with c0 do
  begin
    if(random(2)=1)and(a1+amount<319)then inc(a1,amount)else if(a1>amount)then dec(a1,amount);
    if(random(2)=1)and(b1+amount<319)then inc(b1,amount)else if(b1>amount)then dec(b1,amount);
    if(random(2)=1)and(c1+amount<319)then inc(c1,amount)else if(c1>amount)then dec(c1,amount);
    if(random(2)=1)and(d1+amount<319)then inc(d1,amount)else if(d1>amount)then dec(d1,amount);
    if(random(2)=1)and(a2+amount<319)then inc(a2,amount)else if(a2>amount)then dec(a2,amount);
    if(random(2)=1)and(b2+amount<319)then inc(b2,amount)else if(b2>amount)then dec(b2,amount);
    if(random(2)=1)and(c2+amount<319)then inc(c2,amount)else if(c2>amount)then dec(c2,amount);
    if(random(2)=1)and(d2+amount<319)then inc(d2,amount)else if(d2>amount)then dec(d2,amount);
  end;
end;

procedure mutate(var c0:coords);
begin
  with c0 do
  begin
    case random(20) of
      2: if(a1<314)then inc(a1,random(5));
      4: if(b1<314)then inc(b1,random(5));
      6: if(c1<313)then inc(c1,random(6));
      8: if(d1<313)then inc(d1,random(6));
      10:if(a1>8)then dec(a1,random(7));
      12:if(b1>8)then dec(b1,random(7));
      14:if(c1>9)then dec(c1,random(8));
      16:if(d1>9)then dec(d1,random(8));
    end;
  end;
end;

procedure randfig(var c0:coords);
begin
  with c0 do
  begin
    a1:=random(100); a2:=random(50);
    b1:=succ(a1)+random(220); b2:=random(50);
    c1:=160+random(160); c2:=succ(b2)+random(150);
    d1:=random(160); d2:=succ(a2)+random(150);
  end;
end;

end.