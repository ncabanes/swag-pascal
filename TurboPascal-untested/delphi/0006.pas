unit CurrEdit;

(**************************************************************************
 This is my first custom control, so please be merciful. I needed a simple
 currency edit field, so below is my attempt. It has pretty good behavior
 and I have posted it up to encourage others to share their code as well.

 Essentially, the CurrencyEdit field is a modified memo field. I have put
 in keyboard restrictions, so the user cannot enter invalid characters.
 When the user leaves the field, the number is reformatted to display
 appropriately. You can left-, center-, or right-justify the field, and
 you can also specify its display format - see the FormatFloat command.

 The field value is stored in a property called Value so you should read
 and write to that in your program. This field is of type Extended.

 If you like this control you can feel free to use it, however, if you
 modify it, I would like you to send me whatever you did to it. If you
 send me your CIS ID, I will send you copies of my custom controls that
 I develop in the future. Please feel free to send me anything you are
 working on as well. Perhaps we can spark ideas!

 Robert Vivrette, Owner
 Prime Time Programming
 PO Box 5018
 Walnut Creek, CA  94596-1018

 Fax: (510) 939-3775
 CIS: 76416,1373
 Net: RobertV@ix.netcom.com

 Thanks to Massimo Ottavini, Thorsten Suhr, Bob Osborn, Mark Erbaugh, Ralf

 Gosch, Julian Zagorodnev, and Grant R. Boggs for their enhancements!

 Please look for this and other components in the "Unofficial Newsletter of
 Delphi Users" posted on the Borland Delphi forum on Compuserve (GO DELPHI)
 in the "Delphi IDE" file section.

**************************************************************************)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Menus, Forms, Dialogs, StdCtrls;

type
  TCurrencyEdit = class(TCustomMemo)
  private
    DispFormat: string;
    FieldValue: Extended;
    FDecimalPlaces : Word;
    FPosColor : TColor;
    FNegColor : TColor;
    procedure SetFormat(A: string);
    procedure SetFieldValue(A: Extended);

    procedure SetDecimalPlaces(A: Word);
    procedure SetPosColor(A: TColor);
    procedure SetNegColor(A: TColor);
    procedure CMEnter(var Message: TCMEnter);  message CM_ENTER;
    procedure CMExit(var Message: TCMExit);    message CM_EXIT;
    procedure FormatText;
    procedure UnFormatText;
  protected
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Alignment default taRightJustify;
    property AutoSize default True;

    property BorderStyle;
    property Color;
    property Ctl3D;
    property DecimalPlaces: Word read FDecimalPlaces write SetDecimalPlaces default 2;
    property DisplayFormat: string read DispFormat write SetFormat;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property NegColor: TColor read FNegColor write SetNegColor default clRed;
    property ParentColor;
    property ParentCtl3D;

    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property PosColor: TColor read FPosColor write SetPosColor default clBlack;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property Value: Extended read FieldValue write SetFieldValue;
    property Visible;
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
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Additional', [TCurrencyEdit]);
end;

constructor TCurrencyEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := False;
  Alignment := taRightJustify;
  Width := 121;
  Height := 25;
  DispFormat := '$,0.00;($,0.00)';
  FieldValue := 0.0;
  FDecimalPlaces := 2;
  FPosColor := Font.Color;
  FNegColor := clRed;
  AutoSelect := False;

  {WantReturns := False;}
  WordWrap := False;
  FormatText;
end;

procedure TCurrencyEdit.SetFormat(A: String);
begin
  if DispFormat <> A then
    begin
      DispFormat:= A;
      FormatText;
    end;
end;

procedure TCurrencyEdit.SetFieldValue(A: Extended);
begin
  if FieldValue <> A then
    begin
      FieldValue := A;
      FormatText;
    end;
end;

procedure TCurrencyEdit.SetDecimalPlaces(A: Word);
begin
  if DecimalPlaces <> A then

    begin
      DecimalPlaces := A;
      FormatText;
    end;
end;

procedure TCurrencyEdit.SetPosColor(A: TColor);
begin
  if FPosColor <> A then
    begin
      FPosColor := A;
      FormatText;
    end;
end;

procedure TCurrencyEdit.SetNegColor(A: TColor);
begin
  if FNegColor <> A then
    begin
      FNegColor := A;
      FormatText;
    end;
end;

procedure TCurrencyEdit.UnFormatText;
var
  TmpText : String;
  Tmp     : Byte;

  IsNeg   : Boolean;
begin
  IsNeg := (Pos('-',Text) > 0) or (Pos('(',Text) > 0);
  TmpText := '';
  For Tmp := 1 to Length(Text) do
    if Text[Tmp] in ['0'..'9',DecimalSeparator] then
      TmpText := TmpText + Text[Tmp];
  try
    If TmpText='' Then TmpText := '0.00';
    FieldValue := StrToFloat(TmpText);
    if IsNeg then FieldValue := -FieldValue;
  except
    MessageBeep(mb_IconAsterisk);
  end;
end;

procedure TCurrencyEdit.FormatText;

begin
  Text := FormatFloat(DispFormat,FieldValue);
  if FieldValue < 0 then
    Font.Color := NegColor
  else
    Font.Color := PosColor;
end;

procedure TCurrencyEdit.CMEnter(var Message: TCMEnter);
begin
  SelectAll;
  inherited;
end;

procedure TCurrencyEdit.CMExit(var Message: TCMExit);
begin
  UnformatText;
  FormatText;
  Inherited;
end;

procedure TCurrencyEdit.KeyPress(var Key: Char);
Var
  S : String;
  frmParent : TForm;
  btnDefault : TButton;
  i : integer;

  wID : Word;
  LParam : LongRec;
begin
  {#8 is for Del and Backspace keys.}
  if Not (Key in ['0'..'9','.','-', #8, #13]) Then Key := #0;
  case Key of
    #13 : begin
            frmParent := GetParentForm(Self);
            UnformatText;
            {find default button on the parent form if any}
            btnDefault := nil;
            for i := 0 to frmParent.ControlCount -1 do
              if frmParent.Controls[i] is TButton then
                if (frmParent.Controls[i] as TButton).Default then

                  btnDefault := (frmParent.Controls[i] as TButton);
            {if there's a default button, then make the parent form think it was pressed}
            if btnDefault <> nil then
              begin
                wID := GetWindowWord(btnDefault.Handle, GWW_ID);
                LParam.Lo := btnDefault.Handle;
                LParam.Hi := BN_CLICKED;
                SendMessage(frmParent.Handle, WM_COMMAND, wID, longint(LParam) );
              end;
            Key := #0;
          end;
          { allow only one dot in the number }

    '.' : if ( Pos('.',Text) >0 ) then Key := #0;
          { allow only one '-' in the number and only in the first position: }
    '-' : if ( Pos('-',Text) >0 ) or ( SelStart > 0 ) then Key := #0;
  else
    { make sure no other character appears before the '-' }
    if ( Pos('-',Text) >0 ) and ( SelStart = 0 ) and (SelLength=0) then Key := #0;
  end;

  if Key <> Char(vk_Back) then
    begin
     {S is a model of Text if we accept the keystroke.  Use SelStart and

     SelLength to find the cursor (insert) position.}
      S := Copy(Text,1,SelStart)+Key+Copy(Text,SelStart+SelLength+1,Length(Text));
      if ((Pos(DecimalSeparator, S) > 0) and
         (Length(S) - Pos(DecimalSeparator, S) > FDecimalPlaces))  {too many decimal places}
           or ((Key = '-') and (Pos('-', Text) <> 0))     {only one minus...}
           or (Pos('-', S) > 1)                           {... and only at beginning}
      then Key := #0;

    end;

  if Key <> #0 then inherited KeyPress(Key);
end;

procedure TCurrencyEdit.CreateParams(var Params: TCreateParams);
var
 lStyle : longint;
begin
  inherited CreateParams(Params);
  case Alignment of
    taLeftJustify  : lStyle := ES_LEFT;
    taRightJustify : lStyle := ES_RIGHT;
    taCenter       : lStyle := ES_CENTER;
  end;
  Params.Style := Params.Style or lStyle;
end;

end.