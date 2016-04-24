(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0362.PAS
  Description: Suppressing Scroll Bar
  Author: JEAN DUFRANNE
  Date: 01-02-98  07:33
*)


>I am trying to suppress the creation of the scrollbars that automatically
>pop up in listboxes when the number of items in the listbox exceeds the
>height of the listbox.  I would like to provide my own scroll bar elsewhere
>on the form.

unit NewListBox;
interface
uses
  Windows, Classes, StdCtrls, controls,checklst;
type
  TNoVertListBox = class(TCheckListBox)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;
procedure Register;
implementation
procedure TNoVertListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  CreateSubClass(Params, 'NoVertListBox');
  with Params do
  begin
    Style := Style and not WS_HSCROLL ;
    Style := Style and not WS_VSCROLL ;
  end;
end;
procedure Register;
begin
  RegisterComponents('Standard', [TNoVertListBox]);
end;


