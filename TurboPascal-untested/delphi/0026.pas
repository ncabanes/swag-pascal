
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