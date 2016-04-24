(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0284.PAS
  Description: Component wraps the Win95 PageSetupDlg c
  Author: BRAD STOWERS
  Date: 05-30-97  18:17
*)

{ NOTE DCR AND DEMO located at the END of this unit }

{-----------------------------------------------------------------------------}
{ A component to wrap the Win95 PageSetupDlg common dialog API function.      }
{ Borland seems to have forgotten this new common dialog in Delphi 2.0.       }
{ Copyright 1996, Brad Stowers.  All Rights Reserved.                         }
{ This component can be freely used and distributed in commercial and private }
{ environments, provided this notice is not modified in any way and there is  }
{ no charge for it other than nominal handling fees.  Contact me directly for }
{ modifications to this agreement.                                            }
{-----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions  }
{ at bstowers@pobox.com or 72733,3374 on CompuServe.                          }
{ The lateset version will always be available on the web at:                 }
{   http://www.pobox.com/~bstowers/delphi/                                    }
{-----------------------------------------------------------------------------}
{ Date last modified:  08/27/96                                               }
{-----------------------------------------------------------------------------}

{ ----------------------------------------------------------------------------}
{ TPageSetupDialog v1.00                                                      }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   A component to wrap the PageSetupDlg API function that Borland forgot.    }
{   It is a common dialog available on the Win95 platform, so it can not be   }
{   used with Delphi 1.0.                                                     }
{ ----------------------------------------------------------------------------}
{ Revision History:                                                           }
{ 1.00:  + Initial release.                                                   }
{ ----------------------------------------------------------------------------}

unit PgSetup;

interface

{$IFNDEF WIN32}
  ERROR!  This unit only available for Delphi 2.0!!!
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CommDlg, DsgnIntf;

type
  TPageSetupOption = (
       poDefaultMinMargins, poDisableMargins, poDisableOrientation,
       poDisablePagePainting, poDisablePaper, poDisablePrinter, poNoWarning, poShowHelp
     );
  TPageSetupOptions = set of TPageSetupOption;
  TPSPaperType = (ptPaper, ptEnvelope);
  TPSPaperOrientation = (poPortrait, poLandscape);
  TPSPrinterType = (ptDotMatrix, ptHPPCL);
  TPSPaintWhat = (pwFullPage, pwMinimumMargins, pwMargins,
                  pwGreekText, pwEnvStamp, pwYAFullPage);

  TPSMeasurements = (pmMillimeters, pmInches);
  TPSPrinterEvent = procedure(Sender: TObject; Wnd: HWND) of object;

  { PPSDlgData is simply redeclared as PPageSetupDlg (COMMDLG.PAS) to prevent compile }
  { errors in units that have this event.  They won't compile unless you add CommDlg  }
  { to their units.  This circumvents the problem.                                    }
  PPSDlgData = ^TPSDlgData;
  TPSDlgData = TPageSetupDlg;
  { PaperSize: See DEVMODE help topic, dmPaperSize member. DMPAPER_* constants. }
  TPSInitPaintPageEvent = function(Sender: TObject; PaperSize: short;
              PaperType: TPSPaperType; PaperOrientation: TPSPaperOrientation;
              PrinterType: TPSPrinterType; pSetupData: PPSDlgData): boolean of object;
  TPSPaintPageEvent = function(Sender: TObject; PaintWhat: TPSPaintWhat;
              Canvas: TCanvas; Rect: TRect): boolean of object;


  TPageSetupDialog = class(TCommonDialog)
  private
    FOptions: TPageSetupOptions;
    FCustomData: LPARAM;
    FPaperSize: TPoint;
    FMinimumMargins: TRect;
    FMargins: TRect;
    FMeasurements: TPSMeasurements;
    FOnPrinter: TPSPrinterEvent;
    FOnInitPaintPage: TPSInitPaintPageEvent;
    FOnPaintPage: TPSPaintPageEvent;

    function DoPrinter(Wnd: HWND): boolean;
    function DoExecute(Func: pointer): boolean;
  protected
    function Printer(Wnd: HWND): boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: boolean; virtual;
    { It is the user's responsibility to clean up this pointer if necessary. }
    property CustomData: LPARAM
        read FCustomData
        write FCustomData;

    { These should be published, but need Property Editors for TPoint and TRect.  As }
    { best I can tell, there is no way to do that, since they need RTTI, and that is }
    { not available for record types.  Bummer.                                       }
    { Also, all of these rects return sizes that need to be divided by 1000.  For    }
    { example, PaperSize.X would be 8500 for 8.5 inch paper.  Maybe I should make a  }
    { TSingleRect and TSinglePoint and return the actual single value, but the API   }
    { returns them to me that way, and I'm lazy by default. :)                       }
    property PaperSize: TPoint
        read FPaperSize
        write FPaperSize;
    property MinimumMargins: TRect
        read FMinimumMargins
        write FMinimumMargins;
    property Margins: TRect
        read FMargins
        write FMargins;

  published
    property Options: TPageSetupOptions
        read FOptions
        write FOptions
        default [poDefaultMinMargins, poShowHelp];
    property Measurements: TPSMeasurements
        read FMeasurements
        write FMeasurements
        default pmInches;

    { Events }
    property OnPrinter: TPSPrinterEvent
        read FOnPrinter
        write FOnPrinter;
    property OnInitPaintPage: TPSInitPaintPageEvent
        read FOnInitPaintPage
        write FOnInitPaintPage;
    property OnPaintPage: TPSPaintPageEvent
        read FOnPaintPage
        write FOnPaintPage;
  end;

procedure Register;

implementation

uses Printers;

const
  IDPRINTERBTN = $0402;

{ Private globals }
var
  HelpMsg: Integer;
  HookCtl3D: boolean;


{ Center the given window on the screen }
procedure CenterWindow(Wnd: HWnd);
var
  Rect: TRect;
begin
  GetWindowRect(Wnd, Rect);
  SetWindowPos(Wnd, 0,
    (GetSystemMetrics(SM_CXSCREEN) - Rect.Right + Rect.Left) div 2,
    (GetSystemMetrics(SM_CYSCREEN) - Rect.Bottom + Rect.Top) div 3,
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

{ Generic dialog hook. Centers the dialog on the screen in response to
  the WM_INITDIALOG message }
function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  case Msg of
    WM_INITDIALOG:
      begin
        if HookCtl3D then
        begin
          Subclass3DDlg(Wnd, CTL3D_ALL);
          SetAutoSubClass(True);
        end;
        CenterWindow(Wnd);
        Result := 1;
      end;
    WM_DESTROY:
      if HookCtl3D then SetAutoSubClass(False);
  end;
end;

var
  PageSetupDialog: TPageSetupDialog;

function PageSetupDialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM;
                             LParam: LPARAM): UINT; stdcall;
const
  PagePaintWhat: array[WM_PSD_FULLPAGERECT..
                       WM_PSD_YAFULLPAGERECT] of TPSPaintWhat = (
    pwFullPage, pwMinimumMargins, pwMargins,
    pwGreekText, pwEnvStamp, pwYAFullPage
  );
  PRINTER_MASK = $00000002;
  ORIENT_MASK  = $00000004;
  PAPER_MASK   = $00000008;
var
  PaperData: word;
  Paper: TPSPaperType;
  Orient: TPSPaperOrientation;
  Printer: TPSPrinterType;
  PaintRect: TRect;
  PaintCanvas: TCanvas;
begin
  if (Msg = WM_COMMAND) and (LongRec(WParam).Lo = IDPRINTERBTN) and
     (LongRec(WParam).Hi = BN_CLICKED) then begin
    // if hander is assigned, use it.  If not, let system do it.
    Result := ord(PageSetupDialog.DoPrinter(Wnd));
  end else begin
    if assigned(PageSetupDialog.FOnInitPaintPage) and
           assigned(PageSetupDialog.FOnPaintPage) then begin
      case Msg of
        WM_PSD_PAGESETUPDLG:
          begin
            PaperData := HiWord(WParam);
            if (PaperData AND PAPER_MASK > 0) then
              Paper := ptEnvelope
            else
              Paper := ptPaper;
            if (PaperData AND ORIENT_MASK > 0) then
              Orient := poPortrait
            else
              Orient := poLandscape;
            if (PaperData AND PAPER_MASK > 0) then
              Printer := ptHPPCL
            else
              Printer := ptDotMatrix;
            Result := Ord(PageSetupDialog.FOnInitPaintPage(PageSetupDialog,
                LoWord(WParam), Paper, Orient, Printer, PPSDlgData(LParam)));
          end;
        WM_PSD_FULLPAGERECT,
        WM_PSD_MINMARGINRECT,
        WM_PSD_MARGINRECT,
        WM_PSD_GREEKTEXTRECT,
        WM_PSD_ENVSTAMPRECT,
        WM_PSD_YAFULLPAGERECT:
          begin
            if LParam <> 0 then
              PaintRect := PRect(LParam)^
            else
              PaintRect := Rect(0,0,0,0);
            PaintCanvas := TCanvas.Create;
            PaintCanvas.Handle := HDC(WParam);
            try
              Result := Ord(PageSetupDialog.FOnPaintPage(PageSetupDialog,
                                   PagePaintWhat[Msg], PaintCanvas, PaintRect));
            finally
              PaintCanvas.Free;   { This better not be deleting the DC! }
            end;
          end;
      else
        Result := DialogHook(Wnd, Msg, wParam, lParam);
      end;
    end else
      Result := DialogHook(Wnd, Msg, wParam, lParam);
  end;
end;


constructor TPageSetupDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [poDefaultMinMargins, poShowHelp];
  FOnPrinter := NIL;
  FOnInitPaintPage := NIL;
  FOnPaintPage := NIL;
  FCustomData := 0;
  FPaperSize := Point(0,0);
  FMinimumMargins := Rect(0,0,0,0);
  FMargins := Rect(1000,1000,1000,1000);
  FMeasurements := pmInches;
end;

destructor TPageSetupDialog.Destroy;
begin
  inherited Destroy;
end;


procedure GetPrinter(var DeviceMode, DeviceNames: THandle);
var
  Device, Driver, Port: array[0..79] of char;
  DevNames: PDevNames;
  Offset: PChar;
begin
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
  if DeviceMode <> 0 then
  begin
    DeviceNames := GlobalAlloc(GHND, SizeOf(TDevNames) +
     StrLen(Device) + StrLen(Driver) + StrLen(Port) + 3);
    DevNames := PDevNames(GlobalLock(DeviceNames));
    try
      Offset := PChar(DevNames) + SizeOf(TDevnames);
      with DevNames^ do
      begin
        wDriverOffset := Longint(Offset) - Longint(DevNames);
        Offset := StrECopy(Offset, Driver) + 1;
        wDeviceOffset := Longint(Offset) - Longint(DevNames);
        Offset := StrECopy(Offset, Device) + 1;
        wOutputOffset := Longint(Offset) - Longint(DevNames);;
        StrCopy(Offset, Port);
      end;
    finally
      GlobalUnlock(DeviceNames);
    end;
  end;
end;

procedure SetPrinter(DeviceMode, DeviceNames: THandle);
var
  DevNames: PDevNames;
begin
  DevNames := PDevNames(GlobalLock(DeviceNames));
  try
    with DevNames^ do
      Printer.SetPrinter(PChar(DevNames) + wDeviceOffset,
        PChar(DevNames) + wDriverOffset,
        PChar(DevNames) + wOutputOffset, DeviceMode);
  finally
    GlobalUnlock(DeviceNames);
    GlobalFree(DeviceNames);
  end;
end;

function CopyData(Handle: THandle): THandle;
var
  Src, Dest: PChar;
  Size: Integer;
begin
  if Handle <> 0 then
  begin
    Size := GlobalSize(Handle);
    Result := GlobalAlloc(GHND, Size);
    if Result <> 0 then
      try
        Src := GlobalLock(Handle);
        Dest := GlobalLock(Result);
        if (Src <> nil) and (Dest <> nil) then Move(Src^, Dest^, Size);
      finally
        GlobalUnlock(Handle);
        GlobalUnlock(Result);
      end
  end
  else Result := 0;
end;

function TPageSetupDialog.DoExecute(Func: pointer): boolean;
const
  PageSetupOptions: array [TPageSetupOption] of DWORD = (
      PSD_DEFAULTMINMARGINS, PSD_DISABLEMARGINS, PSD_DISABLEORIENTATION,
      PSD_DISABLEPAGEPAINTING, PSD_DISABLEPAPER, PSD_DISABLEPRINTER,
      PSD_NOWARNING, PSD_SHOWHELP
    );
  PageSetupMeasurements: array [TPSMeasurements] of DWORD = (
      PSD_INHUNDREDTHSOFMILLIMETERS, PSD_INTHOUSANDTHSOFINCHES
    );
var
  Option: TPageSetupOption;
  PageSetup: TPageSetupDlg;
  SavePageSetupDialog: TPageSetupDialog;
  DevHandle: THandle;
begin
  FillChar(PageSetup, SizeOf(PageSetup), 0);
  with PageSetup do
  try
    lStructSize := SizeOf(TPageSetupDlg);
    hInstance := System.HInstance;

    Flags := PSD_MARGINS;

    if assigned(FOnPrinter) or assigned(FOnInitPaintPage) or assigned(FOnPaintPage) then begin
      Flags := Flags or PSD_ENABLEPAGESETUPHOOK;
      lpfnPageSetupHook := PageSetupDialogHook;
    end;

    for Option := Low(Option) to High(Option) do
      if Option in FOptions then
        Flags := Flags OR PageSetupOptions[Option];
    Flags := Flags OR PageSetupMeasurements[FMeasurements];
{    if not assigned(FOnPrinter) then
      Flags := Flags OR PSD_DISABLEPRINTER;}
    if assigned(FOnInitPaintPage) and assigned(FOnPaintPage) then begin
      Flags := Flags OR PSD_ENABLEPAGEPAINTHOOK;
      lpfnPagePaintHook := PageSetupDialogHook;
    end;

    hWndOwner := Application.Handle;
    GetPrinter(DevHandle, hDevNames);
    hDevMode := CopyData(DevHandle);
    HookCtl3D := Ctl3D;
    lCustData := FCustomData;
    ptPaperSize := FPaperSize;
    rtMinMargin := FMinimumMargins;
    rtMargin := FMargins;

    SavePageSetupDialog := PageSetupDialog;
    PageSetupDialog := Self;
    Result := TaskModalDialog(Func, PageSetup);
    PageSetupDialog := SavePageSetupDialog;

    if Result then begin
      FPaperSize := ptPaperSize;
      FMinimumMargins := rtMinMargin;
      FMargins := rtMargin;
      SetPrinter(hDevMode, hDevNames);
    end else begin
      if hDevMode <> 0 then GlobalFree(hDevMode);
      if hDevNames <> 0 then GlobalFree(hDevNames);
    end;
  finally
    { Nothing yet }
  end;
end;

function TPageSetupDialog.Execute: boolean;
begin
  Result := DoExecute(@PageSetupDlg);
end;

function TPageSetupDialog.Printer(Wnd: HWND): boolean;
begin
  Result :=  assigned(FOnPrinter);
  if Result then
    FOnPrinter(Self, Wnd);
end;

function TPageSetupDialog.DoPrinter(Wnd: HWND): boolean;
begin
  try
    Result := Printer(Wnd);
  except
    Result := FALSE;
    Application.HandleException(Self);
  end;
end;


procedure Register;
begin
  { You may prefer it on the Dialogs page, I like it on Win95 because it is }
  { only available on Win95.                                                }
  RegisterComponents('Win95', [TPageSetupDialog]);
end;


{ Initialization and cleanup }

procedure InitGlobals;
begin
  HelpMsg := RegisterWindowMessage(HelpMsgString);
end;

initialization
  InitGlobals;
finalization
  { Nothing }
end.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000488-130396--72--85-52265-----PGSETUP.DCR--1-OF--1
+++++0++++1zzk++zzw+++++++++++++++++++++++06+E++E++++Dzz+U-I+3++EE-5+2I+
Ik-3+3E+JE-E+2E+GE--+2k+Hk-5++++++++++++2-+7-+++++++++++8++++-U++++M++++
+E+2+++++++U+E+++++++++++++++++++++++++++++++6+++6++++0+U+0+++++U+0++60+
++1+kA++U60+++++zk++zk+++Dzz+Dw+++1z+Dw+zzw++Dzzzk+nAnAnAnAnAnAnAnAnAnAn
AnAnAnAnAnAnA++++++++++++nAnADzzzzzzzzzz+nAnADzzzzzzzzzz+nAnADzzzzzzzzzz
+nAnADzzzzzzzzzz+nAnADzzzzzk++zz+nAnADzzzzxivi1z+nAnADU+++1a++Xz+nAnAD-i
PivUyDzz+nAnADU+++1a++Xz+nAnADzzzzVivi1z+nAnADzzzzy+++Xz+nAnADzzzzzzzzzz
+nAnADzzzzzzzzzz+nAnADzzzzzzw++++nAnADzzzzzzwDTr+nAnADzzzzzzw5xkAnAnADzz
zzzzwDQ1AnAnADzzzzzzw5+nAnAnA+++++++++AnAnAnAnAnAnAnAnAnAnAnAnAnAnAnAnAn
AnA+
***** END OF BLOCK 1 *****



*XX3402-002427-270896--72--85-39530--------DEMO.ZIP--1-OF--1
I2g1--E++++6+5lq4m28GpP-V++++9c++++6++++N4JhPmtYQ56f8AdD9ofAJIV7nQqrtiLW
tGchHWratJ7EQAgjmWrK+P30wn791-ImwlHIkGmxUgFWRMJeY9lV9JV9hIeEUdNSY4hk9MWL
Z7eSaETGtpVEY7CNb3WGaNybtkbIaNaMYpaJOcoitJmIaZWG0X7C6kFge+vMPYBB17J-dLZ+
gRGw31qEDE-EGkA23+++++U+UrMP6HdGJDQt+U++rkE+++Y+++-JPaZoAGtYNaq3YwyCon+E
lhpY2uRBmpM06F+QQZdl+PIfEBexhJqeLR4GW2Gel+arxPMKWFotvZ7s4cuw1Gz+UGAGNwvU
C5yOde0xK7fAn4wyTz5wOM3Uv9uRxY4jyyo6UA+PxwlUn5XIBxFtBA5LEjzJo+AKusyona+V
m+oSAGcs0m2QPcFUh4wD4JxWvchD6MPKD9YU84EfC28l66mOxnmokXsKanV9C-QsMipFG1+J
ZtWgpY8zqv0nS2OKMeqzOvH4QgOn2EgNVyp3C0BomHs4S0hgZQXOhBxB3Pp-2HMvIxzl2IoQ
5rBmbTIfFHOkD7OEJ+ew2nBzkH4a6nY9wst5hXVADAmju48hjKyZ2r7q-tX--AplO8cngo9f
dYtcZsPGePooWy9mgfO5MgkRbrn4tq+TQJd-u1z-zlZhZuRSc1GcEttLROlnFb16u2s77R2a
QeO6fkVBudkLJH3T0n3D1Y3K3H12Bl8UnhkEc6HYzT953M+nMl0G3MI40aK-sOyZ9P+xHsNA
DdZcEWUi-HKJNOZX4H9SwpUj7NIBRgKTGgjCorzoh8ETyIqeIr65xSyUO5Ze1HO0dKcgOmPT
xMmXi3ZWs04XRCxq0+mmXGYK7uDoZ77ifjppkLWsSpAbuEMtOcKg+ArRRBgo+3oeZqPl+PNn
b6cCdaHDHjw-PVhXj1fN2f2Po8UDCAo5R6DOFVzLseN9DIvG1MDrOubwyv39fmUF5d7FKU2T
pyfqgfPYZNIDugEWYxrnGrND0k1k3p-9+kEI++++0+-pRVgVfDRcut+3++1x2U++0E+++3Ji
OLEl9b-VQxpMrKwPBklz1t1zURU554ySaqHPEqDocL5G9ZW04949h+Xu6BzlP0ouuG1dsbV3
zzSFiUyTnwuGTakMNVExWG6dwYS8Z77fuS2BzLQkqBrNrN5Ocop2V1n75PfR5M-feKCnQ1qs
ECT214YoLfcrLWcO1NJkXYajfQXaAa8GoRsOLblZP2eT2maIaPYS8ljvSCUh9tvSyr7oUHeb
nqUqFdxbB91-1VRAWclqbWJN4Qb+0yXosmHh17UskLhT2TqxvkEFjwkk97uwifWoYvQHKhsX
eyvEycZVDQ56MgcOiV1YG66L1sUxMfTqkfH90k+XwXnMJrVn-7AKNJ1k5STS4rp+uwJcXLnM
7dy98Gda1cAawL+PwNRhl3xPl4Cw8rG4kO+mDoAvZbxWWzbGGhFSS4ZoOyJ0uUhVNp8vxg7K
OaNBV53igL7pe4FoinR45OAZrgjd5lXtvUDQ-rz9bSEuMUjPEHWXl-o7GVOahsJ9qHLLluZE
WjU5-L30WQ8-5BSnRO3pQ2eq-b3EdSd8oKdSewc8WsILFn+OXIzIXATR6nUqFe5EXnXt3+S7
srciT4ZYCFj+ICUvkM2e-UCs6X4OwaRXzpJ6qUMIDapg1xQuDc6nKdiV9I8JKLYbD-M8Dn+u
D6IMuHnN+7a1Xs2lbp9+SIF8ky4v2vMutNmvsJjId1FHa3OEAyL1RpTkEtwCxwSeHA3sfgUe
8YlnJCfZu0l6viugT0cIxVz9nGZGOfAREqIQVv+mvk3B1yRhfIYaPI1vdzQMtMG9buC4af4F
eTqVm26i59o6W+WzpvaKgNxHOTfydwDyMT6BgTy4QXPr8p8bJqI2zqvOiuuojsJbQ90zjxzP
g4n3wuvYSRwhOmD+Ed6-PEYe2n9Bov6cE4ke4pPpMtgrttXsdXBL9JSyDTXtluMr1zsu2tAp
3FoPWYju20UDz4vqUXq3lxoSv-Lap5DScs8grC07u4n0wYxXwXI+iKb+oMAa42z1shYnOjFt
YZ040kyFGSa67dMs8SAVmeqZswn3Uih86Q4bd7Xr4kKKfAvAm3Vj-RpHy9VIhXSMaZ-q8iNC
kMX8sKAWto959e92vuneILLguu7QbjdDPY0Tr5myIiBtEhCd0kx3uuJGY347Hd2jLVElqYVe
W2a4efS9f7l8DEjVmxWKTWZrFPhM1RvaJAoAS8eyUGYCw-HVLm+g-AIvBffXWm4llUO2LY7g
lM6oxo1qgJ980WtpXGjEBMNY3d7oOyCdM272G47A0a7MaflMAZchMMMS-2mJo9RP1Io27EFj
HkfAMaoL6esoClAIFo650o5ucCU8LOtwC9AjnwSbHoyIlt9YGlhs5QhB0s4wQ9XO+olG5x67
6IrMGhgA8mLDsZKi37hvJ-qSQcBJuGUguVzPrArvEuCAtIoXxEsNqQ48ARF3BfVF--g8S2Lc
aQ7EUYBt8GhCJJuuhP68vBdugXjVd0KTJfZNyP1SaReShAkMcKtuwRcWug3zn3i2BDU0hh7G
izctDZtVjCYVwsnxIW5nNCv2y0SUQ1qL5jwp24fjMH35mU+by6N6hMTSUR83wuffFCN+rj6P
vzyDnRUH2+2RG4Vrd+SiAVau4chHTFRsDUq8MtLXZq-FQorRq0Wt-RQBnBPFzye6hNjwlhry
Qlx+BNvZLoecuytp7bB8mXap8cKqO1gix-PeByMCfNIl7n9JtPb6AhGCfrbEjiRp3jlIs-75
nlp9JmTYjvc2EaYRHAC1d+xkZf1yvKecur693H2pnxccnVN7O92qhrESou8XSb49qxLk0fIJ
4kcjWwPGNIcgenh0NJA+QPi8+ZcGReUGgXf+FDw036mDFE7fKRkLbXzzTfiKgitvaK8zosDI
byYYr8Od3TTU7dpSzjuy-zjRFfHdqmxSVrw-I2g-+VE93+++++U+T5MP6Ed9Jg42++++iU++
++U++++++++++E+U+9O-+++++4FZPKwiN5-mI2g-+VE93+++++U+UrMP6HdGJDQt+U++rkE+
++Y++++++++++E+U+9O-eU+++3JiOLEl9aFaPJ-9+E6I0lE++++6+5Jq4m4gxqXfY+I++DoG
+++7++++++++++2+6+0qUEc1++-JPaZoAGtkMLBEGkI4++++++A++k0Y++++kEU+++++
***** END OF BLOCK 1 *****


