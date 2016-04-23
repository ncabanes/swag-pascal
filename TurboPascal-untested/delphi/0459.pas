Unit MKFile32;   {Delphi32 Bit Only!}

///////////////////////////////////////////////////////////////////////////////
// MKFile32 Coded in Part by G.E. Ozz Nixon Jr. of Warpgroup.com             //
// ========================================================================= //
// Original Source for DOS by Mythical Kindom's Mark May (mmay@dnaco.net)    //
// Re-written and distributed with permission!                               //
// See Original Copyright Notice before using any of this code!              //
///////////////////////////////////////////////////////////////////////////////

Interface

Uses
   FileCtrl,
   Forms,
   Windows,
   SysUtils;

Const
   fmReadOnly  = 0;          {FileMode constants}
   fmWriteOnly = 1;
   fmReadWrite = 2;
   fmDenyAll   = 16;
   fmDenyWrite = 32;
   fmDenyRead  = 48;
   fmDenyNone  = 64;
   fmNoInherit = 128;

Const
   Tries:Word    = 150;
   TryDelay:Word = 100;

Type
   FindRec=Record
      SRec:TSearchRec;
      Dir,
      Name,
      Ext:String;
      DError:Word;
   End;

Type
   FindObj=Object
      FI:^FindRec;
      Procedure Init;               {Initialize}
      Procedure Done;               {Done}
      Procedure FFirst(FN:String);  {Find first}
      Procedure FNext;              {Find next}
      Procedure FDone;              {Find close}
      Function  Found:Boolean;      {File was found}
      Function  GetName:String;     {Get Filename}
      Function  GetFullPath:String; {Get filename with path}
      Function  GetDate:LongInt;    {Get file date}
      Function  GetSize:LongInt;    {Get file size}
   End;

Type
   TFileArray32=Array[1..$fff0] of Char;

Type
   TFileRec32=Record
      MsgBuffer:^TFileArray32;
      BufferStart:LongInt;
      BufferFile:File;
      CurrentStr:String;
      StringFound:Boolean;
      BufferPtr,
      Error:Word;
      BufferChars,
      BufferSize:Integer;
   End;

Type
   TFile32=Object
      TF:^TFileRec32;
      Procedure Init;
      Procedure Done;
      Function  GetString:String;           {Get string from file}
      Function  GetUString:String;          {Get LF delimited string}
      Function  GetCString:String;          {Get #0 delimited string}
      Procedure GetBlock(Var Buf;NumToRead:Integer);
      Function  OpenTextFile(FilePath:String):Boolean;  {Open file}
      Function  CloseTextFile:Boolean;      {Close file}
      Function  GetChar:Char;               {Internal use}
      Procedure BufferRead;                 {Internal use}
      Function  StringFound:Boolean;        {Was a string found}
      Function  SeekTextFile(SeekPos:LongInt):Boolean; {Seek to position}
      Function  GetTextPos:LongInt;         {Get text file position}
      Function  Restart:Boolean;            {Reset to start of file}
      Procedure SetBufferSize(BSize:Word);  {Set buffer size}
   End;

Var
   MKFileError: Word;

procedure Delay(msecs:integer);
Function  GetEnv(Str:String):String;
Function  FExpand(Str:String):String;
Procedure FSplit(Path:String; Var Dir,Name,Ext:String);
Function  FSearch(Path: String; DirList: String): String;
Function  FileExist(FName: String): Boolean;
Function  SizeFile(FName: String): LongInt;
Function  DateFile(FName: String): LongInt;
Function  FindPath(FileName: String): String;
Function  LongLo(InNum: LongInt): Word;
Function  LongHi(InNum: LongInt): Word;
Function  shAssign(Var F: File; FName: String): Boolean;
Function  shLock(Var F; LockStart,LockLength: LongInt): Word;
Function  shUNLock(Var F; LockStart,LockLength: LongInt): Word;
Procedure FlushFile(Var F);
Function  shReset(Var F: File; RecSize: Word): Boolean;
Function  shReWrite(Var F: File; RecSize: Word): Boolean;
Function  shRead(Var F:File; Var Rec; ReadSize: Integer; Var NumRead: Integer): Boolean;
Function  shWrite(Var F: File; Var Rec; ReadSize: Integer): Boolean;
Function  shOpenFile(Var F: File; PathName: String): Boolean;
Function  shMakeFile(Var F: File; PathName: String): Boolean;
Procedure shCloseFile(Var F: File);
Procedure shEraseFile(Var F: File);
Function  shSeekFile(Var F: File; FPos: LongInt): Boolean;
Function  shFindFile(Pathname: String; Var Name: String; Var Size, Time: LongInt): Boolean;
Procedure shSetFTime(Var F: File; Time: LongInt);
Function  GetCurrentPath: String;
Procedure CleanDir(FileDir: String);
Function  IsDevice(FilePath: String): Boolean;
Function  LoadFilePos(FN: String; Var Rec; FS: Word; FPos: LongInt): Word;
Function  LoadFile(FN: String; Var Rec; FS: Word): Word;
Function  SaveFilePos(FN: String; Var Rec; FS: Word; FPos: LongInt): Word;
Function  SaveFile(FN: String; Var Rec; FS: Word): Word;
Function  ExtendFile(FN: String; ToSize: LongInt): Word;
Function  CreateTempDir(FN: String): String;
Function  GetTempName(FN: String): String;
Function  GetTextPos(Var F: Text): LongInt;
Function  FindOnPath(FN: String; Var OutName: String): Boolean;
Function  CopyFile(FN1: String; FN2: String): Boolean;
Function  EraseFile(FN: String): Boolean;
Function  MakePath(FP: String): Boolean;
Function  DirExist(FName:String):Boolean;

Implementation

Uses MkString32;

Var
   DosError:Integer;

Function GetEnv(Str:string):String;
Var
   LpBuffer:PChar;
   Rtn:Integer;

Begin
   LpBuffer:=StrAlloc(1024);
   StrPCopy(LpBuffer,Str);
   Rtn:=GetEnvironmentVariable(LpBuffer,LpBuffer,1024);
   If Rtn>0 then Result:=StrPas(LpBuffer)
   Else Result:='';
   StrDispose(LpBuffer);
End;

Function FExpand(Str:String):String;
Begin
   FExpand:=ExpandFileName(Str);
End;

Procedure FSplit(Path: String; Var Dir,Name,Ext:String);
Begin
   Dir:=WithBackSlash(ExtractFileDir(Path));
   Name:=ExtractFileName(Path);
   Ext:=ExtractFilePath(Path);
End;

Function  FSearch(Path: String; DirList: String): String;
Begin
   FSearch:=FileSearch(Path,DirList);
End;

Procedure FindObj.Init;
Begin
   New(FI);
   FI^.DError := 1;
End;

Procedure FindObj.Done;
Begin
   Dispose(FI);
End;

Procedure FindObj.FFirst(FN: String);
Begin
   FN := FExpand(FN);
   FSplit(FN, FI^.Dir, FI^.Name, FI^.Ext);
   FI^.DError:=FindFirst(FN, faArchive + faReadOnly, FI^.SRec);
End;

Function  FindObj.GetName: String;
Begin
   If Found Then GetName:=FI^.SRec.Name
   Else GetName := '';
End;

Function FindObj.GetFullPath: String;
Begin
   GetFullPath:=FI^.Dir+GetName;
End;

Function  FindObj.GetSize: LongInt;
Begin
  If Found Then GetSize:=FI^.SRec.Size
  Else GetSize:=0;
End;

Function  FindObj.GetDate: LongInt;
Begin
   If Found Then GetDate := FI^.SRec.Time
   Else GetDate := 0;
End;

Procedure FindObj.FNext;
Begin
   FI^.DError:=FindNext(FI^.SRec);
End;

Procedure FindObj.FDone;
Begin
   FindClose(FI^.SRec);
End;

Function FindObj.Found: Boolean;
Begin
   Found:=(FI^.DError=0);
End;

Function shAssign(Var F: File; FName: String): Boolean;
Begin
   AssignFile(F,FName);
   MKFileError:=0; {duh!}
   shAssign:=True;
End;

Function shRead(Var F: File; Var Rec; ReadSize: Integer; Var NumRead: Integer): Boolean;
Var
    Count: Word;
    Code: Word;

Begin
   If IOResult<>0 then ;
   Count:=Tries;
   Code:=5;
   While ((Count>0) and (Code = 5)) Do Begin
      {$I-} BlockRead(F,Rec,ReadSize,NumRead); {$I+}
      Code:=IoResult;
      Dec(Count);
   End;
   MKFileError:=Code;
   ShRead:=(Code=0);
End;

Function shWrite(Var F: File; Var Rec; ReadSize: Integer): Boolean;
Var
   Count: Word;
   Code: Word;

Begin
   IF IOResult<>0 then ;
   Count := Tries;
   Code := 5;
   While ((Count > 0) and (Code = 5)) Do Begin
      {$I-} BlockWrite(F,Rec,ReadSize); {$I+}
      Code := IoResult;
      Dec(Count);
   End;
   MKFileError := Code;
   shWrite := (Code = 0);
End;

Procedure CleanDir(FileDir:String);
Var
   SR:TSearchRec;

Begin
   AddBackSlash(FileDir);
   DosError:=FindFirst(FileDir+'*.*',faReadOnly+faArchive,SR);
   While DosError=0 Do Begin
      DeleteFile(StrPCopy('',FileDir+SR.Name));
      DosError:=FindNext(SR);
   End;
   FindClose(SR);
End;

Function GetCurrentPath: String;
Begin
   GetCurrentPath:=WithBackSlash(GetCurrentDir);
End;

procedure Delay(msecs:integer);
var
   FirstTickCount:longint;
begin
   FirstTickCount:=GetTickCount;
   repeat
      Application.ProcessMessages; {allowing access to other
                                    controls, etc.}
   until ((GetTickCount-FirstTickCount) >= Longint(msecs));
end;

Function shLock(Var F; LockStart,LockLength: LongInt): Word;
Var
  Count: Word;
  Code: Word;
  TmpLong:Longint;

Begin
   Count := Tries;
   Code := $21;
   TmpLong:=TFilerec(F).Handle;
   While ((Count > 0) and (Code = $21)) Do Begin
      If Not LockFile(TmpLong,LockStart,0,LockLength,0) then Begin
         Delay(TryDelay);
         Dec(Count);
      End
      Else Code:=0;
   End;
   If Code = 1 Then Code := 0;
   MKFileError:=Code;
   shLock := Code;
End;

Function shUNLock(Var F; LockStart,LockLength: LongInt): Word;
Var
  Count: Word;
  Code: Word;
  TmpLong:Longint;

Begin
   Count := Tries;
   Code := $21;
   TmpLong:=TFilerec(F).Handle;
   While ((Count > 0) and (Code = $21)) Do Begin
      If Not UNLockFile(TmpLong,LockStart,0,LockLength,0) then Begin
         Delay(TryDelay);
         Dec(Count);
      End
      Else Code:=0;
   End;
   If Code = 1 Then Code := 0;
   MKFileError:=Code;
   shUNLock := Code;
End;

Function shReset(Var F: File; RecSize: Word): Boolean;
Var
   Count: Word;
   Code: Word;

Begin
  If IOResult<>0 then ;
  Count := Tries;
  Code := 5;
   While ((Count > 0) and (Code = 5)) Do Begin
      {$I-} Reset(F,RecSize); {$I+}
      Code := IoResult;
      Dec(Count);
   End;
   MKFileError := Code;
   ShReset := (Code = 0);
End;

Function shReWrite(Var F: File; RecSize: Word): Boolean;
Var
   Count: Word;
   Code: Word;

Begin
  If IOResult<>0 then ;
  Count := Tries;
  Code := 5;
   While ((Count > 0) and (Code = 5)) Do Begin
      {$I-} ReWrite(F,RecSize); {$I+}
      Code := IoResult;
      Dec(Count);
   End;
   MKFileError := Code;
   ShReWrite := (Code = 0);
End;


Procedure FlushFile(Var F); {Dupe file handle, close dupe handle}
Begin
   Flush(TextFile(F));
   MKFileError:=0;
End;

Function LongLo(InNum: LongInt): Word;
Begin
   LongLo := InNum and $FFFF;
End;

Function LongHi(InNum: LongInt): Word;
Begin
   LongHi := InNum Shr 16;
End;

Function SizeFile(FName: String):LongInt;
Var
  SR: TSearchRec;

Begin
  DosError:=FindFirst(FName,faAnyFile,SR);
  If DosError=0 Then SizeFile := SR.Size
  Else SizeFile:=-1;
  MKFileError:=DosError;
  FindClose(SR);
End;

Function  DateFile(FName: String): LongInt;
Var
    SR: TSearchRec;

Begin
   DosError:=FindFirst(FName,faAnyFile,SR);
   If DosError=0 Then DateFile:=SR.Time
   Else DateFile:=0;
   MKFileError:=DosError;
   FindClose(SR);
End;

Function DirExist(FName: String): Boolean;
Var
   SR: TSearchRec;

Begin
   if (length(FName)>1) and (FName[length(FName)] in ['\','/']) then Copy(FName,1,Length(FName)-1);
   DirExist:=FindFirst(FName+'.',faReadOnly+faHidden+faArchive+faDirectory,SR)=0;
   FindClose(SR);
End;

Function FileExist(FName: String): Boolean;
Begin
   FileExist:=FileExists(FName);
End;

Function FindPath(FileName: String):String;
Begin
   FindPath := FileName;
   If FileExist(FileName) Then FindPath:=FExpand(FileName)
   Else FindPath:=FExpand(FSearch(FileName,GetEnv('PATH')));
End;

Procedure TFile32.BufferRead;
  Begin
  TF^.BufferStart := FilePos(TF^.BufferFile);
  if Not shRead (TF^.BufferFile,TF^.MsgBuffer^ , TF^.BufferSize, TF^.BufferChars) Then
    TF^.BufferChars := 0;
  TF^.BufferPtr := 1;
  End;


Function TFile32.GetChar: Char;
  Begin
  If TF^.BufferPtr > TF^.BufferChars Then
    BufferRead;
  If TF^.BufferChars > 0 Then
    GetChar := TF^.MsgBuffer^[TF^.BufferPtr]
  Else
    GetChar := #0;
  Inc(TF^.BufferPtr);
  If TF^.BufferPtr > TF^.BufferChars Then
    BufferRead;
  End;


Function TFile32.GetString: String;

  Var
    TempStr: String;
    GDone: Boolean;
    Ch: Char;

  Begin
    TempStr := '';
    GDone := False;
    TF^.StringFound := False;
    While Not GDone Do
      Begin
      Ch := GetChar;
      Case Ch Of
        #0:  If TF^.BufferChars = 0 Then
               GDone := True
             Else
               Begin

               TempStr:=TempStr+Ch;
               TF^.StringFound := True;
               {the following not true in 32bit}
{               If Length(TempStr) = 255 Then GDone := True;}
               End;
        #10:;
        #26:;
        #13: Begin
             GDone := True;
             TF^.StringFound := True;
             End;
        Else
          Begin
            TempStr:=TempStr+Ch;
            TF^.StringFound := True;
            {following not valid in 32bit!}
{            If Length(TempStr) = 255 Then GDone := True;}
          End;
        End;
      End;
    GetString := TempStr;
  End;


Function TFile32.GetCString: String;

  Var
    TempStr: String;
    GDone: Boolean;
    Ch: Char;

  Begin
  TempStr := '';
  GDone := False;
  TF^.StringFound := False;
  While Not GDone Do
    Begin
    Ch := GetChar;
    Case Ch Of
      #0:  If TF^.BufferChars = 0 Then
             GDone := True
           Else
             Begin
             TF^.StringFound := True;
             End;
      Else
        Begin
        TempStr:=TempStr+Ch;
        TF^.StringFound := True;
        End;
      End;
    End;
  GetCString := TempStr;
  End;

Procedure  TFile32.GetBlock(Var Buf;NumToRead:Integer);
Var
   Loop:Integer;
   TmpStr:String;

Begin
   TmpStr:='';
   Loop:=0;
   While Loop<NumToRead do Begin
      TmpStr:=TmpStr+GetChar;
      Inc(Loop);
   End;
   Move(TmpStr[1],Buf,NumToRead);
   TF^.StringFound:=True;
End;

Function TFile32.GetUString:String;
  Var
    TempStr: String;
    GDone: Boolean;
    Ch: Char;

  Begin
  TempStr := '';
  GDone := False;
  TF^.StringFound := False;
  While Not GDone Do Begin
    Ch := GetChar;
    Case Ch Of
      #0:  If TF^.BufferChars=0 Then
             GDone:=True
           Else
             Begin
             TempStr:=TempStr+Ch;
             TF^.StringFound := True;
             {the following not valid in 32bit}
{             If Length(TempStr) = 255 Then GDone := True;}
             End;
      #13:;
      #26:;
      #10: Begin
           GDone := True;
           TF^.StringFound := True;
           End;
      Else
        Begin
        TempStr:=TempStr+Ch;
        TF^.StringFound := True;
        {the following not true in 32bit}
{        If Length(TempStr) = 255 Then GDone := True;}
        End;
      End;
    End;
  GetUString := TempStr;
  End;


Function TFile32.OpenTextFile(FilePath: String): Boolean;
  Begin
  If Not shAssign(TF^.BufferFile,FilePath) Then;
  FileMode := fmReadOnly + fmDenyNone;
  If Not shReset(TF^.BufferFile,1) Then
    OpenTextFile := False
  Else
    Begin
    BufferRead;
    If TF^.BufferChars > 0 Then
      TF^.StringFound := True
    Else
      TF^.StringFound := False;
    OpenTextFile := True;
    End;
  End;


Function TFile32.SeekTextFile(SeekPos: LongInt): Boolean;
  Begin
  TF^.Error := 0;
  If ((SeekPos < TF^.BufferStart) Or (SeekPos > TF^.BufferStart + TF^.BufferChars)) Then
    Begin
    {$I-} Seek(TF^.BufferFile, SeekPos); {$I+}
    TF^.Error := IoResult;
    BufferRead;
    End
  Else
    Begin
    TF^.BufferPtr := SeekPos + 1 - TF^.BufferStart;
    End;
  SeekTextFile := (TF^.Error = 0);
  End;


Function TFile32.GetTextPos: LongInt;       {Get text file position}
  Begin
  GetTextPos := TF^.BufferStart + TF^.BufferPtr - 1;
  End;


Function TFile32.Restart: Boolean;
  Begin
  Restart := SeekTextFile(0);
  End;


Function TFile32.CloseTextFile: Boolean;
  Begin
  {$I-} CloseFile(TF^.BufferFile); {$I+}
  CloseTextFile := (IoResult = 0);
  End;


Procedure TFile32.SetBufferSize(BSize: Word);
  Begin
  FreeMem(TF^.MsgBuffer, TF^.BufferSize);
  TF^.BufferSize := BSize;
  GetMem(TF^.MsgBuffer, TF^.BufferSize);
  TF^.BufferChars := 0;
  TF^.BufferStart := 0;
  If SeekTextFile(GetTextPos) Then;
  End;


Procedure TFile32.Init;
  Begin
  New(TF);
  TF^.BufferSize := 2048;
  GetMem(TF^.MsgBuffer, TF^.BufferSize);
  End;

Procedure TFile32.Done;
  Begin
  {$I-} CloseFile(TF^.BufferFile); {$I+}
  If IoResult <> 0 Then;
  FreeMem(TF^.MsgBuffer, TF^.BufferSize);
  Dispose(TF);
  End;

Function TFile32.StringFound: Boolean;
  Begin
  StringFound := TF^.StringFound;
  End;

Function  shOpenFile(Var F: File; PathName: String): Boolean;
Begin
   shAssign(F,PathName);
   FileMode:=fmReadWrite+fmDenyNone;
   shOpenFile:=shReset(f,1);
End;

Function  shMakeFile(Var F: File; PathName: String): Boolean;
Begin
   shAssign(F,PathName);
   FileMode:=fmReadWrite+fmDenyNone;
   shMakeFile:=shRewrite(f,1);
END;

Procedure shCloseFile(Var F: File);
Begin
   If (IOresult <> 0) Then;
   {$I-} CloseFile(F); {$I+}
   MKFileError:=IOResult;
End;

Procedure shEraseFile(Var F: File);
Begin
   If (IOresult <> 0) Then;
   {$I-} Erase(F); {$I+}
   MKFileError:=IOResult;
End;


Function  shSeekFile(Var F: File; FPos: LongInt): Boolean;
Begin
   If IOResult=0 then ;
   {$I-} Seek(F,FPos); {$I+}
   MKFileError:=IOResult;
   shSeekFile := (MKFileError = 0);
End;


Function  shFindFile(Pathname: String; Var Name: String; Var Size, Time: LongInt): Boolean;
Var
   SR: TSearchRec;

Begin
   DosError:=FindFirst(PathName, faArchive, SR);
   If (DosError = 0) Then Begin
      shFindFile := True;
      Name := Sr.Name;
      Size := Sr.Size;
      Time := Sr.Time;
   End
   Else Begin
      shFindFile := False;
   End;
   FindClose(SR);
End;

Procedure shSetFTime(Var F: File; Time: LongInt);
Begin
   FileSetDate(TFileRec(F).Handle,Time);
End;

Function IsDevice(FilePath: String): Boolean;
Begin
   IsDevice:=False; {Expand this later!}
End;

Function LoadFile(FN: String; Var Rec; FS: Word): Word;
Begin
   LoadFile := LoadFilePos(FN, Rec, FS, 0);
End;

Function LoadFilePos(FN: String; Var Rec; FS: Word; FPos: LongInt): Word;
Var
   F: File;
   Error: Word;
   NumRead:Integer;

Begin
  Error := 0;
  If Not FileExist(FN) Then Error := 8888;
  If Error = 0 Then Begin
    If Not shAssign(F, FN) Then Error := MKFileError;
  End;
  FileMode := fmReadOnly + fmDenyNone;
  If Not shReset(F,1) Then Error := MKFileError;
  If Error = 0 Then Begin
    {$I-} Seek(F, FPos); {$I+}
    Error := IoResult;
  End;
  If Error = 0 Then
    If Not shRead(F, Rec, FS, NumRead) Then
      Error := MKFileError;
  If Error = 0 Then
    Begin
    {$I-} CloseFile(F); {$I+}
    Error := IoResult;
    End;
  LoadFilePos := Error;
  End;


Function SaveFile(FN: String; Var Rec; FS: Word): Word;
   Begin
   SaveFile := SaveFilePos(FN, Rec, FS, 0);
   End;

Function SaveFilePos(FN: String; Var Rec; FS: Word; FPos: LongInt): Word;
  Var
    F: File;
    Error: Word;

  Begin
  Error := 0;
  If Not shAssign(F, FN) Then
    Error := MKFileError;
  FileMode := fmReadWrite + fmDenyNone;
  If FileExist(FN) Then
    Begin
    If Not shReset(F,1) Then
      Error := MKFileError;
    End
  Else
    Begin
    {$I-} ReWrite(F,1); {$I+}
    Error := IoResult;
    End;
  If Error = 0 Then
    Begin
    {$I-} Seek(F, FPos); {$I+}
    Error := IoResult;
    End;
  If Error = 0 Then
    If FS > 0 Then
      Begin
      If Not shWrite(F, Rec, FS) Then
        Error := MKFileError;
      End;
  If Error = 0 Then
    Begin
    {$I-} CloseFile(F); {$I+}
    Error := IoResult;
    End;
  SaveFilePos := Error;
  End;

Function ExtendFile(FN: String; ToSize: LongInt): Word;
{Pads file with nulls to specified size}
  Type
    FillType = Array[1..8000] of Byte;

  Var
    F: File;
    Error: Word;
    FillRec: ^FillType;

  Begin
  Error := 0;
  New(FillRec);
  If FillRec = Nil Then
    Error := 10;
  If Error = 0 Then
    Begin
    FillChar(FillRec^, SizeOf(FillRec^), 0);
    If Not shAssign(F, FN) Then
    Error := MKFileError;
    FileMode := fmReadWrite + fmDenyNone;
    If FileExist(FN) Then
      Begin
      If Not shReset(F,1) Then
        Error := MKFileError;
      End
    Else
      Begin
      {$I-} ReWrite(F,1); {$I+}
      Error := IoResult;
      End;
    End;
  If Error = 0 Then
    Begin
    {$I-} Seek(F, FileSize(F)); {$I+}
    Error := IoResult;
    End;
  If Error = 0 Then
    Begin
    While ((FileSize(F) < (ToSize - SizeOf(FillRec^))) and (Error = 0)) Do
      Begin
      If Not shWrite(F, FillRec^, SizeOf(FillRec^)) Then
        Error := MKFileError;
      End;
    End;
  If ((Error = 0) and (FileSize(F) < ToSize)) Then
    Begin
    If Not shWrite(F, FillRec^, ToSize - FileSize(F)) Then
      Error := MKFileError;
    End;
  If Error = 0 Then
    Begin
    {$I-} CloseFile(F); {$I+}
    Error := IoResult;
    End;
  Dispose(FillRec);
  ExtendFile := Error;
  End;


Function  CreateTempDir(FN: String): String;
Var
   S:String;

Begin
   S:=WithBackSlash(GetTempName(FN));
   ForceDirectories(S);
   CreateTempDir:=S;
End;

Function  GetTempName(FN: String): String;
Var
   S:String;
Begin
   S:=FN+'TEMP'+IntToStr(Random(1234))+'.$$$';
   While FileExists(S) do S:=FN+'TEMP'+IntToStr(Random(1234))+'.$$$';
   GetTempName:=S;
End;

Function  GetTextPos(Var F: Text): LongInt;
Begin
   {todo}
End;
(*  Type WordRec = Record
    LongLo: Word;
    LongHi: Word;
    End;

  Var
   {$IFDEF WINDOWS}
   TR: TTextRec Absolute F;
   {$ELSE}
   TR: TextRec Absolute F;
   {$ENDIF}
   Tmp: LongInt;
   Handle: Word;
   {$IFNDEF BASMINT}
     {$IFDEF WINDOWS}
     Regs: TRegisters;
     {$ELSE}
     Regs: Registers;
     {$ENDIF}
   {$ENDIF}

  Begin
  Handle := TR.Handle;
  {$IFDEF BASMINT}
  Asm
    Mov ah, $42;
    Mov al, $01;
    Mov bx, Handle;
    Mov cx, 0;
    Mov dx, 0;
    Int $21;
    Jnc @TP2;
    Mov ax, $ffff;
    Mov dx, $ffff;
    @TP2:
    Mov WordRec(Tmp).LongLo, ax;
    Mov WordRec(Tmp).LongHi, dx;
    End;
  {$ELSE}
  Regs.ah := $42;
  Regs.al := $01;
  Regs.bx := Handle;
  Regs.cx := 0;
  Regs.dx := 0;
  MsDos(Regs);
  If (Regs.Flags and 1) <> 0 Then
    Begin
    Regs.ax := $ffff;
    Regs.dx := $ffff;
    End;
  WordRec(Tmp).LongLo := Regs.Ax;
  WordRec(Tmp).LongHi := Regs.Dx;
  {$ENDIF}
  If Tmp >= 0 Then
    Inc(Tmp, TR.BufPos);
  GetTextPos := Tmp;
  End; *)


Function FindOnPath(FN: String; Var OutName: String): Boolean;
  Var
    TmpStr: String;

  Begin
  If FileExist(FN) Then
    Begin
    OutName := FExpand(FN);
    FindOnPath := True;
    End
  Else
    Begin
    TmpStr := FSearch(FN, GetEnv('Path'));
    If FileExist(TmpStr) Then
      Begin
      OutName := TmpStr;
      FindOnPath := True;
      End
    Else
      Begin
      OutName := FN;
      FindOnPath := False;
      End;
    End;
  End;


Function  CopyFile(FN1: String; FN2: String): Boolean;
  Type
    TmpBufType = Array[1..8192] of Byte;

  Var
    F1: File;
    F2: File;
    NumRead:Integer;
    Buf: ^TmpBufType;
    Error: Word;

  Begin
  New(Buf);
  AssignFile(F1, FN1);
  FileMode := fmReadOnly + fmDenyNone;
  {$I-} Reset(F1, 1); {$I+}
  Error := IoResult;
  If Error = 0 Then
    Begin
    AssignFile(F2, FN2);
    FileMode := fmReadWrite + fmDenyNone;
    {$I-} ReWrite(F2, 1); {$I+}
    Error := IoResult;
    End;
  If Error = 0 Then
    Begin
    {$I-} BlockRead(F1, Buf^, SizeOf(Buf^), NumRead); {$I+}
    Error := IoResult;
    While ((NumRead <> 0) and (Error = 0)) Do
      Begin
      {$I-} BlockWrite(F2, Buf^, NumRead); {$I+}
      Error := IoResult;
      If Error = 0 Then
        Begin
        {$I-} BlockRead(F1, Buf^, SizeOf(Buf^), NumRead); {$I+}
        Error := IoResult;
        End;
      End;
    End;
  If Error = 0 Then
    Begin
    {$I-} CloseFile(F1); {$I+}
    Error := IoResult;
    End;
  If Error = 0 Then
    Begin
    {$I-} CloseFile(F2); {$I+}
    Error := IoResult;
    End;
  Dispose(Buf);
  CopyFile := (Error = 0);
  End;


Function  EraseFile(FN: String): Boolean;
Begin
   EraseFile:=DeleteFile(FN);
End;


Function  MakePath(FP: String): Boolean;
Begin
   AddBackSlash(FP);
   ForceDirectories(FP);
   MakePath := DirExist(FP);
End;

End.
