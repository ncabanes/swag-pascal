
From: "James D. Rofkar" <jim_rofkar%lotusnotes1@instinet.com>

JAAD wrote:
>
> I want to make a Delphi-Form to REALLY stay on top, But not only within
it own  application (thats simpel)
    No I want it to stay on top even when I am using  for instance EXCEL.
>
Try using the Windows API function SetWindowPos(). Something like...


--------------------------------------------------------------------------------

   with MyForm do
      SetWindowPos(Handle,
                   HWND_TOPMOST,
                   Left,
                   Top,
                   Width,
                   Height,
                   SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);

--------------------------------------------------------------------------------

You may need to call this function in your Form's OnShow(), OnDeactivate(),
and OnActivate() event handlers.

