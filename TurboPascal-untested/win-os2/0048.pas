{
From: bobs@dragons.nest.nl (Bob Swart)

{ here is a very small screensaver. It compiles to less than 3Kbytes: }
{$A+,B-,D-,F+,G+,I-,K-,L-,N-,P-,Q-,R-,S+,T-,V-,W+,X+,Y-}
{$M 8192,0,8192}
program ScrnSave;
{$D SCRNSAVE: Bob Swart}
uses WinTypes,
     WinProcs;

  function MyYield: Boolean;
  var msg: TMsg;
  begin
    while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
    begin
      if msg.message = WM_QUIT then
      begin
        PostQuitMessage(msg.wParam);
        MyYield := TRUE;
        EXIT
      end
      else
      begin
        TranslateMessage(msg);
        DispatchMessage(msg)
      end
    end;
    MyYield := FALSE
  end {MyYield};


function DefSaverProc(hwnd: HWND; msg,wp: Word; lp: LongInt): LongInt; export;
Const SC_SCREENSAVE = $F140;
begin
  DefSaverProc := 0;
  case msg of
      WM_CREATE: ShowCursor(FALSE);
     WM_DESTROY: begin
                   ShowCursor(TRUE);
                   PostQuitMessage(0);
                 end;
  WM_SYSCOMMAND: if wp <> SC_SCREENSAVE then { screen saver starten }
                   PostMessage(hwnd, WM_CLOSE, 0, 0);
 WM_ACTIVATEAPP: if wp = 0 then PostMessage(hwnd, WM_CLOSE, 0, 0);
     WM_KEYDOWN,
  WM_SYSKEYDOWN,
{  WM_MOUSEMOVE, => I don't like my screensaver to stop on a mousemove }
 WM_LBUTTONDOWN,
 WM_MBUTTONDOWN,
 WM_RBUTTONDOWN: PostMessage(hwnd, WM_CLOSE, 0, 0);
    else
      DefSaverProc := DefWindowProc(hwnd, msg, wp, lp)
  end {case}
end {DefSaverProc};


function WndProc(hwnd: HWND; msg, wp: Word; lp: LongInt): LongInt; export;
var ps: TPaintStruct;
    X,Y: Integer;
    R,G,B: Byte;
    Dc: HDC;
begin
  WndProc := 0;
  case msg of
    WM_PAINT:
      begin
        beginPaint(hwnd, ps);
        endPaint(hwnd, ps);

        Dc := GetDC(hwnd);
        SetBkMode(Dc,TRANSPARENT);
        X := GetSystemMetrics(SM_CXSCREEN);
        Y := GetSystemMetrics(SM_CYSCREEN);
        while NOT MyYield do
        begin
          R := Random($FF);
          G := Random($FF);
          B := Random($FF);
          SetTextColor(Dc,RGB(R,G,B));
          TextOut(Dc,Random(X),Random(Y),'Bob Swart',9);
        end;
        releasedc(Dc, hwnd)
      end;
  else
    WndProc := CallWindowProc(@DefSaverProc, hwnd, msg, wp, lp)
  end
end {WndProc};


function BlackBox(WndProc: TFARPROC): Integer;
var msg: TMsg;
Const wc: TWndClass=();
begin
  wc.style         := CS_OWNDC;
  wc.lpfnWndProc   := WndProc;
  wc.hInstance     := hInstance;
  wc.hbrBackground := GetStockObject(BLACK_BRUSH);
  wc.lpszClassName := 'BlackBox';
  RegisterClass(wc);

  CreateWindow('BlackBox', nil, WS_POPUP+WS_MAXIMIZE+WS_VISIBLE,
        0, 0, 0, 0, 0, 0, hInstance, nil);

  while GetMessage(msg, 0, 0, 0) do DispatchMessage(msg);
  BlackBox := msg.wParam
end {BlackBox};

function Configure: Integer;
begin
  Configure :=
    MessageBox(HWnd(0),
              'Borland Pascal Performance Optimiziation screen saver demo',
              'DOS/Win Special 94/4',
               mb_OK OR mb_IconInformation)
end {Configure};


begin
  if hPrevInst <> 0 then Halt(1);
  Randomize;
  while ord(CmdLine[0]) <> 0 do
  begin
    if (CmdLine[0] = '-') OR (CmdLine[0] = '/') then
    begin
      Inc(CmdLine);
      case CmdLine[0] of
        's', 'S': blackbox(@WndProc) { activate };
        'c', 'C': configure
      end
    end;
    Inc(CmdLine)
  end
end.
