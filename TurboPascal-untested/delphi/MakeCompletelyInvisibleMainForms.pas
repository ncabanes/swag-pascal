(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0434.PAS
  Description: Make completely invisible main forms??
  Author: CHRIS RANDALL
  Date: 01-02-98  07:34
*)


From: gt6298d@prism.gatech.edu (Chris Randall)

"J.J. Bakker" <J.J.Bakker@stud.rgl.ruu.nl> wrote:
>Does anyone know the answer, I', trying to make an app that has an icon in the notification area with a popupmenu. However the application is still visible on the taskbar.
Using Application.ShowMainForm:=False; is not enough.
>
I have run into the same problem but found the answer. This little bit
of code works great.


--------------------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.OnMinimize:=AppMinimize;
  Application.OnRestore:=AppMinimize;
  Application.Minimize;
  AppMinimize(@Self);
end;

procedure TMainForm.AppMinimize(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

