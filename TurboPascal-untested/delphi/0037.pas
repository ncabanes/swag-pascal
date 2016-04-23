
>I need to draw to a Windows metafile. Delphi does not directly support this,
>so I plan to use API calls to create the metafile. Creating a Metafile returns
>a THandle which can be cast to a DC.
>
>In delphi, how can I use the THandle to get/create a Canvas for drawing?

I've asked a similar question a few days ago but got no response, so
I figured it out myself. Here's the code. (hope it's what you need).

unit Metaform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    Image1: TImage;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

type
  TMetafileCanvas = class(TCanvas)
  private
    FClipboardHandle: THandle;
    FMetafileHandle: HMetafile;
    FRect: TRect;
  protected
    procedure CreateHandle; override;
    function GetMetafileHandle: HMetafile;
  public
    constructor Create;
    destructor Destroy; override;
    property Rect: TRect read FRect write FRect;
    property MetafileHandle: HMetafile read GetMetafileHandle;
  end;

constructor TMetafileCanvas.Create;
begin
  inherited Create;
  FClipboardHandle := GlobalAlloc(
    GMEM_SHARE or GMEM_ZEROINIT, SizeOf(TMetafilePict));
end;

destructor TMetafileCanvas.Destroy;
begin
  DeleteMetafile(CloseMetafile(Handle));
  if Bool(FClipboardHandle) then GlobalFree(FClipboardHandle);
  if Bool(FMetafileHandle) then DeleteMetafile(FMetafileHandle);
  inherited Destroy;
end;

procedure TMetafileCanvas.CreateHandle;
var
  MetafileDC: HDC;
begin
  { Create a metafile DC in memory }
  MetafileDC := CreateMetaFile(nil);
  if Bool(MetafileDC) then
  begin
    { Map the top,left corner of the displayed rectangle to the
top,left of the
      device context. Leave a border of 10 logical units around the
picture. }
    with FRect do SetWindowOrg(MetafileDC, Left - 10, Top - 10);
    { Set the extent of the picture with a border of 10 logical units.
}
    with FRect do SetWindowExt(MetafileDC, Right - Left + 20, Bottom -
Top + 20);
    { Play any valid metafile contents to it. }
    if Bool(FMetafileHandle) then
    begin
      PlayMetafile(MetafileDC, FMetafileHandle);
    end;
  end;
  Handle := MetafileDC;
end;

function TMetafileCanvas.GetMetafileHandle: HMetafile;
var
  MetafilePict: PMetafilePict;
  IC: HDC;
  ExtRect: TRect;
begin
  if Bool(FMetafileHandle) then DeleteMetafile(FMetafileHandle);
  FMetafileHandle := CloseMetafile(Handle);
  Handle := 0;
  { Prepair metafile for clipboard display. }
  MetafilePict := GlobalLock(FClipboardHandle);
  MetafilePict^.mm := mm_AnIsoTropic;
  IC := CreateIC('DISPLAY', nil, nil, nil);
  SetMapMode(IC, mm_HiMetric);
  ExtRect := FRect;
  DPtoLP(IC, ExtRect, 2);
  DeleteDC(IC);
  MetafilePict^.xExt := ExtRect.Right - ExtRect.Left;
  MetafilePict^.yExt := ExtRect.Top - ExtRect.Bottom;
  MetafilePict^.HMF :=  FMetafileHandle;
  GlobalUnlock(FClipboardHandle);
  { I'm giving you this handle, but please do NOT eat it. }
  Result := FClipboardHandle;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  MetafileCanvas : TMetafileCanvas;
begin
  MetafileCanvas := TMetafileCanvas.Create;
  MetafileCanvas.Rect := Rect(0,0,500,500);
  MetafileCanvas.Ellipse(10,10,400,400);
  Image1.Picture.Metafile.LoadFromClipboardFormat(
    cf_MetafilePict, MetafileCanvas.MetafileHandle, 0);
  MetafileCanvas.Free;
end;

end.

