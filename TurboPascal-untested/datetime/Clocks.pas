(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0033.PAS
  Description: Clocks
  Author: BRIAN GRAINGER
  Date: 01-27-94  11:55
*)

{
▒> Does anyone know how to make a clock (ie....working second to second)

You can use the clock from the Gadgets unit included with BP7.
}

type
  PClockView = ^TClockView;
  TClockView = object(TView)
    Refresh: Byte;
    LastTime: DateTime;
    TimeStr: string[13];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function FormatTimeStr(M, S: Word): String; virtual;
    procedure Update; virtual;
  end;

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;

constructor TClockView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;

procedure TClockView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, TimeStr, C);
  WriteLine(0, 0, Size.X, 1, B);
end;

procedure TClockView.Update;
var
  h,m,s,hund: word;
  AmPmStr : STRING;
  vTmpStr : STRING;
begin
  GetTime(h,m,s,hund);
  if Abs(s - LastTime.sec) >= Refresh then
  begin
    with LastTime do
      begin
        IF ((H >= 12) AND (H < 24)) THEN
          AmPmStr := ' p.m.'
        ELSE
          AmPmStr := ' a.m.';
        IF H > 12 THEN
          H := H - 12;
        IF H = 0 THEN
          H := 12;
      end;
    Str(H : 2, vTmpStr);
    TimeStr := vTmpStr + FormatTimeStr(m, s) + AmPmStr;
    DrawView;
  end;
end;

function TClockView.FormatTimeStr(M, S: Word): String;
begin
  FormatTimeStr := ':'+ LeadingZero(m) +
    ':' + LeadingZero(s);
end;


