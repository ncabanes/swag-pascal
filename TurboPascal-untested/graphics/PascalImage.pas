(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0099.PAS
  Description: Pascal Image
  Author: SEAN MARTENS
  Date: 05-26-94  06:20
*)

{
 BK> Could someone tell me how to view this image in Turbo Pascal 7.0 ??

  Take your data and put it above the following code.
  compile and see your image.
  Please note graphics functions kept a simple as possible. Crux of matter
  image not programing.

  Your data was 1028 bytes long.
  The first four bytes lead to two integer with value 31. ( dimensions)

  31*31 = 961.
  1028 - 961 - 4(for dimensions) = 64.

  64 = ?

  Your image says "Thanks in advance" . Its a pleasure.


_________o/_________
         o\
}

program demo;

Uses dos;

{cut and paste your data here }

type

  rgbx_type  = record
     red,green,blue,blank : byte;
  end;

  rgb_type  = record
     red,green,blue,blank : byte;
  end;

  img_type = record
     width,                                  { dimentions }
     height  : integer;
     data    : array [0..31,0..31] of byte;  { image data }
     pallete : array [0..15] of rgbx_type;   { no supporting evidence      }
                                             { some indexes bigger than 16 }
  end;

  screen_type = array [0..199,0..319] of byte;

var
  screen      : screen_type absolute $a000:$0000;
  colours     : array [0..255] of rgb_type;

procedure SetPallete(first_colour,num_colours : word);
var
  regs  : registers;
begin
   regs.ax := $1012;
   regs.cx := num_colours;
   regs.bx := first_colour;
   regs.dx := ofs(colours);
   regs.es := seg(colours);
   intr($10,regs);
end;

procedure GraphicsMode;
var
  regs  : registers;
begin
  regs.ax := $13;
  intr($10,regs);
end;

procedure TextMode;
var
  regs  : registers;
begin
  regs.ax := $3;   { should use a saved mode }
  intr($10,regs);
end;

procedure SetPixel(x,y : integer; colour : byte);
begin
  screen[y,x] := colour;
end;

var
  i,j   : integer;
  img   : img_type absolute image;
  dump  : char;
begin
  graphicsMode;
  for i := 0 to 15 do
     begin
        colours[i].red   := img.pallete[i].red;
        colours[i].green := img.pallete[i].green;
        colours[i].blue  := img.pallete[i].blue;
     end;

  SetPallete(0,16);
  for i := 1 to 31 do
     for j := 1 to 31 do
        SetPixel(i,j,img.data[j,i]);

  dump := readkey;
  Textmode;
end.

