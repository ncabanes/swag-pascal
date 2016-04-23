unit Chg_prn;

interface

uses WinTypes, WinProcs, Classes, sysutils, printers, dialogs, messages;

procedure ChangeDefaultPrinter;

implementation

procedure ChangeDefaultPrinter;

var szPrinterName, szIniInfo, szSection: PChar ;

begin
  try
   GetMem(szPrinterName,SizeOf(Char) * 256);                            {allocate memory}
   GetMem(szIniInfo,SizeOf(Char) * 256);
   GetMem(szSection,10) ;
   StrPCopy(szPrinterName,                                              {get name for printer selected in printerindex}
            Copy(Printer.Printers[Printer.PrinterIndex], 1,
            Pos('on', Printer.Printers[Printer.PrinterIndex]) - 2 ));
   GetProfileString('DEVICES', szPrinterName, nil, szIniInfo, 254) ;    {locate device info in win.ini}
   if szIniInfo^ <> #0 then
     begin                                                              {if device found, then..}
     StrCat(szPrinterName,',') ;                                        {prepare new device line}
     StrCat(szPrinterName,szIniInfo) ;
     WriteProfileString('Windows','DEVICE',szPrinterName) ;             {update ini file}
     StrCopy(szSection,'Windows') ;
     PostMessage(HWND_BROADCAST,WM_WININICHANGE,0,LongInt(szSection)) ; {notify all apps - ini has changed}
   end ;
   FreeMem(szPrinterName,SizeOf(Char) * 256) ;                          {release memory}
   FreeMem(szIniInfo,SizeOf(Char) * 256) ;
   FreeMem(szSection,10) ;
 except
   on E: EOutOfMemory do ShowMessage(E.Message) ;                       {handles no memory to allocate}
   on E: EInvalidPointer do ShowMessage(E.Message) ;                    {handles bad pointer}
 end ;
end;

end.
