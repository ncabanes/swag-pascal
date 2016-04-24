(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0440.PAS
  Description: Determining which font (Large or Small)
  Author: GREG PETERSON
  Date: 01-02-98  07:34
*)


"Greg Peterson" <maxint@cwnet.com>

Try this:
--------------------------------------------------------------------------------
 
FUNCTION SmallFonts : BOOLEAN;
{returns TRUE if  small fonts are set, FALSE if using Large Fonts }
VAR
  DC : HDC; { used to check for number of colors available }
BEGIN
  DC := GetDC(0);
  Result :=   (GetDeviceCaps(DC, LOGPIXELSX) = 96); 
  { LOGPIXELSX will = 120 if large fonts are in use }
  ReleaseDC(0, DC);
END;

--------------------------------------------------------------------------------


Large/Small Fonts?

Gene Eighmy <eighmy@scott.net>

> 
> When my programs run on systems with small fonts, I
> often get strange output.  Labels too small to hold all
> the text, leaving the right, or the bottom, unshown, for
> instance.  StringGrid's which don't align as expected.
> 
Try this. This will rescale both the form size and also reform small vs. large fonts. Call it in Form.FormCreate. Hope this helps. 


--------------------------------------------------------------------------------

unit geScale;

interface
uses Forms, Controls;

procedure geAutoScale(MForm: TForm);

implementation
Type
TFooClass = class(TControl); { needed to get at protected }
                               { font property }


procedure geAutoScale(MForm: TForm);
const
     cScreenWidth :integer = 800;
     cScreenHeight:integer = 600;
     cPixelsPerInch:integer= 96;
     cFontHeight:integer   = -11;  {Design-time value of From.Font.Height}

var
  i: integer;

begin
     {
     IMPORTANT!! : Set Scaled Property of TForm to FALSE with Object Inspector.

     The following routine will scale the form such that it looks the same
     regardless of the screen size or pixels per inch.  The following section
     determines if the screen width differs from the design-time screen size.
     If it differs, Scaled is set true and component positions are rescaled such
     that they appear in the same screen location as the design-time location.
     }
     if (Screen.width &;lt> cScreenWidth)or(Screen.PixelsPerInch <> cPixelsPerInch) then
     begin
          MForm.scaled := TRUE;
          MForm.height := MForm.height * screen.Height DIV cScreenHeight;
          MForm.width  := MForm.width  * screen.width DIV cScreenWidth;
          MForm.ScaleBy(screen.width, cScreenWidth);

     end;

     {
      This section determines if the run-time font size differs from the design-
      time font size.  If the run-time pixelsperinch differs form the design-time
      pixelsperinch, the fonts must be rescaled in order for the form to appear
      as designed.  Scaling is calculated as the ratio of the design-time font.height
      to run-time font.height.  Font.size will not work as it may equal the design-
      time value yet appear physically larger crowding and overrunning other
      components.    For instance, a form designed in 800x600 small fonts
      has a font.size of 8.  When you run the form on in 800x600 large fonts,
      font.size is also 8 but the text is noticably larger than when run in small
      font mode. This scaling will make them both appear to be the same size.
     }

     if (Screen.PixelsPerInch <> cPixelsPerInch) then
     begin

         for i := MForm.ControlCount - 1 downto 0 do
              TFooClass(MForm.Controls[i]).Font.Height :=
               (MForm.Font.Height div cFontHeight) *
                 TFooClass(MForm.Controls[i]).Font.Height;

     end;

end;

end.

