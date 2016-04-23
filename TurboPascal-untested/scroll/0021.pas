{ ------------------------------------- }
{ Why does it flicker, when I scroll ?? }
{ ------------------------------------- }


{ Please excuse of posting a source, but I think it is easier to }
{ understand my source than understanding my english             }

{ ------------------------------ CUT HERE ---------------------------------}

{   Scroll Up and Down with "."and ";"  }

{   Most routines are nod made by me ..   }
{   I got them from SWAG i think          }

{ Nearly no documentation :) }

uses crt;

const rows=200;    { Should be greater than 25, do see the problem }

var i     : integer;
    qc    : char;
    qs    : byte;
    Start : pointer absolute $b800:0;        { Eine Zeile VOR dem sichtbaren
    Bereich }
    Blick : pointer absolute $b800:160;      { Sichtbarer Bereich }
    txt   : array[1..rows] of string[80];


procedure vretrace; assembler; { vertical retrace }
asm
  mov dx,3dah
 @vert1:
  in al,dx
  test al,8
  jz @vert1
 @vert2:
  in al,dx
  test al,8
  jnz @vert2
end;

procedure VFine(y:byte);assembler;
asm
    mov  dx,03d4h
    mov  ah,Y
    mov  al,8
    out  dx,ax
end;

{ Not needed by me...  perhaps you'll need that }
{
procedure scroff(soffset:integer);assembler;
asm
  cli
  mov dx,03d4h
  mov bx,soffset
  mov ah,bh
  mov al,00ch
  out dx,ax
  mov ah,bl
  inc al
  out dx,ax
  sti
end;
}

procedure fasttext(x, y : word; col : byte; what : string);assembler;
asm
      push   ds

      dec    [x]
      dec    [y]
      mov    ax, $b800
      mov    es, ax
      mov    ax, [y]
      mov    bl, 160
      mul    bl
      add    ax, [x]
      add    ax, [x]
      mov    di, ax

      lds    si, what
      cld
      lodsb
      xor    ch, ch
      mov    ah, [col]
      mov    cl, al
      cmp    cx, 0
      jz     @@2

 @@1: lodsb
      stosw
      loop   @@1

 @@2:
      pop    ds
end;

Function formatstr(kette:string;typ,laenge:byte):string;
{ These routines are not fast, but they are not important for me }
{ Wenn Typ=1 dann linksorientiert  }
{      Typ=2 dann Mittig           }
{      Typ=3 dann rechtsorientiert }
begin
  if length(kette)>laenge then
  delete(kette,succ(laenge),length(kette)-laenge);
  Case typ of
        1 : while length(kette)<laenge do
            begin
              insert(' ',kette,succ(length(kette)));
            end;
        2 : while length(kette)<laenge do
            begin
              insert(' ',kette,succ(length(kette)));
              insert(' ',kette,1);
              if length(kette)>laenge then delete(kette,succ(laenge),1);
            end;
            { Schlecht programmiert, aber funktioniert ! }
        3 : while length(kette)<laenge do
            begin
              insert(' ',kette,1);
            end;
  end; { CASE }
  formatstr:=kette;
end;


procedure ScreenDown;
{ What I make is: I scroll the screen (pixel by pixel) and than add a new }
{ line out of the visible Screen }
var n:byte;
begin
  vretrace;
  vfine(0);
  move(Blick,Start,4160);
  inc(qs);
  fasttext (1,27,$0F,txt[qs+26]);
  for n:=0 to 15 do
  begin
    vretrace;
    vfine(n);
  end;
end;

procedure ScreenUp;
{ Here I wanted to do the same (except putting the first line), but some-  }
{ how it has a worse result !                                              }
                                    { Can you please tell me             }
var n:byte;                         { what must I do, to stop flickering }
begin                               { in here ?                          }
  for n:=15 downto 0 do
  begin
    vretrace;
    vfine(n);
  end;
  vretrace;
  move(Start,Blick,4160);
  if qs>1 then fasttext (1,1,$0F,txt[pred(qs)]);
  vfine(15);
  dec(qs);
end;

function I2S(I: Longint): String;
var
  S: string[11];
begin
  Str(I, S);
  s:=formatstr(s,3,3);
  I2S:=S;
end;

procedure make_text;
{ Creates virtual text .. only for testing purposes }
var nn:byte;
begin
  for nn:=1 to rows do
  begin
    txt[nn]:='Line '+i2s(nn)+': '+formatstr('ExampleTxt',random(3)+1,70);
  end;
end;

begin
  textattr := 15;
  clrscr;
  asm        { Cursor Off }
    mov   ah,01
    mov   ch,20h
    int   10h
  end;
  qs:=0;      { Counts the number of current top line }
  make_text;  { Create Virtul Text }
  fasttext(1,1,$0F,formatstr(' ',1,80));    { Make Blank first Line }
  for i:=2 to succ((ord(rows<=30)*rows)+(ord(rows>30)*30)) do
  BEGIN
    fasttext (1,i,$0F,txt[i-1]);
  END;
  for i := 0 to 15 do   {  Scroll a little bit down, to set           }
  begin                 {  the starting Screen to hmmm to that it is  }
    vretrace;           {  working ...                                }
    vfine (i);
  end;
  while keypressed do readkey;
  repeat
    qc:=' ';
    if keypressed then
    begin
      qc:=readkey;
      if (qc='.') and ((qs+25)<rows) then ScreenDown;
      if (qc=';') and (qs>=1) then ScreenUp;
    end;
  until qc='q';
  textmode(co80);
end.

{ ------------------------------ CUT HERE ---------------------------------}

