(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0074.PAS
  Description: Windows Printing
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:56
*)


{$X+}
(*
    This program will print strings to the printer
    via the Print Manager if it is enabled.
*)

Program HardCopy_Printing;

uses WinTypes, WinProcs, Strings;

const
  BigButton = 100;
  Message1 = 'Now Printing from Windows!'+#0;
  Message2 = 'With the WIN.INI printer device settings.'+#0;

var
  S: string;
  Wnd, PrintButton: Word;
  DC, PrinterDC: HDC;
  PStr : pChar;
  Temp, PrintType, PrintDrv, PrintPort: pChar;
  PrintInfo: Array[1..80] of Char;

function WindowSetUp(Wnd: hWnd; iMessage, wParam: word; lParam: LongInt): LongInt;
export;
begin
  PStr:= 'Test';
  case iMessage of
    WM_Command: begin
                  case wParam of
                     BigButton: Begin
                                  messagebeep(0);
                                  DC:=GetDC(Wnd);
                                  GetProfileString('windows','device',#0,@PrintInfo,80);
                                  Temp := StrScan(@PrintInfo,',');
                                  PrintType := @PrintInfo;
                                  PrintDrv := Temp + 1;
                                  Temp[0]:= #0;
                                  PrintPort := StrScan(PrintDrv,',');
                                  PrintPort[0] := #0;
                                  Inc(PrintPort);
                                  PrinterDC := CreateDC(PrintDrv, PrintType, PrintPort, nil);
                                  Escape(PrinterDC, STARTDOC, 4, @PStr, nil);
                                  TextOut(PrinterDC, 1,1, Message1, Length(Message1)-1);
                                  TextOut(PrinterDC, 1,20, Message2, Length(Message2)-1);
                                  TextOut(DC, 1,1, Message1, Length(Message1)-1);
                                  TextOut(DC, 1,20, Message2, Length(Message2)-1);
                                  Escape(PrinterDC, NewFrame,0,nil,nil);
                                  Escape(PrinterDC, ENDDOC,0,nil,nil);
                                  DeleteDC(PrinterDC);
                                  ReleaseDC(Wnd, DC);
                                end;
                  end;
                end;

    WM_Destroy: PostQuitMessage(0);
  else
    WindowSetUp:= DefWindowProc(Wnd, iMessage,wParam, lParam);
  end;
end;

Procedure WinMain;
var
  WndClas: TWndClass;
  w: word;
  Msg: tMsg;
begin
  if hPrevInst = 0 then
    begin
      WndClas.Style := CS_HReDraw or CS_VReDraw;
      WndClas.lpfnWndProc:= @WindowSetUp;
      WndClas.cbClsExtra:= 0;
      WndClas.cbWndExtra:= 0;
      WndClas.hInstance:= hInstance;
      WndClas.hIcon:= 0;
      WndClas.hCursor:= 1;
      WndClas.hbrBackground:= GetStockObject(White_Brush);
      WndClas.lpszMenuName:= '';
      WndClas.lpszClassName:= 'AWindowClass';
      if not RegisterClass(WndClas) then
	halt;
    end;
    Wnd:= CreateWindow('AWindowClass','Printing Text to Printer',
		       WS_OverLapped or WS_SysMenu or WS_MinimizeBox,
		       10,10,400,400,
		       0,0,hInstance, nil);
    PrintButton:= CreateWIndow('Button','Print',
                              WS_Child or WS_Visible or BS_DefPushButton,
                              20,200,160,100,
                              Wnd,BigButton,hInstance, nil);
    ShowWindow(Wnd, SW_ShowNormal);
    UpDateWindow(Wnd);
    while GetMessage(Msg,0,0,0) do
      begin
	TranslateMessage(Msg);
	DispatchMessage(Msg);
      end;
end;

begin              { ********** Main ********** }
  WinMain;
end.


