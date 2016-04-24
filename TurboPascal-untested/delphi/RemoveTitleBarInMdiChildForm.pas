(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0065.PAS
  Description: Remove title bar in MDI child form
  Author: ANDY MCFARLAND
  Date: 11-24-95  10:16
*)


type
  TForm2 = class(TForm)
	{ other stuff above }
	procedure CreateParams(var Params: TCreateParams); override;
	{ other stuff below }
  end;


procedure TForm2.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style and not WS_OVERLAPPEDWINDOW or WS_BORDER
end;


For an MDI child form, setting the BorderStyle to bsNone does NOT remove
the title bar. (This is mentioned in the help).  This does it:

Procedure tMdiChildForm.CreateParams( var Params : tCreateParams ) ;
Begin
   Inherited CreateParams( Params ) ;
   Params.Style := Params.Style and (not WS_CAPTION) ;
End ;

