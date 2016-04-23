{
> Who has information on the BMP format?

I do :-)
}

Unit BGIDrv;
{ Mee linken van grafische drivers in een applicatie }
interface
implementation
Uses Graph;
procedure EgaVgaDriverProc; external;
{$L EGAVGA.OBJ }
Begin
 { This links in the EGA and VGA drivers }
 RegisterBGIdriver(@EGAVGADriverProc);
End.

Unit bmp;         { V 1.02}
{ changes :
  V 1.00 : - initial implementation
  V 1.01 : - graphics must be opened and closed by the calling application
           - BGI Drivers now linked in by a seperate unit 'BGIDrv'
           - a few small optimizations
  V 1.02 : - major bug fixed
           - text output now uses OutText (not Writeln)
}

{$ifdef DEBUG} {$D+,R+,S+,Q+,I+}
{$else} {$R-,S-,Q-,I-,B-} {$endif}
interface

Procedure BMPDisplay(const FileName: String);
{ This procedure takes the name of an existing file as input, and tries
  to show the contents of the file on screen.
  In this implementation, an error message will be written to the screen
  if something goes wrong. Otherwise, the screen is cleared and the bitmap
  is schown. The procedure then returns. It is thus YOUR responsibility to
  set and close the graphics mode, after you have spent some time doing
  something (hopefully usefull), while the user was watching the bitmap.
}
implementation
Uses BgiDrv,Graph;

Type
 TBitMapHeader =
  Record
   bfType :             Word;
   bfSize :             LongInt;
   bfReserved :         LongInt;     {Moet 0 zijn}
   bfOffBits :          LongInt;
   biSize :             LongInt;
   biWidth :            LongInt;
   biHeight :           LongInt;
   biPlanes :           Word;        {Moet 1 zijn}
   biBitCount :         Word;        {1,4,8,24}
   biCompression :      LongInt;
   biSizeImage :        LongInt;     {in bytes}
   biXPelsPerMeter :    LongInt;
   biYPelsPerMeter :    LongInt;
   biClrUsed :          LongInt;
   biClrImportant :     LongInt;
  End;

 TRGBQuad =
  Record
   rgbBlue,
   rgbGreen,
   rgbRed,
   rgbReserved :        Byte;
  End;

Type TByteArray = Array[0..50000] of byte;

Procedure Display1 (Var f : File; const BitMapHeader : TBitMapHeader);
Begin
 OutText ('24 bit color not supported yet.');
End;

Procedure Display4 (Var f : File; const BitMapHeader : TBitMapHeader);
Var i,j : Integer;
Var RGBQuad : TRGBQuad;
Var TwoPixel : Byte;
Var Black : Byte;
Var Line : ^TByteArray;
Var number : Word;
Var BeginX,BeginY,EindY : Integer;
    CurrentX: Integer;
Begin
 If GetMaxColor < 15 then
  Begin
   OutText ('This machine does not support 4 bit color.');
   Exit;
  End;

 Black := 16;
 With BitMapHeader do
  begin
   For i:= 0 to 15 do
    Begin
     BlockRead(f,RGBQuad,SizeOf(RGBQuad));
     If (LongInt(RGBQuad)=0) then Black := i;
     With RGBQuad do
      SetRGBPalette(i, rgbRed shr 2, rgbGreen shr 2, rgbBlue shr 2);
     SetPalette(i,i);
    End;

   Number := (biWidth div 2 + 3) and not 3;
   BeginX := (GetMaxX - biWidth) div 2;
   BeginY := GetMaxY - (GetMaxY - biHeight) div 2;
   EindY := BeginY+1-biHeight;
  End;

 GetMem (Line,number+1);
 For j:=BeginY downto EindY do
  Begin
   BlockRead(f,Line^[1],number);
   CurrentX := BeginX;
   For i:=1 to number do
    Begin
     TwoPixel := Line^[i];
     If TwoPixel shr 4 <> Black then {verspil niet nutteloos tijd}
      PutPixel(CurrentX,j,TwoPixel shr 4);
     Inc(CurrentX);
     If TwoPixel and 15 <> Black then
      PutPixel(CurrentX,j,TwoPixel and 15);
     Inc(CurrentX);
    End;
  End;
 FreeMem (Line,number+1);
End;

Procedure Display8 (Var f : File; const BitMapHeader : TBitMapHeader);
Begin
 OutText ('8 bit color not supported yet.');
End;

Procedure Display24 (Var f : File; const BitMapHeader : TBitMapHeader);
Begin
 OutText ('24 bit color not supported.');
End;

Procedure BMPDisplay(const FileName: String);
Var f: File;
    BitMapHeader : TBitMapHeader;
Begin
 Assign(f,FileName);
 FileMode := 0; {Read Only}
 Reset(f,1);
 FileMode := 2; {Default}

 If IOResult<>0 Then
  Begin
   OutText ('File doesn''t exist');
   Close(f);
   Exit;
  End;

 BlockRead(f,BitMapHeader,SizeOf(BitMapHeader));
 With BitMapHeader do
  Begin
   If (bfType<>19778) or (bfReserved<>0) or (biPlanes<>1) then
    Begin
     OutText ('Not a valid Windows BitMap File.');
     Close(f);
     Exit;
    End;
   If biCompression<>0 Then
    Begin
     OutText ('Cannot read compressed files.');
     Close(f);
     Exit;
    End;
   ClearDevice;
   Case biBitCount of
    1  : Display1  (f, BitMapHeader);
    4  : Display4  (f, BitMapHeader);
    8  : Display8  (f, BitMapHeader);
    24 : Display24 (f, BitMapHeader);
   else
    Begin
     OutText ('Not a valid Windows BitMap File.');
     Close(f);
     Exit;
    End;
   End;
  End;
 Close(f);
End;
End.
