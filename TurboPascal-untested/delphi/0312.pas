{
Delphi1 & Delphi2.

This unit is to replace QuickReport's Preview Form.

Advantages:
  1. cursor keys can be used to move around the preview page.
  2. [page_up] and [page_down] keys used to move between pages
  3. [home] or [ctrl][page_up] to move to first page
  4. [end] or [ctrl][page_down] to move to last page

  5. automatically fills entire screen (except task bar)


Usage:

  1. Make sure QuickRep is in the uses clause on your MainForm.
  2. Add this Preview unit to your project.
  3. Add the following procedure to your MainForm -
	procedure TMainForm.MyPreview;
	begin
	   FmPreview.ShowModal;
	end;
  4. add -
	QRPrinter.OnPreview := MyPreview;
     to your code (or place it in FormCreate method) before calling -
	YourReport.Quickreport1.preview;


Angus Johnson
ajohnson@rpi.net.au
}

unit Preview;  { dfm file is at end .. use XX34 to decode }

interface

uses
  SysUtils, Classes, Controls, Forms, Quickrep, ExtCtrls, Messages,
  StdCtrls, Buttons, WinTypes, WinProcs, Dialogs, Printers,
  IniFiles;

type
  TFmPreview = class(TForm)
	 Panel1: TPanel;
	 QRPreview1: TQRPreview;
	 Label1: TLabel;
	 PrintDialog1: TPrintDialog;
	 bbPrev: TBitBtn;
	 bbNext: TBitBtn;
	 bbZoomOut: TBitBtn;
	 bbZoomW: TBitBtn;
	 bbZoomIn: TBitBtn;
	 bbPrint: TBitBtn;
    bbClose: TBitBtn;
	 procedure FormShow(Sender: TObject);
	 procedure bbZoomOutClick(Sender: TObject);
	 procedure bbZoomWClick(Sender: TObject);
	 procedure bbPrevClick(Sender: TObject);
	 procedure bbNextClick(Sender: TObject);
	 procedure bbPrintClick(Sender: TObject);
	 procedure bbZoomInClick(Sender: TObject);
	 procedure bbCloseClick(Sender: TObject);
	 procedure FormActivate(Sender: TObject);
	 procedure FormClose(Sender: TObject; var Action: TCloseAction);
	 procedure FormKeyDown(Sender: TObject; var Key: Word;
	   Shift: TShiftState);
  private
	 procedure CMDialogKey(var message: TCMDialogKey); message CM_DIALOGKEY;
  public
  end;

var
  FmPreview: TFmPreview;

implementation

uses
  Main;

{$R *.DFM}


procedure TFmPreview.FormShow(Sender: TObject);
begin
	QRPreview1.Zoom := 100; {defaults to ZoomIn}
	Label1.caption := 'Page 1 of ' +inttostr(QRPrinter.PageCount);
	if QRPrinter.PageCount = 1 then bbNext.enabled := false
	else bbNext.enabled := true;
	bbClose.setfocus;
	bbZoomIn.enabled := false;
	bbZoomW.enabled := true;
	bbZoomOut.enabled := true;
end;

procedure TFmPreview.bbZoomOutClick(Sender: TObject);
begin
	QRPreview1.ZoomToFit;
	bbZoomOut.enabled := false;
	bbZoomW.enabled := true;
	bbZoomIn.enabled := true;
	bbClose.setfocus;
end;

procedure TFmPreview.bbZoomWClick(Sender: TObject);
begin
	QRPreview1.ZoomToWidth;
	bbZoomW.enabled := false;
	bbZoomOut.enabled := true;
	bbZoomIn.enabled := true;
	bbClose.setfocus;
end;

procedure TFmPreview.bbPrevClick(Sender: TObject);
begin {Previous page}
  if QRPreview1.PageNumber > 1 then
         QRPreview1.PageNumber := QRPreview1.PageNumber-1;
  Label1.caption := 'Page ' + inttostr(QRPreview1.PageNumber)+
                        ' of ' +inttostr(QRPrinter.PageCount);
  bbNext.enabled := true;
  if QRPreview1.PageNumber = 1 then begin
	 bbPrev.enabled := false;
	 bbNext.setfocus;
  end;
end;

procedure TFmPreview.bbNextClick(Sender: TObject);
begin {Next page}
  if QRPreview1.PageNumber < QRPrinter.PageCount then
					QRPreview1.PageNumber := QRPreview1.PageNumber+1;
  Label1.caption := 'Page ' + inttostr(QRPreview1.PageNumber)+
					' of ' +inttostr(QRPrinter.PageCount);
  bbPrev.enabled := true;
  if QRPreview1.PageNumber = QRPrinter.PageCount then begin
	 bbNext.enabled := false;
	 bbPrev.setfocus;
  end;
end;

procedure TFmPreview.bbPrintClick(Sender: TObject);
begin
  {A PrintDialog component can be added to the form with an -
  if not PrintDialog1.execute then exit -
  statement placed here.}
  screen.cursor := crHourglass;
  try
	 QRPrinter.Print;
	 while tag > 1 do begin
	   QRPrinter.Print;
	   tag := tag-1;
	 end;
	 tag := 1;
  finally
	 screen.cursor := crDefault;
  end;
  close;
end;

procedure TFmPreview.bbZoomInClick(Sender: TObject);
begin
	QRPreview1.Zoom := 100;
	bbZoomIn.enabled := false;
	bbZoomW.enabled := true;
	bbZoomOut.enabled := true;
	bbClose.setfocus;
end;

procedure TFmPreview.bbCloseClick(Sender: TObject);
begin
	close;
end;

procedure TFmPreview.FormActivate(Sender: TObject);
var
  TrayHwnd: HWnd;
  Rect: TRect;
  CxFullScreen, CyFullScreen, CyCaption: integer;
begin
  {size the form to fill the screen...}
  TrayHwnd := FindWindow('Shell_TrayWnd','');
  if TrayHwnd = 0 then {not Win95 screen}
	 WindowState := wsMaximized
  else begin
	 GetWindowRect(TrayHwnd,Rect);
	 CxFullScreen    := GetSystemMetrics(SM_CXFULLSCREEN);
	 CyFullScreen    := GetSystemMetrics(SM_CYFULLSCREEN);
	 CyCaption       := GetSystemMetrics(SM_CYCAPTION);

	 {NOTE: Position must equal either poDefault or poDesigned,
	  and WindowState = wsNormal}
	 Top      := 0;
	 Left     := 0;
	 Width    := CxFullScreen;
	 Height   := CyFullScreen + CyCaption;

	 if (Rect.Top < 0) and (Rect.Left < 0) then begin
	   {Taskbar on either top or left}
	   if Rect.Right > Rect.Bottom then {Taskbar on top}
		 Top  := Rect.Bottom
	   else {Taskbar on left}
		 Left := Rect.Right;
	 end;
  end;
  bbClose.left := width - 76;
  bbPrint.left := width - 144;
end;

procedure TFmPreview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  QRPreview1.PageNumber := 1; {this is necessary if reopening form!!!?}
  bbPrev.enabled := false;
  QRPreview1.HorzScrollbar.Position := 0;
  QRPreview1.VertScrollbar.Position := 0;
end;

procedure TFmPreview.CMDialogKey(var message: TCMDialogKey);
begin {INTERCEPTS ARROW KEYS INORDER TO MOVE AROUND PAGE}
  with message do
	 case CharCode of
	   VK_LEFT: begin
		 with QRPreview1.HorzScrollbar do Position := Position -50;
		 exit;
		 end;
		VK_RIGHT: begin
		 with QRPreview1.HorzScrollbar do Position := Position +50;
		 exit;
		 end;
		VK_UP: begin
		 with QRPreview1.VertScrollbar do Position := Position -50;
		 exit;
		 end;
		VK_DOWN: begin
		 with QRPreview1.VertScrollbar do Position := Position +50;
		 exit;
		 end;
	 end;
  inherited;
end;

procedure TFmPreview.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin {INTERCEPTS [PG_UP],[PG_DN], [CTRL][PG_UP],[CTRL][PG_DN], [HOME],[END]}
  if (((Key = VK_NEXT) and (Shift = [ssCtrl])) or (Key = VK_END))
											and bbNext.enabled then begin
	 QRPreview1.PageNumber := QRPrinter.PageCount; {GOTO LAST PAGE}
	 Label1.caption := 'Page ' + inttostr(QRPrinter.PageCount)+
					  ' of ' +inttostr(QRPrinter.PageCount);
	 bbPrev.enabled := true;
	 bbNext.enabled := false;
	 bbPrev.setfocus;
	 end
  else if (((Key = VK_PRIOR) and (Shift = [ssCtrl])) or (Key = VK_HOME))
											 and bbPrev.enabled then begin
	 QRPreview1.PageNumber := 1; {GOTO FIRST PAGE}
	 Label1.caption := 'Page 1' +
					  ' of ' +inttostr(QRPrinter.PageCount);
	 bbPrev.enabled := false;
	 bbNext.enabled := true;
	 bbNext.setfocus;
	 end
  else if (Key = VK_NEXT) and bbNext.enabled then bbNextClick(Sender)
  else if (Key = VK_PRIOR) and bbPrev.enabled then bbPrevClick(Sender);
end;

end.
{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-001873-240597--72--85-09701-----PREVIEW.DFM--1-OF--1
zkc+J2NBI373JYZ3Jk+k21o5++-II2Mk0ZF4PJ-mNLNdNLQ7FapEQaJqOKJr-2lZNbE0++BI
Pr+0++h0Pr7YNL77MqxiQkgAMaZHSLBoNKpBNKtp++d-RLFjIqBmPqlg0+R1ML-oOKxi-UpE
QaZiR0-EQaJqOKJr12BgOKJiR2VZOKRcR+Cn+Eh1P4ZZPbFLOKFoO+Bs+Ud4Pqto9YBjP4xm
-klXP3RdPaFjRpFZS5E9FaxiR0t6NKZbO5E0x+Z4Pqto9YtVPKI4-I3mOK3g0YNjPbEiIrFt
P4I9++d9NLZEQaJqOKJr0EpEOLVZP5BENL77PaBc+a+6I4xnOLFdPqs51b-jIqBmNKJiEqJi
R4Jm-ZBXMKlZN+U8Hqt-MrFdRa3oNEQAFaxmPI3XR4ZqMLFZ-oxiEqljQqI50INjQap1P4xn
NEZDPYhZSIFjRqs50oNjQap9NLZ2PrRi-YxiIqVjRkQ6FaxmPJBcPrQ8J4JsR2VZOKRcR+6D
++NII43iNKk4I43iNKkl-2lZNbE0++BIPr+0++JLOKFoO+Bs+UN6NKZbO5E04UJ-P4ZbPUQ3
MKlIPr+6J43WHr7YNL60+++4J2lVMaJg-YlVMaJgAEFANKNo+sU++pFjQ+64-JRdN5Fc+b+4
G4JdNqVo+Uw7EKldNqthNKto-kVoMIBZPbFZQUV-RLFjIqZuNEU5Eq3kR4ZjPUM9I43bNG+l
64xa612+++RIEaZoEbFi-a7WI57ZRUFANKNo+U21J4xk+U63JqZYR4U0EUN6NKZbO5E03UR1
ML-oOKxi-UdEQaIaRW-EMKRZ-oJiMK7gNKE603FVMYxmN4Jm+U+5Hqt1P4ZXOkQ9Ma7EQaJq
EqldMqg+++RIEaZoEbFi-a7WHaJsR+FANKNo+YE1J4xk+U63JqZYR4U0EUN6NKZbO5E03UR1
ML-oOKxi-UcaHaJsR0-EMKRZ03FVMYxmN4Jm+U25Hqt1P4ZXOkQ9Ma7CNLVoEqldMqg+++RI
EaZoEbFi0K7WKaxjPIxpR+FANKNo+zc++pFjQ+60-JRdN5Fc+YQ4G4JdNqVo+VM5Eq3kR4Zj
PUM7KaxjPG+aHrJo03FVMYxmN4Jm+U65Hqt1P4ZXOkQCMa7OPqxhHrJoEqldMqg+++RIEaZo
EbFi-q7WKaxjPJQ2H4JaR+B0+EBIPr+0+UJLOKFoO+77-YVZOKRcR+6K-oBVQ5FdPqs40p-V
NqIU7ZRdN5Fc03FVMYxmN4Jm+UA5Hqt1P4ZXOkQAMa7OPqxhJoBgOKBf+++5J27dR27oPUVW
MZdjPqp7PUFANKNo+sk-+pFjQ+60-JRdN5Fc+YQ4G4JdNqVo+VM5Eq3kR4ZjPUM6KaxjPG+a
GKs5FKtVMalZN+U6J43WHr7YNL60-+RDPYBgOKBf-kpWMZdjPqp7PYBgOKBf+++5J27dR27o
PURWMZ-mOKto-2lZNbE1wE21J4xk+U63JqZYR4U0EUN6NKZbO5E03UR1ML-oOKxi-UNEQaZi
7bE6J43WHr7YNL60-ERDPYBgOKBf-klWMZ-mOKtoEqldMqg+++RIEaZoEbFi-q7WEqljQqI2
H4JaR+Ao+UBIPr+0+UJLOKFoO+70-YVZOKRcR+6K-YBVPaBZP+Y5Eq3kR4ZjPUM47YBgPrBZ
03FVMYxmN4Jm+UM5Hqt1P4ZXOkQAMa71P4xnNIBgOKBf0YRgSL-c9YFVR428M+2++3k-++-0
HJk-++++++++RU+++0U++++F++++2E++++2+-+++++++n+++++++++++++++++++++++++++
++++++0+++0+++++U6++U++++6++U+0+U+++kA1++60+U++++Dw++Dw+++1zzk1z++++zk1z
+Dzz++1zzzw+RrRrRrRrRrRk++++Xzzzzzzzzzzk++++VrRrRrRrRrTk++++VsW6RrRsW6Tk
++++VsaNVrS7aMTk++++VsaNa5WNaMTk++++VrWNaMaNa5Tk++++VrS7aNaNVrTk++++VrRs
aNaMRrTk++++VrS7aNaNVrTk++++VrWNaMaNa5Tk++++VsaNa5WNaMTk++++VsaNVrS7aMTk
++++VsW6RrRsW6Tk++++VrRrRrRrRrTk++++W6W6W6W6W6Xk++++RrRrRrRrRrRk++++++++
+++++++++++++++++++++++++++++++++++8J33GI57ZRaZZRkdFIZ-mNLNdNLQl-2lZNbE0
++BIPr+04UJLOKFoO+Bs+UN6NKZbO5E1aE23EKldNqs5043gEqldNKto0YNjPbEiEqxgPr65
14BgJqZiN4xrJ4JsR+h4Pqto9YVZOKRcR+9k0INjPbEiHa3hNEM3EL7dMKk8FaxiR0tHR5Zg
NEg+0Z-VQaJiR2NjPbE603FVMYxmN4Jm+U28I43bNItpPK7ZQU6--3djPqo0N+++13FEQaZi
R2FdMKljNklEQaZiR2FdMKljNn22H4JaR+B5+UBIPr+05U++++++
***** END OF BLOCK 1 *****

