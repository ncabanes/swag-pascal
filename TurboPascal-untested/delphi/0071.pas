
Following on from " "Sean Gates" <sgates@goofy.iafrica.com>", place the
following at the start of your name.dpr:

begin
  if HPrevInst <> 0 then begin
    ActivatePreviousInstance;
    Exit;
  end;
  .
  .
  .

and include the following unit:

-------------- cut here -------------------- }
unit PrevInst;

interface

uses WinProcs, WinTypes, SysUtils;

type
  PHWnd = ^HWnd;

function EnumFunc(Wnd : HWnd; TargetWindow : PHWnd): Bool; export;
procedure ActivatePreviousInstance;

implementation

function EnumFunc(Wnd : HWnd; TargetWindow : PHWnd): Bool;
var
  ClassName : array [0..30] of char;
begin
  Result := True;
  if GetWindowWord(Wnd,GWW_HINSTANCE) = HPrevInst then begin
    GetClassName(Wnd,ClassName,30);
    if StrIComp(ClassName,'TApplication') = 0 then begin
      TargetWindow^ := Wnd;
      Result := False;
    end;
  end;
end;

procedure ActivatePreviousInstance;
var
  PrevInstWnd : HWnd;
begin
  PrevInstWnd := 0;
  EnumWindows(@EnumFunc,Longint(@PrevInstWnd));
  if PrevInstWnd <> 0 then
    if IsIconic(PrevInstWnd) then
      ShowWindow(PrevInstWnd,SW_RESTORE)
    else
      BringWindowToTop(PrevInstWnd);
end;

end.
