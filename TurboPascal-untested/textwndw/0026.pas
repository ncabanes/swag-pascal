unit txtwin;

INTERFACE

type
  psave=^tsave;
  tsave=record
          x1,y1,x2,y2:word;
          saved:pointer;
          active:boolean;
        end;
  wintype=array[1..6]of char;
  pwin=^twin;
  twin=record
         x1,y1,x2,y2:word;
         f1,b1:byte;
         screen:psave;
         active:boolean;
         wint:wintype;
       end;
const
  normal:wintype=('┌','┐','└','┘','─','│');
  double:wintype=('╔','╗','╚','╝','═','║');

procedure initback(var sav:psave);
procedure saveback(var sav:psave;xx1,yy1,xx2,yy2:word);
procedure resback(var sav:psave);
procedure initwin(var win:pwin);
procedure drawwin(var win:pwin; xx1,yy1,xx2,yy2:word; ff1,bb1:byte;wt:wintype);
procedure shade(x1,x2,y:word);
procedure closewin(var win:pwin);
procedure redrawwin(var win:pwin);

IMPLEMENTATION

procedure initback(var sav:psave);
begin
  with sav^ do
  begin
    active:=false;
    x1:=0; y1:=0; x2:=0; y2:=0;
  end;
end;

procedure saveback(var sav:psave;xx1,yy1,xx2,yy2:word);
var
  y,w,o:word;
begin
  with sav^ do
  begin
    if(active)then exit;
    x1:=xx1; y1:=yy1;
    x2:=xx2; y2:=yy2;
    w:=succ(x2-x1)*2;
    getmem(saved,w*succ(y2-y1));
    active:=true;
    o:=0;
    for y:=y1 to y2 do
    begin
      move(mem[segb800:pred(y)*160+pred(x1)],mem[seg(saved^):ofs(saved^)+o],w);
      inc(o,w);
    end;
  end;
end;

procedure resback(var sav:psave);
var y,w,o:word;
begin
  with sav^ do
  begin
    if not(active)then exit;
    w:=succ(x2-x1)*2;
    o:=0;
    for y:=y1 to y2 do
    begin
      move(mem[seg(saved^):ofs(saved^)+o],mem[segb800:pred(y)*160+pred(x1)],w);
      inc(o,w);
    end;
    freemem(saved,w*succ(y2-y1));
    active:=false;
    x1:=0; y1:=0; x2:=0; y2:=0;
  end;
end;

procedure initwin(var win:pwin);
begin
  with win^ do
  begin
    x1:=0; y1:=0; x2:=0; y2:=0;
    f1:=0; b1:=0;
    active:=false;
    wint:=normal;
  end;
end;

function buildstr(const ch:char;const num:byte):string; assembler;
asm
  xor ch,ch
  mov al,[num]
  mov cl,al
  les di,@result
  stosb
  jcxz @@exit
  mov al,[&ch]
  mov ah,al
  shr cl,1
  rep stosw
  adc cl,cl
  rep stosb
  @@exit:
end;

procedure str2scr(const s:string;const x,y:word;const c:byte); assembler;
asm
  push ds
  dec [x]
  dec [y]
  mov es,segb800
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  add di,[x]
  shl di,1
  lds si,s
  xor ch,ch
  mov cl,ds:[si]
  inc si
  mov ah,[c]
 @@loop:
   lodsb
   stosw
   loop @@loop
 @@exit:
 pop ds
end;

procedure drawwin(var win:pwin; xx1,yy1,xx2,yy2:word; ff1,bb1:byte;wt:wintype);
var
  tmp:string;
  cnt:byte;
begin
  with win^ do
  begin
    if(active)then exit;
    active:=true;
    initback(screen);
    x1:=xx1; y1:=yy1;
    x2:=xx2; y2:=yy2;
    f1:=ff1; b1:=bb1;
    saveback(screen,x1,y1,x2,y2);
    wint:=wt;
  end;
  tmp:=''; tmp:=wt[1];
  if((xx2-xx1)>2)then tmp:=concat(tmp,buildstr(wt[5],pred(xx2-xx1)));
  tmp:=concat(tmp,wt[2]);
  str2scr(tmp,xx1,yy1,(bb1 shl 4)+ff1);
  tmp[1]:=wt[3]; tmp[ord(tmp[0])]:=wt[4];
  str2scr(tmp,xx1,yy2,(bb1 shl 4)+ff1);
  tmp:=''; tmp:=wt[6];
  if((xx2-xx1)>2)then tmp:=concat(tmp,buildstr(' ',pred(xx2-xx1)));
  tmp:=concat(tmp,wt[6]);
  if((yy2-yy1)>2)then
  begin
    for cnt:=1 to pred(yy2-yy1)do
      str2scr(tmp,xx1,yy1+cnt,(bb1 shl 4)+ff1);
  end;
end;

procedure shade(x1,x2,y:word); assembler;
asm
  mov es,segb800
  dec [x1]
  dec [y]
  mov cx,[x2]
  sub cx,[x1]
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  shl di,1
  add di,[x1]
  add di,[x1]
  inc di
  @@loop:
    mov al,es:[di]
    sub al,112
    mov es:[di],al
    add di,2
    dec cx
    jnz @@loop
end;

procedure closewin(var win:pwin);
begin
  with win^ do
  begin
    if not(active)then exit;
    active:=false;
    x1:=0; y1:=0; x2:=0; y2:=0;
    f1:=0; b1:=0;
    resback(screen);
    wint:=normal;
  end;
end;

procedure redrawwin(var win:pwin);
var
  tmp:string;
  c:byte;
begin
  with win^ do
  begin
    if not(active)then exit;
    tmp:=''; tmp:=wint[1];
    if((x2-x1)>2)then tmp:=concat(tmp,buildstr(wint[5],pred(x2-x1)));
    tmp:=concat(tmp,wint[2]);
    str2scr(tmp,x1,y1,(b1 shl 4)+f1);
    tmp[1]:=wint[3]; tmp[ord(tmp[0])]:=wint[4];
    str2scr(tmp,x1,y2,(b1 shl 4)+f1);
    tmp:=''; tmp:=wint[6];
    if((x2-x1)>2)then tmp:=concat(tmp,buildstr(' ',pred(x2-x1)));
    tmp:=concat(tmp,wint[6]);
    if((y2-y1)>2)then
    begin
      for c:=1 to pred(y2-y1)do
        str2scr(tmp,x1,y1+c,(b1 shl 4)+f1);
    end;
  end;
end;

begin
end.