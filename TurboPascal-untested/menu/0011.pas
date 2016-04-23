unit iface; { INTERFACE, for creating TEXT interfaces. }

INTERFACE

uses crt,dos,link,txtwin;
     { NOTE : Link in POINTERS.SWG
              txtwin in TEXTWNDW.SWG }

const
  kbnull=#0;
  kbesc=#27;
  kbpgup=#73;
  kbpgdown=#81;
  kbhome=#71;
  kbend=#79;
  kbleft=#75;
  kbright=#77;
  kbup=#72;
  kbdown=#80;
  kbf1=#59;
  kbenter=#13;
  kbdel=#83;
  kbbackspace=#8;
  colseg:word=$b800;
type
  tchok=set of char;

function  getkey(const s:string;const chok:tchok):char;
function  getstring(col,x,y,max:byte;legalch:tchok):string;
procedure xorbar(x1,x2,y:word;c:byte);
function  selectbar(xp,yp,x2,num,col,ystart:byte;abort:boolean):byte;
function  selectfile(wildcard:string;x,y,col:byte;abort:boolean):string;

IMPLEMENTATION

var
  dirlink:plink;
  dirinfo:searchrec;

function getkey(const s:string;const chok:tchok):char;
var ch:char;
begin
  write(s);
  repeat
    ch:=readkey;
  until(ch in chok);
  getkey:=ch;
end;

function getstring(col,x,y,max:byte;legalch:tchok):string;
var
  ch:char;
  input,temp:string;
  oldcol,i,xpos,ypos:byte;
  hoejre,venstre:string[23];
begin
  getstring:='';
  gotoxy(x,y);
  oldcol:=textattr;
  textattr:=col;
  ch:=#0;
  input:=''; hoejre:=''; venstre:='';
  xpos:=x; ypos:=y;
  repeat
    gotoxy(xpos,ypos);
    venstre:=copy(input,1,xpos-13);
    hoejre:=copy(input,xpos-12,36-xpos);
    repeat
      ch:=readkey;
    until(ch in legalch);
    if(ch=kbnull)then
    begin
      ch:=readkey;
      case ch of
        kbhome:xpos:=x;
        kbleft:if(xpos>x)then dec(xpos);
        kbright:if(xpos<ord(input[0])+x)then inc(xpos);
        kbdel:begin
{                hoejre:=copy(hoejre,2,length(hoejre)-1);
                input:=venstre+hoejre;}
                delete(input,(xpos-x)+1,1);
              end;
        kbend:begin
                xpos:=ord(input[0])+x;
              end;
      end;
    end else if(ord(input[0])<max)and(ch<>kbbackspace)and
               (ch<>kbenter)then
    begin
{      input:=venstre+ch+hoejre;     (* indsæt karakter *)}
      temp:=copy(input,1,(xpos-x));
      temp:=temp+ch;
      temp:=temp+copy(input,(xpos-x)+1,length(input));
      input:=temp;
      write(ch);
      inc(xpos);
    end;
    if(ch=kbbackspace)then
    begin
      if(ord(input[0])>0)then
      begin
        if(xpos>x)then dec(xpos);
        delete(venstre,(xpos-x)+1,1);
        gotoxy(xpos,ypos);
        write(' ');
        input:=venstre+hoejre;
      end;
    end;
    gotoxy(x,y); clreol; write(input);
  until(ch=kbenter)or(ch=kbesc);
  if(ch=kbesc)then
  begin
    getstring:='';
    exit;
  end;
  textattr:=oldcol;
  getstring:=input;
end;

procedure xorbar(x1,x2,y:word;c:byte); assembler;
asm
  dec [y]
  push colseg
  pop es
  mov di,[y]
  mov bx,di
  shl di,6
  shl bx,4
  add di,bx
  add di,[x1]
  shl di,1
  dec di
  mov cx,[x2]
  sub cx,[x1]
  inc cx
  @@loop:
    mov al,[c]
    xor es:[di],al
    add di,2
    dec cx
    jnz @@loop
end;

function selectbar(xp,yp,x2,num,col,ystart:byte;abort:boolean):byte;
var
  ch:char;
  y,oy:byte;
  done:boolean;
begin
  selectbar:=0;
  oy:=255; y:=ystart;
  if(y>num)then exit;
  done:=false;
  repeat
    if(y<>oy)then
    begin
      if(oy<>255)then xorbar(xp,x2,pred(oy+yp),col);
      xorbar(xp,x2,pred(y+yp),col);
      oy:=y;
    end;
    ch:=readkey;
    if(ch=kbnull)then
    begin
      ch:=readkey;
      case ch of
        kbleft,kbup:if(y>1)then dec(y);
        kbright,kbdown:if(y<num)then inc(y);
      end;
    end else
    case ch of
      kbenter:begin selectbar:=succ(y-yp); done:=true; end;
      kbesc:begin if(abort)then done:=true; end;
    end;
  until(done);
end;

function selectfile(wildcard:string;x,y,col:byte;abort:boolean):string;
var
  wx1,wy1,wx2,wy2:byte; { Window dimensions. }
begin
  inilink(dirlink);
  selectfile:='';
  findfirst(wildcard,archive,dirinfo);
  if(dirinfo.name='')then exit;
  while(doserror=0)do
  begin
    addlink2(dirlink,dirinfo.name);
    findnext(dirinfo);
  end;
  writeln(numlinks(dirlink));
  killink(dirlink);
end;

end.