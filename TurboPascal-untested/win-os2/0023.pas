{************************************************}
{                                                }
{   AJC Printer Unit for Windows                 }
{                                                }
{   Printer control constants/functions          }
{                                                }
{   Author:  Andrew J. Cook                      }
{            Omaha, NE                           }
{            CompuServe ID:  71331,501           }
{                                                }
{   Written: January 1994                        }
{                                                }
{   Copyright:  None!  I hereby commit this unit }
{                      to the public domain.     }
{                                                }
{************************************************}

{************************************************}
{                                                }
{  New SetPageSize function added and changed    }
{  margin code in SetPrintParams function.       }
{                                                }
{  Modified by:                                  }
{               Paul Mayer                       }
{               ZPAY Payroll Systems, Inc.       }
{               St. Petersburg,  FL              }
{               CompuServe ID: 76711,1141        }
{                                                }
{  Thanks to Kurt Barthelmess Borland Team B for }
{  pointing out what I was doing wrong so I      }
{  could get this function to work after a week  }
{  of trial and error and a lot of test paper!   }
{                                                }
{                                 April 1994     }
{                                                }
{************************************************}

unit AJCPrntW;

{$F+,O+,S-}

interface

uses WinTypes, WinProcs, OPrinter;

type
  PAJCPrinter = ^TAJCPrinter;
  TAJCPrinter = object(TPrinter)
    function SetPageOrientation(Orientation:  Integer): Integer; virtual;
    function SetPageSize(PageID, NewLength, NewWidth : Integer) : Integer; virtual;
  end;

const
  pm_Size = 1;
  pm_Print = 2;

type
  PAJCPrintOut = ^TAJCPrintOut;
  TAJCPrintOut = object(TPrintOut)
    VUnitsPerInch:  Integer;
    HUnitsPerInch:  Integer;
    LMarginUnits:  Integer;
    TMarginUnits:  Integer;
    RMarginUnits:  Integer;
    BMarginUnits:  Integer;
    OriginalAlignmentOptions:  Word;
    constructor Init(ATitle:  PChar);
    destructor Done; virtual;
    procedure SetPrintParams(ADC: HDC; ASize: TPoint); virtual;
    function VLogPos(Pos:  Integer): Integer; virtual;
    function HLogPos(Pos:  Integer): Integer; virtual;
    function VInches(Inches: Real): Integer; virtual;
    function HInches(Inches: Real): Integer; virtual;
    function Points(APoints:  Integer): Integer; virtual;
    function PrintHeader(Mode, Page:  Word): Integer; virtual;
    function PrintFooter(Mode, Page:  Word): Integer; virtual;
    procedure JustifyLeft;
    procedure JustifyCenter;
    procedure JustifyRight;
  end;

var
  DevModeOut, DevModeIn : PDevMode;

implementation

function TAJCPrinter.SetPageOrientation(Orientation: Integer): Integer;
var
  DevMode:  PDevMode;
  Result:  Integer;
begin
  SetPageOrientation := -1;
  if (Orientation <> dmOrient_Portrait) and
     (Orientation <> dmOrient_Landscape) then
       exit;
  if @ExtDeviceMode = nil then exit;
  if DevSettings^.dmFields or dm_Orientation = 0 then exit;

  if DevSettings^.dmOrientation = Orientation then
    begin
      SetPageOrientation := 1;
      exit;
    end;

  GetMem(DevMode, DevSettingSize);
  Move(DevSettings^, DevMode^, DevSettingSize);
  DevMode^.dmOrientation := Orientation;
  Result := ExtDeviceMode(0, DeviceModule, DevSettings^, Device, Port,
                          DevMode^, nil, dm_In_Buffer or dm_Out_Buffer);
  FreeMem(DevMode, DevSettingSize);
  if Result = IDOK then
    SetPageOrientation := 0;
end;

function TAJCPrinter.SetPageSize(PageID, NewLength, NewWidth : Integer): Integer;
var
  DevModeIn:  PDevMode;
  Result:  Integer;
  Size : Integer;
begin
  SetPageSize := -1;
  if @ExtDeviceMode = nil then exit;
  GetMem(DevModeIn, DevSettingSize);
  Result := ExtDeviceMode(0, DeviceModule, DevSettings^, Device, Port,
                          DevModeIn^, nil, dm_Out_Buffer);
  DevModeIn^.dmDeviceName := DevSettings^.dmDeviceName;
  DevModeIn^.dmSpecVersion := DevSettings^.dmSpecVersion;
  DevModeIn^.dmDriverVersion := 0;
  DevModeIn^.dmFields := dm_PaperSize or dm_Paperlength or dm_PaperWidth;
  DevModeIn^.dmPaperSize := PageId {eg dmPaper_User, dmPaper_Letter};
  DevModeIn^.dmPaperLength := NewLength; {in 1/10 of millimeters}
  DevModeIn^.dmPaperWidth := NewWidth {in 1/10 of millimeters};
  Result := ExtDeviceMode(0, DeviceModule, DevSettings^, Device, Port,
                          DevModeIn^, nil, dm_In_Buffer or dm_Out_Buffer);
  FreeMem(DevModeIn, DevModeIn^.dmSize + DevModeIn^.dmDriverExtra);
  if Result = IDOK then
    SetPageSize := 0;
end;

constructor TAJCPrintOut.Init(ATitle:  PChar);
begin
  inherited Init(ATitle);
  OriginalAlignmentOptions := 0;
end;

destructor TAJCPrintOut.Done;
begin
  if OriginalAlignmentOptions <> 0 then
    SetTextAlign(DC, OriginalAlignmentOptions);

  inherited Done;
end;

procedure TAJCPrintOut.SetPrintParams(ADC: HDC; ASize: TPoint);
var
  lpOffset, lpDimensions : TPoint;
begin
  inherited SetPrintParams(ADC, ASize);

  OriginalAlignmentOptions := GetTextAlign(DC);

  VUnitsPerInch := GetDeviceCaps(DC, LogPixelsY);
  HUnitsPerInch := GetDeviceCaps(DC, LogPixelsX);

  Escape(DC, GetPhysPageSize, 0, nil, @lpDimensions);
  Escape(DC, GetPrintingOffset, 0, nil, @lpOffset);

  TMarginUnits := lpOffset.Y;
  LMarginUnits := lpOffset.X;
  BMarginUnits := (lpDimensions.Y - (Size.Y+lpOffset.Y));
  RMarginUnits := (lpDimensions.X - (Size.X+lpOffset.X));
end;

function TAJCPrintOut.VLogPos(Pos: Integer): Integer;
begin
  if Pos < 0 then
    VLogPos := Size.Y + Pos + TMarginUnits
  else
    VLogPos := Pos - TMarginUnits;
end;


function TAJCPrintOut.HLogPos(Pos: Integer): Integer;
begin
  if Pos < 0 then
    HLogPos := Size.X + Pos + LMarginUnits
  else
    HLogPos := Pos - LMarginUnits;
end;

function TAJCPrintOut.VInches(Inches: Real): Integer;
begin
  VInches := round(Inches * VUnitsPerInch);
end;

function TAJCPrintOut.HInches(Inches: Real): Integer;
begin
  HInches := round(Inches * HUnitsPerInch);
end;

function TAJCPrintOut.Points(APoints:  Integer): Integer;
begin
  Points := APoints * (VUnitsPerInch) div 72;
end;

function TAJCPrintOut.PrintHeader(Mode, Page:  Word):  Integer;
begin
  PrintHeader := 0;
end;

function TAJCPrintOut.PrintFooter(Mode, Page:  Word):  Integer;
begin
  PrintFooter := 0;
end;

procedure TAJCPrintOut.JustifyLeft;
var
  AlignmentOptions:  Word;
begin
  AlignmentOptions := GetTextAlign(DC);
  AlignmentOptions := AlignmentOptions and not (ta_left or ta_center or ta_right);
  AlignmentOptions := AlignmentOptions or ta_left;
  SetTextAlign(DC, AlignmentOptions);
end;

procedure TAJCPrintOut.JustifyCenter;
var
  AlignmentOptions:  Word;
begin
  AlignmentOptions := GetTextAlign(DC);
  AlignmentOptions := AlignmentOptions and not (ta_left or ta_center or ta_right);
  AlignmentOptions := AlignmentOptions or ta_center;
  SetTextAlign(DC, AlignmentOptions);
end;

procedure TAJCPrintOut.JustifyRight;
var
  AlignmentOptions:  Word;
begin
  AlignmentOptions := GetTextAlign(DC);
  AlignmentOptions := AlignmentOptions and not (ta_left or ta_center or ta_right);
  AlignmentOptions := AlignmentOptions or ta_right;
  SetTextAlign(DC, AlignmentOptions);
end;


begin
end.
