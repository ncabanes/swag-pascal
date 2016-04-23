
Program TrnsVect; { Transparent Vectors }
{$G+} { 286 Instructions Enabled }

{  Transparent 3D Vectors Example  }
{     Programmed by David Dahl     }
{  This program is PUBLIC DOMAIN   }

Uses CRT;
Const ViewerDist = 200;
Type VGAArray = Array [0..199, 0..319] of Byte;
     VGAPtr   = ^VGAArray;
     PaletteRec  = Record
                         Red   : Byte;
                         Green : Byte;
                         Blue  : Byte;
                   End;
     PaletteType = Array [0..255] of PaletteRec;
     PalettePtr  = ^PaletteType;
     PolyRaster  = Record
                         X1 : Word;
                         X2 : Word;
                   End;
     PolyFill    = Array [0..199] of PolyRaster;
     PolyFillPtr = ^PolyFill;
     FacetPtr     = ^PolyFacet;
     PolyFacet    = Record
                          Color       : Byte;
                          X1, Y1, Z1,
                          X2, Y2, Z2,
                          X3, Y3, Z3,
                          X4, Y4, Z4  : Integer;
                          NextFacet   : FacetPtr;
                    End;
     PolyHPtr     = ^PolygonHead;
     PolygonHead  = Record
                          X, Y, Z    : Integer;
                          AX, AY, AZ : Integer;
                          FirstFacet : FacetPtr;
                    End;
Var  VGAMEM   : VGAPtr;
     WorkPage : VGAPtr;
     BkgPage  : VGAPtr;
     Palette  : PalettePtr;
     PolyList : PolyFillPtr;
{-[ Initialize 320 X 200 X 256 VGA ]---------------------------------------}
Procedure GoMode13h; Assembler;
ASM
   MOV AX, $0013
   INT $10
End;
{=[ Convex Polygon Drawing Routines ]======================================}
{-[ Clear Polygon Raster List ]--------------------------------------------}
Procedure ClearPolyList (Var ListIn : PolyFill);
Begin
     FillChar (ListIn, SizeOf(ListIn), $FF);
End;
{-[ OR VariableIn with Value -- Modeled after FillChar ]-------------------}
Procedure ORChar (Var VariableIn;
                      Size       : Word;
                      Value      : Byte); Assembler;
ASM
   PUSH DS
   MOV CX, Size
   OR  CX, CX
   JZ  @Done
   LDS SI, VariableIn
   MOV AL, Value
   @ORLoop:
      OR DS:[SI], AL
      INC SI
   LOOP @ORLoop
   @Done:
   POP DS
End;
{-[ Draw Polygon From Raster List To Work Buffer ]-------------------------}
Procedure DrawPolyFromList (Var ListIn      : PolyFill;
                            Var FrameBuffer : VGAArray;
                                Color       : Byte);
Var YCount : Word;
    TempX1 : Word;
    TempX2 : Word;
Begin
     For YCount := 0 to 199 do
     Begin
          TempX1 := ListIn[YCount].X1;
          TempX2 := ListIn[YCount].X2;
          If (TempX1 <= 319) AND (TempX2 <= 319)
          Then
              ORChar (FrameBuffer[YCount, TempX1],
                      TempX2 - TempX1 + 1, Color);
     End;
End;
{-[ Add An Element To The Raster List ]------------------------------------}
Procedure AddRasterToPoly (Var ListIn : PolyFill;
                               X, Y   : Integer);
Begin
     { Clip X }
     If X < 0
     Then
         X := 0
     Else
         If X > 319
         Then
             X := 319;
    { If Y in bounds, add to list }
    If ((Y >= 0) AND (Y <= 199))
    Then
    Begin
         If (ListIn[Y].X1 > 319)
         Then
         Begin
             ListIn[Y].X1 := X;
             ListIn[Y].X2 := X;
         End
         Else
             If (X < ListIn[Y].X1)
             Then
                 ListIn[Y].X1 := X
             Else
                 If (X > ListIn[Y].X2)
                 Then
                     ListIn[Y].X2 := X;
    End;
End;
{=[ Polygon ]==============================================================}
{-[ Add A Facet To Current Polygon ]---------------------------------------}
Procedure AddFacet (Polygon          : PolyHPtr;
                    Color            : Byte;
                    X1In, Y1In, Z1In : Integer;
                    X2In, Y2In, Z2In : Integer;
                    X3In, Y3In, Z3In : Integer;
                    X4In, Y4In, Z4In : Integer);
Var CurrentFacet : FacetPtr;
Begin
     If Polygon^.FirstFacet = Nil
     Then
     Begin
          New(Polygon^.FirstFacet);
          CurrentFacet := Polygon^.FirstFacet;
     End
     Else
     Begin
          CurrentFacet := Polygon^.FirstFacet;
          While CurrentFacet^.NextFacet <> Nil do
                CurrentFacet := CurrentFacet^.NextFacet;
          New(CurrentFacet^.NextFacet);
          CurrentFacet := CurrentFacet^.NextFacet;
     End;
     CurrentFacet^.Color := Color;
     CurrentFacet^.X1 := X1In;
     CurrentFacet^.X2 := X2In;
     CurrentFacet^.X3 := X3In;
     CurrentFacet^.X4 := X4In;
     CurrentFacet^.Y1 := Y1In;
     CurrentFacet^.Y2 := Y2In;
     CurrentFacet^.Y3 := Y3In;
     CurrentFacet^.Y4 := Y4In;
     CurrentFacet^.Z1 := Z1In;
     CurrentFacet^.Z2 := Z2In;
     CurrentFacet^.Z3 := Z3In;
     CurrentFacet^.Z4 := Z4In;
     CurrentFacet^.NextFacet := Nil;
End;
{-[ Initialize a New Polygon ]---------------------------------------------}
Procedure InitializePolygon (Var PolyHead               : PolyHPtr;
                                 XIn, YIn, ZIn          : Integer;
                                 RollIn, PitchIn, YawIn : Integer);
Begin
     If PolyHead = Nil
     Then
     Begin
          New(PolyHead);
          PolyHead^.X := XIn;
          PolyHead^.Y := YIn;
          PolyHead^.Z := ZIn;
          PolyHead^.AX := RollIn;
          PolyHead^.AY := PitchIn;
          PolyHead^.AZ := YawIn;
          PolyHead^.FirstFacet := Nil;
     End;
End;
{-[ Dispose Polygon ]------------------------------------------------------}
Procedure DisposePolygon (Var PolyHead : PolyHPtr);
Var TempPtr : FacetPtr;
    TP2     : FacetPtr;
Begin
     TempPtr := PolyHead^.FirstFacet;
     While TempPtr <> Nil do
     Begin
          TP2 := TempPtr^.NextFacet;
          Dispose (TempPtr);
          TempPtr := TP2;
     End;
     Dispose (PolyHead);
     PolyHead := Nil;
End;
{-[ Rotate Polygon About Axies ]-------------------------------------------}
Procedure RotatePolygon (Var PolyHead   : PolyHPtr;
                             DX, DY, DZ : Integer);
Begin
     INC (PolyHead^.AX, DX);
     INC (PolyHead^.AY, DY);
     INC (PolyHead^.AZ, DZ);
     While (PolyHead^.AX > 360) do
           DEC(PolyHead^.AX, 360);
     While (PolyHead^.AY > 360) do
           DEC(PolyHead^.AY, 360);
     While (PolyHead^.AZ > 360) do
           DEC(PolyHead^.AZ, 360);
     While (PolyHead^.AX < -360) do
           INC(PolyHead^.AX, 360);
     While (PolyHead^.AY < -360) do
           INC(PolyHead^.AY, 360);
     While (PolyHead^.AZ < -360) do
           INC(PolyHead^.AZ, 360);
End;
{=[ Graphics Related Routines ]============================================}
{-[ Build Facet Edge ]-----------------------------------------------------}
Procedure DrawLine (X1In, Y1In,
                    X2In, Y2In  : Integer;
                    Color       : Byte);
Var dx, dy : Integer;
    ix, iy : Integer;
    X,  Y  : Integer;
    PX, PY : Integer;
    i      : Integer;
    incc   : Integer;
    plot   : Boolean;
Begin
     dx := X1In - X2In;
     dy := Y1In - Y2In;
     ix := abs(dx);
     iy := abs(dy);
     X  := 0;
     Y  := 0;
     PX := X1In;
     PY := Y1In;
     AddRasterToPoly (PolyList^, PX, PY);
     If ix > iy
     Then
         incc := ix
     Else
         incc := iy;
     i := 0;
     While (i <= incc) do
     Begin
          Inc (X, ix);
          Inc (Y, iy);
          Plot := False;
          If X > incc
          Then
          Begin
               Plot := True;
               Dec (X, incc);
               If dx < 0
               Then
                   Inc(PX)
               Else
                   Dec(PX);
          End;
          If Y > incc
          Then
          Begin
               Plot := True;
               Dec (Y, incc);
               If dy < 0
               Then
                   Inc(PY)
               Else
                   Dec(PY);
          End;
          If Plot
          Then
              AddRasterToPoly (PolyList^, PX, PY);
          Inc(i);
     End;
End;
{-[ Draw Polygon ]---------------------------------------------------------}
Procedure DrawPolygon3D (PolyHead : PolyHPtr;
                         Buffer   : VGAPtr);
Var CurrentFacet               : FacetPtr;
    CalcX1, CalcY1, CalcZ1,
    CalcX2, CalcY2, CalcZ2,
    CalcX3, CalcY3, CalcZ3,
    CalcX4, CalcY4, CalcZ4     : Integer;
    XPrime1, YPrime1, ZPrime1,
    XPrime2, YPrime2, ZPrime2,
    XPrime3, YPrime3, ZPrime3,
    XPrime4, YPrime4, ZPrime4  : Integer;
    Temp                       : Integer;
    CTX, STX,
    CTY, STY,
    CTZ, STZ  : Real;
Begin
     CurrentFacet := PolyHead^.FirstFacet;
     While CurrentFacet <> Nil do
       With CurrentFacet^ do
       Begin
            ClearPolyList (PolyList^);
            XPrime1 := X1; YPrime1 := Y1; ZPrime1 := Z1;
            XPrime2 := X2; YPrime2 := Y2; ZPrime2 := Z2;
            XPrime3 := X3; YPrime3 := Y3; ZPrime3 := Z3;
            XPrime4 := X4; YPrime4 := Y4; ZPrime4 := Z4;
            { Rotate Coords }
            CTX := COS(PolyHead^.AX * PI / 180);
            STX := SIN(PolyHead^.AX * PI / 180);
            CTY := COS(PolyHead^.AY * PI / 180);
            STY := SIN(PolyHead^.AY * PI / 180);
            CTZ := COS(PolyHead^.AZ * PI / 180);
            STZ := SIN(PolyHead^.AZ * PI / 180);
            Temp    := Round((YPrime1 * CTX) - (ZPrime1 * STX));
            ZPrime1 := Round((YPrime1 * STX) + (ZPrime1 * CTX));
            YPrime1 := Temp;
            Temp    := Round((XPrime1 * CTY) - (ZPrime1 * STY));
            ZPrime1 := Round((XPrime1 * STY) + (ZPrime1 * CTY));
            XPrime1 := Temp;
            Temp    := Round((XPrime1 * CTZ) - (YPrime1 * STZ));
            YPrime1 := Round((XPrime1 * STZ) + (YPrime1 * CTZ));
            XPrime1 := Temp;
            Temp    := Round((YPrime2 * CTX) - (ZPrime2 * STX));
            ZPrime2 := Round((YPrime2 * STX) + (ZPrime2 * CTX));
            YPrime2 := Temp;
            Temp    := Round((XPrime2 * CTY) - (ZPrime2 * STY));
            ZPrime2 := Round((XPrime2 * STY) + (ZPrime2 * CTY));
            XPrime2 := Temp;
            Temp    := Round((XPrime2 * CTZ) - (YPrime2 * STZ));
            YPrime2 := Round((XPrime2 * STZ) + (YPrime2 * CTZ));
            XPrime2 := Temp;
            Temp    := Round((YPrime3 * CTX) - (ZPrime3 * STX));
            ZPrime3 := Round((YPrime3 * STX) + (ZPrime3 * CTX));
            YPrime3 := Temp;
            Temp    := Round((XPrime3 * CTY) - (ZPrime3 * STY));
            ZPrime3 := Round((XPrime3 * STY) + (ZPrime3 * CTY));
            XPrime3 := Temp;
            Temp    := Round((XPrime3 * CTZ) - (YPrime3 * STZ));
            YPrime3 := Round((XPrime3 * STZ) + (YPrime3 * CTZ));
            XPrime3 := Temp;
            Temp    := Round((YPrime4 * CTX) - (ZPrime4 * STX));
            ZPrime4 := Round((YPrime4 * STX) + (ZPrime4 * CTX));
            YPrime4 := Temp;
            Temp    := Round((XPrime4 * CTY) - (ZPrime4 * STY));
            ZPrime4 := Round((XPrime4 * STY) + (ZPrime4 * CTY));
            XPrime4 := Temp;
            Temp    := Round((XPrime4 * CTZ) - (YPrime4 * STZ));
            YPrime4 := Round((XPrime4 * STZ) + (YPrime4 * CTZ));
            XPrime4 := Temp;
            { Translate Coords }
            XPrime1 := PolyHead^.X + XPrime1;
            YPrime1 := PolyHead^.Y + YPrime1;
            ZPrime1 := PolyHead^.Z + ZPrime1;
            XPrime2 := PolyHead^.X + XPrime2;
            YPrime2 := PolyHead^.Y + YPrime2;
            ZPrime2 := PolyHead^.Z + ZPrime2;
            XPrime3 := PolyHead^.X + XPrime3;
            YPrime3 := PolyHead^.Y + YPrime3;
            ZPrime3 := PolyHead^.Z + ZPrime3;
            XPrime4 := PolyHead^.X + XPrime4;
            YPrime4 := PolyHead^.Y + YPrime4;
            ZPrime4 := PolyHead^.Z + ZPrime4;
            { Translate 3D Vectorspace to 2D Framespace }
            CalcX1 := 160 + ((LongInt(XPrime1)*ViewerDist) DIV
                             (ZPrime1+ViewerDist));
            CalcY1 := 100 + ((LongInt(YPrime1)*ViewerDist) DIV
                             (ZPrime1+ViewerDist));
            CalcX2 := 160 + ((LongInt(XPrime2)*ViewerDist) DIV
                             (ZPrime2+ViewerDist));
            CalcY2 := 100 + ((LongInt(YPrime2)*ViewerDist) DIV
                             (ZPrime2+ViewerDist));
            CalcX3 := 160 + ((LongInt(XPrime3)*ViewerDist) DIV
                             (ZPrime3+ViewerDist));
            CalcY3 := 100 + ((LongInt(YPrime3)*ViewerDist) DIV
                             (ZPrime3+ViewerDist));
            CalcX4 := 160 + ((LongInt(XPrime4)*ViewerDist) DIV
                             (ZPrime4+ViewerDist));
            CalcY4 := 100 + ((LongInt(YPrime4)*ViewerDist) DIV
                             (ZPrime4+ViewerDist));
            { Draw Shape }
            DrawLine (CalcX1, CalcY1, CalcX2, CalcY2, Color);
            DrawLine (CalcX2, CalcY2, CalcX3, CalcY3, Color);
            DrawLine (CalcX3, CalcY3, CalcX4, CalcY4, Color);
            DrawLine (CalcX4, CalcY4, CalcX1, CalcY1, Color);
            DrawPolyFromList (PolyList^, WorkPage^, Color);
            CurrentFacet := CurrentFacet^.NextFacet;
       End;
End;
{-[ Build Background ]-----------------------------------------------------}
Procedure BuildBackground (Var BufferIn : VGAArray);
Var CounterX,
    CounterY  : Integer;
Begin
     For CounterY := 0 to 199 do
      For CounterX := 0 to 319 do
          BufferIn[CounterY, CounterX] := 1 + ((CounterY MOD 5) * 5) +
                                               (CounterX MOD 5);
End;
{-[ Build Palette ]--------------------------------------------------------}
Procedure BuildPalette (Var PaletteOut : PaletteType);
Const BC = 16;
Var Counter1,
    Counter2  : Integer;
Begin
     FillChar (PaletteOut, SizeOf(PaletteOut), 0);
     For Counter1 := 0 to 4 do
     For Counter2 := 1 to 2 do
     Begin
          PaletteOut[1+(Counter1 * 5)+Counter2].Red   := BC+(Counter2 * 5);
          PaletteOut[1+(Counter1 * 5)+Counter2].Green := BC+(Counter2 * 5);
          PaletteOut[1+(Counter1 * 5)+Counter2].Blue  := BC+(Counter2 * 5);
          PaletteOut[1+(Counter1 * 5)+4-Counter2].Red   := BC+(Counter2 * 5);
          PaletteOut[1+(Counter1 * 5)+4-Counter2].Green := BC+(Counter2 * 5);
          PaletteOut[1+(Counter1 * 5)+4-Counter2].Blue  := BC+(Counter2 * 5);
     End;
     For Counter1 := 0 to 4 do
     Begin
          If PaletteOut[1+(5 * 1)+Counter1].Red < BC + 5
          Then
          Begin
              PaletteOut[1+(5 * 1)+Counter1].Red   := BC + 5;
              PaletteOut[1+(5 * 1)+Counter1].Green := BC + 5;
              PaletteOut[1+(5 * 1)+Counter1].Blue  := BC + 5;
              PaletteOut[1+(5 * 3)+Counter1].Red   := BC + 5;
              PaletteOut[1+(5 * 3)+Counter1].Green := BC + 5;
              PaletteOut[1+(5 * 3)+Counter1].Blue  := BC + 5;
          End;
          PaletteOut[1+(5 * 2)+Counter1].Red   := BC + 10;
          PaletteOut[1+(5 * 2)+Counter1].Green := BC + 10;
          PaletteOut[1+(5 * 2)+Counter1].Blue  := BC + 10;
     End;
     For Counter1 := 0 to 24 do
     Begin
      PaletteOut[32+Counter1].Red   := ((PaletteOut[Counter1].Red* 8)+
                                        (26 * 24)) DIV 32;
      PaletteOut[32+Counter1].Green := ((PaletteOut[Counter1].Green* 8)+
                                        (0  * 24)) DIV 32;
      PaletteOut[32+Counter1].Blue  := ((PaletteOut[Counter1].Blue* 8)+
                                        (0  * 24)) DIV 32;
      PaletteOut[64+Counter1].Red   := ((PaletteOut[Counter1].Red* 8)+
                                        (0  * 24)) DIV 32;
      PaletteOut[64+Counter1].Green := ((PaletteOut[Counter1].Green* 8)+
                                        (26 * 24)) DIV 32;
      PaletteOut[64+Counter1].Blue  := ((PaletteOut[Counter1].Blue* 8)+
                                        (0  * 24)) DIV 32;
      PaletteOut[128+Counter1].Red   := ((PaletteOut[Counter1].Red* 8)+
                                        (0  * 24)) DIV 32;
      PaletteOut[128+Counter1].Green := ((PaletteOut[Counter1].Green* 8)+
                                        (0  * 24)) DIV 32;
      PaletteOut[128+Counter1].Blue  := ((PaletteOut[Counter1].Blue* 8)+
                                        (26 * 24)) DIV 32;
      PaletteOut[32+64+Counter1].Red   := ((PaletteOut[Counter1].Red* 6)+
                                        (23 * 26)) DIV 32;
      PaletteOut[32+64+Counter1].Green := ((PaletteOut[Counter1].Green* 6)+
                                        (23 * 26)) DIV 32;
      PaletteOut[32+64+Counter1].Blue  := ((PaletteOut[Counter1].Blue* 6)+
                                        (0  * 26)) DIV 32;
      PaletteOut[32+128+Counter1].Red   := ((PaletteOut[Counter1].Red* 6)+
                                        (23 * 26)) DIV 32;
      PaletteOut[32+128+Counter1].Green := ((PaletteOut[Counter1].Green* 6)+
                                        (0  * 26)) DIV 32;
      PaletteOut[32+128+Counter1].Blue  := ((PaletteOut[Counter1].Blue* 6)+
                                        (23 * 26)) DIV 32;
      PaletteOut[64+128+Counter1].Red   := ((PaletteOut[Counter1].Red* 6)+
                                        (0  * 26)) DIV 32;
      PaletteOut[64+128+Counter1].Green := ((PaletteOut[Counter1].Green* 6)+
                                        (23 * 26)) DIV 32;
      PaletteOut[64+128+Counter1].Blue  := ((PaletteOut[Counter1].Blue* 6)+
                                        (23 * 26)) DIV 32;
     End;
End;
{-[ Move Background by Moving Palette ]------------------------------------}
Procedure MoveBackground (Var PaletteIn : PaletteType);
Var TempPal : Array[0..5] of PaletteRec;
Begin
     {-- Move Background Colors --}
     Move (PaletteIn[1], TempPal[0], 5 * 3);
     Move (PaletteIn[1+5], PaletteIn[1], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[1 + (5 * 4)], 5 * 3);
     {-- Move See-Through Colors --}
     { Red }
     Move (PaletteIn[32], TempPal[0], 6 * 3);
     Move (PaletteIn[32+5], PaletteIn[32], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[32 + (5 * 4)], 6 * 3);
     { Green }
     Move (PaletteIn[64], TempPal[0], 6 * 3);
     Move (PaletteIn[64+5], PaletteIn[64], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[64 + (5 * 4)], 6 * 3);
     { Blue }
     Move (PaletteIn[128], TempPal[0], 6 * 3);
     Move (PaletteIn[128+5], PaletteIn[128], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[128 + (5 * 4)], 6 * 3);
     { Red + Green }
     Move (PaletteIn[(32 OR 64)], TempPal[0], 6 * 3);
     Move (PaletteIn[(32 OR 64)+5], PaletteIn[(32 OR 64)], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[(32 OR 64) + (5 * 4)], 6 * 3);
     { Red + Blue }
     Move (PaletteIn[(32 OR 128)], TempPal[0], 6 * 3);
     Move (PaletteIn[(32 OR 128)+5], PaletteIn[(32 OR 128)], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[(32 OR 128) + (5 * 4)], 6 * 3);
     { Green + Blue }
     Move (PaletteIn[(64 OR 128)], TempPal[0], 6 * 3);
     Move (PaletteIn[(64 OR 128)+5], PaletteIn[(64 OR 128)], ((5 * 4) * 3));
     Move (TempPal[0], PaletteIn[(64 OR 128) + (5 * 4)], 6 * 3);
End;
{-[ Set Palette ]----------------------------------------------------------}
Procedure SetPalette (Var PaletteIn : PaletteType); Assembler;
ASM
   PUSH DS
   LDS SI, PaletteIn { Sets whole palette at once...       }
   MOV CX, 256 * 3   {  *NOT* good practice since many VGA }
   MOV DX, 03DAh     {  cards will show snow at the top of }
   @WaitNotVSync:    {  of the screen.  It's done here     }
     IN  AL, DX      {  'cause the background animation    }
     AND AL, 8       {  requires large ammounts of the     }
   JNZ @WaitNotVSync {  palette to be updated every new    }
   @WaitVSync:       {  frame.                             }
     IN  AL, DX
     AND AL, 8
   JZ @WaitVSync
   XOR AX, AX
   MOV DX, 03C8h
   OUT DX, AL
   INC DX
   @PaletteLoop:
     LODSB
     OUT DX, AL
   LOOP @PaletteLoop
   POP DS
End;
{=[ Main Program ]=========================================================}
Var Polygon1 : PolyHPtr;
Begin
     VGAMEM := Ptr($A000, $0000);
     New (WorkPage);
     New (BkgPage);
     New (Palette);
     New (PolyList);
     ClearPolyList (PolyList^);
     GoMode13h;
     BuildBackground (BkgPage^);
     BuildPalette    (Palette^);
     SetPalette (Palette^);
     Polygon1 := Nil;
     InitializePolygon (Polygon1,  { Polygon List Head         }
                        0, 0, 60,  { X, Y, Z of polygon        }
                        0, 0, 0);  { Iniitial Roll, Pitch, Yaw }
     AddFacet (Polygon1,       { Polygon List Head        }
                32,            { Color                    }
               -40, -40,  50,  { One Corner of Polygon    }
                40, -40,  50,  { Second Corner of Polygon }
                40,  40,  50,  { Third Corner of Polygon  }
               -40,  40,  50); { Last Corner of Polygon   }
     AddFacet (Polygon1,
                64,
               -50, -40, -40,
               -50, -40,  40,
               -50,  40,  40,
               -50,  40, -40);
     AddFacet (Polygon1,
               128,
                40, -50, -40,
                40, -50,  40,
               -40, -50,  40,
               -40, -50, -40);
     Repeat
           { Clear Workpage }
           WorkPage^ := BkgPage^;
           ClearPolyList (PolyList^);
           DrawPolygon3D (Polygon1,    { Polygon Definition }
                          WorkPage);   { Work buffer        }
           MoveBackground (Palette^);
           SetPalette     (Palette^);
           { Display Work Buffer }
           VGAMEM^ := WorkPage^;
           RotatePolygon (Polygon1,
                          5, 10, 1);
     Until Keypressed;
     DisposePolygon (Polygon1);
     Dispose (PolyList);
     Dispose (Palette);
     Dispose (BkgPage);
     Dispose (WorkPage);
     TextMode (C80);
End.
