{
> Could someone maybe tell me how to display
> a 640X480X256 .gif?  Thanks a bunch...

     Here's some Gif routines i found... Have fun!
}

{**************************************************************
**                   GIFVIEW  Version 1.0                    **
**         Made by: Lars Fastrup Nielsen, March 1991         **
**                                                           **
**                Please distribute freely.                  **
**************************************************************}
{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}
program GifView;

{Includes for external .OBJ files.}
{$L nlzw}
{$L readrast}

uses
  crt, dos, CrtModes;

const
  Select320x200x256 = 1;          {Videomode supported by BIOS.}
  Select320x400x256 = 2;          {Videochip is reprogrammed.}
  Select360x480x256 = 3;          {Videochip is reprogrammed.}
  Select640x480x256 = 4;          {Simulated videomode.}
  Select512x480x256 = 5;          {Simulated videomode.}

  BufferSize        = 64000;      {Size of GIFStuff and Raster array.}

  {MaxCode values for differing code sizes}
  MaxCodes: Array [0..9] of Word = (4,8,16,$20,$40,$80,$100,$200,$400,$800);

  {Saves computing these values, Pascal having no exponentiation}
  PowersOf2: Array [0..8] of word=(1,2,4,8,16,32,64,128,256);

type
  PaletteType  = array [0..255] of word;
  BufferArray  = array [0..BufferSize] of byte;
  BufferP      = ^BufferArray;

var
  GIFFile  : file;      {GIF input file.}
  GIFStuff : BufferP;   {Raw data, read directly from file.}
  Raster   : BufferP;   {Unblocked rasterdata ready to decode.}

  {Info read form GIF header.}
  RasterWidth,     {X-coordinate resolution. (eks. 320,360,640,800 or 1024)}
  RasterHeight,    {Y-coordinate resolution. (eks. 200,400,480,600 or 768)}
  ImageLeft,       {Image offset from the left.}
  ImageTop,        {Image offset from the top.}
  ImageWidth,      {Width of picture in pixels. (Often equal to RasterWidth)}
  ImageHeight,     {Height of picture in pixels. (Often equal to RasterHeight)}
  ColorMapSize,    {Number of colors in picture. Used when reading colormap.}

  Freecode,        {Next free code, used by decompressor.}
  Clearcode,       {GIF clear code.}
  Bitmask,         {Used during read from compressed file.}
  Maxcode,         {Decompressor limiting value for current code size.}
  FirstFree,       {First free code, generated per GIF spec.}
  Codesize,        {Size of code, computed from GIF header.}
  Readmask,        {Code AND mask for current code size.}
  EOFCode,         {GIF end-of-information code.}
  GIFPtr,          {Index pointer for GIFStuff ARRAY.}
  RasterPtr,       {Index pointer for Raster ARRAY.}
  BufSize,         {Size of GIFStuff and Raster ARRAY.}
  Work             {Utility}
  : word;

  BitsPerPixel,    {Bits per pixel, read from GIF header.}
  Resolution,      {Resolution, read from GIF header.}
  Background,      {Background color, read from GIF header.}
  InitCodeSize,    {Starting code size, used during Clear.}
  BlockPtr,        {Index pointer for a block in GIFStuff ARRAY.}
  BlockSize,       {Size of current block in GIFStuff ARRAY.}
  SelectMode       {Video mode.}
  : byte;

  key : char;      {Keyboard input.}

  ZeroBitOffset    {Used when calling ReadRaster the first time.}
  : longint;

  ColorMap,        {True if colormap present.}
  Interlace,       {True if interlaced image.}
  Clear,           {True during clear.}
  First
  : boolean;

  {The global colormap read from the GIF header.}
  Red,Green,Blue : PaletteType;      {Original colormap read from GIF header.}
  R,G,B          : PaletteType;    {Real colors calculated by CalcRealColors.}

  Search         : searchrec;

{****************************************************************************}

procedure nlzw; external;
{Decompress and show picture.}

procedure unblockraster; external;
{Unblock Rasterdata from GIFStuff to Raster.}

{****************************************************************************}

function DetermineVideoMode (Width,Height : word) : byte;
{Determine which videomode to display picture in.}

var
  Mode : byte;

begin
  mode := 0;                 {No videomode selected.}

  if Width <= 640 then
  begin
    if Height <= 480 then Mode := Select640x480x256;
  end;
  if Width <= 512 then
  begin
    if Height <= 480 then Mode := Select512x480x256;
  end;
  if Width <= 360 then
  begin
    if Height <= 480 then Mode := Select360x480x256;
  end;
  if Width <= 320 then
  begin
    if Height <= 400 then Mode := Select320x400x256;
    if Height <= 200 then Mode := Select320x200x256;
  end;

  DetermineVideoMode := mode;
end; {DetermineVideoMode}

{****************************************************************************}

procedure Terminate (errormsg : string);
begin
  textmode(5);
  writeln (errormsg);
  if GIFStuff <> nil then freemem (GIFStuff,BufSize);
  if Raster <> nil then freemem (Raster,BufSize);
  halt;
end; {Terminate}

{****************************************************************************}

procedure AllocMem (var P:BufferP);
{Allocate memory for GIFStuff- or RasterArray.}

begin
  If BufSize > MaxAvail then
  begin
    textmode (15);
    Terminate ('Out of memory!');
  end else
    getmem (P,BufSize);                     {Allocate memory.}
end; {AllocMem}

{****************************************************************************}

procedure ReadMore;
{Read more data from GIFFile into GIFStuff array.}

var
  BytesRead  : word;

begin
  GIFPtr := 0;                              {Point on first byte in GIFStuff.}
  blockread(GIFFile,GIFStuff^,BufSize,BytesRead);
  if ioresult <> 0 THEN Terminate ('Error reading from file');
end; {ReadMore}

{****************************************************************************}

function GetByte : byte;
{Get next byte from GIFStuff array. Call Readmore if end of GIFStuff.}

begin
  GetByte := GIFStuff^[GIFPtr];
  GIFPtr  := succ(GIFPtr);
  if GIFPtr = BufSize then ReadMore;
end; {GetByte}

{****************************************************************************}

function GetWord : word;
{Get a word from GIFStuff array. Read low byte first, and then highbyte.}

var
  low,high : byte;

begin
  low  := GetByte;
  high := GetByte;
  GetWord := high*256+low;
end; {GetWord}

{****************************************************************************}

procedure ReadRaster (var BitOffset : longint);
{When unblocking Rasterdata, "ReadRaster" prepares RasterArray and RasterPtr}
{before "UnblockRaster" is called.}

var
  ByteOffset : word;

begin
  ByteOffset := BitOffset div 8;

  if ByteOffset = 0 then
  begin
    BlockSize := GetByte;
    BlockPtr  := 0;
    RasterPtr := 0;
  end else
  begin
    {Move the last bytes in RasterArray to the start of RasterArray.}
    {This must be done because readcode who calls this procedure, does}
    {not always read to the end of RasterArray. Also remember to set}
    {RasterPtr to number of bytes moved, so they are not overwritten}
    {when unblocking new rasterdata from GIFStuff.}
    move(Raster^[ByteOffset],Raster^[0],BufSize-ByteOffset+1);
    BitOffset := BitOffset mod 8;        {If BitOffset was odd to ByteOffset.}
    RasterPtr := BufSize-ByteOffset+1;
  end;

  UnblockRaster;
end; {ReadRaster}

{****************************************************************************}

function ValidGIFFile : boolean;
{Check if file really is a GIFfile. This is done by checking if the}
{first 6 bytes of the GIFfile matches the string: 'GIF87a'.}

var
  idstring : string[6];
  cnt      : byte;

begin
  idstring := '';
  for cnt := 1 to 6 do
    idstring := idstring + chr(GetByte);
  ValidGIFFile := idstring = 'GIF87a';
end; {ValidGIFFile}

{****************************************************************************}

procedure CalcRealColors (Colors : word; Intensity : byte;
                          var R,G,B : PaletteType);
{Colors from global colormap can't be used directly in the video DAC, }
{therefore new values are computed here.}

var
  Cnt : byte;

begin
  for Cnt := 0 to Colors-1 do
  begin
    R[Cnt] := round (Intensity*(Red[Cnt] / 255));
    G[Cnt] := round (Intensity*(Green[Cnt] / 255));
    B[Cnt] := round (Intensity*(Blue[Cnt] / 255));
  end;
end; {CalcRealColors}

{****************************************************************************}

procedure ReprogramDAC (Colors : word; var R,G,B : PaletteType);
{Sets the colorpalette in the video DAC.}

var
  Cnt : byte;

begin
  port[$03c4] := 1;                   {Select Clocking Mode Register.}
  port[$03c5] := port[$03c5] or 32;   {Turn Screen Off. (Prevent snow)}

  port[$03c8] := 0;                   {Color register 0 of 256.}
  inline ($fa);                       {cli, CLear Interrupts.}
  for Cnt := 0 to Colors-1 do
  begin
    port[$03c9] := R[cnt];
    port[$03c9] := G[cnt];
    port[$03c9] := B[cnt];
  end;
  inline ($fb);                       {sti, SeT Interrupts.}

  port[$03c4] := 1;                   {Select Clocking Mode Register.}
  port[$03c5] := port[$03c5] and 223; {Turn Screen On.}
end; {ReprogramDAC}

{****************************************************************************}

procedure DoClear;
{This procedure is called by NLZW when a clearcode is picked up.}

begin
  CodeSize := InitCodeSize;
  MaxCode  := MaxCodes [CodeSize-2];
  FreeCode := FirstFree;
  ReadMask := (1 shl CodeSize)-1;
end; {DoClear}

{****************************************************************************}

begin { main program }
  BufSize  := BufferSize;
  GIFStuff := nil;
  Raster   := nil;
  First    := true;

  writeln ('GifView V1.0, by Lars Fastrup Nielsen, March 1991');
  if paramcount < 1 then
    Terminate ('USAGE: <filename.gif>  *,? wildcards ok!');

  AllocMem (GIFStuff);
  AllocMem (Raster);

  findfirst (PARAMSTR(1),anyfile,Search);
  while doserror = 0 do
  begin
    assign (GIFFile,Search.name);
    reset (GIFFile,1);
    if ioresult <> 0 then Terminate ('Error opening GIF-file!!');
    ReadMore;
    if NOT ValidGIFFile then Terminate ('Not a GIF-file!!');

    RasterWidth  := GetWord;
    RasterHeight := GetWord;

    {Get the packed byte immediately following and decode it. JG}
    Work := GetByte;
    ColorMap := (Work AND $80) = $80;
    Resolution := (Work and $70 shr 5)+1;
    BitsPerPixel := (Work and 7)+1;
    BitMask := (1 shl BitsPerPixel)-1;
    Background := GetByte;
    Work := GetByte;        { Skip '0' }

    {Determine number of colors in picture.}
    ColorMapSize := 1 shl BitsPerPixel;

    {Read global colormap if one present.}
    if ColorMap then
    begin
      for Work := 0 to ColorMapSize-1 do
      begin
        Red[Work]   := GetByte;
        Green[Work] := GetByte;
        Blue[Work]  := GetByte;
      end;
      CalcRealColors (ColorMapSize,63,R,G,B);
    end else
      Terminate ('I can only process GIF pictures with global colormap');

    if chr(GetByte) <> ',' then Terminate ('Bad image separator!');

    {Now read the values from the image descriptor. JG}
    ImageLeft   := GetWord;       {Left offset, ignored by this program.}
    ImageTop    := GetWord;       {Top offset, also ignored here.}
    ImageWidth  := GetWord;       {The actual width of picture. Used by NLZW.}
    ImageHeight := GetWord;       {The actual height of picture. Ignored.}
    Work := GetByte;

    {Determine wether picture is interlaced or not.}
    Interlace := (Work and $40) = $40;
    if Interlace then
      Terminate ('Displaying interlaced pictures not supported yet!');

    {Start reading the raster data. First we get the intial code size. JG}
    CodeSize := GetByte;

    {Compute decompressor constant values based on the codesize. JG}
    ClearCode := PowersOf2[CodeSize];
    EOFCode := ClearCode+1;
    FirstFree := ClearCode+2;
    FreeCode := FirstFree;

    {The GIF spec has it that the code size used to compute the above values}
    {is the code size given in the file, but the code size used in}
    {compression/decompression is the code size given in the file plus one. JG}
    CodeSize := succ(CodeSize);
    InitCodeSize := CodeSize;
    MaxCode := MaxCodes[CodeSize-2];
    ReadMask := (1 shl CodeSize)-1;

    {I don't know why i can't call ReadRaster(0) but the compiler wont}
    {accept that. So it was nessesary to create the ZeroBitOffset variable.}
    {It is only a dummy variable and is only used here.}
    ZeroBitOffset := 0;
    ReadRaster (ZeroBitOffset);   

    if not First then delay (7000);
    First := false;

    SelectMode := DetermineVideoMode(RasterWidth,RasterHeight);
    case SelectMode of
      Select320x200x256 : SetMode(mode320x200x256);
      Select320x400x256 : SetMode(mode320x400x256);
      Select360x480x256 : SetMode(mode360x480x256);
      Select512x480x256 : SetMode(mode360x480x256);
      Select640x480x256 : SetMode(mode360x480x256);
    else
      Terminate ('Picture does not fit on any modes!');
    end;

    ReprogramDAC (ColorMapSize,R,G,B);      {Set the color palette.}

    Clear := false;
    nlzw;

    close(GIFFile);
    findnext (Search);
  end; { while }

  sound (1800); delay (40);
  sound (1500); delay (40);
  nosound;

  repeat until readkey=#13;

  textmode (5);
  freemem (GIFStuff,BufSize);
  freemem (Raster,BufSize);
end.
