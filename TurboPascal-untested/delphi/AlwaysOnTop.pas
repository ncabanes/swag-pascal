(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0397.PAS
  Description: Always on Top
  Author: TODD JACOBS
  Date: 01-02-98  07:34
*)



(* Always on Top *)

{I had a hard time finding out how to ensure a form always remains on top 
of all other forms. fsAlwaysOnTop only affects the z-order within the 
current application. To ensure that it remains on top of other forms from 
other programs as well, one needs to use the Windows API.

Including the following in a form's OnCreate event will designate it as a 
topmost window.}

     procedure TYourForm.FormCreate(Sender: TObject);
     begin
          SetWindowPos(YourForm.Handle,
          HWND_TOPMOST,
          0, 0, 0, 0,
          SWP_NOMOVE OR
          SWP_NOACTIVATE OR
          SWP_NOSIZE);
     end;

{However, you need to keep reminding Windows to restore your window to the 
top of the z-order ahead of any other topmost windows by adding the 
following to the form's OnPaint event. Otherwise, other programs that 
modify the z-order can paint over yours.}

     procedure TYourForm.FormPaint(Sender: TObject);
     begin
          SetZOrder(True);
     end;


