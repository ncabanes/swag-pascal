(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0192.PAS
  Description: A Drives handling unit
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)

unit Disques;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     FileCtrl,LZExpand,ShellAPI;

// Constants
const
     (* drive type *)
     _drive_not_exist = 255;
     _drive_floppy    = 1;
     _drive_hard      = 2;
     _drive_network   = 3;
     _drive_CDRom     = 4;
     _drive_RAM       = 5;
     (* directory option *)
     _directory_recurrent      = 1;
     _directory_not_recurrent  = 0;
     _directory_force          = 1;
     _directory_not_force      = 0;
     _directory_clear_file     = 1;
     _directory_not_clear_file = 0;
     (* file error *)
     _File_Unable_To_Delete     = 10;
     _File_Copied_Ok            = 0;
     _File_Already_Exists       = 1;
     _File_Bad_Source           = 2;
     _File_Bad_Destination      = 3;
     _File_Bad_Source_Read      = 4;
     _File_Bad_Destination_Read = 5;
     (* copy switch *)
     _File_copy_Overwrite       = 1;

// Drives
function _Drive_Type (_Drive : char) : byte;
function _Drive_As_Disk (_Drive: Char): Boolean;
function _Drive_Size (_Drive : char) : longint;
function _Drive_Free (_Drive : char) : longint;

// Directories
function _Directory_Exist (_Dir : string) : boolean;
function _Directory_Create (_Dir : string) : boolean;
function _Directory_Delete (_Dir  : string;ClearFile : byte) : boolean;
function _Directory_Delete_Tree (_Dir : string; ClearFile : byte) : boolean;
function _Directory_Rename (_Dir,_NewDir : string) : boolean;

// Files
function _File_Exist (_File : string) : boolean;
function _File_Delete (_File : string) : boolean;
function _File_Recycle (_File : string) : boolean;
function _File_Rename (_File,_NewFile : string;_Delete : byte) : boolean;
function _File_Copy_UnCompress (FromFile,ToFile : string;Switch : byte) : byte;
function _File_Copy(source,dest: String): Boolean;
function _File_Move (_Source,_Destination : string) : boolean;
function _File_Get_Attrib (_File : string) : byte;
function _File_Set_Attrib (_File : string;_Attrib : byte) : boolean;
function _File_Get_Date (_File : string) : string;
function _File_Set_Date (_File,_Date : string) : boolean;
function _File_Get_Size (_File : string) : longint;
function _File_Start (AppName,AppParams,AppDir : string) : integer;

// Miscellaneous
function _Get_WindowsDir : string;
function _Get_SystemDir : string;
function _Get_TempDir : string;
function _Get_Apps_Dir (ExeName : PChar) : string;
function _Get_Apps_Drive (ExeName : PChar) : string;
function _Get_WindowsVer : real;
function _Get_WindowsBuild : real;
function _Get_WindowsPlatform : string;
function _Get_WindowsExtra : string;

implementation


(**********)
(* drives *)
(**********)


(* type of drive *)
function _Drive_Type (_Drive : char) : byte;
var i: integer;
    c : array [0..255] of char;
begin
 _Drive := upcase (_Drive);
 if not (_Drive in ['A'..'Z']) then
  Result := _drive_not_exist
 else
 begin
  strPCopy (c,_Drive + ':\');
  i := GetDriveType (c);
  case i of
   DRIVE_REMOVABLE: result := _drive_floppy;
   DRIVE_FIXED    : result := _drive_hard;
   DRIVE_REMOTE   : result := _drive_network;
   DRIVE_CDROM    : result := _drive_CDRom;
   DRIVE_RAMDISK  : result := _drive_RAM;
  else
   result := _drive_not_exist;
  end;
 end;
end;

(* test is a disk is in drive *)
function _Drive_As_Disk (_Drive: Char): Boolean;
var ErrorMode: Word;
begin
 _Drive := UpCase(_Drive);
 if not (_Drive in ['A'..'Z']) then
 raise
  EConvertError.Create ('Not a valid drive letter');
 ErrorMode := SetErrorMode (SEM_FailCriticalErrors);
 try
  Application.ProcessMessages;
  Result := (DiskSize ( Ord(_Drive) - Ord ('A') + 1) <> -1);
 finally
  SetErrorMode(ErrorMode);
  Application.ProcessMessages;
 end;
end;

(* size of drive *)
function _Drive_Size (_Drive : char) : longint;
var ErrorMode : word;
begin
 _Drive := upcase (_Drive);
 if not (_Drive in ['A'..'Z']) then
 raise
  EConvertError.Create ('Not a valid drive letter');
 ErrorMode := SetErrorMode (SEM_FailCriticalErrors);
 try
  Application.ProcessMessages;
  Result := DiskSize ( Ord(_Drive) - Ord ('A') + 1);
 finally
  SetErrorMode (ErrorMode);
 end;
end;

(* free space in drive *)
function _Drive_Free (_Drive : char) : longint;
var ErrorMode : word;
begin
 _Drive := upcase (_Drive);
 if not (_Drive in ['A'..'Z']) then
 raise
  EConvertError.Create ('Not a valid drive letter');
 ErrorMode := SetErrorMode (SEM_FailCriticalErrors);
 try
  Application.ProcessMessages;
  Result := DiskFree ( Ord(_Drive) - Ord ('A') + 1);
 finally
  SetErrorMode (ErrorMode);
 end;
end;


(***************)
(* directories *)
(***************)

(* directory exists or not *)
function _Directory_Exist (_Dir : string) : boolean;
VAR  OldMode : Word;
     OldDir  : String;
BEGIN
 Result := True;
 GetDir(0, OldDir);
 OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
 try
  try
   ChDir(_Dir);
 except
   ON EInOutError DO
    Result := False;
 end;
 finally
   ChDir(OldDir);
   SetErrorMode(OldMode);
 end;
END;

(* create a directory enven if parent does not exists *)
function _Directory_Create (_Dir : string) : boolean;
begin
 ForceDirectories(_Dir);
 Result := _Directory_Exist (_Dir);
end;

(* delete a directory *)
function _Directory_Delete (_Dir : string;ClearFile : byte) : boolean;
begin
 if _Directory_Exist (_Dir) then
  Result := RemoveDir (_Dir)
 else
  Result := false;
end;

(* delete a tree *)
function _directory_delete_tree (_Dir : string; ClearFile : byte) : boolean;
var SearchRec : TSearchRec;
    Erc : Word;
begin
 if _Directory_Exist (_Dir) then
 begin
  Try
   ChDir (_Dir);
   FindFirst('*.*',faAnyFile,SearchRec);
   Erc := 0;
   while Erc = 0 do
   begin
    if ((SearchRec.Name <> '.' ) and
       (SearchRec.Name <> '..')) then
    begin
     if (SearchRec.Attr and faDirectory > 0) then
      _Directory_Delete_Tree (SearchRec.Name,ClearFile)
     else
      if ClearFile = 1 then
       _File_Delete (SearchRec.Name);
    end;
    Erc := FindNext (SearchRec);
   end;
   FindClose (SearchRec);
   Application.ProcessMessages;
  finally
   if Length(_Dir) > 3 then
    ChDir ('..' );
   Result := RemoveDir (_Dir);
  end;
 end
 else
 (* not exists *)
  Result := false;
end;

(* Renamme a directory *)
function _Directory_Rename (_Dir,_NewDir : string) : boolean;
var SearchRec : TSearchRec;
    Erc : Word;
    f : file;
    o : string;
begin
 if _Directory_Exist (_Dir) then
 begin
  Try
   (* just name of directory *)
   o := _dir;
   Delete (o,1,2); (* remove drive and : *)
   if o [1] = '\' then delete (o,1,1); (* remove \ at begin *)
   if o [length (o)] = '\' then
    o := copy (o,1,length (o)-1); (* delete \ at end *)
   ChDir (_Dir);
   ChDir ('..');
   FindFirst('*.*',faAnyFile,SearchRec);
   Erc := 0;
   while Erc = 0 do
   begin
    if ((SearchRec.Name <> '.' ) and
       (SearchRec.Name <> '..')) then
    begin
     if (SearchRec.Attr and faDirectory > 0) then
     begin
      if SearchRec.Name = o then
      begin
       assignfile (f,SearchRec.Name);
       {$I-};
        rename (F,_NewDir);
       {I+};
       result := (ioresult = 0);
      end;
     end;
    end;
    Erc := FindNext (SearchRec);
   end;
   Application.ProcessMessages;
  finally
   if Length(_Dir) > 3 then
    ChDir ('..' );
  end;
  FindClose (SearchRec);
 end
 else
 (* not exists *)
  Result := false;
end;


(*********)
(* files *)
(*********)

(* file exists or not *)
function _File_Exist (_File : string) : boolean;
begin
 _File_Exist := FileExists(_File);
end;

(* delete a file remove -r if needed *)
function _File_Delete (_File : string) : boolean;
begin
 if FileExists (_File) then
 begin
  _File_Set_Attrib (_File,0);
  Result := DeleteFile (_File);
 end
 else
  Result := false;
end;

(* send a file to recycle *)
function _File_Recycle(_File : TFilename): boolean;
var Struct: TSHFileOpStruct;
    pFromc: array[0..255] of char;
    Resul  : integer;
begin
 if not FileExists(_File) then
 begin
  _File_Recycle := False;
  exit;
 end
 else
 begin
  fillchar(pfromc,sizeof(pfromc),0);
  StrPcopy(pfromc,expandfilename(_File)+#0#0);
  Struct.wnd := 0;
  Struct.wFunc := FO_DELETE;
  Struct.pFrom := pFromC;
  Struct.pTo   := nil;
  Struct.fFlags:= FOF_ALLOWUNDO or FOF_NOCONFIRMATION	;
  Struct.fAnyOperationsAborted := false;
  Struct.hNameMappings := nil;
  Resul := ShFileOperation(Struct);
  _File_Recycle := (Resul = 0);
 end;
end;

(* renamme a file, delete if needed *)
function _File_Rename (_File,_NewFile : string;_Delete : byte) : boolean;
var f : file;
begin
 if FileExists (_File) then
 begin
  if FileExists (_NewFile) then
  begin
   if _Delete = 0 then
    Result := false
   else
    _File_Delete (_NewFile);
  end;
  assignfile (f,_File);
  {$I-};
   Rename (f,_NewFile);
  {$I+};
  Result := (ioresult = 0);
 end
 else
  Result := false;
end;

(* copy a file *)
function _File_Copy_UnCompress (FromFile,ToFile : string;Switch : byte) : byte;
var Tmp : integer;
    FromF, ToF: file;
    NumRead, NumWritten: Word;
    iHandle : Integer;
    iNewHandle : Integer;
    iReturn : Integer;
    iLongReturn : LongInt;
    pFrom : Array[0..256] of Char;
    pTo : Array[0..256] of Char;
begin
 Tmp := 0;
 If (FileExists (ToFile)) and (Switch = 0) then
  Tmp := 1
 else
 begin
  StrPCopy( pFrom, FromFile );
  iReturn := GetExpandedName( pFrom, pTo );
  if iReturn = -1 then
   Tmp := 2
  else
  begin
   if iReturn = -2 then
    Tmp := 3
   else
   begin
    if ( StrEnd( pTo ) - pTo ) > 0 then
    begin
     ToFile := ExtractFilePath( ToFile ) +
               ExtractFileName( strPas( pTo ) );
     iHandle := FileOpen( FromFile, fmShareDenyWrite );
     LZInit (iHandle);
     if iHandle < 1 then
      Tmp := 2
     else
     begin
      iNewHandle := FileCreate( ToFile );
      if iNewHandle < 1 then
       Tmp := 3
      else
      begin
       iLongReturn := LZCopy( iHandle , iNewHandle );
       if iLongReturn = LZERROR_UNKNOWNALG then
        Tmp := 5
       else
       begin
        FileClose( iHandle );
        FileClose( iNewHandle );
        LZClose (iHandle);
       end;
      end;
     end;
    end
    else
     Tmp := 3;
   end
  end;
 end;
 _File_Copy_UnCompress := Tmp;
end;

(* just copy a file *)
function _File_Copy(source,dest: String): Boolean;
var
  fSrc,fDst,len: Integer;
  size: Longint;
  buffer: packed array [0..2047] of Byte;
begin
  if pos ('\\',source) <> 0 then delete (source,pos ('\\',source),1);
  if pos ('\\',dest) <> 0 then delete (dest,pos ('\\',dest),1);
  Result := False;
  if source <> dest then
  begin
   fSrc := FileOpen(source,fmOpenRead);
   if fSrc >= 0 then
   begin
    size := FileSeek(fSrc,0,2);
    FileSeek(fSrc,0,0);
    fDst := FileCreate(dest);
    if fDst >= 0 then begin
     while size > 0 do
     begin
       len := FileRead(fSrc,buffer,sizeof(buffer));
       FileWrite(fDst,buffer,len);
       size := size - len;
     end;
     FileSetDate(fDst,FileGetDate(fSrc));
     FileClose(fDst);
     FileSetAttr(dest,FileGetAttr(source));
     Result := True;
    end;
    FileClose(fSrc);
   end;
  end;
end;

(* move a file *)
function _File_Move (_Source,_Destination : string) : boolean;
var Tmp : boolean;
begin
 tmp := _File_Copy (_Source,_Destination);
 if Tmp = true then
  if _File_Delete (_Source) = true then
   Tmp := true
  else
   Tmp := false;
 Result := Tmp;
end;

(* Get file attributes *)
function _File_Get_Attrib (_File : string) : byte;
var Tmp : byte;
    Att : integer;
begin
 if FileExists (_File) then
 begin
  Att := FileGetAttr (_File);
  if Att <> -1 then
  begin
   Tmp := 0;
   if (Att AND faReadOnly) = faReadOnly then Tmp := Tmp + 1;
   if (Att AND faHidden) = faHidden then Tmp := Tmp + 2;
   if (Att AND faSysFile) = faSysFile then Tmp := Tmp + 4;
   if (Att AND faArchive) = faArchive then Tmp := Tmp + 8;
   Result := Tmp;
  end
  else
   Result := 255;
 end
 else
  Result := 255;
end;

(* Set file attributes *)
function _File_Set_Attrib (_File : string;_Attrib : byte) : boolean;
var Tmp : integer;
begin
 if FileExists (_File) then
 begin
  Tmp := 0;
  if _Attrib and 1 = 1 then Tmp := tmp OR faReadOnly;
  if _Attrib and 2 = 2 then Tmp := tmp OR faHidden;
  if _Attrib and 4 = 4 then Tmp := tmp OR faSysFile;
  if _Attrib and 8 = 8 then Tmp := tmp OR faArchive;
  Result := FileSetAttr (_File,Tmp) = 0;
 end
 else
  Result := false
end;

(* Get datestamp of file *)
function _File_Get_Date (_File : string) : string;
var f   : file;
    Hdl : integer;
    Tmp : string;
    Dte : integer;
    Dat : TDateTime;
begin
 Tmp := '';
 Hdl := FileOpen(_File, fmOpenRead or fmShareDenyNone);
 if Hdl > 0 then
 begin
  Dte := FileGetDate (Hdl);
  FileClose (Hdl);
  Dat := FileDateToDateTime (Dte);
  Tmp := DateToStr (Dat);
  while pos ('/',Tmp) <> 0 do delete (Tmp,pos ('/',Tmp),1);
  if length (tmp) > 6 then delete (Tmp,5,2);
 end;
 Result := Tmp;
end;

(* Set datestamp of file *)
function _File_Set_Date (_File,_Date : string) : boolean;
var f   : file;
    Hdl : integer;
    Dte : integer;
    Dat : TDateTime;
    Att : integer;
begin
 Att := _File_Get_Attrib (_File);
 if (Att AND 1) <> 1 then Att := 0
                     else _File_Set_Attrib (_File,0);
 Hdl := FileOpen(_File, fmOpenReadWrite or fmShareDenyNone);
 if Hdl > 0 then
 begin
  if length (_Date) < 8 then Insert ('19',_Date,5);
  if pos ('/',_Date) = 0 then
   _Date := copy (_Date,1,2) + '/' +
            copy (_Date,3,2) + '/' +
            copy (_Date,5,4);
  Dat := StrToDateTime (_Date);
  Dte := DateTimeToFileDate (Dat);
  Result := FileSetDate (Hdl,Dte) = 0;
  FileClose (Hdl);
  if Att <> 0 then
    _File_Set_Attrib (_File,Att);
 end
 else
 begin
  if Att <> 0 then
    _File_Set_Attrib (_File,Att);
  Result := False;
 end;
end;

(* return size of a file *)
function _File_Get_Size (_File : string) : longint;
var f: file of Byte;
    a : integer;
begin
 if FileExists (_File) then
 begin
  a := _File_Get_Attrib (_File);
  if (a AND 1) = 1 then
   _File_Set_Attrib (_File,0)
  else
   a := 0;
  AssignFile(f,_File);
  {$I-};
   Reset(f);
  {$I+};
  if ioresult = 0 then
  begin
   Result := FileSize(f);
   CloseFile(f);
   if a <> 0 then
    _File_Set_Attrib (_File,a);
  end
  else
  begin
   if a <> 0 then
    _File_Set_Attrib (_File,a);
   Result := -1;
  end;
 end
 else
  Result := -1;
end;

(* lancement d'une application *)
function _File_Start (AppName,AppParams,AppDir : string) : integer;
var Tmp : Integer;
    zFileName : array [0 .. 79] of char;
    zParams   : array [0 .. 79] of char;
    zDir      : array [0 .. 79] of Char;
begin
 Tmp := 0;
 StrPCopy (zFileName,AppName);
 StrPCopy (zParams,AppParams);
 StrPCopy (zDir,AppDir);
 Tmp := ShellExecute (0,Nil,zFileName,zParams,zDir,1);
 _File_Start := Tmp;
end;



(*****************)
(* miscellaneous *)
(*****************)

(* return Windows directory *)
function _Get_WindowsDir : string;
var Tmp : array [0 .. 255] of char;
    Ret : string;
begin
 if GetWindowsDirectory (Tmp,255) <> 0 then
 begin
  Ret := StrPas (Tmp);
  if Ret [length (Ret)] = '\' then
   Ret := copy (Ret,1,length (Ret) - 1);
  Result := Ret;
 end
 else
  Result := '';
end;

(* return Windows system directory *)
function _Get_SystemDir : string;
var Tmp : array [0 .. 255] of char;
    Ret : string;
begin
 if GetSystemDirectory (Tmp,255) <> 0 then
 begin
  Ret := StrPas (Tmp);
  if Ret [length (Ret)] = '\' then
   Ret := copy (Ret,1,length (Ret) - 1);
  Result := Ret;
 end
 else
  Result := '';
end;

(* return Windows Temp directory *)
function _Get_TempDir : string;
var Tmp : array [0 .. 255] of char;
    Ret : string;
begin
 if GetTempPath (255,Tmp) <> 0 then
 begin
  Ret := StrPas (Tmp);
  if Ret [length (Ret)] = '\' then
   Ret := copy (Ret,1,length (Ret) - 1);
  Result := Ret;
 end
 else
  Result := '';
end;

(* return application directory *)
function _Get_Apps_Dir (ExeName : PChar) : string;
var Hdl : THandle;
    Nam : PChar;
    Fil : array [0..255] of char;
    Siz : integer;
    Ret : integer;
    Pas : string;
    Pat : string [79];
begin
 Pat := '';
 Hdl := GetModuleHandle (ExeName);
 Ret := GetModuleFileName (Hdl,Fil,Siz);
 Pas := StrPas (Fil);
 Pat := ExtractFilePath (Pas);
 Delete (Pat,1,2);
 if Pat [length (Pat)] = '\' then
  Pat := copy (Pat,1,length (Pat) - 1);
 Result := Pat;
end;

(* return dirve of current application *)
function _Get_Apps_Drive (ExeName : PChar) : string;
var Hdl : THandle;
    Nam : PChar;
    Fil : array [0..255] of char;
    Siz : integer;
    Ret : integer;
    Pas : string;
    Drv : string [02];
begin
 Drv := '';
 Hdl := GetModuleHandle (ExeName);
 Ret := GetModuleFileName (Hdl,Fil,Siz);
 Pas := StrPas (Fil);
 Drv := ExtractFilePath (Pas);
 _Get_Apps_Drive := Drv;
end;

(* return windows version as a real *)
function _Get_WindowsVer : real;
var tempo   : string;
    Temp    : real;
    err     : integer;
    struct  : TOSVersionInfo;
begin
 struct.dwOSVersionInfoSize := sizeof (Struct);
 struct.dwMajorVersion := 0;
 struct.dwMinorVersion := 0;
 GetVersionEx (Struct);
 Tempo  := inttostr (Struct.dwMajorVersion) + '.' + inttostr (Struct.dwMinorVersion);
 val (tempo,temp,err);
 Result := Temp;
end;

(* return type of platform *)
function _Get_WindowsPlatform : string;
var tempo   : string;
    Temp    : string;
    err     : integer;
    struct  : TOSVersionInfo;
begin
 struct.dwOSVersionInfoSize := sizeof (Struct);
 struct.dwPlatformId := 0;
 GetVersionEx (Struct);
 case struct.dwPlatformid of
  ver_platform_win32s : temp := 'Win32S';
  ver_platform_win32_windows : temp := 'Win32';
  ver_platform_win32_nt : temp := 'WinNT';
 end;
 Result := Temp;
end;

(* get extra information *)
function _Get_WindowsExtra : string;
var tempo   : string;
    Temp    : string;
    err     : integer;
    struct  : TOSVersionInfo;
begin
 struct.dwOSVersionInfoSize := sizeof (Struct);
 struct.dwMajorVersion := 0;
 struct.dwMinorVersion := 0;
 struct.dwBuildNumber := 0;
 struct.dwPlatformId := 0;
 GetVersionEx (Struct);
 Temp := '';
 Temp := strPas (Struct.szCSDVersion);
 Result := Temp;
end;

(* return windows build as a real *)
function _Get_WindowsBuild : real;
var tempo   : string;
    Temp    : real;
    err     : integer;
    struct  : TOSVersionInfo;
begin
 struct.dwOSVersionInfoSize := sizeof (Struct);
 struct.dwBuildNumber := 0;
 GetVersionEx (Struct);
 tempo := inttostr (struct.dwBuildNumber AND $0000FFFF);
 val (tempo,temp,err);
 Result := Temp;
end;

begin
end.


