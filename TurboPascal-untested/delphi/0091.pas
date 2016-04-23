unit EDSPrint;
  {unit to programmatically set printer options so that user does not}
  {have to go to the Printer Options Dialog Box}
  {Revision 2.1}
interface
uses
  Classes, Graphics, Forms, Printers, SysUtils, Print, WinProcs, WinTypes, Messages;
            {see the WinTypes unit for constant declarations such as}
            {dmPaper_Letter, dmbin_Upper, etc}

const
  CCHBinName  = 24;  {Size of bin name (should have been in PRINT.PAS}
  CBinMax     = 256; {Maximum number of bin sources}
  CPaperNames = 256; {Maximum number of paper sizes}
type
  TPrintSet = class (TComponent)
  private
    { Private declarations }
    FDevice:     PChar;
    FDriver:     PChar;
    FPort:       PChar;
    FHandle:     THandle;
    FDeviceMode: PDevMode;
    FPrinter:    integer;   {same as Printer.PrinterIndex}
    procedure    CheckPrinter;
      {-checks to see if the printer has changed and calls SetDeviceMode if it has}
  protected
    { Protected declarations }
    procedure   SetOrientation (Orientation: integer);
    function    GetOrientation: integer;
      {-sets/gets the paper orientation}
    procedure   SetPaperSize (Size: integer);
    function    GetPaperSize: integer;
      {-sets/gets the paper size}
    procedure   SetPaperLength (Length: integer);
    function    GetPaperLength: integer;
      {-sets/gets the paper length}
    procedure   SetPaperWidth (Width: integer);
    function    GetPaperWidth: integer;
      {-sets/gets the paper width}
    procedure   SetScale (Scale: integer);
    function    GetScale: integer;
      {-sets/gets the printer scale (whatever that is)}
    procedure   SetCopies (Copies: integer);
    function    GetCopies: integer;
      {-sets/gets the number of copies}
    procedure   SetBin (Bin: integer);
    function    GetBin: integer;
      {-sets/gets the paper bin}
    procedure   SetPrintQuality (Quality: integer);
    function    GetPrintQuality: integer;
      {-sets/gets the print quality}
    procedure   SetColor (Color: integer);
    function    GetColor: integer;
      {-sets/gets the color (monochrome or color)}
    procedure   SetDuplex (Duplex: integer);
    function    GetDuplex: integer;
      {-sets/gets the duplex setting}
    procedure   SetYResolution (YRes: integer);
    function    GetYResolution: integer;
      {-sets/gets the y-resolution of the printer}
    procedure   SetTTOption (Option: integer);
    function    GetTTOption: integer;
      {-sets/gets the TrueType option}
  public
    { Public declarations }
    constructor Create (AOwner: TComponent); override;
      {-initializes object}
    destructor  Destroy;  override;
      {-destroys class}
    function    GetBinSourceList: TStringList;
      {-returns the current list of bins}
    function    GetPaperList: TStringList;
      {-returns the current list of paper sizes}
    procedure   SetDeviceMode;
      {-sets the internal pointer to the printers TDevMode structure}
    procedure   UpdateDeviceMode;
      {-updates the printers TDevMode structure}
    procedure   SaveToDefaults;
      {-updates the default settings for the current printer}
    procedure   SavePrinterAsDefault;
      {-saves the current printer as the Window's default}
    function    GetPrinterName: string;
      {-returns the name of the current printer}
    function    GetPrinterPort: string;
      {-returns the port of the current printer}
    function    GetPrinterDriver: string;
      {-returns the printer driver name of the current printer}

    { Property declarations }
    property Orientation: integer     read   GetOrientation
                                      write  SetOrientation;
    property PaperSize: integer       read   GetPaperSize
                                      write  SetPaperSize;
    property PaperLength: integer     read   GetPaperLength
                                      write  SetPaperLength;
    property PaperWidth: integer      read   GetPaperWidth
                                      write  SetPaperWidth;
    property Scale: integer           read   GetScale
                                      write  SetScale;
    property Copies: integer          read   GetCopies
                                      write  SetCopies;
    property DefaultSource: integer   read   GetBin
                                      write  SetBin;
    property PrintQuality: integer    read   GetPrintQuality
                                      write  SetPrintQuality;
    property Color: integer           read   GetColor
                                      write  SetColor;
    property Duplex: integer          read   GetDuplex
                                      write  SetDuplex;
    property YResolution: integer     read   GetYResolution
                                      write  SetYResolution;
    property TTOption: integer        read   GetTTOption
                                      write  SetTTOption;
    property PrinterName: String      read   GetPrinterName;
    property PrinterPort: String      read   GetPrinterPort;
    property PrinterDriver: String    read   GetPrinterDriver;
  end;  { TPrintSet }

procedure CanvasTextOutAngle (OutputCanvas: TCanvas; X,Y: integer;
                              Angle: Word; St: string);
  {-prints text at the desired angle}
  {-current font must be TrueType!}
procedure SetPixelsPerInch;
  {-insures that PixelsPerInch is set so that text print at the desired size}
function GetResolution: TPoint;
  {-returns the resolution of the printer}

procedure Register;
  {-registers the printset component}

implementation

constructor TPrintSet.Create (AOwner: TComponent);
  {-initializes object}
begin
  inherited Create (AOwner);
  if not (csDesigning in ComponentState) then
  begin
    GetMem (FDevice, 255);
    GetMem (FDriver, 255);
    GetMem (FPort, 255);
    {SetDeviceMode;}
    FPrinter := -99;
  end {:} else
  begin
    FDevice := nil;
    FDriver := nil;
    FPort   := nil;
  end;  { if... }
end;  { TPrintSet.Create }

procedure TPrintSet.CheckPrinter;
  {-checks to see if the printer has changed and calls SetDeviceMode if it has}
begin
  if FPrinter <> Printer.PrinterIndex then
    SetDeviceMode;
end;  { TPrintSet.CheckPrinter }

function TPrintSet.GetBinSourceList: TStringList;
  {-returns the current list of bins (returns nil for none)}
type
  TcchBinName = array[0..CCHBinName-1] of Char;
  TBinArray   = array[1..cBinMax] of TcchBinName;
  PBinArray   = ^TBinArray;
var
  NumBinsReq:   Longint;      {number of bins required}
  NumBinsRec:   Longint;      {number of bins received}
  BinArray:     PBinArray;
  BinList:      TStringList;
  BinStr:       String;
  i:            Longint;
  DevCaps:      TFarProc;
  DrvHandle:    THandle;
  DriverName:   String;
begin
  CheckPrinter;
  Result   := nil;
  BinArray := nil;
  try
    DrvHandle := LoadLibrary (FDriver);
    if DrvHandle <> 0 then
    begin
      DevCaps := GetProcAddress (DrvHandle, 'DeviceCapabilities');
      if DevCaps<>nil then
      begin
        NumBinsReq := TDeviceCapabilities (DevCaps)(FDevice, FPort, DC_BinNames,
                                                    nil, FDeviceMode^);
        GetMem (BinArray, NumBinsReq * SizeOf (TcchBinName));
        NumBinsRec := TDeviceCapabilities (DevCaps)(FDevice, FPort, DC_BinNames,
                                                    PChar (BinArray), FDeviceMode^);
        if NumBinsRec <> NumBinsReq then
        begin
          {raise an exception}
          Raise EPrinter.Create ('Error retrieving Bin Source Info');
        end;  { if... }
        {now convert to TStringList}
        BinList := TStringList.Create;
        for i := 1 to NumBinsRec do
        begin
          BinStr := StrPas (BinArray^[i]);
          BinList.Add (BinStr);
        end;  { next i }
      end;  { if... }
      FreeLibrary (DrvHandle);
      Result := BinList;
    end {:} else
    begin
      {raise an exception}
      DriverName := StrPas (FDriver);
      Raise EPrinter.Create ('Error loading driver '+DriverName);
    end;  { else }
  finally
    if BinArray <> nil then
      FreeMem (BinArray, NumBinsReq * SizeOf (TcchBinName));
  end;  { try }
end;  { TPrintSet.GetBinSourceList }

function TPrintSet.GetPaperList: TStringList;
  {-returns the current list of paper sizes (returns nil for none)}
type
  TcchPaperName = array[0..CCHPaperName-1] of Char;
  TPaperArray   = array[1..cPaperNames] of TcchPaperName;
  PPaperArray   = ^TPaperArray;
var
  NumPaperReq:   Longint;      {number of paper types required}
  NumPaperRec:   Longint;      {number of paper types received}
  PaperArray:    PPaperArray;
  PaperList:     TStringList;
  PaperStr:      String;
  i:             Longint;
  DevCaps:       TFarProc;
  DrvHandle:     THandle;
  DriverName:    String;
begin
  CheckPrinter;
  Result     := nil;
  PaperArray := nil;
  try
    DrvHandle := LoadLibrary (FDriver);
    if DrvHandle <> 0 then
    begin
      DevCaps := GetProcAddress (DrvHandle, 'DeviceCapabilities');
      if DevCaps<>nil then
      begin
        NumPaperReq := TDeviceCapabilities (DevCaps)(FDevice, FPort, DC_PaperNames,
                                                     nil, FDeviceMode^);
        GetMem (PaperArray, NumPaperReq * SizeOf (TcchPaperName));
        NumPaperRec := TDeviceCapabilities (DevCaps)(FDevice, FPort, DC_PaperNames,
                                                     PChar (PaperArray), FDeviceMode^);
        if NumPaperRec <> NumPaperReq then
        begin
          {raise an exception}
          Raise EPrinter.Create ('Error retrieving Paper Info');
        end;  { if... }
        {now convert to TStringList}
        PaperList := TStringList.Create;
        for i := 1 to NumPaperRec do
        begin
          PaperStr := StrPas (PaperArray^[i]);
          PaperList.Add (PaperStr);
        end;  { next i }
      end;  { if... }
      FreeLibrary (DrvHandle);
      Result := PaperList;
    end {:} else
    begin
      {raise an exception}
      DriverName := StrPas (FDriver);
      Raise EPrinter.Create ('Error loading driver '+DriverName);
    end;  { else }
  finally
    if PaperArray <> nil then
      FreeMem (PaperArray, NumPaperReq * SizeOf (TcchPaperName));
  end;  { try }
end;  { TPrintSet.GetPaperList }

procedure TPrintSet.SetDeviceMode;
begin
  Printer.GetPrinter (FDevice, FDriver, FPort, FHandle);
  if FHandle = 0 then
  begin  {driver not loaded}
    Printer.PrinterIndex := Printer.PrinterIndex;
      {-forces Printer object to load driver}
  end;  { if... }
  Printer.GetPrinter (FDevice, FDriver, FPort, FHandle);
  if FHandle<>0 then
  begin
    FDeviceMode := Ptr (FHandle, 0);
      {-PDeviceMode now points to Printer.DeviceMode}
    FDeviceMode^.dmFields := 0;
  end {:} else
  begin
    FDeviceMode := nil;
    Raise EPrinter.Create ('Error retrieving DeviceMode');
  end;  { if... }
  FPrinter := Printer.PrinterIndex;
end;  { TPrintSet.SetDeviceMode }

procedure TPrintSet.UpdateDeviceMode;
  {-updates the loaded TDevMode structure}
var
  DrvHandle:   THandle;
  ExtDevCaps:  TFarProc;
  DriverName:  String;
  ExtDevCode:  Integer;
  OutDevMode:  PDevMode;
begin
  CheckPrinter;
  DrvHandle := LoadLibrary (FDriver);
  if DrvHandle <> 0 then
  begin
    ExtDevCaps := GetProcAddress (DrvHandle, 'ExtDeviceMode');
    if ExtDevCaps<>nil then
    begin
      ExtDevCode := TExtDeviceMode (ExtDevCaps)
        (0, DrvHandle, FDeviceMode^, FDevice, FPort,
         FDeviceMode^, nil, DM_IN_BUFFER or DM_OUT_BUFFER);
      if ExtDevCode <> IDOK then
      begin
        {raise an exception}
        raise EPrinter.Create ('Error updating printer driver.');
      end;  { if... }
    end;  { if... }
    FreeLibrary (DrvHandle);
  end {:} else
  begin
    {raise an exception}
    DriverName := StrPas (FDriver);
    Raise EPrinter.Create ('Error loading driver '+DriverName);
  end;  { else }
end;  { TPrintSet.UpdateDeviceMode }

procedure TPrintSet.SaveToDefaults;
  {-updates the default settings for the current printer}
var
  DrvHandle:   THandle;
  ExtDevCaps:  TFarProc;
  DriverName:  String;
  ExtDevCode:  Integer;
  OutDevMode:  PDevMode;
begin
  CheckPrinter;
  DrvHandle := LoadLibrary (FDriver);
  if DrvHandle <> 0 then
  begin
    ExtDevCaps := GetProcAddress (DrvHandle, 'ExtDeviceMode');
    if ExtDevCaps<>nil then
    begin
      ExtDevCode := TExtDeviceMode (ExtDevCaps)
        (0, DrvHandle, FDeviceMode^, FDevice, FPort,
         FDeviceMode^, nil, DM_IN_BUFFER OR DM_UPDATE);
      if ExtDevCode <> IDOK then
      begin
        {raise an exception}
        raise EPrinter.Create ('Error updating printer driver.');
      end {:} else
        SendMessage ($FFFF, WM_WININICHANGE, 0, 0);
    end;  { if... }
    FreeLibrary (DrvHandle);
  end {:} else
  begin
    {raise an exception}
    DriverName := StrPas (FDriver);
    Raise EPrinter.Create ('Error loading driver '+DriverName);
  end;  { else }
end;  { TPrintSet.SaveToDefaults }

procedure TPrintSet.SavePrinterAsDefault;
  {-saves the current printer as the Window's default}
var
  DeviceStr: String;
begin
  CheckPrinter;  {make sure new printer is loaded}
  {set the new device setting in the WIN.INI file}
  DeviceStr := StrPas (FDevice) + ',' + StrPas (FDriver) + ',' + StrPas (FPort) + #0;
  WriteProfileString ('windows', 'device', @DeviceStr[1]);
  {force write to WIN.INI}
  WriteProfileString (nil, nil, nil);
  {broadcast to everyone that WIN.INI changed}
  SendMessage ($FFFF, WM_WININICHANGE, 0, 0);
end;  { TPrintSet.SavePrinterAsDefault }

procedure TPrintSet.SetOrientation (Orientation: integer);
  {-sets the paper orientation}
begin
  CheckPrinter;
  FDeviceMode^.dmOrientation := Orientation;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_ORIENTATION;
end;  { TPrintSet.SetOrientation }

function TPrintSet.GetOrientation: integer;
  {-gets the paper orientation}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmOrientation;
end;  { TPrintSet.GetOrientation }

procedure TPrintSet.SetPaperSize (Size: integer);
  {-sets the paper size}
begin
  CheckPrinter;
  FDeviceMode^.dmPaperSize := Size;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_PAPERSIZE;
end;  { TPrintSet.SetPaperSize }

function TPrintSet.GetPaperSize: integer;
  {-gets the paper size}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmPaperSize;
end;  { TPrintSet.GetPaperSize }

procedure TPrintSet.SetPaperLength (Length: integer);
  {-sets the paper length}
begin
  CheckPrinter;
  FDeviceMode^.dmPaperLength := Length;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_PAPERLENGTH;
end;  { TPrintSet.SetPaperLength }

function TPrintSet.GetPaperLength: integer;
  {-gets the paper length}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmPaperLength;
end;  { TPrintSet.GetPaperLength }

procedure TPrintSet.SetPaperWidth (Width: integer);
  {-sets the paper width}
begin
  CheckPrinter;
  FDeviceMode^.dmPaperWidth := Width;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_PAPERWIDTH;
end;  { TPrintSet.SetPaperWidth }

function TPrintSet.GetPaperWidth: integer;
  {-gets the paper width}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmPaperWidth;
end;  { TPrintSet.GetPaperWidth }

procedure TPrintSet.SetScale (Scale: integer);
  {-sets the printer scale (whatever that is)}
begin
  CheckPrinter;
  FDeviceMode^.dmScale := Scale;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_SCALE;
end;  { TPrintSet.SetScale }

function TPrintSet.GetScale: integer;
  {-gets the printer scale}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmScale;
end;  { TPrintSet.GetScale }

procedure TPrintSet.SetCopies (Copies: integer);
  {-sets the number of copies}
begin
  CheckPrinter;
  FDeviceMode^.dmCopies := Copies;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_COPIES;
end;  { TPrintSet.SetCopies }

function TPrintSet.GetCopies: integer;
  {-gets the number of copies}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmCopies;
end;  { TPrintSet.GetCopies }

procedure TPrintSet.SetBin (Bin: integer);
  {-sets the paper bin}
begin
  CheckPrinter;
  FDeviceMode^.dmDefaultSource := Bin;
  FDeviceMode^.dmFields  := FDeviceMode^.dmFields or DM_DEFAULTSOURCE;
end;  { TPrintSet.SetBin }

function TPrintSet.GetBin: integer;
  {-gets the paper bin}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmDefaultSource;
end;  { TPrintSet.GetBin }

procedure TPrintSet.SetPrintQuality (Quality: integer);
  {-sets the print quality}
begin
  CheckPrinter;
  FDeviceMode^.dmPrintQuality := Quality;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_PRINTQUALITY;
end;  { TPrintSet.SetPrintQuality }

function TPrintSet.GetPrintQuality: integer;
  {-gets the print quality}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmPrintQuality;
end;  { TPrintSet.GetPrintQuality }

procedure TPrintSet.SetColor (Color: integer);
  {-sets the color (monochrome or color)}
begin
  CheckPrinter;
  FDeviceMode^.dmColor := Color;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_ORIENTATION;
end;  { TPrintSet.SetColor }

function TPrintSet.GetColor: integer;
  {-gets the color}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmColor;
end;  { TPrintSet.GetColor }

procedure TPrintSet.SetDuplex (Duplex: integer);
  {-sets the duplex setting}
begin
  CheckPrinter;
  FDeviceMode^.dmDuplex := Duplex;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_DUPLEX;
end;  { TPrintSet.SetDuplex }

function TPrintSet.GetDuplex: integer;
  {-gets the duplex setting}
begin
  CheckPrinter;
  Result := FDeviceMode^.dmDuplex;
end;  { TPrintSet.GetDuplex }

procedure TPrintSet.SetYResolution (YRes: integer);
  {-sets the y-resolution of the printer}
var
  PrintDevMode: Print.PDevMode;
begin
  CheckPrinter;
  PrintDevMode := @FDeviceMode^;
  PrintDevMode^.dmYResolution := YRes;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_YRESOLUTION;
end;  { TPrintSet.SetYResolution }

function  TPrintSet.GetYResolution: integer;
  {-gets the y-resolution of the printer}
var
  PrintDevMode: Print.PDevMode;
begin
  CheckPrinter;
  PrintDevMode := @FDeviceMode^;
  Result := PrintDevMode^.dmYResolution;
end;  { TPrintSet.GetYResolution }

procedure TPrintSet.SetTTOption (Option: integer);
  {-sets the TrueType option}
var
  PrintDevMode: Print.PDevMode;
begin
  CheckPrinter;
  PrintDevMode := @FDeviceMode^;
  PrintDevMode^.dmTTOption := Option;
  FDeviceMode^.dmFields := FDeviceMode^.dmFields or DM_TTOPTION;
end;  { TPrintSet.SetTTOption }

function TPrintSet.GetTTOption: integer;
  {-gets the TrueType option}
var
  PrintDevMode: Print.PDevMode;
begin
  CheckPrinter;
  PrintDevMode := @FDeviceMode^;
  Result := PrintDevMode^.dmTTOption;
end;  { TPrintSet.GetTTOption }

function TPrintSet.GetPrinterName: string;
  {-returns the name of the current printer}
begin
  CheckPrinter;
  Result := StrPas (FDevice);
end;  { TPrintSet.GetPrinterName }

function TPrintSet.GetPrinterPort: string;
  {-returns the port of the current printer}
begin
  CheckPrinter;
  Result := StrPas (FPort);
end;  { TPrintSet.GetPrinterPort }

function TPrintSet.GetPrinterDriver: string;
  {-returns the printer driver name of the current printer}
begin
  CheckPrinter;
  Result := StrPas (FDriver);
end;  { TPrintSet.GetPrinterDriver }

destructor TPrintSet.Destroy;
  {-destroys class}
begin
  if FDevice <> nil then
    FreeMem (FDevice, 255);
  if FDriver <> nil then
    FreeMem (FDriver, 255);
  if FPort <> nil then
    FreeMem (FPort, 255);
  inherited Destroy;
end; { TPrintSet.Destroy }

procedure CanvasTextOutAngle (OutputCanvas: TCanvas; X,Y: integer;
                              Angle: Word; St: string);
  {-prints text at the desired angle}
  {-current font must be TrueType!}
var
  LogRec:        TLogFont;
  NewFontHandle: HFont;
  OldFontHandle: HFont;
begin
  GetObject (OutputCanvas.Font.Handle, SizeOf (LogRec), Addr (LogRec));
  LogRec.lfEscapement := Angle;
  NewFontHandle := CreateFontIndirect (LogRec);
  OldFontHandle := SelectObject (OutputCanvas.Handle, NewFontHandle);
  OutputCanvas.TextOut (x, y, St);
  NewFontHandle := SelectObject (OutputCanvas.Handle, OldFontHandle);
  DeleteObject (NewFontHandle);
end; { CanvasTextOutAngle }

procedure SetPixelsPerInch;
  {-insures that PixelsPerInch is set so that text print at the desired size}
var
  FontSize: integer;
begin
  FontSize := Printer.Canvas.Font.Size;
  Printer.Canvas.Font.PixelsPerInch := GetDeviceCaps (Printer.Handle, LOGPIXELSY );
  Printer.Canvas.Font.Size := FontSize;
end;  { SetPixelsPerInch }

function GetResolution: TPoint;
  {-returns the resolution of the printer}
begin
  Result.X := GetDeviceCaps(Printer.Handle, LogPixelsX);
  Result.Y := GetDeviceCaps(Printer.Handle, LogPixelsY);
end;  { GetResolution }

procedure Register;
  {-registers the printset component}
begin
  RegisterComponents('Domain', [TPrintSet]);
end;  { Register }

end.  { EDSPrint }
