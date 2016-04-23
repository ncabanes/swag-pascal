program Bitmapld;
Uses
  DOS,
  CRT;

{FUNCTION:
  Loads and displays a mono .BMP bitmap file in
  Colour EGA/VGA text mode.
}

const
  CHAR_WIDTH = 8; {Width of chars in usable pixels}

{*********** `Spare' characters overwitten by bitmap}
{Edit this to suit your requirements}
  GRABCHRS_STR : String =
  #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15 +
  #16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31 +
  '!"#$%&'#39'()*+,-./' +
  '0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVW' +
  'XYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~' +
  'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥₧ƒáíóúñÑªº' +
  '¿⌐¬½¼¡«»░▒▓│┤╡╢╖╕╣║╗╝╜╛┐' +
  'αßΓπΣσµτΦΘΩδ∞φε∩≡±≥≤⌠⌡÷≈' +
  '°∙·√ⁿ²■ ';

type
{*********** .BMP file data structures}
  TBitMapFileHeader = record
    bfType           : Word;
    bfSize           : LongInt;
    bfReserved1      : Word;
    bfReserved2      : Word;
    bfOffbits        : LongInt;
  end; {TBitMapFileHeader}

  TRgbQuad          = record
    rgbBlue	     : Byte;
    rgbGreen	     : Byte;
    rgbRed	     : Byte;
    rgbReserved	     : Byte;
  end; {TRgbQuad}

  TBitMapInfoHeader = record
    biSize           : LongInt;
    biWidth	     : LongInt;
    biHeight	     : LongInt;
    biPlanes	     : Word;
    biBitCount	     : Word;

    biCompression    : LongInt;
    biSizeImage	     : LongInt;
    biXPelsPerMeter  : LongInt;
    biYPelsPerMeter  : LongInt;
    biClrUsed	     : LongInt;
    biClrImportant   : LongInt;
  end; {TBitMapInfoHeader}

  TBitMapInfo       = record
    bmHeader         : TBitMapInfoHeader;
    bmiColors        : array [0..0] of TRgbQuad;
  end; {TBitMapInfo}

  TBitMapContents  = record
    case Boolean of
    True:   (bmcHeader  : TBitMapFileHeader;
             bmcInfo    : TBitMapInfo);
    False:  (bmcByte    : array[0..100] of Byte);
   end; {TBitMapContents}

  PBitMapContents = ^TBitMapContents;

{*********** Character Map Structures}
  TCharMap = array[0..31] of Byte;
  TCharMapArray = array[0..255] of TCharMap;

{*********** Global variables}
var
  { Addresses assume colour EGA/VGA }
  CRT_COLS        : Word absolute $0040:$004A;
  CRT_ROWS_MINUS_1: Byte absolute $0040:$0084;
  POINTS          : Word absolute $0040:$0085;

  CharMapArray    : TCharMapArray
                         absolute $A000:$0000;
  ScreenBuffer    : array[0..$fff] of Byte
                         absolute $B800:0000;
  TempVideoBuffer : array[0..$fff] of Byte;

  {Shorthand for GRABCHRS' length byte}
  NOGRABCHRS : byte absolute GRABCHRS_STR;
  {Easy access to GRABCHRS}
  GRABCHRS : array[-1..255] of Byte
                            absolute GRABCHRS_STR;
  {Stores default Exit procedure pointer}
  ExitSave : Pointer;

{*********** Code begins}

function LoadBitMapFile(fname : String;
                        var FSize : LongInt)
                                  : Pointer;
var
  buffer : Pointer;
  Infile : File;
begin
  Assign(Infile, fname);
{$I-}
  Reset(Infile,1);
  if IOresult <> 0 then
  begin
    Writeln('Error opening file ',fname);
    Exit;
  end;
{$I+}
  FSize := FileSize(Infile);
  GetMem(buffer,Fsize);
  Reset(Infile,Fsize);
  if buffer <> nil then
    BlockRead(Infile,buffer^,1)
  else
    WriteLn('Error: File too big to load');
  Close(Infile);
  LoadBitMapFile := Buffer;
end; {LoadBitMapFile}

procedure ProcessBitMap(Buffer : PBitMapContents;
                                 row, col : Byte);
{ Displays the bitmap Buffer, with top left
  corner at position (row, col)             }

type
  TByteBuffer = array[0..32767] of Byte;
  TSeqAndGCparms = array [0..3] of Word;

const
  SeqparmsSet : TSeqAndGCparms =
    ($100, $402, $704, $300);
  GCParmsSet  : TSeqAndGCparms =
    ($204, $005, $006, 0);
  SeqparmsClr : TSeqAndGCparms =
    ($100, $302, $304, $300);
  GCParmsClr  : TSeqAndGCparms =
    ($004, $1005, $0E06, 0);


var
  BMData : ^TByteBuffer;
  BMBytesPerRow,
  CurX, CurY,
  WidthInChars, HeightInChars,
  CharsUsedUp : Integer;
  CharMap : TCharMap;
  lastrow, endrow, endmask : Byte;

  procedure SetUp;
  var
    PixelWidth : Word;
    CRT_ROWS   : Byte;
  begin
    {Get start address of bitmap data}
    with Buffer^ do
      BMData := @bmcByte[bmcHeader.bfOffBits];

    with Buffer^.bmcInfo.bmHeader do
    begin
      BMBytesPerRow := 4 * ((biWidth + 31) div 32);
      {Get Clipped Width}
      if biWidth > (CHAR_WIDTH * CRT_COLS) then
        biWidth := (CHAR_WIDTH * CRT_COLS);
      WidthInChars := (biWidth + CHAR_WIDTH - 1)
                                  div CHAR_WIDTH;
      if biWidth = (WidthInChars * CHAR_WIDTH) then
        endmask := $FF
      else
        endmask := Byte($FF shl (CHAR_WIDTH -
                          biWidth mod CHAR_WIDTH));
      CRT_ROWS := Succ(CRT_ROWS_MINUS_1);
      {Get Clipped Height}
      if biHeight > (POINTS * CRT_ROWS) then
        biHeight := (POINTS * CRT_ROWS);
      HeightInChars := (biHeight + Pred(POINTS))
                                        div POINTS;
      endrow := POINTS - Pred(biHeight) mod POINTS;
    end; {with}
  end; {SetUp}

procedure cGenMode(var Seqparms, GCparms:
                                   TSeqAndGCparms);
var i : Integer;
begin
  asm cli end; {Disable interrupts}
  for i := 0 to 3 do
    PortW[$03c4] := Seqparms[i];
  asm sti end;
  for i := 0 to 2 do
    PortW[$03ce] := GCparms[i];
end;

  procedure MapToChar;
  var
    i, offset : Integer;
    mask : Byte;
  begin
    if CurX = WidthInChars - 1 then
      mask := endmask
    else
      mask := $FF;
    offset := Succ(CurY) * POINTS * BMBytesPerRow
                                             + CurX;
    CharMap[POINTS] := 0; {Zero checksum}
    for i := 0 to POINTS - 1 do
    begin
      if i >= lastrow  then
        CharMap[i] := BMData^[offset] and mask
      else
        CharMap[i] := 0;
      Inc(CharMap[POINTS], CharMap[i]);
      Dec(offset,BMBytesPerRow);
    end;
  end; {MapToChar}

  procedure PlotChar(character : Byte);
  begin
    TempVideoBuffer[((HeightInChars - CurY + row - 1)
                    * CRT_COLS + CurX + col) * 2]
                                        := character;
  end; {PlotChar}


  function FoundInStore : Boolean;

    function Comp(var Buf1, Buf2 : TCharMap;
                      POINTS     : Word)
                              : Boolean; assembler;
    asm
      push	ds
{ Move default return to ax - 'True'}
      mov       ax, 1
      lds	si, Buf1
      add       si, [POINTS]
      les	di, Buf2
      add       di, [POINTS]
      mov	cx, [POINTS]
      inc       cx
{ Search backwards to find checksum 1st}
      std
      rep	cmpsb
      je	@@Exit
{ Flag failed match in return }
      xor	ax, ax
@@Exit:
      pop	ds
end;

  var
    i : Integer;
  begin
    FoundInStore := True;
    for i := 0 to Pred(CharsUsedUp) do
      if Comp(CharMapArray[GRABCHRS[i]],
               CharMap,POINTS)            then
      begin
        PlotChar(GRABCHRS[i]);
        Exit;
      end;
    FoundInStore := False;
  end;

begin  { ProcessBitMap }
  Setup;
  Move(ScreenBuffer, TempVideoBuffer,
                     Sizeof(TempVideoBuffer));
  cGenMode(SeqparmsSet, GCParmsSet);
  CharsUsedUp := 0; lastrow := 0;
  CurX := 0; CurY := 0;
  repeat
    MapToChar;
    if not FoundInStore then
    begin
      Move(CharMap,
           CharMapArray[GRABCHRS[CharsUsedUp]],
           Succ(Points));
      PlotChar(GRABCHRS[CharsUsedUp]);
      Inc(CharsUsedUp);
    end;
    CurX := (CurX + 1) mod WidthInChars;
    if (CurX = 0) then
    begin
      Inc(CurY);
      if CurY = HeightInChars - 1 then
        lastrow := endrow
    end;
  until (CharsUsedUp = NOGRABCHRS) or
        (CurY = HeightInChars);
  cGenMode(SeqparmsClr, GCParmsClr);
  Move(TempVideoBuffer, ScreenBuffer,
       Sizeof(TempVideoBuffer));

end; {ProcessBitMap}

procedure DisplayBitMap;
var
  BitMapBuffer : PBitMapContents;
  FileSize : LongInt;
begin
  if ParamStr(1) = '' then
  begin
    WriteLn('USAGE: BITMAPLD <file.bmp>');
    Exit;
  end;
  BitMapBuffer :=
            LoadBitMapFile(ParamStr(1),FileSize);
  if BitMapBuffer<> nil then
  begin
    ProcessBitMap(BitMapBuffer,0,0);
    FreeMem(BitMapBuffer, FileSize);
  end;
end; {DisplayBitMap}

procedure ResetFont; far;
{This is called as an exit procedure, so the screen
 is always restored, even if something goes wrong...
 not that it will...   }
var
  regs : Registers;
begin
  ExitProc := ExitSave; {Restore default exit proc}
  regs.ah := $11;
  case POINTS of {Select correct ROM font}
    16: {Load 8 x 16 font}
      regs.al := 4;
    8:  {Load 8 x 8 font}
      regs.al := 2;
    else {Choose 8 x 14 - it's the safest}
      regs.al := 1;
  end; {case}
  regs.bl := 0;
  intr($10,regs);
end; {ResetFont}

{*********** Main program }

begin
  ExitSave := ExitProc; ExitProc := @ResetFont;
  ClrScr;
  DisplayBitMap;
  ReadKey;
end.

