{
Hello!

I'm from Hungary, and I love the SWAG!

It's a very useful site, and I use it since 2 years.
I send to You a Delphi 2.0 component:
 - TLCDControl (it looks like WinNT 4.0 Task Manager's LCD)
      resource file included (XX3402)

This component was made for Delphi 2.0, but it is also working on Delphi 1.0
(I think).
I send it to You, because I don't know any other addresses about SWAG.
I hope, this component will be useful for somebody.

Kind regards
        Matthew Csulik
        matthew-c@usa.net

P.S.: To extract the resource file, use WinZip95 (the 32bit version)!

-----------------------------------------------------------------------
-                                                                     -
-   LCDControl.pas                                                    -
-   **************                                                    -
-   This component is completely FREE.                                -
-                                                                     -
-----------------------------------------------------------------------

unit LCDControl;

{ written by Matthew }
{ matthew-c@usa.net  }

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
   TNumberType = (ntNone, ntCharK, ntPercent);

   TLCDControl = class(TGraphicControl)
   private
      NumBmp: array[0..9] of TBitmap;
      CharKBmp: TBitmap;
      PercentBmp: TBitmap;
      OnBmp: TBitmap;
      OffBmp: TBitmap;
      FNumber: integer;
      FNumberType: TNumberType;
      FNumberMax: integer;
      procedure SetNumber(Value: integer);
      procedure SetNumberType(Value: TNumberType);
      procedure SetNumberMax(Value: integer);
   protected
      procedure Paint; override;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure WriteLCDNum(Num: integer; X,Y: integer; ACanvas: TCanvas);
      procedure WriteNumber(Num: integer; NumType: TNumberType; X,Y:
integer; ACanvas: TCanvas);
      function GetNumberLength(Num: integer; NumType: TNumberType): integer;
      procedure DisplayTicks(Rect: TRect; Num: integer; ACanvas: TCanvas);
      procedure UpdateLCD(UpdateCanvas: TCanvas);
   published
      property Number: integer read FNumber write SetNumber;
      property NumberType: TNumberType read FNumberType write SetNumberType;
      property NumberMax: integer read FNumberMax write SetNumberMax;
   end;

procedure Register;

implementation

{$R LCD.RES}

constructor TLCDControl.Create(AOwner: TComponent);
var
   i: integer;
begin
   inherited Create(AOwner);
   for i:= 0 to 9 do
   begin
      NumBmp[i]:= TBitmap.Create;
      NumBmp[i].LoadFromResourceID(HInstance, i);
   end;
   CharKBmp:= TBitmap.Create;
   CharKBmp.LoadFromResourceName(HInstance, 'CHARK');
   PercentBmp:= TBitmap.Create;
   PercentBmp.LoadFromResourceName(HInstance, 'PERCENT');
   OnBmp:= TBitmap.Create;
   OnBmp.LoadFromResourceName(HInstance, 'ON');
   OffBmp:= TBitmap.Create;
   OffBmp.LoadFromResourceName(HInstance, 'OFF');
   FNumber:= 0;
   FNumberMax:= 100;
   FNumberType:= ntNone;
   Width:= 100;
   Height:= 120;
end;

procedure TLCDControl.Paint;
begin
   with inherited Canvas do
   begin
      Brush.Color:= clBlack;
      FillRect(Self.ClientRect);
      Pen.Color:= clbtnShadow;
      Polyline([Point(Width-1,0),Point(0,0),Point(0,Height-1)]);
      Pen.Color:= clbtnHighlight;
      Polyline([Point(Width-1,1),Point(Width-1,Height-1),Point(1,Height-1)]);
   end;
   UpdateLCD(Canvas);
end;

destructor TLCDControl.Destroy;
var
   i: integer;
begin
   for i:= 0 to 9 do
   begin
      NumBmp[i].Free;
   end;
   CharKBmp.Free;
   PercentBmp.Free;
   OnBmp.Free;
   OffBmp.Free;
   inherited Destroy;
end;

procedure TLCDControl.SetNumber(Value: integer);
begin
   if (FNumber <> Value) and (Value <= NumberMax) then
   begin
      FNumber:= Value;
      UpdateLCD(Canvas);
   end;
end;

procedure TLCDControl.SetNumberMax(Value: integer);
begin
   if (Value > 0) and (Value >= Number) then
   begin
      FNumberMax:= Value;
      Invalidate;
   end;
end;

procedure TLCDControl.SetNumberType(Value: TNumberType);
begin
   if FNumberType <> Value then
   begin
      FNumberType:= Value;
      UpdateLCD(Canvas);
   end;
end;

procedure TLCDControl.WriteLCDNum(Num: integer; X,Y: integer; ACanvas: TCanvas);
begin
   with ACanvas do
   begin
      Brush.Color:= clBlack;
      Draw(X,Y,NumBmp[Num]);
   end;
end;

procedure TLCDControl.WriteNumber(Num: integer; NumType: TNumberType; X,Y:
integer; ACanvas: TCanvas);
var
   NumLength: integer;
   NumStr: string;
   CNum: integer;
   CX: integer;
   i: integer;
begin
   CX:= X;
   NumStr:= IntToStr(Num);
   NumLength:= Length(NumStr);
   for i:= 1 to NumLength do
   begin
      CNum:= StrToInt(NumStr[i]);
      WriteLCDNum(CNum, CX, Y, ACanvas);
      Inc(CX, 8);
   end;
   if NumType <> ntNone then
   begin
      with ACanvas do
      begin
         Brush.Color:= clBlack;
         case NumType of
            ntCharK:
            begin
               Draw(CX,Y,CharKBmp);
            end;
            ntPercent:
            begin
               Draw(CX,Y,PercentBmp);
            end;
         end;
      end;
   end;
end;

function TLCDControl.GetNumberLength(Num: integer; NumType: TNumberType):
integer;
var
   NumLength: integer;
   NumStr: string;
begin
   Result:= 0;
   NumStr:= IntToStr(Num);
   NumLength:= Length(NumStr);
   case NumType of
      ntNone:
         Result:= NumLength * 8;
      ntCharK:
         Result:= (NumLength + 1) * 8;
      ntPercent:
         Result:= (NumLength + 1) * 8;
   end;
end;


procedure TLCDControl.DisplayTicks(Rect: TRect; Num: integer; ACanvas: TCanvas);
var
   TicksH: integer;
   Ticks: integer;
   TicksOn: integer;
   TicksOff: integer;
   i: integer;
   Center: integer;
   SY: integer;
begin
   SY:= Rect.Top;
   TicksH:= Rect.Bottom-Rect.Top;
   Center:= (Rect.Right-Rect.Left) div 2;
   Ticks:= TicksH div 3;
   TicksOn:= (Ticks * Num) div NumberMax;
   TicksOff:= Ticks-TicksOn;
   with ACanvas do
   begin
      Brush.Color:= clBlack;
      for i:= 1 to TicksOff do
      begin
         Draw(Center-17,SY,OffBmp);
         Draw(Center+1,SY,OffBmp);
         Inc(SY,3);
      end;
      for i:= 1 to TicksOn do
      begin
         Draw(Center-17,SY,OnBmp);
         Draw(Center+1,SY,OnBmp);
         Inc(SY,3);
      end;
   end;
end;

procedure TLCDControl.UpdateLCD(UpdateCanvas: TCanvas);
var
   CX: integer;
begin
   DisplayTicks(Rect(2,2,Self.Width-2,Self.Height-20),Number,UpdateCanvas);
   CX:= (Self.Width div 2)-(GetNumberLength(Number,NumberType) div 2);
   UpdateCanvas.Brush.Color:= clBlack;
   UpdateCanvas.FillRect(Rect(2,Self.Height-15,Self.Width-2,Self.Height-2));
   WriteNumber(Number,NumberType,CX,Self.Height-15,UpdateCanvas);
end;


procedure Register;
begin
   RegisterComponents('Matthew', [TLCDControl]);
end;

end.

{ the following contains addition files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000656-230497--72--85-06793------LCDRES.ZIP--1-OF--1
I2g1--E++U+6+BNUZm7zSdQJaU+++Bk-+++C++++H2B2EqxiR57jP0tYMr7XM4-UI+1WzzwV
4-poA16ka61ZaFV045kMb-ZQUBWTkEz60k9GDZ-p+U7w91+x4Y+g+QKA1--V-IM458+-X-UO
4W+I0682UAG-+kR+BcAFm53U0UH-PjrDM6k2nDz1kKRnVC3+BhSe-OgK9C-O+4Mn94-M+07U
sY+aL-kc+FRT-J41P+t6+cUMu0vCd8E+F7XW05Mt5-EXVkY+I2g1--E++U+6+4dUZm9FyTbH
5U2++Bk7+++5++++H2B29b7ZQwqIEKf1A--3TtEoHZEcDc6KLKHVGkGHIUWodTEkKTcECM1c
oeTknNkzYdd4RYmx8R8AjwMS0Tko4UE+Vidvfu4ReQfB8rnUU2zI5Bzk3SP9wabpgrN53REX
hM-DJtWmlXpc4Vz27QKVunftcrg2mUJllyUVBJdc1EjPUeAYb9FZGZh4TSLT-TsOfxVn-wT2
v8EHQCz239LQUvLyrPcB+GTeCP0zgyOMs0sdRQBRzUBrCv0MvMKSXgo2Iw5CpttKp09NKFD3
4hyRjx4My7iGRH4nGgPActIqx7+VGav699aMSNaISJXbSQmff5cXp1vGxuUr5f8fwqqjG-nL
SNqubmDBMmumjnT4n7gQunn8lQnP5Djt1qNYJKSt6yslLk-EGk20AUgI++6+0+1KM7QWTreL
3Nc+++1Q+E++1U+++++++++++0++hc2+++++H2B2EqxiR57jP0tYMr7EGk20AUgI++6+0+-e
M7QWoTbtols-++1Q0E++-k+++++++++++0++hc54++++H2B29b7ZQp-9-EM++++++U+0+52+
+++7+U++++++
***** END OF BLOCK 1 *****

