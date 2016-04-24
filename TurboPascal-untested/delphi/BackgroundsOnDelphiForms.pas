(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0239.PAS
  Description: Backgrounds on Delphi forms
  Author: CHAMI
  Date: 05-30-97  18:17
*)


Windows, web pages, multimedia programs, etc. have backgrounds. How come your Delphi
form doesn't?
--------------------------------------------------------------------------------
Of course you could place an Image component on your form and set it's Alignment
to Client to place a background on your form. But, here's another way to do it:

(1) Add following to your form's Public declarations section:

    bmpBackground : TBitmap;

(2) Double click on your form and add bitmap initialization code to the
FormCreate procedure:

    bmpBackground := TBitmap.Create;
    bmpBackground.LoadFromFile( 'c:\windows\setup.bmp' );

(3) Go to the form's events list and double click on OnPaint. Add following
line to the FormPaint procedure:

    Canvas.Draw( 0, 0, bmpBackground );

(4) Finally insert the following code to FormDestroy
procedure (OnDestroy event):

    bmpBackground.Free;


