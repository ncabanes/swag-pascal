(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0104.PAS
  Description: Cannon Ball Animation
  Author: LUIS MEZQUITA RAYA
  Date: 08-24-94  13:27
*)

{
 JG> This coding works fine, I would like to make the ball travel
 JG> smoother.  When it travels in the air, its kinda "Chunky"

 JG> How could you make it so that the computer calculates the next
 JG> point and make it travel the ball to that point one pixel at a
 JG> time?  Cause with this structure, it kinda "Jumps there"

        Try next code and tell me ...
}

Program FallingBall;

{ Written by Luis Mezquita Raya }

{$x+}

uses  Crt,
      Graph;

Procedure Init;
var cg,mg:integer;
begin
 cg:=Detect;
 InitGraph(cg,mg,'\turbo\tp');
end;

Procedure Wait(msk:byte); assembler;
asm
        mov dx,3dah
@Loop1: in al,dx
        test al,msk
        jz @Loop1
@Loop2: in al,dx
        test al,msk
        jnz @Loop2
end;

Procedure Calc;
var angle,power,gravity,a1,a2,a3,y0,n:real;
    size:word;
    ball,mask,bkg:pointer;
    x,y,ox,oy,pause:integer;
begin

 ClearViewPort;

 size:=ImageSize(0,0,20,20);
 GetMem(ball,size);
 GetMem(mask,size);
 GetMem(bkg,size);

 SetFillStyle(SolidFill,Yellow);        { Draw a ball }
 Circle(10,10,8);
 FloodFill(10,10,White);
 GetImage(0,0,20,20,ball^);             { Get the ball }

 SetFillStyle(SolidFill,White);         { Draw ball's mask }
 Bar(0,0,20,20);
 SetFillStyle(SolidFill,Black);
 SetColor(Black);
 Circle(10,10,10);
 FloodFill(10,10,Black);
 GetImage(0,0,20,20,mask^);             { Get the mask }

 ClearViewPort;                         { Draw a background }
 SetFillStyle(CloseDotFill,LightBlue);
 Bar(0,0,GetMaxX,GetMaxY);

 angle:=35;                             { Init vars }
 power:=10;
 gravity:=0.1;
 y0:=200;
 ox:=-1;
 n:=0;

 while n<80 do                          { Main loop }
  begin
   a1:=cos(angle*pi/180)*power*n;
   a2:=y0-sin(angle*pi/180)*power*n;
   a3:=gravity*n*n;
   x:=Round(a1);
   y:=Round(a2+a3);
   Wait(8);                             { Wait retrace }
   for pause:=0 to 399 do Wait(1);      { Wait scan line }
   if ox<>-1                            { Restore old background }
   then PutImage(ox,oy,bkg^,CopyPut);
   GetImage(x,y,x+20,y+20,bkg^);        { Save background }
   PutImage(x,y,mask^,AndPut);          { Put mask }
   PutImage(x,y,ball^,OrPut);           { Put ball }
   ox:=x;
   oy:=y;
   n:=n+0.2;
  end;

 FreeMem(ball,size);
 FreeMem(mask,size);
end;


begin
 Init;
 Calc;
 ReadKey;
 CloseGraph;
end.

