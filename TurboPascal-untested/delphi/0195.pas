unit mjwstar;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, extctrls;

{ TMJWstar component - version 1.00

  Copyright 1996 (c) by Michael Wilcox
  All Rights Reserved.

  Email:    mwilcox@economat.demon.co.uk
            michael@economatics.co.uk

  Address:  68 Upper Wortley Road
            Rotherham
            South Yorkshire
            S61 2AD
            U.K.

  This component:
    - is Freeware, do not pay money for it!!!
    - is used at your own risk.
    - is open to amendments - please give credit.
    - can be published or supplied on CD-ROM (only if not amended)

  Other components/applications I have created and released:

    TMJWstar          - Panel with moving stars as a background.
                        (MJWSTAR.ZIP)
                        www.delphi32.com
                        Compuserve Delphi32 Forum.

    TMJWcrt           - Simulates a DOS CRT screen.
                        (MJWCRT.ZIP)
                        www.delphi32.com
                        Compuserve Delphi32 Forum.

    MWTerm            - Terminal Emulator, Application (DOS)
                        MWTERM.ZIP
                        www.picksys.com

  Future components, email me if you are interested:

    TMJWcom32         - Win '95 Serial Comms.
                        (SORRY - NOT RELEASED YET)

    TMJWemulator      - ADDS A2/DEBUG terminal emulator parser used with TMJWcrt.
                        (SORRY - NOT RELEASED YET)

    TMJWTextScroll    - Scrolling Credits.
                        (SORRY - NOT RELEASED YET)

    TMJWdigit         - Digital Numbers 0 to 9.
                        (SORRY - NOT RELEASED YET)

  Thanks to:
    - Matthias Laschat (STARFLD.PAS)
    - Marco Cantu, "Mastering Delphi"
    - Dave Jewell, PC PRO magazine.
    - David P J Hill, for use of compuserve.
    - Borland & TeamB (compuserve)

  Features:
    - Inherited Panel component with moving stars as a background.
    - Warps during design time.
    - Forward and Reverse Warps. (Reverse speed eg: -20)
    - Option of raised/lowered Bevels.

  Last Note:
    - Please Email me if you use this component, I would value your comments.
    - I feel it is wrong for developers to charge for components, they should be
      written to support Borland Delphi and its users - otherwise it could be a
      world of C++ and Visual Basic. It should be the completed application that
      is sold - if you must make money!!!

  Thank you... enjoy...

  Amendment History - contributions with thanks:
  	1.00		08/10/96		Michael Wilcox.
}

type
  TMJWStar = class(TCustomPanel)
  private
    { Private }
    FNumberOfStars : word;
    FZoom,
    FSpeed     : Integer;
    TStarData  : array[1..1000] of record
                    x, y, z : single;
                 end;
    FWrapStars : Boolean;
    awidth,
    bwidth     : Integer;
    FInterval  : integer;
    FWarp      : Boolean;
    Timer      : TTimer;
    FWarp10    : Boolean;
    procedure GenerateStars;
    procedure MoveStars(mx, my, mz : integer);
    procedure WrapStars;
    procedure SetSpeed(i : integer);
    procedure SetZoomFactor(i : integer);
    procedure SetNumberOfStars(i : word);
    procedure SetInterval(Value : integer);
    procedure SetWarp(Onn : Boolean);
    procedure TimeHit(Sender : TObject);
  protected
    { Protected }
  public
    { Public }
    constructor create(Aowner : Tcomponent); override;
    destructor destroy; override;
    procedure paintstars;
    procedure paint; override;
    procedure redraw; virtual;
  published
    { Published }
    property Width;
    property Height;
    property NumberOfStars : word read FNumberOfStars write SetNumberOfStars;
    property ZoomFactor : Integer read FZoom write SetZoomFactor;
    property Speed : Integer read FSpeed write SetSpeed;
    property WarpStart : boolean read FWarp write SetWarp;
    property WarpInterval : integer read FInterval write SetInterval;
    property Warp10 : Boolean read Fwarp10 write Fwarp10;

    property Align;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Ctl3D;
    property Locked;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

const

  a : longint = 200;
  grays        : array[0..15] of longint=($ffffff,$ffffff,$ffffff,$ffffff,
                                          $eeeeee,$dddddd,$cccccc,$bbbbbb,
                                          $aaaaaa,$999999,$888888,$777777,
                                          $555555,$333333,$111111,$000000);

procedure Register;

implementation


{Create Method}
constructor TMJWstar.Create(Aowner : Tcomponent);
begin
  inherited create(Aowner);
  width := 300;
  height := 200;
  FNumberOfStars := 200;
  FZoom := 100;
  FSpeed := 20;
  color := clblack;
  if screen.width > 2000 then awidth := screen.width*2 else awidth := 2000;
  bwidth := awidth div 2;
  GenerateStars;
  FInterval := 1;
  FWarp := false;
  FWarp10 := false;
end;

{Destroy Method}
destructor TMJWstar.Destroy;
begin
  inherited destroy;
end;

{Generate Star Data}
procedure TMJWstar.GenerateStars;
var i : integer;
begin
     for i:=1 to FNumberOfStars do
     with TStarData[i] do
     begin
         x:=integer(random(awidth))-1000;
         y:=integer(random(awidth))-bwidth;
         z:=integer(random(awidth));
    end;
end;

{Wrap Stars}
procedure TMJWstar.WrapStars;
var i : integer;
begin
    for i := 1 to FNumberOfStars do
    with TStarData[i] do
    begin
      while x < -bwidth do x := x + awidth;
      while x >  bwidth do x := x - awidth;
      while y < -bwidth do y := y + awidth;
      while y >  bwidth do y := y - awidth;
      while z <= 0      do z := z + awidth;
      while z >  awidth do z := z - awidth;
    end;
    FWrapStars := false;
end;

{Move Stars}
procedure TMJWstar.MoveStars;
var i : integer;
begin
     for i := 1 to FNumberOfStars do
     with TStarData[i] do
     begin
          x := x + mx;
          y := y + my;
          z := z + mz;
     end;
     FWrapStars := true;
end;

{Set Speed}
procedure TMJWstar.SetSpeed(i : integer);
begin
	FSpeed := i;
  redraw;
end;

{Set Zoom Factor}
procedure TMJWstar.SetZoomFactor(i : integer);
begin
	FZoom := i;
  redraw;
end;

{Set Number of Stars}
procedure TMJWstar.SetNumberOfStars(i : word);
begin
  If (i > 1000) then i := 1000;
  If (i < 0)    then i := 5;
	FNumberOfStars := i;
  GenerateStars;
  redraw;
end;

{Timer Interval}
procedure TMJWstar.SetInterval(Value : Integer);
begin
  if Value <> FInterval then
  begin
  Timer.Free;
  Timer := Nil;
  if FWarp and (Value > 0) then
    begin
    Timer := TTimer.Create(Self);
    Timer.Interval := Value;
    Timer.OnTimer := TimeHit;
    end;
  FInterval := Value;
  end;
end;

{Star timer to move stars}
procedure TMJWstar.SetWarp(Onn : boolean);
begin
  if Onn <> FWarp then
  begin
  FWarp := Onn;
  if not Onn then
    begin
    Timer.Free;
    Timer := Nil;
    end
  else if FInterval > 0 then
    begin
    Timer := TTimer.Create(Self);
    Timer.Interval := FInterval;
    Timer.OnTimer := TimeHit;
    end;
  end;
end;

{Paint Stars}
procedure TMJWstar.paintstars;
var
  i : integer;
  rx, ry : integer;
  xmid, ymid : integer;
  azoom : single;
  Rect: TRect;
  TopColor, BottomColor, clr: TColor;
begin
     if (csDesigning in ComponentState) and (Fwarp = false) then
     begin
       	canvas.brush.color := clblack;
        canvas.rectangle(0,0,width,height);
     end;

     if FWrapStars then WrapStars;
     azoom := FZoom/100;

     xmid := width div 2;
     ymid := height div 2;

     {Draw Background Stars}
	   for i := 1 to (FNumberOfStars div 2) do
     with TStarData[i] do
     begin
		      rx:=round(xmid+(a*x/300)* azoom);
          ry:=round(ymid+(a*y/500)* azoom);
          if (ry > (ClientRect.top+BevelWidth)+1) and
             (ry < (ClientRect.Bottom-BevelWidth)-1) and
             (rx > (ClientRect.Left+BevelWidth)+1) and
             (rx < (ClientRect.Right-BevelWidth)-1) then
    	    canvas.pixels[rx,ry] := clWhite;
  	 end;

     for i := (FNumberOfStars div 2)+1 to FNumberOfStars do
     with TStarData[i] do
     begin
          if z > 0  then
          begin
               if Fwarp10 = true then clr := grays[random(15)]
                else clr := color;
               {Remove Small Star}
               rx := round(xmid+(a*x/z)* azoom);
               ry := round(ymid+(a*y/z)* azoom);
               if (ry > (ClientRect.top+BevelWidth)+1) and
                  (ry < (ClientRect.Bottom-BevelWidth)-1) and
                  (rx > (ClientRect.Left+BevelWidth)+1) and
                  (rx < (ClientRect.Right-BevelWidth)-1) then
               canvas.pixels[rx,ry] := clr;
               if round(z*15/awidth) < 7 then
               begin
                    {Remove Large Star}
                  if (ry > (ClientRect.top+BevelWidth)+1) and
                     (ry < (ClientRect.Bottom-BevelWidth)-1) and
                     (rx > (ClientRect.Left+BevelWidth)+1) and
                     (rx < (ClientRect.Right-BevelWidth)-1) then
                  begin
                    canvas.pixels[rx,ry+1] := clr;
                    canvas.pixels[rx,ry-1] := clr;
                    canvas.pixels[rx+1,ry] := clr;
                    canvas.pixels[rx-1,ry] := clr;
                  end;
               end;
          end;

          x := x + 0;
          y := y + 0;
          z := z + (-FSpeed);
          FWrapStars:=true;

          if z > 0 then
          begin
               {Draw Small Star}
               rx := round(xmid+(a*x/z)* azoom);
               ry := round(ymid+(a*y/z)* azoom);
               if (ry > (ClientRect.top+BevelWidth)+1) and
                  (ry < (ClientRect.Bottom-BevelWidth)-1) and
                  (rx > (ClientRect.Left+BevelWidth)+1) and
                  (rx < (ClientRect.Right-BevelWidth)-1) then
               canvas.pixels[rx,ry] := grays[round(z*15/awidth)];
               if round(z*15/awidth) < 7 then
               begin
                    {Draw Large Star}
                  if (ry > (ClientRect.top+BevelWidth)+1) and
                     (ry < (ClientRect.Bottom-BevelWidth)-1) and
                     (rx > (ClientRect.Left+BevelWidth)+1) and
                     (rx < (ClientRect.Right-BevelWidth)-1) then
                  begin
                    canvas.pixels[rx,ry+1] := grays[round(z*15/awidth)];
                    canvas.pixels[rx,ry-1] := grays[round(z*15/awidth)];
                    canvas.pixels[rx+1,ry] := grays[round(z*15/awidth)];
                    canvas.pixels[rx-1,ry] := grays[round(z*15/awidth)];
                  end;
               end;
          end;
    end;
  {Display Bevel}
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    TopColor := clBtnHighlight;
    if BevelOuter = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if BevelOuter = bvLowered then BottomColor := clBtnHighlight;
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
end;

{paint}
procedure TMJWstar.paint;
begin
	canvas.brush.color := clblack;
  canvas.rectangle(0,0,width,height);
  paintstars;
end;

{Redraw}
procedure TMJWstar.redraw;
begin
  paint;
end;

{Respond to timer by calling Paint method}
procedure TMJWstar.TimeHit(Sender : TObject);
begin
	if FWarp then
  begin
  	paintstars;
  end else
  begin
	  Timer.Free;
    Timer := Nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('Mick', [TMJWstar]);
end;

end.
