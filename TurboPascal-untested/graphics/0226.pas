{another plasma. Uses John Bridges' 360x480x256 non standard vga mode,
 somebody elses plasma routine, yet another person's palette cycle
 routine, and my color mutator. }

uses crt,printer;
Const
  granularity=0.5;
  EndProgram:Boolean=False;
  DelayFactor:Byte=20;
  skyr=0;
  skyg=0;
  skyb=55;

var
  pal:array[0..773] of byte;
  r,g,b,dir,which:byte;
  i,j,counter:integer;
  ch:char;


{$F+}
procedure set360x480;
{courtesy of John Bridges}
begin
   asm
      push si
      push di
      mov ax,12h     {clear video memory with bios}
      int 10h        {and set 640x480x16 mode}
      mov ax,13h     {set 320x200x256 mode with bios}
      int 10h
      mov dx,3c4h    {alter sequencer registers}
      mov ax,0604h   {disable chain 4}
      out dx,ax
      mov ax,0100h   {syncronus reset}
      out dx,ax
      mov dx,3c2h
      mov al,0e7h
      out dx,al
      mov dx,3c4h
      mov ax,0300h
      out dx,ax
      mov dx,3d4h
      mov al,11h
      out dx,al
      inc dx
      in al,dx
      and al,7fh
      out dx,al
      dec dx
      mov ax,06b00h  {horiz total}
      out dx,ax
      mov ax,05901h  {horiz displayed}
      out dx,ax
      mov ax,05a02h  {start horiz blanking}
      out dx,ax
      mov ax,08e03h  {end horiz blanking}
      out dx,ax
      mov ax, 05e04h  {start h sync}
      out dx,ax
      mov ax, 08a05h  {end h sync}
      out dx,ax
      mov ax, 00d06h  {vertical total}
      out dx,ax
      mov ax, 03e07h  {overflow}
      out dx,ax
      mov ax, 04009h  {cell height}
      out dx,ax
      mov ax, 0ea10h  {v sync start}
      out dx,ax
      mov ax, 0ac11h  {v sync end and protect cr0-cr7}
      out dx,ax
      mov ax, 0df12h  {vertical displayed}
      out dx,ax
      mov ax, 02d13h  {offset}
      out dx,ax
      mov ax, 00014h  {turn off dword mode}
      out dx,ax
      mov ax, 0e715h  {v blank start}
      out dx,ax
      mov ax, 00616h  {v blank end}
      out dx,ax
      mov ax, 0e317h  {turn on byte mode}
      out dx,ax
     pop di
     pop si
   end;
end;

procedure dot360x480(drawx,drawy,color:word);
begin
   asm
       mov ax,0a000h                {VGA_SEGMENT}
       mov es,ax
       mov ax,90                    {SCREEN_WIDTH/4}
       mul DrawY
       mov di,DrawX
       shr di,1
       shr di,1
       add di,ax
       mov cl,byte ptr DrawX
       and cl,3
       mov ah,1
       shl ah,cl
       mov al,2                    {MAP_MASK}
       mov dx,03c4h                {SC_INDEX}
       out dx,ax
       mov al,byte ptr Color
       stosb                       {draw pixel}
    end;
end;

Function Read360x480(Readx,Ready:word):word;
{Read360x480 PROC FAR ReadX:WORD, ReadY:WORD RETURNS result:WORD}
begin
   asm
       mov ax,0a000h                {VGA_SEGMENT}
       mov es,ax
       mov ax,90                    {SCREEN_WIDTH/4}
       mul ReadY
       mov si,ReadX
       shr si,1
       shr si,1
       add si,ax
       mov ah,byte ptr ReadX
       and ah,3
       mov al,4                    {READ_MAP}
       mov dx,3ceh                 {GC_INDEX}
       out dx,ax
       SEGES mov al,[si]
       sub ah,ah
       mov @result,ax
   end;
end;

{$F-}


procedure bump(var r:byte; var g:byte; var b:byte);
{this one's mine. Inc/dec one r, g, or b value to make returned
 color one bit off from delivered one.
 Ron Nossaman       nossaman@southwind.net }
begin
   dec(counter);
   if counter<=0 then
   begin
      counter:=random(10)+1;
      dir:=random(2);
      which:=random(3);
   end;
   dec(counter);
   case dir of
     0: case which of
         0:if r>0 then dec(r) else counter:=0;
         1:if g>0 then dec(g) else counter:=0;
         2:if b>0 then dec(b) else counter:=0;
        end;
     1: case which of
         0:if r<63 then inc(r) else counter:=0;
         1:if g<63 then inc(g) else counter:=0;
         2:if b<63 then inc(b) else counter:=0;
        end;
   end;
end;



Procedure CyclePalette(s,e:Byte);
var r,g,b:byte;
    p,j:word;
Begin
   r:=pal[s*3];
   g:=pal[s*3+1];
   b:=pal[s*3+2];
   bump(r,g,b);
   move(pal[s*3],pal[s*3+3],(e-(s))*3);
   pal[s*3]:=r;
   pal[s*3+1]:=g;
   pal[s*3+2]:=b;
 {install palette}
   for p:=0 to 255 do
   begin
      j:=p*3;
      ASM
        CLI
      END;
      Port[$3C8]:=p;
      Port[$3C9]:=pal[j];
      Port[$3C9]:=pal[j+1];
      Port[$3C9]:=pal[j+2];
      ASM
        STI
      END;
   end;
End;



procedure setpixel(x,y,hue:integer);
{with brute force (dip stick) clipping}
begin
   if x<0 then exit;
   if y<0 then exit;
   if x>359 then exit;
   if y>479 then exit;
   dot360x480(x,y,hue);
end;



Procedure dopal;        {define palette}
var iback,i3,i,j:integer;
    dir,which:byte;
begin
   pal[0]:=0;
   pal[1]:=0;
   pal[2]:=0;
   pal[3]:=random(10)+26;
   pal[4]:=random(10)+26;
   pal[5]:=random(10)+26;
   counter:=0;
   r:=pal[3];
   g:=pal[4];
   b:=pal[5];
   for i:=1 to 255 do
   begin
      bump(r,g,b);
      pal[i*3]:=r;
      pal[i*3+1]:=g;
      pal[i*3+2]:=b;
   end;
end;



procedure installpal;
var pseg,pofs:word;
begin
    pseg:=seg(pal);
    pofs:=ofs(pal);
    set360x480;
    asm
      mov ah,$10;
      mov al,$12;
      mov bx,0;
      mov cx,256;
      mov dx,pofs;
      mov es,pseg;
      int $10;
    end;
end;

Procedure adjust(xa,ya,x,y,xb,yb:Integer);
Var
  d,v:Integer;
begin
  if read360x480(x,y)<>0 then
    Exit;
  d:=abs(xa-xb)+abs(ya-yb);
  v:=trunc((read360x480(xa,ya)+read360x480(xb,yb))/2+
      (random-0.5)*d*granularity);
  if v<1 then
    v:=1;
  if v>=255 then
    v:=255;
  setpixel(x,y,v);
end;

Procedure subDivide(x1, y1, x2, y2:Integer);
Var
  x, y:Integer;
  v:Real;
begin
  if KeyPressed then
    Exit;
  if (x2-x1 <2)and(y2-y1 <2) then
    Exit;
  x:=(x1+x2) div 2;
  y:=(y1+y2) div 2;
  adjust(x1,y1,x,y1,x2,y1);
  adjust(x2,y1,x2,y,x2,y2);
  adjust(x1,y2,x,y2,x2,y2);
  adjust(x1,y1,x1,y,x1,y2);
  if read360x480(x,y)=0 then
  begin
    v:=(read360x480(x1,y1)+read360x480(x2,y1)+read360x480(x2,y2)+
          read360x480(x1,y2))/4;
    setpixel(x,y,Trunc(v));
  end;

  SubDivide(x1,y1,x,y);
  subDivide(x,y1,x2,y);
  subDivide(x,y,x2,y2);
  subDivide(x1,y,x,y2);
end;



begin
   randomize;
   dopal;
   installpal;
   Randomize;
   setpixel(0,0,1+random(255));
   setpixel(359,0,1+random(255));
   setpixel(359,479,1+random(255));
   setpixel(0,479,1+random(255));
   SubDivide(0,0,359,479);
   Repeat
      cyclepalette(1,255);
      Delay(DelayFactor);
      If KeyPressed then
      Case ReadKey of
        #0:Case ReadKey of
               #80,#75:If DelayFactor<255 then Inc(DelayFactor);{down,left}
               #72,#77:If DelayFactor>0 then Dec(DelayFactor);{up,right}
             end;
        #113,#81,#27 {Q,q}:EndProgram:=True;
        'p':for i:=0 to 86 do
           begin
            write(lst,i*3,': ',pal[i*9],',',pal[i*9+1],',',pal[i*9+2],'   ');
            write(lst,pal[i*9+3],',',pal[i*9+4],',',pal[i*9+5],'   ');
            writeln(lst,pal[i*9+6],',',pal[i*9+7],',',pal[i*9+8]);
           end;
      end;
    Until EndProgram;

  TextMode(lastmode);
end.