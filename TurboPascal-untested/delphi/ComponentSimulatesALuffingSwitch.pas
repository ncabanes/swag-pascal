(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0139.PAS
  Description: Component simulates a Luffing Switch
  Author: UDO JUERSS
  Date: 05-31-96  09:17
*)

{
  Programm : SWITCH.PAS
  Sprache  : Delphi
  Zweck    : Schalter-Komponente
  Datum    : 15, 16. Feb. 1996
  Autor    : U.Jnr-

  This component simulates a luffing switch as used in many electic devices.
  No Bitmaps are used, so it's fully scaleable.

  Sorry for comments are in german.

  Contact: Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]

  Greetings from germany - enjoy...
}

unit
  Switch;

interface

uses
  WinTypes, WinProcs, Messages, Classes, Controls, Graphics;
{------------------------------------------------------------------------------}

type
  RectArray = array[0..3] of TPoint;               {Vektorarraytyp fnr Rechteck}
  TriArray = array[0..2] of TPoint;                 {Vektorarraytyp fnr Dreieck}

  TSwitch = class(TCustomControl)
  private
    TopShape: TriArray;                 {Dreieck Vektoren von Schalteroberseite}
    OnShape: RectArray;               {Rechteck Vektoren von Schalterfront "ON"}
    OffShape: RectArray;             {Rechteck Vektoren von Schalterfront "OFF"}
    SideShape: RectArray;                  {Rechteck Vektoren von Schalterseite}

    FOnChanged: TNotifyEvent;                        {Verbindung zur Aussenwelt}
    FOnChecked: TNotifyEvent;                        {Verbindung zur Aussenwelt}
    FOnUnChecked: TNotifyEvent;                      {Verbindung zur Aussenwelt}

    FCaptionOn: TCaption;                   {Beschriftung Schalterstellung "ON"}
    FCaptionOff: TCaption;                 {Beschriftung Schalterstellung "OFF"}
    FChecked: Boolean;                               {Flag von Schalterstellung}
    FCheckedLeft: Boolean;     {Flag ob "ON" links oder rechts dargestellt wird}
    FSlope: Byte;                            {Neigung (3D Effekt) des Schalters}
    FSideLength: Byte;          {Seitenabstand fnr hervorstehendes Schalterteil}
    FOnColor: TColor;                               {Farbe fnr Frontfl_che "ON"}
    FOffColor: TColor;                             {Farbe fnr Frontfl_che "OFF"}
    FTopColor: TColor;                             {Farbe fnr Schalteroberseite}
    FSideColor: TColor;                                 {Farbe fnr Seitenfl_che}
    ALeft: Integer;                        {Linke Anfangsposition des Schalters}
    ATop: Integer;                         {Obere Anfangsposition des Schalters}
    AHeight: Integer;                                       {Hwhe des Schalters}
    AWidth: Integer;                                      {Breite des Schalters}
    LabelLen: Integer;                                {Halbbreite des Schalters}
    LabelOfs: Integer;                       {Halbbreite fnr Spiegeldarstellung}
    Side: Integer;                                 {Tempor_r in Setup verwendet}

    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure CallNotifyEvent;
    procedure Setup;
    procedure Draw;
    procedure SetCaptionOn(Value: TCaption);
    procedure SetCaptionOff(Value: TCaption);
    procedure SetChecked(Value: Boolean);
    procedure SetCheckedLeft(Value: Boolean);
    procedure SetSlope(Value: Byte);
    procedure SetSideLength(Value: Byte);
    procedure SetOnColor(Value: TColor);
    procedure SetOffColor(Value: TColor);
    procedure SetTopColor(Value: TColor);
    procedure SetSideColor(Value: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  published
    property CaptionOn: TCaption read FCaptionOn write SetCaptionOn;
    property CaptionOff: TCaption read FCaptionOff write SetCaptionOff;
    property Checked: Boolean read FChecked write SetChecked default False;
    property CheckedLeft: Boolean read FCheckedLeft write SetCheckedLeft default True;
    property Slope: Byte read FSlope write SetSlope default 6;
    property SideLength: Byte read FSideLength write SetSideLength default 6;
    property OnColor: TColor read FOnColor write SetOnColor default clRed;
    property OffColor: TColor read FOffColor write SetOffColor default clMaroon;
    property TopColor: TColor read FTopColor write SetTopColor default clSilver;
    property SideColor: TColor read FSideColor write SetSideColor default clSilver;
    property Font;
    property TabStop;
    property TabOrder;
    property ShowHint;

    property OnClick;
    property OnMouseDown;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnChecked: TNotifyEvent read FOnChecked write FOnChecked;
    property OnUnChecked: TNotifyEvent read FOnUnChecked write FOnUnChecked;
  end;
{------------------------------------------------------------------------------}

procedure Register;

implementation
{------------------------------------------------------------------------------}

constructor TSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption:='';
  FCaptionOn:='EIN';
  FCaptionOff:='AUS';
  FSlope:=6;
  FSideLength:=6;
  FChecked:=False;
  FCheckedLeft:=True;
  FOnColor:=clRed;
  FOffColor:=clMaroon;
  FTopColor:=clSilver;
  FSideColor:=clSilver;
  FOnChecked:=nil;
  FOnUnChecked:=nil;
  SetBounds(Left,Top,83,18 + FSlope);
  Font.Name:='small fonts';
  Font.Size:=7;
  Font.Color:=clWhite;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.Paint;
begin
  Draw;            {Keine geerbte Methode aufrufen und sofort Schalter zeichnen}
end;
{------------------------------------------------------------------------------}

procedure TSwitch.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button,Shift,X,Y);
  if (Button = mbLeft) then
  begin
    SetFocus;
    if ((LabelLen > 0) and (X > LabelLen)) or
       ((LabelLen < 0) and (X < Abs(LabelLen))) then
    begin    {Nur wenn Mausklick innerhalb des hervorgehobenen Schalterteil ist}
      FChecked:=not FChecked;
      CallNotifyEvent;
      Invalidate;
    end;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.WMSetFocus(var Message: TWMSetFocus);
begin
  Invalidate;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.WMKillFocus(var Message: TWMKillFocus);
begin
  Invalidate;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Focused and ((Key = VK_Space) or (Key = VK_Return)) then
  begin
    FChecked:=not FChecked;
    CallNotifyEvent;
    Invalidate;
    Click;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.CallNotifyEvent;                       {Au-enwelt informieren}
begin
  if Assigned(FOnChanged) then FOnChanged(Self);
  if FChecked and Assigned(FOnChecked) then FOnChecked(Self) else
  if not FChecked and Assigned(FOnUnChecked) then FOnUnChecked(Self);
end;
{------------------------------------------------------------------------------}

procedure TSwitch.Draw;                                      {Schalter zeichnen}
var
  TW: Integer;
  TH: Integer;
begin
  Setup;                                  {Vektoren fnr Schalterteile berechnen}
  if Focused then Canvas.Rectangle(0,0,Width,AHeight + 1 + 2 * ATop);
  Canvas.Pen.Color:=clWhite;                   {Umrandung von Schalter zeichnen}
  Canvas.MoveTo(ALeft - 1,ATop + AHeight + 1);
  Canvas.LineTo(ALeft + AWidth,ATop + AHeight + 1);      {Untere Linie in weiss}
  Canvas.LineTo(ALeft + AWidth,ATop - 2);                {Rechte Linie in weiss}

  Canvas.Pen.Color:=clGray;
  Canvas.MoveTo(ALeft + AWidth,ATop - 1);
  Canvas.LineTo(ALeft - 1,ATop - 1);                 {Obere Linie in dunkelgrau}
  Canvas.LineTo(ALeft - 1,ATop + AHeight + 1);       {Linke Linie in dunkelgrau}

  Canvas.Pen.Color:=clBlack;                      {Polygonumrandung ist schwarz}
  Canvas.Brush.Style:=bsSolid;                      {Fnllfl_che ist geschlossen}
  Setup;
  Canvas.Brush.Color:=FTopColor;
  Canvas.Polygon(TopShape);                         {Top des Schalters zeichnen}
  Canvas.Brush.Color:=FSideColor;
  Canvas.Polygon(SideShape);                      {Seite des Schalters zeichnen}
  if FChecked then Canvas.Brush.Color:=FOnColor
  else Canvas.Brush.Color:=FOffColor;
  Canvas.Polygon(OnShape);                     {On Seite des Schalters zeichnen}
  Canvas.Brush.Color:=FOffColor;
  Canvas.Polygon(OffShape);                   {Off Seite des Schalters zeichnen}

  Canvas.Font:=Font;                                  {Gew_hlten Font nbergeben}
  Canvas.Brush.Style:=bsClear;                        {Transparente Textausgabe}

  if FChecked then Caption:=FCaptionOn else Caption:=FCaptionOff;

  if LabelLen > 0 then TW:=ALeft + ((Abs(LabelLen) - Canvas.TextWidth(Caption)) div 2)
  else TW:=LabelOfs + ((Abs(LabelLen) - Canvas.TextWidth(Caption)) div 2);
  TH:=ATop + ((AHeight - Canvas.TextHeight(Caption)) div 2);

  Canvas.TextOut(TW,TH,Caption);
end;
{------------------------------------------------------------------------------}

procedure TSwitch.Setup;                  {Vektoren fnr Schalterteile berechnen}
begin
  ALeft:=2;                {2 Pixel linker Abstand fnr Rahmen und Focusrechteck}
  ATop:=2;                 {2 Pixel oberer Abstand fnr Rahmen und Focusrechteck}
  AHeight:=Height - FSlope - 2 * ATop;   {Schalterhwhe = Height - Ofs - Neigung}
  AWidth:=Width - 2 * ALeft;                  {Schalterbreite = Width - 2 * Ofs}
  LabelLen:=AWidth div 2;
  LabelOfs:=LabelLen + ALeft;
  Side:=FSideLength;
  if (not FChecked and FCheckedLeft) or (not FCheckedLeft and FChecked) then
  begin
    LabelLen:=-LabelLen;
    Side:=-FSideLength;
  end;
  TopShape[0].X:=LabelOfs;          {Vektoren von obere Dreieckfl_che berechnen}
  TopShape[0].Y:=ATop;
  TopShape[1].X:=LabelOfs + LabelLen - Side;
  TopShape[1].Y:=ATop + FSlope;
  TopShape[2].X:=LabelOfs + LabelLen;
  TopShape[2].Y:=ATop;

  OnShape[0].X:=LabelOfs - LabelLen;   {Vektoren der "EIN" Frontseite berechnen}
  OnShape[0].Y:=ATop;
  OnShape[1]:=TopShape[0];
  OnShape[2]:=OffShape[3];
  OnShape[3].X:=OnShape[0].X;
  OnShape[3].Y:=ATop + AHeight;

  OffShape[0]:=TopShape[0];            {Vektoren der "AUS" Frontseite berechnen}
  OffShape[1]:=TopShape[1];
  OffShape[2].X:=OffShape[1].X;
  OffShape[2].Y:=OffShape[1].Y + AHeight;
  OffShape[3].X:=OffShape[0].X;
  OffShape[3].Y:=ATop + AHeight;

  SideShape[0]:=OffShape[1];               {Vektoren der Seitenfl_che berechnen}
  SideShape[1]:=TopShape[2];
  SideShape[2].X:=SideShape[1].X;
  SideShape[2].Y:=ATop + AHeight;
  SideShape[3]:=OffShape[2];
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetCaptionOn(Value: TCaption);   {Beschriftung "ON" nbergeben}
begin
  if FCaptionOn <> Value then
  begin
    FCaptionOn:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetCaptionOff(Value: TCaption); {Beschriftung "OFF" nbergeben}
begin
  if FCaptionOff <> Value then
  begin
    FCaptionOff:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetChecked(Value: Boolean);
begin
  if FChecked <> Value then
  begin
    FChecked:=Value;
    CallNotifyEvent;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetCheckedLeft(Value: Boolean);
begin
  if FCheckedLeft <> Value then
  begin
    FCheckedLeft:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetSlope(Value: Byte);
begin
  if FSlope <> Value then
  begin
    FSlope:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetSideLength(Value: Byte);
begin
  if (FSideLength <> Value) and (Value < Width - 4) then
  begin
    FSideLength:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetOnColor(Value: TColor);
begin
  if FOnColor <> Value then
  begin
    FOnColor:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetOffColor(Value: TColor);
begin
  if FOffColor <> Value then
  begin
    FOffColor:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetTopColor(Value: TColor);
begin
  if FTopColor <> Value then
  begin
    FTopColor:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure TSwitch.SetSideColor(Value: TColor);
begin
  if FSideColor <> Value then
  begin
    FSideColor:=Value;
    Invalidate;
  end;
end;
{------------------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('Udo|s',[TSwitch]);
end;
{------------------------------------------------------------------------------}

initialization
end.


