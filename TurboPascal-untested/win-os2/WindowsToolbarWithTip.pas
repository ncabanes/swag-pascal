(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0050.PAS
  Description: Windows Toolbar with TIP
  Author: CHRISTER FAHLGREN
  Date: 11-26-94  04:56
*)

{
From: chrfa@ida.liu.se (Christer Fahlgren)

For all people out there wishing a Toolbar with TIP-capabilities, I've
written a TIPBAR-unit which is the basic toolbar enhanced with tip
capabilities.

Since I'm no expert programmer I'd appreciate input on this.
Info follows in the file included below.

{**************************************************}
{                                                  }
{   Turbo Pascal for Windows                       }
{   Tipbar unit - a toolbar with TIP-capabilities  }
{   Copyleft (cl) 1994 by Christer Fahlgren        }
{                                                  }
{   This source is freeware! Please (ab)use,       }
{   change, include in commercial programs,        }
{   throw away, WHATEVER you feel like.            }
{                                                  }
{   This unit was written because I thought it     }
{   would be cool If I could have tooltips myself. }
{   And I gathered that the best way of enhancing  }
{   this unit would be to throw it out to the      }
{   public programmer mob for scrutiny.            }
{   I am no expert at this and It may contain      }
{   errors for which I can take no respons-        }
{   ibilities. However, please send me your        }
{   comments, enhancements and bugs for my and     }
{   your benefit.                                  }
{                                                  }
{   I also would like to say that I am a bit tired }
{   of all the people asking for money for petty   }
{   source code.                                   }
{                                                  }
{   The inspiration for this unit was the tooltip  }
{   C++ code which I found the other day.          }
{                                                  }
{                                                  }
{   This toolbar relies on the original toolbar    }
{   which resides in the \examples\win\toolbar     }
{   directory in BP7.                              }
{                                                  }
{   Enjoy!                                         }
{                                                  }
{   Christer Fahlgren                              }
{   Email: chrfa@ida.liu.se                        }
{   Snail: VΣstanσgatan 26A:204                    }
{   S-582 35 Link÷ping                             }
{   Sweden                                         }
{**************************************************}

{--------------------------------------------------
 Q:What do I do if I already use the toolbar unit
 in Borland Pascal???

 A:First add Tipbar to your uses clause
   Then add a parameter to your init statement
   of your toolbar like this:
   Init(ParentWin, AName, Orient) ->
   Init(ParentWin, Aname, Orient, Delay) where
   Delay is the delay in milliseconds for the help
   to show up.

   Change occurences of TToolbar to TTipbar
   Change occurences of PToolbar to PTipbar

   Lastly you have to redefine your old
   ToolBarData statements with the new resource-
   name HelpToolBarData. This resource looks
   like the old ToolBarData but a null-terminated
   string is included for every tool. This string
   can maximum be 255 chars.

   Example:

   AHelpToolbar  HelpToolBarData
   BEGIN
         2                      (Number of tools and spacers in this resource )
         tb_open                (id of a bitmap                               )
         cm_open                (menu id                                      )
         "Opens a file\0"       (Text which is null-terminated                )
         tb_save                (id of a bitmap                               )
         cm_save                (menu id                                      )
         "Saves the file\0"     (Text which is null-terminated                )
   END

 ----------------------------------------------------------}

{----------------------------------------------------------}
{                                                          }
{ INFORMATION AND PRECAUTIONS                              }
{ ---------------------------                              }
{ The Store and Load methods are NOT tested!               }
{ It uses one timer (a scarce resource in Win 3.x)         }
{                                                          }
{ This unit is NOT thoroughly tested and all use is at     }
{ your own risk, BUT it SEEMS to work well.                }
{----------------------------------------------------------}

{----------------------------------------------------------}
{ Possible ENHANCEMENTS                                    }
{ ---------------------                                    }
{ Store the font for the popupwindow in the toolbar        }
{ instead of creating it each time in the HelpWindow       }
{ No more than one calculating of the size of the text     }
{ in the popupwindow.                                      }
{----------------------------------------------------------}

unit TipBar;

interface

uses Winprocs, Wintypes, Objects, OWindows, Strings, Win31, toolbar;

type
  PTipbar = ^TTipbar;
  PTipbutton = ^TTipbutton;
  PHelpWindow=^THelpWindow;

  { This is the definition to the Popupwindow which shows the tip}

  THelpWindow=object(TWindow)
     LogicalFont : TLOGFONT;
     ToolToHelp : PTipbutton;
     constructor Init (AParent : PTipbar; Tool : PTipbutton; WherePos : TPoint;
Width, Height : Word);
     procedure Paint (DC : HDC; var PS : TPaintStruct); virtual;
  end;

  { This is a normal toolbarbutton with an extra string variable}

  TTipbutton=object(TToolbutton)
     HelpString:array[0..255] of char;
  end;

  { This is the definition of our new Tipbar }

  TTipbar = object(TToolbar)
    Help : Boolean;          {Decides if we should help or not}
    Timer : Word;            {Timer to use}
    ToolToHelp : PTipButton; {Points to the button to help, it is nil if no
button needs help}
    PopWin : PHelpWindow;    {Pointer to the Helpwindow if one exists}
    OldMouseCoord : Tpoint;  {Helps remember the mousecoordinate}
    Delay : Word;

    constructor Init(AParent : PWindow; AName : PChar; Orient : Word; Delaypar
: word);
    destructor done; virtual;

    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;

    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var WC: TWndClass); virtual;

    procedure ReadResource; virtual;

    procedure Timermsg(Var Msg:TMessage); virtual wm_first+wm_timer;

    procedure GetToolUnder(P:Tpoint);

    procedure WMMouseMove(var Msg: TMessage);
      virtual wm_First + wm_MouseMove;

    function  CreateTool(Num: Integer; Origin: TPoint; Command: Word;
      BitmapName: PChar): PTool; virtual;

    procedure EnableHelp;
    procedure DisableHelp;

    procedure ChangeDelay(Delaypar:Word);
  end;



const
  RTipbar: TStreamRec = (
    ObjType: 12302;
    VmtLink: Ofs(TypeOf(TTipbar)^);
    Load:    @TTipbar.Load;
    Store:   @TTipbar.Store);

implementation


constructor TTipbar.Init (AParent : PWindow; AName : PChar; Orient : Word;
Delaypar : word);
begin
  inherited Init(AParent,Aname,orient);
  Timer := 0;
  Delay := Delaypar;
  Popwin := nil;
  ToolToHelp := nil;
  Help := TRUE;      {Default is to show help}
end;

destructor TTipbar.Done;
begin
  KillTimer(Hwindow,1);
  inherited Done;
end;

procedure TTipbar.Enablehelp;
begin
  Help:=TRUE;
end;


procedure TTipbar.Disablehelp;
begin
  Help:=FALSE;
end;

procedure TTipbar.ChangeDelay(Delaypar:Word);
begin
  Delay:=Delaypar;
end;

constructor TTipbar.Load(var S: TStream);
var
  X: Integer;

  procedure RestoreStates(P : PTool); far;
  begin
    P^.Read(S);
  end;

begin
  inherited Load(S);
  Attr.Style := ws_Child or ws_Visible or ws_Border ;
  SetFlags(wb_MDIChild, False);
  DefaultProc := @DefWindowProc;
  Capture := nil;
  S.Read(Orientation, SizeOf(Orientation));
  Tools.Init(8,8);

  ResName := nil;
  S.Read(X, SizeOf(X));
  if X = 0 then
    S.Read(PtrRec(ResName).Ofs, SizeOf(Word))
  else
    ResName := S.StrRead;

  ReadResource;
  if Status <> em_InvalidChild then
    Tools.ForEach(@RestoreStates)
  else
    S.Status := stGetError;
end;


procedure TTipbar.Store(var S: TStream);
var
  X: Integer;

  procedure SaveStates(P : PTool); far;
  begin
    P^.Write(S);
  end;

begin
  inherited Store(S);
  S.Write(Orientation, SizeOf(Orientation));
  if HiWord(Longint(ResName)) <> 0 then
  begin
    X := 1;
    S.Write(X, SizeOf(X));
    S.StrWrite(ResName);
  end
  else
  begin
    X := 0;
    S.Write(X, SizeOf(X));
    S.Write(PtrRec(ResName).Ofs, SizeOf(Word));
  end;
  Tools.ForEach(@SaveStates);
end;


procedure TTipbar.ReadResource;
type
  ResRec = record
    Bitmap,
    Command: Word;
  end;

  PResArray = ^TResArray;
  TResArray = array [1..$FFF0 div sizeof(ResRec)] of ResRec;

var
  ResIdHandle: THandle;
  ResDataHandle: THandle;
  ResDataPtr: PResArray;
  Count: Word;
  X: Word;
  Origin: TPoint;
  BitInfo: TBitmap;
  P: PTool;

begin
  ResIDHandle := FindResource(HInstance, ResName, 'HelpToolBarData');
  ResDataHandle := LoadResource(HInstance, ResIDHandle);
  ResDataPtr := LockResource(ResDataHandle);
  if (ResIDHandle = 0) or (ResDataHandle = 0) or (ResDataPtr = nil) then
  begin
    Status := em_InvalidChild;
    Exit;
  end;

  X := 0;
  Origin.X := 2;
  Origin.Y := 2;

  Count := PWord(ResDataPtr)^;
  Inc(LongInt(ResDataPtr), SizeOf(Count)); { Skip Count }
  for X := 1 to Count do
    with ResDataPtr^[1] do
    begin
      P := CreateTool(X, Origin, Command, PChar(Bitmap));
      if P <> nil then
      begin
        NextToolOrigin(X, Origin, P);
        Tools.Insert(P);
      end;
      Inc(Longint(ResDataPtr),sizeof(Resrec));

      if Bitmap<>0 then
      begin
        Strcopy(PTipbutton(P)^.HelpString,Pchar(Resdataptr));
        inc(LongInt(ResdataPtr),strlen(PTipbutton(P)^.HelpString)+1);
      end;
    end;
  Inc(Attr.H, 8);
  Inc(Attr.W, 8);

  UnlockResource(ResDataHandle);
  FreeResource(ResDataHandle);
end;


function TTipbar.CreateTool( Num : Integer; Origin : TPoint; Command : Word;
BitmapName : PChar): PTool;
begin
  if Word(BitmapName) = 0 then
    CreateTool := New(PToolSpacer, Init(@Self, Command))
  else
    CreateTool := New(PTipButton, Init(@Self, Origin.X, Origin.Y, Command,
      BitmapName));
end;


function TTipbar.GetClassName: PChar;
begin
  GetClassName := 'Tipbar';
end;

procedure TTipbar.GetWindowClass(var WC: TWndClass);
begin
  TWindow.GetWindowClass(WC);
  WC.hbrBackground := GetStockObject(LtGray_Brush);
end;


procedure TTipbar.WMMouseMove(var Msg: TMessage);
begin
  if Popwin<>nil then
  begin
    if not((OldMouseCoord.x=TPoint(Msg.Lparam).x) and
(OldMouseCoord.y=TPoint(Msg.Lparam).y)) then
    begin
      Popwin^.Done;
      popwin:=NIL;
    end;
  end;

  If HELP then GetToolUnder(TPoint(Msg.Lparam));

  if (Capture <> nil) then
    Capture^.ContinueCapture(TPoint(Msg.LParam));
end;

procedure TTipbar.GetToolUnder(P:TPoint);
  function IsUnder(Item:PTool):boolean; far;
  begin
    IsUnder := Item^.HitTest(P);
  end;
begin
  ToolToHelp := Tools.firstThat(@IsUnder);
  if ToolToHelp <> nil then
  begin
    SetTimer( Hwindow, 1, Delay, nil);
    OldMouseCoord.x := P.x;
    OldMouseCoord.y := P.y;
  end;
end;

procedure TTipbar.Timermsg(Var Msg:TMessage);
var Co : Tpoint;
begin
  GetCursorPos(Co);
  ScreenToClient(Hwindow,Co);
  GetToolUnder(Co);
  if (PopwIN = nil) and (ToolToHelp <> nil) then
  begin
    co.x := OldMouseCoord.x;
    co.y := OldMouseCoord.y;
    ClientToScreen(Hwindow,Co);
    Popwin := new(PHelpWindow,Init(@self,ToolToHelp,Co,10,10));
    Application^.MakeWindow(Popwin);
    ShowWindow(Popwin^.HWindow,SW_SHOWNOACTIVATE);
    KillTimer(Hwindow,1);
  end;
end;

constructor THelpWindow.Init(AParent : PTipbar; Tool : PTipbutton; WherePos :
TPoint; Width, Height : Word);
var Odc:HDC;
    Rect:TRect;
    Font,OldFont:HFONT;
begin
  with LogicalFont do
  begin
    lfHeight        := 14;
    lfWidth         := 0;
    lfEscapement    := 0;
    lfOrientation   := 0;
    lfWeight        := FW_NORMAL;
    lfItalic        := 0;
    lfUnderline     := 0;
    lfStrikeOut     := 0;
    lfCharSet       := ANSI_CharSet;
    lfOutPrecision  := Out_Default_Precis;
    lfClipPrecision := Clip_Default_Precis;
    lfQuality       := Proof_Quality;
    lfPitchAndFamily:= Variable_Pitch or FF_Roman;
    StrCopy(lfFaceName,'Arial');
  end;
  inherited Init(Aparent,nil);

  ToolToHelp := Tool;

  { Firstly, we will position the window att the x coordinate of the cursor and
10 pixels below the y}

  attr.x := Wherepos.x;
  attr.y := Wherepos.y+10;

  { Then, we calculate the height of the text but we set the maximum width to
be 70 pixels}

  setRect(Rect,0,0,70,0);

  font := CreateFontIndirect(LogicalFont);
  Odc := GetDC(0);
  OldFont := Selectobject(odc,font);
  Drawtext(ODc, ToolToHelp^.HelpString, strlen(ToolToHelp^.HelpString), Rect,
DT_LEFT or DT_CALCRECT or DT_WORDBREAK);

  {Now, we have the width and height of the text in Rect. Then we add a bit to
center the text. }

  Attr.w := Rect.right+10;
  Attr.h := Rect.bottom+10;

  Selectobject(odc,OldFont);
  Deleteobject(Font);
  ReleaseDC(0,Odc);

  { The style is pretty important}

  Attr.Style := ws_border or ws_popup or ws_disabled ;

end;

procedure THelpWindow.Paint(DC: HDC; var PS: TPaintStruct);

var Rect:TRect;
    Font,OldFont:HFONT;

begin

  {First, we measure again the size of the text, unnecessary this should be
stored in an instance variable}
  {instead. A future enhancement.}

  setRect(Rect,0,0,70,0);
  Font := CreateFontIndirect(LogicalFont);
  OldFont := Selectobject(dc,font);
  Drawtext(DC, ToolToHelp^.HelpString,strlen(ToolToHelp^.HelpString),Rect
DT_LEFT or DT_CALCRECT or DT_WORDBREAK);

  OffsetRect(Rect,5,5);

  Drawtext(DC,ToolToHelp^.HelpString,strlen(ToolToHelp^.HelpString),Rect
DT_LEFT or DT_WORDBREAK );
  SelectObject(DC,OldFont);
  Deleteobject(Font);
end;

begin
end.

