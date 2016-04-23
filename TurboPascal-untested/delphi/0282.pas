unit UBitmap;
{
Extented TBitmap object for Delphi 1.0
Added methods to load and save a compressed bitmap.
Copyright ⌐ 1997 by Herbert J.Beemster.

Questions, positive remarks, improvements etc. : herbertjb@compuserve.com

Credits goes to:
- Kurt Haenen for the LZRW1KH unit.
- Dan English for the trick with the streams.
- Danny Heijl for sample of using LZRW1KH.


This piece of source is hereby donated to the public domain. Enjoy!
}

interface

uses WinTypes, WinProcs, SysUtils, Classes, Graphics;

type
 TLZRBitmap = class(TBitmap)
 public
   procedure LZRLoadFromFile(
     const Filename : string
   ); virtual;
   procedure LZRSaveToFile(
     const Filename : string
   ); virtual;
 end; {TLZRBitmap}


implementation

uses
  LZRW1KH; {Credits : Kurt Haenen}  { unit can be in ARCHIVES.SWG !! }

const
  ChunkSize = 32768;
  IOBufSize = (ChunkSize + 16);
  LZRWIdentifier : LONGINT =
  ((((((ORD('L') SHL 8)+ORD('Z')) SHL 8)+ORD('R')) SHL 8)+ORD('W'));

var
  InStream   : TMemoryStream;
  OutStream  : TMemoryStream;


procedure TLZRBitmap.LZRLoadFromFile(
  const Filename : string
);
var
  Tmp,
  Identifier,
  OrigSize,
  SrcSize,
  DstSize    : LongInt;
  SrcBuf,
  DstBuf     : BufferPtr;
begin
  try
  {Create InStream & OutStream}
    InStream  := TMemoryStream.Create;
    OutStream := TMemoryStream.Create;
  {Create buffers for LZWR1KH}
    Getmem(SrcBuf, IOBufSize);
    Getmem(DstBuf, IOBufSize);

  {Load the compressed bitmap}
    InStream.LoadFromFile( Filename);
    InStream.Seek(0,0);

  {Decompress the lot...}
  {Read compression ID }
    InStream.Read( Identifier, SizeOf( LongInt));

  {Read in uncompressed filesize }
    InStream.Read( OrigSize, SizeOf( LongInt));

    DstSize := ChunkSize;
    SrcSize := 0;
    while (DstSize = ChunkSize)
    do
    begin
    {Read size of compressed block }
      Tmp := InStream.Read( SrcSize, SizeOf( Word));
    {Read compressed block }
      InStream.Read( SrcBuf^, SrcSize);
    {Decompress block }
      DstSize := Decompression( SrcBuf, DstBuf, SrcSize);
    {Write decompressed block out to OutStream }
      OutStream.Write( DstBuf^, DstSize);
    end;

  {TBitmap thinks its loading from a file!}
    OutStream.Seek(0,0);
    LoadfromStream( OutStream);

  finally
  {Clean Up Memory}
    InStream.Free;
    OutStream.Free;
    Freemem( SrcBuf, IOBufSize);
    Freemem( DstBuf, IOBufSize);

  end; {try}

end; {LZRLoadFromFile}


procedure TLZRBitmap.LZRSaveToFile(
  const Filename : string
);
var
  Size,
  CompIdentifier,
  SrcSize,
  DstSize    : LongInt;
  SrcBuf,
  DstBuf     : BufferPtr;

begin
  try
  {Create InStream & OutStream}
    InStream  := TMemoryStream.Create;
    OutStream := TMemoryStream.Create;
  {Create buffers for LZWR1KH}
    Getmem(SrcBuf, IOBufSize);
    Getmem(DstBuf, IOBufSize);

  {Save the bitmap to InStream}
    SaveToStream( InStream);
    InStream.Seek(0,0);

  {Compress the lot...}
  {Write out compression ID }
    CompIdentifier := LZRWIdentifier;
    OutStream.Write( CompIdentifier, SizeOf( LongInt));

  {Write out uncompressed filesize }
    Size := InStream.Size;
    OutStream.Write( Size, SizeOf( LongInt));


    SrcSize := ChunkSize;
    while (SRCSize = ChunkSize)
    do
    begin
    {Read a block of data }
      SrcSize := InStream.Read( SrcBuf^, ChunkSize);
    {Compress it }
      DstSize := Compression( SrcBuf, DstBuf, SrcSize);
    {Write out compressed size }
      OutStream.Write( DstSize, SizeOf( Word));
    {Write out compressed data }
      OutStream.Write( DstBuf^, DstSize);
    end; {while}

  {Save compressed OutStream to file}
    OutStream.SaveToFile( Filename);

  finally
  {Clean Up Memory}
    InStream.Free;
    OutStream.Free;
    Freemem( SrcBuf, IOBufSize);
    Freemem( DstBuf, IOBufSize);

  end; {try}

end; {LZRSaveToFile}

end.
