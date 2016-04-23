{
>Does anyone know of any way to display a single screen of Graphics on EGA
>640x350 mode *quickly*.  It can be VGA as well; I'm just trying to display t
>screen *fast* from a disk File.  I know, I could have used the GIF or PCX

This would restore a .PIC format File, uncompressed, For 320x200x256
mode $13, With a prepended 256*3 Byte palette entry header.  It should
work- I just wrote this code yesterday to display some unknown .PIC
Files.
}

Program dispic;
Const
  maxpicsize = 320*200;
Type
  pbuf = ^abuf;
  abuf=Array[1..maxPICSIZE] of Byte;
  palbuf = ^apalbuf;
  apalbuf=Array[1..256*3] of Byte;
  headerbuf=^aheaderbuf;
  aheaderbuf=Array[1..32] of Byte;
Var
  f : File;
  i : Byte;
  buf : pbuf;
  pal : palbuf;
  header : headerbuf;
  hsize,vsize,picsize,headersize,palettesize:Word;
  _r,_g,_b,
  cr : Byte;
  nr,ctr : Word;
  fs,overflow : LongInt;
  Filename : String;


Procedure setcolreg(p:Pointer;start,num:Word);
begin
  Asm
    mov  ah,10h
    mov  al,12h           { seg block of color Registers }
    mov  bx,start
    mov  cx,num
    mov  dx,Word ptr p+2  { get high Word of p (seg) }
    mov  es,dx
    mov  dx,Word ptr p    { get low Word of p (ofs) }
    int  $10
  end;
end;

Procedure stop(s:String);
begin
  Writeln(s);
  halt;
end;

begin
  Writeln('DISPIC v0.01ß (c)1993 Brian Pape/Jagaer Technologies'+#10#13);
  Writeln(maxavail,' Bytes available.');
  if paramcount < 1 then
    stop('no .PIC File specified.');
  Filename := paramstr(1);
  assign(f,Filename);
  {$I-} reset(f,1); {$I+}
  if ioresult <> 0 then
    begin
      Writeln('File '+Filename+' not found.');
      halt;
    end;
  new(header);
  Writeln(maxavail,' Bytes available after header allocate.');
  palettesize := sizeof(pal^);
  headersize := sizeof(header^);

  if Filesize(f) < headersize+palettesize then stop('invalid .pic File.');

  blockread(f,header^,headersize,nr);
  if nr < sizeof(headersize) then
    stop('insufficient header information.')
  else
    Writeln('header: ',nr,' Bytes read.');
  hsize := (Word(header^[4]) shl 8) or header^[3];
  vsize := (Word(header^[6]) shl 8) or header^[5];

  picsize := (Word(header^[14]) shl 8) or header^[13];
  Writeln('picsize: ',picsize,' Bytes.');
  if picsize > maxpicsize then
    begin
      picsize := maxpicsize;
      Writeln('picture size read overflow. resetting to maxpicsize.');
    end;

  dispose(header);
  new(pal);
  Writeln(maxavail,' Bytes available after palette allocate.');

  blockread(f,pal^,palettesize,nr);
  if nr < palettesize then
    stop('insufficient palette information.')
  else
    Writeln('palette: ',nr,' Bytes read.');

  new(buf);
  Writeln(maxavail,' Bytes available after buffer allocate.');
  {$I-} blockread(f,buf^,sizeof(buf^),nr); {$I+}
  if ioresult <> 0 then;
  Writeln('picture: ',nr,' Bytes read.');
  Writeln('hsize: ',hsize);
  Writeln('vsize: ',vsize);
  Writeln('press enter.');
  readln;
  close(f);
  Asm
    mov ah,00
    mov al,$13
    int $10
  end;
  move(buf^,ptr($a000,0)^,nr);

  setcolreg(pal,0,256);

  dispose(buf);
  dispose(pal);
  readln;
  Asm
    mov ah,00
    mov al,03
    int $10
  end;
end.

{
> Hello is somebody there that knows how to use pictures that I
> made in Deluxe paint (.lbm)

First, convert the LBM File to a SCI using For instance VPIC.
I assume you are using VGA/MCGA 320x200x256.. In Case you don't,
this won't work...:
}
Uses
  Crt;
Var
  SCIFile : File;
  r, g, b : Byte;
  i       : Integer;
  VideoM  : Byte Absolute $A000:0000;
begin
  Asm
    mov ax,0013h
    int 10h
  end;

  Assign(SCIFile, 'MYSCI.SCI');   { Put your own Filename there }
  Reset(SCIFile, 1);

  For i := 0 to 255 do begin
    Port[$3C8] := i;
    BlockRead(SCIFile,r,1);
    BlockRead(SCIFile,g,1);
    BlockRead(SCIFile,b,1);
    Port[$3C9] := r;
    Port[$3C9] := g;
    Port[$3C9] := b;              { Set palette }
   end;

  BlockRead(SCIFile,VideoM,64000);
  Repeat Until Port[$60] = 1;     { Wait For ESC }

  Asm
    mov ax,0003h
    int 10h
  end;
end.

{
> I am looking to create a simple utility to report the size, color, etc
> of GIFs.
}

Program GI;
Uses
  Dos;

Procedure ExtractGIFInfo (Name : String);

Const
  ColorRez : Array[1..8] of Byte=(1,3,7,15,31,63,127,255);

Type
  GifSigRec = Array[1..6] of Char;

  ScreenDiscRec = Record
    Width,
    Height:Word;
    GenInfo:Byte;
  end;

Var
  F       : File;
  Sig     : GIFSigRec;
  Screen  : ScreenDiscRec;
  Result  : Word;
  Diver,
  X       : Byte;
  Y       : LongInt;
  DirInfo : SearchRec;
  Ratio   : Byte;
  Res     : Word;
  RReal   : Real;

begin
  Assign(F, Name);
  Reset(F, 1);
  BlockRead(F, Sig, SizeOF(Sig), Result);
  BlockRead(F, Screen, SizeOf(Screen), Result);
  Close(F);

  If (Sig[1] + Sig[2] + Sig[3] <> 'GIF') Then
  begin
    WriteLn('Not a Valid .GIF File!');
    Exit;
  end;

  For X := 1 to 6 do
    Write(Sig[X]);
  Write(', ', Screen.Width, 'x', Screen.Height, 'x');
  Screen.GenInfo := (Screen.GenInfo and 7) + 1;
  Res := ColorRez[Screen.GenInfo] + 1;
  WriteLn(Res);
end;

Var
  Count : Byte;
begin
  If ParamCount >= 1 then
    For Count := 1 to ParamCount do
      ExtractGIFInfo (ParamStr(Count))
  else
    WriteLn(' Use a Filename geek!');
end.
Had the PCX info:

ZSoft .PCX File HEADER ForMAT

Byte Item         Size Description/Comments

0    Manufacturer  1    Constant Flag, 10 = ZSoft .pcx

1    Version       1    Version inFormation
            0 = Version 2.5 of PC Paintbrush
            2 = Version 2.8 w/palette inFormation
            3 = Version 2.8 w/o palette inFormation
            4 = PC Paintbrush For Windows(Plus For Windows
                Uses Ver 5)
            5 = Version 3.0 and > of PC Paintbrush and
                PC Paintbrush +, includes Publisher's Paintbrush

2    Encoding       1   1 = .PCX run length encoding

3    BitsPerPixel   1   Number of bits to represent a pixel (per
                                Plane)- 1, 2, 4, or 8

4    Window         8   Image Dimensions: Xmin,Ymin,Xmax,Ymax

12   HDpi           2   Horizontal Resolution of image in DPI*

14   VDpi           2   Vertical Resolution of image in DPI*

16   Colormap       48  Color palette setting, see Text

64   Reserved       1   Should be set to 0.

65   NPlanes        1   Number of color planes

66   BytesPerLine   2   Number of Bytes to allocate For a scanline
                        plane.  MUST be an EVEN number.  Do not
                        calculate from Xmax-Xmin.

68   PaletteInfo    2   How to interpret palette- 1 = Color/BW, 2 =
                                Grayscale (ignored in PB IV/ IV +)

70   HscreenSize    2   Horizontal screen size in pixels.

New field found only in PB IV/IV Plus

72   VscreenSize    2   Vertical screen size in pixels.

New field found only in PB IV/IV Plus

74   Filler         54  Blank to fill out 128 Byte header.  Set all
                        Bytes to 0

notES:

All sizes are measured in ByteS.

All Variables of SIZE 2 are Integers.

*HDpi and VDpi represent the Horizontal and Vertical resolutions
which the image was created (either Printer or scanner); i.e. an
image which was scanned might have 300 and 300 in each of these
fields.
{
> Does anyone have the format structure For PCX format? I had it
> once but I lost it... It had a header (big surprise), and used
> run-length compression (HAHAHAHAHA!!!!), but it seems the easiest major
> format to code.

  Here's the header, I haven't fooled much With coding/decoding PCX
but if I remember right (At least For 256c images) the run
length-Byte is up to 64 since the most-significant bits signify the
end of a line in the image.  And in 256c images, the last 768 Bytes
should be the palette.
}

PCXHeader   =  Record
  Signature      :  Char;
  Version        :  Char;
  Encoding       :  Char;
  BitsPerPixel   :  Char;
  XMin,YMin,
  XMax,YMax      :  Integer;
  HRes,VRes      :  Integer;
  Palette        :  Array [0..47] of Byte;
  Reserved       :  Char;
  Planes         :  Char;
  BytesPerLine   :  Integer;
  PaletteType    :  Integer;
  Filler         :  Array [0..57] of Byte;
end;

