(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0396.PAS
  Description: TEdit component with Left
  Author: EDDIE SHIPMAN
  Date: 01-02-98  07:34
*)


unit AlignEdit;
(*
   Edit Component that allows left, centered, or right justified text.
   Be sure to use the MaxLength property to disallow overflow of the
   control.

   This is essentially a multiline control set to be the size of a single
   line edit control, wherein the text alignment is available.

*)
interface

uses
  Windows, Messages, Classes, Controls, StdCtrls;

type
  TAlignEdit = class(TEdit)
  private
    { Private declarations }
    FTextAlign : TAlignment;
    FMaxLength: Integer;
    procedure SetTextAlignment(Value: TAlignment);
    procedure SetMaxLength(Value: Integer);
    procedure CreateWnd; override;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  published
    { Published declarations }
    property MaxLength: Integer        read FMaxLength write SetMaxLength
default 0;
    property Alignment : TAlignment read FTextAlign write SetTextAlignment
default taLeftJustify;
  end;

procedure Register;

implementation

procedure TAlignEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or ES_MULTILINE;
    case FTextAlign of
    taLeftJustify:
      begin
        Style := Style or ES_LEFT;
      end;
    taCenter:
      begin
        Style := Style or ES_CENTER;
      end;
    taRightJustify:
      begin
        Style := Style or ES_RIGHT;
      end;
    end;
  end;
end;

procedure TAlignEdit.SetTextAlignment(Value: TAlignment);
begin
  if FTextAlign <> Value then
  begin
    FTextAlign := Value;
    RecreateWnd;
  end;
end;

procedure TAlignEdit.SetMaxLength(Value: Integer);
begin
  if FMaxLength <> Value then
  begin
    FMaxLength := Value;
    if HandleAllocated then SendMessage(Handle, EM_LIMITTEXT, Value, 0);
  end;
end;

procedure TAlignEdit.CreateWnd;
begin
  {
    had to override this method because it was not updating
    the EM_LIMITTEXT when the alignment was set to taLeftJustify
  }
  inherited CreateWnd;
  SendMessage(Handle, EM_LIMITTEXT, FMaxLength, 0);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TAlignEdit]);
end;

end.

