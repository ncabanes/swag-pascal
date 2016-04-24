(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0134.PAS
  Description: Marquee Panel For Delphi
  Author: UDO JUERSS
  Date: 05-31-96  09:16
*)

{
  This component uses the VGA standard 8x16 font. No resources are used.

  properties description:

    property BackGround:     Background color of panel. Not visible if size is 1,
                             because pixeldensity is too high.

    property BevelOuter:     as usual.
    property BevelInner:     as usual.
    property BevelWidth:     as usual.
    property Characters:     How many Character are displayed in panel.
                             Increasing this slows down the outputspeed.
    property OffColor:       Color of Pixels not set in character.
    property OnColor:        Color of Pixels set in character.
    property OnComplete:     Fired if output of RunText completed.
    property Running:        Flag if horizontal scrolling is active.
    property RunText:        Outputstring.
    property ScrollBy:       Number of pixels per horizontal scroll.
    property ScrollInterval: Cycletime of horizontal scrolling.
    property Size:           Size of output. If set to 1 character size is 8x16
                             pixels. Increasing size decreases display contrast.

  Contact: Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]

  Previously published by me: Luffing switch      (March  8. 1996)
                              Scaleable LED light (March 10. 1996)

  If someone makes useful enhances or corrections to these components,
  please send me an update!

  March 11. 1996
}

unit
  Marquee;
{------------------------------------------------------------------------------}

interface

uses
  WinTypes, WinProcs, Messages, Classes, Graphics, Controls, ExtCtrls;
{------------------------------------------------------------------------------}

const
  Dual: array[0..7] of Byte = (1,2,4,8,16,32,64,128);
{------------------------------------------------------------------------------}

type
  TMarquee = class(TGraphicControl)
  private
    Timer: TTimer;

    FBackGround: TColor;
    FBevelOuter: TPanelBevel;
    FBevelInner: TPanelBevel;
    FBevelWidth: Byte;
    FBkGnd: TColor;
    FCharacters: Byte;
    FScrollInterval: Word;
    FOffColor: TColor;
    FOnColor: TColor;
    FOnComplete: TNotifyEvent;
    FRunning: Boolean;
    FRunText: string;
    FSize: Byte;
    FScrollBy: Byte;

    Border:Byte;
    Index: Byte;
    WorkString: string;
    PixelPos: Byte;
    CharOfs: Word;
    TextLen: Byte;
    XPos: Integer;
    YPos: Integer;
    procedure Draw;
    procedure DrawText(Shift:Boolean);
    procedure GetCharData(Character: Char);
    procedure PutVerticalPixels(Horizontal: Byte);
    procedure Setup;
    procedure ShiftString;
    procedure TimerShift(Sender: TObject);
  protected
    procedure DrawBevel(Rect: TRect);
    procedure SetBackGround(Value: TColor);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelWidth(Value: Byte);
    procedure SetCharacters(Value: Byte);
    procedure SetScrollInterval(Value: Word);
    procedure SetOffColor(Value: TColor);
    procedure SetOnColor(Value: TColor);
    procedure SetRunning(Value: Boolean);
    procedure SetRunText(Value: string);
    procedure SetSize(Value: Byte);
    procedure SetScrollBy(Value: Byte);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure Paint; override;
  published
    property BackGround: TColor read FBackGround write SetBackGround default clBlack;
    property BevelOuter: TPanelBevel read FBevelOuter write SetBevelOuter default bvRaised;
    property BevelInner: TPanelBevel read FBevelInner write SetBevelInner default bvLowered;
    property BevelWidth: Byte read FBevelWidth write SetBevelWidth default 2;
    property Characters: Byte read FCharacters write SetCharacters default 7;
    property ScrollInterval: Word read FScrollInterval write SetScrollInterval default 50;
    property OffColor: TColor read FOffColor write SetOffColor default clGray;
    property OnColor: TColor read FOnColor write SetOnColor default clLime;
    property OnComplete: TNotifyEvent read FOnComplete write FOnComplete;
    property Running: Boolean read FRunning write SetRunning default False;
    property RunText: string read FRunText write SetRunText;
    property ScrollBy: Byte read FScrollBy write SetScrollBy default 1;
    property Size: Byte read FSize write SetSize default 2;
  end;
{------------------------------------------------------------------------------}

procedure GetFontOfs(CharSet: Byte; var FntOfs: Word);
function SegC000: Word;
procedure Register;

implementation
{------------------------------------------------------------------------------}

var
  CharArray: array[0..15] of Byte;
  FontPtr: Pointer;
  FontOfs: Word;
{------------------------------------------------------------------------------}

procedure GetFontOfs(CharSet: Byte; var FntOfs: Word); assembler;
asm
           push  bp
           mov   ax,1130h
           mov   bh,CharSet
           int   10h
           mov   ax,bp
           pop   bp
           les   di,FntOfs
           stosw
end;
{------------------------------------------------------------------------------}

function SegC000: Word; external 'KERNEL' Index 195;
{------------------------------------------------------------------------------}

constructor TMarquee.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent:=AOwner as TWinControl;
  Canvas.Brush.Style:=bsSolid;
  Timer:=nil;
  FBackGround:=clBlack;
  FBevelOuter:=bvRaised;
  FBevelInner:=bvLowered;
  FBevelWidth:=2;
  FCharacters:=7;
  FScrollInterval:=50;
  FOffColor:=clGray;
  FOnColor:=clLime;
  FOnComplete:=nil;
  FRunning:=False;
  FRunText:='RunText ';
  FSize:=2;
  FScrollBy:=1;

  Border:=2;
  GetFontOfs(6,FontOfs);
  FontPtr:=Ptr(Ofs(SegC000),FontOfs);

  PixelPos:=0;
  TextLen:=Length(FRunText);
  Index:=0;
  WorkString:=FRunText;
  Setup;
  Draw;
end;
{------------------------------------------------------------------------------}

destructor TMarquee.Destroy;
begin
  if FRunning then SetRunning(False);
  inherited Destroy;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.Paint;
begin
  Draw;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.Clear;
var
  Temp: Byte;
begin
  Temp:=FOnColor;
  FOnColor:=FOffColor;
  DrawText(False);
  FOnColor:=Temp;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.Draw;
var
  R: TRect;
begin
  R:=GetClientRect;
  DrawBevel(R);
  Canvas.Pen.Color:=FBackGround;
  Canvas.Brush.Color:=FBackGround;
  InflateRect(R,-Border,-Border);
  Canvas.FillRect(R);
  DrawText(False);
end;
{------------------------------------------------------------------------------}

procedure TMarquee.DrawBevel(Rect: TRect);
var
  TopColor: TColor;
  BottomColor: TColor;

  procedure SetColors(Bevel: TPanelBevel);
  begin
    TopColor:=clBtnHighlight;
    if Bevel = bvLowered then TopColor:=clBtnShadow;
    BottomColor:=clBtnShadow;
    if Bevel = bvLowered then BottomColor:=clBtnHighlight;
  end;

begin
  if FBevelOuter <> bvNone then
  begin
    SetColors(BevelOuter);
    Frame3D(Canvas,Rect,TopColor,BottomColor,BevelWidth);
  end;

  if FBevelInner <> bvNone then
  begin
    SetColors(FBevelInner);
    Frame3D(Canvas,Rect,TopColor,BottomColor,FBevelWidth);
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.DrawText(Shift: Boolean);
var
  Pos: Byte;
  I: Byte;
  R: TRect;
begin
  R:=GetClientRect;
  XPos:=R.Left + Border;
  YPos:=R.Top + Border;
  GetCharData(WorkString[1]);
  for I:=PixelPos to 7 do PutVerticalPixels(I);

  for Pos:=2 to FCharacters do
  begin
    GetCharData(WorkString[Pos]);
    for I:=0 to 7 do PutVerticalPixels(I);
  end;

  GetCharData(WorkString[Succ(FCharacters)]);
  for I:=0 to PixelPos do PutVerticalPixels(I);

  if Shift then Inc(PixelPos,FScrollBy);
  if PixelPos > 7 then
  begin
    PixelPos:=0;
    ShiftString;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.GetCharData(Character: Char); assembler;
asm
           push  ds
           push  ds
           pop   es
           mov   di,offset CharArray
           xor   bh,bh
           mov   bl,Character
           shl   bx,4
           lds   si,FontPtr
           add   si,bx
           mov   cx,16

@MovsLoop: push  cx
           lodsb
           mov   ah,0
           mov   cx,8

@RolLoop:  rol   al,1
           adc   ah,0
           ror   ah,1
           loop  @RolLoop

           mov   al,ah
           stosb
           pop   cx
           loop  @MovsLoop

           pop   ds
end;
{------------------------------------------------------------------------------}

procedure TMarquee.PutVerticalPixels(Horizontal: Byte);
var
  Vertical: Byte;
begin
  for Vertical:=0 to 15 do
  begin
    if CharArray[Vertical] and Dual[Horizontal] > 0 then
      Canvas.Pixels[XPos,YPos + Vertical * FSize]:=FOnColor
      else Canvas.Pixels[XPos,YPos + Vertical * FSize]:=FOffColor;
  end;
  Inc(XPos,FSize);
end;
{------------------------------------------------------------------------------}

procedure TMarquee.TimerShift(Sender: TObject);
begin
  DrawText(True);
end;
{------------------------------------------------------------------------------}

procedure TMarquee.ShiftString;
begin
  Inc(Index);
  if FCharacters >= TextLen - Index then
  begin
    WorkString:=Copy(FRunText,Succ(Index),TextLen - Index);
    WorkString:=WorkString + Copy(RunText,1,Succ(FCharacters) - (TextLen - Index));
  end
  else WorkString:=Copy(FRunText,Succ(Index),Succ(FCharacters));
  if Index >= TextLen then
  begin
    Index:=0;
    if Assigned(FOnComplete) then FOnComplete(Self);
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.Setup;
begin
  Width:=FSize * 8 * FCharacters + 2 * Border + 1;
  Height:=FSize * 16 + 2 * Border;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetBackGround(Value: TColor);
begin
  if FBackGround <> Value then
  begin
    FBackGround:=Value;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetBevelOuter(Value: TPanelBevel);
begin
  if FBevelOuter <> Value then
  begin
    FBevelOuter:=Value;
    if FBevelOuter <> bvNone then Border:=FBevelWidth else Border:=0;
    if FBevelInner <> bvNone then Inc(Border,FBevelWidth);
    Setup;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetBevelInner(Value: TPanelBevel);
begin
  if FBevelInner <> Value then
  begin
    FBevelInner:=Value;
    if FBevelOuter <> bvNone then Border:=FBevelWidth else Border:=0;
    if FBevelInner <> bvNone then Inc(Border,FBevelWidth);
    Setup;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetBevelWidth(Value: Byte);
begin
  if FBevelWidth <> Value then
  begin
    FBevelWidth:=Value;
    if FBevelOuter <> bvNone then Border:=FBevelWidth else Border:=0;
    if FBevelInner <> bvNone then Inc(Border,FBevelWidth);
    Setup;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetCharacters(Value: Byte);
var
  I: Byte;
begin
  if Value < 1 then Value:=1 else if Value > 80 then Value:=80;
  if FCharacters <> Value then
  begin
    FCharacters:=Value;
    if TextLen < FCharacters then
    begin
      for I:=TextLen to FCharacters do FRunText:=FRunText + ' ';
      TextLen:=Byte(FRunText[0]);
    end;
    SetUp;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetScrollInterval(Value: Word);
begin
  if FScrollInterval <> Value then
  begin
    FScrollInterval:=Value;
    if FRunning and Assigned(Timer) then Timer.Interval:=FScrollInterval;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetSize(Value: Byte);
begin
  if Value < 1 then Value:=1 else if Value > 8 then Value:=8;
  if FSize <> Value then
  begin
    FSize:=Value;
    SetUp;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetScrollBy(Value: Byte);
begin
  if Value < 1 then Value:=1 else if Value > 8 then Value:=8;
  if FScrollBy <> Value then FScrollBy:=Value;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetOffColor(Value: TColor);
begin
  if FOffColor <> Value then
  begin
    FOffColor:=Value;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetOnColor(Value: TColor);
begin
  if FOnColor <> Value then
  begin
    FOnColor:=Value;
    Draw;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetRunning(Value: Boolean);
begin
  if FRunning <> Value then
  begin
    FRunning:=Value;
    if FRunning then
    begin
      Timer:=TTimer.Create(Self);
      Timer.Interval:=FScrollInterval;
      Timer.OnTimer:=TimerShift;
      Timer.Enabled:=True;
    end
    else if Assigned(Timer) then
    begin
      Timer.Free;
      Timer:=nil;
    end;
  end;
end;
{------------------------------------------------------------------------------}

procedure TMarquee.SetRunText(Value: string);
var
  I: Byte;
begin
  Index:=0;
  FRunText:=Value;
  TextLen:=Byte(FRunText[0]);
  if TextLen < FCharacters then for I:=TextLen to FCharacters do FRunText:=FRunText + ' ';
  TextLen:=Byte(FRunText[0]);
end;
{------------------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('Udo|s',[TMarquee]);
end;
{------------------------------------------------------------------------------}

initialization
end.


