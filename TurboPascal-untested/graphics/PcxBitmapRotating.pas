(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0117.PAS
  Description: Pcx Bitmap Rotating
  Author: ANDREW EIGUS
  Date: 08-24-94  13:50
*)

{ ROTATE.PAS }

{
  Rotating textured surface.
  Coded by Mike Shirobokov(MSH) aka Mad Max / Queue members.
  You can do anything with this code until this comments
  remain unchanged.

  Bugs corrected by Alex Grischenko
}

{$G+,A-,V-,X+}
{$M 16384,0,16384}

uses Crt, Objects, Memory, VgaGraph;  { unit code at the end of program }

const
{ Try to play with this constants }
  RotateSteps  = {64*5}65*10;
  AngleStep    = {3}1;
  MoveStep     = {10}1;
  ScaleStep    : Real =  0.02;

type
  TBPoint = record X,Y: { Byte} Integer; end;
  TPointArray = array[ 1..500 ] of TBPoint;

  TRotateApp = object(TGraphApplication)
    StartTime,
    FramesNumber:LongInt;
    {Texture: TImage;}
    X,Y    : Integer;
    WSX,WSY: Integer;
    WSXR,
    WSYR   : Real;
    Angle  : Integer;
    Size   : TPoint;
    CurPage: Integer;
    Texture: TImage;
    constructor Init;
    procedure Run;      virtual;
    destructor Done;    virtual;
    procedure Draw;     virtual;
    procedure FlipPage; virtual;
    procedure Rotate( AngleStep: Integer );
    procedure Move( DeltaX, DeltaY: Integer );
    procedure Scale( Factor: Real );
    procedure Update;
  end;
var
  Pal:  TRGBPalette;
  Time:  LongInt absolute $0:$46C;

procedure TRotateApp.FlipPage;
begin
  CurPage := 1-CurPage;
  ShowPage(1-CurPage);
end;

constructor TRotateApp.Init;
var
  I, J: Integer;
begin
  if not inherited Init(True) or not Texture.Load( ParamStr(1) ) then Fail;
  SetPalette( Texture.Palette );
  X := 0;
  Y := 0;
  WSX := 240;
  WSY := 360;
  WSXR := WSX;
  WSYR := WSY;
  Angle := 0;
  Size.X := HRes div 2;
  Size.Y := VRes div 2;
  FramesNumber := 0;
  StartTime := Time;  {     asm mov ax,13h; int 10h; end;}
  system.move (Texture.Data^,Screen,64000);
    SetPalette( Texture.Palette );
{  readkey;}
end;

procedure TRotateApp.Rotate( AngleStep: Integer );
begin
  Inc( Angle, AngleStep );
  Angle := Angle mod RotateSteps;
end;

procedure TRotateApp.Move( DeltaX, DeltaY: Integer );
begin
  Inc( X, DeltaX );
  Inc( Y, DeltaY );
end;

procedure TRotateApp.Scale( Factor: Real );
begin
  WSXR := WSXR*Factor;
  WSX := Round(WSXR);
  WSYR := WSYR*Factor;
  WSY := Round(WSYR);
end;

procedure TRotateApp.Update;
begin
  Move( MoveStep, MoveStep );
  Rotate(AngleStep);
  Scale(1+ScaleStep);
  if (WSY >= 2000) or (WSY<=100) then ScaleStep := -ScaleStep;
end;

procedure TRotateApp.Draw;

var
  I :  Integer;
  Border,
  LineBuf: TPointArray;
  BorderLen: Integer;
  X1RN,X1LN,
  Y1RN,Y1LN,
  X2RN,X2LN,
  Y2RN,Y2LN,
  X1R,X1L,
  Y1R,Y1L,
  X2R,X2L,
  Y2R,Y2L,
  XL,YL: Integer;

{ This function can be heavly optimized but I'm too lazy to do absoletely
  meaningless things :-) }
function BuildLine( var Buffer: TPointArray; X1,Y1, X2,Y2: Integer;
      Len: Integer ): Integer;
var
  I: Word;
  XStep,
  YStep: LongInt;
begin
  XStep := (LongInt(X2-X1) shl 16) div Len;
  YStep := (LongInt(Y2-Y1) shl 16) div Len;
  for I := 1 to Len do
  begin
    Buffer[I].X := Integer( ((XStep*I) shr 16) - ((XStep*(I-1)) shr 16) );
    Buffer[I].Y := Integer( ((YStep*I) shr 16) - ((YStep*(I-1)) shr 16) );
  end;
end;

procedure DrawPicLine( var Buffer; BitPlane: Integer;
        StartX, StartY: Integer; Len: Integer; var LineBuf );
var
  PD :  Pointer;
begin
  PD := Texture.Data;           { pointer to unpacked screen image }
  Port[$3C4] := 2;
  if BitPlane = 0 then
    Port[$3C5] := 3
  else
    Port[$3C5] := 12;

  asm
    push  ds
    mov   bx,[StartX]             { bx = StartX }
    mov   dx,[StartY]             { dx = StartY }
    les   di,Buffer               { ES:DI = @Screen }
    add   di,VPageLen/2-Hres/4    { calc target page }
    mov   cx,Len                  { Drawing buffer length }
    lds   si,PD                   { DS:SI = pointer to data }
    push  bp                      { store BP }
    mov   bp,word ptr LineBuf     { BP = offset LineBuf }
    cld
@loop:
      PUSH DX
      MOV  AX,320
      MUL  DX                     { AX = StartY*320 }
      POP  DX

      PUSH BX
      ADD  BX,AX
      mov  al,[bx+SI]
      POP  BX

      stosb
      sub  di,HRes/4+1{ add di,hres-1}
      add  BX,[bp]
      ADD  bp,2
      add  DX,[bp]
      ADD  bp,2

{      CMP  BX,320
      JB   @@1
      XOR  BX,BX
@@1:  CMP  DX,200
      JB   @@2
      XOR  DX,DX
@@2:}
      loop @loop

      pop bp
      pop ds
  end;
end;

begin

{ Just imagine what can be if the next 8 lines would be more complex.
  I'm working around it. }
{
     (X1L,Y1L)        (X2R,Y1R)
        +---------------+
        |               |
        |               |
        |               |
        +---------------+
     (X2L,Y2L)        (X2R,Y2R)

     (X1LN,Y1LN)        (X2RN,Y1RN)
        +---------------+
        |               |
        |               |
        |               |
        +---------------+
     (X2LN,Y2LN)        (X2RN,Y2RN)

}
  X1L := 0;
  Y1L := 0;
  X2L := 0;
  Y2L := WSY;
  X1R := WSX;
  Y1R := 0;
  X2R := WSX;
  Y2R := WSY;
{ I call Cos and Sin instead of using tables!? Yeah, I do. So what?
  See comments near BuildLine ;-) }
{  I just rotate the rectangle corners, but why I do no more? }
  X1RN := Round(
(X1R*Cos(2*Pi/RotateSteps*Angle)+Y1R*Sin(2*Pi/RotateSteps*Angle)) );
  Y1RN := Round(
(Y1R*Cos(2*Pi/RotateSteps*Angle)-X1R*Sin(2*Pi/RotateSteps*Angle)) );
  X1LN := Round(
(X1L*Cos(2*Pi/RotateSteps*Angle)+Y1L*Sin(2*Pi/RotateSteps*Angle)) );
  Y1LN := Round(
(Y1L*Cos(2*Pi/RotateSteps*Angle)-X1L*Sin(2*Pi/RotateSteps*Angle)) );
  X2RN := Round(
(X2R*Cos(2*Pi/RotateSteps*Angle)+Y2R*Sin(2*Pi/RotateSteps*Angle)) );
  Y2RN := Round(
(Y2R*Cos(2*Pi/RotateSteps*Angle)-X2R*Sin(2*Pi/RotateSteps*Angle)) );
  X2LN := Round(
(X2L*Cos(2*Pi/RotateSteps*Angle)+Y2L*Sin(2*Pi/RotateSteps*Angle)) );
  Y2LN := Round(
(Y2L*Cos(2*Pi/RotateSteps*Angle)-X2L*Sin(2*Pi/RotateSteps*Angle)) );

  XL := X+X1LN;
  YL := Y+Y1LN;

  BuildLine( Border, XL,YL, X+X2LN,Y+Y2LN, Size.X );
  BuildLine( LineBuf, 0, 0, X1RN-X1LN, Y1RN-Y1LN, Size.Y );

{
  The only thing that can be optimized is the loop below. I think it should
  be completely in asm.
}
  for I := 1 to Size.X do
  begin
   DrawPicLine( PBuffer(@Screen)^[CurPage*VPageLen+(I-1) shr 1],
   (I-1) {mod 2} and 1, XL, YL, Size.Y, LineBuf );
{
    Inc( XL, Border[I].X );
    Inc( YL, Border[I].Y );
}
  asm
    mov   di,I
    shl   di,2
    mov   ax,word ptr border[di]-4
    add   XL,ax
    mov   ax,word ptr Border[di]-4+2
    add   YL,ax
  end;
  end;
end;

procedure TRotateApp.Run;
var
  C:  Char;
begin
  repeat
    if KeyPressed then
    begin
      C := ReadKey;
      if C = #0 then C := ReadKey;
      case C of
 #72: Move(0,-10);
 #80: Move(0,-10);
 #75: Move(-10,0);
 #77: Move(10,0);
 #81: Rotate(1);
 #79: Rotate(-1);
 '+': Scale(1+ScaleStep);
 '-': Scale(1-ScaleStep);
 #27: Exit;
      end;
    end;
   Draw;
{ You can comment out the line below and do all transformation yourself }
   Update;
   FlipPage;
   Inc( FramesNumber );
  until False;
end;

destructor TRotateApp.Done;
begin
  inherited Done;
  WriteLn( 'Frames per second = ',
    (FramesNumber / ((Time-StartTime)*0.055) ):5:2 );
end;

var
  RotateApp: TRotateApp;
begin
  if not RotateApp.Init then Exit;
  RotateApp.Run;
  RotateApp.Done;
end.

{---------------------   UNIT CODE NEEDED HERE -------------------- }

{
  VGA graphics unit.
  Coded by Mike Shirobokov(MSH) aka Mad Max / Queue members.

  This this the very small part of my gfx unit. I leave only functions used
  by RotateApp.

  Bugs corrected by Alex Grischenko
}

unit VGAGraph;

interface

uses Objects, Memory;

const
  HRes  = 360;
  VRes  = 320;
  VPageLen = HRes*VRes div 4;

{  HRes = 320; VRes=200; Vpagelen=0;}

type
  PBuffer = ^TBuffer;
  TBuffer = array[ 0..65534 ] of Byte;
  PScreenBuffer = ^TScreenBuffer;
  TScreenBuffer = array[ 0..199, 0..319 ] of Byte;
  TRGBPalette = array[ 0..255 ] of record R,G,B: Byte; end;

  PImage = ^TImage;
  TImage = object( TObject )
    Size: TPoint;
    Palette: TRGBPalette;
    Data: PBuffer;
    constructor Load( Name: String );
{   This procedures are now killed. If you need them just write me or see
    old mail from me.
    procedure Show( Origin: TPoint; var Buffer );
    procedure ShowRect( Origin: TPoint; NewSize: TPoint; var Buffer ); }
    destructor Done; virtual;
  end;

  PGraphApplication = ^TGraphApplication;
  TGraphApplication = object( TObject )
    constructor Init( ModeX : Boolean );
    procedure Run; virtual;
    destructor Done; virtual;
  end;

var
  Screen: TScreenBuffer absolute $A000:0;

  procedure SetPalette( var Pal: TRGBPalette );
  procedure Set360x240Mode;
  procedure ShowPage( Page: Integer );

implementation

uses PCX;

constructor TImage.Load( Name: String );
var
  S: TDosStream;
  I: Integer;
  P: OldPCXPicture;
  Len: Word;
begin
  inherited Init;
  P.Init( Name );
  if P.Status <> pcxOK then
  begin
    P.Done;
    Fail;
  end;
  Size.X := P.H.XMax - P.H.XMin + 1;
  Size.Y := P.H.YMax - P.H.YMin + 1;
{
  I use DOS memory allocation 'cuz GetMem can't allocate 64K
  Even thru DPMI.  :-(
  GetMem( Data, Word(Size.X) * Size.Y );
}
  Len := Word((LongInt(Size.X)*Size.Y+15) div 16);
  LEN:=65536 DIV 16;
  asm
    mov ah,48h
    mov bx,Len
    int 21h
    jnc @mem_ok
    xor ax,ax
@mem_ok:
    mov word ptr es:[di].Data+2,ax
    xor ax,ax
    mov word ptr es:[di].Data,ax
  end;

  if Data = nil then
  begin
    P.Done;
    Fail;
  end;

  fillchar(Data^,len*16-1,0);

  Move( P.Pal, Palette, SizeOf(Palette) );
  for I := 0 to 255 do
  begin
    Palette[I].R := Palette[I].R shr 2;
    Palette[I].G := Palette[I].G shr 2;
    Palette[I].B := Palette[I].B shr 2;
  end;

  for I := 0 to Size.Y-1 do
    P.ReadLine( Data^[ Word(Size.X)*I ] );
  P.Done;
end;

destructor TImage.Done;
begin
{
  FreeMem( Data, Word(Size.X)*Size.Y );
}
  asm
    mov ah,49h
    mov ax,word ptr es:[di].Data+2
    mov es,ax
    int 21h
  end;
  inherited Done;
end;

constructor TGraphApplication.Init( ModeX : Boolean );
begin
  Set360x240Mode
end;

procedure TGraphApplication.Run;
begin
  Abstract;
end;

destructor TGraphApplication.Done;
begin
  asm
    mov ax,3h
    int 10h
  end;
end;

procedure SetPalette( var Pal: TRGBPalette );
var
  I : Integer;
begin
  for I := 0 to 255 do
  begin
    Port[$3C8] := I;
    Port[$3C9] := Pal[I].R;
    Port[$3C9] := Pal[I].G;
    Port[$3C9] := Pal[I].B;
  end;
end;

{  Modified from public-domain mode set code by John Bridges. }

const
 SC_INDEX  = $03c4;   {Sequence Controller Index}
 CRTC_INDEX = $03d4;   {CRT Controller Index}
 MISC_OUTPUT  = $03c2;   {Miscellaneous Output register}

{ Index/data pairs for CRT Controller registers that differ between
  mode 13h and mode X. }

CRT_PARM_LENGTH = 17;
CRTParms : array [1..CRT_PARM_LENGTH] of Word = (

 $6B00,  { Horz total }
 $5901,  { Horz Displayed }
 $5A02,  { Start Horz Blanking }
 $8E03,  { End Horz Blanking }
 $5E04,  { Start H Sync }
 $8A05,  { End H Sync }
 $0d06,  {vertical total}
 $3e07,  {overflow (bit 8 of vertical counts)}
 $ea10,  {v sync start}
 $8c11,  {v sync end and protect cr0-cr7}
 $df12,  {vertical displayed}
 $e715,  {v blank start}
 $0616,  {v blank end}
 $4209,  {cell height (2 to double-scan)}
 $0014,  {turn off dword mode}
 $e317,  {turn on byte mode}
 $2D13 {90 bytes per line}
);

procedure Set360x240Mode;
begin
 asm
 mov     ax,13h  {let the BIOS set standard 256-color}
 int     10h     {mode (320x200 linear)}

 mov     dx,SC_INDEX
 mov     ax,0604h
 out     dx,ax   {disable chain4 mode}
 mov     ax,0100h
 out     dx,ax   {synchronous reset while switching clocks}

 mov     dx,MISC_OUTPUT
 mov     al,0E7h
 out     dx,al   {select 28 MHz dot clock & 60 Hz scanning rate}

 mov     dx,SC_INDEX
 mov     ax,0300h
 out     dx,ax   {undo reset (restart sequencer)}

 mov     dx,CRTC_INDEX {reprogram the CRT Controller}
 mov     al,11h  {VSync End reg contains register write}
 out     dx,al   {protect bit}
 inc     dx      {CRT Controller Data register}
 in      al,dx   {get current VSync End register setting}
 and     al,7fh  {remove write protect on various}
 out     dx,al   {CRTC registers}
 dec     dx      {CRT Controller Index}
 cld
 mov     si,offset CRTParms {point to CRT parameter table}
 mov     cx,CRT_PARM_LENGTH {# of table entries}
@SetCRTParmsLoop:
 lodsw           {get the next CRT Index/Data pair}
 out     dx,ax   {set the next CRT Index/Data pair}
 push cx
 mov cx,1000
@loop: loop @loop
 pop cx
 loop    @SetCRTParmsLoop

 mov     dx,SC_INDEX
 mov     ax,0f02h
 out     dx,ax   {enable writes to all four planes}
 mov     ax,$A000{now clear all display memory, 8 pixels}
 mov     es,ax         {at a time}
 sub     di,di   {point ES:DI to display memory}
 sub     ax,ax   {clear to zero-value pixels}
 mov     cx,VRes*HRes/4/2 {# of words in display memory}
 rep     stosw   {clear all of display memory}
 end;
end;

procedure ShowPage( Page: Integer );
begin
  asm
      mov ax,VPageLen
      mul word ptr Page
      mov bx,ax

      mov dx,3d4h
      mov al,0ch
      mov ah,bh
      out dx,ax
      mov dx,3d4h
      mov al,0dh
      mov ah,bl
      out dx,ax
{ Uncomment this waiting for retrace if you see flickering }
{
      mov dx,3dah
 @@1: in al,dx
      test al,00001000b
      jz @@1
 @@2: in   al,dx
      test al,00001000b
      jnz  @@2
}
  end;
end;

End.

{ --------------------------  UNIT CODE NEEDED HERE -------------}

{
  256 color PCX bitmaps handling unit.
  NewPCXPicture object are removed to reduce traffic. If you
  need it just contact me or dig in old mail from me.
  Coded by Mike Shirobokov(MSH) aka Mad Max / Queue Members.
  Free sourceware.
}

unit PCX;

interface

uses Objects;

type
  TRGBPalette = array[ 0..255 ] of record R,G,B: Byte; end;

  PCXHeader = record
    Creator,
    Version,
    Encoding,
    Bits: Byte;
    XMin,
    YMin,
    XMax,
    YMax,
    HRes,
    VRes: Integer;
    Palette: array [ 1..48 ] of Byte;
    VMode,
    Planes: Byte;
    BytesPerLine,
    PaletteInfo,
    SHRes,
    SVRes: Word;
    Dummy: array [0..53] of Byte;
  end;

const
  pcxOK   = 0;
  pcxInvalidType = 1;
  pcxNoFile  = 2;

type
  OldPCXPicture = object
    H:  PCXHeader;
    S:  TBufStream;
    Pal: TRGBPalette;
    Status: Integer;
    constructor Init( AFileName: String );
    procedure ReadLine( var Buffer );
    function ErrorText: String;
    destructor Done;
  end;
{
  NewPCXPicture = object
    H:  PCXHeader;
    S:  TBufStream;
    Pal: TRGBPalette;
    constructor Init( AFileName: String; HSize: Integer );
    procedure WriteLine( var Buffer );
    destructor Done;
  end;
}
implementation

type
  GetByteFunc = function: Byte;
  ByteArr = array [0..65534] of Byte;
  PByte  = ^ByteArr;

procedure UnpackString( GetByte: GetByteFunc; var Dest; Size: Integer );
var
  DestPtr: PByte;
  Count: Integer;
  B:  Byte;
  I:  Integer;
begin
  DestPtr := @Dest;
  Count := 0;
  while Count < Size do
  begin
    B := GetByte;
    if B < $C0 then
    begin
      DestPtr^[Count] := B;
      Inc(Count);
    end
    else
    begin
      DestPtr^[Count] := GetByte;
      for I := 0 to B-$C1 do
 DestPtr^[Count+I] := DestPtr^[Count];
      Inc( Count, I+1 );
    end;
  end;
end;

constructor OldPCXPicture.Init( AFileName: String );
begin
  S.Init( AFileName, stOpenRead, 2048 );
  if S.Status <> stOk then
  begin
    Status := pcxNoFile;
    Exit;
  end;
  S.Read( H, SizeOf(H) );
  if (H.Planes <> 1) or (H.Encoding <> 1) or (H.Bits <> 8 ) then
  begin
    Status := pcxInvalidType;
    Exit;
  end;
  S.Seek( S.GetSize - SizeOf(Pal) );
  S.Read( Pal, SizeOf(Pal) );
  S.Seek( SizeOf(H) );
  Status := pcxOK;
end;

var
  __GetS__: PStream;

function Get: Byte; far;
var
  B: Byte;
begin
  __GetS__^.Read( B, 1 );
  Get := B;
end;

procedure OldPCXPicture.ReadLine( var Buffer );
begin
  __GetS__ := @S;
  UnpackString( Get, Buffer, H.BytesPerLine );
end;

function OldPCXPicture.ErrorText: String;
begin
  case Status of
    pcxOK:
      ErrorText := 'No errors';
    pcxNoFile:
      ErrorText := 'Can''t open file';
    pcxInvalidType:
      ErrorText := 'Only 8 bit PCXs are supported';
  end;
end;

destructor OldPCXPicture.Done;
begin
  S.Done;
end;

end.


