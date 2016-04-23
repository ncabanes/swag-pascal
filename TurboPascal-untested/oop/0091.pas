{************************************************}
{                                                }
{   UNIT XAPP   Extended Keyboard Events         }
{   Copyright (c) 1996-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

unit XApp;

interface

uses App, Drivers, Objects, Views;

type
  PXApplication = ^TXApplication;
  TXApplication = object(TApplication)
    procedure GetEvent(var Event: TEvent); virtual;
  end;


const
  { New Keyboard Event }
  evXKeyBoard            = $0400;

  { Extended Key-Codes }
  kbAltDown              = $0011;
  kbAltUp                = $0012;
  kbCtrlDown             = $0013;
  kbCtrlUp               = $0014;
  kbLeftShiftDown        = $0015;
  kbLeftShiftUp          = $0016;
  kbRightShiftDown       = $0017;
  kbRightShiftUp         = $0018;

  WaitForKeyUp : boolean = false;

implementation

const
  ksNormal             = $0000;
  ksRightShift         = $0001;
  ksLeftShift          = $0002;
  ksCtrl               = $0004;
  ksAlt                = $0008;

  KeyState    : byte   = ksNormal;
  OldKeyState : byte   = ksNormal;

  Pending     : TEvent = (What: evNothing);


procedure TXApplication.GetEvent(var Event: TEvent);
var R: TRect;

  function ContainsMouse(P: PView): Boolean; far;
  begin
    ContainsMouse := (P^.State and sfVisible <> 0) and
      P^.MouseInView(Event.Where);
  end;

  procedure PutKeyEvent(var Event: TEvent; Key: word);
  begin
    Event.What   := evXKeyBoard;
    Event.KeyCode:= Key;
  end;

  procedure GetKeyStateEvent(var Event: TEvent);
  begin
    KeyState:= GetShiftState and $000F;
    if KeyState <> OldKeyState then
    begin
      if not WaitForKeyUp then
        case KeyState of
          ksLeftShift : PutKeyEvent(Event, kbLeftShiftDown);
          ksRightShift: PutKeyEvent(Event, kbRightShiftDown);
          ksAlt       : PutKeyEvent(Event, kbAltDown);
          ksCtrl      : PutKeyEvent(Event, kbCtrlDown);
          ksNormal    :
            case OldKeyState of
              ksLeftShift : PutKeyEvent(Event, kbLeftShiftUp);
              ksRightShift: PutKeyEvent(Event, kbRightShiftUp);
              ksAlt       : PutKeyEvent(Event, kbAltUp);
              ksCtrl      : PutKeyEvent(Event, kbCtrlUp);
            end;
        end;
      OldKeyState := KeyState;
      WaitForKeyUp:= false;
    end;
  end;


begin
  if Pending.What <> evNothing then
  begin
    Event:= Pending;
    Pending.What:= evNothing;
  end else
  begin
    GetMouseEvent(Event);
    if Event.What = evNothing then
    begin
      GetKeyEvent(Event);
      if Event.What = evNothing then
      begin
        GetKeyStateEvent(Event);
        if Event.What = evNothing then Idle;
      end else WaitForKeyUp:= true
    end;
  end;

  if StatusLine <> nil then
    if (Event.What and evKeyDown <> 0) or
      (Event.What and evMouseDown <> 0) and
      (FirstThat(@ContainsMouse) = PView(StatusLine)) then
      StatusLine^.HandleEvent(Event);
end;



end.
{ --------------- DEMO ------------ CUT HERE !! }

{************************************************}
{                                                }
{   PROGRAM XTEST  Testapp for XAPP Unit         }
{   Copyright (c) 1996-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

program XTest;

uses Drivers, XApp;

type
  TApp = object(TXApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


procedure TApp.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evXKeyBoard then
    if Event.KeyCode = kbAltUp then write(#7);
end;

var
  MyApp: TApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.