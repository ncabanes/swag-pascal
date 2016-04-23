unit ColorApp;

{ see the DEMO unit at the end of this code snipet }
{
 COLORAPP.PAS v1.00 -- Unit for making "pretty" applications

 Written by Scott F. Earnest (scott@whiplash.res.cmu.edu)


 This unit defines three objects:

   TColorApplication -- A simple descendant of TApplication.  It uses color
     text screen images in place of the common "hash" backdrop.
   TColorDesktop -- An intermediate object, direct descendant of TDesktop.
   TColorBackground -- A descendant of TBackground, this object is the one
     that actually manages color images.


 Credits to:

 - Unknown author of source that appears in SWAG -- this is my effort to take
   that badly kludged source and make a valid, functional tool from it.

 - Portions of this code Copyright (C) 1992 Borland International (I had to
   cheat the Init method of TColorApplication to keep it from zeroing out
   the proper pointers.


 Bug reports, upgrade suggestions, comments, flames, humble cash contri-
 butions to author.  Standard disclaimers apply.  Free for general use, but
 if you use this code in a shareware or commercial product, please contact
 me to offer some sort of compensation; i.e., if you profit from this, I'd
 better profit, too!

 Please do not add this code to the SWAG collection.  It will be distributed
 in package form via FTP sites.
}

interface

uses
  App, Objects;

{ -- Public Object Declarations ------------------------------------------- }

type
  PColorApplication = ^TColorApplication;
  TColorApplication = object(TApplication)
    Image25, Image43, Image50 : pointer;
    Len25, Len43, Len50 : word;
    constructor Init;
    destructor Done; virtual;
    procedure InitDesktop; virtual;
    procedure FreeImages; virtual;
    procedure LoadImages; virtual;
  end;

type
  PColorDesktop = ^TColorDesktop;
  TColorDesktop = object(TDesktop)
    Image25, Image43, Image50 : pointer;
    Len25, Len43, Len50 : word;
    constructor Init (var Bounds : TRect;
                      i25, i43, i50 : pointer; l25, l43, l50 : word);
    procedure InitBackground; virtual;
  end;

type
  PColorBackground = ^TColorBackground;
  TColorBackground = object(TBackground)
    Background25,
    Background43,
    Background50 : pointer;
    BGLen25, BGLen43, BGLen50 : word;
    constructor Init (var Bounds : TRect; i25, i43, i50 : pointer;
                      l25, l43, l50 : word);
    procedure Draw; virtual;
  end;

implementation

uses
  Views, Memory, Drivers, HistList;

{ -- TColorApplication ---------------------------------------------------- }

constructor TColorApplication.init;

var
  R : TRect;

begin
  {App.TApplication.Init:}
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  InitHistory;
  {End App.TApplication.Init}

  {App.TProgram.Init:}
  Application := @Self;
  InitScreen;
  R.Assign(0, 0, ScreenWidth, ScreenHeight);
  TGroup.Init(R);
  State := sfVisible + sfSelected + sfFocused + sfModal + sfExposed;
  Options := 0;
  Buffer := ScreenBuffer;
  LoadImages; {This line inserted.}
  InitDesktop;
  InitStatusLine;
  InitMenuBar;
  if Desktop <> nil then Insert(Desktop);
  if StatusLine <> nil then Insert(StatusLine);
  if MenuBar <> nil then Insert(MenuBar);
  {End App.TProgram.Init}
end;

destructor TColorApplication.Done;

begin
  FreeImages;
  inherited done;
end;

procedure TColorApplication.FreeImages;

{
 Use this method to free loaded images if they are loaded onto the heap.
 Default action is to do nothing.
}

begin
end;

procedure TColorApplication.InitDesktop;

var
  R : TRect;

begin
  GetExtent(R);
  inc(R.A.Y);
  dec(R.B.Y);
  Desktop := new(PColorDesktop,init(R,image25,image43,image50,
                                    len25,len43,len50));
end;

procedure TColorApplication.LoadImages;

{
 Use this method to allocate and/or load the image buffers and set the
 proper lengths.
}

begin
  Abstract;
end;

{ -- TColorDesktop -------------------------------------------------------- }

constructor TColorDesktop.Init (var Bounds : TRect;
                                i25, i43, i50 : pointer;
                                l25, l43, l50 : word);

begin
  TGroup.Init(Bounds);
  GrowMode := gfGrowHiX or gfGrowHiY;
  image25 := i25;
  image43 := i43;
  image50 := i50;
  len25 := l25;
  len43 := l43;
  len50 := l50;
  InitBackground;
  if Background <> nil then
    Insert(Background);
end;

procedure TColorDesktop.InitBackground;

var
  R : TRect;

begin
  GetExtent(R);
  Background := new (PColorBackground,init(R,image25,image43,image50,
                                           len25,len43,len50));
end;

{ -- TColorBackground ----------------------------------------------------- }

constructor TColorBackground.Init (var Bounds : TRect;
                                   i25, i43, i50 : pointer;
                                   l25, l43, l50 : word);

begin
  inherited Init (Bounds,#176);
  Background25 := i25;
  Background43 := i43;
  Background50 := i50;
  BGLen25 := l25;
  BGLen43 := l43;
  BGLen50 := l50;
end;

procedure TColorBackground.Draw;

var
  Background : pointer;
  R : TRect;

begin
  getextent (R);
  case R.B.Y of
    23 .. 25 : BackGround := Background25;
    41 .. 43 : BackGround := Background43;
    48 .. 50 : BackGround := Background50;
  else
    BackGround := Background25;
  end;
  WriteBuf (0,0,R.B.X,R.B.Y,Background^);
end;

end.

{ -----------------------   DEMO ----------------------------- }
program Colordesk;

{
 CA-DEMO.PAS -- Demonstration for the ColorApp Unit

 Written by Scott F. Earnest (scott@whiplash.res.cmu.edu)


 It's almost the same as a normal application!
}

uses
  ColorApp, App, Objects, Views, Menus, Drivers, Msgbox, Dialogs;

{Command constants}

const
  cmOptionsVideo = 1501;
  cmMessageHello = 1502;
  cmAppAbout     = 1503;

{These are the raw screen images}

procedure data_25_lines; external;
{$L LINES_25}  { OBJ code  -- extract XX3402 OBJ files at end of this snipet}

procedure data_43_lines; external;
{$L LINES_43}

procedure data_50_lines; external;
{$L LINES_50}

{ -- Application Object --------------------------------------------------- }

type
  PDemoApp = ^TDemoApp;
  TDemoApp = object(TColorApplication)
    procedure LoadImages; virtual;
    procedure initmenubar; virtual;
    procedure About; virtual;
    procedure HandleEvent (var Event : TEvent); virtual;
  end;

procedure TDemoApp.LoadImages;

begin
  image25 := @data_25_lines;
  len25 := 2000;
  image43 := @data_43_lines;
  len43 := 3440;
  image50 := @data_50_lines;
  len50 := 4000;
end;

procedure TDemoApp.InitMenuBar;

var
  r : TRect;

begin
  getextent(R);
  R.B.Y := R.A.Y + 1;
  menubar := new(pmenubar, init(R, NewMenu(
    NewSubMenu('~A~ction', hcNoContext, NewMenu(
      NewItem('Toggle ~L~ines', 'F7', kbF7, cmOptionsVideo, hcNoContext,
      NewItem('Say ~H~ello...', 'F8', kbF8, cmMessageHello, hcNoContext,
      NewLine(
      NewItem('About...', 'F1', kbF1, cmAppAbout, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X',kbAltX, cmQuit, hcNoContext,
      nil))))))),
    nil)
  )));
end;

procedure TDemoApp.About;

var
  D: PDialog;
  Control: PView;
  R: TRect;

begin
  R.Assign (0,0,40,12);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;
    Flags := Flags and not (wfMove or wfGrow or wfZoom or wfClose);
    R.Grow(-1, -1);
    Dec(R.B.Y, 1);
    Insert(New(PStaticText, Init(R,
      #13#3'Color DeskTop Demo'#13#13+
      #3'by Scott F. Earnest'#13+
      #3'(scott@whiplash.res.cmu.edu)'#13#13+
      #3'Screens created with TheDraw(TM)'#13)));
    R.Assign (15,9,25,11);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  if ValidView(D)<>nil then
  begin
    DeskTop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

procedure TDemoApp.HandleEvent (var Event : TEvent);

begin
  inherited HandleEvent (Event);
  if Event.What=evCommand then
    case Event.Command of
      cmOptionsVideo : begin
                         SetScreenMode(ScreenMode xor smFont8x8);
                         ClearEvent (Event);
                       end;
      cmMessageHello : begin
                         messagebox (#3'Hello!  Move me around!'#13,nil,
                                      mfInformation or mfOKButton);
                         ClearEvent (Event);
                       end;
      cmAppAbout     : begin
                         About;
                         ClearEvent (Event);
                       end;
    end;
end;

var
  Appl : TDemoApp;

begin
  Appl.init;
  Appl.About;
  Appl.run;
  Appl.done;
end.

{ OJECT CODE FILES NEED FOR THE DEMO
  Cut each one out and name accordingly
  Use XX3402 to decode these fragments  : XX3402 D filename
  Each of the OBJ files will be created



*XX3402-004084-040296--72--85-62270----LINES_25.OBJ--1-OF--1
U+E++Xcu-dM6+++2Eox2FE-1a+Q+88+D+U2-Vd+I+++-1IF-J23TAXJTH2ZCFJA+++0Ic+E2
+E++6+zQ+RkNrlLTLRlRrpHTHBlAr+EU1m+Dr+HTTxlzrrDTCxkvrnPTPhlirq9Q+W+D6+wU
1m+Dr+fT6RwNr+YU1m+D6+wU1m+D6+wU1m+D6+zQ+xkvr+AU1m+Dr+zTQxwvr+gU1m+D6+zQ
-hwer0fQ+W+Dr+jTBhxir4vTMhwer0fT6RwNr-bQ+G+D6+zQ+hwNr-bT3RxRr3rTJBxAr+kU
1xwer0fT6Rw7rk5T-RxRr3rTJBxAr2kU1xxAr2nTFxxzrkTT+xw9rkDT-hwCrkMU1m+D6+wU
1xxWrmfQ8hwV6+wU1m+D6+wU1m+D6+wU1xxzr5zTQxwvr1gU1xx5rrzQTxxnrnjQ0m+DrqvQ
PhxWrmcU1xxnrnjQCxwq6+wU1m+D6+zT+hw-rkYU1xxWrmfQ8hwVrkYU1xw3rprQLRxIrokU
1m+D6+wU1xk0rlbQ4RwJrprT-G+D6+zQLRxIronQHBx5rrzQTxxnrnjQ0m+D6+wU1m+D6+zT
Phlirq9T8W+D6+wU1m+D6+wU1m+D6+zQHBx5rrzQTxxn6+zTHBlAroTTTxlzrrDTCxkvrnPT
Phli6+zTTxlzrrDTCxk9r+DQ-hkCr+MU1m+D6+zT1hlirq9T8hkerm5Q+Rk76+wU1m+D6+wU
1xkCrq9T8hkerm5T0G+D6+wU1m+D6+zT1Rw3rkHT1Bw2rkTTTxlzrrDTCm+D6+wU1m+Dr1jT
Bhxir4sU1m+D6+wU1m+D6+wU1m+DrpHTHBlAroTTTm+Dr3rTJBxAr2nT-xxzr5zTQxwvr1jT
BW+Dr2nTFxxzr5zT+xw9rkDT-hwC6+wU1m+D6+wU1m+DrkPT+hwer0fT6RwNr-bQ+Rk1r1jT
Bhxir4vTMhk0r+fQ+hk-r+YU1xk-r+bQ+Rk3r+rQ-Rk2r2nTFxxzr5wU1m+D6+wU1xxnrnjQ
Cxwqr+PQ1hk4r+9Q0hk0r+2U1xxRr3rTJBxAr2kU1xwJrprQLRxI6+wU1xw5rrzQTxxnrngU
1xxIronQHBx56+wU1m+D6+zQ0xk1r+MU1xxnrnjQCxwqr+MU1xk4rmfQ8hwVrlbT-xxnrnjQ
CxwqrqvQPhxWrmfQ8hw-6+zT+hwVrlbQ4RwJrprQLRxIronT-0+D6+wU1m+D6+wU1xw5rrDT
CxkvrnPTPhlirq9T8hw06+wU1xw3rprT-G+D6+zT0RkNrlLT1G+D6+wU1xw2roTTTxw56+zT
1RlRrpHTHBlAroTTTxlzrrDTCxw16+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1lSU-+E-++EU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1xk-
r-bT3RxRr3rTJBxAr2nQ-0+D6+zQ-Bxzr5zTQxwvr1jTBhxir4vTMhk06+wU1m+D6+zQ0hwV
rlbQ0G+D6+wU1m+D6+wU1m+D6+wU1xk1r1jQ+m+D6+zQ1xxnrnjQ0m+D6+wU1xk4rmfQ8hk0
6+zQ0xwqrqvQPhxWrmfQ8hwVrlbQ4Rk-6+wU1xk0rlbQ4RwJrprQLRxIronQ10+DrmfQ8hwV
rkbT+Rw3rprQLRxIronQH0+DronQHBx5rrzT-xw1rkjT+xw4rkvT-W+D6+wU1m+Drq9T8hke
rm2U1m+D6+wU1m+D6+wU1m+DrrzQTxxnrnjQCm+DroTTTxlzrrDTCxk96+zTPhlirq9T8W+D
rrDTCxkvrnMU1m+D6+wU1xw0rk5T0G+Drq9T8hkerm5T0G+DrkLTLRlRrpHTH0+D6+wU1m+D
r+9T4RkNrlLTLRw36+wU1xlRrpHTHBlAroTTTxlzrrDTCxk96+wU1m+D6+wU1xxir4vTMhwe
6+wU1m+D6+wU1m+D6+wU1xlAroTTTxlzrrAU1xxAr2nTFxxzr5zTQxwvr1jTBhxir4sU1xxz
r5zTQxwvr+jQ+xk4r+vQ-W+D6+wU1xwCr4vTMhwer0fT6Rk-r+YU1m+D6+wU1m+Dr+vTMhwe
r0fT6Rw76+wU1m+D6+wU1xwBrkLT-BwArkHT-xxzr5zTQxwv6+wU1m+D6+zQCxwqrqvQPW+D
6+wU1m+D6+wU1m+D6+zTJBxAr2nTFxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5
rrzQTxw1rkjT+xw4rksU1m+D6+wU1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-r+DQCxwqrqvQPhxW
r+9Q0hk0r+5Q0G+Dr+5Q0Rk-r+LQ1Rk3r+HQHBx5rrzQTm+D6+wU1m+DrrDTCxkvrnPQ-hkC
r+PQ+hk8r+9Q+G+DrprQLRxIronQH0+DrlLTLRlRrpEU1m+DrkTTTxlzrrDTCm+DrpHTHBlA
roQU1m+D6+wU1xk9r+DQ-W+DrrDTCxkvrnPQ-W+Dr+PT8hkerm5T4Rw5rrDTCxkvrnPTPhli
rq9T8hkerk2U1xw0rm5T4RkNrlLTLRlRrpHTHBw26+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxi
r4vTMhwerk6U1m+DrkLTLRw36+wU1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxA
r2nTFxxza8+2-+2+0BlzrrDTCxw16+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+Dr+5Q4RwJrprQ
LRxIronQHBk26+wU1xk2rrzQTxxnrnjQCxwqrqvQPhxWr+6U1m+D6+wU1xk8rm5T4Rk76+wU
1m+D6+wU1m+D6+wU1m+Dr+DQCxk16+wU1xkDrrDTCxk96+wU1m+Dr+PT8hker+6U1xk9rnPT
Phlirq9T8hkerm5T4RkNr+2U1m+Dr+9T4RkNrlLTLRlRrpHTHBkA6+zT8hkerm5T0Rw-rkLT
LRlRrpHTHBlA6+zTHBlAroTTTxw5rkDT0xw1rkPT1hw46+wU1m+D6+zTMhwer0fT6G+D6+wU
1m+D6+wU1m+D6+zTTxlzrrDTCxkv6+zTFxxzr5zTQxwvr+gU1xxir4vTMhwe6+zTQxwvr1jT
BW+D6+wU1m+Drk9T+Rw76+zTMhwer0fT6Rw76+zT-RxRr3rTJBxA6+wU1m+D6+zQ+hwNr-bT
3RxRrkIU1m+Dr3rTJBxAr2nTFxxzr5zTQxwvr+gU1m+D6+wU1m+DrqvQPhxWrmcU1m+D6+wU
1m+D6+wU1m+Dr2nTFxxzr5zTQm+DronQHBx5rrzQTxxnrnjQCxwqrqvQPW+DrrzQTxxnrnjQ
0xk1r+PQ1hk46+wU1m+DrkvQPhxWrmfQ8hwVr+5Q0G+D6+wU1m+D6+zQ1hxWrmfQ8hwVrkYU
1m+D6+wU1m+DrkrT-Rw2rknT-Bw5rrzQTxxnrngU1m+D6+wU1xkvrnPTPhli6+wU1m+D6+wU
1m+D6+wU1xxIronQHBx5rrwU1xlRrpHTHBlArkTTTxlzrrDTCxkvrnMU1xlAroTTTxlzrkDT
0xw1rkPT1W+D6+wU1m+D6+wU1xw4rk9T8hkerm5T4RkNr+5Q+xkvrnPTPhlirq9Q+hk8r+9Q
+Rk76+zQ+Rk7r+5Q-RkBr+LQ-BlAroTTTxlz6+wU1m+D6+zTQxwvr1jTBhk4r+vQ-hk0r+fQ
+hk-6+zTLRlRrpHTHBlA6+zT3RxRr3rTJ0+D6+zT-xxzr5zTQxwv6+zTJBxAr2nTFm+D6+wU
1m+Dr+jQ+xk46+zTQxwvr1jTBhk46+zQ-hwer0fT6RwNrkTTQxwvr1jTBhxir4vTMhwer0fT
+G+Drk9T6RwNr-bsc8E1+E+ArlLTLRlRrpHTHBw26+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxi
r4vTMhwerk6U1m+DrkLTLRw36+wU1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxA
r2nTFxxzr5zTQxwvrkAU1m+DrkTTQxwvr1jTBhxir4vTMhw86+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+zQ+RkNrlLTLRlRrpHTHBlA
r+EU1m+Dr+HTTxlzrrDTCxkvrnPTPhlirq9Q+W+D6+wU1m+Dr+fT6RwNr+YU1m+D6+wU1m+D
6+wU1m+D6+zQ+xkvr+AU1m+Dr+zTQxwvr+gU1m+D6+zQ-hwer0fQ+W+Dr+jTBhxir4vTMhwe
r0fT6RwNr-bQ+G+D6+zQ+hwNr-bT3RxRr3rTJBxAr+kU1xwer0fT6Rw7rk5T-RxRr3rTJBxA
r2kU1xxAr2nTFxxzrkTT+xw9rkDT-hwCrkMU1m+D6+wU1xxWrmfQ8hwV6+wU1m+D6+wU1m+D
6+wU1xxzr5zTQxwvr1gU1xx5rrzQTxxnrnjQ0m+DrqvQPhxWrmcU1xxnrnjQCxwq6+wU1m+D
6+zT+hw-rkYU1xxWrmfQ8hwVrkYU1xw3rprQLRxIrokU1m+D6+wU1xk0rlbQ4RwJrprT-G+D
6+zQLRxIronQHBx5rrzQTxxnrnjQ0m+D6+wU1m+D6+zTPhlirq9T8W+D6+wU1m+D6+wU1m+D
6+zQHBx5rrzQTxxn6+zTHBlAroTTTxlzrrDTCxkvrnPTPhli6+zTTxlzrrDTCxk9r+DQ-hkC
r+MU1m+D6+zT1hlirq9T8hkerm5Q+Rk76+wU1m+D6+wU1xkCrq9T8hkerm5T0G+D6+wU1m+D
6+zT1Rw3rkHT1Bw2rkTTTxlzrrDTCm+D6+wU1m+Dr1jTBhxir4sU1m+D6+wU1m+D6+wU1m+D
rpHTHBlAroTTTm+Dr3rTJBxAr2nT-xxzr5zTQxwvr1jTBW+Dr2nTFxxzr5zT+xw9rkDT-hwC
6+wU1m+D6+wU1m+DrkPT+hwer0fT6RwNr-bQ+KG8+U++R+++
***** END OF BLOCK 1 *****

{---------------------------------- }


*XX3402-006985-040296--72--85-21224----LINES_43.OBJ--1-OF--2
U+E++Xcu-dM6+++2Eox2FE-1a+Q+8C+O+U2-Ct+I+++-1IF-J23TB1BTH2ZCFJA+++0Ic+E2
+E++6+zQ+hk-6+wU1m+Dr+rTJBxAr+kU1m+Dr+LTHBlAroTTTxlzrrDTCxk96+wU1m+D6+wU
1m+Dr+fT6RwNr+YU1m+D6+wU1m+D6+wU1m+D6+zQ+xkvr+AU1m+Dr+zTQxwvr+gU1m+D6+zQ
-hwer0fQ+W+Dr+jTBhxir4vTMhwer0fT6RwNr-bQ+G+D6+zQ+hwNr-bT3RxRr3rTJBxAr+kU
1xxWrmfQ8hwV6+wU1xwJrprQLRxI6+zT3RxRrkIU1m+D6+zT-xxzr5zTQxwv6+wU1m+D6+wU
1xxWrmfQ8hwV6+wU1m+D6+wU1m+D6+wU1xxzr5zTQxwvr1gU1xx5rrzQTxxnrnjQ0m+DrqvQ
PhxWrmcU1xxnrnjQCxwq6+wU1m+D6+zT+hw-rkYU1xxWrmfQ8hwVrkYU1xw3rprQLRxIronT
Phlirq9T8hk8r+9T4RkNrlLTLG+D6+wU1m+D6+zQ1Rk3r+HQHBx5rrzT-m+D6+wU1m+D6+zT
Phlirq9T8W+D6+wU1m+D6+wU1m+D6+zQHBx5rrzQTxxn6+zTHBlAroTTTxlzrrDTCxkvrnPT
Phli6+zTTxlzrrDTCxk9r+DQ-hkCr+MU1m+D6+zT1hlirq9T8hkerm5Q+Rk76+wU1m+DrkDT
Bhxir4vTMhwer0fT6RwNr-YU1m+D6+wU1m+DrkLT1Rw3rpHTHBlAr+EU1m+D6+wU1m+Dr1jT
Bhxir4sU1m+D6+wU1m+D6+wU1m+DrpHTHBlAroTTTm+Dr3rTJBxAr2nT-xxzr5zTQxwvr1jT
BW+Dr2nTFxxzr5zT+xw9rkDT-hwC6+wU1m+D6+wU1m+DrkPT+hwer0fT6RwNr-bQ+G+D6+wU
1m+D6+wU1xxWrmfQ8hwV6+zTMhwer+cU1m+D6+zQ+RxRr3rTJBxA6+wU1m+D6+wU1xxnrnjQ
Cxwqr+PQ1hk4r+9Q0hk0r+2U1xxRr3rTJBxAr2kU1xwJrprQLRxI6+wU1xw5rrzQTxxnrngU
1xxIronQHBx56+wU1m+D6+zQ0xk1r+MU1xxnrnjQCxwqr+MU1xk4rmfQ8hwVrlYU1m+D6+wU
1m+D6+zT1hlirq9T0W+D6+zT-hxWrmfQ8hwVrlbQ4RwJrkoU1m+D6+wU1m+D6+wU1xw5rrDT
CxkvrnPTPhlirq9T8hw06+wU1xw3rprT-G+D6+zT0RkNrlLT1G+D6+wU1xw2roTTTxw56+zT
1RlRrpHTHBlAroTTTxlzrrDTCxw16+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1qGU-+E-++EU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1xk0
r+2U1m+D6+zQ1RxIronQ10+D6+zQ-RxAr2nTFxxzr5zTQxwvr+gU1m+D6+wU1m+D6+zQ0hwV
rlbQ0G+D6+wU1m+D6+wU1m+D6+wU1xk1r1jQ+m+D6+zQ1xxnrnjQ0m+D6+wU1xk4rmfQ8hk0
6+zQ0xwqrqvQPhxWrmfQ8hwVrlbQ4Rk-6+wU1xk0rlbQ4RwJrprQLRxIronQ10+Drq9T8hke
rm2U1m+DrlLTLRlRrpEU1xwJrprT-G+D6+wU1xw5rrzQTxxnrngU1m+D6+wU1m+Drq9T8hke
rm2U1m+D6+wU1m+D6+wU1m+DrrzQTxxnrnjQCm+DroTTTxlzrrDTCxk96+zTPhlirq9T8W+D
rrDTCxkvrnMU1m+D6+wU1xw0rk5T0G+Drq9T8hkerm5T0G+DrkLTLRlRrpHTHBxir4vTMhwe
r+fQ+hwNr-bT3RxR6+wU1m+D6+wU1xkBr+LQ-BlAroTTTxw56+wU1m+D6+wU1xxir4vTMhwe
6+wU1m+D6+wU1m+D6+wU1xlAroTTTxlzrrAU1xxAr2nTFxxzr5zTQxwvr1jTBhxir4sU1xxz
r5zTQxwvr+jQ+xk4r+vQ-W+D6+wU1xwCr4vTMhwer0fT6Rk-r+YU1m+D6+zT+xwqrqvQPhxW
rmfQ8hwVrlbQ4G+D6+wU1m+D6+zT-RwBrkLTJBxAr2nQ-0+D6+wU1m+D6+zQCxwqrqvQPW+D
6+wU1m+D6+wU1m+D6+zTJBxAr2nTFxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5
rrzQTxw1rkjT+xw4rksU1m+D6+wU1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-6+wU1m+D6+wU1m+D
rq9T8hkerm2U1xxWrmfQ0W+D6+wU1xk-rprQLRxIrokU1m+D6+wU1m+DrrDTCxkvrnPQ-hkC
r+PQ+hk8r+9Q+G+DrprQLRxIronQH0+DrlLTLRlRrpEU1m+DrkTTTxlzrrDTCm+DrpHTHBlA
roQU1m+D6+wU1xk9r+DQ-W+DrrDTCxkvrnPQ-W+Dr+PT8hkerm5T4G+D6+wU1m+D6+wU1xwC
r4vTMhw86+wU1xw4rq9T8hkerm5T4RkNrlLT1G+D6+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxi
r4vTMhwerk6U1m+DrkLTLRw36+wU1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxA
r2nTFxxztO+2-+2+0BlzrrDTCxw16+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+Dr+9Q+G+D6+wU
1xkBrpHTHBkA6+wU1xk3ronQHBx5rrzQTxxnrnjQ0m+D6+wU1m+D6+wU1xk8rm5T4Rk76+wU
1m+D6+wU1m+D6+wU1m+Dr+DQCxk16+wU1xkDrrDTCxk96+wU1m+Dr+PT8hker+6U1xk9rnPT
Phlirq9T8hkerm5T4RkNr+2U1m+Dr+9T4RkNrlLTLRlRrpHTHBkA6+zTMhwer0fT6G+D6+zT
3RxRr3rTJ0+DrlLTLRw36+wU1m+DrkTTTxlzrrDTCm+D6+wU1m+D6+zTMhwer0fT6G+D6+wU
1m+D6+wU1m+D6+zTTxlzrrDTCxkv6+zTFxxzr5zTQxwvr+gU1xxir4vTMhwe6+zTQxwvr1jT
BW+D6+wU1m+Drk9T+Rw76+zTMhwer0fT6Rw76+zT-RxRr3rTJBxArqvQPhxWrmfQ0hk0rlbQ
4RwJrpoU1m+D6+wU1m+Dr+rQ-Rk2r2nTFxxzrkQU1m+D6+wU1m+DrqvQPhxWrmcU1m+D6+wU
1m+D6+wU1m+Dr2nTFxxzr5zTQm+DronQHBx5rrzQTxxnrnjQCxwqrqvQPW+DrrzQTxxnrnjQ
0xk1r+PQ1hk46+wU1m+DrkvQPhxWrmfQ8hwVr+5Q0G+D6+wU1xw1rnPTPhlirq9T8hkerm5T
4RkN6+wU1m+D6+wU1xw3rkrT-RxIronQHBk26+wU1m+D6+wU1xkvrnPTPhli6+wU1m+D6+wU
1m+D6+wU1xxIronQHBx5rrwU1xlRrpHTHBlArkTTTxlzrrDTCxkvrnMU1xlAroTTTxlzrkDT
0xw1rkPT1W+D6+wU1m+D6+wU1xw4rk9T8hkerm5T4RkNr+2U1m+D6+wU1m+D6+zTMhwer0fT
6G+Drq9T8hk86+wU1m+Dr+5TLRlRrpHTH0+D6+wU1m+D6+zTQxwvr1jTBhk4r+vQ-hk0r+fQ
+hk-6+zTLRlRrpHTHBlA6+zT3RxRr3rTJ0+D6+zT-xxzr5zTQxwv6+zTJBxAr2nTFm+D6+wU
1m+Dr+jQ+xk46+zTQxwvr1jTBhk46+zQ-hwer0fT6RwN6+wU1m+D6+wU1m+DrkvQPhxWrkcU
1m+DrkPTMhwer0eLc+E2+E+Arm5T4RkNrlLT1G+D6+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxi
r4vTMhwerk6U1m+DrkLTLRw36+wU1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxA
r2nTFxxzr5zTQxwvrkAU1m+DrkTTQxwvr1jTBhxir4vTMhw86+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+zQ+hk-6+wU1m+Dr+rTJBxA
r+kU1m+Dr+LTHBlAroTTTxlzrrDTCxk96+wU1m+D6+wU1m+Dr+fT6RwNr+YU1m+D6+wU1m+D
6+wU1m+D6+zQ+xkvr+AU1m+Dr+zTQxwvr+gU1m+D6+zQ-hwer0fQ+W+Dr+jTBhxir4vTMhwe
r0fT6RwNr-bQ+G+D6+zQ+hwNr-bT3RxRr3rTJBxAr+kU1xxWrmfQ8hwV6+wU1xwJrprQLRxI
6+zT3RxRrkIU1m+D6+zT-xxzr5zTQxwv6+wU1m+D6+wU1xxWrmfQ8hwV6+wU1m+D6+wU1m+D
6+wU1xxzr5zTQxwvr1gU1xx5rrzQTxxnrnjQ0m+DrqvQPhxWrmcU1xxnrnjQCxwq6+wU1m+D
6+zT+hw-rkYU1xxWrmfQ8hwVrkYU1xw3rprQLRxIronTPhlirq9T8hk8r+9T4RkNrlLTLG+D
6+wU1m+D6+zQ1Rk3r+HQHBx5rrzT-m+D6+wU1m+D6+zTPhlirq9T8W+D6+wU1m+D6+wU1m+D
6+zQHBx5rrzQTxxn6+zTHBlAroTTTxlzrrDTCxkvrnPTPhli6+zTTxlzrrDTCxk9r+DQ-hkC
r+MU1m+D6+zT1hlirq9T8hkerm5Q+Rk76+wU1m+DrkDTBhxir4vTMhwer0fT6RwNr-YU1m+D
6+wU1m+DrkLT1Rw3rpHTHBlAr+EU1m+D6+wU1m+Dr1jTBhxir4sU1m+D6+wU1m+D6+wU1m+D
rpHTHBlAroTTTm+Dr3rTJBxAr2nT-xxzr5zTQxwvr1jTBW+Dr2nTFxxzr5zT+xw9rkDT-hwC
6+wU1m+D6+wU1m+DrkPT+hwer0fT6RwNr-bQ+G+D6+wU1m+D6+wU1xxWrmfQ8hwV6+zTMhwe
r+cU1m+D6+zQ+RxRr3rTJBxA6+wU1m+D6+wU1xxnrnjQCxwqr+PQ1hk4r+9Q0hk0r+2U1xxR
r3rTJBxAr2kU1xwJrprQLH8U-+E-+-1TJ0+D6+zT-xxzr5zTQxwv6+zTJBxAr2nTFm+D6+wU
1m+Dr+jQ+xk46+zTQxwvr1jTBhk46+zQ-hwer0fT6RwN6+wU1m+D6+wU1m+DrkvQPhxWrkcU
1m+DrkPTMhwer0fT6RwNr-bT3RwB6+wU1m+D6+wU1m+D6+zT-xxnrnjQCxwqrqvQPhxWrmfT
+W+D6+zT-RxRrkIU1m+DrkbQ4RwJrkoU1m+D6+zT-Bx5rrzT-m+DrkrQLRxIronQHBx5rrzQ
TxxnrnjT+m+D6+zT-xxnrnjQCxwqrqvQPhxWrkcU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
***** END OF BLOCK 1 *****



*XX3402-006985-040296--72--85-03267----LINES_43.OBJ--2-OF--2
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1xk0r+2U1m+D6+zQ1RxIronQ10+D6+zQ
-RxAr2nTFxxzr5zTQxwvr+gU1m+D6+wU1m+D6+zQ0hwVrlbQ0G+D6+wU1m+D6+wU1m+D6+wU
1xk1r1jQ+m+D6+zQ1xxnrnjQ0m+D6+wU1xk4rmfQ8hk06+zQ0xwqrqvQPhxWrmfQ8hwVrlbQ
4Rk-6+wU1xk0rlbQ4RwJrprQLRxIronQ10+Drq9T8hkerm2U1m+DrlLTLRlRrpEU1xwJrprT
-G+D6+wU1xw5rrzQTxxnrngU1m+D6+wU1m+Drq9T8hkerm2U1m+D6+wU1m+D6+wU1m+DrrzQ
TxxnrnjQCm+DroTTTxlzrrDTCxk96+zTPhlirq9T8W+DrrDTCxkvrnMU1m+D6+wU1xw0rk5T
0G+Drq9T8hkerm5T0G+DrkLTLRlRrpHTHBxir4vTMhwer+fQ+hwNr-bT3RxR6+wU1m+D6+wU
1xkBr+LQ-BlAroTTTxw56+wU1m+D6+wU1xxir4vTMhwe6+wU1m+D6+wU1m+D6+wU1xlAroTT
TxlzrrAU1xxAr2nTFxxzr5zTQxwvr1jTBhxir4sU1xxzr5zTQxwvr+jQ+xk4r+vQ-W+D6+wU
1xwCr4vTMhwer0fT6Rk-r+YU1m+D6+zT+xwqrqvQPhxWrmfQ8hwVrlbQ4G+D6+wU1m+D6+zT
-RwBrkLTJBxAr2nQ-0+D6+wU1m+D6+zQCxwqrqvQPW+D6+wU1m+D6+wU1m+D6+zTJBxAr2nT
Fxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5rrzQTxw1rkjT+xw4rksU1m+D6+wU
1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-z8+2-+2+30+D6+wU1m+D6+wU1xxWrmfQ8hwV6+zTMhwe
r+cU1m+D6+zQ+RxRr3rTJBxA6+wU1m+D6+wU1xxnrnjQCxwqr+PQ1hk4r+9Q0hk0r+2U1xxR
r3rTJBxAr2kU1xwJrprQLRxI6+wU1xw5rrzQTxxnrngU1xxIronQHBx56+wU1m+D6+zQ0xk1
r+MU1xxnrnjQCxwqr+MU1xk4rmfQ8hwVrlYU1m+D6+wU1m+D6+zT1hlirq9T0W+D6+zT-hxW
rmfQ8hwVrlbQ4RwJrkoU1m+D6+wU1m+D6+wU1xw5rrDTCxkvrnPTPhlirq9T8hw06+wU1xw3
rprT-G+D6+zT0RkNrlLT1G+D6+wU1xw2roTTTxw56+zT1RlRrpHTHBlAroTTTxlzrrDTCxw1
6+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+Dr+9Q+G+D6+wU1xkBrpHTHBkA6+wU1xk3ronQHBx5
rrzQTxxnrnjQ0m+D6+wU1m+D6+wU1xk8rm5T4Rk76+wU1m+D6+wU1m+D6+wU1m+Dr+DQCxk1
6+wU1xkDrrDTCxk96+wU1m+Dr+PT8hker+6U1xk9rnPTPhlirq9T8hkerm5T4RkNr+2U1m+D
r+9T4RkNrlLTLRlRrpHTHBkA6+zTMhwer0fT6G+D6+zT3RxRr3rTJ0+DrlLTLRw36+wU1m+D
rkTTTxlzrrDTCm+D6+wU1m+D6+zTMhwer0fT6G+D6+wU1m+D6+wU1m+D6+zTTxlzrrDTCxkv
6+zTFxxzr5zTQxwvr+gU1xxir4vTMhwe6+zTQxwvr1jTBW+D6+wU1m+Drk9T+Rw76+zTMhwe
r0fT6Rw76+zT-RxRr3rTJBxArqvQPhxWrmfQ0hk0rlbQ4RwJrpoU1m+D6+wU1m+Dr+rQ-Rk2
r2nTFxxzrkQU1m+D6+wU1m+DrqvQPhxWrmcU1m+D6+wU1m+D6+wU1m+Dr2nTFxxzr5zTQm+D
ronQHBx5rrzQTxxnrnjQCxwqrqvQPW+DrrzQTxxnrnjQ0xk1r+PQ1hk46+wU1m+DrkvQPhxW
rmfQ8hwVr+5Q0G+D6+wU1xw1rnPTPhlirq9T8hkerm5T4RkN6+wU1m+D6+wU1xw3rkrT-RxI
ronQHBk26+wU1m+D6+wU1xkvrnPTPhli6+xbcCE0+E+M6+wU1m+D6+wU1m+D6+zTJBxAr2nT
Fxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5rrzQTxw1rkjT+xw4rksU1m+D6+wU
1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-6+wU1m+D6+wU1m+Drq9T8hkerm2U1xxWrmfQ0W+D6+wU
1xk-rprQLRxIrokU1m+D6+wU1m+DrrDTCxkvrnPQ-hkCr+PQ+hk8r+9Q+G+DrprQLRxIronQ
H0+DrlLTLRlRrpEU1m+DrkTTTxlzrrDTCm+DrpHTHBlAroQU1m+D6+wU1xk9r+DQ-W+DrrDT
CxkvrnPQ-W+Dr+PT8hkerm5T4G+D6+wU1m+D6+wU1xwCr4vTMhw86+wU1xw4rq9T8hkerm5T
4RkNrlLT1G+D6+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxir4vTMhwerk6U1m+DrkLTLRw36+wU
1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxAr2nTFxxzr5zTQxwvrkAU1m+DrkTT
Qxwvr1jTBhxir4vTMhw86+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+zQ+hk-6+wU1m+Dr+rTJBxAr+kU1m+Dr+LTHBlAroTTTxlzrrDT
Cxk96+wU1m+D6+wU1m+Dr+fT6RwNr+YU1m+D6+wU1m+D6+wU1m+D6+zQ+xkvr+AU1m+Dr+zT
Qxwvr+gU1m+D6+zQ-hwer0fQ+W+Dr+jTBhxir4vTMhwer0fT6RwNr-bQ+G+D6+zQ+hwNr-bT
3RxRr3rTJBxAr+kU1se8+U++R+++
***** END OF BLOCK 2 *****

{------------------------------- }


*XX3402-008112-040296--72--85-07094----LINES_50.OBJ--1-OF--2
U+E++Xcu-dM6+++2Eox2FE-1a+Q+82+T+U2-pd+I+++-1IF-J23TBH-TH2ZCFJA+++0Kc+E2
+E++r+HTTxlzrrDTCxkvrnPTPhlirq9Q+W+D6+zQ0xwqrqvQPhxWrmfQ0W+D6+wU1m+D6+wU
1m+Dr+fT6RwNr+YU1m+D6+wU1m+D6+wU1m+D6+zQ+xkvr+AU1m+Dr+zTQxwvr+gU1m+D6+zQ
-hwer0fQ+W+Dr+jTBhxir4vTMhwer0fT6RwNr-bQ+G+D6+zQ+hwNr-bT3RxRr3rTJBxAr+kU
1xxAr2nTFxxzrkTT+xw9rkDT-hwCrkMU1xlzrrDTCxkvrkPT1hlirq9T8W+D6+wU1m+D6+wU
1xxWrmfQ8hwV6+wU1m+D6+wU1m+D6+wU1xxzr5zTQxwvr1gU1xx5rrzQTxxnrnjQ0m+DrqvQ
PhxWrmcU1xxnrnjQCxwq6+wU1m+D6+zT+hw-rkYU1xxWrmfQ8hwVrkYU1xw3rprQLRxIronQ
LRxIronQHBx5rrzQTxxnrnjQ0m+D6+zTFxxzr5wU1xk1r1jTBhxir4sU1m+D6+wU1m+D6+zT
Phlirq9T8W+D6+wU1m+D6+wU1m+D6+zQHBx5rrzQTxxn6+zTHBlAroTTTxlzrrDTCxkvrnPT
Phli6+zTTxlzrrDTCxk9r+DQ-hkCr+MU1m+D6+zT1hlirq9T8hkerm5Q+Rk76+wU1m+D6+zT
1Rw3rkHT1Bw2rkTTTxlzrrDTCm+DronQHBx5rrzT-m+DrnjQCxwq6+wU1m+D6+wU1m+Dr1jT
Bhxir4sU1m+D6+wU1m+D6+wU1m+DrpHTHBlAroTTTm+Dr3rTJBxAr2nT-xxzr5zTQxwvr1jT
BW+Dr2nTFxxzr5zT+xw9rkDT-hwC6+wU1m+D6+wU1m+DrkPT+hwer0fT6RwNr-bQ+Rk-r+bQ
+Rk3r+rQ-Rk2r2nTFxxzr5wU1xlRrpHTHBkAr+HTTxlzrrDTCm+D6+wU1m+D6+wU1xxnrnjQ
Cxwqr+PQ1hk4r+9Q0hk0r+2U1xxRr3rTJBxAr2kU1xwJrprQLRxI6+wU1xw5rrzQTxxnrngU
1xxIronQHBx56+wU1m+D6+zQ0xk1r+MU1xxnrnjQCxwqr+MU1xk4rmfQ8hwVrlbT+hwVrlbQ
4RwJrprQLRxIronT-0+D6+wU1xwBr3rTJBxAr2nTFxwD6+wU1m+D6+wU1m+D6+wU1xw5rrDT
CxkvrnPTPhlirq9T8hw06+wU1xw3rprT-G+D6+zT0RkNrlLT1G+D6+wU1xw2roTTTxw56+zT
1RlRrpHTHBlAroTTTxlzrrDTCxw16+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1lCU-+E-++EU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+zQ-Bxz
r5zTQxwvr1jTBhxir4vTMhk06+wU1xk9rnPTPhlirq9T8hk86+wU1m+D6+wU1m+D6+zQ0hwV
rlbQ0G+D6+wU1m+D6+wU1m+D6+wU1xk1r1jQ+m+D6+zQ1xxnrnjQ0m+D6+wU1xk4rmfQ8hk0
6+zQ0xwqrqvQPhxWrmfQ8hwVrlbQ4Rk-6+wU1xk0rlbQ4RwJrprQLRxIronQ10+DronQHBx5
rrzT-xw1rkjT+xw4rkvT-W+Dr5zTQxwvr1jT-hwCr4vTMhwe6+wU1m+D6+wU1m+Drq9T8hke
rm2U1m+D6+wU1m+D6+wU1m+DrrzQTxxnrnjQCm+DroTTTxlzrrDTCxk96+zTPhlirq9T8W+D
rrDTCxkvrnMU1m+D6+wU1xw0rk5T0G+Drq9T8hkerm5T0G+DrkLTLRlRrpHTHBlRrpHTHBlA
roTTTxlzrrDTCxk96+wU1xx5rrzQTm+Dr+DQCxwqrqvQPW+D6+wU1m+D6+wU1xxir4vTMhwe
6+wU1m+D6+wU1m+D6+wU1xlAroTTTxlzrrAU1xxAr2nTFxxzr5zTQxwvr1jTBhxir4sU1xxz
r5zTQxwvr+jQ+xk4r+vQ-W+D6+wU1xwCr4vTMhwer0fT6Rk-r+YU1m+D6+wU1xwBrkLT-BwA
rkHT-xxzr5zTQxwv6+zTHBlAroTTTxw56+zTCxkvrnMU1m+D6+wU1m+D6+zQCxwqrqvQPW+D
6+wU1m+D6+wU1m+D6+zTJBxAr2nTFxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5
rrzQTxw1rkjT+xw4rksU1m+D6+wU1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-r+5Q0Rk-r+LQ1Rk3
r+HQHBx5rrzQTm+Dr3rTJBxAr+nQ-Bxzr5zTQxwv6+wU1m+D6+wU1m+DrrDTCxkvrnPQ-hkC
r+PQ+hk8r+9Q+G+DrprQLRxIronQH0+DrlLTLRlRrpEU1m+DrkTTTxlzrrDTCm+DrpHTHBlA
roQU1m+D6+wU1xk9r+DQ-W+DrrDTCxkvrnPQ-W+Dr+PT8hkerm5T4Rw0rm5T4RkNrlLTLRlR
rpHTHBw26+wU1m+DrkrQLRxIronQHBx5rkwU1m+D6+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxi
r4vTMhwerk6U1m+DrkLTLRw36+wU1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxA
r2nTFxxzZ8+2-+2+0BlzrrDTCxw16+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1xk2rrzQTxxnrnjQ
CxwqrqvQPhxWr+6U1m+Dr+jTBhxir4vTMhwer+cU1m+D6+wU1m+D6+wU1xk8rm5T4Rk76+wU
1m+D6+wU1m+D6+wU1m+Dr+DQCxk16+wU1xkDrrDTCxk96+wU1m+Dr+PT8hker+6U1xk9rnPT
Phlirq9T8hkerm5T4RkNr+2U1m+Dr+9T4RkNrlLTLRlRrpHTHBkA6+zTHBlAroTTTxw5rkDT
0xw1rkPT1hw46+zQTxxnrnjQCxw4rkvQPhxWrmcU1m+D6+wU1m+D6+zTMhwer0fT6G+D6+wU
1m+D6+wU1m+D6+zTTxlzrrDTCxkv6+zTFxxzr5zTQxwvr+gU1xxir4vTMhwe6+zTQxwvr1jT
BW+D6+wU1m+Drk9T+Rw76+zTMhwer0fT6Rw76+zT-RxRr3rTJBxAr3rTJBxAr2nTFxxzr5zT
Qxwvr+gU1m+DroTTTxlz6+zQ+xkvrnPTPhli6+wU1m+D6+wU1m+DrqvQPhxWrmcU1m+D6+wU
1m+D6+wU1m+Dr2nTFxxzr5zTQm+DronQHBx5rrzQTxxnrnjQCxwqrqvQPW+DrrzQTxxnrnjQ
0xk1r+PQ1hk46+wU1m+DrkvQPhxWrmfQ8hwVr+5Q0G+D6+wU1m+DrkrT-Rw2rknT-Bw5rrzQ
TxxnrngU1xxAr2nTFxxzrkQU1xwvr1jTBW+D6+wU1m+D6+wU1xkvrnPTPhli6+wU1m+D6+wU
1m+D6+wU1xxIronQHBx5rrwU1xlRrpHTHBlArkTTTxlzrrDTCxkvrnMU1xlAroTTTxlzrkDT
0xw1rkPT1W+D6+wU1m+D6+wU1xw4rk9T8hkerm5T4RkNr+5Q+Rk7r+5Q-RkBr+LQ-BlAroTT
Txlz6+zQLRxIronQ1Bk2rrzQTxxnrngU1m+D6+wU1m+D6+zTQxwvr1jTBhk4r+vQ-hk0r+fQ
+hk-6+zTLRlRrpHTHBlA6+zT3RxRr3rTJ0+D6+zT-xxzr5zTQxwv6+zTJBxAr2nTFm+D6+wU
1m+Dr+jQ+xk46+zTQxwvr1jTBhk46+zQ-hwer0fT6RwNrk9T6RwNr-bT3RxRr3rTJBxArkEU
1m+D6+zT1RlRrpEDc+E2+E+AronQHBx5rkwU1m+D6+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxi
r4vTMhwerk6U1m+DrkLTLRw36+wU1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxA
r2nTFxxzr5zTQxwvrkAU1m+DrkTTQxwvr1jTBhxir4vTMhw86+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+Dr+HTTxlzrrDTCxkvrnPTPhli
rq9Q+W+D6+zQ0xwqrqvQPhxWrmfQ0W+D6+wU1m+D6+wU1m+Dr+fT6RwNr+YU1m+D6+wU1m+D
6+wU1m+D6+zQ+xkvr+AU1m+Dr+zTQxwvr+gU1m+D6+zQ-hwer0fQ+W+Dr+jTBhxir4vTMhwe
r0fT6RwNr-bQ+G+D6+zQ+hwNr-bT3RxRr3rTJBxAr+kU1xxAr2nTFxxzrkTT+xw9rkDT-hwC
rkMU1xlzrrDTCxkvrkPT1hlirq9T8W+D6+wU1m+D6+wU1xxWrmfQ8hwV6+wU1m+D6+wU1m+D
6+wU1xxzr5zTQxwvr1gU1xx5rrzQTxxnrnjQ0m+DrqvQPhxWrmcU1xxnrnjQCxwq6+wU1m+D
6+zT+hw-rkYU1xxWrmfQ8hwVrkYU1xw3rprQLRxIronQLRxIronQHBx5rrzQTxxnrnjQ0m+D
6+zTFxxzr5wU1xk1r1jTBhxir4sU1m+D6+wU1m+D6+zTPhlirq9T8W+D6+wU1m+D6+wU1m+D
6+zQHBx5rrzQTxxn6+zTHBlAroTTTxlzrrDTCxkvrnPTPhli6+zTTxlzrrDTCxk9r+DQ-hkC
r+MU1m+D6+zT1hlirq9T8hkerm5Q+Rk76+wU1m+D6+zT1Rw3rkHT1Bw2rkTTTxlzrrDTCm+D
ronQHBx5rrzT-m+DrnjQCxwq6+wU1m+D6+wU1m+Dr1jTBhxir4sU1m+D6+wU1m+D6+wU1m+D
rpHTHBlAroTTTm+Dr3rTJBxAr2nT-xxzr5zTQxwvr1jTBW+Dr2nTFxxzr5zT+xw9rkDT-hwC
6+wU1m+D6+wU1m+DrkPT+hwer0fT6RwNr-bQ+Rk-r+bQ+Rk3r+rQ-Rk2r2nTFxxzr5wU1xlR
rpHTHBkAr+HTTxlzrrDTCm+D6+wU1m+D6+wU1xxnrnjQCxwqr+PQ1hk4r+9Q0hk0r+2U1xxR
r3rTJBxAr2kU1xwJrprQLH0U-+E-+-1TJ0+D6+zT-xxzr5zTQxwv6+zTJBxAr2nTFm+D6+wU
1m+Dr+jQ+xk46+zTQxwvr1jTBhk46+zQ-hwer0fT6RwNrk9T6RwNr-bT3RxRr3rTJBxArkEU
1m+D6+zT1RlRrpHTHBlAroTT1m+D6+wU1m+D6+wU1m+D6+zT-xxnrnjQCxwqrqvQPhxWrmfT
+W+D6+zT-RxRrkIU1m+DrkbQ4RwJrkoU1m+D6+zT-Bx5rrzT-m+DrkrQLRxIronQHBx5rrzQ
TxxnrnjT+m+D6+zT-xxnrnjQCxwqrqvQPhxWrkcU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
***** END OF BLOCK 1 *****



*XX3402-008112-040296--72--85-38139----LINES_50.OBJ--2-OF--2
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+zQ-Bxzr5zTQxwvr1jTBhxir4vTMhk06+wU
1xk9rnPTPhlirq9T8hk86+wU1m+D6+wU1m+D6+zQ0hwVrlbQ0G+D6+wU1m+D6+wU1m+D6+wU
1xk1r1jQ+m+D6+zQ1xxnrnjQ0m+D6+wU1xk4rmfQ8hk06+zQ0xwqrqvQPhxWrmfQ8hwVrlbQ
4Rk-6+wU1xk0rlbQ4RwJrprQLRxIronQ10+DronQHBx5rrzT-xw1rkjT+xw4rkvT-W+Dr5zT
Qxwvr1jT-hwCr4vTMhwe6+wU1m+D6+wU1m+Drq9T8hkerm2U1m+D6+wU1m+D6+wU1m+DrrzQ
TxxnrnjQCm+DroTTTxlzrrDTCxk96+zTPhlirq9T8W+DrrDTCxkvrnMU1m+D6+wU1xw0rk5T
0G+Drq9T8hkerm5T0G+DrkLTLRlRrpHTHBlRrpHTHBlAroTTTxlzrrDTCxk96+wU1xx5rrzQ
Tm+Dr+DQCxwqrqvQPW+D6+wU1m+D6+wU1xxir4vTMhwe6+wU1m+D6+wU1m+D6+wU1xlAroTT
TxlzrrAU1xxAr2nTFxxzr5zTQxwvr1jTBhxir4sU1xxzr5zTQxwvr+jQ+xk4r+vQ-W+D6+wU
1xwCr4vTMhwer0fT6Rk-r+YU1m+D6+wU1xwBrkLT-BwArkHT-xxzr5zTQxwv6+zTHBlAroTT
Txw56+zTCxkvrnMU1m+D6+wU1m+D6+zQCxwqrqvQPW+D6+wU1m+D6+wU1m+D6+zTJBxAr2nT
Fxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5rrzQTxw1rkjT+xw4rksU1m+D6+wU
1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-i8+2-+2+3Bk-r+bQ+Rk3r+rQ-Rk2r2nTFxxzr5wU1xlR
rpHTHBkAr+HTTxlzrrDTCm+D6+wU1m+D6+wU1xxnrnjQCxwqr+PQ1hk4r+9Q0hk0r+2U1xxR
r3rTJBxAr2kU1xwJrprQLRxI6+wU1xw5rrzQTxxnrngU1xxIronQHBx56+wU1m+D6+zQ0xk1
r+MU1xxnrnjQCxwqr+MU1xk4rmfQ8hwVrlbT+hwVrlbQ4RwJrprQLRxIronT-0+D6+wU1xwB
r3rTJBxAr2nTFxwD6+wU1m+D6+wU1m+D6+wU1xw5rrDTCxkvrnPTPhlirq9T8hw06+wU1xw3
rprT-G+D6+zT0RkNrlLT1G+D6+wU1xw2roTTTxw56+zT1RlRrpHTHBlAroTTTxlzrrDTCxw1
6+wU1xw5rrDTCxkvrnPTPhlirq9T0W+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1xk2rrzQTxxnrnjQCxwqrqvQPhxWr+6U1m+Dr+jTBhxi
r4vTMhwer+cU1m+D6+wU1m+D6+wU1xk8rm5T4Rk76+wU1m+D6+wU1m+D6+wU1m+Dr+DQCxk1
6+wU1xkDrrDTCxk96+wU1m+Dr+PT8hker+6U1xk9rnPTPhlirq9T8hkerm5T4RkNr+2U1m+D
r+9T4RkNrlLTLRlRrpHTHBkA6+zTHBlAroTTTxw5rkDT0xw1rkPT1hw46+zQTxxnrnjQCxw4
rkvQPhxWrmcU1m+D6+wU1m+D6+zTMhwer0fT6G+D6+wU1m+D6+wU1m+D6+zTTxlzrrDTCxkv
6+zTFxxzr5zTQxwvr+gU1xxir4vTMhwe6+zTQxwvr1jTBW+D6+wU1m+Drk9T+Rw76+zTMhwe
r0fT6Rw76+zT-RxRr3rTJBxAr3rTJBxAr2nTFxxzr5zTQxwvr+gU1m+DroTTTxlz6+zQ+xkv
rnPTPhli6+wU1m+D6+wU1m+DrqvQPhxWrmcU1m+D6+wU1m+D6+wU1m+Dr2nTFxxzr5zTQm+D
ronQHBx5rrzQTxxnrnjQCxwqrqvQPW+DrrzQTxxnrnjQ0xk1r+PQ1hk46+wU1m+DrkvQPhxW
rmfQ8hwVr+5Q0G+D6+wU1m+DrkrT-Rw2rknT-Bw5rrzQTxxnrngU1xxAr2nTFxxzrkQU1xwv
r1jTBW+D6+wU1m+D6+wU1xkvrnPTPhli6+wKc+E2+E+M6+wU1m+D6+wU1m+D6+zTJBxAr2nT
Fxxz6+zQLRxIronQHBw5rrzQTxxnrnjQCxwq6+zQHBx5rrzQTxw1rkjT+xw4rksU1m+D6+wU
1m+D6+zT-hw0rmfQ8hwVrlbQ4Rk-r+5Q0Rk-r+LQ1Rk3r+HQHBx5rrzQTm+Dr3rTJBxAr+nQ
-Bxzr5zTQxwv6+wU1m+D6+wU1m+DrrDTCxkvrnPQ-hkCr+PQ+hk8r+9Q+G+DrprQLRxIronQ
H0+DrlLTLRlRrpEU1m+DrkTTTxlzrrDTCm+DrpHTHBlAroQU1m+D6+wU1xk9r+DQ-W+DrrDT
CxkvrnPQ-W+Dr+PT8hkerm5T4Rw0rm5T4RkNrlLTLRlRrpHTHBw26+wU1m+DrkrQLRxIronQ
HBx5rkwU1m+D6+wU1m+D6+wU1m+DrkTTQxwvr1jTBhxir4vTMhwerk6U1m+DrkLTLRw36+wU
1xw7r-bT3RwB6+wU1m+DrkHTFxxzrkQU1xwBr3rTJBxAr2nTFxxzr5zTQxwvrkAU1m+DrkTT
Qxwvr1jTBhxir4vTMhw86+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU
1m+D6+wU1m+D6+wU1m+Dr+HTTxlzrrDTCxkvrnPTPhlirq9Q+W+D6+zQ0xwqrqvQPhxWrmfQ
0W+D6+wU1m+D6+wU1m+Dr+fT6RwNr+YU1m+D6+wU1m+D6+wU1m+D6+zQ+xkvr+AU1m+Dr+zT
Qxwvr+gU1m+D6+zQ-hwer0fQ+W+Dr+jTBhxir4vTMhwer0fT6RwNr-bQ+G+D6+zQ+hwNr-bT
3RxRr3rTJBxAr+kU1xxAr2nTFxxzrkTT+xw9rkDT-hwCrkMU1xlzrrDTCxkvrkPT1hlirq9T
8W+D6+wU1m+D6+wU1xxWrmfQ8hwV6+wU1m+D6+wU1m+D6+wU1xxzr5zTQxwvr1gU1xx5rrzQ
TxxnrnjQ0m+DrqvQPhxWrmcU1xxnrnjQCxwq6+wU1m+D6+zT+hw-rkYU1xxWrmfQ8hwVrkYU
1xw3rprQLRxIronQLRxIronQHBx5rrzQTxxnrnjQ0m+D6+zTFxxzr5wU1xk1r1jTBhxir4sU
1m+D6+wU1m+D6+zTPhlirq9T8W+D6+wU1m+D6+wU1m+D6+zQHBx5rrzQTxxn6+zTHBlAroTT
TxlzrrDTCxkvrnPTPhli6+zTTxlzrrDTCxk9r+DQ-c8UF+A-+-nQ1hk46+wU1m+DrkvQPhxW
rmfQ8hwVr+5Q0G+D6+wU1m+DrkrT-Rw2rknT-Bw5rrzQTxxnrngU1xxAr2nTFxxzrkQU1xwv
r1jTBW+D6+wU1m+D6+wU1xkvrnPTPhli6+wU1m+D6+wU1m+D6+wU1xxIronQHBx5rrwU1xlR
rpHTHBlArkTTTxlzrrDTCxkvrnMU1xlAroTTTxlzrkDT0xw1rkPT1W+D6+wU1m+D6+wU1xw4
rk9T8hkerm5T4RkNr+5Q+Rk7r+5Q-RkBr+LQ-BlAroTTTxlz6+zQLRxIronQ1Bk2rrzQTxxn
rngU1m+D6+wU1m+D6+zTQxwvr1jTBhk4r+vQ-hk0r+fQ+hk-6+zTLRlRrpHTHBlA6+zT3RxR
r3rTJ0+D6+zT-xxzr5zTQxwv6+zTJBxAr2nTFm+D6+wU1m+Dr+jQ+xk46+zTQxwvr1jTBhk4
6+zQ-hwer0fT6RwNrk9T6RwNr-bT3RxRr3rTJBxArkEU1m+D6+zT1RlRrpHTHBlAroTT1m+D
6+wU1m+D6+wU1m+D6+zT-xxnrnjQCxwqrqvQPhxWrmfT+W+D6+zT-RxRrkIU1m+DrkbQ4RwJ
rkoU1m+D6+zT-Bx5rrzT-m+DrkrQLRxIronQHBx5rrzQTxxnrnjT+m+D6+zT-xxnrnjQCxwq
rqvQPhxWrkcU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D6+wU1m+D
6+wU1m+D6+zQ-Bxzr5zTQxwvr1jTBhxir4vTMhk06+wU1xk9rnPTPhlirq9T8hk86+wU1m+D
6+wU1m+D6+zQ0hwVrlbQ0G+D6+wU1m+D6+wU1m+D6+wU1xk1r1jQ+m+D6+zQ1xxnrnjQ0m+D
6+wU1xk4rmfQ8hk06+zQ0xwqrqvQPhxWrmfQ8hwVrlbQ4Rk-6+wU1xk0rlbQ4RwJrprQLRxI
ronQ10+Dr6c0++-o
***** END OF BLOCK 2 *****


