(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0124.PAS
  Description: Preventing a Form from Resizing
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)


In some cases, developers would want to create a regular window
(Form) in Delphi that contains some of the characteristics of a
dialog box.  For example, they do not want to allow their users
to resize the form at runtime due to user interface design
issues.  Other than creating the whole form as a dialog box,
there is not a property or a method to handle this in a regular
window in Delphi.  But due to the solid connection between Delphi
and the API layer, developers can accomplish this easily.

The following example demonstrates a way of handling the Windows
message "WM_GetMinMaxInfo" which allows the developer to restrict
the size of windows (forms) at runtime to a specific value.  In
this case, it will be used to disable the functionality of sizing
the window (form) at runtime.

Consider the following unit:

unit getminmax;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TForm1 = class(TForm)
  private
    { Private declarations }
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
              message WM_GETMINMAXINFO;
    procedure WMInitMenuPopup(var Msg: TWMInitMenuPopup);
              message WM_INITMENUPOPUP;
    procedure WMNCHitTest(var Msg: TWMNCHitTest);
              message WM_NCHitTest;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

 procedure TForm1.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
 begin
     inherited;
     with Msg.MinMaxInfo^ do
     begin
          ptMinTrackSize.x:= form1.width;
          ptMaxTrackSize.x:= form1.width;
          ptMinTrackSize.y:= form1.height;
          ptMaxTrackSize.y:= form1.height;
     end;
 end;

 procedure TForm1.WMInitMenuPopup(var Msg: TWMInitMenuPopup);
 begin
      inherited;
      if Msg.SystemMenu then
         EnableMenuItem(Msg.MenuPopup, SC_SIZE, MF_BYCOMMAND or MF_GRAYED)
 end;

 procedure TForm1.WMNCHitTest(var Msg: TWMNCHitTest);
 begin
      inherited;
      with Msg do
           if Result in [HTLEFT, HTRIGHT, HTBOTTOM, HTBOTTOMRIGHT,
                     HTBOTTOMLEFT, HTTOP, HTTOPRIGHT, HTTOPLEFT] then
              Result:= HTNOWHERE
 end;
end.  { End of Unit}

A message handler for the windows message "WM_GetMinMaxInfo" in
the code above was used to set the minimum and maximum TrackSize
of the window to equal the width and height of the form at design
time.  That was actually enough to disable the resizing of the
window (form), but the example went on to handle another couple
of messages just to make the application look professional.  The
first message was the "WMInitMenuPopup"  and that was to gray out
the size option from the System Menu so that the application does
not give the impression that this functionality is available.
The second message was the "WMNCHitTest" and that was used to
disable the change of the cursor icon whenever the mouse goes
over one of the borders of the window (form) for the same reason
which is not to give the impression that the resizing
functionality is available.

