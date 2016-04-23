
From: Mark Pritchard <pritchma@ozemail.com.au>

Here is a free one (took around half an hour to put together, it doesn't grab the parent font correctly, but I couldn't be bothered putting any more time into it) -



--------------------------------------------------------------------------------


unit IDSLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
Dialogs,
  ExtCtrls;

type
  TIDSLabel = class(TBevel)
  private
    { Private declarations }
    FAlignment : TAlignment;
    FCaption : String;
    FFont : TFont;
    FOffset : Byte;

    FOnChange : TNotifyEvent;

    procedure SetAlignment( taIn : TAlignment );
    procedure SetCaption( const strIn : String);
    procedure SetFont( fntNew : TFont );
    procedure SetOffset( bOffNew : Byte );
  protected
    { Protected declarations }
    constructor Create( compOwn : TComponent ); override;
    destructor Destroy; override;
    procedure Paint; override;
  public
    { Public declarations }
  published
    { Published declarations }
    property Alignment : TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Caption : String read FCaption write SetCaption;
    property Font : TFont read FFont write SetFont;
    property Offset : Byte read FOffset write SetOffset;

    property OnChange : TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TIDSLabel.Create;
begin
   inherited Create(compOwn);

   FFont := TFont.Create;
   with compOwn as TForm do
       FFont.Assign(Font);

   Offset := 4;
   Height := 15;
end;

destructor TIDSLabel.Destroy;
begin
   FFont.Free;

   inherited Destroy;
end;

procedure TIDSLabel.Paint;
var
   wXPos, wYPos : Word;
begin

   {Draw the bevel}
   inherited Paint;

   {Retreive the font}
   Canvas.Font.Assign(Font);

   {Calculate the y position}
   wYPos := (Height - Canvas.TextHeight(Caption)) div 2;

   {Calculate the x position}
   wXPos := Offset;
   case Alignment of
       taRightJustify: wXPos := Width - Canvas.TextWidth(Caption) - Offset;
       taCenter:       wXPos := (Width - Canvas.TextWidth(Caption)) div 2;
   end;
   Canvas.Brush := Parent.Brush;
   Canvas.TextOut(wXPos,wYPos,Caption);

end;

procedure TIDSLabel.SetAlignment;
begin
   FAlignment := taIn;
   Invalidate;
end;

procedure TIDSLabel.SetCaption;
begin
   FCaption := strIn;

   if Assigned(FOnChange) then
       FOnChange(Self);

   Invalidate;
end;

procedure TIDSLabel.SetFont;
begin
   FFont.Assign(fntNew);
   Invalidate;
end;

procedure TIDSLabel.SetOffset;
begin
   FOffset := bOffNew;
   Invalidate;
end;

end.
