
{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}
Program Tiles;         { by Paul H. Kahler 1994 }
USES CRT;            {email:  phkahler@oakland.edu}

{ This program is mostly undocumented. If you want to know whats going on,
  see the other program, it has more comments and much of the same code, so
  it should be more helpful. This version doesn't account for the non-square
  pixels in mode 13h (see the other program to fix that) and it's slower
  because a different fixed-point format is used (see the hloop of both
  programs). I like it because it's shorter and simpler. }

{ A 32x32 bitmap is defined in the data below. Feel free to change it to
  whatever you like, I just punched in the first thing that came to mind. }

Const Tile: array [0..1023] of byte =
   ( 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,1,1,1,1,1,0,0,1,1,1,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,
     2,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,
     2,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,
     2,0,0,0,0,1,1,1,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,
     2,0,0,0,0,1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,
     2,0,0,0,0,1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1,1,1,0,0,1,1,1,1,1,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,0,0,5,5,5,5,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,5,5,5,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,0,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,3,3,3,3,0,0,3,3,3,0,0,0,3,3,3,0,0,3,0,0,0,0,0,0,0,0,
     2,0,0,0,0,3,0,0,0,0,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0,0,0,0,0,0,0,0,
     2,0,0,0,0,3,0,0,0,0,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0,0,0,0,0,0,0,0,
     2,0,0,0,0,3,0,0,0,0,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0,0,0,0,0,0,0,0,
     2,0,0,0,0,3,0,0,0,0,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0,0,0,0,0,0,0,0,
     2,0,0,0,0,3,0,0,0,0,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,3,3,3,3,0,0,3,3,3,0,0,0,3,3,3,0,0,3,3,3,3,3,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 );

Var   SinTable,CosTable: Array[0..255] of longint;

Procedure MakeTables;
Var direction:integer;
    angle:real;
begin
     For Direction:=0 to 255 do begin
         angle:=Direction;
         angle:=angle*3.14159265/128;
         SinTable[Direction]:=round(Sin(angle)*256);
         CosTable[Direction]:=round(Cos(angle)*256);
     end;
end;

Procedure GraphMode;  {set 320x200x256 mode}
begin
     Asm
        Mov     AH,00
        Mov     AL,13h
        Int     10h
     end;
end;

Procedure DrawScreen(x,y:word; rot,scale:byte);
var Temp:Longint;
    ddx,ddy,d2x,d2y:word;
    i,j:word;
    label hloop,vloop;

begin
     Temp:=(CosTable[rot]);Temp:=(Temp*Scale) div 32;
     ddx:=Temp;
     Temp:=(SinTable[rot]);Temp:=(Temp*Scale) div 256;
     ddy:=Temp;
     Temp:=(CosTable[(rot+64) and 255]);Temp:=(Temp*SCALE) div 32;
     d2x:=Temp;
     Temp:=(SinTable[(rot+64) and 255]);Temp:=(Temp*SCALE) div 256;
     d2y:=Temp;
     i:=x-ddx*160-d2x*100; j:=y-ddy*160-d2y*100;

         ASM
                 mov  ax,0
                 mov  di,ax
                 mov  ax,$a000
                 mov  es,ax
                 mov  cx,200
         vloop:
                 push cx
                 mov  ax,[i]
                 mov  dx,[j]
                 mov  cx,320
         hloop:
                 add  ax,[ddx]
                 add  dx,[ddy]
                 mov  bl,ah
                 mov  bh,dh
                 shr  bx,3
                 and  bx,$03FF
                 add  bx,OFFSET tile
                 mov  si,bx
                 movsb
                 loop hloop

                 mov  ax,d2x
                 add  i,ax
                 mov  ax,d2y
                 add  j,ax
                 pop  cx
                 loop vloop
         end;
end;

Var dist,dd,rot,dr:byte;
    x,y:word;
Begin
     MakeTables;
     GraphMode;
     x:=32768; y:=1024;
     rot:=0; dr:=1;
     dist:=127; dd:=255;
     repeat
        DrawScreen(x,y,rot,dist);
        rot:=rot+dr;
        y:=y+128;
        dist:=dist+dd;
        if (dist=250) or (dist=3) then dd:=-dd;
        if random(150)=3 then begin
           dr:=0; while dr=0 do dr:=random(5)-3; end;
     until keypressed;
     ASM {back to 80x25}
      MOV AX,3
      INT 10h
     END;
end.