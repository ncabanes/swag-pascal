(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0335.PAS
  Description: Shadowed Label Component
  Author: ENDRE I. SIMAY
  Date: 08-30-97  10:09
*)

unit ShdLabel;
(********************************************************************
  TShadowedLabel Component For Delphi.

  It Is A "Special" Label-Component Developed For
  Allow To Shadow A Single Lined Caption Text
  Of A Label.
  For The Correct Draw of Text The Properties Transparent
  And WordWrap Are Set False And Hidden.

  Author:  Endre I. Simay;
           Budapest, HUNGARY; 1997.

  Freeware: Feel Free To Use And Improve, But Mention The Source

  This Source Is Compatible With Both DELPHI 1.0 & DELPHI 3.0
*********************************************************************)
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus;
type
  TShadowType=(shdULeft,shdDLeft,shdURight,shdDRight);
type
  TShadowedLabel = class(TCustomLabel)
  private
    { Private declarations }
    FShadColor:TColor;
    FShadSolid:Boolean;
    FShadLeft,
    FShadDown:Word;
    TxtH,TxtW:Word;
    FShadowType:TShadowType;
  protected
    { Protected declarations }
    Function GetShadLeft:Word;
    procedure SetShadLeft(Sl:Word);
    Function GetShadDown:Word;
    procedure SetShadDown(Sd:Word);
    Function GetShadColor:TColor;
    procedure SetShadColor(Sc:TColor);
    procedure SetShadSolid(B:Boolean);
    procedure SetShadowType(St:TShadowType);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
  published
    { Published declarations }
    Function TxtHeight:Word;
    Function TxtWidth:Word;
    property ShadowType:TShadowType read FShadowType write SetShadowType;
    property SolidShadow:Boolean read FShadSolid write SetShadSolid;
    property ShadowColor:TColor read GetShadColor Write SetShadColor;
    property ShadowDown:Word read GetShadDown Write SetShadDown;
    property ShadowLeft:Word read GetShadLeft Write SetShadLeft;
    property Caption;
    property Align;
    property Alignment;
    property AutoSize;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
 end;

procedure Register;

implementation

Function WMax(A,B:Word):Word;
 begin
  if a>=b then WMax:=a else WMax:=b;
 end;


constructor TShadowedLabel.Create(AOwner: TComponent);
 begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  AutoSize:=True;
  FShadSolid:=True;
  FShadColor:=clWhite;
  FShadowType:=shdDLeft;
  FShadLeft:=2;
  FShadDown:=2;
  Transparent:=False;
  WordWrap:=False;
  Alignment:=taLeftJustify;
  ParentFont:=False;
  With Font do
   begin
    Color:=clBlack;
    Name:='Arial';
    Pitch:=fpDefault;
    Size:=10;
    Style:=[];
   end;
 end;

destructor TShadowedLabel.Destroy;
 begin
  inherited Destroy;
 end;

procedure TShadowedLabel.Paint;
 const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
 var
  LabRect1,LabRect2:TRect;
  Flags:Word;
  Text: array[0..255] of Char;
  FC:TColor;
  TxtPt:TPoint;
  I:Integer;
 begin
  inherited Paint;
  GetTextBuf(Text, SizeOf(Text));
  StrPCopy(Text, Caption);
  TxtH:=Canvas.TextHeight(Caption);
  TxtW:=Canvas.TextWidth(Caption);
  If ShowAccelChar and (Pos('&',Caption)<>0)
   then TxtW:=TxtW-Canvas.TextWidth('&');
  TxtPt.y:=ClientRect.Top;
  Flags:=Alignments[Alignment];
  case Flags of
   DT_LEFT:TxtPt.x:=ClientRect.Left+FShadLeft-1;
   DT_RIGHT:TxtPt.x:=ClientRect.Right-TxtW-1;
   DT_CENTER:TxtPt.x:=ClientRect.Left+(ClientRect.Right-TxtW) div 2+2;
  end;
  Flags:=(DT_EXPANDTABS or DT_WORDBREAK)or Alignments[Alignment];
  if not ShowAccelChar then Flags := Flags or DT_NOPREFIX;

 With LabRect1 do
   begin
     case FShadowType of
      shdULeft:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH;
       end; {Uleft}
      shdDLeft:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end;    {Dleft}
      shdDRight:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end; {DRight}
      shdURight:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH;
       end; {URight}
     end;{Case in Labrect1}
   end; {With Labrect1}

 With LabRect2 do
   begin
     case FShadowType of
      shdULeft:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end;{Uleft}
      shdDLeft:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH;
       end; {Dleft}
      shdDRight:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH;
       end; {DRight}
      shdURight:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end; {URight}
     end;  {Case in Labrect2}
   end;   {With Labrect2}

 if AutoSize then
  begin
   case Align of
    alTop, alBottom:
     if ClientHeight<>TxtH+FShadDown then ClientHeight:=TxtH+FShadDown;
    alLeft, alRight:
     if ClientWidth<>TxtW+FShadLeft then ClientWidth:=TxtW+FShadLeft;
    alNone:
     begin
      if ClientHeight<>TxtH+FShadDown then ClientHeight:=TxtH+FShadDown;
      if ClientWidth<>TxtW+FShadLeft then ClientWidth:=TxtW+FShadLeft;
     end;
   end;
  end;

 with Canvas do
  begin
    if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;
    Brush.Style := bsClear;
  end;
  Fc:=Canvas.Font.Color ;

  Canvas.Font.Color :=FShadColor;
  if not Enabled then Canvas.Font.Color := clWhite;
{  if not FShadSolid then}
   DrawText(Canvas.Handle, Text, StrLen(Text), LabRect1, Flags);
  if FShadSolid then
  begin
  for I:=0 to WMax(FShadLeft,FShadDown) do
   begin
    case FShadowType of
     shdULeft:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-FShadLeft+I;
         LabRect1.Right:=TxtPt.x+TxtW-FShadLeft+I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+I;
         LabRect1.Bottom:=TxtPt.y+TxtH+I;
        end;
      end; {ULeft}
     shdDLeft:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-FShadLeft+I;
         LabRect1.Right:=TxtPt.x+TxtW-FShadLeft+I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+FShadDown-I;
         LabRect1.Bottom:=TxtPt.y+TxtH+FShadDown-I;
        end;
      end; {DLeft}
     shdDRight:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-I;
         LabRect1.Right:=TxtPt.x+TxtW-I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+FShadDown-I;
         LabRect1.Bottom:=TxtPt.y+TxtH+FShadDown-I;
        end;
      end; {DRight}
     shdURight:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-I;
         LabRect1.Right:=TxtPt.x+TxtW-I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+I;
         LabRect1.Bottom:=TxtPt.y+TxtH+I;
        end;
      end; {URight}
     end; {Case}
    DrawText(Canvas.Handle, Text, StrLen(Text), LabRect1, Flags);
   end;  {for}
  end; {if FShadSolid}

  Canvas.Font.Color :=Fc;
  if not Enabled then Canvas.Font.Color := clGray;
  DrawText(Canvas.Handle, Text, StrLen(Text), LabRect2, Flags);
  Canvas.Font.Color :=Fc;
 end;

function TShadowedLabel.GetShadColor:TColor;
begin
 Result:=FShadColor;
end;

procedure TShadowedLabel.SetShadColor(Sc:TColor);
begin
 if FShadColor<>Sc then
  begin
   FShadColor:=Sc;
   Invalidate;
  end;
end;

Function TShadowedLabel.GetShadLeft:Word;
begin
 Result:=FShadLeft;
end;

procedure TShadowedLabel.SetShadLeft(Sl:Word);
begin
 if FShadLeft<>sl then
  begin
   FShadLeft:=sl;
   Invalidate;
  end;
end;

Function TShadowedLabel.GetShadDown:Word;
begin
 Result:=FShadDown;
end;

procedure TShadowedLabel.SetShadDown(Sd:Word);
begin
 if FShadDown<>sd then
 begin
  FShadDown:=sd;
  Invalidate;
 end;
end;

procedure TShadowedLabel.SetShadSolid(B:Boolean);
begin
 if FShadSolid<>B then
  begin
   FShadSolid:=B;
   Invalidate;
  end;
end;

procedure TShadowedLabel.SetShadowType(St:TShadowType);
begin
 if FShadowType<>St then
  begin
   FShadowType:=St;
   Invalidate;
  end;
end;


function TShadowedLabel.TxtHeight:Word;
begin
 Result:=TxtH;
end;
function TShadowedLabel.TxtWidth:Word;
begin
 Result:=TxtW;
end;

procedure Register;
begin
  RegisterComponents('MyComps', [TShadowedLabel]);
end;

end.

{ ------------------            CUT              ----------------------}

{ the following contains addition files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members. 

{ ------------------            CUT              ----------------------}



*XX3402-021396-050897--72--85-04051----SHDLABEL.ZIP--1-OF--5
I2g1--E++U+++Da+-GA++++++++++++++++2++++F12q9p-9+kEI++6+0+-3W9+WdzjA-KE0
++-S-E++2++++2ElBWxHG232F2JBLmt2FYqRZAqCon+ElxqYyKXGLSo7kE4d53W7+qU99v-h
ic4JZfNeUpPQpYqaKqjRi59Q9uuw-Cz+YFR+sZaECA07-k+bHYemc68sl-ZvNintyHzysO1+
5slShh57IRx+8-Xu7qPUAntj4xarTU3HcLx0Sg+KyZhYL776nDEDBTA3YCiNo-zJ1XeV60jk
K0ksctPJLEf-sfPZsMIU91NJ5gBXZ5590aaLsj14wOLv2nLL1CYZWGCq1a+Xr4l-7RSyBn8f
XyRUaiBh6a0i+gRWGw33-oCm+NcAUNz5sImvgUSllk29g7loIzLjd4bnV2TcA-XDgBk9cUgw
+LdMgT7erqLJOeSeK4qPpufRRtFrg3q+pIVaIKyInfhXFYaYZalLXOcmAuHDCRvaMHqqXXIn
Bx8BB4Q5GFP8KwRb2F4B1WLLwFlWMRY0Sr62PbSKUcr74v0BLS6yLaqPDUiLGI5SGADPNP8B
YDf9Q7MELA5uhMHJxRWG2y0hDen9PApdoaIogeT7iQ0IVAURMWsDYmKq5KKYzXPOnzFdlZFv
a+bcGmsU9GeMrWgnhJCaeLgNOOC0p+vdOu0IfQhEuqKcyUueCtJEiwjXJ6zzV3KeQo0ZZehQ
0oKLmFMufb1xJi7eR1X-h89KzmLsH-3IcWkuw5rFURe1qkFTzNLUaB+Jw17-zQw2vzFUnZcd
lge7X+maNK+eXvGTP-aO2R6FF-JYbzQWmoK6ef0A6-KuIbiZMOxiBylRCw0H+My+OuWSDUCa
AyFgUVy1X2L60hHB3VRQJif5rtKucp6zql1l8rLBYgyCP72PetYbmWm2o2xEGkA23++0++U+
Yf0j6ZXxT9Mf+U++A+I++-++++-2AHMjIoV-F2F3HJwiI23HZJF9Xxck29sXwFzao+BPJOXP
rc6sE+XPef+U+ggF4H6ERlAvWgpGVDfTCqC5dPhYyv+E5gxwwwr1symJh-0b6YYkLrKOXKN1
8cjZJamE1ri1dhY+W6xaMKJaDg-GejalE0xBGvoVOMn4W-rfkYkMkw7R8MdIgX5ImdOOL7Zb
eAiQR+AdAfoX6TdVEpgmPqmHgtEa6v54n4JX8FMvnhbn3feksEUhRvlV+o0IG5gPk7nrXZTp
xxNelIcjJKeiIlzEovDpVO6CxCZTE7zT+-LI5Inq7Pemkl83lJOA8g4GD0PfvvWlBpTM8jQk
Ytj5SbFFmWSWwcsbaDcX72Wx8MKJKVbsuM1vBP2wsxnd0iPBoxYYX+O9KQHLCXMvO1roNY+0
lOPz1j1lWp-7VYY+TOon36fHCQpHOM-yVpFMG-r0U2oFwaceeVVIWPjF7p4S7s4jkCpywD6W
klmJRPaltjFi-izPUy5MIJlOt7rOTyve4bRGQOFSIJ1RXfExIRKg-ZpT7k5DWHIPZmNI2Tur
4JEPXCCDkRknxuCvfzRI-Y1MWmAaO7zT0Ym4jj59TDIBXkBxI63Lz9MeTrWx57ibKovd9jBb
hZTfsL2pYvjI-Wz+ENQB599nZhQ6hvJCWu9C7PcTL8gjGWeFjVyVnbBeKJ1X9vQipA33ugPV
8VlBe26O6ZKPc8gxu38bCnHMGZju8aW1MdqtFw4FOK7w+XJnwvQLJYqCsvmA-yrhNiALI2g1
--E++U+6+4K--GDV4pcqj++++-Y-+++E++++F12q9pB6EIF2FIpD9YFEIaqDDki1A-13Rw5j
Q2D-hcXUqh7-afEd86H2IF-PUkMo-jxAsbSjGRiVhBDRirizstriiucjKi-pINOWvMuisnfH
6+PL+PVoTHjsdbijQt+8j+nVa77PlX4WZ3rLai82Ndl20C2Y1qX2DNUB50uKFe9FBKboLteg
2XDy4dCMKhn4a1QAxU51T15e9Wedn9J6uoMyWZ3q8YXZq+UsbA1vD41EPwyt3wIcH7lhOYDt
xf3kxyBYYpdbEdK-unk-I2g1--E++U+6+3B+g08GMYNJG+2++-c1+++E++++F12q9pB6EIF2
FIpD9Z73IuJHDKy1A-+xc-7W8JHeLgOCrQ9KJdomBDo9rNcFeMDNOWZGn7XJMibTE0nwZ6kR
YP6kc3njXAl5YYuxwvDprdqlA+zo+-q6cVwLs-s+Mg6HkM2fAC505m5B+0bvVNAZaieu7ULB
+AFysKG77vwJqupelLiP936kT9ryO6IQyLzekYP8L20KQpWinicUo5HYNXwzI8+OuiNZGQVm
ZFvINwxNm9AkmQE0f01YEIbTBd-+NHfKBU1hrbWSfql1aaGavq4sIiS4MvlWLJ9e8Gy9gVlc
I7GJfjG2uo9f8GysMxnDLCwaL7RJATaYUNuJuQ-eneZVPc7+bvXWZCwiC4QD23s0ZHk9Qd1T
YBMFq13MClhgkA5CzQMiPD16Leex5b80qWS2WDgvl6PEDW6S0QXsEctfS5pSfdMjPmhmzapz
xNFl5-bTwvzUk0xEGkA23++0++U+qe0j6f22Sq05++++c+2++-++++-2AHMjIoV2H230FIki
F2BGywz22-9gsSXW5yvesiDctCf1M01EkQX+cA5+k0+-lMkA9+kUcA16U+62s8k4A47cO6-E
6+UG+V651Vk+Wjk56sPzzm2I0682U6ElhM+x+wWg1kng6As5Rf-6AIE09+tJJ+mJ-6g-+HCI
nEtH1hPkUE3iOX3ACJ+FDoktK5AlehIkQLNXOU6+I2g1--E++U+6+4c9-0DhJ+Rd1VY++-+q
+++E++++F12q9pB6F2l-EYJA9YF1JQJP0rUIJNMyhueuizd75YUWnw0EU-1+gAUk77-+EUHZ
2EWE106GYdMYVWEa5Ekm--0-VAVX2gE56i5XiPCXi8CkijD7BAWAk9cc6g6cAyg15p44FRR5
Z2lbzrifefiu2pnKyPsNy2uRCiTwxxlnPxouxx4JfAkt8MFz5x-0yg8nf7gx8ZfwTmveSBGd
eDIlvTP9gJOehL1ACsvsa5pG2Lj9HXTwfotQbq9b4SQXdELAkOeM4H43hNfYjh7RYb3zq25o
PFQygs2slhOnIGlQLmblRaXzyf3bUpO9aZhQB9JUYPSAuCiwPob2Mf5a9ejqSNQEXT6sc4+0
huluXeyYf7cccvoTypNHtdKInptKuMKmRi2cV4wcQuce0e5wvqybg5uOQderifdUAIRCn3a+
w9XGZZZKI3rBRJxTe47HBC1hJEKJlGKwx2RzLgwKOAfAWb7TJEKjTBzldx-7L4b7feVO+gpz
NXy9-UhzKGI3NFK9cTjgbKDg8OpcfewcopT3WxvzqLaoL-GRtWqjUSP2CBtPo2XCqPb3-IIJ
1z1K-BUJh0s8NDGy1C7OBGd-mDkSrO7K3lTBaSexpuT7NCWm17pKbBYtPZP7sa8VZ298f8-G
3Yf7csTVpNt7jLG3cgYyH-5DPtz2Ov3DIkFKYpGGPLi2xNFoIJecbaPto-3xpO53YmGi5adF
7QQ4lr15HDgtyk5v66nGBMtgLZRaFJZ3ZPcBvfuKZf+u3XHYJdGJ38ZDki0FTw3s7uql0kBj
b9cRyWFtgZaTJT3+iPc1yj44LdZRutigvcFedZ-RZ6EeHxo3JN3EnNHLC9B1LOziVeJCtXrW
YPCQhrhxFcrFOVFAlKsWatgrQ8xSmLX+QgqkSA0S1A9CW6tZlA2g8SGG-lih7U-v6cVhopoG
-JpegA4+TFy21JFA9cjY97TiIjFYh5cfk4cED3LFCjJf8QiJ4sMP+xnM64uNvdGXqI+Z0-ND
6JfB+5Wklk1jow5wgP0dGdNP-qhx48pC-bdC2DqKXhM5d49BfD6Ky9kdwHa+zRuNfACiuH0D
csGlNMdWmz7KstpPBXAy5vVjbSoR4eujFFhNylH3YZBEIiu9XZw6E5TLPBpFiUucYlIv5k-S
DgOX7lQ1h0MMJ733uyhoWu9m6J3Gt0iCbZk7n82UdZv5j8Ks5O5aARuCEtPRpB4lHx3SgLoG
fE7PdFJmCoKbOGIMvuAD9Iw0jGk0fKJec+JED-L4inzOCV16eF3cVlVnFW-wL1+SrLXf4TY8
FYssq0bumE1nQGb+xpbf+BkP+LPVAhvehaIKJDd88gfNuBVaxeVpxQrBv9IynQmAl4V-mxqK
0KIZWwjN3IwnSxYu10rvIwwk53trcYShPfj+9T4KypW8JA7OfIr+DaYz5MPh-ceqihI7BPu8
r765jO91ihiO+LrJ-CIw0jEVeUxpJNdh15-5SnKnRl2ilrrToR2F1JlraxiFJJKkC9CaeVfU
mStaJa6P1n+bkyZL+AS6cSRKCLVOFN4L7QIoguqqsM+BBo3te94UJbHIdD80FKLS6V5d2RgE
c9frPUu9h9hswxqiv6f0aadxva+TqdjNLqmP+BwIvbXJHPWIqBl8Bd1A5JL5ieiX+2a5JuKb
pWsCus59mpOrAuSU0bqexE8DMO8O15Fobz+MsY1rKRoC1GpQQr03CVHUX+Vkj5UZr-sBb3hQ
wQ1Y2fp+Wne3DvO6+XS18ZGrDOSWgeOGnqOg7TMxxVcG-Nl5B8wb9aYqhtivbJ-Mu0r990vE
6axL5kLqTm8SQmzEJfm0MK2AgYw4h-lV77iud1Qi2pKrPKt7REaSWI1ChBw0N8yysE5r+PI1
COAwgumYw1tqL0tVmyoD+jZUF9VxQTY9VgyAwel3NG5k+Th1+1sI+Sv5bvMek-V+KJIJZKlN
xqNqnfs6k2IFM1tt5v2Ns-Z9jJLgBc+ZFma+dF5Uza74QBhbZ2we9y7sxVhUVnieU8i8k+v+
NPbRvNlFDeqWdhcfggBRS6rbCys+wcs6x2xkSIoBceRJ9DKmvI-jQAk0QZM2SW+iwlow1c4S
ImYw2wo1PZs2BZ4YB2KRtJpQUUJQ3JBf6LwWAefm1pttnbS4fnkJ7KxOEGqdDD-pnZ02D338
qiEe9ZPOsbnCeOz1q6HyJi37alZYBf4z2dFPb97pZfSudgn5+Vq4oWc8LV6CNCi24EyISuju
iwGYm4SuptqmYighirS0JOXsUYgfkJmWV44w3XGqiNtmnLBRQdaAT2eg3wglqF5AiRLuij2C
3ozrpa1PS0fiut7J9D-aSEhx8OmhUtQTcknZ1H9I6xbJc1f37JimmkcKJvAfEeSrLNbhfTKl
8k4iSUKJi8JEnzDJrrkaQ27t+PQ5UPbT7IjNaSknIMVbw9DkXTYrlwQy3fdOSGWfRwZMX3wG
wWWx0lDRASuk1Vac-BhgR5dv-pRmfpP8+beCJY989Snjk5meaIkiddcuT8qv8hlzbRn7Tu01
8sq5igRxmD-T-jxvtJ15u0vqmW5z5vbT1DRzdWjzNony3QxB5hpz2TmrRTPTNj6zoXBFEqB2
CgFevVTVs4KalhvXeHFQys1amnZh-l32vnCVKnkPDK4Vdpiu01rR2UfxHQzjkYgIRJKWm47y
Es6X-zx6P0mofQtYLNyXwrmR9xHt47pbu9nMSCppbe+DzQ4uT0i73sheRLaJnij3hWJ8n6HQ
aocwXXoMjtkDIYs6DZGUg4dXhK9ZYUEwruDzljYssl3kis7ibk+SmrXh8WK-7sDTdgiHRHZD
tuIuLu5PhyVw7zVhW7ib98CD5ePUpfUvaPP2Pn5HJXW8H3hUVIlPrrU8PLZT6BBKRm4NhfU8
4JhPVI7PqVkmPKI-oPSklIdk-ww5rJqh+pmtYvCaHdUsOSfkb+atDCV4ldDVDBnRVMnYuK5X
aKsVqZF+DOVrP6n9vf5OP5OLmyIaNnQkWiDdXXyVNGXUQ5TXaK+35hluSd4uCK7v1FeIZBmb
inlyr488sqghJO2sKp8QP8CSQIZ7Ag64Zw1+hMs1kVML7onEUTIAsPIZuooobf+RHooZAEsw
p1Cu1nOzjOZDDlfVkNBKUON-zsGJV5AERfrUEg-303-409UEXQ-frmhVF0y3tuMADXEMyW1K
kNDD76XNn2OCC6epYw8nmrGcNb02owPHFmv2qFnV7VI6bVzaErKrVi+7c+1WcV00jyNwEBoL
***** END OF BLOCK 1 *****



*XX3402-021396-050897--72--85-08451----SHDLABEL.ZIP--2-OF--5
Ij3riFceLoX3LpMyrCcoDzlBL+rl6IrYAykudh7u9jM7HfmMFTa7F1lasrXAqT4MQSDd9Z0Z
p7AiGbqklym9LLAzGd6Hg0riHnB-FT6+dB72tA6Yd9l-m3a1YPdjESsRUdEo36Ya4FDT0Alj
hq6OGo3i4MJgQFiqIOClpTUdpjhXg1rs4HMcMv4OHQKq6Upfs53MVsz54XwRuwcA97obM9os
2IifH0nQgf+SasF3MHPKdvRH0nOXfq23quvSEMDgRx7AypGgZ8PF+ThoCaSTEN6XVsMvNa83
AsgqC58lidW9yLkStjltp+7uGpZ6fnhtT9K6PkKZi3PGDBReH4GfeRvp21rZKYBbLEzH7RRO
nAnfo9MAv6UbgGnr29FvChgftv6xPhvqyOlB9a08Nn1OLQd4SbXPexYxbaGoSEIfgelaVlrf
K9avCpp0Dyuk7s1uUl7-GO--cA4k1EIT-PcBxnw3zlZc94USfJG9E3uOcdG0vUAhULsZu02O
8OwVlP8CLf6po4PfFiWaglrqLB-wI+4v77K0fk0hNVzULGV9r2+9-Zs1XKM9-eM7LO3j7HK0
Zc7iIJNHgPmKbdMrIs4m4PMaqWEroLGZ0NVar1RHhR6Av3PQPsJy8yGhRAqrXIu-T1KDETQo
P2yXz2vsqEZv0yEKKezgUfk9xfqExw8y1z6yqDR1rUzv+QU5MDwpt3z1zUnYNq-z3j8ng-y2
T-1qtm2z1zg9Y3y+zF1YEv+TVbkMRXxYDyl56Fy3zFXYMv0z+jYJq3y3z0fg7m0TUDoYt7Ck
bs7w0jPHY2z1zXfYpq3z+z6Pg7y-T+PqQt1DkTsqt9RVDkztDCkL63y+rQ6qmFNKfJX-fOl+
QP0bNERPfnX-bKmu2UBx1Cmls94klo2T-rgwS1ngzO1j-rg0S+9g+u2T05gWS09gmR+bknsA
T-Xg8R0bk1sGT8FsdXTTRUooahpwazOACLpj5k3OG1CZAicXfOFdaTL0RXTf+vc3B+EoVbuj
r2gvMmjd6PaGfgPSXpFQFRrhJNHSjNfivSs1ta5m71PGvgF5E7jcLB7Jqh9n8jULx49D9uX1
xEIR4z+Zt8wUToIlvexcw8-jsDAPw1PkBj1jk9x1LRxFKy6po4UqSB-MhXBq95UeS0en8Oag
9H2BwXX6sxXR9+AoGQFQD88EHhg9uRuQ-yYjEljcsD1Bc0NEAqUf7LFvXp7+AsSzHtCuTI-t
c6j1DmFDhojETMnvHs1vYUeHvq03mTaUSo2Jc3fsvo247OgxeRGpW87RdNHiicz4CijdZut4
o0CUHO19g3o-zkPI-jcCR+ooajrGBFOI0Yc1XFByKxY+I17cB59FTCGWyQV9wt3fSHtO-0d2
1Wl0njIWxxu9D9gMCLYlwawlwaw7QaENQi+GtABmZ8Y3fI0iOU-hE-vRUDnQ0Bu65Do6y0D6
YFj-Bo9SV3mq4PZh0r9R3jXNUjhTEhQ2rorUnQ+oUqw3rkfPBi0q+PQBDVu1z-XmslC6Nnja
WOS+SlfZbUPT0Kd-aFP69PXTVFVq6SPRiBw9rJvkTMVx5zVysDN1hlzr-s+v+Do-n1KzUjlf
o1CEbk3z3fVbkEw0Ql0uUtWHzVLmwu+LE6RUDkFy4DP1mBazFJkj6usXoDZ-Fp5a8DUls6u-
jk9Q8x0xUfVy1zZJo+bEGRVDUdy0zFHWS+rrdl5TOT1LEKz+zUPYBr-z-dUnWCAgvgx-Rkvw
PTVw4zkwQCSVCszv0w-RUDs0biCTA8zx3yHr6PwD1AMTO9nwASGD6Lw0yFDeuve8CSwetdhj
wAnPACRxVyRt1Tpx1Tpy1KCV5LBE+CAY+5k+NEBc9v4y2aBhq3BtN7bBQpbM7N+5SOQBT7v9
0hb8NW9zS2-h9YseGt7Jq-mkCG+vQCz2jNCBFpte+lwdSQ0XI0M8hVXMMb+T+poAt3X6gT+N
0pogR7liUgyPM6i19EvrQR13EMu55+yzwR13ElTDvd7uUTR-qHukxsCx5yFyi2z+TE9w7Y1a
B+-Z-Y+z2De-i-w6rI16WN+HsHAFiYHc2ZaqB-Vw05kCUHoNxaH6mPUTVjhVw1YAAeQF81A0
yVHcgHY4nLCBlDp6y-g7SGFv0izgD3+xu0nSrOqqJCXGqDqUSh-NjACJIUN9R2xY3uK7i7w2
TXjK-9S1Hk4T+hpohhORUrVmQ7w9DUTfV1bUSS-toApb5vYL67M3i0w+9wHOcF1Q0yu3fdFx
9NJV5J24LUtS1ZopOqLJf2WikPeW-jk-w+SULw3OD0gFzofQfqNjShPkrnpkLwxuoanO7nJF
CRLEo8UvuEZu0LjySDchjGjsNTeO5ipxdrPuMTuF8jWvZ3VR4nx2-Lxx0jrY3DeR8PH7qoBz
nrwFDqdd0xfEHkCW+QNj+9M6gC21mrxXaxBL85OHhYxZlWNmZIeCwCttgVD2HiPT-gklVX+C
AjwWo1L4GOPT+Pe4iAVoyhwpl2r4aHxL1MiA3ZgUvOGTrnRpgbOXoDYyZtj12BdtTT-ILxid
RrE2cx+DuWr-FdfDtcqHSRA7DhSOnyGB2zbUiHoLVrE8cHgNdzJQNHtvBovSkwvciLtIK7XO
iPgsaSRmQeQOsgVw5YzW10+G2oyaIrVlihY7QXB3b9pfdl0VkrHX81posguJXrNmp6j0nxap
AtH67jIapJnF9NrQx05XH7qfnATYlW4tQN9CJSOHQSBQr5FynfLawr1XBBloOguptZBksknQ
R3PChSP1PyDcCrF0ndLa+qzXiBhw9gvJtaBist1PT-fCpSPXPSBkCrE4DeTVclQZjC1shyOm
p7VhHQpKeZHkVin+txP4P+KwAHhkwdW0RuWed80A3p0A+geeCUTtp1KLJO5cKCfdKCd8wSQQ
fvBOwoke6GQR5tTIQLRO8EhNQNToVvJD2YhuRSoql+XqC5IER9i3PXh7-9M1f7HoAeII8byx
Syvry6dF1LLhXqE5GYBZTsRQY5SwfhpI75Xju3cjKaXPP2JnXuAzf6pnpNCb56FiGD29E3Vn
-RcWPYySge6BcLH3Cuur72mf9zSKEaIq5fYGu73LH0lGhT56dPzqm+hdRJCsIXHptEpY2VjK
vfklq0t8KjLmcoGyCoH5R3aTrSx9pfghnAAHXGQOry4uFfV7SLDcoJtbVQSBFms4R0TO+lyp
tfXGiCvDUMNpbkMsTgDO7bewgSrA7spfWFemfnFaLlZ5JDCnulGw411Jh-opmIRXnktXhCMR
OZXrQO-p1sqHe4NA877NCRTlx3vUWNzTlSAAZTtwwHV4BMj00vzJJS29Fi4L72dtJzH+RGiu
m92wH6h2OxsI3LJei1i5htqflFCcgOAPr8HeiUoMzqZIgo-jAiy+FbVtUUTEYBrKW8tgmDtS
hwv8oMADkbXRKfEBqSokvUkODxKAS8ZPVvAotdBPJp4cOmDfULd5tu7zEvpQo7oOMSmbB9Za
6GyC0fJEfZBbdudii79DAxCYabGx1frnEgzwFbn0WTatO8uiRVrfZprvzSe4MjqaREGSGwp2
jEMhq0yj4ylLLETvHKgfvxO0untOkz2BDQffJj6kdIYMEWiiDsFyc6hyN9qRSolvWNfl2gah
JdOoMR8kB4Kdr5eB5axstQm5knjqYqZaA0KHbRVL0XydNqiIp8Cyaw9ICLe-piSv9fq9kvNr
8eqfXR8T9zoPejsPuXKGRQCFxk8DfDgU258ZyagaQqh5nJXEaCA+M8fg3dftkVIPXpm6G52Q
M8-N-Bec3WdPIiCYe8H4CH2Buns9B4mv9BuTXYCD2mvP86Um3JmpMUXJr3HQEOIRLNZBQoyC
AHzmeuudOyiFpv5oGgXPmoy82P35FcLPSOovu3BACCWA35wefbJmOvrQgCtGs5CZ+xTEusoF
zEQ84wuL+YyYbjq3RSK0p8ADn9jCK+wWhJ5NRUAXD876SqHqAucRXKd5wVR+VWeMifdwAoni
+ep9775VjyXoSju1qmCe3S8gbChYT0A3T8z1PW+H42I0fHIgHIOvHpurrLe5TVkM8Xeo9GmK
uwxczuXqvBLGvBBzfzPwmD5qzrl7SJ5y5e7ZRSoRVmw5CUtz3X+bYAXIo8Bs3FKjKjJXQgDJ
I9IzIBD7Ike3PqyoZWBRBHvuCBNfvEpngFZePtkPo85u3W+AZXfLJKB7nLPsSXRaClfbifGZ
BckBA-dNBCjY8NL0xpv4kxIrL3pIg7qsqqWsVQDhNZzK9brhy+3TCwmyRbHmNQ7ikDtg9ARi
+9MSkUxWRtilizzj45S4lxX7jghYhopPZZald96uz-a7nQa9FDxCyVDOKBTS6uxIgtzw1qrn
7N5tMucaDtRuUDCDAOO0wswlScDnXn3whBlzE7mTtDi97LvuYyzbrpsB-3wZwSw5wjrps9D-
hoXwEstwTsj2XpHmzKx6z5Ucrrw-T1vsSy-dsDm+QG5sEj+Ww3eNTy0-wi-Zs+RYze35ijy0
ZLzMYSsb4nwoGTSfs3bUIHNyy75inl4TJ8Hv3n9l6MVzg2JwwiVDgD+XciJyzd47Wtcmv3F9
ei1fGI4vyAQY1S1wSC6lu8DpTh+y3JbijoIQAKbxYUUyKNmXYTwtzaY9t+nlsQeRkZs4yJPl
MIeHTsnc9z8r+9Q3AjzINGgszoXZQJrzD4HylSizUTCDIbu9xhsDzXPjBzsL5vmTsTXDs3AU
TwDvXTxh+BcdXfvMQV3zPuP3AlcmPwRsdgKHlz9x8avi+LwCQW2sztGZ-jnbD+uxr2iEss2v
0bsGyXyWz4flBkXtzUHyOMeIvwQs6cSYsLh-tdysz2GLom5nzfxRZlR-tgyVJ8cLvKbExTwW
9TTnHnuSpyInkCI1xoRkDzFzojJTEeu3zbgdrQyzEcqFBHtGnjTjsUQ4s2zk1rn+zlZwCzUm
ziIgC6zvTJqq8D+5DnPGi-jwIsKc9tsfPow8OTop+tmTzuk-fkTTH3ezPWShLTjlT9S6Et8a
1DvBtb56z1os1TuQS2tr0bwTUzBqT6YV8juSEuzL0Xyrei9fMjxJILxHFUf7JYbkScGdQOjU
Tv0cCbTctKAF1uybDzlAZfLrfoIQV1bxJmISjmPTUzcHM0zLtLKElwXw075v6zeJfYR009O5
uozciDCENT5LCmH4xFyN7gR950TFCYiyu8RBs3RtSL1SLuy-wnHmJxpihqfqgJPBbaLJv1LK
tG8DP9PSuOy5z+ns+T+Xs5uosppRjanJyXjFdj2gQDsr9PYqdw-tPMbyKXnIOZiHC9TPchjP
57fRsRHgwIuhT6PC3ncpL6JHkurKQNhpyuyQsSD3GXQaKuxXBrUrx4i1C2VimZ0pT0fyY8+T
riAKU2M2wyzz+Z-9+kEI++6++++1UEIX++++++++++++++++-U+++2EnAZwn9p-9+kEI++6+
0+02MPUWULN-bto+++1Y+E++2U+++2EnAZwn9pB6F2l-EYJA9YF1IepCCkv0A+lx+OG6WMuA
5FaFiW6VeW6lJ46+WMDY+VYtJcuI4kHvtGCJiTv2xjCnMk1clJD8zWxT+pnMry0B3lusMQ6H
5xkZnZ8BYgqBTyvqiteTl6z31H9QayLyfaKS-ixnI3J6bV00LY1H6lZISLD0g7NQcPgWf-PF
2b4tEPmEL4YG2xaKr3Mu-m9OJZTdEXdICcTRwii8qq3ByE3EGkA23++0++U+QOzp6W7JFtI1
2k++gWU++-6+++-2An7TAmxHG2FAEI73H0t2EpL3KLxoIpKSjyyy75pBonEhXp7XkR6-98Kh
8LEt13GaDt9EAjoFaVHE+QOEj8HFY7HY3OWfVmdZB2EQTkmQpL5Cu-mRoJrIUy6FIQtKuD1f
A6WccysuNrKDsw6WWdvW36yayvrrzQV9aXcuzqksvxpvDxyTxrizxzji9IqzK4JzcEeVnQxT
eJlOADMpqcjuHSsyTxWvIEXLxLjX6yijJ08zjZC61AGDnz9B0lUxfaXzE1w-1WssAhjbtxmW
jpKAVGKmmRAu2-SXane6UgiqrRC1VLJOu0HnrDj-OvF6rEd-d-qDg2rwzAWZ5qKFiu7W8-1m
***** END OF BLOCK 2 *****



*XX3402-021396-050897--72--85-42158----SHDLABEL.ZIP--3-OF--5
SQJEB297NFZYhm+q1sVFRyVq6MQkcMN1kQUa6G9d9gwaCuCyULVfB094ca58AHCPkxoLrRfg
wkbVpXtjX97Amq-dXEZSIH7yPPOg7yOBlDixAQLw7BzLF4DyBH3jDuKKN3-Rrd+gRKpqj99I
yjltxd+r5+rGBT1txQtcP7DQtyGtoK3kVYQSpha3U5QU99Nt6zuk23B0ZmO46c6f3ioLMa76
W0iymqHkc1IQ+iDRgJ+k78p8uKFeXy+HglE1nGtg0TY2+WXfbG3eXra1vNiwERZcWIff2Ply
huV2aZRlhmHH4TI9KF7+QOJ1Px5WLRtBEVOu7i850TiI-NPFxgUKPnXYJwlOBCvoeyiHMP6Z
CV1lGwsLeLVjju6Wk5ZOjToYaTwffqSTFW3NJWIW4PseOA1UcPbwvWzWzQ3W9ES3eK+4r-cB
FqBN2KuDIxEhFaC0bqfBUyG8lOClLuqeT1yEvp3WuMiPK2oQE7oXshoMZcI8D4h02NbqLD4V
nn6xRYPZk2nLq0JUqeka2xJZmiKjGZFpKWTHm+th0oqmGSV8fNeQB-Z0pqUQJEUONnDWg1cI
1o2UO-nAB3tqq0WC9GHXbpqxLQOuhkUlWboyYFw635cQ2Hy-8OHvoXoA6SmA1gE30dmux8Ef
I0E-bR2h2fWmhjTT6Ikfc1foVLndfFa5RX199HZtKUM0Z81rVXrFTdjhT3aEwsNPcW6IXrcm
mf45qsFEg2zAqi5i53G1BxkV-AG3F2ySBxl106j6MANYdKh0Tf3jwXdb2o3ZJnEWr+-Oc397
AtIy7+MDHMSzDKfP4B-vmCfjLyRM5AnnVRToVIGVmztIER-AwQlI-sOKgBRrKvTx8KCkI4JE
BrlOlVIGTREBy8MFX6vr5iKT0yM5yiLmy3YsgJeXFTr8d9KslQ4kKbWwI0rWRKEZB52fpi9e
rAaycz-9xvzvBJG8ZhV+j0xn8VdEhE7dEo28D-yNSIokPqDQ5MIGZJTqoChY4oeqb83kK8qz
kB6O3fklXf0cvg-WGRJTKUdT4C6zyAPcr+9sb9G4jT4sc5nlKuCPya4N6i8fpzp-FqiAD8vf
W5fxwVutFUCjZahaXl-FsXtREpsHUlJApz7m1Qbh1EWhrb1MgQobx8iTTBvX2a9lI3kY9Arl
C7EvHpECyWG8j8HeRzyfyMzT0CQGScsMd1jfeQ8TRUI9FGx7ttLkNEKwumryYq-7Xl+Yea8e
Dz4nzldP+ObN8QHXt7houPORXw6EWVztJh-VAAziyLa5kyZtdLY-4yFUoBCycgrn8VbZkuXJ
oSJlx-m06SElKN7z8kdKEbevcZ-XjAD183U6L6upfiMiiuStlLqJ07c+KhDRMqzdQHHzx0F-
0U1dubPpC7nhOkyxg7VMWbarYdFutMMPDtNwwUnqemuu-yCxMWUgiEVbh7WfBRczKDzPrwo6
4a1I6IHixPvlBWkpA9N5Ee6YNc0F84kWUo-SGnE8KFDljhvvH2-51WfTB-rv2lGRvcqrkXHe
icGhvN4su6rsZ2ymH514-041cjD2-cF1httO3REvjS4sw+do+wG9I0EsP4qn-snBYLUcDEuO
aaU0GWSfjzpqT3KkI29YuYSUU6uQlnOQ5BkEm4i5koFEWBpmdSDlE9u980CoArYDzkka0riq
Cs1U3qFRoHXhQ2oR709FCBIhXJf1gShzzJ-HoBkYvEdb8+7tG2rttb9lDbwjGNRRmkyunXQW
F-2vFLt02Hkrbz1EefWfWI6u0hYZe7Z0Vic0XvjDusxi7KhpvmTa1rvGC8ycHgM2DnrV1Kpr
DTHiQZFhncHjzTrqnRCO8b-RTO+3JSbKR5er6KHFqKMnnOIqB7hd8PLV0YCD26Su-M0jObea
j5lE5G79UVtYWrLqqHer2+uIBVZbArKZHgBgErDrpcUE8tr1JE-EnjaeGfBImD4LRBXfCJI3
7ubkrLexIRpsQKQPieq8np7-XvKGUi9fmZE3VUcCu4Fzp+SeFxH-kY1pslJuNxUPX7TOX-Iu
Yj0-ZIJbIlAH3RXN4f0CJyUxqoGL48UtLw4oZmuVfZS+uxRaqJp-DjZSDmqjYbZniJKlXhH+
KR3YITQYoEPhn95PJqf3jWdfPcgYGGEdGvZhgY4mIhPQ-hCGGn9hVK4ddvFbXquBz4Dqod7N
xjnIrVFVcJyT544-V8k1eT9QIh6Cm-ZBgPEFtAemt1n8FzLjn4r4N1buoTovMdlGysT6XYRf
9LNTZMbKUB1hxCsdsLqn8s1+kFJNqeeYb019PC-i9KOk+zwHVYpSh+7le8aNRTuaaCj2CfG8
PQSqoEs1eX2upIF0pa7K5hA6cffNP2qyIpZrN7ij1Aam63gxKuAXAI0q5oixBQXKnBMICBDF
F6rhP4q-7iqsgNCshg0h-Rv-8UTFmspxZCOEU2ispeHR9BnMTY1Q4QXVB28RtwOishf0X8LZ
ljFgbI4eCOAZ+fsVHmsScuZ-L8ibNK0oCc3fwxKJtQS8qJdCKH-yP0NfAuMJwcqK6UXqI0Sf
Nl5hqEecQMa3fmiVs6zNepUZIkfpaPTm3BmD1mhYKHSNBKwfdRV5y36KZIGBhtJFv0FyFu5a
mNQs5ZYd+6x2oBDmluBm-IOqT9IWwaVK4iOIjpjke27-gIojSMgeJPJuuUqtD2ULBFvBIKXb
PNlmLyDFj9HeDDaileCeh4OHxYwRD8fCx3h51fEwegZ20nErAlvJdNINovQm5hbGi1bnFgOX
VKZOjbcPsp31ddr0X1ymw4VlKcd9upeG8NEbrwFsh1HBbhQRUJi4vnMSBKNm4vgXxcpVaPNw
AYqylz4c8GSBrCRsp777myyCmDQu5han6hQRcRQtaZr6aNh6vbcwOdiYZ-7vkNSJ4GGT5Se8
t29FlAH2RhE2rKO2YFDVcUtYEgkwKkRWR+Vp99M1r68yNQrV7qs2+95OUkR1gcF3oYwxquV5
ajF77bq+OI8NDtrQDWurfwDnBjfzyq3YcKquaVF7gpD8GRNdWjWTZsIdQtm5p+6zWk9b27cU
9GDFmM6AQIVHakVu6URHDh8K88qzKWsXoZOeePU8Y8NUHQJYEdeuBFJH6J983s3KHDMPaN3I
loXzhFno6dEiOaFw45XK6NFGS2VfEKe36tV5JWDzVYVN8oNuRQcr+towWcclmD+Gd8Zv-4o1
VWIOCyEp1OZ3Y+nhKSuGZYR8FGHEkFk9BFpZZ2S0iv6Q7YwdcbKGX7otvAl+qc77M2QCfX8Y
eNs2jHI5onIcetEGmfcQbZhFiesGQ0G5gahFNc2ZV30CuNIXHaiiBMSeaIUdikFu2XWSp0kO
SKMVdEMHO-xExqJlL6QolNWUkw+kbAJIUHFJaO1r+QBxKImnYOMw2zElM5UgWuYGdSgo+K3p
7w7ND1x0qc7BM6X+V7X3BERd8nS-vk0CCv8ste7o0EwgCvg37swQROxSArlCt5OALXtDy77T
7DwXCNswgyVQwfU2z1ZtDAZBf4dwUN2uusvRQs82zjUxcx1+LY15vXZ5UA1lSovFSUSRovGX
8jaCHb8f0zf5ODzESkEsdX16c12BvdfyMLckz7yWoTx9DSbi41IZXzxwkwyCIcQa0BMQ0rb1
QUetJwCY9WTT4jfjJ3cqHysaXp2t1AbIaznofh3xQ6C1c0kuZxVn4ff7xlOBxDMxbMSETw9a
HpEYXp8drLj6HSwJYc2eEhaZEN6CRiwYH3BFYngCY7AG+E875KSy1xBNgcejXh+gK781yy-6
bgmwQoGQQMWAh+faIkKvxvl4tQVWpWFrXg+UsFVTB97flqi28RbccAkvDaRW7f2fAD44SDq3
imT9YI5FmkyH7KSDh0IQMlRjmS6MZHW6nEIGlz7AXdT6MDSSTJeV+peVBwQ5KT0NjPnX42sA
X2rqwEqL56s-TS0iBl0rOkR7lSHNcTxZMXB2RydIoH+794bjVzP07yEHwL8GC7rg5IhyiS09
lA05mQvlFCT5+-CXv0ZtIUhC7HfDEtz6gvrXWRtD9nmRGlc+Yirgxp4Ww9s7qWuiHrOC7Hd-
zgLHJC2syqJW+1GwG1K+OV-AbZ4oIHbExib3iK+voNjhRPOnBIlgahWFCZ2oz+k7k+blhUgY
0N8CgMHXPB59CuUylrX0wHMAe+d0SEw4NmG8MjB6kj5-VKRJoSFrmF1KiqaERgV-Kb+qoHh7
FUbCYKnVWqpNYZAsaZi-piCVJkzHsw1kzt0moPc0kb351MvZkxBosGqYvZctNif091hGB5l+
Wojqnwfg3zsZEzFgCW46e5WbWh3Ne46LzJCO2qRAMKde8nCag77wwI-OPbVYs6OYYoyuDF9B
mGwu7pQWnFOI-wQIbVQMeIS9Ff97Z5HlWRtjYUyD8XJYu7zhO40OGXx2ufzgtr5LPgS59YrB
YzgiHEZmGIdSDG2hncgAqQlopE77CVZNpwXCYO9vxU0p8S4sjCUfOJjLY1oR70YxEJCuO5UT
KN6ZX-e8NNSrLohHVzonv-+tH8k0b7R1jClmoGxNIfURsoZ8y3XNCLHoeJkZTe14zPHkkCNP
cBI6izfg+efokEmZNP0PYdGW8eKXhAPhjizERh5tUpGJHHLJ5v7encbCmoIvBugT7N6SjRzY
n6eVcG3hJdnxLjcbOJooQjBBBzYHZfvbsHiqSyRdFQDF0rFDLM6DTj8juyJjDYCjFm+zF59p
uCfYtKJvGIwgHB+qSGldaSWlPnUOG+uRYXY0mzOGfaUC74V5mrAunLBOsHahtE5Oofobe6Jv
ONh7CGRHnaLd7Q2b9JabcuiS61B7uCMYrptowi+Q7Fsr5tJCJVAkPxEtGDvH7osC7yFM+cSF
8eEQFiV77lqb4x9-4MTUf1yuctOSYcxiic8FrU355+RiUASXPsRyCutUCf23KiYlQgklXebW
a8wttViC4QEQQs7XeXba3ASAQ6mNMlcsNWb55C4MIMsFU3n1ALIQMyCMVFmna4CKQ2kXlmnb
a0OCOS2MCwQYUAb2AFM9IwlKA1DN7TdCABm7ew+Ulr0Js6i3oPB9aOwgn3LQm1n+ATi-Q-Wu
slnn2LEjsOKYSl8uvo1LmH3h59CmUSakA3oqtfG38Jb0TCJY5f+k9cvdeK6w8tbJHe7iPEBn
gsLVZnADKNVp59BV5U3jOGHjXRGSjsLFKNX+2h6jPG9jDcuthMtokUrA4HhnNWIHKQbofqFW
PMnMkKndMAEqTGyqu+JQWUhl7GvPVOoZi9k2ZtHUXKJsfl40MgODZi15mj1jH5Hkt1fx60v5
qodlAGvFvwEaTE7K664hSBMQT9gJhpLWnyXvxpLYzTFGr3M8N0CSXoiU9QJDrwngl+xWS-La
su2ByCsmTCxej8g21ur4RthdrscfNi3xD5ui+FyUvvo9wRttyD6wTB02nnTVLbl3fskKNl6f
wJsfBJC9HPUS9xPjlqPxMRmUDkbHT+QjoLw2vGJcfk8aNljolOl3DlCSyOkCZf0AaQwOwPa3
yZeKNqfNAaMJhY79J7Leus3Z3HMNuhY5TcArAtSaMnC5QHIMUs--O5VsGh9zR+NsZt35hxHE
+Csg90j-PQ+n-nTWZT1DUyhk1Ou+gFrPRLTU8evQo+OfMA9Jr-lcfR1OM1E9Zr3po7dkaRZe
61ofhb898K63nZbEpb0nc9LW4aCBneefoaolx44zoOwnuIf-DpvLcCBpgr0dPW3S0zEqEsiC
c7K+wQNtabsBvNSHhsnHDZSCpxuDhtK+Ju+-Bu7tL1J2+aC1nc7BCXCbkqMuUXVYXkkuVGjR
AocQtA4sFZSBhXm6QPo-DKFgEaVlf5k+ckzApExW7C0auXoMLQ7B3QxWh7whSFWVLlrclPSE
Ab+HFaUxFjUaP2uhVoT+XmDIXo8sqfUNMfQ7JlgqstvI+CEq3w9nKSX-OlBt1F6BBbEbBb3r
kIHilAhHRw4Hk0Cfx8WzN1RiAnm0urL4Fz0U9jI6ThBUT-NDbwMxWyTmeKSkIAcxUtwc-w9J
aObRSDCgp5tAzu9p2WOD8LKMe8x+fqA1xoRgk5z2ZObLgGppIi9u2mODCTKClDIyQDo3iDu0
***** END OF BLOCK 3 *****



*XX3402-021396-050897--72--85-26161----SHDLABEL.ZIP--4-OF--5
tuLSlkqdXmGijq9ma3CL78sjUCg8Q3o-fWy+uuc2TkgkklckkpOajUIHSdP0yOm-8kGs2C-w
pdMeNebCuGltn8aNob+qGltnOXtPkQ4kZeq+y3beGMCExzw+I2g1--E++U+6+2aGsW6B7x4P
V+I++8M8+++G++++F1AmLnAjIoV-F2F3HJwiF2BJnJJRPBBK39v5HS8f90gdBJZV3IguV19K
VeN3O1w6ZOOoRCdDO368P60ATNAM51jMHe4wo7Ih0UBph8jqA4YRYudeqxjSoEHf71Hlh0RS
E7fEa7U4qfFJ4i8-vjcbfRCkxpZCTAzrbLjiCRwxpyse5SlNx0DIDriztTnVtOTcIpE6d58w
879wWJW-prRH+aZfI2zjM-y34-4bQi6+Tt96tfFATRfoIAwG4piwQ8Mlim3K1Jt6nhsFu1l1
H-WOfBzO8anDSBDvFQZszSb7K6NBRlQBEpISR4K5gvuMFLViLzkfWqACwpp1iN24q5zCK+jU
GzTbyGlFKbPSnv6lqyXvSrVF2BYSWNTJfCIaWBtSJQhLpXH5-yvQTgpQlVl5jbfoC9gtbGXe
VdcrURUyKQce0JIlB3LKzzXywOjN7XSRo+VjY0GjwLaPrJf9XYY8fTo+fsUmgLkqDQR52Gpe
Wtje6Fay8-jqHArWaxTlYY8GaZcUaW2FCs3LeXpoajV2HENJ7TMF6m39F134W41IZXWY4Z74
2bV1IVK9TQbB7bZ7ASnshPKB23tA4PGwKWd318cOLPGqv2Cw96ZooUVFy9kxhR5BIupcnM73
P8mJgbO0cs73QCiGu3K3cWrQ0zg8-RadQz7SgdFhe6chevcJajNRdFrA7e7OoScRlAb+7LH6
nJNqkxbfZxrQuWMAOp7KIdnBfbPc6SCGE2m+b1CQfL-td59eKKRQirOzAiv6uiXXsYN6kRl3
NtDQ2MbFfFMJILSoRZ4XVRJMcPEvFsrDKaRDfwWx3gjY-ZLFbVJoAoDCFZBlynGyY7A2tvGm
0NbLRK79HHR2nFRIVOcI4p-tYMWJjZe3lnH764ghpymWIbm475VNrbxC66LJNiPGGO9dYauM
9jhobNvqhCeIKwAs8EsGLHQfT5nukwycGJIlyx2mAtvoc7sRqznlRNh6HlFKzJ6HyeUVmMv7
IfBTYEnPwZ5965Yf-7gSDba85gLvgt4DAamrege2JzWPcpzHLPCNq-+tquzc-ew6l8b06Lcp
EeeMyWuv4rgZVRMywQwLHks8qpbvPFSTXCtuwCN4hABbayJVsMQW3vPSYD3TXzpsfwXh0HCl
S0O2cUqqGwnwhvhwocmDCb-Hl7AWQWP2cMUjFFGFO83uFcWyu2mU6Z-3P4T4tRlGFy3EU4ZV
vEH3IB+HfVhAhTQ4Y--hR4PPvzgsDFf0OHh4s9wK13UZGiTh+qkKWb8FQ7AElNJjpWEmfq+Y
q0Ho6MmsnvqxrPXgFnyldPrTXDhEexTwpAEtnlaqZLJKtbnjgurpJNyjCATAfAQuCCP9xJUb
lrn9hjegol1bw2qqnPya5fQwrFNkJwQhnvTtP92wmrB01ookh64aCvZVNKLZ+ieWEra4vI9J
ZsTyfhBT34lvW1uL+Toj9lwOdNbRhP8nZTuNXU3JdDu3KUlOdzL1ts+RXts1Rjt7kHfYmAqU
-ahBZy8B3Z0ZiRDrbddIHMFpq6fYPuDJFY9cwWMHifnlohE0TRuOiiMs9Goxh-uXZlyZ1cpp
rVXBFOYdffG9Zw6fLdDej55om-5lIX0rozHvnMFyTr9Wy9j5ZWuqaEMgtQj6Ko7E0YANEsbS
ETDSWW456MdV2gAIVfoMHa5MUI54647clv+9kr2APq16MBW1ME-11AAEVeAMrgCk4wBP42Mk
d12Qkb+MElX1+Ekh49NVq6uV3QAv41ck713o-O-o3uNPM5sLp4A6Mj-V043j4I4tmImdiQIv
vObfrUNnTiwQstpba-uzRs41VGOsgUIK+gk56SyW-us2T6hLukQWDeNx4sANlixVoDUAkomV
KMN18-Hy-84ttaZ9sOjoPbwq3nP5wlN0BPraTvN+YI7koQ9tTk3EGkA23++0++U+Ft9W6dfu
GLkF-+++gkc++-6+++-2An7TAmxHG232F2JBLmt2FYqhZgxf72IIlxzoH5TLx4GnENNZDEXl
s880mqPrjC1wm9X-P17YCWk9cZjdfgYIKnAxpBFYAi8VkIinSDCm7my08-uxSD+E2D5erm+8
6Uf0ShW12Ch5xuEvimG1deSuOifpeqyzxyaevXfqk4xjvxlPUtgfbrg+TeRxoz5P2FygqPei
P78S85wDNHwOZHw4ynsBFPzwHQatGyVyLtHT83qe-s6SY4Mo31lWfhiM0-2Bpxka5UYO1Nr9
rHsCcmY7JnTl5a3XilalW9hik-cA-syKqb9UXKMTwn2FviLKSfiyiyZzo9lPryaiytuteYQg
-Sky5Icdblm8aftUUf0SJbJj0ky6srFbMo24Na-Ln-Wd+RcSBXb-UfWSGgfwjxGVVn8Q1i2P
ku-jDTGIP0es+ghy3fOCSfbEGuYwoJGghkoIOtMmgJvlX9Qz4l4rCiu5fFpZfrIXFYBn0RJA
On7n+jMClvBoK0iO1WobvOUPKRsQdYmIfptT1uacpVbR5kv6I9V6s8Ng0ITpWMWux2C0v9bk
3XuMGQP-N7kx6JgBLpiQSnJUvIbE5pBQUDt51beh4Ios7LlpWonnt7rSi-4l2DL44k6n4Y0h
UvYAJEgXnrGIDs8nWRzGl8rLx1Hw9Nq4JdUFTnZD50bWmXoDj3c+XU9qU1+KHTD68rbYtHbm
KYwWPomiepax25EtgvSNL-33uhauK7lvhY68pDzAIPTfb47KaCbzZSxhkxRAu4mJTtqhQijJ
orlrnyLPdSm+w1nTwcjtLaqFEPGe6-QWgXJepwNAVbEqxwKFqU5P6K2-u8xb+YobA-FFCjv4
+CwHFxTdmy-OGQzBNlawlt1-Ktt5Kbp7jacsILZUpe9X2QAnhBGVUNVkQeC3-TNs-Q1p4pEA
w8UbznTieJcR-z7wLNuDtPYgnl8M0ryJMLugEDu6RM2sBcru8NCgXcuCdCJM3nUyBcru8NCg
YcgsFXwyil0R5nuxQesDGi7nTQ94ayTul+jcTDZSEnc0oiu7P4LF5I-lb8+sURXc+0-t7IOm
XY2tGkTZeWocSJ1z9UhQ1p+JAfZc5SZjcY4e60KIuC5OBn5Ggjbenix8KvYNfJEbaSj64drc
u764fuJGmmwTDRIxckCUWftzbCI3nyb63-AHdveBnXTtv5qO-bWGZktAVMsUHYqO1yWw67SL
IJMKzioLOJvlLATQqmGaQ4cRNEBB3KKQ1LZExaHrrPwnnZ1IWIxDcY8PkdkTRzvtuTFnZwj7
DDS01U-ugIteziHbzvYWXBfIjN1ZZM1x-A1qpOv+P+o8iti5drQrpt0DxvNtG9U33PJbQfkC
XzPkKoGCpGwjzO59jbTt1zTFwlziyKSUgbt6lMZomNJvBfZXSCEidI8u7xxHzk7EGkA23++0
++U+Bd9W6e3cOB2o+U++FEI++-6+++-2An7TAmxHG232F2JBLmtEEJCJJBxjqX+ETYTWTvW5
DR-dEijq3gE1VB-JUs66Z2RYm24w7bMIan7IxLzTbFr8Kh9xg-+ybvzvnjTtb9qG3i7I7+ba
eounoKl6NP5QWUrmMazEB-g+wR2gfAnA7pV8BHwKu8pdeHRYXR2MgKBTa+ZXq9UdFN38rUmp
geKaICMNuX6bro08HCz6W5vOo7PA4xjYN8L7G8klQuSlZ6g1tllt1JrMQ6OKKpvl-Y0IG5gR
k7nbXbTpxxNelItjJKuiIlzEozDi8oQRuAizU9uy+vfBGFFCssn8KN-YaCl9R3e27Ee9fFVJ
UWIV7ygTi93L3xWec10HasRuR358Fu9mUIwkxIh6Y+EfVNJO4LVqkDqOK3tkPbI-wxjHqGGA
-chNl5QxBXhcrTRaE+PZdjwCwD8PI2a4GE-xfHAIWcznB2yZ+TcRIa2VREU1BYL6epOdQZ+Z
vdcTFLZe1lPAnPsPwm9157JpNqDDosQNT4kDVaB5QNP6-vLzfCcORp7ldZtFIBqCh1pFJEA5
LJwb+Iw5OnPC6ZENzZQAeUr4wSRUvdbvoQrh5NI-2DPWW+bOdkQ2Yu2LTdajjiBlc+wew6vT
FVIDPsRXwrH98RpZzg9qNhkzf4NmZxfU3HXcwUObv9kLBQ7hPR0We+i7vUOLvfCHGeGDGeXn
b0E9Oi9ZpeIui2nRC3m3ckZJG2qYOUzcOUyud5G54ZhdGtw8PJ0gAzQcC1BpX1x+HRzwvMJJ
bSAsnyp-QvjNy+JEGkA23++0++U+VN9W6jg+iKCa+E+++UA++-6+++-2An7TAmxHG232F2JB
Hmt2HoNJIhhmqX+ITDSAzm3To627HRDdy+3WIaWUi526PHBt2D6db2F65ZpmuRRL8oB0LxOv
SsuYcvLi9gmiNILqDgy4FHzDFYIjnmv+Gg+MwV9k3L60a+8y+OtEa65BkPu19E+Js+SwOo+B
i+2g+PScfg-yUjo0ykpKPwrnV9Jr-v2GJfDS79rIv6S8VGBLf3XTj9MROQmnyl8zZHLmrGXL
r5KAmX32Jxq9gPIRnvAwitilTYk-n2Jv4PD+C6jUqy+LukSLwX1O4IL1hYr-o1dgdjeDEKbC
ijN0DhPwZsfyqSbt+Diw55axkTb5HqQlhdrMo0WCLknubkSbjRUsTe4Gb9HQSXOuGBCIP2Zu
MtbQzK4Cu-JR+ASu7a5ZhV7y4oIJnsjvim7Bqn+q3+cmXJiPM0L3RL0KXhvOSybEGZWl6owK
Nps5bHFO7wPtS4r3IfmDS-jvcXV--f3zeeI81ILr2AckS-DRIK1Jd712Uv4lbZs8usvXQN+W
--9dKqwO3uGmR3GjKt6gJ3TU7y4HKwtaylgQnrFmFOys05varWzu5x78okHdzzDy+J-9+kEI
++6+0++X0vQWdUgbisc+++19++++2U+++2EnAZwn9pB6EIF2FIpD9YFEIWgcmYwjGglJ0At6
H2Z7nQqrtiLWtGchHWratJ7EQAgjmWrK+P4Uoj28aLY8uX0CLY3WgPd0BIWJMGpMMvJ8Y68K
Ld-fQ0q6ZtGObdY5oipMI70HaNlMYdaTdlSGKN8Hea-Z0nQaLxoOLMpnIKdWGGf6L6oEgCYu
M8QMOa8c10fB+seZteLcwL6-+3-9+kEI++6+0+-7Yi6WD1wczk+-++-Q+E++2U+++2EnAZwn
9pB6EIF2FIpD9YFGFZqDDIs1AF03LuUEpEfF64qFWUNF69V+hDbF8UG01+cJm8nBfWLzf4kH
GAYFi+35EAc3cAelkdWY+IhjxCbBn7A5+9eYxLeXzqyr+tnzxjQkFEw3lZF548127MOsqgtp
zutxdL76uimnVUgVXIBqmVdlkFyZ-ZNg2O6ok-h-OJJ2hYBo4tICmAQnNMJv6HePm--s9ECm
yo9n2-8h0aR179WyKPGZTO9cst5bPOAeAcyc4vqX50m5nVimDeRSqGUx-QscafLCOKHnWPHD
N5qLlW+9jGeeiPl1TZ+sMufcOSGXfvVqBIKw1ptXEFuVM33gA0zviYuzH-i2kAbqqcRozkxE
GkA23++0++U+Io0k6aYGbk-Q+E++P+A++-6+++-2An7TAmxHG232F2JBHmtGFJCZIv3Ckn+E
DHR6IFNG75MmAbNfBY-A1A+jgB2l2cCnMOZGbP4fZMLTW99YIncmFieG6SdltxGhIwf2CQzK
SrQLCwsR+2-0E-lkOhwHtkw6kafHOLHVz9Tvz5i0U9owUHxAqESI4VMS9B5IB+rjMVwyW3ps
q5DF35NmhR8RTCjGSEOK9lPjbJF5zVyzR7MlZt+LP6vfLruEO0A8awwjZ8UDTjil7CG3nfPu
My+g35aQtb6CHd-eepLc+YUUBqrf+c0mZo2EOVSEdPaBalqiJ3ml5OzMJ1GAnuimeUso8ejO
pAPXdXH4tmJ55DCNavL5HJKLrWyBnAVB4xNXHU5X6cXAGJKQwjKNmhY+lCR+fg0-8WVgGSg7
***** END OF BLOCK 4 *****



*XX3402-021396-050897--72--85-42690----SHDLABEL.ZIP--5-OF--5
L15MW0Kq690TT42ThvXXKae0+Qd12l7WlAoBMYjcvV-r-4Fw2j0OBdXNofm2NrW+7rUVDA6f
fQvwji-i27+YIxgJr2I0TU-EGkA23++0++U+Gd9W6hORuZ1B-k++y-Y++-6+++-2An7TAmxH
G232F2JBHmtHJ38ZKBZmr2EIPH7Sgy2sNImqWU9MnY8Qg3OF3n-766NgtP+IXz6gbebAJd7a
58Ts-1u01y21y+EyUmRq0CSSjWqpd93Z0fYwYfdjxxrCLJf44-DUzwI9ypywtZtmwnDszyJZ
4PitYApDaxgaAN5daahamanUbi+dk4XLRAnEP7i-0H5Tk3U1nooHsuaDdkHrq6l+AwFPlDRB
IwRn5yD9taCgHoXRkIU18tzVSM+J0Swhz2PMiqxqA5T1DA-j5vC-KHAfK9T4ZP6yV0kFNYDg
gcTrPHlri0s+TMmr-YTrG4hZOqAokbi9gjJApTK1wSroOwZCIx1beLY0LKja0r1NljoiSBRV
kPjUaN1TB0Z0X1OlsX2Yz-9jxiYCe4eYPK1Y5iHeYScyTZhMTsGooqM9iip+zUFnRo0pmrKP
h4cB6opMMkNwqe-foJhJpz2Q-bsfuHOfjid-wW4sn7ejuTCyKZYoXD+bZXl4GNlJEuneoCCn
EAm+AlrCH7ZJwkrFIgDHEwkRAMzAtt1wBbpIdlvHa9j5dm3aJc4zPQKGj4pVFf0tVxpLkLS5
jcpchJJWhKiCMixJX+OUZ3wvSUmwJlKfzbXpBHTZqyfrYerSw4kFE+i9mmH3suuWLTkK2DJX
X6WqUQN4kYV6n9bzh3ARocTE7sOzfEJR16cjuck1EPzkZ8UFV5MpAWk5qKrAiMvCtLZQIUwa
Z8aPWwAqSRis1sXkWB4O3DOsI7-BABcU7lYB2CBrs2T79X9HdLGT87Oi3BPKmRJaVw-wJN0w
kzoSsJQWkRf6uWZXxtHjgdRJ1dC3HVTcMoNpcbNAe4iRyns-nPOtnVVqx5tahD8tqMzAdvGe
NAhBHstuHiBhOhMZPWpmqqerY3OD32o1xPPDKqHgkJQmDcbLSmLfCfkpjGmtXiS5x95nZ7il
u6cIlmAWpm8UerarHimCALcJoNOVrO4dLY-4GBd+esHYU-PrWRClDB6K0lcou9QRhMuHQtsS
H11K6g92ZcjAiioovnGcLt3eqehSpJSvtiS7DmPYWPIoThN8u-07lulf5IdHNnIMYfi9enva
lQALpNcizfANKPYmgI88lsKXKD2Jcg1bBeFDVcfhjJGK2IOK1Y2x74vOW695dPZmXt17gXG-
rhf3mLuR3V-29SSmcthriJ4oLiTj9Lov-mhNvwPAy3bhxzCMbnB5X6oniRcbwjG6eaP7NtZB
ZZCY56tyeMGqzKYj5NU3PJwHA-AytxB+cwP8MeIuXouWLyXBacenQZTbpz7ZN2wzAwPkF8mt
lLcVdiIWhPH9xqCBqv9rExNRJkoZMbTJWuR8GBhAPLZT2JBxzNW9knx9QLWqM2wPElrq2XMC
JvkikPojJKF9toKVDJqUhTXiZyVCcKMYiYzDkrH+O9-6LmnEvC8tcpkneag39zLcbk2v7JbH
HjZ8v+odLFMvSSfMsrRJBJbHidvlnelHXhEm9j8v9j6gsL9LGUsRKFmKwouQgsGDoWJqVbaC
yypv6QLGEFr+RYcjipn4PUro6s4rhgvw63KictbfA1hQmCpU8N71fVIjqomNRRaHsgfpS5rO
n6xqOo5bxut8ge6M8stLFuzYYmunX6q2q9mSJjfxehTVOZHpxLDiTDNL8Qvbq9SAWSphKaqC
NuKuBp7XpmObeESIJItmIjBeCCy6dD9SlYUBDObMFyV1bYKSe5x0G1uXeyrPfCsFuziwvhLr
liNormURaJ2CPhvm4H2XmoXpxJDC5byLv32nbq4z9isPiCxEZmNDfszMeRLILXKpoWncErOH
6HD150FgkatFCX6BjID4KljD4yk9CiHkU17DYKCTdnD9KzGor2Towvn8Y5UyaJJt-jdSRLpr
lBTvbt9StmhCJKDeo84iWTOo2SJTlVYXDpTgqTctyYgZyanig9Za0R6yoqw5TIO6XMiuqgZ3
zEf43a19C1qFi7YKJbLod9TA54drOyZLWDqypEXxUYPaNRvTp3nEprkeCSV1w8lffMxdjEuv
SHwXVOdvUzKxaSPtcLQ84X-vq7fYif5pB1Cs5eOwkpZ2YynlXbYP6tZbNKr+wufMy7P8iquC
dfpUY3itUQvHbaN4v-6bquyaAJ-HvBQIwHJ3ioBuHN3SRLqPuopSZ9-uNY8jDO1IWLux4dEe
E9aPxow4Ida4XCSE2LTnTzbjA-sumKcWK5h8if4WnpOB2sJj0hTlPfw87B1YAOBbfDPToKdV
nxo7AozaeFJ4GXYisbpEtadCYidWgK2vgEp4EZP9r5sNkht8jojMDTljYbbvNpxLL-qoCzfT
K8FjhzZ-Qa3DeyEtDKgLlvCHGqiW1-R940VaBMQ1RkerLcZJnnCJuwisSuqIvLcwovFdRRgT
GOwE5tVldhWt0Mua2NyijvlGg9J3q6XTcUAWmNtzchkrYLS-vUzAyyYN8R7j23PHeijvL-ol
0wLMD53+XroQxfi-SPwbhlbc71FljLSt3pocqRqR23mrR-eRkc0Mu359jMbb0TaWYT27Ql5S
64p5uw3KSgOEufebTIh+aYOeaxhr5fq+p9mbaWb3byKyj8x6XFUx3jZ1qae-uxorFVhFxejw
Qx6D25ZPraaqnhCgnFmN7FTG8fOHNg3wJUYaq9592qpKtvBACUbB3q4zUpMo8jFMfZVTZDXJ
0jeFRUjNWeffLp-9+E6I+-E++U+++Da+-GA++++++++++++++++2++++++++++++A+++++++
++-2AHMjI2g-+VE+3++0++U+FMWk6eTvn+JY+U++LUI++-+++++++++++++U++++6U+++2El
BWxHG232F2JBLmt2FYpEGk203++I++6+0+0Gg8wWKDpwhWg0+++k-E++2++++++++++++0++
++0o+U++F12q9pB6EIF2FIpT9Z--Ip-9+E6I+-E++U+6+4K--GDV4pcqj++++-Y-+++E++++
++++++++6+++++o3++-2AHMjIoV-F2F3HIwiF3-GI2g-+VE+3++0++U+Io0k6d7WFZJ6+E++
4UA++-+++++++++++++U++++xkI++2ElBWxHG232F2JBHmtGFJBEGk203++I++6+0+1Oc8wW
gEFvM6Q+++0U+E++2++++++++++++0++++-h-k++F12q9pB6F2l-EYJA9YF1IZ-9+E6I+-E+
+U+6+4c9-0DhJ+Rd1VY++-+q+++E++++++++++++6++++066++-2AHMjIoV2H230FIkiF2BJ
I2g-+VE+3++0+++++s236k++++++++++++++++M++++++++++++k++++LW2++2EnAZwn9p-9
+E6I+-E++U+6+6FVi08-RY4TbE+++CE-+++G++++++++++++6++++66V++-2An7TAmxHG2FA
EI73H0t2Ep7EGk203++I++6+0+-lfzIW6ZJ5ZEAH++0m8+++2U+++++++++++0++++-D6U++
F1AmLnAjIoV2H230FIkiF2BJI2g-+VE+3++0++U+GN9W6UoboNi2-E++dUc++-6+++++++++
+++U++++UXI++2EnAZwn9pB6EIF2FIpT9YF1JJ-9+E6I+-E++U+6+2SGsW8OyYZw2EE++9A8
+++G++++++++++++6++++1Mv++-2An7TAmxHG232F2JBLmt2FYpEGk203++I++6+0++qYi6W
cKVcoHE0++-3-E++2U+++++++++++0++++-rDk++F1AmLnAjIoV-F2F3HJwiI23HI2g-+VE+
3++0++U+VN9W6jg+iKCa+E+++UA++-6++++++++++++U++++qo2++2EnAZwn9pB6EIF2FIpD
9YFDFZ-9+E6I+-E++U+6+0A9hm8a0mSvWU+++Ag++++G++++++++++++6++++931++-2An7T
AmxHG232F2JBHmt2I37EGk203++I++6+0+-7Yi6WD1wczk+-++-Q+E++2U+++++++++++0++
++-fF+++F1AmLnAjIoV-F2F3HIwiF374I2g-+VE+3++0++U+Io0k6aYGbk-Q+E++P+A++-6+
+++++++++++U++++aoI++2EnAZwn9pB6EIF2FIpD9Z73Ip-9+E6I+-E++U+6+2eGsW9KbSdE
nEQ++DUN+++G++++++++++++6++++0R5++-2An7TAmxHG232F2JBHmtHJ37EGkI4+++++-6+
2U-O-+++72w+++++
***** END OF BLOCK 5 *****


