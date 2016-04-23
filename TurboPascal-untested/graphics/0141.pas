{
Here is a version of a bitmap scaler. It is rather old and isn't very
optimized. Please do not send improvements to me, as I don't want them.
The unit IMAGE is included in the next message.

}
Program ScaleImage;
{ A bitmap scaler }
{ Alex Chalfin    achalfin@uceng.uc.edu }
{ About 1 1/2 years old. It works and its pretty fast }
{ Sorry about the Pascal only, bungled, uncommented code }

Uses Crt,Image;
Var
  Pic, Bit : Pointer;
  X, y, z, A1, A12 : Integer;


Procedure Scale(Factor : Real; Var Image, Scaled : Pointer);

Var
  NewLength, NewWidth, Segment, Offset, ScaleSeg, ScaleOfs : Word;
  ScaleSize, Count3, Count2, Count, Orig, Orig2, TallStep, SideStep : Word;
  Msb, Lsb, TallLeft, SideLeft, TallSkip, SideSkip : Byte;

Begin
  Segment := Seg(Image^); Offset := Ofs(Image^);
  Msb := Mem[Segment:Offset + 2]; Lsb := Mem[SegMent:Offset + 3];
  Orig2 := (Msb ShL 8) + Lsb;
  ScaleSize := Trunc((Factor * Factor) * ((MsB ShL 8) + LsB));
  GetMem(Scaled, (ScaleSize) + 4);
  ScaleSeg := Seg(Scaled^); ScaleOfs := Ofs(Scaled^);
  Msb := Mem[Segment:Offset]; Lsb := Mem[Segment:Offset + 1];
  Orig := ((Msb ShL 8) + LsB);
  NewWidth := Trunc(Factor * Orig);
  NewLength := Trunc(Factor * (Orig2 div Orig));
  A1 := newwidth; A12 := newlength;
  TallStep := Trunc(NewLength / (Orig2 div Orig));
  SideStep := NewWidth Div Orig; TallLeft := NewLength Mod TallStep;
  SideLeft := NewWidth Mod SideStep;
  Mem[ScaleSeg:ScaleOfs] := NewWidth Shr 8;
  Mem[ScaleSeg:ScaleOfs + 1] := NewWidth and 255;
  Mem[ScaleSeg:ScaleOfs + 2] := (NewLength * NewWidth + 4) Shr 8;
  Mem[ScaleSeg:ScaleOfs + 3] := (NewLength * NewWidth + 4) and 255;
  ScaleOfs := ScaleOfs + 4;
  Offset := Offset + 4;
  If TallLeft > 0
    Then TallSkip := TallSkip + 1;
  If SideLeft > 0
    Then SideSkip := SideSkip + 1;
  For Count := 1 to (Orig2 Div Orig) do
    Begin
      For Count2 := 1 to Orig do
        Begin
          FillChar(Mem[ScaleSeg:ScaleOfs], SideStep, Mem[Segment:Offset]);
          ScaleOfs := ScaleOfs + SideStep;
          Offset := Offset + 1;
        End;
      For Count3 := 1 to (TallStep - 1) do
        Begin
          Move(Mem[ScaleSeg:ScaleOfs - NewWidth], Mem[ScaleSeg:ScaleOfs], NewWi
          ScaleOfs := ScaleOfs + NewWidth;
        End;
   End;
End;

Begin
  Asm
    mov  ax,13h
    int  10h
  End;
  For X := 0 to 199 do
    FillChar(Mem[$A000:X*320], 320, X);
  z := ImageSize(1, 1, 10, 10);
  Getmem(Pic, z);
  Getimage(1, 1, 10, 10, Pic^);
  for z := 1 to 15 do
    begin
      Scale(z, Pic, Bit);
      Putimage((320 div 2) - (A1 div 2), (200 div 2) - (A12 div 2), Bit^);
    {  Delay(200);}
    end;
  Readln;
  Asm
    mov  ax,3
    int  10h
  End;
End.

{
Here is the IMAGE unit required for the bitmap scaler.
Again, don't send me improvements.
}

Unit Image;

Interface

Function ImageSize(X1, Y1, X2, Y2 : Word): Word;
Procedure GetImage(X1, Y1, X2, Y2 : Word; Var BitMap);
Procedure Putimage(X1, Y1 : Word; Var BitMap);

Implementation

Function ImageSize(X1, Y1, X2, Y2 : Word) : Word;

Begin
  ImageSize := 4 + ((1 + (Y2 - Y1)) * (1 + (X2 - X1)));
End;

Procedure GetImage(X1, Y1, X2, Y2 : Word; Var BitMap);

Var
  BitMapPicSize : Word;  {size of bitmap to be saved}
  Count : Word;          {counting variable}
  TempOfs : Word;        {length of a line in bitmap}
  Offset : Word;         {offset to move move memory to}
  Msb, Lsb : Byte;       {most and least significant bytes of a word}

Begin
  BitMapPicSize := ImageSize(X1, Y1, X2, Y2);
  OffSet := Ofs(BitMap);
  TempOfs := (X2 - X1) + 1;
  Msb := TempOfs ShR 8;            {\                                 }
  Lsb := TempOfs and 255;          {  \                               }
  MemW[Seg(BitMap):OffSet] := Msb; {   | Save line length in pointer  }
  Offset := OffSet + Sizeof(Msb);  {   |                              }
  MemW[Seg(BitMap):OffSet] := Lsb; {  /                               }
  Offset := OffSet + Sizeof(Msb);  {/                                 }
  Msb := BitMapPicSize ShR 8;      {\                                 }
  Lsb := BitMapPicSize and 255;    {  \                               }
  MemW[Seg(BitMap):OffSet] := Msb; {   | Save imagesize in pointer    }
  Offset := OffSet + Sizeof(Msb);  {   |                              }
  MemW[Seg(BitMap):OffSet] := Lsb; {  /                               }
  OffSet := OffSet + Sizeof(Lsb);  {/                                 }
  For Count := Y1 to Y2 do                     {\                         }
    Begin                                      {  \                       }
      Move(MemW[$A000:X1 + (320 * Count)],    {    \  Save picture info  }
           MemW[Seg(BitMap):Offset], TempOfs); {    /                     }
      OffSet := OffSet + TempOfs;              {  /                       }
    End;                                       {/                         }
End;

Procedure Putimage(X1, Y1 : Word; Var BitMap);

Var
  OffSet : Word;
  BitLength : Word;
  BitSize : Word;
  VGAOffSet : Word;
  Msb : Byte;
  Lsb : Byte;
  BitCount : Word;

Begin
  VGAOffSet := X1 + (Y1 * 320);
  OffSet := Ofs(BitMap);
  Msb := MemW[Seg(BitMap):Offset];
  Lsb := MemW[Seg(BitMap):Offset + 1];
  BitLength := (Msb ShL 8) + Lsb;
  Msb := MemW[Seg(BitMap):Offset + 2];
  Lsb := MemW[Seg(BitMap):Offset + 3];
  OffSet := OffSet + 4;
  BitSize := (Msb Shl 8) + Lsb;
  BitSize := ((BitSize - 2) div BitLength);
  For BitCount := 1 to BitSize do
    Begin
      Move(MemW[Seg(BitMap):OffSet], MemW[$A000:VGAOffSet], BitLength);
      OffSet := OffSet + BitLength;
      VgaOffSet := VGAOffSet + 320;
    End;
End;

End.
