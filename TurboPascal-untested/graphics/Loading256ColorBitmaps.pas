(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0150.PAS
  Description: Loading 256 Color Bitmaps
  Author: KRISJANIS GALE
  Date: 11-26-94  05:02
*)

{
For all who are interested:
}
{------------------------------------------------------------------------}
{  HOW TO READ A .BMP FILE!                                              }
{------------------------------------------------------------------------}
procedure LoadBMP(dx:integer;dy:byte;usepal:boolean;filestr:string);
  {Loads a 256-color .BMP file directly onto}
  {the screen at point x,y; K.Gale, 8/23/94}
  {added option to use or not use the saved palette; 8/24/94}
var
   cel:text;
   inchar:char;
   instr:string[4];
   y,r,g,b,ymax:byte;
   x,xmax:integer;
const
     bmpheader=18;
begin
     x:=0;y:=0;
     assign(cel,filestr);
     reset(cel);
     for x:=1 to bmpheader do
         read(cel,inchar);
     x:=0;
     read(cel,instr);
     xmax:=ord(instr[1])+(ord(instr[2])*256)
          +(ord(instr[2])*256*256)+(ord(instr[3])*256*256*256)-1;
     read(cel,instr);
     ymax:=ord(instr[1])+(ord(instr[2])*256)
          +(ord(instr[2])*256*256)+(ord(instr[3])*256*256*256)-1;
     for x:=27 to 54 do
         read(cel,inchar);
     x:=0;
     if usepal<>false then
        begin
             for y:=0 to 255 do
                 pal(y,0,0,0);
             y:=0;
             while x<=255 do
             begin
                  read(cel,instr);
                  r:=ord(instr[3]) div 4;
                  g:=ord(instr[2]) div 4;
                  b:=ord(instr[1]) div 4;
                  pal(x,r,g,b);
                  inc(x,1)
             end
        end
     else
         for x:=0 to 255 do
             read(cel,instr);
     x:=0;
     while (y<=ymax) do
     begin
          read(cel,inchar);
          putpixel(dx+x,dy+(ymax-y),ord(inchar),vga);
          if x<xmax then
             inc(x,1)
          else
              begin
                   inc(y,1);
                   x:=0;
              end
     end;
     close(cel)
end;
{------------------------------------------------------------------------}

There...
never mind the putpixel procedure call...
you DO NOT have that procedure.  I use a gfx unit that
a friend of mine wrote and so, you will have to substitute
the proper procedure call for putting a pixel on the screen.

Furthermore, this will ONLY work for 256-color .BMP files.
Lastly, the "usepal" boolean switch is for those cases when
you want to preserve an already defined palette, rather than
having the .BMP re-define all of those colors.

