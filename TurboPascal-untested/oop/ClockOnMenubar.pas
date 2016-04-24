(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0044.PAS
  Description: Clock on Menubar
  Author: DANNY THORPE
  Date: 08-26-94  08:32
*)

unit clocks;
{$X+}  {allow discardable function results}

{ Clock-on-a-menubar OOP extension to Turbo Vision apps

  Copyright (c) 1990 by Danny Thorpe

  Alarms have not been implemented.
}

interface
uses dos, objects, drivers, views, menus, dialogs, app, msgbox;

const  cmClockChangeDisplay = 1001;
       cmClockSetAlarm = 1002;

       ClockNoSecs   = 0;
       ClockDispSecs = 1;
       Clock12hour   = 0;
       Clock24hour   = 1;

type

     ClockDataRec = record
       Format: word;
       Seconds: word;
       RefreshStr: String[2];
       end;


     PClockMenu = ^TClockMenu;
     TClockMenu = object(TMenuBar)
       ClockOptions: ClockDataRec;
       Refresh: byte;
       LastTime: DateTime;
       TimeStr: string[10];
       constructor Init(var Bounds: TRect; Amenu: PMenu);
       procedure Draw;   virtual;
       procedure Update; virtual;
       procedure SetRefresh(Secs: integer);        virtual;
       procedure SetRefreshStr( Secs: string);     virtual;
       procedure ClockChangeDisplay;               virtual;
       procedure HandleEvent( var Event: TEvent);  virtual;
       function  FormatTimeStr(h,m,s:word):string; virtual;
       end;




implementation


function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;



constructor TClockMenu.Init(var Bounds: TRect; AMenu: PMenu);
  var Temp: PMenuBar;
      ClockMenu: PMenu;
      R: TRect;
  begin
  ClockMenu:= NewMenu(NewSubMenu('~'#0'~Clock ', hcNoContext, NewMenu(
                NewItem('~C~hange display','',0,cmClockChangeDisplay, hcNoContext,
                NewItem('Set ~A~larm','', 0, cmClockSetAlarm, hcNoContext,
                nil))),
                AMenu^.Items));
                { ^^ tack passed menubar on end of new clock menu }
  ClockMenu^.Default:= AMenu^.Default;

  TMenuBar.Init(Bounds, ClockMenu);

  fillchar(LastTime,sizeof(LastTime),#$FF);   {fill with 65000's}
  TimeStr:='';
  ClockOptions.Format:= Clock24Hour;
  ClockOptions.Seconds:= ClockDispSecs;
  SetRefresh(1);
  end;



procedure TClockMenu.Draw;
  var P: PMenuItem;
  begin
  P:= FindItem(#0);
  if P <> nil then
    begin
    DisposeStr(P^.Name);
    P^.Name:= NewStr('~'#0'~'+TimeStr);
    end;
  TMenuBar.Draw;
  end;



procedure TClockMenu.Update;
  var h,m,s,hund: word;
  begin
    GetTime(h,m,s,hund);
    if abs(s-LastTime.sec) >= Refresh then
      begin
      with LastTime do
        begin
        Hour:=h;
        Min:=m;
        Sec:=s;
        end;
      TimeStr:= FormatTimeStr(h,m,s);
      DrawView;
      end;
  end;




procedure TClockMenu.SetRefresh(Secs: integer);
  begin
  if Secs > 59 then
    Secs := 59;
  if Secs < 0 then
    Secs := 0;
  Refresh:= Secs;
  Str(Refresh:2,ClockOptions.RefreshStr);
  end;



procedure TClockMenu.SetRefreshStr( Secs: string);
  var temp,code: integer;
  begin
  val(Secs, temp, code);
  if code = 0 then
    SetRefresh(temp);
  end;




procedure TClockMenu.ClockChangeDisplay;

  var
    D: PDialog;
    Control: PView;
    Command: word;
    temp,code: integer;
    R: TRect;
    ClockData : ClockDataRec;

  begin

  ClockData := ClockOptions;

  R.Assign(14,3,48,15);
  D:= new(PDialog, Init(R, 'Clock Display'));

  R.Assign(3,3,20,5);
  Control:= new(PRadioButtons, Init(R,
            NewSItem('~1~2 hour',
            NewSItem('~2~4 hour',
            nil))));
  D^.Insert(Control);

  R.Assign(3,2,20,3);
  Control:= new(Plabel, Init(R, '~F~ormat', Control));
  D^.Insert(Control);

  R.Assign(3,6,20,7);
  Control:= new(PCheckBoxes, Init(R,
            NewSItem('~S~econds',
            nil)));
  D^.Insert(Control);

  R.Assign(16,9,20,10);
  Control:= new(PInputLine, Init(R, 2));
  D^.Insert(Control);

  R.Assign(2,8,20,9);
  Control:= new(PLabel, Init(R, '~R~efresh Rate', Control));
  D^.Insert(Control);

  R.Assign(2,9,15,10);
  Control:= new(PLabel, Init(R, '0-59 seconds', PLabel(Control)^.Link));
  D^.Insert(Control);

  R.Assign(21,3,31,5);
  Control:= new(PButton, Init(R, '~O~k', cmOk, bfDefault));
  D^.Insert(Control);

  R.Assign(21,6,31,8);
  Control:= new(PButton, Init(R, '~C~ancel', cmCancel, bfNormal));
  D^.Insert(Control);


  D^.SelectNext(False);
  D^.SetData(ClockData);
  repeat
    Command:= Desktop^.ExecView(D);
    if Command = cmOK then
      begin
      D^.GetData(ClockData);
      val(ClockData.RefreshStr,temp,code);
      if (code <> 0) or ((temp<0) or (temp>59)) then
        MessageBox('Refresh rate must be between 0 and 59 seconds.',nil,
           mfOKButton+mfError);
      end;
  until (Command = cmCancel)
     or ((code=0) and ((temp>=0) and (temp<=59)));

  Dispose(D, Done);

  if Command = cmOk then
    begin
    ClockOptions:= ClockData;
    SetRefreshStr(ClockData.RefreshStr);
    end;

  { update display to reflect changes immediately }
  TimeStr:= FormatTimeStr(LastTime.hour, LastTime.min, LastTime.sec);
  DrawView;
  end;





procedure TClockMenu.HandleEvent( var Event: TEvent);
  begin
  TMenuBar.HandleEvent( Event);
  if Event.What = evCommand then
    begin
    case Event.Command of
      cmClockChangeDisplay: ClockChangeDisplay;
      cmClockSetAlarm: ;
      end;
    end;
  end;




function TClockMenu.FormatTimeStr(h,m,s: word): string;
  var st, tail: string;
  begin
  tail:='';
  if ClockOptions.Format = Clock24Hour then
    st:= LeadingZero(h)
  else
    begin
    if h >= 12 then
      begin
      tail:= 'pm';
      if h>12 then
        dec(h,12);
      end
    else
      tail:= 'am';
    if h=0 then h:=12;   {12 am}
    str(h:0,st);    { no leading space on hours }
    end;

  st:=st+':'+ LeadingZero(m);


  if ClockOptions.Seconds = ClockDispSecs then
    st:= st+':'+LeadingZero(s);

  FormatTimeStr:= st + tail;
  end;




end.

{ ----------------------------- DEMO  ---------------------- }

program TestPlatform;

uses Objects, Drivers, Views, Menus, App,
     Dos,     { for the paramcount and paramstr funcs}
     Clocks;  { for the clock on the menubar object, TClockMenu }

{ This generic test platform has been hooked up to the clock-on-the-menubar
  object / unit.  Search for *** to find hook-up points.

  Copyright (c) 1990 by Danny Thorpe
}


const  cmNewWin =   100;
       cmFileOpen = 101;

       WinCount : Integer = 0;
       MaxLines = 50;


type  PInterior = ^TInterior;
      TInterior = object(TScroller)
        constructor init(var Bounds: TRect; AHScrollbar, AVScrollbar: PScrollbar);
        procedure Draw;  virtual;
        end;


      PDemoWindow = ^TDemoWindow;
      TDemoWindow = object(TWindow)
        constructor Init(WindowNo: integer);
        end;


      TMyApp = object(TApplication)
        procedure InitStatusLine;  virtual;
        procedure InitMenuBar;  virtual;
        procedure NewWindow;
        procedure HandleEvent( var Event: TEvent); virtual;
        procedure Idle; virtual;
        end;


var MyApp: TMyApp;
    Lines: array [0..MaxLines-1] of PString;
    LineCount: Integer;


constructor TInterior.Init(var Bounds: TRect; AHScrollbar, AVScrollbar: PScrollbar);
  begin
  TScroller.Init(Bounds,AHScrollbar,AVScrollbar);
  Growmode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofFramed;
  SetLimit(128,LineCount);
  end;


procedure TInterior.Draw;
  var color: byte;
      y,i: integer;
      B: TDrawBuffer;

  begin
  TScroller.Draw;
  Color := GetColor($01);
  for y:= 0 to Size.Y -1 do
    begin
    MoveChar(B,' ',Color,Size.X);
    I := Delta.Y + Y;
    if (I<Linecount) and (Lines[I] <> nil) then
      MoveStr(B,Copy(Lines[I]^,Delta.X+1,size.x),Color);
    WriteLine(0,y,size.x,1,B);
    end;
  end;


procedure ReadFile;
  var  F: text;
       S: string;

  begin
  LineCount:=0;
  if paramcount = 0 then
    assign(F,'clockwrk.pas')
  else
    assign(F,paramstr(1));
  reset(F);
  while not eof(F) and (linecount < maxlines) do
    begin
    readln(f,s);
    Lines[Linecount] := NewStr(S);
    Inc(LineCount);
    end;
  Close(F);
  end;





constructor TDemoWindow.Init(WindowNo: Integer);
  var  LInterior, RInterior: PInterior;
       HScrollbar, VScrollbar: PScrollbar;
       R: TRect;
       Center: integer;

  begin
    R.Assign(0,0,40,15);
    R.Move(Random(40),Random(8));

    TWindow.Init(R, 'Window', wnNoNumber);
    GetExtent(R);
    Center:= (R.B.X + R.A.X) div 2;
    R.Assign(Center,R.A.Y+1,Center+1,R.B.Y-1);
    VScrollbar:= new(PScrollbar, Init(R));
    with VScrollbar^ do Options := Options or ofPostProcess;
    Insert(VScrollbar);
    GetExtent(R);
    R.Assign(R.A.X+2,R.B.Y-1,Center-1,R.B.Y);
    HScrollbar:= new(PScrollbar, Init(R));
    with HScrollbar^ do Options := Options or ofPostProcess;
    Insert(HScrollbar);
    GetExtent(R);
    R.Assign(R.A.X+1,R.A.Y+1,Center,R.B.Y-1);
    LInterior:= new(PInterior, Init(R, HScrollbar, VScrollbar));
    with LInterior^ do
      begin
      Options:= Options or ofFramed;
      Growmode:= GrowMode or gfGrowHiX;
      SetLimit(128,LineCount);
      end;
    Insert(LInterior);

    GetExtent(R);
    R.Assign(R.B.X-1,R.A.Y+1,R.B.X,R.B.Y-1);
    VScrollbar:= new(PScrollbar, Init(R));
    with VScrollbar^ do Options := Options or ofPostProcess;
    Insert(VScrollbar);
    GetExtent(R);
    R.Assign(Center+2,R.B.Y-1,R.B.X-2,R.B.Y);
    HScrollbar:= new(PScrollbar, Init(R));
    with HScrollbar^ do
      begin
      Options := Options or ofPostProcess;
      GrowMode:= GrowMode or gfGrowLoX;
      end;
    Insert(HScrollbar);
    GetExtent(R);
    R.Assign(Center+1,R.A.Y+1,R.B.X-1,R.B.Y-1);
    RInterior:= new(PInterior, Init(R, HScrollbar, VScrollbar));
    with RInterior^ do
      begin
      Options:= Options or ofFramed;
      Growmode:= GrowMode or gfGrowLoX;
      SetLimit(128,LineCount);
      end;
    Insert(RInterior);
    end;




procedure TMyApp.InitStatusLine;
  var R: TRect;

  begin
  GetExtent(R);      { find out how big the current view is }
  R.A.Y := R.B.Y-1;  { squeeze R down to one line at bottom of frame }
  StatusLine := New(PStatusline, Init(R,
                  NewStatusDef(0, $FFFF,
                    NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
                    NewStatusKey('~F4~ New', kbF4, cmNewWin,
                    NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
                    nil))),
                  nil)
                ));
  end;


{ *** The vvv below indicate the primary hook-up point for the menubar-clock.
  This programmer-defined normal menu structure will be tacked onto the
  end of the clock menubar in TClockMenu.Init.
}

procedure TMyApp.InitMenuBar;
  var R: TRect;

  begin
  GetExtent(R);       {***}
  r.b.y:= r.a.y+1;   { vvv }
  Menubar := New(PClockMenu, Init(R, NewMenu(
               NewSubMenu('~F~ile', hcNoContext, NewMenu(
                 NewItem('~O~pen','F3', kbF3, cmFileOpen, hcNoContext,
                 NewItem('~N~ew','F4', kbF4, cmNewWin, hcNoContext,
                 NewLine(
                 NewItem('E~x~it','Alt-X', kbAltX, cmQuit, hcNoContext,
                 nil))))),
               NewSubMenu('~W~indow', hcNoContext, NewMenu(
                 NewItem('~N~ext','F6', kbF6, cmNext, hcNoContext,
                 NewItem('~Z~oom','F7', kbF7, cmZoom, hcNoContext,
                 nil))),
               nil))    { one ) for each menu defined }
             )));
  end;


procedure TMyApp.NewWindow;
  var
    Window: PDemoWindow;
    R: TRect;

  begin
  inc(WinCount);
  Window:= New(PDemoWindow, Init(WinCount));
  Desktop^.Insert(Window);
  end;




{*** clock hook-up point - typecasting required to access "new" method }

procedure TMyApp.Idle;
  begin
  TApplication.Idle;
  PClockMenu(MenuBar)^.Update;
  end;




procedure TMyApp.HandleEvent( var Event: TEvent);
  begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
    begin
      case Event.Command of
        cmNewWin: NewWindow;
      else  { case }
        Exit;
      end;  { case }
      ClearEvent(Event);
    end; {if}
  end;








begin

readfile;

MyApp.Init;
MyApp.run;
MyApp.done;
end.

