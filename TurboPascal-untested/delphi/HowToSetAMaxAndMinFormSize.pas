(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0110.PAS
  Description: How to set a max and min form size
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

{
When you want to control how much your users can resize your
form, you can control that by setting the MinMax values.  (If
you use the resize method to limit the size, it will work, but
it won't look quite as good.)

Note:  To make it so that the user cannot change the form's
size at all, make the min and max sizes the same values.

This is an example of how to declare and use the wm_GetMinMaxInfo
windows message in your applications.
}
unit MinMax;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TForm1 = class(TForm)
  private
    { Private declarations }
    procedure WMGetMinMaxInfo(var MSG: Tmessage); message WM_GetMinMaxInfo;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.WMGetMinMaxInfo(var MSG: Tmessage);
Begin
  inherited;
  with PMinMaxInfo(MSG.lparam)^ do
  begin
    with ptMinTrackSize do
    begin
      X := 300;
      Y := 150;
    end;
    with ptMaxTrackSize do
    begin
      X := 350;
      Y := 250;
    end;
  end;
end;

end.

