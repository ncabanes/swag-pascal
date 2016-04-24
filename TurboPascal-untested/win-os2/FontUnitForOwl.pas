(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0070.PAS
  Description: Font Unit for OWL
  Author: JASON SPRENGER
  Date: 05-27-95  10:38
*)


{***********************************************}
{                                               }
{  Turbo Pascal for Windows                     }
{  WinFont Unit                                 }
{  Font Unit for OWL or non-OWL programs        }
{  Written by Jason John Sprenger  11/8/91      }
{                                               }
{***********************************************}

unit WinFont;

interface

uses
  WinTypes, WinProcs;

{/// Select Font Constants ///}
const
  fs_Normal     = 256;
  fs_Bold       = 1;
  fs_DoubleWide = 2;
  fs_DoubleHigh = 4;
  fs_Italic     = 8;
  fs_Underline  = 16;
  fs_StrikeOut  = 32;

{/// SelectFont function ///}
function SelectFont(DC: HDC; FaceName: PChar; Height: word;
  Flags: word): HFont;
{
  Accepts the current Device Context, the name of the font desired,
  and some combination of the fs_ constants.  fs_constants are additive.
  That is, for double-wide, italic text use fs_doublewide or fs_italic.
  SelectFont returns the font handle of that most closely matches the
  font name and height specified.  If the font name specified is not
  supported by the device then zero is returned. The current font
  remains unchanged.  You will have to call SelectObject to make this new
  font the current font for the appropriate device context.
}

implementation

type
  PFontInfo = ^TFontInfo;
  TFontInfo = record
    DC: HDC;
    Height: word;
    NewFont: TLogFont;
    Name: PChar;
  end;

function EnumFontCallBack(LogFont: TLogFont; ATextMetric: TTextMetric;
  FontType: Word; Data: Pointer): integer; export;
{ Returns the font that most closely matches the Height requirements
  given in the TFontInfo record passed in the data parameter. }
var
  FI: PFontInfo absolute Data;
begin
  if (ATextMetric.tmHeight>=FI^.Height) then
  begin
    EnumFontCallBack:=0;
    if (ATextMetric.tmHeight=FI^.Height)
    then
      FI^.NewFont:=LogFont;
  end
  else
  begin
    FI^.NewFont:=LogFont;
    EnumFontCallBack:=1;
  end;
end;

function SelectFont(DC: HDC; FaceName: PChar; Height: word;
  Flags: word): HFont;
var
  EnumFunc: TFarProc;
  Data: TFontInfo;
begin
  Data.DC:=DC;
  Data.Height:=Height;
  Data.Name:=FaceName;
  Data.NewFont.lfHeight:=0;
  EnumFunc:=MakeProcInstance(@EnumFontCallBack, HInstance);
  EnumFonts(DC, FaceName, EnumFunc, @Data);
  if Data.NewFont.lfHeight=0
  then
    SelectFont:=0
  else begin
    if (Flags and fs_Normal)<>0 then
      Data.NewFont.lfWeight:=400;

    if (Flags and fs_Bold)<>0 then
      Data.NewFont.lfWeight:=700;

    if (Flags and fs_DoubleWide)<> 0 then
      Data.NewFont.lfWidth:=Data.NewFont.lfWidth*2;

    if (Flags and fs_DoubleHigh)<> 0 then
      Data.NewFont.lfHeight:=Data.NewFont.lfHeight*2;

    if (Flags and fs_Italic)<>0 then
      Data.NewFont.lfItalic:=255;

    if (Flags and fs_Underline)<>0 then
      Data.NewFont.lfUnderline:=255;

    if (Flags and fs_Strikeout)<>0 then
      Data.NewFont.lfStrikeout:=255;

    SelectFont:=CreateFontIndirect(Data.NewFont);
  end;

  FreeProcInstance(EnumFunc);
end;

end.

