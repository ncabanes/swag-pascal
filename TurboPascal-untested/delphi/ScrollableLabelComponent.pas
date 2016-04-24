(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0334.PAS
  Description: Scrollable Label Component
  Author: ENDRE I. SIMAY
  Date: 08-30-97  10:09
*)

unit ScrolLbl;
(********************************************************************
  TScrollLabel Component FOR Delphi.

  It Is A "Special" Label-Component Developed For
  Allow To Scroll A Single Lined Caption Text
  Of A Label.
  For Correct Function You Should Be Switch The
  AutoSize Property To False After Building Your Form.

  Author:  Endre I. Simay;
           Budapest, HUNGARY; 1997.

  Freeware: Feel Free TO Use AND Improve, But Mention The Source

  This Source Is Compatible With Both DELPHI 1.0 & DELPHI 3.0
*********************************************************************)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes,
  Graphics, Controls, ExtCtrls, StdCtrls;

type
  TScrlDir=(sdLeft,sdRight);

type
  TScrollLabel = class(TCustomLabel)
  private
    { Private declarations }
    FRunned,
    FRunTxt:String;
    FTimer:TTimer;
    FInterval:Word;
    FRunning:Boolean;
    FTxtScroll:TScrlDir;
    FBigO,
    FMaxChar:Integer;
    procedure SetScrlDir(Sd:TScrlDir);
    function GetRunTxt:String;
    procedure SetRunTxt(S:String);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShiftLabelText(Sender: TObject);
    function GetInterval:Word;
    procedure SetInterval(W:Word);
    function GetRunning:Boolean;
    procedure SetRunning(R:Boolean);
    procedure TxtRestore;
  published
    { Published declarations }
    property ScrollDirection: TScrlDir read FTxtScroll write SetScrlDir;
    property RunText: String read GetRunTxt write SetRunTxt ;
    property Interval: Word read GetInterval write SetInterval Default 200;
    property Running: Boolean read GetRunning write SetRunning Default False;
    property Align;
    property Alignment;
    property AutoSize;
    property Color;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Transparent;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
 end;

procedure Register;

implementation

constructor TScrollLabel.Create;
 begin
  Inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  Caption:=FRunTxt;
  FTimer:=TTimer.Create(Self);
  FInterval:=200;
  FTxtScroll:=sdLeft;
  Alignment:=taCenter;
  AutoSize:=True;
  ParentFont:=False;
  Transparent:=False;
  WordWrap:=False;
  With Font do
   begin
    Color:=clBlack;
    Name:='Arial';
    Pitch:=fpDefault;
    Size:=10;
    Style:=[fsBold];
   end;
  FBigO:=Canvas.TextWidth('OWQTEKSZY\')div 10;
  If FTimer<>NIL then
   begin
    FTimer.OnTimer := ShiftLabelText;
    FTimer.Interval := FInterval;
    FTimer.Enabled :=FRunning;
   end;
 end;

destructor TScrollLabel.Destroy;
 begin
  FTimer.Free;
  inherited Destroy;
 end;

procedure TScrollLabel.SetScrlDir(Sd:TScrlDir);
 begin
  FTxtScroll:=Sd;
 end;

procedure TScrollLabel.SetInterval(W:Word);
 begin
  FInterval:=W;
  FTimer.Interval := FInterval;
 end;

function TScrollLabel.GetInterval:Word;
 begin
  Result:=FInterval;
 end;

procedure TScrollLabel.SetRunning(R:Boolean);
  begin
   FRunning:=R;
   FTimer.Enabled:=FRunning;
   if not R then TxtRestore;
  end;

function TScrollLabel.GetRunning:Boolean;
  begin
   Result:=FRunning;
  end;

procedure TScrollLabel.SetRunTxt(S:String);
 begin
  FRunned:=S;
  FRunTxt:=S;
  Caption:=FRunTxt;
 end;

function TScrollLabel.GetRunTxt:String;
 begin
  Result:=FRunTxt;
 end;

procedure TScrollLabel.ShiftLabelText(Sender: TObject) ;
   var
    TxtL:integer;
    Pc:PChar;
   begin
    FBigO:=Canvas.TextWidth('OWQTEKSZY\')div 10;
    FMaxChar:=Width div FBigO;
    TxtL:=Length(FRunned);
    Case FTxtScroll of
    sdLeft:
     begin
      FRunned:=FRunned+FRunned[1]+#0;
      Pc:=@FRunned[2];
      FRunned:=StrPas(Pc);
     end;
    sdRight:
     begin
      FRunned:=FRunned[TxtL]+FRunned;
     {$IFDEF WIN32}
      SetLength (FRunned,TxtL);
     {$ELSE}
      FRunned[0]:=Chr(TxtL);
     {$ENDIF}
     end;
    end;
{Set the textlength to scrolling region of label}
    if (TxtL*FBigO) > (FMaxChar * FBigO)
     then
      Caption:=Copy(FRunned,1,FMaxChar-1)
     else
      Caption:=FRunned;
  end;

procedure TScrollLabel.TxtRestore;
 begin
  FRunned:=FRunTxt;
  Caption:=FRunned;
 end;

 {This allows font changes to be detected so the label might be adjusted}
procedure TScrollLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  FBigO:=Canvas.TextWidth('OWQTEKSZY\')div 10;
end;

procedure Register;
begin
  RegisterComponents('MyComps', [TScrollLabel]);
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



*XX3402-008723-050897--72--85-62167----SCROLLBL.ZIP--1-OF--2
I2g1--E++U+++Cm+-GA++++++++++++++++2++++F12q9p-9+kEI++6+0++RirgWbrbJXtY+
++0S+E++2++++2ElBWxHEp7DH2l0H0t2Ep7pHvgCkm+EAuJGpckRArN2MgXQJhqE6fLxY2Xw
+4AzWnyXxm+o4T0-nv7wsWUbTBuDpl70iBqT+Kvw4i+8s38jkFaAmS0+gOYY-mZdsq898CRA
Hd41IfFlgILYir0qgMBeOcuTIvNvjQwQNfg+71t6YbZ4xB92fm4mpY5peUztCZ1XAi1ODl0r
C+pMh+pcmvXd4TxjpkKuy+3EGkA23++0++U+OEg26tHUZPg52+++o-w++-++++-2AHMjIoBG
HolAEYkiF2BJnJZxQ3HLRHzrvRirPxxeVMH2But-UAlb1ENQBy-86-10c06Ec1I66c3KO94o
IZMfUFlLsYi+29VUX6kd6XWqgNcllbLgVBP4rXXM-i64dmqCNnlZmBTIsvWiAoo4Ec5hvxnv
RjShl2nwJuRWvdtvnjrRQwwxxxmDwpVEh4c4sSyLJ2KbTFAmLfHznT+jx0zlZqGytTeXGLFK
NwkjnC41ZqitsaILTSqzxbvwSa47W2VkZYOoCAbxgVzq52NyLxlRvny6DK8KrLPQUPZ5IzFS
QGAdRNjZ4mCBxIgrp-AxxC-px4KVIRvK5+oq2Ar8h0+E2hTKj0cOeawa8flpfvWiV-KVwAeq
dW02KuhakTm2g0nGi-50zveyKBmfV8L-tiPeHMmQLvMStf5EIpFTrRnAgXxw2V493L-Fd9ed
9gGxTrBpXpWjV2KBsGXAVD1IySBkYVEir-chWYNMq5aGtunAXBPMkaxxnhC5dNet2dCgLl08
T08yVBpN8+bTAK4daHJ4wZm5p4WiKFegXGdCsXnBBGh0ayeWGULzOFYfdSzeZpNj0BPDp9uY
PD7CouKPZqjQoJgeMwDaH57tjehlOsiqFugmnsY+N2GzXxj96rwnOP6brrr6b4pSxSlkLnNS
xl1hx-GjO+a5UnJa1rHpOawFnpJ7JquBaXpWiTPxVBEcLVZe02PA5aqtRY2vbRj5Eazlsb+o
44ahfXSDELtB8l2GP2f3cT+awnX2pvIb6BuXvPG8cJNBnil3EtO9drp-qyYibVzOhAkw+RZs
3lNFN9aUcvFuOp3RRQEw0T2Q8GPONNI5cvPPgwogqDqOZwXXtlbLidHfdGxvhJrSFQ4caYeq
CFn6bpU7N9R9nEfujCIdo-W+HWF-PxXe40deLPjwFOL3W-SM3BsIfAbCa+VoYmxnY29zmYOT
4fJ8i6ZocmUGf6s4NkmT1hV4vpFPeOIfK8MJEUldiaR-g-YVq9Nwy2D+5T5SWWjQB9L2BASZ
NtPLVKeXAVdK-hbAEW-j7wqgh1IO4gkQvx7xa5JWJP9B2a1xGSlCLGrEfk+fRw98+9iKRCEN
KmK1lHJBhtEXSI4nnE0UxIaBJzEbd2N9pupm-uc8e66YWhl86KB37O-kxkdAj12Gn1Pf+0rr
7O1tPXLlvqjyEGdIgB9-XR3EMpXkkUPQjJcwDgSZhghmXPO-P3Cay1qwYj0Fs1LPsOs3efgT
oWiRunQHQlQwmRDiGjp9S0Q3jQ-f7GqLGbZGUerziTgAI3ToB8LYYvvpiyTJVnO3lNSNVoLQ
DMrWwLwTSJUsQFYcDrTvjF9L2+l5lEkh78MMHk3vn5gi1SiL6SUrtvJ24wh1XkTZw8iBks-y
s6+8iPa7Hfjxve94ygO6O-1hchps09UTXHcgDVplK11iNXkS5kHQ3ADjKFWirZ+Tf72Oysn7
ECOCDdmaAEgZsDPf5D10bxIi9Vin+0g+H-yd396ngz2HRzhxNRIFH2MBnodj4pC-nfsbLSZU
4JdyGu4ZOUNDxYk-i9+TC2RiIrya+dTLBKsd0RYRpbcKgvzuRQXZewzkaqbErNsGEAC+HbKM
DEEzhkqzPqKYChnQ7+SEuBQxHT1gS0hx6MOWvDPsDOh1nG4sHG8jSWN-vuUzGnRV4AdO67S3
Wyd14lwHtpoVMNeD+wb34ML1wRBby8pZsEIPuZDUqSMC+5To+szUIxvoytO3GlhPacA94fS2
lReQkq8XyEWEXzF1XwHDOWC79apg1Mez+zeEiE963TrEcz0noTFvPTGe7eaNO+pkOzdVFwiB
eNgfUdh0iAQXkak0zvnQijfzekS66Lxrw3sbZn3jqNNkA16qEtvFTD+qS3puSP0yRdsVFLn5
eVvTIHoGXLlM7lfTwjunOhH8OwNOC7QHZrcGDGRBpIq33VI+vsESDaMyHsqvou3ugXLAGVir
oatYsr3AhhF5lNpsdOq2Smmq5ZIxl+ecjs6KREcbBJlleCymKhDJblacDVszMmhFpdyppNSD
dLUrtgLbONyJpB1haCdbpdJoxPKizifRZVGm2cDixwrrXTNtTBlQ5UnLM4IgSRrl-SNEAmpZ
dMvfMWZQk09p15-dNFj3HGasYHFubGzB1ftoIihlI1Juv+TX-2jSvrlPDyt9RbYXPEYHTnUt
tJj87DKMaqX9+nMhgqaHj+S6VZCqd4BgSNIwmz2EhjbdBWqlOO3BuqmuJPvTwj59sluU4t7y
dXI7dWT3Fl6p4zfNYV5+gSP7C9ELmJ3Bei0L+ymchTYhc6yVhVhoD51DU4sLSyaIXTgdu-8o
LtJu7l7vjNuGnrKH5AxobFnDQwLMnz6AQXn5gmXp17xCXiTrJ56wiwSHsvYxaVnDv-eFH04k
m-xbzWsjcvlclP8ZGyQjzTCmSSLgULyHirQJj9oOTITb1AsNtn4w4TXnYqwE0CJZo6XQ6HGA
Bn7oIVE4KsDwUrWfhc3zb3lYyLHSX5lcRL0n9pjbfPM9T0SOAroSrYlRMDQVcWnTs0mRxwd-
0+udRhsBFw1qc1pzq9+QbMDxC+Gxf5ucnZ5u549UFJUt84yEtROd70hDoyKmmN+N-OzYu-mk
vs9vANglAYTbO9k6k0Lagz7oDVgjMn2ysa2HVlsTcNlrXAF446b1RGGCkrhcXnO4SfKlS2LZ
sLoxXetdsyauBc4mLDYorbITnee7q78Hg72b6yWbk75HQRfBk8Nv+8TDH-lDgr-AnAMtwW1q
oJzUJTMBj+Tao+vrL9ko5gMXtexkwFTUBJ46mqMS9hvtiAy8u98l+1TfEWEPlPU73l5TjuzX
ifveSEFLq-8OPGv3RJB8VwmzlZ4z5CCicUMjXxoAaxdkmYv2qCroiLQKvBW3wPhkq1o6Kkv0
pWDINoq4rQRVtrDYwHq+kyFtaixv+HOyWrZQdARxIu1rAcLxEuXLCstyXLbfvjgcP1s+TWP8
9AVacnm6yZnEVqalzX-paCh-jsZGVJ7BsuoKh9SXv+8a0yIUR1k5LQzHDCA34iTicmKi5p0D
ulnwDtEyiCwJGFDZuJ3HI0v8yYrAPtSqXYe9TUNy45obdsNqi4fcetkU1QihdJlj9FLYPe9O
r1du18zVtmRgFXa3we52XwPupBoTc7xu+qHQxmXJZfK0DYjfdfw2SUvZ5NHr79MrBkxZ1HIA
LIANklfc3oD1xACVXO1PETR9n3Hn5heQII234RJo84AnmWaI1l312p+acbk1AQHfIc2GE-kx
WXVOUyho1K7d9S8c2f3KWTJTVzJTXzLy7hOt0iiz+T4p4RX5I-ekFUqUMTE7UnMW-ViVhlbp
3h+qXBA4LRz4abwPT1hkqv1iqx0y5TLhYCr0pPUPxRqcRu3zBq8V4yrvIRyDyU4gyk4o5QER
xlFYHu3y-95z1C9Y4RVx3DEcu9CE5wR3RE9p2uUz-nhDMFyw-DcGMeUDTTdUmxxXLhx1zKL2
p4ZE9eyUzUfqpOicjkPgOu+z+CLm7jez0HpjEbMCx-ncCx1z9iVtX5ISx1rk3s5v2DFbGAOL
sHbJEFgcF3CmZgXxuodyFoVyCd-j4DKh6D4-65IRTJSXzwCzh8wFm3gtVm-DaXHt1eDYYHp2
0XVHGov7nhDu7rLCgJ6s9mJGiM5h8XJ97b-rJM-HAt4qAHSByVa0iocZOplzOY0fbp6d4jC5
ol+etIcaNideXwSHJhWtZYf5G3vBzPjXRfGHA-PBGiih2WiNSX2zRI1bkSFAi3UwNE+aVlld
3YgL1s1YIfzYGfp7ydgmV2kbM80fVt6nYK97d+3X1OB2yYHmqYpZF6Zw872omMSv6kZ8d20C
J6aZngkbYTQs2mEKCzCRF9PXH6hMvAln2ZZC8VZmnsi2eiihNFL9JmtQIfvaoQdJLPwtexAl
-izwEhzKPZ5IrDa38ELlpglsOwOAKBbtRgCcQ6UYbrzysTnsifacPzyUFlUJHd+NPnJS3KJb
WTs7JdR78RfnindvhDmi6oSpz+wuXqYL8DzxnZuBBahqlwoWdKEnzSYuennzBvCuqazh9vun
4Iqqz-q2AymttSWGf3iCiYXJvGvERqtTEgqnzqXFxHweioxcyRpgj8zne-ORPpE+XxaJqJpu
B6R3wHSCOTpZyneDOqJCcTGotqzl9hxtriUiBfdLalQjKMHZa-39nGq3Hpg3qRYhelQj4MtC
yschvfQLLYpju3MBLT1u+Dhgt3Yh2EMOEvg-vGeyoppwty6ZzKt15BTiDegK8qLcrJJnhvr3
wLr3QJjpKF8mTTgL7DPzutAzrjzdfEBjIzmxJijZvlqOzdzzzQ8Hbn6zh2634xOb9esoCgIW
7Pt9I3uwN8NvBk4kIhrM5ATS2B6qEvBhAvGj2mE9wtvBjrsChOvCYymV5dfyOzUFhJth9fIw
QS1havQR2v3bQTCCZ+5p18bhYcd8Vw4IBgLw+tp5OTyvLQIripPTIXfWfPTWfHTjriCrWyO8
ZW83kv8WrLJ14ZWKXfxvvrqm-xOxVpFsM5PLLnmVRJy+9ZaPwuDqeQaNeAtmEohgGL6ESs1T
tWFFLqCF-YtyMBSohIhdkLYJPrL2t7xSF9P0IxdKpBXEp7lyDgeyuZHf8fvJhTfCUTNPEmgq
qx5n2zgauMWd0ugXlcblIZ1CWoNH7BMbvwN6v3KNiUJWRFfTb63MYwONMm0qHSDYCl1P0vcG
x814GLYURZ9XOnAEyoXXanYEykGo2jEOu3lEt2x6mUCl8h+Oo8oiHfvFrwJdPm1Kty7YjW1q
WQ4tOo4AD7mY3wFAo+KUKFuy8+hWNM9Hus7MZN+T-K6HrNnwIqmAaqzLG8l2DXEu0fomdKTO
GEPalqZv3zVgSzuaT3-2MdDYtOvwAEsoGpvh3DjAnSZtFsmz4Ws1tEw9m6-X7xqQpbT6QFd-
yIA2ohnMet1j-wwT8+u0Jc2yXLYh-bqNzE1uCinaQGtVLDvkw0xqjmz+wqSxrxAGqSsLUNW7
mV-ELcQFEi4aU-wCyIml79ORDly+5kCy5-F9HVIqfUtw0SFBBfwTDDjhONgz+tvxxoCPzlVw
+DlJo-VbhvPwicX6STkD8BzHQJgyGgDu+HxC8sXlVx6tBZo9COTsvO1PtOhNwSxfu0TICbqa
wpgZ6irZi8W1j7e0VRSYDsDPa2Mc8CStlTPHARgzdoXBsnJGxfkBiZTuQobgcAn8CkfNXjw+
nr5wCp1qrqpE5gw9jz5wVUX44HEGz2C6iobUyMDE6u7X4xBG2MnlEucGx+NzN+9xWfxB00fY
zr6u7BFw28elCjVX0CmOXc18+zyJnYzTJ9iWGYySnLgQwezgiCBtninLndHbzNQq9PDxhR4V
jobiKwLbMjvJAWZEwtf8xgaDN6VPYhxLd9yu7At5HxfwMJjD0yG9-R1jDNjzqCvr-ljb2YeS
0wfyLmCIDHIqPFDdRcqlvIrA8ljfRFHmgFXzKz7nav7nhhoy0D6qyL9h81HZj1fYzn9RWrpn
2gusDzYGzZxEGkA23++0++++ws+36k++++++++++++++++M+++-2An7TAmxEGkA23++0++U+
E7au6cCXID4a++++s+2++-6+++-2An7TAmxHEp7DH2l0H0t2Ep7pHvgC+W2E5AHWv8uojB8G
V6NKXNq7WTd-71Fy3by4yk0wAq4LrNbgnFs1+0lIdKXxlwQ+EPvjwAM9Jnnlk3rmX+hiV0rQ
***** END OF BLOCK 1 *****



*XX3402-008723-050897--72--85-27584----SCROLLBL.ZIP--2-OF--2
TBUrTe6upX9EwK8qztsvWr6Eck6bYNkn6Iy851Mck0Zy0zkkbCrREHa-syioqnJTOnOvkk-2
DcaGSo1m+X8j6Vf3GLbIWrlRe57NQDoRG2pC0lPR+PZAXETwbZoB1CA9I2g1--E++U+6+54j
xG7hSKMFIks++DQQ+++G++++F1AmLnAjIoBGHolAEYkiF2BJlJVvI3jLaHzbEsy996FAV+m2
I226GlWUWgBsMWzi+C7VIhsGdbuZiIVLsWN0IeG9PH979WpyUMPR74sSHhgoqqabgngN7opr
hUtBdxr+q4aaav7CBgpiAXjHzB3BBsxuDQHqSXlWjrDijR8J65yja5DjyLvTwrnbTCSQGwSd
oSvfpMEwwj6LRLiqfRwYnt02rFxAleDFmKVfEYmxRCG9CV6Gz2f6dmGXeIgpkMOkDS0PGGbl
uE3lIcdSwGuJFodOXR-juDZzXpEOYRMyGS4RU5FQyTAPbxpNk-u88r7M1ce856xlRZYSSoGI
MudOFFviZtHC4GLiZlyJhX18i32t2diKBCLP0oA87AJM8W2ahlPkPlOs9Iz+ZtF2FRcufcZs
AXGF3-CQKtKjBhUPXmay8H2KYI8A5kk7DQSJL5shUM+w9GJTcPsR2KifGWlQ1bsE8J5vFgTP
BEVR1gRsJwhT3iuD8J9me-Uh3Cy7WNDFP++y1+ZbbEQEQTU4jxYvD-HkvSgQuijdfbVyvRwW
Ck8OG4ir3-NbcgcyAFO8OiseXIkt7coYskYdeQVGGgyClgOYyu6mdbAs8IRYROvRavZXIZ+d
A6mwPiac57EMc8yWDBLid-XdblMXahCm94xA2YByFQyM8sjvJNr-S2Ueo21CG4vKbINwG7mK
0h07K+U55BFLW6Pqln1dQYVrunG2YwWitnmLLT4NK2UBjXG9XmRo2vUiy5fyzOZI+WTGcAVV
PLsBg0wSXGQ9whGTseVTWGTJiHR2b9wcwcTBZWl5mkqa44Wkh4BnzfM86QjAqenOnDBDlMzh
ovCIBqJtb2d1B1fXmwOqLov7C1WSmaq-kTVAGictWevSyil56y3G3FWA5pL-ypj4TsJG2r7A
gr-yyz9byGb7vaIv+bpMuJBmA3Q28LnDOeKZATLOtWatzflrAakCg+nwx51DfcW1RzAbnFeA
RYL3sAD1rHyqMSbf+hY3aBANYNLU3-yLXKCQTaP3RHtG52tctTdtR44zkIdqnwlNwGinKbNI
8tmy48ww5v42IprlO8WawazqglIasgdChP9VHwUVNIcRdhIL3JAdGFqZ1IQtbMX5A74zyAdD
H5lNObHfE3kAORBHOM1rOwIm7gLo+NMPq-B7KN3mFJlhMDb3gCEHcx4Sso2dYHp-L62F8NaG
IkcHuImZg260QOraBb4oIKSDWqhrjvULXnZy9ArmxT1XYewDFEF3x2ZgClptlzL5GBaM343K
YhZEIajzYCn14FyIIWaq1rrqwAbbko7+6qAjV5MU2tQIqmosImI1gkZ77zqneL33Xb6mMj2f
mF2lJRryxgwlkQXeXwa88aV-Gd4aiERPNmkZcuUQWtmcqhQRBf51tpP5lLw7KvjWwOUYlgFz
5jzvg7KR--2dyS+L+my49ENtOq-swW5QQHxuebMlMisJcmbdhMTS4gLeIT5K6SZMTmmZW94U
jcJeXBuY7CJlH65YX9HAZCoRT24cFxLp5xl+l8X3dIhI4OpQiB0qXU4Af1AI4dD05--I6-Il
I9tcwWyyypF5lB4V5Y8xQUnbLnJEn0I4B6KkSEEDqiHPpfC56dM-8FNFdUXyB1g613zMglel
XwTYFqMYBGLQQX5KUo5QkQKn45RYwgIHgtmfiaEYNtFkgXQNbqOi2lSyYdIEZG31X2XSmwXU
LNNIO2+88siTr-VyfdaEiumdo7UQaJ6KDyI+B+Y-j7B3iyLYaPD15zmtiE5jKycZXRwctcPd
HzufZHHNXS0NcxtHRrcxo5dDS0RdjAr6oisDQqkCm8VtiuahpiGLca4rppN9Kxqv99KKni3X
AGbdRUgS-7l0gB4JNo0PARL0kLi2f+3-BF-gr72bnrMLRE0eWWCbEKf-5r6rEv0lcZ-3jvac
CZuX1dpkSnOdx-KeC8gxKFKDNIl8sHvcxd+hcViPWQJkvZKpgPnlX9bfBcqbfo11IJqrqJ2R
Cb7jsGVkL34pDgntgRFGTvXaFe30Lvt0QrJBJi3CrIoBngvhyKuat51iieqezg3gR4PlGv2E
nawXS2lcTQ-R9rVU7CVigVKC39bcVtqcedrSWdmNM4BJzf6mLalJwHa1pnefhV4uer5e-5rr
b4ApE9vVP+gqqbYVmszmvk+Jbufp62DUPUMacrCgs6Wn3eJx+PXuCFN5OFwFW5RjISw-ir+B
m0B3uxvJDFPGPCpZImG3GArq6dL+gN0Oqe7aGmyz--DHDILBlPruYW4Sne7acJSPJp9LLxFg
uoIJRMGYSP0cqRnP7IS4GToc2lkIXvDu7jJWIMghhw17SXao34QbXekTER8T6oSVdGEjIPGc
pD58lgN7O9KcRPZORjCfJer0JXD3oC96bp1HiUkhqkm9rPHSUc1T0BF0WmqrG2rfDQ-XnB8v
YQtBfKbxQT0KeUD36S+SXTZrBHh9ARRnDsJm69nbhP7-M+GiaX6C563FbGLcjZoS3oROc-N6
PF5LMHtRRKuCxw-i6AFftaShWpFkY2qehnVvz9d6JEsKx2ww3ubKIT0OyHr7FKdoeBHA6xEi
g0vWmQaOK9NRd0sfmWDSNfWViYVxHhmKitquG2ACRyHTH3qYAQQHQaVHUFj1BuG9BCT4NRLi
cmvGafBX5MvV3p1kMFTltdil1QSu7uAOPqS-Wy2MjvlqlsxVFhiqNf8PfMjgmaQKOwnlV6jQ
ZwQ8RaBJeLt8BnMqzddoM9SH+Ba33FRxfQu2N35qK87gFDm-Dyoookyl1d9vjMXBN80LgPq-
vIDmzzRnw0Rcp8fqTdADmD28uySRemlwOluW1z+CYhqamXbk1W2PVgGkrAs7d91CX92M7Mi7
LatPGP1sP0FPRJxWV4kXSjoleaxnEAFCp37YzRSrs7SEL3omydQcQtWEX0t1SEenFQekU4N4
ywqlmWkZOgImc9j+1LgvWJuu1-cdgA1ORg9faB4xKlUc6wO0Nb1D3Z8r2IBpAzGV9MFQd81I
4ITS6eFm6VV3hdc+Bn3i++nlPS3l-x3r+kPx00JMAuu40e7j1Elu0PYj3IVI2gASkJ-Q3-jF
+e2eMhkg46klPGU3IfQHsuv-sAREsf20eKeGqnvwymRCL3O2yRIf5nByybzGzt4yYLvvrgjd
GmfkLjdGKhUMPIwzmpOiXjviJTdrfACdVRCzlKTsoiYpLbwLHvz1o3R-2ruJeWMCNspiveGD
XK1z6iwjhq4kKXw5qYUKL0ljnoYgvqDxozyc-zAO2nlrzLwLHfz9B5Vc7ryBru3HqLV9Tzvg
KdObKbnqQXtksUD33jdPAyjCfxfHZvvtk82JUhjd-cAuYn6jL7NHVX4DklCXUNujykwSk-9n
vwQYLYaTmZd9jnDrIIO93mpPhKvu6ZcxwkH9pYfufT10aHISr9yatv8O8y5o52BLB7gfNovl
GBQApYxwA8BPF5i9QolUNHnxuGXCvQ9sfTHvuNtPOX7zDHsZsXiosEohS7PaqNON5ZRtGzBj
4eXoKIuhO4c51lk69HWbK+OLB3gfTq9DHutUMUsQMR3RFHwLJHox36nV6In4FDdxtfaTuduL
5qFHBfxdmh7L3bv47wprrvbfaMLtxpaTFuY4RKJlbiKeaGOhme2z9P1gzqlJXGZxZbIKmvXU
lgmh8MKmAH3kiIUrg7GnhLGQ9a3ehAIrTgj+yiHSb9r+ncpwWLFuBRxOyXpJM7s3LjfmZTEj
SBGz9rptvGyjzhKRO4cYzPjyNJck3DGh7jSH2hJJMOt5u7TZSigpln1x5DSbrxS0mop5bdR1
8mWWxNTPm7OHgQ-5RCV9r6rmuZwkpOTTjTQr3ydptMAfKYZMwHosmzuzYW8s15+Fg0LEa3pw
j6tmczpePdErQ7F5JiNPy2uvAjoO2DBJEeyqoegBtbJ0pmjciY0jwSSuYpc2ycl+KkLuVY-L
-JcA+bpCc3u-DWzE7kFe2yUSULM6x0a-TYSUBkKuIu-h+hoZoDg2qWvEfkaoGu1R+ioJu1u-
rWxEio+3UHeeuShCybc3DEZptai2Lehb1Yppx8eHZYArTJqUFx1L89HFTl7c0rNfMFSx6B+S
vCt4RA-7VvnoSovej6xSu8J77loFu3UXjS0YUHOeCCZyULuXUN25qxbnw-vqT809DFwIu4Ef
ApMaI-TbVhfc0xroVThdS6-C1R1kDjBBBvlN-zXt5GqX5VjITEqQxL0s13lZI32-FqrodUAS
9MD58i1PRhMzUMUP3hid11OcfsS4CaXwhfYMei0h0cWtsPRZtb7ka4iV+FdgtVNkabR18nGu
sL32Sv0BUUTSRi864q4h4hOe63e3V-Aiqy5R0jAFe65r54MNeh4-anJM566Dly-X7l6Sy4wr
z4QJb2T3FjWs2HuhUcwSU1yu63f1vAWObQDalp4KqPOPHs6ReamMTvEIA1w77XPpHq9kDxld
TVdQx4acc1Sew6JuPjAttBykKwv-2mwQc5iRo6FeNHWsFbkug4Zz7Ugy8pUnJI4vmMJGxOMi
mo2oscORUULg+W0r4dwC0m1eF-hiVWDJ1RLspoMw3Xi91G2jR80p8YgR52ORBhC+cwe25mpQ
NUEgI+RJUUbT1aWrS+4UqRF2XXs7A3t2bX7t0KaTR7e-f1fC2j8RtqvW5Hh-PXLN81E7aGM9
VP4A4Ss4kEnacgmhvtgm4Kn3w0-yUd+GX5EvFZI0UQlqPCIA7eEGPwBr+638g4Tik3OfkbQV
T1T0RoBNtWtcnPE+jzfS+uktAfhJarjFNWTOr+g1aItgDOdIDv-ansl0Vo+GCwSVqn6CfqGC
e2cW8YWc8271Fg6a+xuI2qLHs9LAk+y3KNU3qmnw+H6nI498H+ApNltbRdrYKq0lT+iuAWSN
6GRNE567QvI2fgk0X4GS-6y+rdw41uP3SMux0-5z1p-9+E6I+-E++U+++Cm+-GA+++++++++
+++++++2++++++++++++A+++++++++-2AHMjI2g-+VE+3++0++U+5Phv6dxtpMyN++++bU2+
+-+++++++++++++U++++6U+++2ElBWxHEp7DH2l0H0t2Ep7EGk203++I++6+0+-d0kEXZC0J
ikQE++1E5k++2++++++++++++0++++1d++++F12q9pB1IYxAH27A9YF1JJ-9+E6I+-E++U++
+DC+-GA++++++++++++++++4++++++++++++A++++-sF++-2An7TAmxEGk203++I++6+0+-+
aPcWUuBEwOM+++1U+E++2U+++++++++++0++++-02E++F1AmLnAjIoBGHolAEYkiF2BGI2g-
+VE+3++0++U+QOzp6aptNV3H1U++xlk++-6++++++++++++U++++4-6++2EnAZwn9pB1IYxA
H27A9YF1JJ-9-EM+++++-U+4+46-++0P6+++++++
***** END OF BLOCK 2 *****


