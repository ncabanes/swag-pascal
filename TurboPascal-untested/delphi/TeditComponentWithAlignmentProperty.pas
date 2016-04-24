(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0329.PAS
  Description: TEdit Component with Alignment property
  Author: BOB SWART
  Date: 08-30-97  10:09
*)


Hi Jon & Aimee Robertson,

> I'm trying to find a TEdit component which contains an
> alignment property.  The alignment during editing isn't
> important, but the alignment of the text when the
> control does not have focus is important.
>
> I've searched every Delphi site I can find.  Does any one
> know of such a component?  If so, where can I find it?

OK, so I need to make my components more visible on my site, thanks for
the hint... <grin>

In the meantime, here's my TBRightEdit component (you need to write your
register procedure yourself, as this is in a separate unit for a design
time package ;-)

unit DrBobRED;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Menus, Dialogs, StdCtrls;

Type
  TBRightEdit = class(TCustomMemo)
  private
    { Private declarations }
    FOnMaxLength: TNotifyEvent;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Change; override; { dynamic; }
  published
    { Published declarations }
  { property AutoSelect; }
  { property AutoSize; }
    property BorderStyle;
    property CharCase;
    property Color;
    property Ctl3D;
    property Cursor;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Height;
    property HelpContext;
    property HideSelection;
    property Hint;
    property Left;
    property MaxLength;
    property Name;
    property OEMConvert;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
  { property PasswordChar; }
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property Tag;
    property Text;
    property Top;
    property Visible;
    property Width;

    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMaxLength: TNotifyEvent read FOnMaxLength write
FOnMaxLength;
  end;

implementation

constructor TBRightEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alNone;
  Alignment := taRightJustify;
  ScrollBars := ssNone;
  WantReturns := False;
  WantTabs := False;
  WordWrap := False;
  OnMaxLength := nil;
end;

procedure TBRightEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if AHeight > (2 * abs(Font.Height)) then AHeight := 2 *
abs(Font.Height);
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TBRightEdit.KeyDown(var Key: Word; Shift: TShiftState);
{ prevent Ctrl+Enter as well }
begin
  if Key in [10, 13] then Key := 0
  else
    inherited KeyDown(Key, Shift)
end;

procedure TBRightEdit.KeyPress(var Key: Char);
{ prevent Ctrl+Enter as well }
begin
  if Key in [#10, #13] then Key := #0
  else
    inherited KeyPress(Key)
end;

procedure TBRightEdit.Change;
{ prevent Ctrl+Enter as well }
var MyText: String;
    CrPos: integer;
begin
  MyText := Text;
  CrPos := Pos(#13, MyText);
  if CrPos > 0 then Text := Copy(MyText, 1, CrPos-1)
  else
    inherited Change;
  { now check for max length... }
  if (MaxLength > 0) and (Length(Text) >= MaxLength) then
    if Assigned(FOnMaxLength) then FOnMaxLength(Self)
end;

end.

> Jon Robertson

Groetjes,
          Bob Swart (aka Dr.Bob - www.drbob42.com)

--
drs. Robert E. (Bob) Swart, Knowledge Engineer Specialist, Bolesian
P.O. Box 799, 5702 NP HELMOND, THE NETHERLANDS. fax: +31-492-533985
E-mail: bob@bolesian.nl (work), drbob@pi.net (home) & [100434,2072]

