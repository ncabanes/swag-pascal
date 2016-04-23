
From: "Chami" <72223.10@compuserve.com>

> I need to have a form in my application that zooms to half of
> the screen when the Maximize button is pressed, not to full
> screen.
>
you could handle the WM_GETMINMAXINFO message from your form.

for example, add the following declaration to the protected section of your form (interface):


--------------------------------------------------------------------------------

procedure _WM_GETMINMAXINFO( var mmInfo : TWMGETMINMAXINFO );  message wm_GetMinMaxInfo;

--------------------------------------------------------------------------------

then define (implementation) the above message handler as follows (TForm1 being the name of your form of course):


--------------------------------------------------------------------------------

procedure TForm1._WM_GETMINMAXINFO( var mmInfo : TWMGETMINMAXINFO );
begin
        // set the position and the size of your form when maximized:
        with mmInfo.minmaxinfo^ do
        begin
                ptmaxposition.x := Screen.Width div 4;
                ptmaxposition.y := Screen.Height div 4;

                ptmaxsize.x     := Screen.Width div 2;
                ptmaxsize.y     := Screen.Height div 2;
        end;
end;
