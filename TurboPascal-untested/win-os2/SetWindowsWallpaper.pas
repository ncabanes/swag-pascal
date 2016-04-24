(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0020.PAS
  Description: Set WINDOWS Wallpaper
  Author: SWAG SUPPORT TEAM
  Date: 02-15-94  07:55
*)

Program Paper;

{$R-,I-,S-,L-,D-,G+}

Uses
  WinTypes,WinProcs,WObjects,Strings;

{ Declare undocumented Windows API call }

Procedure SetDeskWallpaper(Name : PChar);
  Far; External 'USER' Index 285;

Var
  hPal : HPalette;

{---------------------------------------------------}

{ --- App/Win Object declarations --- }

Type
  TPaperApp = Object(TApplication)
                Procedure InitMainWindow; Virtual;
              End;

  PPaperWindow = ^PaperWindow;
  PaperWindow = Object(TWindow)
                  Procedure SetupWindow;
                    Virtual;

                  Procedure WMQueryNewPalette(Var Msg : TMessage);
                    Virtual wm_QueryNewPalette;

                  Procedure WMPaletteChanged(Var Msg : TMessage);
                    Virtual wm_PaletteChanged;
                End;

{---------------------------------------------------}

{ --- App Methods --- }

Procedure TPaperApp.InitMainWindow;

Begin
  If hPrevInst = 0
    Then MainWindow := New(PPaperWindow,Init(nil,'Paper'))
    Else Halt(0);
End {InitMainWindow};

{ --- Window Methods --- }

{---------------------------------------------------}

Procedure PaperWindow.SetupWindow;

Var
  PaperStr : Array [0..80] Of Char;
  FName : String[80];
  DC : HDC;
  LogPal : TLogPalette;
  hOldPal : HPalette;

Begin
  { Retreive filename - if none: we just fixup the palette }
  FName := ParamStr(1);

  If FName <> ''
    Then Begin
           { Add .BMP to filename, if necess. }
           If Pos('.',FName) = 0
             Then FName := FName + '.bmp';

           { Put string in "C" style }
           StrPCopy(PaperStr,FName);

           { Make sure we keep WIN.INI apprised of our changes }
           WriteProfileString('Desktop','Wallpaper',PaperStr);

           { Set the wallpaper }
           SetDeskWallpaper(PaperStr);   { Undoc'd win call }
         End;

  { Invalidate the screen, even if we don't load a new wallpaper - if
    we don't do this, the "transparent" areas of icons will be fratzed up }
  InvalidateRect(0,Nil,False);

  { Create a small palette to fix the fact that loading the wallpaper
    doesn't realize the palette }

  LogPal.palVersion := $0300;
  LogPal.palNumEntries := 1;
  LogPal.palPalEntry[0].peRed := 0;
  LogPal.palPalEntry[0].peGreen := 0;
  LogPal.palPalEntry[0].peBlue := 0;
  LogPal.palPalEntry[0].peFlags := 0;

  { Get a DC and realize our palette }
  DC := GetDC(HWindow);

  hPal := CreatePalette(LogPal);
  hOldPal := SelectPalette(DC,hPal,False);

  RealizePalette(DC);

  { Close up our palette stuff }
  SelectPalette(DC,hOldPal,False);

  DeleteObject(hPal);
  ReleaseDC(HWindow,DC);

  { Close ourselves automatically }
  PostMessage(HWindow,wm_Close,0,0);

End {SetupWindow};

{---------------------------------------------------}

Procedure PaperWindow.WMQueryNewPalette(Var Msg : TMessage);

Var
  ahDC : HDC;

Begin
  ahDC := GetDC(HWindow);
  SelectPalette(ahDC,hPal,False);

  If (RealizePalette(ahDC) > 0)
    Then Begin
           ReleaseDC(HWindow,ahDC);
           InvalidateRect(HWindow,Nil,False)
         End
    Else ReleaseDC(HWindow,ahDC);
End {WMQueryNewPalette};

{---------------------------------------------------}

Procedure PaperWindow.WMPaletteChanged(Var Msg : TMessage);

Var
  ahDC : HDC;

Begin
  If Msg.wParam <> HWindow
    Then Begin
           ahDC := GetDC(HWindow);
           SelectPalette(ahDC,hPal,False);

           If (RealizePalette(ahDC) > 0)
             Then InvalidateRect(HWindow,nil,False);

           ReleaseDC(HWindow,ahDC);
         End;
End {WMPaletteChanged};

{---------------------------------------------------}

{ --- Main --- }

Var
  PaperApp : TPaperApp;

Begin
  CmdShow := sw_Minimize;

  PaperApp.Init('Paper');
  PaperApp.Run;
  PaperApp.Done;
End.

