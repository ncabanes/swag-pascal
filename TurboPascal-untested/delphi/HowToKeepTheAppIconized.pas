(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0015.PAS
  Description: How to keep the app iconized
  Author: SWAG SUPPORT GROUP
  Date: 11-22-95  13:27
*)


iconized apps

Q:  How do I keep the form in icon form when I run it?  

A:  

1.  You must set WindowState to wsMinimized in the form's properties.

2.  In the private section of the form object's declaration, put:

      PROCEDURE WMQueryOpen(VAR Msg : TWMQueryOpen); message WM_QUERYOPEN;

3.  In the implementation section, put this method:

      PROCEDURE TForm1.WMQueryOpen(VAR Msg : TWMQueryOpen);
      begin
        Msg.Result := 0;
      end;

That's it! The form will always remain iconic. 





