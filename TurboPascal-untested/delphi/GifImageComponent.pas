(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0180.PAS
  Description: GIF Image Component
  Author: RICHARD SHOTBOLT
  Date: 08-30-96  09:36
*)

unit xGif; {$D-}

{Freeware GIF image component

Based on GifUtl.pas (c)1993 Sean Wenzel 	Compuserve 71736,1245
Converted to Delphi by Richard Dominelli 	RichardA_Dominelli@mskcc.org
Converted to Delphi 2 and made into an
image component by Richard Shotbolt		Compuserve 100327,2305

enhance component as a descendant from          www.fabula.com
TBitmap and register the GIF file format        stefc@fabula.com
so it's ideal for include it in the xTools      CompuServe 100023,275
Now you can Load bitmaps from
by Stefan B÷ther

Left Open :
  - Also store the format via SaveToStream override
    so the GIF format can be used in blob formats
    also !
  - GIF 89a format not work propably 
  - use real gif transarency for TransparentColor
    property instead of lower-left pixel
  - support of new PNG format

Before using the GIF format in any commercial
application be sure you know the legal issuees for
this format !!!
}

interface

uses
  Windows, Forms, SysUtils, Classes, Graphics;

type
  TGifBitmap = class(TBitmap)
  public
    procedure LoadFromStream(Stream: TStream); override;
  end;

type
  EGifException = class(Exception)
  end;

implementation

uses
  Math; 

const
  { image descriptor bit masks }
  idLocalColorTable      = $80;	  { set if a local color table follows }
  idInterlaced           = $40;	  { set if image is interlaced }
  idSort                 = $20;	  { set if color table is sorted }
  idReserved             = $0C;	  { reserved - must be set to $00 }
  idColorTableSize       = $07;	  { size of color table as above }
  Trailer: byte          = $3B;	  { indicates the end of the GIF data stream }
  ExtensionIntroducer: byte = $21;
  MAXSCREENWIDTH         = 800;
  ImageSeparator: byte   = $2C;

  { logical screen descriptor packed field masks }
  lsdGlobalColorTable = $80;	{ set if global color table follows L.S.D. }
  lsdColorResolution = $70;	{ Color resolution - 3 bits }
  lsdSort = $08;					{ set if global color table is sorted - 1 bit }
  lsdColorTableSize = $07;	{ size of global color table - 3 bits }
										{ Actual size = 2^value+1    - value is 3 bits }
  BlockTerminator: byte = 0; { terminates stream of data blocks }
  MAXCODES = 4095;				{ the maximum number of different codes 0 inclusive }

  { error constants }
  geNoError         =  0;  { no errors found }
  geNoFile          =  1;  { gif file not found }
  geNotGIF          =  2;  { file is not a gif file }
  geNoGlobalColor   =  3;  { no Global Color table found }
  geImagePreceded   =  4;  { image descriptor preceeded by other unknown data }
  geEmptyBlock      =  5;  { Block has no data }
  geUnExpectedEOF   =  6;  { unexpected EOF }
  geBadCodeSize     =  7;  { bad code size }
  geBadCode         =  8;  { Bad code was found }
  geBitSizeOverflow =  9;  { bit size went beyond 12 bits }
  geNoBMP           = 10;  { Could not make BMP file }

  ErrName: Array[1..10] of string = (
	'GIF file not found',
	'Not a GIF file',
	'Missing color table',
	'Bad data',
	'No data',
 	'Unexpected EOF',
	'Bad code size',
	'Bad code',
	'Bad bit size',
        'Bad bitmap');

CodeMask: array[0..12] of Word = (  { bit masks for use with Next code }
	0,
	$0001, $0003,
	$0007, $000F,
	$001F, $003F,
	$007F, $00FF,
	$01FF, $03FF,
	$07FF, $0FFF);

type
  TDataSubBlock = packed record
    Size: byte;     { size of the block -- 0 to 255 }
    Data: array[1..255] of byte; { the data }
  end;

type
  THeader = packed record
    Signature: array[0..2] of char; { contains 'GIF' }
    Version: array[0..2] of char;   { '87a' or '89a' }
  end;

TLogicalScreenDescriptor = packed record
  ScreenWidth: word;              { logical screen width }
  ScreenHeight: word;  { logical screen height }
  PackedFields: byte;     { packed fields - see below }
  BackGroundColorIndex: byte;     { index to global color table }
  AspectRatio: byte;      { actual ratio = (AspectRatio + 15) / 64 }
end;

type
  TColorItem = packed record			{ one item a a color table }
    Red: byte;
    Green: byte;
    Blue: byte;
  end;

  TColorTable = packed array[0..255] of TColorItem;	{ the color table }

type
  TImageDescriptor = packed record
    Separator: byte;		{ fixed value of ImageSeparator }
    ImageLeftPos: word; 	{ Column in pixels in respect to left edge of logical screen }
    ImageTopPos: word;	{ row in pixels in respect to top of logical screen }
    ImageWidth: word;		{ width of image in pixels }
    ImageHeight: word; 	{ height of image in pixels }
    PackedFields: byte;	{ see below }
  end;

{ other extension blocks not currently supported by this unit
	- Graphic Control extension
	- Comment extension           I'm not sure what will happen if these blocks
	- Plain text extension        are encountered but it'll be interesting
	- application extension }

type
  TExtensionBlock = packed record
    Introducer: byte;                               { fixed value of ExtensionIntroducer }
    ExtensionLabel: byte;
    BlockSize: byte;
  end;

  PCodeItem = ^TCodeItem;
  TCodeItem = packed record
    Code1, Code2: byte;
  end;

{===============================================================}
{    Bitmap File Structs
{===============================================================}

type
  GraphicLine      = packed array [0..2048] of byte;
  PBmLine         = ^TBmpLinesStruct;
  TBmpLinesStruct = packed record
    LineData  : GraphicLine;
    LineNo    : Integer;
  end;

type
  { This is the actual gif object }
  PGif = ^TGif;
  TGif = class(TObject)
  private
    FStream             : TStream;       	     { the file stream for the gif file }
    Header              : THeader;  		     { gif file header }
    LogicalScreen       : TLogicalScreenDescriptor;  { gif screen descriptor }
    GlobalColorTable    : TColorTable;		     { global color table }
    LocalColorTable     : TColorTable;		     { local color table }
    ImageDescriptor     : TImageDescriptor; 	     { image descriptor }
    UseLocalColors      : boolean;		{ true if local colors in use }
    Interlaced          : boolean;				{ true if image is interlaced }
    LZWCodeSize         : Byte;				{ minimum size of the LZW codes in bits }
    ImageData           : TDataSubBlock;		{ variable to store incoming gif data }
    TableSize           : Word;					{ number of entrys in the color table }
    BitsLeft,
    BytesLeft           : Integer;	{ bits left in byte - bytes left in block }
    BadCodeCount        : word;          	{ bad code counter }
    CurrCodeSize        : Integer;       	{ Current size of code in bits }
    ClearCode           : Integer;          	{ Clear code value }
    EndingCode          : Integer;         	{ ending code value }
    Slot                : Word;							{ position that the next new code is to be added }
    TopSlot             : Word;			{ highest slot position for the current code size }
    HighCode            : Word;		{ highest code that does not require decoding }
    NextByte            : Integer;	{ the index to the next byte in the datablock array }
    CurrByte            : Byte;  		{ the current byte }
    DecodeStack         : array[0..MAXCODES] of byte; { stack for the decoded codes }
    Prefix              : array[0..MAXCODES] of integer;                     { array for code prefixes }
    Suffix              : array[0..MAXCODES] of integer;             { array for code suffixes }
    LineBuffer          : GraphicLine; { array for buffer line output }
    CurrentX,
    CurrentY            : Integer;                                            { current screen locations }
    Status              : Word;
    InterlacePass       : byte;    { interlace pass number }
    {Conversion Routine Vars}
    BmHeader : TBitmapInfoHeader; {File Header for bitmap file}
    ImageLines: TList; {Image data}
    {Member Functions}
    procedure ParseMem;
    function NextCode: word; 	{ returns the next available code }
    procedure Error(ErrCode: integer);
    procedure InitCompressionStream;   { initializes info for decode }
    procedure ReadSubBlock;  { reads a data subblock from the stream }
    procedure CreateLine;
    procedure CreateBitHeader; {Takes the gif header information and converts it to BMP}
    procedure Decode;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  end;


(*

function Power(A, N: real): real; { returns A raised to the power of N }
begin
  Power := exp(N * ln(A));
end;

*)

{ TGifBitmap }

procedure TGifBitmap.LoadFromStream(Stream: TStream);
var
  aBitmap : TBitmap;
  aGif    : TGif;
  aStream : TMemoryStream;
begin
  aGif := TGif.Create;
  try
    aGif.LoadFromStream(Stream);

    aStream:=TMemoryStream.Create;
    try
      aGif.SaveToStream(aStream);
      aBitmap:=TBitmap.Create;
      aBitmap.LoadFromStream(aStream);
      Assign(aBitmap);
    finally
      aStream.Free;
    end;
  finally
    aGif.Free;
  end;
end;

{ TGif }

constructor TGif.Create;
begin
  FStream := nil;
  ImageLines := TList.Create;
end;

{------------------------------------------------------------------------------}

destructor TGif.Destroy;
begin
  ImageLines.Free;
  inherited Destroy;
end;

{------------------------------------------------------------------------------}

procedure TGif.LoadFromStream(Stream: TStream);
begin
  FStream:=Stream;
  { Converts GIF file to bitstream }
  ParseMem;
  { Create the bitmap header info }
  CreateBitHeader;
  { Decode the GIF }
  Decode;
(*  WriteBitmapToStream; *)
end;

{------------------------------------------------------------------------------}

{Raise exception with a message}
procedure TGif.Error(ErrCode: integer);
begin
  raise EGifException.Create(ErrName[ErrCode]);
end;
{------------------------------------------------------------------------------}

procedure TGif.ParseMem;
{Decodes the header and palette info}
begin
  FStream.Read(Header, sizeof(Header)); { read the header }
  {Stupid validation tricks}
  if Header.Signature <> 'GIF' then Error(geNotGif);  { is vaild signature }
  {Decode the header information}
  FStream.Read(LogicalScreen, sizeof(LogicalScreen));
  if LogicalScreen.PackedFields and lsdGlobalColorTable = lsdGlobalColorTable then
  begin
    TableSize := Trunc(intPower(2,(LogicalScreen.PackedFields and lsdColorTableSize)+1));
    FStream.Read(GlobalColorTable, TableSize*sizeof(TColorItem)); { read Global Color Table }
  end else
    Error(geNoGlobalColor);
  {Done with Global Headers}
  {Image specific headers}
  FStream.Read(ImageDescriptor, sizeof(ImageDescriptor)); { read image descriptor }
  {Decode image header info}
  if ImageDescriptor.Separator <> ImageSeparator then   { verify that it is the descriptor }
     Error(geImagePreceded);
  {Check for local color table}
  if ImageDescriptor.PackedFields and idLocalColorTable = idLocalColorTable then
  begin                                                               { if local color table }
    TableSize := Trunc(intPower(2,(ImageDescriptor.PackedFields and idColorTableSize)+1));
    FStream.Read(LocalColorTable, TableSize*sizeof(TColorItem)); { read Local Color Table }
    UseLocalColors := True;
  end else
    UseLocalColors := False;
  {Check for interlaced}
  if ImageDescriptor.PackedFields and idInterlaced = idInterlaced then
  begin
    Interlaced := true;
    InterlacePass := 0;
  end;
 {End of image header stuff}
 {Reset then Expand capacity of the Image Lines list}
 ImageLines.Clear;
 ImageLines.Capacity := ImageDescriptor.ImageHeight;
 if (FStream = nil) then	{ check for stream error }
    Error(geNoFile);
end;

{------------------------------------------------------------------------------}

procedure TGif.InitCompressionStream;
begin
  {InitGraphics;}   								{ Initialize the graphics display }
  FStream.Read(LZWCodeSize, sizeof(byte));	{ get minimum code size }
  if not (LZWCodeSize in [2..9]) then     	{ valid code sizes 2-9 bits }
     Error(geBadCodeSize);
  CurrCodeSize := succ(LZWCodeSize); { set the initial code size }
  ClearCode := 1 shl LZWCodeSize;    { set the clear code }
  EndingCode := succ(ClearCode);     { set the ending code }
  HighCode := pred(ClearCode);   		{ set the highest code not needing decoding }
  BytesLeft := 0;                    { clear other variables }
  BitsLeft := 0;
  CurrentX := 0;
  CurrentY := 0;
end;
{------------------------------------------------------------------------------}

procedure TGif.ReadSubBlock;
begin
  FStream.Read(ImageData.Size, sizeof(ImageData.Size)); { get the data block size }
  if ImageData.Size = 0 then
     Error(geEmptyBlock);									{ check for empty block }
  FStream.Read(ImageData.Data, ImageData.Size); 	{ read in the block }
  NextByte := 1;                                 { reset next byte }
  BytesLeft := ImageData.Size;        				{ reset bytes left }
end;

{------------------------------------------------------------------------------}

function TGif.NextCode: word; { returns a code of the proper bit size }
begin
  if BitsLeft = 0 then    	{ any bits left in byte ? }
  begin 						{ any bytes left }
    if BytesLeft <= 0 then 	{ if not get another block }
       ReadSubBlock;
    CurrByte := ImageData.Data[NextByte]; 	{ get a byte }
    Inc(NextByte);                        	{ set the next byte index }
    BitsLeft := 8;                        	{ set bits left in the byte }
    Dec(BytesLeft);                       	{ decrement the bytes left counter }
  end;
  Result := CurrByte shr (8 - BitsLeft);			{ shift off any previosly used bits}
  while CurrCodeSize > BitsLeft do        	{ need more bits ? }
    begin
      if BytesLeft <= 0 then						{ any bytes left in block ? }
         ReadSubBlock;                       { if not read in another block }
      CurrByte := ImageData.Data[NextByte]; 	{ get another byte }
      inc(NextByte);                        	{ increment NextByte counter }
      Result := Result or (CurrByte shl BitsLeft);	{ add the remaining bits to the return value }
      BitsLeft := BitsLeft + 8;              { set bit counter }
      Dec(BytesLeft);                     	{ decrement bytesleft counter }
    end;
  BitsLeft := BitsLeft - CurrCodeSize;  { subtract the code size from bitsleft }
  Result := Result and CodeMask[CurrCodeSize];{ mask off the right number of bits }
end;

{------------------------------------------------------------------------------}

procedure TGif.Decode;  { this procedure actually decodes the GIF image }
var
  SP: integer; { index to the decode stack }

  { local procedure that decodes a code and puts it on the decode stack }
  procedure DecodeCode(var Code: word);
  begin
    while Code > HighCode do { rip thru the prefix list placing suffixes }
    begin                    { onto the decode stack }
      DecodeStack[SP] := Suffix[Code]; { put the suffix on the decode stack }
      inc(SP);                         { increment decode stack index }
      Code := Prefix[Code];            { get the new prefix }
    end;
    DecodeStack[SP] := Code;        		{ put the last code onto the decode stack }
    Inc(SP);                    			{ increment the decode stack index }
  end;

var
  TempOldCode, OldCode: word;
  BufCnt: word;	{ line buffer counter }
  Code, C: word;
  CurrBuf: word;	{ line buffer index }
  MaxVal: boolean;
begin
  InitCompressionStream;    { Initialize decoding paramaters }
  OldCode := 0;
  SP := 0;
  BufCnt := ImageDescriptor.ImageWidth; { set the Image Width }
  CurrBuf := 0;
  MaxVal := False;
  C := NextCode;				{ get the initial code - should be a clear code }
  while C <> EndingCode do  { main loop until ending code is found }
  begin
    if C = ClearCode then	{ code is a clear code - so clear }
    begin
      CurrCodeSize := LZWCodeSize + 1;	{ reset the code size }
      Slot := EndingCode + 1;				{ set slot for next new code }
      TopSlot := 1 shl CurrCodeSize;	{ set max slot number }
      while C = ClearCode do
	C := NextCode;	{ read until all clear codes gone - shouldn't happen }
      if C = EndingCode then
	 Error(geBadCode);   	{ ending code after a clear code }
      if C >= Slot then { if the code is beyond preset codes then set to zero }
	 C := 0;
      OldCode := C;
      DecodeStack[sp] := C; 	{ output code to decoded stack }
      inc(SP);        			{ increment decode stack index }
    end else   { the code is not a clear code or an ending code so it must }
    begin  { be a code code - so decode the code }
      Code := C;
      if Code < Slot then     { is the code in the table? }
      begin
      	DecodeCode(Code);     			{ decode the code }
      	if Slot <= TopSlot then
      	begin               			{ add the new code to the table }
          Suffix[Slot] := Code;  		{ make the suffix }
	  PreFix[slot] := OldCode; 	{ the previous code - a link to the data }
	  inc(Slot);     	{ increment slot number }
	  OldCode := C;    	{ set oldcode }
        end;
	if Slot >= TopSlot then 		{ have reached the top slot for bit size }
	begin                   	{ increment code bit size }
	  if CurrCodeSize < 12 then 	{ new bit size not too big? }
	  begin
	    TopSlot := TopSlot shl 1;	{ new top slot }
	    inc(CurrCodeSize) 			{ new code size }
          end else
            MaxVal := True; 			{ Must check next code is a start code }
       	end;
      end else
      begin	{ the code is not in the table }
        if Code <> Slot then
	   Error(geBadCode); { so error out }
	{ the code does not exist so make a new entry in the code table
	  and then translate the new code }
	TempOldCode := OldCode;  { make a copy of the old code }
	while OldCode > HighCode do 	{ translate the old code and place it }
	begin              			{ on the decode stack }
	  DecodeStack[SP] := Suffix[OldCode]; { do the suffix }
	  OldCode := Prefix[OldCode];         { get next prefix }
        end;
	DecodeStack[SP] := OldCode;	{ put the code onto the decode stack }
                          		{ but DO NOT increment stack index }
			                { the decode stack is not incremented because because we are only
 			                  translating the oldcode to get the first character }
        if Slot <= TopSlot then
	begin 	{ make new code entry }
	  Suffix[Slot] := OldCode;     	{ first char of old code }
	  Prefix[Slot] := TempOldCode; 	{ link to the old code prefix }
	  inc(Slot);                   	{ increment slot }
        end;

	if Slot >= TopSlot then { slot is too big }
	begin						{ increment code size }
	  if CurrCodeSize < 12 then
	  begin
	    TopSlot := TopSlot shl 1;	{ new top slot }
            inc(CurrCodeSize);   		{ new code size }
          end else
            MaxVal := True; 			{ Must check next code is a start code }
        end;
	DecodeCode(Code); { now that the table entry exists decode it }
	OldCode := C;     { set the new old code }
      end;
    end;
    { the decoded string is on the decode stack so pop it off and put it
      into the line buffer }
    while SP > 0 do
    begin
      dec(SP);
      LineBuffer[CurrBuf] := DecodeStack[SP];
      inc(CurrBuf);
      dec(BufCnt);
      if BufCnt = 0 then  { is the line full ? }
      begin
	CreateLine;
	CurrBuf := 0;
	BufCnt := ImageDescriptor.ImageWidth;
      end;
    end;
    C := NextCode;	{ get the next code and go at is some more }
    if (MaxVal = True) and (C <> ClearCode) then
     	Error(geBitSizeOverflow);
    MaxVal := False;
  end; { while }
end;

{------------------------------------------------------------------------------}

procedure TGif.CreateBitHeader;
{ This routine takes the values from the GIF image
  descriptor and fills in the appropriate values in the
  bit map header struct. }
begin
  with BmHeader do
  begin
    biSize           := Sizeof(TBitmapInfoHeader);
    biWidth          := ImageDescriptor.ImageWidth;
    biHeight         := ImageDescriptor.ImageHeight;
    biPlanes         := 1;            {Arcane and rarely used}
    biBitCount       := 8;            {Hmmm Should this be hardcoded ?}
    biCompression    := BI_RGB;       {Sorry Did not implement compression in this version}
    biSizeImage      := 0;            {Valid since we are not compressing the image}
    biXPelsPerMeter  :=143;           {Rarely used very arcane field}
    biYPelsPerMeter  :=143;           {Ditto}
    biClrUsed        := 0;            {all colors are used}
    biClrImportant   := 0;            {all colors are important}
  end;
end;

{------------------------------------------------------------------------------}

{fills in Line list with current line}
procedure TGif.CreateLine;
var
  p: PBmLine;
begin
  Application.ProcessMessages;
  {Create a new bmp line}
  New(p);
  {Fill in the data}
  p^.LineData := LineBuffer;
  p^.LineNo := CurrentY;
  {Add it to the list of lines}
  ImageLines.Add(p);
  {Prepare for the next line}
  Inc(CurrentY);
  if InterLaced then
  { Interlace support }
  begin
    case InterlacePass of
      0: CurrentY := CurrentY + 7;
      1: CurrentY := CurrentY + 7;
      2: CurrentY := CurrentY + 3;
      3: CurrentY := CurrentY + 1;
    end;
    if CurrentY >= ImageDescriptor.ImageHeight then
    begin
      Inc(InterLacePass);
      case InterLacePass of
        1: CurrentY := 4;
        2: CurrentY := 2;
        3: CurrentY := 1;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------}

procedure TGif.SaveToStream(Stream: TStream);
var
  BitFile: TBitmapFileHeader;
  i: integer;
  Line: integer;
  ch: char;
  p: PBmLine;
  x: integer;
begin
  with BitFile do begin
     bfSize := (3*255) + Sizeof(TBitmapFileHeader) +  {Color map info}
	                 Sizeof(TBitmapInfoHeader) +
  	(ImageDescriptor.ImageHeight*ImageDescriptor.ImageWidth);
     bfReserved1 := 0; {not currently used}
     bfReserved2 := 0; {not currently used}
     bfOffBits := (4*256)+ Sizeof(TBitmapFileHeader)+
                           Sizeof(TBitmapInfoHeader);
  end; 
  {Write the file header}
  with Stream do begin
    Position:=0;
    ch:='B';
    Write(ch,1);
    ch:='M';
    Write(ch,1);
    Write(BitFile.bfSize,sizeof(BitFile.bfSize));
    Write(BitFile.bfReserved1,sizeof(BitFile.bfReserved1));
    Write(BitFile.bfReserved2,sizeof(BitFile.bfReserved2));
    Write(BitFile.bfOffBits,sizeof(BitFile.bfOffBits));
    {Write the bitmap image header info}
    Write(BmHeader,sizeof(BmHeader));
    {Write the BGR palete inforamtion to this file}
    if UseLocalColors then {Use the local color table}
    begin
      for i:= 0 to 255 do
      begin
        Write(LocalColorTable[i].Blue,1);
        Write(LocalColorTable[i].Green,1);
        Write(LocalColorTable[i].Red,1);
        Write(ch,1); {Bogus palete entry required by windows}
      end;
    end else {Use the global table}
    begin
      for i:= 0 to 255 do
      begin
        Write(GlobalColorTable[i].Blue,1);
        Write(GlobalColorTable[i].Green,1);
        Write(GlobalColorTable[i].Red,1);
        Write(ch,1); {Bogus palete entry required by windows}
      end;
    end;

    {Init the Line Counter}
    Line := ImageDescriptor.ImageHeight;
    {Write out File lines in reverse order}
    while Line >= 0 do
    begin
      {Go through the line list in reverse order looking for the
       current Line. Use reverse order since non interlaced gifs are
       stored top to bottom.  Bmp file need to be written bottom to
       top}
      for i := (ImageLines.Count - 1) downto 0  do
      begin
        p := ImageLines.Items[i];
        if p^.LineNo = Line then
        begin
          x := ImageDescriptor.ImageWidth;
          Write(p^.LineData, x);
          ch := chr(0);
          while (x and 3) <> 0 do { Pad up to 4-byte boundary with zeroes }
          begin
            Inc(x);
            Write(ch, 1);
          end;
          break;
        end;
      end;
      Dec(Line);
    end;
    Position:=0; { reset mewmory stream}
  end;
end;

{------------------------------------------------------------------------------}

initialization
  { register the TGifBitmap as a new graphic file format
    now all the TPicture storage stuff can access our new
    GIF graphic format !
  }
  TPicture.RegisterFileFormat('gif','GIF-Format', TGifBitmap);
end.


