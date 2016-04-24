(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0340.PAS
  Description: BmpToGif
  Author: JOHN THE GREAT
  Date: 08-30-97  10:09
*)

{ Caveats:
  1. This ONLY converts 256 color bitmaps!
  2. The only format supported is GIF87a.
}

unit Bmp2Gif;

interface

  uses
    SysUtils,
  Classes,
  Windows,
  Graphics;

  function SaveAsGif(InputBM : TBitmap; FName : string) : boolean;

implementation

const
  BlockTerminator:byte = 0;
  FileTrailer:byte = $3B;
  gifBGColor:byte = 0;
  gifPixAsp:byte = 0;
  gifcolordepth:byte = 8;  // 8 bit = 256 colors
  gifncolors:integer = 256;
  gifLIDid:byte = $2C;
  HASHSIZE:integer = 5101;
  HASHBITS:integer = 4;
  TABLSIZE:integer = 4096;
  EMPTY:integer = -1;

var
 F : integer;
 Dbg : TextFile;
 MapBM : TBitmap;
 ImageWidth,ImageHeight:Integer;
 buffer : array[0..255] of byte;
 codes : array[0..5101] of Integer;
 prefix: array[0..5101] of Integer;
 suffix: array[0..5101] of Integer;
 nBytes,nbits, size,cursize, curcode, maxcode : Integer;
 BitmapSizeImage : Integer;
 Started : Boolean;
 minsize,maxsize,nroots,Capacity : Integer;
 endc, clrc : Integer;
 MinLZWCodeSize : Byte;
 bytecode,bytemask :Integer;
 counter : Integer;
 strc,chrc :Integer;
 ErrorMsg : string;

function Putbyte(B,fh:Integer):Boolean;

begin
  Counter := counter + 1;
  buffer[nbytes] := B;
  Inc(nbytes);
  If nbytes = 255 then
  begin
    //ShowMessage('255');
    FileWrite(fh,nbytes,1);
    FileWrite(fh,buffer,nbytes);
    nbytes := 0;
  end;
  result := True;
end;

function PutCode(code, fh :Integer) : Boolean;

var
  temp,n,mask :Integer;

begin
  mask := 1;
  n := nbits;
  //If nbits > 11 then ShowMessage('nbits = 12');
  while n > 0 do
  begin
    dec(n);
    if ((code and mask)<>0) then bytecode := (bytecode or bytemask);
    bytemask := bytemask shl 1;
    if (bytemask > $80) then
    begin
      If PutByte(bytecode,fh) then
      begin
        bytecode := 0;
        bytemask := 1;
      end;
    end;
    mask := mask shl 1;
  end;
  result := True;
end;

procedure Flush(fh:Integer);

begin
  if bytemask <> 1 then
  begin
    PutByte(byteCode,fh);
    bytecode :=0;
    bytemask :=1;
  end;
  if nbytes > 0 then
  begin
    FileWrite(fh,nbytes,1);
    FileWrite(fh,buffer,nbytes);
    nbytes :=0;
  end;
end;

procedure ClearX;

var
  J : Integer;

begin
  cursize := minsize;
  nbits := cursize;
  curcode := endc + 1;
  maxcode := 1 shl cursize;
  for J := 0 to HASHSIZE do codes[J] := EMPTY;
end;

function findstr(pfx,sfx :Integer):integer;

var
  i,di : Integer;

begin
  i := (sfx shl HASHBITS) xor pfx;
  if i = 0 then di := 1 else di := Capacity -i;
  while True do
  begin
    if codes[i] = EMPTY then break;
    if ((prefix[i] = pfx) and (suffix[i] = sfx)) then break;
    i := i - di;
    if i < 0 then i := i + Capacity;
  end;
  Result := i;
end;

procedure EncodeScanLine(fh : Integer; var buf : Pbyte; npxls : Integer);

var
  np,I : Integer;

begin
  np := 0;
  if not Started then
  begin
    strc := buf^;
    Inc(np); Inc(buf);
    Started := True;
  end;
  while np < npxls do
  begin
    // If np = 3 then break;
    chrc := buf^;
    Inc(np); Inc(buf);
    I := findstr(strc,chrc);
    if codes[I] <> EMPTY then
      strc := codes[I]
    else
    begin
      codes[I] := curcode;
      prefix[I] := strc;
      suffix[I] := chrc;
      putcode(strc,fh);
      strc := chrc;
      Inc(curcode);
      if curcode > maxcode then
      begin
        Inc(cursize);
        if cursize > maxsize then
        begin
          putcode(clrc,fh);
          ClearX;
        end
        else
        begin
          nbits := cursize;
          maxcode := maxcode shl 1;
          if cursize = maxsize  then dec(maxcode);
        end;
      end;
    end;
  end;
end;

procedure Initialize(fh:integer);

var
  flags : Byte;

begin
  counter := 0;
  Started := False;
  size := 8;
  nbytes := 0;
  nbits := 8;
  bytecode := 0;
  bytemask := 1;
  Capacity := HASHSIZE;
  minsize := 9;
  maxsize := 12;
  nroots := 1 shl 8;
  clrc := nroots;
  endc := clrc + 1;
  MinLZWCodeSize := 8;
  ClearX;
  // Write the type
  FileWrite(fh,'GIF87a',6);
  // Write the GIF screen descriptor
  // Note: width > 255 is a two byte word!!
  FileWrite(fh,ImageWidth,2);
  FileWrite(fh,ImageHeight,2);
  flags := $80 or ((gifcolordepth-1)shl 4) or (gifcolordepth-1);
  FileWrite(fh,flags,1);
  FileWrite(fh,gifBGColor,1);
  FileWrite(fh,gifPixAsp,1);
end;



procedure WriteGif(fh : integer);

var
  F:TextFile;
  gifxLeft,gifyTop : word; //Must be 16 bit!!
  flags :Byte;
  K : Pointer;
  Test,J,M : Integer;
  scanLine, TempscanLine, Bits, PBits : PByte;

begin
  //Get the info from the Bitmap
  GetMem(K,(sizeof(TBitMapInfoHeader) + 4 * gifncolors));
  TBitmapInfo(K^).bmiHeader.biSize := sizeof(TBitMapInfoHeader);
  TBitmapInfo(K^).bmiHeader.biWidth := ImageWidth;
  TBitmapInfo(K^).bmiHeader.biHeight := ImageHeight;
  TBitmapInfo(K^).bmiHeader.biPlanes := 1;
  TBitmapInfo(K^).bmiHeader.biBitCount := 8;
  TBitmapInfo(K^).bmiHeader.biCompression := BI_RGB;
  TBitmapInfo(K^).bmiHeader.biSizeImage :=
  ((((TBitmapInfo(K^).bmiHeader.biWidth * TBitmapInfo(K^).bmiHeader.biBitCount)+31)
      and Not(31)) shr 3)*TBitmapInfo(K^).bmiHeader.biHeight;
  TBitmapInfo(K^).bmiHeader.biXPelsPerMeter := 0;
  TBitmapInfo(K^).bmiHeader.biYPelsPerMeter := 0;
  TBitmapInfo(K^).bmiHeader.biClrUsed := 0;
  TBitmapInfo(K^).bmiHeader.biClrImportant := 0;
  try
    GetMem(Bits,TBitmapInfo(K^).bmiHeader.biSizeImage);
    Test := GetDIBits(MapBM.Canvas.Handle,MapBM.Handle,0,ImageHeight,Bits,TBitmapInfo(K^),DIB_RGB_COLORS);
    If Test > 0 then
    begin
      for J := 0 to 255 do
      begin
        FileWrite(fh,TBitMapInfo(K^).bmiColors[J].rgbRed,1);
        FileWrite(fh,TBitMapInfo(K^).bmiColors[J].rgbGreen,1);
        FileWrite(fh,TBitMapInfo(K^).bmiColors[J].rgbBlue,1);
      end;
      //Write the Logical Image Descriptor
      FileWrite(fh,gifLIDid,1);
      gifxLeft := 0;  FileWrite(fh,gifxLeft,2); // Write X position of image
      gifyTop  := 0;  FileWrite(fh,gifyTop,2);  // Write Y position of image
      FileWrite(fh,ImageWidth,2);
      FileWrite(fh,ImageHeight,2);
      flags := 0; FileWrite(fh,flags,1); //Write Local flags 0=None
      //Write Min LZW code size = 8 (for 8 bit)
      MinLZWCodeSize := 8;
      FileWrite(fh,MinLZWCodesize,1);
      PutCode(clrc,fh);
      PBits := Bits;
      Inc(Pbits,(ImageWidth *(ImageHeight -1)));
      GetMem(scanLine,ImageWidth);
      TempscanLine := scanLine;
      For M := 0 to ImageHeight-1 do
      begin
        FillChar(scanLine^,ImageWidth,0);
        move(PBits^,scanLine^,ImageWidth);
        EncodeScanLine(fh,scanLine,ImageWidth);
        dec(scanLine,ImageWidth);
        Dec(PBits,ImageWidth);
      end;
    end;
  finally
    scanLine := TempscanLine;
    FreeMem(scanLine,ImageWidth);
    FreeMem(Bits,TBitMapInfo(K^).bmiHeader.biSizeImage);
    FreeMem(K,(sizeof(TBitMapInfoHeader) + 4 * gifncolors));
  end;
end;


function SaveAsGif(InputBM : TBitmap; FName : string) : boolean;

begin
  ErrorMsg := '';
  Result := FALSE;
  MapBM := InputBM;
  ImageWidth := MapBM.Width;
  ImageHeight := MapBM.Height;
  F := FileCreate(FName);
  if F >= 0 then
  begin
    Initialize(F);
    WriteGif(F);
    PutCode(strc,F);
    PutCode(endc,F);
    Flush(F);
    FileWrite(F,BlockTerminator,1);
    FileWrite(F,FileTrailer,1);
    FileClose(F);
    if length(ErrorMsg) = 0 then Result := TRUE;
  end;
end;

end.

