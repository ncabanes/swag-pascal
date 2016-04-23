{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+,Y+}
{$M 16384,0,32786}
Program BitMap;       { rotates/pans/scales a 256x256 bitmap }
USES CRT;                 { by Paul H. Kahler   Jan 1994 }

Var   SinTable,CosTable: Array[0..255] of integer;
      Sin2Table,Cos2Table: Array[0..255] of integer;
      Map:word; {used as a pointer to the bitmap}

Procedure MakeTables;                   {Creates sin/cos tables}
Var direction:integer;
    angle:real;
begin
     For Direction:=0 to 255 do begin   {use 256 degrees in circle}
         angle:=Direction;
         angle:=angle*3.14159265/128;
         SinTable[Direction]:=round(Sin(angle)*256);
         CosTable[Direction]:=round(Cos(angle)*256);
         Sin2Table[Direction]:=round(Sin(angle+3.14159265/2)*256*1.2);
         Cos2Table[Direction]:=round(Cos(angle+3.14159265/2)*256*1.2);
     end;                 { the 1.2 accounts for pixel aspect ratio }
end;

Procedure DrawScreen(x,y,scale:word; rot:byte);
var Temp:Longint;            {used for intermediate large values}
    ddx,ddy,d2x,d2y:integer;
    i,j:word;
    label hloop,vloop,nodraw;

begin
{ the following 8 lines of code calculate a 'right' and 'down' vector used
  for scanning the source bitmap. I use quotes because these directions
  depend on the rotation. For example, with a rotation, 'right' could mean
  up and to the left while 'down' means up and to the right. Since the
  destination image (screen) is scanned left-right/top-bottom, the bitmap
  needs to be scanned in arbitrary directions to get a rotation. }

     Temp:=(CosTable[rot]);Temp:=(Temp*Scale) div 256;
     ddx:=Temp;
     Temp:=(SinTable[rot]);Temp:=(Temp*Scale) div 256;
     ddy:=Temp;

{ Different tables are used for the 'down' vector to account for the non-
  square pixels in mode 13h (320x200). The 90 degree difference is built
  into the tables. If you don't like that, then use (rot+64)and255 here
  and take the pi/2 out of CreateTables. To each his own I guess. }

     Temp:=(Cos2Table[rot]);Temp:=(Temp*SCALE) div 256;
     d2x:=Temp;
     Temp:=(Sin2Table[rot]);Temp:=(Temp*SCALE) div 256;
     d2y:=Temp;

{ Since we want to rotate around the CENTER of the screen and not the upper
  left corner, we need to move 160 pixels 'left' and 100 'up' in the bitmap.}

     i:=x-ddx*160-d2x*100; j:=y-ddy*160-d2y*100;

{ The following chunk of assembly does the good stuff. It redraws the entire
  screen by scanning left-right/top-bottom on screen while also scanning the
  bitmap in the arbitrary directions determined above. }

         ASM
                 push ds
                 mov  ax,[Map]      {get segment of bitmap}
                 mov  ds,ax
                 mov  ax,$a000      {set es: to video memory}
                 mov  es,ax
                 mov  ax,0          {set ds: to upper left corner of}
                 mov  di,ax         {the video memory}
                 mov  ax,[ddx]      {this is just to speed things up later}
                 mov  si,ax         {add ax,si  faster than  add ax,[ddx] }
                 mov  cx,200        {Number of rows on Screen}
         vloop:
                 push cx
                 mov  ax,[i]        {start scanning the source bitmap}
                 mov  dx,[j]        {at i,j which were calculated above.}
                 mov  cx,320        {Number of coulumns on screen}
         hloop:
                 add  ax,si        {add the 'right' vector to the current}
                 add  dx,[ddy]     {bitmap coordinates.  8.8 fixed point}
                 mov  bl,ah        {  bx = 256*int(y)+int(x)  }
                 mov  bh,dh
                 mov  bl,[ds:bx]   { load a pixel from source }
                 mov  [es:di],bl   { copy it to destination }
                 inc  di           { advance to next destination pixel }

         {*** by repeating the above 7 instructions 5 times, and reducing
              the loop count to 64, I have hit 37fps on a 486-33 with a
              fast video card. ***}

                 loop hloop         {End of horizontal loop}

                 mov  ax,d2x        { get the 'down' vector }
                 mov  dx,d2y

              { add  si,2 }    {** uncomment this instr. for extra fun **}

                 add  i,ax          { i,j is the starting coords for a line }
                 add  j,dx          { so this moves down one line }
                 pop  cx            { get the row count back and loop }
                 loop vloop         { End of verticle loop }
                 pop  ds            { Restore the ds }
         end;
end;

Procedure GraphMode;      {start 320x200x256 mode}
begin
     Asm
        Mov     AH,00
        Mov     AL,13h
        Int     10h
     end;
end;

Procedure AllocateMem;  {returns a segment pointer for a 64K bitmap}
label noerror;
begin
     asm
              mov   ah,$48
              mov   bx,$1000     { request 64K }
              int   $21
              jnc   noerror
              mov   ax,0000
     noerror: mov   Map,ax       { The segment pointer goes in Map }
              end;
     If Map=0 then begin
        Writeln('Could not allocate enough memory');
        Writeln('Program ending...');
        Halt;end;
end;

Procedure GiveBackMem; {returns the memory used for the map to the system}
begin
     asm
        mov  ah,$49
        mov  dx,Map
        mov  es,dx
        int  $21
     end;
end;

Procedure DrawImage;  {draws a test image which shows some limitations.}

{ If anyone stuffs in code to load a picture in a standard format
  (ie .gif .bmp etc..) I'd like if you send me a copy. Preferably
  something simple. This will have to do for now. }

Var x,y:integer;
Begin
     for x:=-32768 to 32767 do mem[Map:x]:=0;
     for y:=0 to 15 do          {this just frames the area}
        for x:=y to 255 do begin
           mem[Map:Y*256+x]:=1;
           mem[Map:X*256+y]:=2;
           end;
     for y:=16 to 47 do         { this part show Aliasing effects }
        for x:=16 to 255 do mem[Map:Y*256+x]:=2+(x and 1)+(y and 1);

     for y:= -50 to 50 do       { this draw the circles }
        for x:= round(-sqrt(2500 - y*y)) to round(sqrt(2500 - y*y)) do
          mem[Map:(y+100)*256+x+100]:=5+(X*X+Y*Y) div 100;

     for x:=0 to 100 do         { These lines also show sampling effects }
        for y:=0 to 8 do
           mem[Map:(Y*2560)+x+41100]:=5;
end;

Var    rot,dr:word;
       x,y,dist,dd:word;

Begin
     AllocateMem;
     DrawImage;
     MakeTables;
     GraphMode;
     x:=32768; y:=0;         {this corresponds to (128,0) in fixed point}
     rot:=0; dr:=1;          {rotation angle and it's delta}
     dist:=1200; dd:=65534;  {distance to bitmap (sort of) and its delta}
     repeat
        DrawScreen(x,y,dist,lo(rot));
        rot:=rot+dr;
        y:=y+128;      {slow panning. 1/2 pixel per frame}
        dist:=dist+dd;
        if (dist=2000) or (dist=2) then dd:=-dd;
        if random(150)=1 then dr:=random(7)-3;
     until keypressed;
     GiveBackMem;
     ASM {back to 80x25}
      MOV AX,3
      INT 10h
     END;
end.