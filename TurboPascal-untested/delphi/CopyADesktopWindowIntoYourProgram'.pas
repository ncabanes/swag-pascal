(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0049.PAS
  Description: Copy a desktop window into your program'
  Author: SWAG SUPPORT TEAM
  Date: 11-24-95  10:15
*)


  {************************************************}
  {  Copy DeskTop Demo program                     }
  {************************************************}
  {
    Here's the beginning of the resource:
    -------------------------------------------------------
    MENU_1 MENU
    BEGIN
          MENUITEM "Blit_Upper_Left_Corner_of_Desktop", 101
    END
    -------------------------------------------------------
    End of Resource (Don't include lines)
  }
  program MyProgram;

  uses WinTypes, WinProcs, OWindows;
  {$R BMPDESK}

  const
    idBlitIt = 101;

  type
    TMyApplication = object(TApplication)
      procedure InitMainWindow; virtual;
    end;

  type
    PMyWindow = ^TMyWindow;
    TMyWindow = object(TWindow)
      constructor Init(AParent: PWIndowsObject; Name: PChar);
      destructor Done; virtual;
      procedure BlitIt(var Msg: TMessage);
        virtual Cm_First + idBlitIt;
    end;

  {--------------------------------------------------}
  { TMyWindow's method implementations:              }
  {--------------------------------------------------}

  constructor TMyWindow.Init(AParent: PWindowsObject; Name: PChar);
  begin
    inherited Init(AParent, Name);
    Attr.Menu := LoadMenu(HInstance, 'Menu_1');
  end;

  destructor TMyWindow.Done;

  begin
    inherited Done;
  end;

  procedure TMyWindow.BlitIt(var Msg: TMessage);
  var
    DeskDc: HDC;
    TempDC, PaintDC: HDC;
    MyBitMap: HBitMap;
    R: TRect;
  begin
    DeskDc := GetDC(GetDeskTopWindow);
    PaintDC := GetDC(HWindow);
    GetClientRect(HWindow, R);
    BitBlt(PaintDC, 0, 0, R.right, R.bottom, DeskDC, 0, 0,
  SRCCopy);
    ReleaseDC(HWindow, PaintDC);
    ReleaseDC(GetDeskTopWindow, DeskDC);
  end;

  {--------------------------------------------------}
  { TMyApplication's method implementations:         }
  {--------------------------------------------------}

  procedure TMyApplication.InitMainWindow;
  begin
    MainWindow := New(PMyWindow, Init(nil, 'Sample ObjectWindows
                      Program'));
  end;

  {--------------------------------------------------}
  { Main program:                                    }
  {--------------------------------------------------}

  var

    MyApp: TMyApplication;

  begin
    MyApp.Init('MyProgram');
    MyApp.Run;
    MyApp.Done;
  end.





























