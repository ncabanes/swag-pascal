(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0037.PAS
  Description: Using VER.DLL
  Author: ZWEITZE DE VRIES
  Date: 08-25-94  09:12
*)

{
From: ZWEITZE@et.tudelft.nl (Zweitze de Vries)

>Does anyone have examples of installation programs that use
>the file installation library (VER.DLL) in BP7?

Since all installation programs do the same thing, why reinvent
the wheel? Just buy one, it should be cheaper than developing
your own. There are also some share/freeware apps around (try CICA).

In respect to your question, I have some code that fills a dialog
box ('About...') according to the version information resource:
}

procedure THelpAbout.SetUpWindow;
var
  lVerInfoSize: LongInt;
  lVerHandle: LongInt;
  szModuleName: array [0..fsPathName] of Char;
  pVerData: PChar;
  Buffer: Pointer;
  lenBuffer: Word;
begin
  TDialog.SetupWindow;
  GetModuleFileName(hInstance, szModuleName, SizeOf(szModuleName));
  lVerInfoSize := GetFileVersionInfoSize(szModuleName, lVerHandle);
  if lVerInfoSize = 0 then Exit;
  GetMem(pVerData, lVerInfoSize);
  if not GetFileVersionInfo(szModuleName, lVerHandle, lVerInfoSize, pVerData)
    then Exit;
  if VerQueryValue(pVerData, '\StringFileInfo\CATE\ProductName',
                   Buffer, LenBuffer)
     and (LenBuffer <> 0)
    then SetDlgItemText(hWindow, stat_AppName, Buffer);
  if VerQueryValue(pVerData, '\StringFileInfo\CATE\ProductVersion',
                   Buffer, LenBuffer)
     and (LenBuffer <> 0)
    then SetDlgItemText(hWindow, stat_AppVersion, Buffer);
  if VerQueryValue(pVerData, '\StringFileInfo\CATE\CompanyName',
                   Buffer, LenBuffer)
     and (LenBuffer <> 0)
    then SetDlgItemText(hWindow, stat_AppCompany, Buffer);
  if VerQueryValue(pVerData, '\StringFileInfo\CATE\LegalCopyright',
                   Buffer, LenBuffer)
     and (LenBuffer <> 0)
    then SetDlgItemText(hWindow, stat_AppCopyright, Buffer);
  FreeMem(pVerData, lVerInfoSize);
end;

