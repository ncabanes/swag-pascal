(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0182.PAS
  Description: Compensating for different screen resolu
  Author: DAVID NOVAK
  Date: 11-29-96  08:17
*)

{
My forms always look bad when displayed at a screen resolution different
from the one it was designed at. I found some code in Lloyd's help file,
which made it look very easy. The only problem is that it won't compile for
me. The code is as follows:

------------------------------------------------ }

implementation
const
  ScreenWidth: LongInt = 800; {I designed my form in 800x600 mode.}
  ScreenHeight: LongInt = 600;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
  i, OldFormWidth: integer;
begin
  scaled := true;
  if (screen.width <> ScreenWidth) then begin
    OldFormWidth := width;
    height := longint(height) * longint(screen.height) DIV ScreenHeight;
    width := longint(width) * longint(screen.width) DIV ScreenWidth;

    scaleBy(screen.width, ScreenWidth);
    font.size := (Width DIV OldFormWidth) * font.size;
  end;
end;


Then, you will want to have something that checks to see that  the font
sizes are OK.  Before you change the font's size, you  would need to ensure
the object actually has a font property by checking the RTTI.   This can be
done as follows:

USES TypInfo;  {Add this to your USES statement.}

var
  i: integer;
begin
  for i := componentCount - 1 downto 0 do
    with components[i] do
    begin
      if GetPropInfo(ClassInfo, 'font') <> nil  then
        font.size := (NewFormWidth DIV OldFormWidth) * font.size;

    end;
end;


------------------------------------------------

The first problem is that the TypeInfo unit does not seem to exist. The
other problem is that the GetPropInfo() function is undefined. Apparently
it is in the TypeInfo unit. What am I missing? Has the TypeInfo class been
removed from Delphi in version 2? Is there another way to find out if a
component has a Font property? Please help!

Thanks,
David Novak
novak@valu-line.net
Delphi 2.01, Win95


