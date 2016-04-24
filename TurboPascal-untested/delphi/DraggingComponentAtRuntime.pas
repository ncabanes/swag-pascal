(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0383.PAS
  Description: Dragging component at run-time
  Author: THANH QUACH
  Date: 01-02-98  07:34
*)


Since I installed IE4, some of my mails are sometime removed without a =
warning. Anybody knows why?. May be I just miss a simple setup.  =20

Here is the code to use to drag a component on a form at run-time.=20

procedure TForm1.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove =$F012; // what a number
begin
  ReleaseCapture; // See Win32 API help
  Button1.perform(WM_SysCommand, SC_DragMove, 0);
end.


