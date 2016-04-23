unit link;
{$o-,g-,d-,l-,y-,q-,r-,s-,t-,v-,x-,n-,e-,b-}

INTERFACE

type
  pstring=^string;
  pdata=^tdatarec;
  tdatarec=record
             name:pstring;
             size:byte;
           end;
  plink=^tlink;
  tlink=record
          prev,next:plink;
          data:pdata;
        end;

procedure inilink(var l:plink);
function  addlink(var l:plink;var d:pdata):boolean;
function  addlink2(var l:plink;var d:string):boolean;
procedure dellink(var l:plink);
procedure linkdata(var l:plink;var p:pdata);
function  linkdata2(var l:plink):string;
function  numlinks(var l:plink):longint;
procedure killink(var l:plink);

IMPLEMENTATION

procedure inilink(var l:plink);
begin
  l^.prev:=nil; l^.next:=nil; l^.data:=nil; l:=nil;
end;

function addlink(var l:plink;var d:pdata):boolean;
begin
  addlink:=false;
  if(memavail<(d^.size+16))then exit;
  if(l^.next=nil)then
  begin
    new(l^.next);
    l^.next^.next:=nil;
    l^.next^.prev:=l;
    new(l^.next^.data);
    getmem(l^.next^.data^.name,d^.size);
    l^.next^.data^.name^:='';
    l^.next^.data^.name^:=d^.name^;
{    l^.next^.data^.name^[0]:=d[0];}
    l^.next^.data^.size:=d^.size;
  end else
  begin
    freemem(l^.next^.data^.name,l^.next^.data^.size);
    getmem(l^.next^.data^.name,d^.size);
    l^.next^.data^.name^:=d^.name^;
    l^.next^.data^.size:=d^.size;
  end;
  addlink:=true;
  l:=l^.next;
end;

function addlink2(var l:plink;var d:string):boolean;
begin
  addlink2:=false;
  if(memavail<(succ(ord(d[0])))+16)then exit;
  if(l^.next=nil)then
  begin
    new(l^.next);
    l^.next^.next:=nil;
    l^.next^.prev:=l;
    new(l^.next^.data);
    getmem(l^.next^.data^.name,succ(ord(d[0])));
    l^.next^.data^.name^:='';
    l^.next^.data^.name^:=d;
    l^.next^.data^.name^[0]:=d[0];
    l^.next^.data^.size:=succ(ord(d[0]));
  end else
  begin
    freemem(l^.next^.data^.name,l^.next^.data^.size);
    getmem(l^.next^.data^.name,succ(ord(d[0])));
    l^.next^.data^.name^:=d;
    l^.next^.data^.size:=succ(ord(d[0]));
  end;
  addlink2:=true;
  l:=l^.next;
end;

procedure dellink(var l:plink);
var tmp:plink;
begin
  tmp:=l;
  if((tmp^.prev=nil)and(tmp^.next=nil))or(tmp^.data=nil)then exit;
  if(tmp^.prev<>nil)and(tmp^.next<>nil)then tmp^.prev:=tmp^.next;
  if(tmp^.prev<>nil)and(tmp^.next<>nil)then tmp^.next^.prev:=tmp^.prev;
  l:=tmp^.next;
  freemem(tmp^.data^.name,tmp^.data^.size);
  dispose(tmp^.data);
  dispose(tmp);
end;

procedure linkdata(var l:plink;var p:pdata);
begin
  if(p=nil)then
  begin
    new(p);
    new(p^.name);
  end;
  p^.name^:=l^.data^.name^;
end;

function linkdata2(var l:plink):string;
var tmp:string;
begin
{  tmp:=l^.data^.name^;
  linkdata2:=tmp;      }
  move(l^.data^.name^[1],tmp[1],succ(l^.data^.size));
  tmp[0]:=char(pred(l^.data^.size));
  linkdata2:=tmp;
end;

function numlinks(var l:plink):longint;
var
  tmp:plink;
  cnt:longint;
begin
  numlinks:=0;
  if(l=nil)then exit;
  tmp:=l;
  while(tmp^.prev<>nil)do tmp:=tmp^.prev;
  cnt:=1;
  while(tmp^.next<>nil)do
  begin
    inc(cnt);
    tmp:=tmp^.next;
  end;
  numlinks:=cnt;
end;

procedure killink(var l:plink);
var c:longint;
begin
  while(l^.prev<>nil)do l:=l^.prev;
  for c:=1 to numlinks(l)do dellink(l);
end;

end.