(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0175.PAS
  Description: Tabbed List Box Component
  Author: SWAG SUPPORT TEAM
  Date: 08-30-96  09:36
*)

unit ListboxT;

interface

Uses Forms, Controls, StdCtrls;

Type
  TListBoxTabs = Class (TListBox)
    public
      procedure CreateParams (var Params: TCreateParams); override;
      Procedure SetTabStops (Val: Array of Cardinal);
      { Remember - tabstops are in dialog units, which is approx
        1/4 the width of an average character }
    end;

Procedure Register;

implementation

Uses
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  WinTypes, WinProcs,
  {$ENDIF}
  Classes, Messages;

procedure TListBoxTabs.CreateParams (var Params: TCreateParams);
begin
  inherited CreateParams (Params);
  with Params do
    Style := Style or lbs_UseTabStops;
  end;

procedure TListBoxTabs.SetTabStops (Val: Array of Cardinal);
begin
  SendMessage (Handle, lb_SetTabStops, High (Val) - Low (Val) + 1, LongInt (@Val));
  end;


Procedure Register;
begin
  RegisterComponents ('My Stuff', [TListboxTabs]);
  end;

end.

