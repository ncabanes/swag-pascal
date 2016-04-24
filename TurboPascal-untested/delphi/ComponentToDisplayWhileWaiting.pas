(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0190.PAS
  Description: Component to display while waiting
  Author: MARTIJN TONIES
  Date: 11-29-96  08:17
*)

{
After I got the new Swag-snippets and saw how to make components for
Delphi, I just made this one for fun.

You all still remember Knight Rider with his car, KITT... Well, at the
front the car had a scanner... I made it as a component...

All properties are as obvious as can be (I think) so that shouldn't be a
problem. Just install it as normal (Don't forget to make a bitmap for
it!)

Remember, it's just for fun. Use it when scanning something or waiting
for something...

Author: Martijn Tonies
Date    : 10-28-1996

E-mail: M.Tonies@hsbos.nl

{---8<------------------------------------------------------------------------}

unit UKITScan;

interface

uses
	SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
	Forms, Dialogs, ExtCtrls;

const
	MaxLeds = 100;

type
	TScanColor = (scBlue,scGreen,scRed,scYellow);
	TScanMode  = (smLeftToRight,smRightToLeft,smBoth);

	TKITScanner = class(TGraphicControl)
	private
		FBevelInner:    TPanelBevel;
		FBevelOuter:    TPanelBevel;
		FBevelWidth:    Byte;
		FHowManyLeds: Byte;
		FOutColor:      TColor;
		FOnColor:       TColor;
		FScanColor:     TScanColor;
		FScanSpeed:     Integer;
		FScanning:      Boolean;
		FScanMode:      TScanMode;
		FLedsColors:    array [1..MaxLeds] of TScanColor;

		LedPos:             Byte;
		LedWay:             Boolean;
		Border:             Byte;
		LedH,LedW:      Integer;
		LedX:               array [1..MaxLeds] of Integer;
		ScanTimer:      TTimer;
		procedure DoScan(Sender: TObject);
		procedure Draw;
		procedure DrawBevel(Rect: TRect);
		procedure DrawLeds;
		procedure SetBevelInner(Value: TPanelBevel);
		procedure SetBevelOuter(Value: TPanelBevel);
		procedure SetBevelWidth(Value: Byte);
		procedure SetHowManyLeds(Value: Byte);
		procedure SetScanColor(Value: TScanColor);
		procedure SetScanMode(Value: TScanMode);
		procedure SetScanning(Value: Boolean);
		procedure SetScanSpeed(Value: Integer);
		procedure UpdateBorder;
		procedure UpdatePos;
		{ Private declarations }
	protected

		{ Protected declarations }
	public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure Paint; override;
		{ Public declarations }
	published
		property Align;
		property BevelInner: TPanelBevel read FBevelInner write SetBevelInner default bvNone;
		property BevelOuter: TPanelBevel read FBevelOuter write SetBevelOuter default bvRaised;
		property BevelWidth: Byte read FBevelWidth write SetBevelWidth default 1;
		property Color;
		property Cursor;
		property Enabled;
		property HowManyLeds: Byte read FHowManyLeds write SetHowManyLeds default 7;
		property ScanColor: TScanColor read FScanColor write SetScanColor default scRed;
		property ScanMode: TScanMode read FScanMode write SetScanMode default smBoth;
		property Scanning: Boolean read FScanning write SetScanning default False;
		property ScanSpeed: Integer read FScanSpeed write SetScanSpeed default 100;
		property ShowHint;
		property Visible;
		{ Published declarations }
	end;

procedure Register;

implementation
{==============================================================================}
{Private functions and procedures}
procedure TKITScanner.Draw;
var R: TRect;
begin
	R:=GetClientRect;
	UpdateBorder;
	Drawbevel(R);

	InflateRect(R,-Border,-Border);
	Canvas.Brush.Style:=bsSolid;
	Canvas.Brush.Color:=Color;
	Canvas.FillRect(R);

	DrawLeds;
end;
{------------------}
procedure TKITScanner.DrawBevel(Rect: TRect);
var
	TopColor: TColor;
	BottomColor: TColor;

	procedure SetColors(Bevel: TPanelBevel);
	begin
		if Bevel=bvLowered
		then TopColor:=clBtnShadow
		else TopColor:=clBtnHighlight;
		if Bevel=bvLowered
		then BottomColor:=clBtnHighlight
		else BottomColor:=clBtnShadow;
	end;

begin
	if FBevelOuter<>bvNone
	then begin
				 SetColors(FBevelOuter);
				 Frame3D(Canvas,Rect,TopColor,BottomColor,FBevelWidth);
			 end;
	if FBevelInner<>bvNone
	then begin
				 SetColors(FBevelInner);
				 Frame3D(Canvas,Rect,TopColor,BottomColor,FBevelWidth);
			 end;
end;
{------------------}
procedure TKITScanner.SetBevelInner(Value: TPanelBevel);
begin
	if Value<>FBevelInner
	then begin
				 FBevelInner:=Value;
				 Draw;
			 end;
end;
procedure TKITScanner.SetBevelOuter(Value: TPanelBevel);
begin
	if Value<>FBevelOuter
	then begin
				 FBevelOuter:=Value;
				 Draw;
			 end;
end;
procedure TKITScanner.SetBevelWidth(Value: Byte);
begin
	if Value<>FBevelWidth
	then begin
				 FBevelWidth:=Value;
				 Draw;
			 end;
end;
procedure TKITScanner.UpdateBorder;
begin
	Border:=0;
	if FBevelInner<>bvNone
	then Border:=FBevelWidth;
	if FBevelOuter<>bvNone
	then Inc(Border,FBevelWidth);
end;
{------------------}
procedure TKITScanner.SetHowManyLeds(Value: Byte);
begin
	if Value=0
	then Value:=1;
	if Value>MaxLeds
	then Value:=MaxLeds;
	if FHowManyLeds<>Value
	then begin
				 FHowManyLeds:=Value;
				 Draw;
			 end;
end;
{------------------}
procedure TKITScanner.SetScanMode(Value: TScanMode);
begin
	if Value<>FScanMode
	then FScanMode:=Value;
end;
{------------------}
procedure TKITScanner.SetScanSpeed(Value: Integer);
begin
	if Value<>FScanSpeed
	then FScanSpeed:=Value;
	if FScanning and Assigned(ScanTimer)
	then ScanTimer.Interval:=FScanSpeed;
end;
{------------------}
procedure TKITScanner.SetScanColor(Value: TScanColor);
begin
	if Value<>FScanColor
	then begin
				 FScanColor:=Value;
				 Draw;
			 end;
end;
{------------------}
procedure TKITScanner.SetScanning(Value: Boolean);
begin
	if Value<>FScanning
	then begin
				 FScanning:=Value;
				 if FScanning
				 then begin
								ScanTimer:=TTimer.Create(Self);
								ScanTimer.Interval:=FScanSpeed;
								ScanTimer.OnTimer:=DoScan;
								ScanTimer.Enabled:=True;
							end
				 else if Assigned(ScanTimer)
							then begin
										 ScanTimer.Free;
										 ScanTimer:=nil;
									 end;
			 end;
end;
{------------------}
procedure TKITScanner.DrawLeds;
var n:Integer;
begin
	LedH:=Height-Border-Border-2;
	if LedH<1
	then begin
				 Height:=3+Border+Border;
				 Draw;
			 end;
	LedW:=(Width-Border-Border-1-FHowManyLeds) div FHowManyLeds;
	if LedW<1
	then begin
				 Width:=Border+Border+1+FHowManyleds*(2);
				 Draw;
			 end;
	if (Width<>(Border+Border+1+FHowManyLeds*(1+LedW))) and
	((Align=alLeft) or (Align=alRight) or (Align=alNone))
	then begin
				 Width:=Border+Border+1+FHowManyLeds*(1+LedW);
				 Draw;
			 end;
	case FScanColor of
		scBlue      : begin
									FOutColor:=clNavy;
									FOnColor:=clBlue;
								end;
		scGreen     : begin
									FOnColor:=clLime;
									FOutColor:=clGreen;
								end;
		scRed       : begin
									FOutColor:=clMaroon;
									FOnColor:=clRed;
								end;
		scYellow    : begin
									FOutColor:=clOlive;
									FOnColor:=clYellow;
								end;
	end;

	Canvas.Brush.Color:=FOutColor;
	Ledx[1]:=Border+1;
	n:=2;
	while n<=FHowManyLeds
	do begin
			 Ledx[n]:=Ledx[n-1]+1+LedW;
			 Inc(n);
		 end;
	for n:=1 to FHowManyLeds
	do Canvas.FillRect(Rect(Ledx[n],Border+1,Ledx[n]+LedW,Height-Border-1));
end;
{------------------}
procedure TKITScanner.UpdatePos;
begin
	case FScanMode of
		smBoth              : if LedWay
										then if LedPos>FHowManyLeds
												 then LedWay:=not LedWay
												 else Inc(LedPos,1)
										else if LedPos<1
												 then LedWay:=not LedWay
												 else Dec(LedPos,1);
		smLeftToRight : begin
											LedWay:=True;
											if LedPos>FHowManyLeds
											then LedPos:=0
											else Inc(LedPos,1);
										end;
		smRightToLeft : begin
											LedWay:=False;
											if LedPos<1
											then LedPos:=FHowManyLeds+1
											else Dec(LedPos,1);
										end;
	end;
end;

procedure TKITScanner.DoScan;
var n: Byte;
begin
	Canvas.Brush.Color:=FOutColor;
	for n:=1 to FHowManyLeds
	do Canvas.FillRect(Rect(Ledx[n],Border+1,Ledx[n]+LedW,Height-Border-1));
	UpdatePos;
	Canvas.Brush.Color:=FOnColor;
	if (LedPos>=1) and (LedPos<=FHowManyLeds)
	then Canvas.FillRect(Rect(Ledx[LedPos],Border+1,Ledx[LedPos]+LedW,Height-Border-1));
end;
{==============================================================================}
{Protected functions and procedures}


{==============================================================================}
{Public functions and procedures}
constructor TKITScanner.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);

	FBevelInner:=bvNone;
	FBevelOuter:=bvRaised;
	FBevelWidth:=1;
	FHowManyLeds:=7;
	FScanColor:=scRed;
	FScanSpeed:=100;
	FScanMode:=smBoth;

	LedPos:=1;
	LedWay:=True;

	Width:=82;
	Height:=12;
end;

destructor TKITScanner.Destroy;
begin
	if FScanning
	then SetScanning(False);
	inherited Destroy;
end;

procedure TKITScanner.Paint;
begin
	Draw;
end;
{==============================================================================}
procedure Register;
begin
	RegisterComponents('Samples', [TKITScanner]);
end;

end.

