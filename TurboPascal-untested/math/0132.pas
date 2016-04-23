Program SinCosFilter;

{Salvatore Meschini 
 E-Mail: smeschini@ermes.it - http://www.ermes.it/pws/mesk
 Check this: http://www.gdsoft.com/swag/downloads.html}
{Original idea: Dirty Abe (Albert Veli)}

{The following program ins't optimized (lookup tables,assembler...) because
it only show how to write a filter with sin/cos. Just an idea :) }

{Press ESC to quit - OTHER keys to browse filters}
{Useful routines: Keypressed/GetPixel/SetPixel/GetKey/CyclePal/Get&SetPal/
 vretrace}


const kx=2*pi/320;
      ky=2*pi/200;

var x,y:word;
    i,counter:byte;
    ch:char;

function KeyPressed: Boolean; Assembler;
{FASTEST keypressed replacement! No interrupts}
  asm
   mov  ax, 40h
   mov  es, ax
   mov  dx, es:[1ah]
   mov  bx, es:[1ch]
   xor  ax, ax
   cmp  dx, bx
   je  @fine
   mov  al, 1
   @fine:
 end;

procedure Putpixel(X, Y: word; Col: Byte); assembler; {Draw a point at x,y}
asm
          mov     ax,$A000                { 8  Cycles}
          mov     es,ax                   { 2  }
          mov     bx,[X]                  { 8  }
          mov     dx,[Y]                  { 8  }
          mov     di,bx                   { 2  }
          mov     bx, dx                  { 2  }
          shl     dx, 8                   { 8  }
          shl     bx, 6                   { 8  }
          add     dx, bx                  { 3  }
          add     di, dx                  { 3  }
          mov     al, [Col]               { 8  }
          stosb                           { 11 }
end;

Function GetPixel(x,y:word):byte;Assembler;   {Get color of pixel at x,y}
 asm
   mov ax,0a000h
    mov es,ax
    mov bx,y
    mov di,bx
    xchg bh,bl
    shl di,6
    add di,bx
    add di,x
    mov al,[es:di]
 end;

procedure Setmode(mode: byte); assembler; {Set graphical/text mode}
asm
 xor ah,ah
 mov al,mode
 int 10h
end;

procedure Vretrace; assembler; {Wait for vertical retrace}

label
  l1, l2;

asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;


function GetKey: Char;   {Get last keypressed}

  var
    AsciiK: byte;

  begin
    asm
     xor ah,ah
     int 16h
     mov asciik,al
    end;
    getkey := chr(asciik);
  end;


Procedure SinCos;
 var col:byte;
 begin
 for x:=1 to 320 do
  for y:=1 to 200 do
  begin
  col:=round((sin(x*KX*0.5)*sin(y*KY*0.5))*(127-20)+128);
  putpixel(x,y,col);
  end;
 end;

Procedure ApplyFilter;
 var col:byte;

 begin
  sincos;
  for x:=1 to 320 do
   for y:=1 to 200 do
    begin
    col:=getpixel(x,y);
    case counter of
    0:col:=col + y - x ;
    1:col:=col + round((sin(x*KX*10)*sin(y*KY*10))*20);
    2:col:=col xor x xor y;
    3:col:=col - round((cos(x*Ky*10)*cos(y*Kx*10))*2);
    4:counter:=0;
    end;
    if col=0 then inc(col);
    putpixel(x,y,col);
    end;
 end;


Procedure SetPal(ColorNo: Byte; R, G, B: Byte);
  begin
    Port[$3c8] := ColorNo;
    Port[$3c9] := R;
    Port[$3c9] := G;
    Port[$3c9] := B;
  end;

procedure GetPal(ColorNo: Byte; var R, G, B: Byte);
  begin
    Port[$3c7] := ColorNo;
    R := Port[$3c9];
    G := Port[$3c9];
    B := Port[$3c9];
  end;

Procedure CyclePal(startc,endc:byte);
 var j,r,g,b,r1,g1,b1:byte;
 begin
  getpal(startc,r1,b1,g1);
  for j:=startc to endc do
   begin
     getpal(j+1,r,g,b);
     setpal(j,r,g,b);
   end;
  setpal(endc,r1,b1,g1);
 end;

 begin
 setmode($13);      {GoTo mode $13}
  for i:=1 to 170 do setpal(i,i,i or 32,i); {Set colors}
  for i:=171 to 255 do setpal(i,i or 32,i,i);
  applyfilter;{Apply custom filter to screen}
 repeat
 cyclepal(1,255);
 vretrace;
 if keypressed then begin ch:=getkey; if ch <> #27 then begin
 inc(counter); applyfilter;
 end;
 end;
 until ch=#27;           {Press ESC to quit!}
 setmode(3);
 end.
