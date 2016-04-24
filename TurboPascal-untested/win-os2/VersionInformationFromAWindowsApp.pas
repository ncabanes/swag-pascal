(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0078.PAS
  Description: Version information from a Windows app
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  11:03
*)

{
  This sample program demonstrates how to use the
  GetFileVersionInfo,  GetFileVersionInfoSize, and

  VerQueryValue API functions to obtain  version
  information from a Windows EXE or DLL containing
  a version  information resource.
}

program GetVer;

uses WinCRT, WinTypes, WinProcs, Ver;

const
  FileName: PChar = 'c:\windows\system\mmsystem.dll';

type
  PLongInt = ^Longint;

var
  VSize, VHandle: Longint;
  Buffer: PChar;
  Length, LangID, CharSetID: Word;
  TranslationInfo, Result: Pointer;
  StringFileInfo: Array[0..49] of Char;
  LangCharSetIDArray: Array[1..2] of Word;


begin
  { Get size of version info }
  VSize := GetFileVersionInfoSize(FileName, VHandle);
  { Allocate version info buffer }
  GetMem(Buffer, VSize + 1);
  { Get version info }
  if GetFileVersionInfo(FileName, VHandle, VSize, Buffer) then
    { Get translation info for Language / CharSet IDs }
    if VerQueryValue(Buffer, '\VarFileInfo\Translation',
                                       TranslationInfo, Length) then begin
      LangCharSetIDArray[1] := LoWord(PLongint(TranslationInfo)^);

      LangCharSetIDArray[2] := HiWord(PLongint(TranslationInfo)^);
      { Get comments - this field is often blank }
      wvsPrintf(StringFileInfo, '\StringFileInfo\%04x%04x\Comments',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Comments: ', PChar(Result));
      { Get company name }
      wvsPrintf(StringFileInfo,
                           '\StringFileInfo\%04x%04x\CompanyName',
                          LangCharSetIDArray);

      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Company: ', PChar(Result));
      { Get file description }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\FileDescription',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('File description: ', PChar(Result));
      { Get file version }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\FileVersion',

                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('File version: ', PChar(Result));
      { Get internal name}
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\InternalName',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Internal name: ', PChar(Result));
      { Get legal copyright info }

      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\LegalCopyright',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Copyright: ', PChar(Result));
      { Get trademarks }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\LegalTrademarks',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);

      Writeln('Trademarks: ', PChar(Result));
      { Get original filename }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\OriginalFilename',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Original filename: ', PChar(Result));
      { Get private build info }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\PrivateBuild',

                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Private build info: ', PChar(Result));
      { Get product name }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\ProductName',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Product name: ', PChar(Result));
      { Get product version }

      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\ProductVersion',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);
      Writeln('Product version: ', PChar(Result));
      { Get special build info }
      wvsPrintf(StringFileInfo,
                          '\StringFileInfo\%04x%04x\SpecialBuild',
                          LangCharSetIDArray);
      VerQueryValue(Buffer, StringFileInfo, Result, Length);

      Writeln('Special build info: ', PChar(Result));
    end;
  FreeMem(Buffer, VSize + 1);
end.

