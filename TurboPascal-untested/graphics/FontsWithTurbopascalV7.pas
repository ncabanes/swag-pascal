(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0110.PAS
  Description: FONTS WITH TURBOPASCAL V7
  Author: FRED JOHNSON
  Date: 08-24-94  13:40
*)


{compile the *.bgi and *.chr files into a .exe file?  If so how?

1. Collect all the fonts you can
   If you don't have them all, fake it (use old one in place of real one)
2. Compile them separately into OBJ files
   example: binobj bold.chr bold.obj bold

3. DO the BGI driver for your video card.
   example: binobj egavga.bgi egavga.obj egavga

4. use the TPUs in your main prog
5. Load the video driver like an external procedure;


{-------------------------------example 1 (converts chr->obj->tpu)}

unit boldfont;   {use the name + font for all of the fonts}

interface
procedure bold;
implementation
procedure bold; external;
{$L bold.obj}
end.
{------------------------------------------------------------------------}

{--------------------------------example 2}
uses graph,
   boldfont, eurofont, gothfont, lcomfont, littfont,
   sansfont, simpfont, scrifont, tripfont, tscrfont;

procedure egavga; external;
{$L egavga.obj}

const
   xFonts : array[0..10] of record
      sFontName  : string;
      xpFontAddr : pointer;
   end =
   ( {Fonts must remain in this order because of settextstyle()}
   (sFontName :'Default'; xpFontAddr : nil),  {style 00}
   (sFontName :'Triplex'; xpFontAddr : @TRIP),{style 01}
   (sFontName :'Small';   xpFontAddr : @LITT),{style 02}
   (sFontName :'Sans';    xpFontAddr : @SANS),{style 03}
   (sFontName :'Gothic';  xpFontAddr : @GOTH),{style 04}
   (sFontName :'Script';  xpFontAddr : @SCRI),{style 05}
   (sFontName :'Simplex'; xpFontAddr : @SIMP),{style 06}
   (sFontName :'Tscr';    xpFontAddr : @TSCR),{style 07}
   (sFontName :'Lcom';    xpFontAddr : @LCOM),{style 08}
   (sFontName :'Euro';    xpFontAddr : @EURO),{style 09}
   (sFontName :'Bold';    xpFontAddr : @BOLD) {style 10}
   );

var
   gd, gm, i : integer;

begin
   if RegisterBGIDriver(@EGAVGA) < 0 then halt;
   for i := 1 to 10 do
      if RegisterBGIFont(xFonts[i].xpFontAddr) < 0 then
         write('Can''t register', xFonts[i].sFontName,' font');

   gd := VGA;
   gm := VGAHi;
   initgraph(gd, gm, '');

   for i := 0 to 10 do
      begin
         settextstyle(i,0,10);
         outtextxy(10,20,xFonts[i].sFontName);
         readln;
         cleardevice;
      end;
   closegraph;
end.

