{
> Can you post the gif source and any other graphic source for doing this

Here is gif format (it doesn't get to full 768·1024·256)
or even less, but it is ok.
}

{$R-}{$S-}{$B-}
program GIF4TP;

uses
  crt, GRAPH;

const
  ProgramName = 'TP4GIF';
  ProgramRevision = '2';

type
  BufferArray = array[0..63999] of byte;
  BufferPointer = ^BufferArray;

var
  GifFile : file of BufferArray;
  InputFileName : string;
  RawBytes : BufferPointer;   { The heap array to hold it, raw    }
  Buffer : BufferPointer;     { The Buffer data stream, unblocked }
  Buffer2 : BufferPointer;    { More Buffer data stream if needed }
  Byteoffset,                 { Computed byte position in Buffer array }
  BitIndex                    { Bit offset of next code in Buffer array }
   : longint;

  Width,      {Read from GIF header, image width}
  Height,     { ditto, image height}
  LeftOfs,    { ditto, image offset from left}
  TopOfs,     { ditto, image offset from top}
  RWidth,     { ditto, Buffer width}
  RHeight,    { ditto, Buffer height}
  ClearCode,  {GIF clear code}
  EOFCode,    {GIF end-of-information code}
  OutCount,   {Decompressor output 'stack count'}
  MaxCode,    {Decompressor limiting value for current code size}
  CurCode,    {Decompressor variable}
  OldCode,    {Decompressor variable}
  InCode,     {Decompressor variable}
  FirstFree,  {First free code, generated per GIF spec}
  FreeCode,   {Decompressor, next free slot in hash table}
  RawIndex,     {Array pointers used during file read}
  BufferPtr,
  XC,YC,      {Screen X and Y coords of current pixel}
  ReadMask,   {Code AND mask for current code size}
  I           {Loop counter, what else?}
  :word;

  Interlace,  {true if interlaced image}
  AnotherBuffer, {true if file > 64000 bytes}
  ColorMap    {true if colormap present}
  : boolean;

  ch : char;
  a,              {Utility}
  Resolution,     {Resolution, read from GIF header}
  BitsPerPixel,   {Bits per pixel, read from GIF header}
  Background,     {Background color, read from GIF header}
  ColorMapSize,   {Length of color map, from GIF header}
  CodeSize,       {Code size, read from GIF header}
  InitCodeSize,   {Starting code size, used during Clear}
  FinChar,        {Decompressor variable}
  Pass,           {Used by video output if interlaced pic}
  BitMask,        {AND mask for data size}
  R,G,B
  :byte;

    {The hash table used by the decompressor}
  Prefix: array[0..4095] of word;
  Suffix: array[0..4095] of byte;

    {An output array used by the decompressor}
  PixelValue : array[0..1024] of byte;

    {The color map, read from the GIF header}
  Red,Green,Blue: array [0..255] of byte;
  MyPalette : PaletteType;

  TempString : String;

Const
 MaxCodes: Array [0..9] of Word = (4,8,16,$20,$40,$80,$100,$200,$400,$800);
 CodeMask:Array [1..4] of byte= (1,3,7,15);
 PowersOf2: Array [0..8] of word=(1,2,4,8,16,32,64,128,256);
 Masks: Array [0..9] of integer = (7,15,$1f,$3f,$7f,$ff,$1ff,$3ff,$7ff,$fff);
 BufferSize : Word = 64000;

function NewExtension(FileName,Extension : string) : string;
{
Places a new extension on to the file name.
}
var
  I : integer;
begin
  if (Extension[1] = '.') then delete(Extension,1,1);
  delete(Extension,4,251);
  I := pos('.',FileName);
  if (I = 0) then
  begin
    while (length(FileName) > 0) and (FileName[length(FileName)] = ' ')
      do delete(FileName,length(FileName),1);
    NewExtension := FileName + '.' + Extension;
  end else begin
    delete(FileName,I + 1,254 - I);
    NewExtension := FileName + Extension;
  end;
end; { NewExtension }

function Min(I,J : longint) : longint;
begin
  if (I < J) then Min := I else Min := J;
end; { Min }

procedure AllocMem(var P : BufferPointer);
var
  ASize : longint;
begin
  ASize := MaxAvail;
  if (ASize < BufferSize) then begin
    Textmode(15);
    writeln('Insufficient memory available!');
    halt;
  end else getmem(P,BufferSize);
end; { AllocMem }

function Getbyte : byte;
begin
  if (RawIndex >= BufferSize) then exit;
  Getbyte := RawBytes^[RawIndex];
  inc(RawIndex);
end;

function Getword : word;
var
  W : word;
begin
  if (succ(RawIndex) >= BufferSize) then exit;
  move(RawBytes^[RawIndex],W,2);
  inc(RawIndex,2);
  Getword := W;
end; { GetWord }

procedure ReadBuffer;
var
  BlockLength : byte;
  I,IOR : integer;
begin
  BufferPtr := 0;
  Repeat
    BlockLength := Getbyte;
    For I := 0 to Blocklength-1 do
    begin
      if RawIndex = BufferSize then
      begin
        {$I-}
        Read (GIFFile,RawBytes^);
        {$I+}
        IOR := IOResult;
        RawIndex := 0;
      end;
      if not AnotherBuffer
        then Buffer^[BufferPtr] := Getbyte
        else Buffer2^[BufferPtr] := Getbyte;
      BufferPtr := Succ (BufferPtr);
      if BufferPtr=BufferSize then begin
        AnotherBuffer := true;
        BufferPtr := 0;
        AllocMem (Buffer2);
      end;
    end;
  Until Blocklength=0;
end; { ReadBuffer }

procedure InitEGA;
var
  Driver,Mode : integer;
begin
  DetectGraph(Driver,Mode);
  InitGraph(Driver,Mode,'e:\bp\bgi');
  SetAllPalette(MyPalette);
  if (Background <> 0) then begin
    SetFillStyle(SolidFill,Background);
    bar(0,0,Width,Height);
  end;
end; { InitEGA }

procedure DetColor(var PValue : byte; MapValue : Byte);
{
Determine the palette value corresponding to the GIF colormap intensity
value.
}
var
  Local : byte;
begin
  PValue := MapValue div 64;
  if (PValue = 1)
    then PValue := 2
    else if (PValue = 2)
      then PValue := 1;
end; { DetColor }

procedure Init;
var
  I : integer;
begin
  XC := 0;          {X and Y screen coords back to home}
  YC := 0;
  Pass := 0;        {Interlace pass counter back to 0}
  BitIndex := 0;   {Point to the start of the Buffer data stream}
  RawIndex := 0;      {Mock file read pointer back to 0}
  AnotherBuffer := false;    {Over 64000 flag off}
  AllocMem(Buffer);
  AllocMem(RawBytes);
  InputFileName := NewExtension(InputFileName,'GIF');
  {$I-}
  Assign(giffile,InputFileName);
  Reset(giffile);
  I := IOResult;
  if (I <> 0) then begin
    textmode(15);
    writeln('Error opening file ',InputFileName,'. Press any key ');
    readln;
    halt;
  end;
  read(GIFFile,RawBytes^);
  I := IOResult;
{$I+}
end; { Init }

procedure ReadGifHeader;
var
  I : integer;
begin
  TempString := '';
  for I := 1 to 6 do TempString := TempString + chr(Getbyte);
  if (TempString <> 'GIF87a') then begin
    textmode(15);
    writeln('Not a GIF file, or header read error. Press enter.');
    readln;
    halt;
  end;
{
Get variables from the GIF screen descriptor
}
  RWidth := Getword;         {The Buffer width and height}
  RHeight := Getword;
{
Get the packed byte immediately following and decode it
}
  B := Getbyte;
  Colormap := (B and $80 = $80);
  Resolution := B and $70 shr 5 + 1;
  BitsPerPixel := B and 7 + 1;
  ColorMapSize := 1 shl BitsPerPixel;
  BitMask := CodeMask[BitsPerPixel];
  Background := Getbyte;
  B := Getbyte;         {Skip byte of 0's}
{
Compute size of colormap, and read in the global one if there. Compute
values to be used when we set up the EGA palette
}
  MyPalette.Size := Min(ColorMapSize,16);
  if Colormap then begin
    for I := 0 to pred(ColorMapSize) do begin
      Red[I] := Getbyte;
      Green[I] := Getbyte;
      Blue[I] := Getbyte;
      DetColor(R,Red[I]);
      DetColor(G,Green [I]);
      DetColor(B,Blue [I]);
      MyPalette.Colors[I] := B and 1 +
                    ( 2 * (G and 1)) + ( 4 * (R and 1)) + (8 * (B div 2)) +
                    (16 * (G div 2)) + (32 * (R div 2));
    end;
  end;
{
Now read in values from the image descriptor
}
  B := Getbyte;  {skip image seperator}
  Leftofs := Getword;
  Topofs := Getword;
  Width := Getword;
  Height := Getword;
  A := Getbyte;
  Interlace := (A and $40 = $40);
  if Interlace then begin
    textmode(15);
    writeln(ProgramName,' is unable to display interlaced GIF pictures.');
    halt;
  end;
end; { ReadGifHeader }

procedure PrepDecompressor;
begin
  Codesize := Getbyte;
  ClearCode := PowersOf2[Codesize];
  EOFCode := ClearCode + 1;
  FirstFree := ClearCode + 2;
  FreeCode := FirstFree;
  inc(Codesize); { since zero means one... }
  InitCodeSize := Codesize;
  Maxcode := Maxcodes[Codesize - 2];
  ReadMask := Masks[Codesize - 3];
end; { PrepDecompressor }

procedure DisplayGIF;
{
Decompress and display the GIF data.
}
var
  Code : word;

  procedure DoClear;
  begin
    CodeSize := InitCodeSize;
    MaxCode := MaxCodes[CodeSize-2];
    FreeCode := FirstFree;
    ReadMask := Masks[CodeSize-3];
  end; { DoClear }

  procedure ReadCode;
  var
    Raw : longint;
  begin
    if (CodeSize >= 8) then begin
      move(Buffer^[BitIndex shr 3],Raw,3);
      Code := (Raw shr (BitIndex mod 8)) and ReadMask;
    end else begin
      move(Buffer^[BitIndex shr 3],Code,2);
      Code := (Code shr (BitIndex mod 8)) and ReadMask;
    end;
    if AnotherBuffer then begin
      ByteOffset := BitIndex shr 3;
      if (ByteOffset >= 63000) then begin
        move(Buffer^[Byteoffset],Buffer^[0],BufferSize-Byteoffset);
        move(Buffer2^[0],Buffer^[BufferSize-Byteoffset],63000);
        BitIndex := BitIndex mod 8;
        FreeMem(Buffer2,BufferSize);
      end;
    end;
    BitIndex := BitIndex + CodeSize;
  end; { ReadCode }

  procedure OutputPixel(Color : byte);
  begin
    putpixel(XC,YC,Color); { about 3x faster than using the DOS interrupt! }
    inc(XC);
    if (XC = Width) then begin
      XC := 0;
      inc(YC);
      if (YC mod 10 = 0) and keypressed and (readkey = #27) then begin
        textmode(15);  { let the user bail out }
        halt;
      end;
    end;
  end; { OutputPixel }



begin { DisplayGIF }
  CurCode := 0; { not initted anywhere else... don't know why }
  OldCode := 0; { not initted anywhere else... don't know why }
  FinChar := 0; { not initted anywhere else... don't know why }
  OutCount := 0;
  DoClear;      { not initted anywhere else... don't know why }
  repeat
    ReadCode;
    if (Code <> EOFCode) then begin
      if (Code = ClearCode) then begin { restart decompressor }
        DoClear;
        ReadCode;
        CurCode := Code;
        OldCode := Code;
        FinChar := Code and BitMask;
        OutputPixel(FinChar);
      end else begin        { must be data: save same as CurCode and InCode }
        CurCode := Code;
        InCode := Code;
{ if >= FreeCode, not in hash table yet; repeat the last character decoded }
        if (Code >= FreeCode) then begin
          CurCode := OldCode;
          PixelValue[OutCount] := FinChar;
          inc(OutCount);
        end;
{
Unless this code is raw data, pursue the chain pointed to by CurCode
through the hash table to its end; each code in the chain puts its
associated output code on the output queue.
}
        if (CurCode > BitMask) then repeat
          PixelValue[OutCount] := Suffix[CurCode];
          inc(OutCount);
          CurCode := Prefix[CurCode];
        until (CurCode <= BitMask);
{
The last code in the chain is raw data.
}
        FinChar := CurCode and BitMask;
        PixelValue[OutCount] := FinChar;
        inc(OutCount);
{
Output the pixels. They're stacked Last In First Out.
}
        for I := pred(OutCount) downto 0 do OutputPixel(PixelValue[I]);
        OutCount := 0;
{
Build the hash table on-the-fly.
}
        Prefix[FreeCode] := OldCode;
        Suffix[FreeCode] := FinChar;
        OldCode := InCode;
{
Point to the next slot in the table. If we exceed the current MaxCode
value, increment the code size unless it's already 12. if it is, do
nothing: the next code decompressed better be CLEAR
}
        inc(FreeCode);
        if (FreeCode >= MaxCode) then begin
          if (CodeSize < 12) then begin
            inc(CodeSize);
            MaxCode := MaxCode * 2;
            ReadMask := Masks[CodeSize - 3];
          end;
        end;
      end; {not Clear}
    end; {not EOFCode}
  until (Code = EOFCode);
end; { DisplayGIF }

begin { TP4GIF }
  writeln(ProgramName,' Rev ',ProgramRevision);
  if (paramcount > 0)
    then TempString := paramstr(1)
  else begin
    write(' > ');
    readln(TempString);
  end;
  InputFileName := TempString;
  Init;
  ReadGifHeader;
  PrepDecompressor;
  ReadBuffer;
  FreeMem(RawBytes,BufferSize);
  InitEGA;
  DisplayGIF;
  SetAllPalette(MyPalette);
  close(GifFile);
  Ch := readkey;
  textmode(15);
  freemem(Buffer,BufferSize);        { totally pointless, but it's good form }
end.
