{
From: ZWEITZE@ET.TUDelft.NL (Zweitze de Vries)

>Metafiles made in BP won't import into Word for Windows, while
>CorelDraw accepts the files. Does anyone know what's causing
>this problem?

Yes. There is not one Metafile format, there are three (!)
(excluding NT formats). The original is meant for internal
usage, like fast painting. Later this original was saved to
file to enable graphics exchange. This gave problems,
because of different mapping modes, and device resolutions.
Still, MS wanted to encourage exchange, so two new metafile
formats were developed, metafile to clipboard and the
placeable metafile (which is saved to file).

Word only accepts clipboard and placeable metafiles.
A placeable metafile is an original metafile with a 22 byte
header, which is called the placeable metafile header.
This 22 byte record is documented in your online help topic
'Metafile format'. The record type def is not implemented
in BP, so you've got to type it yourself. (Or use my copy
below)

Hereby I supply my metafile output code. There are two
entry points, which make the metafile go to clipboard or
file. In case of file, a common dialog is displayed.


{*****************************************************************************}
{*                   Werkgroep Elektrotechnisch Practicum                    *}
{*                       Faculteit der Elektrotechniek                       *}
{*                       Technische Universiteit Delft                       *}
{*****************************************************************************}
{*                               project : CATE                              *}
{* program      :  cateshell (werktitel)             date     :  Oct 1994    *}
{* filename   :  APPCHILD.PAS                     version  :  0.61           *}
{* author     :  Z.A. de Vries                    compiler :  BPW 7.0        *}
{* description:  Performs basic MDI child window handling                    *}
{*****************************************************************************}

uses
  CommDlg, WinProcs, WinTypes, Objects, OWindows, Strings, Win31;

{...}

{ Not found in runtime libs, this structure is the header of a so-called
  Placeable metafile. A Placeable metafile is a standard metafile with 
  this 22byte header. This header is documented in the online help under 
  'Metafile Format' }
type
  PPlaceableMF = ^TPlaceableMF;
  TPlaceableMF = record
    Key:      LongInt;
    hMF:      THandle;
    BBox:     TRect;
    Inch:     Integer;
    Reserved: LongInt;
    Checksum: Integer;
  end;

procedure TChildWndBase.MetafileToFile;
var
  szNewName: PChar;
  szFilter: array [0..100] of Char;
  szExt: array [0..3] of Char;
  pFilter: PChar;
  SaveRec: TOpenFileName;
  wmfFile: PBufStream;
  wmfHeader: TPlaceableMF;
  hMetafile: THandle;
  pMetafile: PMetaHeader;
  ScrnDC: HDC;
begin
  GetMem(szNewName, fsCompleteName);    { const fsCompleteName = 144 }

  FillChar(szFilter, SizeOf(szFilter), 0);
  StrCopy(szFilter, 'Windows Metafiles (*.WMF)');
  pFilter := StrEnd(szFilter);
  Inc(pFilter);
  pFilter := StrECopy(pFilter, '*.WMF');
  Inc(pFilter);
  pFilter := StrECopy(pFilter, 'All files (*.*)');
  Inc(pFilter);
  StrCopy(pFilter, '*.*');

  StrCopy(szNewName, '*.WMF');
  FillChar(SaveRec, SizeOf(SaveRec), 0);
  with SaveRec
    do begin
      hwndOwner     := Application^.MainWindow^.hWindow;
      lStructSize   := SizeOf(SaveRec);
      lpstrFile     := szNewName;
      nMaxFile      := fsCompleteName;
      Flags         := ofn_NoReadOnlyReturn or ofn_OverwritePrompt or
                       ofn_PathMustExist or ofn_ShowHelp or ofn_HideReadOnly;
      lpstrDefExt   := 'WMF';
      lpstrFilter   := szFilter;
      nFilterIndex  := 1;
    end;

  if GetSaveFileName(SaveRec)
    then begin
      ScrnDC := GetDC(hWindow);
      with wmfHeader
        do begin
          Key := $9AC6CDD7;
          hMF := 0;
          GetClientRect(hWindow, BBox);
          Inch := (GetDeviceCaps(ScrnDC, LogPixelsX) +
                   GetDeviceCaps(ScrnDC, LogPixelsY)) div 2;
          Reserved := 0;
          Checksum := $9AC6 xor $CDD7 xor BBox.Right xor BBox.Bottom xor Inch;
        end;
      ReleaseDC(hWindow, ScrnDC);

      hMetafile := DrawMetafile(nil);

      wmfFile := new(PBufStream, Init(szNewName, stCreate, 2048));
      wmfFile^.Write(wmfHeader, SizeOf(wmfHeader));
      pMetafile := GlobalLock(hMetafile);
      wmfFile^.Write(pMetafile^, pMetafile^.mtSize * 2);
      GlobalUnlock(hMetaFile);
      wmfFile^.Done;

      DeleteMetafile(hMetafile);
    end;

  FreeMem(szNewName, fsCompleteName);
end;

procedure TChildWndBase.MetafileToClipboard;
const
  HiMetricPerInch = 2540;
var
  hMetafile, hMetafileClipboardHeader: THandle;
  pMetafileClipboardHeader: PMetafilePict;
  rcWindow: TRect;
  RefDC: HDC;
begin
  if not OpenClipboard(hWindow)
    then Exit;
  EmptyClipboard;

  hMetafile := DrawMetafile(nil);

  hMetafileClipboardHeader :=
          GlobalAlloc(gmem_DDEShare, SizeOf(TMetaFilePict));
  if (hMetafile = 0) or (hMetafileClipboardHeader = 0)
    then begin
      CloseClipboard;
      if hMetafile <> 0
        then GlobalFree(hMetafile);
      if hMetafileClipboardHeader <> 0
        then GlobalFree(hMetafileClipboardHeader);
      Exit;
    end;

  pMetafileClipboardHeader :=
          PMetaFilePict(GlobalLock(hMetafileClipboardHeader));
  with pMetafileClipboardHeader^
    do begin
      mm   := mm_Anisotropic;
      hMF  := hMetafile;
      GetClientRect(hWindow, rcWindow);  { Size is window size }
      with rcWindow
        do begin
          RefDC := GetDC(hWindow);
          xExt := MulDiv(Right - Left, HiMetricPerInch,
                         GetDeviceCaps(RefDC, LogPixelsX));
          yExt := MulDiv(Bottom - Top, HiMetricPerInch,
                         GetDeviceCaps(RefDC, LogPixelsY));
          ReleaseDC(hWindow, RefDC);
        end;
    end;

  GlobalUnlock(hMetafileClipboardHeader);
  SetClipboardData(cf_MetafilePict, hMetafileClipboardHeader);
  CloseClipboard;
end;


function TChildWndBase.DrawMetafile(szOutput: PChar): THandle;
var
  MetaDC      : HDC;
  PaintStruct : TPaintstruct;
begin
  MetaDC := CreateMetaFile(szOutput);
  SetMapMode(MetaDC, mm_anisotropic);
  SetWindowOrg(MetaDC, 0, 0);

  with PaintStruct
    do begin
      hdc    := MetaDC;
      fErase := false;
      GetClientRect(hWindow, rcPaint);
      with rcPaint
        do begin
                   { Its size is exact the same as the window size }
          SetWindowExt(MetaDC, Right - Left, Bottom - Top);

                   { Setup a clipping rectangle }
          IntersectClipRect(MetaDC, Left, Top, Right, Bottom);

                   { Setup the background color of the metafile 
                     which is the same as the window background }
          SelectObject(MetaDC, GetClassWord(hWindow, gcw_hbrBackground));
          PatBlt(MetaDC, Left, Top, Right, Bottom, PatCopy);
          SelectObject(MetaDC, GetStockObject(Hollow_Brush));
        end;
    end;

  DrawContents(MetaDC, PaintStruct); 
       { DrawContents does the actual drawing. It is also called by
         my painting and printing handlers. DrawContents assumes it
         is working in MM_TEXT mode, when the output is going to a
         metafile, the actual mapping mode is MM_ANISOTROPIC, but
         resembling MM_TEXT on any device. }

  DrawMetafile := CloseMetaFile(MetaDC);
end;

