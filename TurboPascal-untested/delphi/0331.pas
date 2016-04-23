
Why not use the TRichEdit Control to do the work for you? I created an
extended RichEdit control with a RTFText property that you can read and
write to. To do conversions, just set the text property of the control,
and read the RTFtext and vice versa.

  TAXRichEdit = class(TRichEdit)
  private
    { Private declarations }
    FStream: TMemoryStream;
    procedure SetRTFText(RichText: string);
    function GetRTFText: string;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property RTFText: string read GetRTFText write SetRTFText;
  end;

implementation

constructor TAXRichEdit.Create(AOwner: TComponent);
begin

  Inherited Create(AOwner);

  FStream := TMemoryStream.Create;

end;

destructor TAXRichEdit.Destroy;
begin

  FStream.Free;

  inherited Destroy;

end;


procedure TAXRichEdit.SetRTFText(RichText: string);
begin

  FStream.Clear;
  FStream.WriteBuffer(RichText[1], Length(RichText));
  FStream.Position := 0;
  Lines.LoadFromStream(FStream);

end;


function TAXRichEdit.GetRTFText: string;
begin

  FStream.Clear;
  Lines.SaveToStream(FStream);
  Result := PChar(FStream.Memory);

end;


HTH,
Robert Cram
rcram@knoware.nl
