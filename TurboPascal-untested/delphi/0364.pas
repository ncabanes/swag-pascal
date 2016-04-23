
How to give wallpaper or image in the delphi's form, not Windows
wallpaper?

Aries,

We do this in our application (D1), but the method is rather difficult (well, its not easy at any rate). If interested ( or others) I can post the code. (its not too long). Oh what the hey, I'll just post it now:

{the declaration part}
  TMainForm = class(TForm)
  private
         PROCEDURE ClientWndProc(VAR Message: TMessage);


{the actual procedure}
PROCEDURE TMainForm.ClientWndProc(VAR Message: TMessage);
VAR
  MyDC : hDC;
  Ro, Co : Word;
begin
  with Message do
    case Msg of
      WM_ERASEBKGND:
        begin
          MyDC := TWMEraseBkGnd(Message).DC;
          Ro := 0;
          Co := 0;
          PaintRgn(MyDC, CreateRectRgn(0, 0, ClientWidth, ClientHeight));
          BitBlt(MyDC, Co*ImageEagle.Picture.Width, Ro*ImageEagle.Picture.Height,
                ImageEagle.Picture.Width, ImageEagle.Picture.Height,
                                 {ImageEagle.Picture.Bitmap.Canvas.Handle, 0, -130, SRCCOPY);}
                                 ImageEagle.Picture.Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
                   Result := 1;
                 end;
    else
      Result := CallWindowProc(FPrevClientProc, ClientHandle, Msg, wParam, lParam);
    end;

end;

{the reference to activate the process}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  FClientInstance := MakeObjectInstance(ClientWndProc);
  FPrevClientProc := Pointer(GetWindowLong(ClientHandle, GWL_WNDPROC));
  SetWindowLong(ClientHandle, GWL_WNDPROC, LongInt(FClientInstance));
end;


On the form itself there is a TImage called ImageEagle. this contains the image that will be used.
It works for us, but there may be a better way do do it.

HTH,
Dustin
