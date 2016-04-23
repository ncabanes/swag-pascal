
Program ColorTV;

uses Objects, Drivers, Views, Menus, Dialogs, App, StdInput;

const
  cmButton  = 101;
  cmNewWin  = 102;
  cmNewDlg  = 103;

  WinCount : integer = 0;  { number of current windows }

type

  PApp = ^TApp;
  TApp = object(TApplication)
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure HandleEvent(var Event : TEvent); virtual;
    procedure NewWindow;
    procedure NewDialog;
    function  GetPalette : PPalette; virtual;

  end;

  PWin = ^TWin;
  TWin = object(TWindow)
    constructor Init(Bounds: TRect; WinTitle: String;
                     WindowNo: Word);
    function GetPalette : PPalette; virtual;
  end;

  PInLine = ^TInLine;
  TInLine = object(TInputReal)
    function GetPalette : PPalette; virtual;
  end;

  PDlg = ^TDlg;
  TDlg = object(TDialog)
    function GetPalette : PPalette; virtual;
  end;


{ TWin }
constructor TWin.Init(Bounds: TRect; WinTitle: String;

                      WindowNo: Word);
var
  S : string[3];
  R : TRect;
  MyInputLine : PInLine;
begin
  Str(WindowNo, S);
  TWindow.Init(Bounds, WinTitle + ' ' + S, wnNoNumber);
  GetClipRect(Bounds);
  Bounds.Grow(-1,-1);

  { insert input string }
  R.Assign(8, 2, 20, 3);
  Insert(New(PInLine, Init(R, 12)));

  { insert button }
  R.Assign(8, 5, 20, 7);
  Insert(New(PButton, Init(R, '~O~k', cmButton, bfDefault)));

  { move to the top }
  SelectNext(false);


end;

function TWin.GetPalette : PPalette;
{ add color indexes to TWin to allow button to be displayed in }
{ the window.  notice that TButton's palette starts mapping    }
{ from 10 - 15, and TWindow's palette runs from 1 - 8, there-  }
{ fore add the indexes for the button on the end of TWin       }
{ palettes.                                                    }
const
  CWin = CBlueWindow + #0#41#42#43#44#45#64;
  PWin : string[Length(CWin)] = CWin;
begin

  GetPalette := @ PWin;
end;

{ TApp }
procedure TApp.InitMenuBar;
var
  Menu: TRect;
begin
  GetExtent(Menu);
  Menu.B.Y := Menu.A.Y + 1;
  MenuBar := New(PMenuBar, Init(Menu, NewMenu(
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~W~indow', '', kbF4, cmNewWin, hcNoContext,
      NewItem('~D~ialog', '', kbF5, cmNewDlg, hcNoContext,
      NewLine(
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,

      nil)))))),
    nil))));
end;

procedure TApp.InitStatusLine;
var
  Line: TRect;
begin
  GetExtent(Line);
  Line.A.Y := Line.B.Y-1;
  StatusLine := New(PStatusLine, Init(Line,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F4~ Window', kbF4, cmNewWin,
      NewStatusKey('~F5~ Dialog', kbF5, cmNewDlg,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil))))),

    nil)));
end;

procedure TApp.NewWindow;
var
  Window : PWin;
  Box    : TRect;
begin
  Inc(WinCount);
  Box.Assign(0, 0, 30, 8);
  Box.Move(Random(34), Random(11));
  Window := New(PWin, Init(Box, 'Test Window', WinCount));
  DeskTop^.Insert(Window);
end;

procedure TApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewWin : NewWindow;
      cmNewDlg : NewDialog;

      cmButton : ;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TApp.NewDialog;
var
  Dialog     : PDlg;
  R          : TRect;
  C          : Word;
begin

  R.Assign(25, 5, 55, 13);
  Dialog := New(PDlg, Init(R, 'Test Dialog'));

  with Dialog^ do
  begin

    { message }
    R.Assign(9, 2, 27, 3);
    Insert(New(PStaticText, Init(R, 'Error Message')));

    { insert button }
    R.Assign(10, 5, 20, 7);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));


  end;

  C := DeskTop^.ExecView(Dialog);

  Dispose(Dialog, Done);
end;

function TApp.GetPalette : PPalette;
{ this is the palette that all other views are mapped to. }
{ the first 64 (0..63) are defined, any other colors are  }
{ added from 64 on.  the #$10 is for TWin for the back-   }
{ ground color for the button.  from $47 on maps the new  }
{ color for TDlg and its views.                           }
const
  CApp = CColor + #$10#$47#$4E#$40#$4F#$30#$3E;

  PApp : string[Length(CApp)] = CApp;
begin
  GetPalette := @ PApp;
end;

{ TInLine }
function TInLine.GetPalette : PPalette;
{ color indexes into TWin color palette }
const
  CInLine = #4#4#3#3;
  PInLine : string[Length(CInLine)] = CInLine;
begin
  GetPalette := @ PInLine;
end;

{ TDlg }
function TDlg.GetPalette : PPalette;
{ when replacing colors for a view must replace the entire   }
{ string.  notice that any color > 63 maps to a user defined }
{ color from TApp's palette (65 = $47, 66 = $4E, etc.).      }

{ i.e.                                                       }
{ index 2, the active frame maps to 65 which is color $47    }
{          (or grey on red).                                 }
{ index 3, the frame icon maps to 66->$4E (yellow on red).   }
{ index 46, the button shadow maps to 67->$40 (black on rec).}
{ index 37, the statictext maps to 68->$47 (white on red).   }
{           (no reason 46 is before 38).                     }
{ index 41-43, button stuff 69->$30 (cyan on black).         }

{ index 45, button shortcut 70->$3E (cyan on yellow).        }
const
  CDlg = #32#65#66#35#36#68#38#39#40#69#69#69#44#70#67#47#48#49 +
         #50#51#52#53#54#55#56#57#58#59#60#61#62#63;
  PDlg : string[Length(CDlg)] = CDlg;
begin
 GetPalette := @ PDlg;
end;

var
  MyApp : TApp;

{ main }
begin

  MyApp.Init;
  MyApp.Run;
  MyApp.Done;

end.


