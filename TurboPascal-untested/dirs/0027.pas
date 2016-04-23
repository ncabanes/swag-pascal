
{ Updated DIRS.SWG on February 15, 1994 }

Unit PDir;

(*

   Palcic Directory Routines
   Copyright (C) 1989, Matthew J. Palcic
   Requires Turbo Pascal 5.5 or higher

   v1.0, 18 Aug 89 - Original release.

*)


INTERFACE

uses Dos,Objects;

(*------------------------------------------------------------------------*)

TYPE

  AttrType = Byte;
  FileStr = String[12];

  BaseEntryPtr = ^BaseEntry;
  BaseEntry = object(Node)
    Attr: AttrType;
    Time: Longint;
    Size: Longint;
    Name: FileStr;
    constructor Init;
    destructor Done; virtual;
    procedure ConvertRec(S:SearchRec);
    function FileName: FileStr; virtual;
    function FileExt: ExtStr; virtual;
    function FullName: PathStr; virtual;
    function FileTime: Longint; virtual;
    function FileAttr: AttrType; virtual;
    function FileSize: Longint; virtual;
    function IsDirectory: Boolean;
    constructor Load(var S: Stream);
    procedure Store(var S: Stream); virtual;
    end;

  FileEntryPtr = ^FileEntry;
  FileEntry = object(BaseEntry)
    constructor Init;
    destructor Done; virtual;
    procedure ForceExt(E:ExtStr);
    procedure ChangeName(P:PathStr); virtual;
     (* Change the name in memory *)
    procedure ChangePath(P:PathStr); virtual;
    procedure ChangeTime(T:Longint); virtual;
    procedure ChangeAttr(A:AttrType); virtual;
    procedure Erase; virtual;
    function Rename(NewName:PathStr): Boolean; virtual;
     (* Physically rename file on disk, returns False if Rename fails *)
    function ResetTime: Boolean;
    function ResetAttr: Boolean;
    function SetTime(T:Longint): Boolean; virtual;
    function SetAttr(A:AttrType): Boolean; virtual;
    constructor Load(var S: Stream);
    procedure Store(var S: Stream); virtual;
    end;

  DirEntryPtr = ^DirEntry;
  DirEntry = object(FileEntry)
    DirEntries: List;
    constructor Init;
    constructor Clear;
    destructor Done; virtual;
    procedure FindFiles(FileSpec: FileStr; Attrib: AttrType);
    procedure FindDirectories(FileSpec: FileStr; Attrib: AttrType);
    constructor Load(var S: Stream);
    procedure Store(var S: Stream); virtual;
    end;

  DirStream = object(DosStream)
    procedure RegisterTypes; virtual;
    end;

function ExtensionPos(FName : PathStr): Word;
function CurDir: PathStr;
function ReadString(var S: Stream): String;
procedure WriteString(var S: Stream; Str: String);

(*------------------------------------------------------------------------*)

IMPLEMENTATION

  (*--------------------------------------------------------------------*)
  (* Methods for BaseEntry                                               *)
  (*--------------------------------------------------------------------*)

  constructor BaseEntry.Init;
    begin
    end;

  destructor BaseEntry.Done;
    begin
    end;

  procedure BaseEntry.ConvertRec;
    begin
    Name := S.Name;
    Size := S.Size;
    Time := S.Time;
    Attr := S.Attr;
    end;

  function BaseEntry.FileName;
    begin
    FileName := Name;
    end;

  function BaseEntry.FullName;
    begin
    FullName := Name;
    end;

  function BaseEntry.FileExt;
    var
      ep: word;
    begin
    ep := ExtensionPos(Name);
    if ep > 0 then
      FileExt := Copy(Name, Succ(ep), 3)
    else
      FileExt[0] := #0;
  end;


  function BaseEntry.FileAttr;
    begin
    FileAttr := Attr;
    end;

  function BaseEntry.FileSize;
    begin
    FileSize := Size;
    end;

  function BaseEntry.FileTime;
    begin
    FileTime := Time;
    end;

  function BaseEntry.IsDirectory;
    begin
    IsDirectory := (FileAttr and Dos.Directory) = Dos.Directory;
    end;

  constructor BaseEntry.Load;
    begin
    S.Read(Attr,SizeOf(Attr));
    S.Read(Time,SizeOf(Time));
    S.Read(Size,SizeOf(Size));
    Name := ReadString(S);
    end;

  procedure BaseEntry.Store;
    begin
    S.Write(Attr,SizeOf(Attr));
    S.Write(Time,SizeOf(Time));
    S.Write(Size,SizeOf(Size));
    WriteString(S,Name);
    end;

  (*--------------------------------------------------------------------*)
  (* Methods for FileEntry                                              *)
  (*--------------------------------------------------------------------*)

  constructor FileEntry.Init;
    begin
    BaseEntry.Init; (* Call ancestor's Init *)
    Name := '';
    Size := 0;
    Time := $210000; (* Jan. 1 1980, 12:00a *)
    Attr := $00;  (* ReadOnly  = $01;
                     Hidden    = $02;
                     SysFile   = $04;
                     VolumeID  = $08;
                     Directory = $10;
                     Archive   = $20;
                     AnyFile   = $3F; *)
    end;

  destructor FileEntry.Done;
    begin
    BaseEntry.Done;
    end;

  function FileEntry.Rename;
    var
      F: File;
    begin
    Assign(F,FullName);
    System.Rename(F,NewName); (* Explicit call to 'System.Rename' avoid
                                 calling method 'FileEntry.Rename' *)
    if IOResult = 0 then
      begin
      ChangePath(NewName);
      Rename := True;
      end
    else
      Rename := False;
    end;

  procedure FileEntry.ForceExt;
    var
      ep: Word;
      TempBool: Boolean;
    begin
    ep := ExtensionPos(FullName);
    if ep > 0 then
      TempBool := Rename(Concat(Copy(FullName, 1, ep),FileExt))
    else
      TempBool := Rename(Concat(FullName,'.',FileExt));
    end;

  procedure FileEntry.ChangeName;
    begin
    Name := P;
    end;

  procedure FileEntry.ChangePath;
    begin
    Name := P;  (* FileEntry object does not handle path *)
    end;

  procedure FileEntry.ChangeTime;
    begin
    Time := T;
    end;

  procedure FileEntry.ChangeAttr;
    begin
    Attr := A;
    end;

  procedure FileEntry.Erase;
    var
      F:File;
    begin
    Assign(F,FullName);
    Reset(F);
    System.Erase(F); (* Remove ambiguity about 'Erase' call *)
    Close(F);
    end;

  function FileEntry.ResetTime;
    var
      F:File;
    begin
    Assign(F,FullName);
    Reset(F);
    SetFTime(F,FileTime);
    ResetTime := IOResult = 0;
    Close(F);
    end;

  function FileEntry.SetTime;
    var
      F:File;
    begin
    Assign(F,FullName);
    Reset(F);
    SetFTime(F,T);
    SetTime := IOResult = 0;
    Close(F);
    end;

  function FileEntry.ResetAttr;
    var
      F:File;
    begin
    Assign(F,FullName);
    SetFAttr(F,FileAttr);
    ResetAttr := IOResult = 0;
    end;

  function FileEntry.SetAttr;
    var
      F:File;
    begin
    ChangeAttr(A);
    SetAttr := ResetAttr;
    end;

  constructor FileEntry.Load;
    begin
    BaseEntry.Load(S);
    end;

  procedure FileEntry.Store;
    begin
    BaseEntry.Store(S);
    end;

  (*--------------------------------------------------------------------*)
  (* Methods for DirEntry                                               *)
  (*--------------------------------------------------------------------*)

  constructor DirEntry.Init;
    var
      TempNode: Node;
    begin
    FileEntry.Init;
    DirEntries.Delete;
    end;

  destructor DirEntry.Done;
    begin
    DirEntries.Delete;
    FileEntry.Done;
    end;

  constructor DirEntry.Clear;
    begin
    DirEntries.Clear;
    Init;
    end;

  procedure DirEntry.FindFiles;
    var
      DirInfo: SearchRec;
      TempFile: FileEntryPtr;
    begin
    FindFirst(FileSpec,Attrib,DirInfo);
    while (DosError = 0) do
      begin
      TempFile := New(FileEntryPtr,Init);
      TempFile^.ConvertRec(DirInfo);
      DirEntries.Append(TempFile);
      FindNext(DirInfo);
      end;
    end;

  procedure DirEntry.FindDirectories;
    var
      DirInfo: SearchRec;
      TempDir: DirEntryPtr;
    begin

    if FileSpec <> '' then
      FindFiles(FileSpec,Attrib and not Dos.Directory);

    FindFirst('*.*',Dos.Directory,DirInfo);
    while (DosError = 0) do
      begin
      if (DirInfo.Name[1] <> '.') and
         ((DirInfo.Attr and Dos.Directory) = Dos.Directory) then
         { if first character is '.' then name is either '.' or '..' }
        begin
        TempDir := New(DirEntryPtr,Clear);
        TempDir^.ConvertRec(DirInfo);
        DirEntries.Append(TempDir);
        end;
      FindNext(DirInfo);
      end;

    TempDir := DirEntryPtr(DirEntries.First);
    while TempDir <> nil do
      begin
      if TempDir^.IsDirectory then
        begin
        ChDir(TempDir^.FileName);
        TempDir^.FindDirectories(FileSpec,Attrib);
        ChDir('..');
        end;
      TempDir := DirEntryPtr(DirEntries.Next(TempDir));
      end;
    end;

  constructor DirEntry.Load;
    begin
    FileEntry.Load(S);
    DirEntries.Load(S);
    end;

  procedure DirEntry.Store;
    begin
    FileEntry.Store(S);
    DirEntries.Store(S);
    end;

  (*--------------------------------------------------------------------*)
  (* Methods for DirStream                                               *)
  (*--------------------------------------------------------------------*)

  procedure DirStream.RegisterTypes;
    begin
    DosStream.RegisterTypes;
    Register(TypeOf(BaseEntry),@BaseEntry.Store,@BaseEntry.Load);
    Register(TypeOf(FileEntry),@FileEntry.Store,@FileEntry.Load);
    Register(TypeOf(DirEntry),@DirEntry.Store,@DirEntry.Load);
    end;

(*---------------------------------------------------------------------*)
(*  Miscellaneous Unit procedures and functions                        *)
(*---------------------------------------------------------------------*)

function ExtensionPos;
  var
    Index: Word;
  begin
  Index := Length(FName)+1;
  repeat
    dec(Index);
    until (FName[Index] = '.') OR (Index = 0);
  IF (Pos('\', Copy(FName, Succ(Index), SizeOf(FName))) <> 0) THEN Index := 0;
  ExtensionPos := Index;
  end;

function CurDir;
  var
    P: PathStr;
  begin
  GetDir(0,P); { 0 = Current drive }
  CurDir := P;
  end;

function ReadString;
  var
    T: String;
    L: Byte;

  begin
  S.Read(L, 1);
  T[0] := Chr(L);
  S.Read(T[1], L);
  IF S.Status = 0 then
    ReadString := T
  else
    ReadString := '';
  end;

procedure WriteString;
  begin
  S.Write(Str, Length(Str) + 1);
  end;

(* No initialization code *)
end.

{===============================    DEMO ============================ }

program PDTest;

uses Objects,PDir,Dos;

var
  DP: DirEntryPtr;
  St: DirStream;
  Orig: PathStr;

procedure ProcessDir(D: DirEntryPtr; DirName: PathStr);
  var
    DirPtr : DirEntryPtr;
  begin
  DirPtr := DirEntryPtr(D^.DirEntries.First);
  while DirPtr <> nil do
    begin
    if DirPtr^.IsDirectory then
      ProcessDir(DirPtr,DirName+'\'+DirPtr^.FileName)
      {recursively process subdirectories}
    else
      WriteLn(DirName+'\'+DirPtr^.FileName);
    DirPtr := DirEntryPtr(D^.DirEntries.Next(DirPtr));
    end;
  end;



begin
Orig := CurDir;
WriteLn('Palcic''s File Finder v1.0');

if ParamCount = 0 then { Syntax is incorrect }
  begin
  WriteLn;
  WriteLn('Syntax: PFF filespec');
  WriteLn;
  WriteLn('Directory names can not be passed.');
  WriteLn;
  WriteLn('Example: PFF *.ZIP');
  WriteLn;
  Halt;
  end;

ChDir('C:\');
New(DP,Clear);

WriteLn;
Write('Scanning for ',ParamStr(1),'...');
DP^.FindDirectories(ParamStr(1),Archive);
WriteLn;
WriteLn;

ProcessDir(DP,'C:');

WriteLn;
WriteLn('Back to original directory ',Orig);
ChDir(Orig);

St.Init('PFF.DAT',SCreate);
DP^.Store(St);
St.Done;

Dispose(DP,Done);

end.
