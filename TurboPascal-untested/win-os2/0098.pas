PROGRAM Bmptblt;
{ Dieser Code beschreibt die Darstellung von Bitmaps mit "durchsichtigen" Bereichen
  (c) 1997 U. Conrad, uconrad1@gwdg.de }

{$R BMPTBLT.RES}  { see end of document .. XX34 to extract RES file}

USES OWindows,WinTypes,WinProcs,Strings;

TYPE TDemoApp=OBJECT(TApplication)
       PROCEDURE InitMainWindow; virtual;
     END;

TYPE PDemoWin = ^TDemoWin;
     TDemoWin = OBJECT(TWindow)
       PROCEDURE Paint(PaintDC : HDC;var PaintInfo : TPaintStruct); virtual;
       PROCEDURE GetWindowClass(var AWndClass : TWndClass); virtual;
     END;

{ Prozedur fuer die normale Abbildung von Bitmpas }
PROCEDURE BmpBlt(DC : HDC;x,y : integer;hbmp : HBitmap);
VAR MemDC        : HDC;
    OldBmp       : HBitmap;
    Bitmap       : TBitmap;
BEGIN
  MemDC:=CreateCompatibleDC(DC);
  OldBmp:=SelectObject(MemDC,hbmp);
  GetObject(hBmp,Sizeof(Bitmap),@Bitmap);
  BitBlt(DC,10,10,Bitmap.bmWidth,Bitmap.bmHeight,MemDC,0,0,SrcCopy);
  SelectObject(MemDC,OldBmp);
  DeleteDC(MemDC);
END;

{ Prozedur fuer die durchsichtige Darstellung }
PROCEDURE BmpTransparentBlt(hDCDest : HDC;x,y : integer;hbmp : HBitmap;rgbTransparent : TColorRef);
{ hDCDest bezeichnet den Zielkontext, x und y die obere linke Ecke der Bitmap;
  hBmp ist ein Handle zu der Bitmap und rgbTransparent bezeichnet die Farbe,
  die bei der Darstellung "durchsichtig" dargestellt werden soll }
VAR hDCSrc            : HDC;
    hDCMask           : HDC;
    Bitmap            : TBitmap;
    hbmTransMask      : HBitmap;
    OldBk             : TColorRef;
    OldCol            : TColorRef;
BEGIN
  GetObject(hBmp,SizeOf(TBitmap),@Bitmap);           { Informationen ueber Bitmap speichern }
  hDCSrc:=CreateCompatibleDC(hDCDest);               { Quellkontext erzeugen }
  hDCMask:=CreateCompatibleDC(hDCDest);              { Kontext fuer MAske erzeugen }
  hbmTransMask:=CreateBitmap(Bitmap.bmWidth,Bitmap.bmHeight,1,1,nil);
  SelectObject(hDCSrc,hbmp);                         { Bitmap im Quellkontext abbilden }
  SelectObject(hDCMask,hbmTransMask);                { }
  SetBkColor(hDCSrc,rgbTransparent);                 { Maske erzeugen }
  BitBlt(hdcMask,0,0,Bitmap.bmWidth,Bitmap.bmHeight,hDCSrc,0,0,SrcCopy);
  { mit Maske kombinieren }
  OldBk:=SetBkColor(hDCDest,RGB(255,255,255));
  OldCol:=SetTextColor(hDCDest,RGB(0,0,0));
  BitBlt(hDCDest,x,y,Bitmap.bmWidth,Bitmap.bmHeight,hDCSrc,0,0,SRCInvert);
  BitBlt(hDCDest,x,y,Bitmap.bmWidth,Bitmap.bmHeight,hDCMask,0,0,SRCAnd);
  BitBlt(hDCDest,x,y,Bitmap.bmWidth,Bitmap.bmHeight,hDCSrc,0,0,SRCInvert);
  SetBkColor(hDCDest,OldBk);
  SetTextColor(hDCDest,OldCol);
  { Kontexte freigeben }
  DeleteDC(hDCSrc);
  DeleteDC(hDCMask);
  DeleteDC(hDCDest);
  { Objekte loeschen }
  DeleteObject(hbmTransMask);
END;

{ ================== Methoden des Fensters ===================== }
PROCEDURE TDemoWin.Paint(PaintDC : HDC;var PaintInfo : TPaintStruct);
VAR BmpTransparent   : HBitmap;
    BmpNormal        : HBitmap;
    OldMode          : integer;
BEGIN
  BmpTransparent:=LoadBitmap(hInstance,'BMP_TRANSPARENT');
  BmpNormal:=LoadBitmap(hInstance,'BMP_Normal');
  BmpBlt(PaintDC,10,10,BmpNormal);
  TextOut(PaintDC,50,15,'Normale Darstellung',StrLen('Normale Darstellung'));
  { bildet die Bitmap ganz normal ab }
  BmpTransparentBlt(PaintDC,10,60,BmpTransparent,RGB(0,0,255));
  { bildet die Bitmap ab, ohne Pixel der Farbe RGB(0,0,255) darzustellen }
  OldMode:=SetBkMode(PaintDC,transparent);
  { fuer die Textausgabe wird erst jetzt der Transparent-Modus gesetzt }
  TextOut(PaintDC,50,65,'Transparente Darstellung',StrLen('Transparente Darstellung'));
  SetBkMode(PaintDC,OldMode);
  DeleteObject(BmpTransparent);
  DeleteObject(BmpNormal);
END;

PROCEDURE TDemoWin.GetWindowClass(var AWndClass : TWndClass);
BEGIN
  inherited GetWindowClass(AWndClass);
  AWndClass.hbrBackground:=GetStockObject(LtGray_Brush);
  { fuer dieses Fenster nehmen wir einen grauen HIntergrund, um den
    Effekt sichtbar zu machen }
END;

{ ================== Methoden der Applikation ===================== }
PROCEDURE TDemoApp.InitMainWindow;
BEGIN
  MainWindow:=New(PDemoWin,Init(nil,'Durchsichtige Darstellung von Bitmaps'));
END;

{ *****************   Programm ******************* }

VAR DemoApp  : TDemoApp;

BEGIN
  DemoApp.Init('DemoApp');
  DemoApp.Run;
  DemoApp.Done;
END.

END.
{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-001337-200697--72--85-48751-----BMPTBLT.RES--1-OF--1
zk6+EYpELotDIYp-H++k+4U0+++c++++6++++0+++++-++E++++++++0++++++++++++++++
+++E++++++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z++1z++++zzw+
zk+++Dw+zk1zzk++zzzz+Dzzzzzzzzzzzzzzzzzzzzzzzz++++zzzzzzzzzzzzzzzz+5W6W+
zzzzzzzzzzzzzzw5RrRrQDzzzzzzzzzzzzzkRrTzzs++++++++++++++-r1zzzzkW6W6W6W6
W6W6U+QDzzzz1zzzzzzzzzzzzz+5+++++5Q5Q5Q5Q5Q5Q5wD+DwDzkTkTkTkTkTkTkTkzz++
++-z-z-z-z-z-z-z1zw5RrW6-s-s-s-s-s-s-kzz-rRsW6W6W6W6W6W6W6wDzkRrTzzzzzzz
zzzzzzzz1zw5RsW6W6W6W6W6W6W6UDzz-rVr+++++++++++5W+zzzkS5Q5W6W6W6W6W6U61z
zzzk++RsXzzzzzzzy6+Dzzzzzzw5SD++++++++S+zzzzzzzz-rXkNqRbNqQ5UDzzzzzzzkRs
w4NaNaNa-s1zzzzzzzw5SD-bNqRbNkS+zzzzzzzz-rXkNaNaNaM5UDzzzzzzzkRsw4XsxqRb
-s1zzzzzzzw5SD-jXsNaNUS+zzzzzzzz-rXkNqRbNqQ5UDzzzzzzzkRsw+++++++-s1zzzzz
zzw5S6RrRrRrRrW+zzzzzzzz-rW6W6W6W6W6UDzzzzzzzkRzzzzzzzzzzkzzzzzzzzw5W6W6
W6W6W61zzzzzzzzzw++++++++++Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk6+EYpELpFGEItH
I23GFItI+1++O+6++0U++++U++++6+++++2+-+++++++++6++++++++++++++++++-++++++
++++++0+++0+++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1zzk1z++++zk1z
+Dzz++1zzzw+nAnAnAnAnAnAnAnAnAnAnAnAk+++1AnAnAnAnAnAnAnAk+S6W61AnAnAnAnA
nAnAn+RrRrRknAnAnAnAnAnAnA-rRzzzU+++++++++++++k5QDzzzz06W6W6W6W6W6W+-kzz
zzwDzzzzzzzzzzzzw+Q+++++RkRkRkRkRkRkTkk+zkzz-z-z-z-z-z-z-z1Ak++++5w5w5w5
w5w5w5wAn+RrS6U5U5U5U5U5U5U51Ak5RrW6W6W6W6W6W6W6XknA-rRzzzzzzzzzzzzzzzwA
n+RrW6W6W6W6W6W6W6W+nAk5S5Q+++++++++++S61AnA-sRkS6W6W6W6W6W+UAnAnA++-rWD
zzzzzzzsU+nAnAnAn+Rsw+++++++-s1AnAnAnAk5SD-bNqRbNkS+nAnAnAnA-rXkNaNaNaM5
UAnAnAnAn+Rsw4RbNqRb-s1AnAnAnAk5SD-aNaNaNUS+nAnAnAnA-rXkODXrNqQ5UAnAnAnA
n+Rsw4yDVaNa-s1AnAnAnAk5SD-bNqRbNkS+nAnAnAnA-rXk+++++++5UAnAnAnAn+RsVrRr
RrRrS61AnAnAnAk5S6W6W6W6W6W+nAnAnAnA-rzzzzzzzzzz1AnAnAnAn+S6W6W6W6W6UAnA
nAnAnAn+++++++++++nAnAnAnAnAnAnAnAnAnAnAnAnAnAnz1k1z+E+k51+++++G++6++M++
EYpELotDIYp-H++L++6++c++EYpELpFGEItHI23GFItI++++++++++++
***** END OF BLOCK 1 *****

