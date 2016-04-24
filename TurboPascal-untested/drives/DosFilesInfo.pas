(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0063.PAS
  Description: DOS Files Info
  Author: SWAG SUPPORT TEAM
  Date: 01-27-94  17:38
*)

unit FileInfo;
(* FILEINFO scans DOS' "list of lists" to retrieve valuable file information.
   It does this by calling undocumented MSDOS call 52h.  It should be noted
   that this only works for DOS versions 2.0 and higher.  No error checking
   for this is performed.
*)
interface
uses
  dos;
type
  FileTblPtr     = ^FileTables;
  FileTables     = record
    Next:               FileTblPtr;
    NumFiles:           word;
    NumHandles:         byte;
  end;  { FileTables }
  ListofListsRec = record
    DOSDriveParamBlock: pointer;
    DOSFileTbl:         FileTblPtr;
    ClockDevice:        pointer;
    ConDevice:          pointer;
    MaxBytes:           word;
    DiskBuffer:         pointer;
    SubDirectory:       pointer;
    FCBTable:           pointer;
    FCBsProtected:      word;
    NumBlocks:          byte;
    LastDrive:          byte;
  end;  { ListofLists }
  DOSFilesObj = object
    ListOfLists : ^ListofListsRec;
    constructor Init;
    function    LastDrive   : char;
    function    FilesUsed   : integer;
    function    ConfigFiles : integer;
  end;  { ConfigObj }

implementation

constructor DOSFilesObj.Init;
var
  regs:   registers;
begin
  regs.ah := $52;
  MsDos(regs);       { call undocumented function 52h                    }
                     { returns pointer to list of lists @Regs.ES,Regs.BX }
  ListofLists := Ptr(regs.ES,regs.BX);
end;  { DOSFilesObj.Init }

function DOSFilesObj.LastDrive : char;
begin
  LastDrive   := Char(ListofLists^.LastDrive+64);
end;  { DOSFilesObj.LastDrive }

function DOSFilesObj.FilesUsed : integer;
var
  n:   integer;
  p:   FileTblPtr;
begin
  n := 0;
  p := ListOfLists^.DOSFileTbl;
  while ofs(p^)<>$FFFF do
  begin
    inc(n,p^.NumHandles);
    p := p^.Next;
  end;  { while }
  FilesUsed := n;
end;  { DOSFilesObj.FilesUsed }

function DOSFilesObj.ConfigFiles : integer;
var
  n:   integer;
  p:   FileTblPtr;
begin
  n := 0;
  p := ListOfLists^.DOSFileTbl;
  while ofs(p^)<>$FFFF do
  begin
    inc(n,p^.NumFiles);
    p := p^.Next;
  end;  { while }
  ConfigFiles := n;
end;  { DOSFilesObj.ConfigFiles }

end.  { FileInfo }

{--------------     DEMO ------------------ }

program filetest;
uses fileinfo;
var
  DOSFiles : DOSFilesObj;
begin
  DOSFiles.Init;
  Writeln('LASTDRIVE=',DOSFiles.LastDrive);
  Writeln('DOS FILES USED=',DOSFiles.FilesUsed);
  Writeln('DOS FILES=',DOSFiles.ConfigFiles);
end.  { FileInfo }
