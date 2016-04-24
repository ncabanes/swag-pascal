(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0069.PAS
  Description: Skewed Colors when stretching bitmaps
  Author: SWAG SUPPORT TEAM
  Date: 11-24-95  10:16
*)

{
Here is a simple test program I wrote for displaying a 256 color
bitmap. It works properly on my system ... so far. The code was derived from a
sample which is included in the WM_QUERYNEWPALETTE help description in the
Microsoft Visual C++ compiler (The Win API). These examples were not included
in the Delphi version of the Win API help file for some reason. Too bad
because they are extremely useful.

This code passes all the tests on my system. The app starts with the bitmap
displayed correctly. With another app in the foreground or with an icon (for
example the MSDOS icon) dragged on top, it displays a proper "background
palette". Minimizing and moving the window shows a proper palette.

You will need to find a 256 color bitmap (Test.bmp). My bitmap is smaller than
the client area. The Form contains a single TImage aligned to client. The
messages are documented in Delphi's online help. }

unit Paltst;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Menus, Buttons;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure QNewPalette(var Msg : TWMQueryNewPalette); message
      WM_QueryNewPalette;
    procedure PalChanged(var Msg : TWMPaletteChanged); message
      WM_PaletteChanged;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Bmap : TBitmap;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
  i : Word;
begin
  Bmap := TBitmap.Create;
  Bmap.LoadFromFile('Test.bmp');

  Image1.Canvas.StretchDraw(Image1.BoundsRect, Bmap);
end;

procedure TForm1.QNewPalette(var Msg : TWMQueryNewPalette);
var
  i : Word;
  DC : HDC;
  HPold : HPalette;
begin
  DC := Form1.Canvas.Handle;
  HPold := SelectPalette(DC, Bmap.Palette, False);
  i := RealizePalette(DC);
  SelectPalette(DC, HPold, False);
  if (i > 0) then InvalidateRect(Handle, Nil, False);
  Msg.Result := i;
end;

procedure TForm1.PalChanged(var Msg : TWMPaletteChanged);
var
  i : Word;
  DC : HDC;
  HPold : HPalette;
begin
  if (Msg.PalChg = Handle) then Msg.Result := 0
  else begin
    DC := Form1.Canvas.Handle;
    HPold := SelectPalette(DC, Bmap.Palette, True);
    i := RealizePalette(DC);
    UpdateColors(DC);
    SelectPalette(DC, HPold, False);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Bmap.Free;
end;

end.


