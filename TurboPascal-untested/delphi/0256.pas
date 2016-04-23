>
>> Hi everyone,
>>
>> I have done it, but it ONLY looks like transparent. If you move the
>> form, then
>> you move the contents, which was "behind (or below)" the form, too.
>>
>> regards
>
>  Yup, but it looks great for
>  splash screens for example.....
>  ( with label set as transparent)
>

Another recipe:

Take a form.=20
Roast it in its own fat...

Set its BorderStyle to bsNone, and BorderIcons to [].
Put in the OnCreate handler:

Brush.Style:=3DbsClear;
Top:=3D0;
Left:=3D0;
Width:=3DScreen.Width;
Height:=3DScreen.Height;


Then place a TImage on that form. Make it invisible. Load a checked
(black/transparent) ICON in the Image.Picture.

Write an OnPaint handler like this:

procedure TForm1.FormPaint(Sender: TObject);
Var i,j:Integer;
begin
For i:=3D0 To ClientWidth Div 32 Do
    For j:=3D0 To ClientHeight Div 32 Do
        Form1.Canvas.Draw(i*32,j*32,Image1.Picture.Icon);
end;

And what you see is what you get.
(A little bit slow) Shut-Down Type Effect.

Regards.
Laszlo Kovacs
Budapest, Hungary

