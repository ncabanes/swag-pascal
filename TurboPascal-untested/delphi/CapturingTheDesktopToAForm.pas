(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0026.PAS
  Description: Capturing the Desktop to a form
  Author: CRAIG FRANCISCO
  Date: 11-22-95  13:33
*)


Try this:

 procedure TScrnFrm.GrabScreen;
 var

    DeskTopDC: HDc;
    DeskTopCanvas: TCanvas;
    DeskTopRect: TRect;
    
 begin
    DeskTopDC := GetWindowDC(GetDeskTopWindow);
    DeskTopCanvas := TCanvas.Create;
    DeskTopCanvas.Handle := DeskTopDC;

    DeskTopRect := Rect(0,0,Screen.Width,Screen.Height);

    ScrnForm.Canvas.CopyRect(DeskTopRect,DeskTopCanvas,DeskTopRect);

    ReleaseDC(GetDeskTopWindow,DeskTopDC);
end;

