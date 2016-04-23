{
I tested out an 8 bit DAC mode with a 3d rendered image for ANIVGA v1.2
compatible TeleGame SDK.  There were portions of the image which actually
popped out of the screen like a 3d movie.  Now very realistic 3d sprites and
images are possible with TeleGame.  There is no impediment to display speed
with this technique.  The higher color variation allows anti-aliasing and
smooth blending.

Here is ATT 20c491 specific code from VGADOC3 for Orchid Fahrenheit VA/VLB:
program Orchid;
}
uses ANIVGA, CRT;
CONST
      Pic1 = 'HIPALACE.PIC';
      PalName = 'HI.PAL';
      ch : Char = #0;
VAR
    i : Integer;
    dac8 : Boolean;
    DAC_RS2 : word;    {These address bits are fed to the }
    {DAC_RS3 : word;    RS2 and RS3 pins of the palette chip}
    daccomm : word;    { temp to trigger DAC reads }
    Dac6Colors : Palette;     { 6 bit dac RGB values 0..63 }
    Dac8Colors : Palette;     { 8 bit dac RGB values 0..255 }
type
  pel = record
           index, red, green, blue : byte;
        end;
procedure disable;  {Disable interupts}
begin
  inline($fa);   { CLI instruction }
end;  {disable}
procedure enable;   {Enable interrupts}
begin
  inline($fb);   { STI instruction }
end;  {enable}
procedure outp(reg, val : word);  {Write the low byte of VAL to I/O port REG}
begin
  port[reg] := val;
end;  {outp}
function inp(reg : word) : byte;  {Reads a byte from I/O port REG}
begin
  reg := port[reg];
  inp := reg;
end;  {inp}
function trigdac : word;  {Reads $3C6 4 times}
var x : word;
begin
  x := inp($3c6);
  x := inp($3c6);
  x := inp($3c6);
  trigdac := inp($3c6);
end;
procedure dac2pel;    {Force DAC back to PEL mode}
begin
  if inp($3c8)=0 then;
end;  {dac2pel}
procedure dac2comm;   {Enter command mode of HiColor DACs}
begin
  dac2pel;
  daccomm := trigdac;
end;  {dac2comm}
procedure readpelreg(index : word; var p : pel);
begin
  p.index := index;
  disable;
  outp($3C7, index);
  p.red   := inp($3C9);
  p.blue  := inp($3C9);
  p.green := inp($3C9);
  enable;
end;  {readpelreg}
procedure writepelreg(var p : pel);
begin
  disable;
  outp($3C8, p.index);
  outp($3C9, p.red);
  outp($3C9, p.blue);
  outp($3C9, p.green);
  enable;
end;  {writepelreg}
function setcomm(cmd : word) : word;
begin
  dac2comm;
  outp($3c6, cmd);
  dac2comm;
  setcomm := inp($3c6);
end;  {setcomm}
function dacis8bit : boolean;
var
  pel2, x, v : word;
  pel1 : pel;
begin
  pel2 := inp($3C8);
  readpelreg(255, pel1);
  v := pel1.red;
  pel1.red := 255;
  writepelreg(pel1);
  readpelreg(255, pel1);
  x := pel1.red;
  pel1.red := v;
  writepelreg(pel1);
  outp($3C8, pel2);
  dacis8bit := (x=255);
end;  {dacis8bit}
function prepDAC : word;     {Sets DAC up to receive command word}
begin
  dac2comm;
  prepDAC := inp($3C6);
  dac2comm;
end;  {prepDAC}
procedure dacmode(andmsk, ormsk : word);
begin
  ormsk := ormsk and (not andmsk);
  if DAC_RS2 <> 0 then
  begin
    outp($3C6+DAC_RS2,(inp($3C6+DAC_RS2) AND andmsk) OR ormsk);
  end
  else begin
    outp($3C6,(prepDAC AND andmsk) OR ormsk);
    dac2pel;
  end;
end;  {dacmode}
procedure testdac;      {Test for type of DAC}
begin
  DAC_RS2 := 0;
  { DAC_RS3 := 0; }
end;
procedure setdac6;
begin
  dacmode(0, 0);
end; {setdac6}
procedure setdac8;
begin
  dacmode($FD, 2);
end; {setdac8}
BEGIN  {main}
 testdac;
 dac8 := false;          {default is normal VGA 6 bit RGB values}
 InitGraph;
 IF LoadPalette(PalName, 0, actualColors) =0
  THEN BEGIN
        CloseRoutines;
        WRITELN('Couldn''t access file '+PalName+' : '+GetErrorMessage);
        Halt
       END
  ELSE BEGIN
       SetPalette(actualColors,TRUE);
       move(actualColors, Dac6Colors, SizeOf(Palette));
       END;
 { sample 8 bit palette converted from a 6 bit palette }
 move(actualColors, Dac8Colors, SizeOf(Palette));
 { index, red, green, blue }
 for i := 0 to 63 do begin
        Dac8Colors[i].red       := i*4;
        Dac8Colors[i].green     := 0;
        Dac8Colors[i].blue      := 0;
        Dac8Colors[i+$40].red   := 0;
        Dac8Colors[i+$40].green := i*4;
        Dac8Colors[i+$40].blue  := 0;
        Dac8Colors[i+$80].red   := 0;
        Dac8Colors[i+$80].green := 0;
        Dac8Colors[i+$80].blue  := i*4;
        Dac8Colors[i+$C0].red   := i*4;
        Dac8Colors[i+$C0].green := i*4;
        Dac8Colors[i+$C0].blue  := i*4;
 end; {for}
 LoadPage(Pic1, SCROLLPAGE);
 GetBackgroundFromPage(SCROLLPAGE);
 Animate; {just to initialize pages}
    repeat
         if keypressed then while keypressed do ch := upcase(readkey);
         case ch of
          'F': FadeIn(BACKGNDPAGE,2000,Fade_Squares);  { sample fade }
          'P': begin                                   { pixel noise }
                 FillPage(1-PAGE, Black);
                 FOR i := 1 TO 20000 DO
                 BEGIN
                  PutPixel(Random(Succ(XMAX)),Random(Succ(YMAX)),Random(256));
                 END;
               end;
          ' ': begin                         { Space toggles DAC 8/6 }
                dac8 := not dac8;
                if dac8 then begin
                     setdac8;
                     SetPalette(Dac8Colors, FALSE);
                     OutTextXY(16,10,BACKGNDPAGE,'DAC=8');
                     end
                else begin
                     setdac6;
                     SetPalette(Dac6Colors, FALSE);
                     end;
               end;
         end; {case}
    until (ch = #27)
    setdac6;
    dac2comm;     {Reset DAC}
    outp($3c6,0);
    dac2pel;
 CloseRoutines;
END.
