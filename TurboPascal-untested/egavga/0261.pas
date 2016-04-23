
{ ---RLTGA.PAS--- The Run-Length Encoded Targa (type 9) viewer for DOS ---}
{ ===Coded by Patrick O'Malley===                                         }
{ ---Is this OK for SWAG?---                                              }
{ ===Please mention me if you use this proggy in one of your proggys===   }
{ ---Sorry about the lack of comments. I did add _some_ tho ;)---         }
{ ---My InterNet E-Mail address is: d005530c@dcfreenet.seflin.lib.fl.us---}

{ Just a small note about the strange stuff at the end of the proggy:
  That virtual screen that is written to is used to flip the TGA around.
  These TGAs are encoded bottom-up. Since I can't read the file from
  bottom up, I must flip the file around after it has been read. }

{$X+}
Program Read_Encoded_TGA;
Uses Crt;
Type TGAHeader = record
                   IDFieldLength : Byte;
                   ColorMapType : Byte;
                   ImageType : Byte;
                   CMapOrigin : Integer;
                   CMapLength : Integer;
                   CMapSize : Byte;
                   XOrigin : Integer;
                   YOrigin : Integer;
                   Width : Integer;
                   Height : Integer;
                   ImagePixSize : Byte;
                   ImageDescriptor : Byte;
                 end;
     ImageIDFieldType = Array[1..256] of byte;

Const VGA = $A000;

Var Header : TGAHeader;
    ImageIDField : ImageIDFieldType;
    TGA : File;
    TGAName : String;
    VGAScreen : Pointer;
    VGASeg : Word;
    Pal : Array[0..255,0..2] of byte;
    Counter,Count : Word;
    Temp : Byte;
    PixelCount : Word;
    Rep : Byte;
    NewByte : Byte;
    MaxPix : Word;

Procedure SetColor(Col, R, G, B : Byte);
Begin
   Asm
      mov   dx, 3c8h
      mov   al, [Col]
      out   dx, al
      inc   dx
      mov   al, [R]
      out   dx, al
      mov   al, [G]
      out   dx, al
      mov   al, [B]
      out   dx, al
   End;
End; {SetColor}

Procedure SetMcga;
Begin
   Asm
      mov   ax, 0013h
      int   10h
   End;
End;  {SetMCGA}

Procedure SetText;
Begin
   Asm
      mov   ax, 0003h
      int   10h
   End;
End; {SetText}

Procedure Error(Str : String);
Begin
  writeln(Str);
  Halt(1);
End;

Begin
  TGAName := Paramstr(1);
  If TGAName = '' then Error('Enter filename on Command Line.');
  {$I-}
  Assign(TGA,TGAName);
  Reset(TGA,1);
  IF IOResult <> 0 then Error('File not found!');
  {$I+}
  BlockRead(TGA,Header,SizeOf(Header));
  {This next part checks for an image ID field (header.IDFieldLength > 0)
   then, if one is found, reads it into ImageIDField. Should be less than
   256 bytes (let's hope). It is usually omitted (header.IDFieldLength=0).}
  If Header.IDFieldLength > 0 then
    BlockRead(TGA,ImageIDField,Header.IDFieldLength);
  {Make sure that it is an encoded type 9 TGA}
  If Header.ImageType <> 9 then Begin
    Close(TGA);
    Error('Not a color-mapped type-9 Targa!');
  End;
  SetMCGA;
  {Read colors}
  For Counter := 0 to Header.CMapLength-1 do
    For Count := 0 to 2 do Begin
      BlockRead(TGA,Temp,1);
      Pal[Counter,Count] := Temp shr 2;
    End;
  {Set colors}
  For Counter := 0 to 255 do
    SetColor(Counter,Pal[Counter,2],Pal[Counter,1],Pal[Counter,0]);
  {Read image stuff!}
  MaxPix := (Header.Height*Header.Width);
  PixelCount := 0;
  GetMem(VGAScreen,64000);
  VGASeg := Seg(VGAScreen^);
  FillChar(Mem[VGASeg:0],64000,0);
  Repeat
    BlockRead(TGA,Temp,1);
    If Temp shr 7 = 1 then begin
      BlockRead(TGA,NewByte,1);
      Rep := Temp AND 127;
      For Count := 1 to rep+1 do begin
        Mem[VGASeg:PixelCount] := NewByte;
        Inc(PixelCount);
      End;
    end
    else
    Begin
      Rep := Temp AND 127;
      For Count := 1 to Rep+1 do Begin
        BlockRead(TGA,NewByte,1);
        Mem[VGASeg:PixelCount] := NewByte;
        Inc(PixelCount);
      End;
    End;
  Until PixelCount = MaxPix;
  {Flip the screen onto the display}
  For Count := 0 to Header.Width-1 do  {x}
    For Counter := 0 to Header.Height-1 do {y}
      Mem[VGA:Counter*320+Count] :=
Mem[VGASeg:((Header.Height-1)-Counter)*Header.Width+Count];  Readkey;
  Close(TGA);
  Freemem(VGAScreen,64000);
  SetText;
End.
