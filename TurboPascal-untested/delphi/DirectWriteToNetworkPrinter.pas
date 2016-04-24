(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0219.PAS
  Description: Direct write to network printer
  Author: PETER VAN LONKHUYZEN
  Date: 03-04-97  13:18
*)


unit Rawprint;

interface
uses printers,windows;

type TRawprinter =class(TPrinter)
                  public
                    dc2 : HDC;
                    aborted : boolean;
                    printing : boolean;
                    lasttime : integer;
                    procedure abort;
                    function startraw : boolean;
                    function endraw: boolean;
                    function write(s : string): boolean;
                    function writeln: boolean;
                    destructor destroy; override;
                    procedure settimer;
                    function printerror : boolean;
                  end;
implementation
uses sysutils,forms,dialogs,controls;

procedure TRawPrinter.settimer;
begin
  lasttime:=gettickcount;
end;

function TRawPrinter.printerror : boolean;
var r : integer;
begin
  result:=false;
  if (gettickcount>lasttime+15000) or (gettickcount<lasttime) then
  begin
    r:=messagedlg('Error '+inttostr(getlasterror)+' Printing on '+printers[printerindex],mterror,[mbretry,mbabort,mbignore],0);
    if r=mrretry then
      result:=false
    else
    begin
      result:=true;
      if r=mrabort then
        abort;
    end;
    settimer;
  end;
end;

procedure TRawPrinter.abort;
begin
  abortdoc(dc2);
  endraw;
end;

function AbortProc(Prn: HDC; Error: Integer): Bool; stdcall;
begin
  Application.ProcessMessages;
  Result := not TRawprinter(Printer).Aborted;
end;

type
  TPrinterDevice = class
    Driver, Device, Port: String;
    constructor Create(ADriver, ADevice, APort: PChar);
    function IsEqual(ADriver, ADevice, APort: PChar): Boolean;
  end;

constructor TPrinterDevice.Create(ADriver, ADevice, APort: PChar);
begin
  inherited Create;
  Driver := ADriver;
  Device := ADevice;
  Port := APort;
end;

function TPrinterDevice.IsEqual(ADriver, ADevice, APort: PChar): Boolean;
begin
  Result := (Device = ADevice) and (Port = APort);
end;


destructor TRawprinter.destroy;
begin
  if dc2<>0 then
    deletedc(dc2);
end;

function TRawprinter.startraw:boolean;
var
  CTitle: array[0..31] of Char;
  CMode : Array[0..4] of char;
  DocInfo: TDocInfo;
  r : integer;
begin
  result:=false;
  StrPLCopy(CTitle, Title, SizeOf(CTitle) - 1);
  StrPCopy(CMode, 'RAW');
  FillChar(DocInfo, SizeOf(DocInfo), 0);
  with DocInfo do
  begin
    cbSize := SizeOf(DocInfo);
    lpszDocName := CTitle;
    lpszOutput := nil;
    lpszDatatype :=CMode;
  end;
  with TPrinterDevice(Printers.Objects[PrinterIndex]) do
  begin
    if dc2=0 then
    begin
      DC2 := CreateDC(PChar(Driver), PChar(Device), PChar(Port), nil);
      if dc2=0 then
      begin
        result:=false;
        exit;
      end;
     SetAbortProc(dc2, AbortProc);
   end;
  end;
  settimer;
  aborted:=false;
  repeat
    application.processmessages;
  until (StartDoc(dc2, DocInfo)>0) or printerror;
  if not aborted then
    printing:=true;
  result:=printing;
end;

function TRawprinter.endraw : boolean;
begin
  settimer;
  if not aborted and printing then
  repeat
    application.processmessages;
  until (windows.enddoc(dc2)>0) or printerror;
  printing:=false;
  result:=not aborted;
end;

type passrec = packed record
                 l : word;
                 s : Array[0..255] of char;
               end;
var pass : Passrec;
function TRawprinter.write(s : string):boolean;
var tmp : string;
begin
result:=false;
  if not aborted and printing then
  while s<>'' do
  begin
    result:=false;
    tmp:=copy(s,1,255);
    delete(s,1,255);
    pass.l:=length(tmp);
    strpcopy(pass.s,tmp);
    settimer;
    repeat
      application.processmessages
    until (escape(dc2,PASSTHROUGH,0,@pass,nil)>=0) or printerror;
    if aborted then
      break;
    result:=true;
  end;
end;

function TRawprinter.writeln : boolean;
begin
  pass.l:=2;
  strpcopy(pass.s,#13#10);
  settimer;
  repeat
    application.processmessages
  until (escape(dc2,PASSTHROUGH,0,@pass,nil)>=0) or printerror;
  result:=not aborted;
end;

end.


