(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0385.PAS
  Description: Object Caption
  Author: RORY DAULTON
  Date: 01-02-98  07:34
*)


Pedro,

If I understand you correctly, you want to be able to access (and show) the
caption of ANY control, regardless of its type, whether is is a TButton,
TForm, TLabel, and so on.  Is that right?

If so, the difficulty is this: although all descendants of TControl have a
Caption property, within TControl and some of its descendants the property
is protected, rather than public or published.  So, trying
TControl(Sender).Caption gives you an error.  Here is a trick, though, to
access that Caption property.

Add this in the implementation section of your unit:

type
  TCaptionControl = class(TControl)
  public
    property Caption;
  end;

You can then access the Caption of any control with
TCaptionControl(Sender).Caption, as in the following:

procedure TForm1.Label1Click(Sender: TObject);
begin
  ShowMessage(TCaptionControl(Sender).Caption);
end;

If you need to ensure that Sender is a descendant of TControl, then use:

procedure TForm1.Label1Click(Sender: TObject);
begin
  if Sender is TControl then
    ShowMessage(TCaptionControl(Sender).Caption);
end;

Note that using (Sender as TCaptionControl).Caption will not work, since
Sender will be a TControl but not a TCaptionControl.  Also note that some
controls (like TEdit) do not have an accessible Caption, but my code will
get it anyway!  For example, a TEdit's Caption is its Text.  For some other
controls it may be nonsense.


