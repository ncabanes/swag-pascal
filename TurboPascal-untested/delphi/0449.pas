
'Joe C. Hecht' <jhecht@wpo.borland.com>

Below are some code snippets to change the printer settings.
Wherever the changes are made, you could instead examine the printer
settings. See the documentation for ExtDeviceMode and the TDEVMODE
structure as well the printer escape GETSETPAPERBINS and GetDeviceCaps().

*********************************************
One way to change printer settings at the start of a print job is to
change the printers devicemode.

Example:


--------------------------------------------------------------------------------

var
Device : array[0..255] of char;
Driver : array[0..255] of char;
Port   : array[0..255] of char;
hDMode : THandle;
PDMode : PDEVMODE;
begin
  Printer.PrinterIndex := Printer.PrinterIndex;
  Printer.GetPrinter(Device, Driver, Port, hDMode);
  if hDMode <> 0 then begin
    pDMode := GlobalLock(hDMode);
    if pDMode <> nil then begin
      pDMode^.dmFields := pDMode^.dmFields or DM_COPIES;
      pDMode^.dmCopies := 5;
      GlobalUnlock(hDMode);
    end;
    GlobalFree(hDMode);
  end;
  Printer.PrinterIndex := Printer.PrinterIndex;
  Printer.BeginDoc;
  Printer.Canvas.TextOut(100,100, 'Test 1');
  Printer.EndDoc;

--------------------------------------------------------------------------------

Another way is to change TPrinter. This will enable you to change
settings in mid job. You must make the change >>>between<<< pages.

To do this:

Before every startpage() command in printers.pas in the Source\VCL
directory add something like:


--------------------------------------------------------------------------------

 DevMode.dmPaperSize:=DMPAPER_LEGAL
{any other devicemode settings go here}
 Windows.ResetDc(dc,Devmode^);

--------------------------------------------------------------------------------

This will reset the pagesize. you can look up DEVMODE in the help to
find other paper sizes.

You will need to rebuild the vcl source for this to work, by adding the
path to the VCL source directory to the beginning of the library
path s tatement under tools..options.. library...libaray path.
Quit Delphi then do a build all.

Another quick note...

When changing printers, be aware that fontsizes may not always scale
properly. To ensure proper scaling set the PixelsPerInch property of
the font.

Here are two examples:


--------------------------------------------------------------------------------

uses Printers;

var
  MyFile: TextFile;
begin
  AssignPrn(MyFile);
  Rewrite(MyFile);

  Printer.Canvas.Font.Name := 'Courier New';
  Printer.Canvas.Font.Style := [fsBold];
  Printer.Canvas.Font.PixelsPerInch:=
    GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY);

  Writeln(MyFile, 'Print this text');

  System.CloseFile(MyFile);
end;

uses Printers;

begin
  Printer.BeginDoc;
  Printer.Canvas.Font.Name := 'Courier New';
  Printer.Canvas.Font.Style := [fsBold];

  Printer.Canvas.Font.PixelsPerInch:=
    GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY);

  Printer.Canvas.Textout(10, 10, 'Print this text');

  Printer.EndDoc;
end;
