Unit X3840;
{=========================================
 =   320X200 3840 color, 2 page Mode X   =
 =        by David Dahl @ 1:272/85       =
 =========================================}
(* PUBLIC DOMAIN *)
Interface
  Uses CRT, DOS;
  Procedure PutPixel (XCoord, YCoord   : Word;
                      Red, Green, Blue : Byte);
  Procedure InitializeGraphics;
  Procedure EnableScreen;
  Procedure SetActivePage (PageNo : Word);
  Procedure SetDisplayPage (PageNo : Word);
Implementation
Const SC_INDEX = $3C4; SC_MEM_MODE = 4;
      GC_INDEX = $3CE; GC_GRAPH_MODE = 5; GC_MISCELL = 6;
      CRTC_INDEX = $3D4; CC_UNDERLINE = $14; CC_MODE_CTRL = $17;
      DAC_WRITE_ADR = $3C8; DAC_DATA = $3C9;
      SeqCtrlIndex   = $3C4;
      AttrCtrlWrite  = $3C0;
      INPUT_STATUS_1 = $3DA;
Type  PageOfsArray = Array[0..3] of Word;
      CRTCPageRec = Record High:Word; Low:Word; End;
      CRTCPageArray = Array[0..3] of CRTCPageRec;
      PaletteRec = Record Red:Byte; Green:Byte; Blue:Byte; End;
      PaletteArray = Array [0..255] of PaletteRec;
Const PageOfs    : PageOfsArray = ($0000,$4000,$8000,$C000);
Var   CRTCPage   : CRTCPageArray;
      Palette    : PaletteArray;
      InGraphics : Boolean;
      SaveExit   : Pointer;
      DisplayPage : Word;
      ActivePage  : Word;
      PageNum     : Word;
{-[ Initialize Variables ]------------------------------------------------}
Procedure InitializeVariables;
Var Index : Integer;
    RedCount,
    GreenCount,
    BlueCount   : Integer;
Begin
  PageNum     := 0;
  DisplayPage := 0;
  ActivePage  := 0;
  { Calculate CRTC Page Offsets }
  For Index := 0 to 3 do
  Begin
    CRTCPage[Index].High := (Word(Hi(PageOfs[Index])) SHL 8) OR $0C;
    CRTCPage[Index].Low  := (Word(Lo(PageOfs[Index])) SHL 8) OR $0D;
  End;
  { Calculate Palette }
  Index := 0;
  For BlueCount := 0 to 14 do
    For RedCount := 0 to 15 do
    Begin
      Palette[Index].Red   := (RedCount  * 63) DIV 15;
      Palette[Index].Green := 0;
      Palette[Index].Blue  := (BlueCount * 63) DIV 14;
      Inc(Index)
    End;
  For GreenCount := 0 to 15 do
  Begin
    Palette[Index].Red   := 0;
    Palette[Index].Green := (GreenCount * 63) DIV 15;
    Palette[Index].Blue  := 0;
    Inc(Index);
  End;
End;
{-[ Put Pixel To Screen ]-------------------------------------------------}
Procedure PutPixel (XCoord, YCoord   : Word;
                    Red, Green, Blue : Byte); Assembler;
ASM
  MOV AX, SegA000; MOV ES, AX
  MOV DI, ActivePage; SHL DI, 1; MOV BX, XCoord;
  MOV CX, BX; AND CX, $03; MOV AX, 1; SHL AX, CL
  MOV DX, SeqCtrlIndex; MOV AH, AL; MOV AL, 2; OUT DX, AX
  ADD BX, YCoord; MOV CX, BX; AND BX, 1; SHL BX, 1
  MOV SI, Word(PageOfs[DI+BX])
  MOV BX, CX; INC BX; AND BX, 1;  SHL BX, 1
  MOV DI, Word(PageOfs[DI+BX])
  MOV AX, YCoord; MOV BX, AX; SHL AX, 4; SHL BX, 6; ADD AX, BX
  MOV BX, XCoord; SHR BX, 2; ADD BX, AX
  MOV AL, Blue; SHL AL, 4; ADD AL, Red
  MOV AH, Green; ADD AH, 15 * 16
  MOV ES:[DI+BX], AH; MOV ES:[SI+BX], AL
End;
{-[ Set VGA DAC ]---------------------------------------------------------}
Procedure SetPalette (Pal : Pointer); Assembler;
ASM
  LES DI, Pal; MOV DX, DAC_WRITE_ADR; XOR AL, AL; OUT DX, AL
  MOV DX, DAC_DATA; MOV CX, 256 * 3
  @PalOut:; MOV AL, Byte(ES:[DI]); INC DI; OUT DX, AL; LOOP @PalOut
END;
{-[ Initialize 3840 Color Mode X ]----------------------------------------}
Procedure InitializeGraphics;
Begin
  InGraphics := True;
  ASM
    MOV AX, $12; INT $10; MOV AX, $13; INT $10
    MOV DX, GC_INDEX; MOV AL, GC_GRAPH_MODE; OUT DX, AL; INC DX
    IN  AL, DX; AND AL, 11101111b; OUT DX, AL; DEC DX
    MOV AL, GC_MISCELL; OUT DX, AL; INC DX; IN  AL, DX
    AND AL, 11111101b; OUT DX, AL
    MOV DX, SC_INDEX; MOV AL, SC_MEM_MODE; OUT DX, AL; INC DX
    IN  AL, DX; AND AL, 11110111b; OR  AL, 4; OUT DX, AL
    MOV DX, CRTC_INDEX; MOV AL, CC_UNDERLINE; OUT DX, AL; INC DX
    IN  AL, DX; AND AL, 10111111b; OR  AL, 4; OUT DX, AL; DEC DX
    MOV AL, CC_MODE_CTRL; OUT DX, AL; INC DX; IN  AL, DX
    OR  AL, 01000000b; OUT DX, AL
  END;
  PortW[CRTC_INDEX]  := $4218;
  Port[CRTC_INDEX]   := $07;
  Port[CRTC_INDEX+1] := Port[CRTC_INDEX+1] OR $10;
  Port[CRTC_INDEX]   := $09;
  Port[CRTC_INDEX+1] := Port[CRTC_INDEX+1] AND Not($20);
  Port[AttrCtrlWrite] := $10 OR $20;
  Port[AttrCtrlWrite] := $61; {01100001b;}
  SetPalette (Addr(Palette));
End;
{-[ Ping-Pong Screen To Enable 3840 Colors ]------------------------------}
Procedure EnableScreen;
Begin
  PageNum := (PageNum + 1) AND 1;
  Repeat Until (Port[Input_Status_1] AND 8) = 0;
  PortW[CRTC_INDEX] := CRTCPage[PageNum OR DisplayPage].High;
  PortW[CRTC_INDEX] := CRTCPage[PageNum OR DisplayPage].Low;
  Repeat Until (Port[Input_Status_1] AND 8) <> 0;
End;
{-[ Set Active Page # ]---------------------------------------------------}
Procedure SetActivePage (PageNo : Word);
Begin ActivePage := (PageNo AND 1) SHL 1; End;
{-[ Set Display Page # ]--------------------------------------------------}
Procedure SetDisplayPage (PageNo : Word);
Begin DisplayPage := (PageNo AND 1) SHL 1; End;
{-[ Exit Code ]-----------------------------------------------------------}
{$F+}
Procedure GpxExit;
Begin
  ExitProc := SaveExit;
  If InGraphics
  Then
    TextMode(C80);
End;
{$F-}
{=[ Unit Init Code ]======================================================}
Begin
  InGraphics := False;
  SaveExit   := ExitProc;
  ExitProc   := Addr(GpxExit);
  InitializeVariables;
End.

{  -------------------  DEMO PROGRAMS ------------------ }

{$Q-,A+,S-,R-}
Program DisplayTGA;
{====================================
 = Display TGA in 3840 color Mode X =
 =     by David Dahl @ 1:272/85     =
 ====================================}
(* Public Domain *)
Uses CRT, X3840;
Type TGAHeaderRec = Record
                      IDLen      : Byte;
                      ColMapType : Byte; ImageType : Byte;
                      CMOrg      : Word; CMLen     : Word; CMBits : Byte;
                      XOfs       : Word; YOfs      : Word;
                      XSize      : Word; YSize     : Word;
                      BPix       : Byte;
                      ImageDesc  : Byte;
                    End;
     TGAHeaderPtr = ^TGAHeaderRec;
     Buffer32Array = Array [0 .. (127 * 4)] of Byte;
     Buffer32Ptr   = ^Buffer32Array;
Var Header       : TGAHeaderPtr;
    Fin          : File;
    YPos, XPos   : LongInt;
    XSize, YSize : Integer;
    CodeByte     : Byte;
    Count        : Byte;
    Index        : Word;
    ColorBuffer  : Buffer32Ptr;
    PixelSize    : Word;
    Done         : Boolean;
    FileName     : String;
Begin
  New (ColorBuffer); New (Header);
  If ParamCount = 1
  Then
    FileName := ParamStr(1)
  Else
  Begin
    Writeln ('Enter Filename of Targa File to View');
    Readln  (FileName);
  End;
  If Pos('.',FileName) = 0
  Then
    FileName := FileName + '.TGA';
  Assign (Fin, FileName); Reset  (Fin,1);
  BlockRead (Fin, Header^, SizeOf(Header^));
  If Header^.ImageDesc = 0
  Then
  Begin
    With Header^ do
    Begin
      Writeln ('XSize, YSize :',XSize:6,YSize:6);
      Writeln ('Image Type   :',ImageType:6);
      Writeln ('Bits/Pixel   :',BPix:6);
    End;
    If ((Header^.BPix = 16)OR(Header^.BPix = 24)OR(Header^.BPix = 32)) AND
       (Header^.ImageType >= 8)
    Then
    Begin
      Writeln ('Press Any Key To View Image.');
      While Keypressed do Readkey;
      Repeat Until Keypressed;
      While Keypressed do Readkey;
      InitializeGraphics;
      XSize     := Header^.XSize;
      YSize     := Header^.YSize;
      XPos      := 0;
      YPos      := Header^.YSize-1;
      PixelSize := (Header^.BPix SHR 3);
      Done      := False;
      Repeat
        BlockRead (Fin, CodeByte, SizeOf(CodeByte));
        Count := (CodeByte AND 127) + 1;
        CodeByte := CodeByte SHR 7;
        If CodeByte = 0
        Then  { Output Count Colors }
        Begin
          BlockRead (Fin, ColorBuffer^, Count * PixelSize);
          Index := 0;
          While (Count > 0) AND Not(Done) do
          Begin
            If PixelSize > 2
            Then
              PutPixel ((XPos * 319) DIV XSize,
                        (YPos * 199) DIV YSize,
                        ColorBuffer^[Index+2] SHR 4,  { Red   }
                        ColorBuffer^[Index+1] SHR 4,  { Green }
                        (ColorBuffer^[Index] * 14) DIV 255) { Blue  }
            Else
              PutPixel ((XPos * 319) DIV XSize,
                        (YPos * 199) DIV YSize,
                        (ColorBuffer^[Index+1] SHR 3) AND 15,   { Red   }
                        ((ColorBuffer^[Index] SHR 6) OR
                        (ColorBuffer^[Index+1] SHL 2)) AND 15, { Green }
                        (ColorBuffer^[Index] SHR 1) AND 15);    { Blue  }
            Inc(Index, PixelSize);
            Dec(Count);
            Inc(XPos,1);
            If XPos >= XSize
            Then
            Begin
              XPos := 0; Dec (YPos);
              If YPos < 0
              Then
                Done := True;
            End;
            If KeyPressed
            Then
              Done := ReadKey = #27;
          End;
        End
        Else
        Begin  { Output Color Count Times }
          BlockRead (Fin, ColorBuffer^, PixelSize);
          While (Count > 0) AND Not(Done) do
          Begin
            If PixelSize > 2
            Then
              PutPixel ((XPos * 319) DIV XSize,
                        (YPos * 199) DIV YSize,
                        ColorBuffer^[2] SHR 4,  { Red   }
                        ColorBuffer^[1] SHR 4,  { Green }
                        (ColorBuffer^[0] * 14) DIV 255) { Blue  }
            Else
              PutPixel ((XPos * 319) DIV XSize,
                        (YPos * 199) DIV YSize,
                        (ColorBuffer^[1] SHR 3) AND 15,   { Red   }
                        ((ColorBuffer^[0] SHR 6) OR
                         (ColorBuffer^[1] SHL 2)) AND 15, { Green }
                        (ColorBuffer^[0] SHR 1) AND 15);  { Blue  }
            Dec(Count);
            Inc(XPos,1);
            If XPos >= XSize
            Then
            Begin
              XPos := 0; Dec (YPos);
              If YPos < 0
              Then
                Done := True;
            End;
            If KeyPressed
            Then
              Done := ReadKey = #27;
          End;
        End;
      Until Done;
      While Keypressed do Readkey;
      Repeat EnableScreen Until Keypressed;
      While Keypressed do Readkey;
      TextMode (C80);
    End
    Else
      Writeln ('Cannot view this picture.');
  End
  Else
    Writeln ('Not a TGA File.');
  Close  (Fin); Dispose (Header); Dispose (ColorBuffer);
End.

{ --------------------------- CUT -------------- }

Program TestX3840;
{=============================
 =  Display All 3840 Colors  =
 = by David Dahl  @ 1:272/85 =
 =============================}
(* PUBLIC DOMAIN *)
Uses CRT, X3840;
Var Red, Green, Blue : Integer;
Begin
  InitializeGraphics;                    { Initialize 3840 Color Mode X }
  For Red := 0 to 15 do
    For Green := 0 to 15 do
      For Blue := 0 to 14 do
        PutPixel (Red+(Blue*16), Green,  { X, Y  }
                  Red, Green, Blue);     { Color }
  Repeat EnableScreen Until Keypressed;  { Enable 3840 Colors }
  While Keypressed do Readkey;
  TextMode(C80);
End.

----------------------------[ CUT HERE ]------------------------

        Message 1 contains a unit to display a pseudo 3840 
color Mode X on a standard VGA.  Message 2 contains a bare-bone 
Targa viewer.  Message 3 contains a program to display all 3840 
colors to the screen and this short text description.  

        A brief description of the procedures in the X3840 unit 
follow: 

InitializeGraphics;

  Initializes the 3840 color graphic mode.  EnableScreen must be 
  called to view the 3840 colors.

EnableScreen;

  Enables 3840 colors.  This procedure should be called in a 
  tight loop in order to properly display the colors.  See included 
  programs for example. 

Putpixel (XCoord, YCoord : Integer; Red, Green, Blue : Byte); 

  XCoord is an integer in the set 0 .. 319.  YCoord is an integer 
  in the set 0 .. 199.  Red, Green, and Blue specify the 
  corresponding color components of the pixel.  Red and Green 
  must be in the set 0 .. 15, but Blue must be in the set 0 .. 
  14.  No range checking is performed so you must make sure the 
  values do not stray outside these sets or unexpected results 
  will occur. 

SetActivePage (PageNumber : Integer);
  
  Sets the page to be written to.  There are 2 pages (0 and 1) 
  for use.

SetDisplayPage (PageNumber : Integer);

  Sets the page to be displayed.  There are 2 pages (0 and 1) for 
  use.

        How 3840 color works: 
        This mode is really just a 256 color mode in which the 
palette has been carefully selected to give 16 intensities of red 
and green, and 15 intensities of blue.  The red and blue colors 
are mixed in the palette as indices 0 .. 239, and green as 
indices 240 .. 255.  To get an effective 3840 colors, the 
red/blue mix of a pixel is placed on one page and the green is 
placed on another page and the screen is flipped quickly between 
the two pages.  If the pages are flipped quick enough, your eye 
blends he colors together and sees 3840 colors (16R * 16G * 15B) 
instead of just 256. 

        The bare-bone targa file viewer will only view 16, 24, or 
32-bit color RLE compressed files.  8-Bit Grey scale and raw 
image files are not supported.  I only tested it on a 24-bit 
image, but I believe 16 and 32-bit should work alright also. 

                                                Dave

