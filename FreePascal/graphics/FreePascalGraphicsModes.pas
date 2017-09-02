(*
  FreePascalGraphicsModes.pas
  Not originally part of SWAG, adapted from
  
  https://www.freepascal.org/docs-html/rtl/graph/modes.html
  Added by Nacho, 2017
*)

(*
In FreePascal, The following drivers are defined:

D1bit = 11;
D2bit = 12;
D4bit = 13;
D6bit = 14;  { 64 colors Half-brite mode - Amiga }
D8bit = 15;
D12bit = 16; { 4096 color modes HAM mode - Amiga }
D15bit = 17;
D16bit = 18;
D24bit = 19; { not yet supported }
D32bit = 20; { not yet supported }
D64bit = 21; { not yet supported }

lowNewDriver = 11;
highNewDriver = 21;
Each of these drivers specifies a desired color-depth.

The following modes have been defined:

detectMode = 30000;
m320x200 = 30001;
m320x256 = 30002; { amiga resolution (PAL) }
m320x400 = 30003; { amiga/atari resolution }
m512x384 = 30004; { mac resolution }
m640x200 = 30005; { vga resolution }
m640x256 = 30006; { amiga resolution (PAL) }
m640x350 = 30007; { vga resolution }
m640x400 = 30008;
m640x480 = 30009;
m800x600 = 30010;
m832x624 = 30011; { mac resolution }
m1024x768 = 30012;
m1280x1024 = 30013;
m1600x1200 = 30014;
m2048x1536 = 30015;

lowNewMode = 30001;
highNewMode = 30015;
*)


Program FreePascalGraphicsModes;
{ Program to demonstrate static graphics mode selection }

uses graph, wincrt;


const
  TheLine = 'We are now in 640 x 480 x 256 colors!'+
            ' (press <Return> to continue)';

var
  gd, gm, lo, hi, error,tw,th: integer;
  found: boolean;

begin
  { We want an 8 bit mode }
  gd := D8bit;
  gm := m640x480;
  initgraph(gd,gm,'');
  { Make sure you always check graphresult! }
  error := graphResult;
  if (error <> grOk) Then
    begin
    writeln('640x480x256 is not supported!');
    halt(1)
    end;
  { We are now in 640x480x256 }
  setColor(cyan);
  rectangle(0,0,getmaxx,getmaxy);
  { Write a nice message in the center of the screen }
  setTextStyle(defaultFont,horizDir,1);
  tw:=TextWidth(TheLine);
  th:=TextHeight(TheLine);
  outTextXY((getMaxX - TW) div 2,
            (getMaxY - TH) div 2,TheLine);
  { Wait for a key press }
  readkey;
  { Back to text mode }
  closegraph;
end.
