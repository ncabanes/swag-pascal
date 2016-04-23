Unit Fmanage;
{=========================================================}
{ A TP unit containing some basic file handling routines. }
{                                                         }
{ Fmanage has been checked on TP 6.0, but may work on     }
{ other versions as well.                                 }
{=========================================================}


Interface

Var
  FileNameSet: set of char;
  { A character set containing all characters valid in DOS file names. }

function  IsDirName(DirName: string): boolean;
{================================================================}
{ Returns TRUE if DirName is a valid (not necessarily existing!) }
{ directory string.                                              }
{================================================================}

function  IsFileName(FileName: string): boolean;
{=================================================================}
{ Returns TRUE if FileName is a valid (not necessarily existing!) }
{ file name string.                                               }
{=================================================================}

function  FileExist(FileName: string): Boolean;
{==================================}
{ Returns TRUE if FileName exists. }
{==================================}

function  TextFileSize(FileName: String): LongInt;
{======================================================}
{ Returns the size in bytes of the text file FileName. }
{======================================================}

procedure Fdel(FileName: string; Var ErrCode: byte);
{===================================================================}
{ Deletes the file FileName. ErrCode returns the standard DOS error }
{ codes if unsuccessful.                                            }
{===================================================================}

procedure Frename(SourceFile,TargetFile: string; Var ErrCode: byte);
{===============================================================}
{ Rename the file SourceName to TargetName. ErrCode returns the }
{ standard DOS error codes if unsuccessful.                     }
{===============================================================}

procedure Unique(Path: String; Var FileName: String);
{==============================================================}
{ Return a unique file name in the directory Path. FileName is }
{ empty if unsuccessful.                                       }
{===============================================================}


Implementation

Uses Dos;

Function IsDirName(DirName: string): boolean;
Var
  i: byte;
  ch: char;
  ok: boolean;
begin                              { IsDirName }
  ok:=true; ch:=DirName[1];
  if Pos(':',DirName)>0 then ok:=(ch in ['A'..'Z','a'..'z']);
  if ok and (Pos(':',DirName)>2) then ok:=false;
  if ok and (Pos(':',DirName)=2) then
  begin
    Delete(DirName,1,2);
    if Pos(':',DirName)>0 then ok:=false;
  end;
  if ok then
  for i:=1 to length(DirName) do
  begin
    ch:=DirName[i];
    if not (ch in FileNameSet) then ok:=false;
  end;
  IsDirName:=ok;
end;                               { IsDirName }

Function IsFileName(FileName: string): boolean;
Var
  i: byte;
  ch: char;
  ok: boolean;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  tmp: string;
begin                                 { IsFileName }
  ok:=true;
  Fsplit(FileName,Dir,Name,Ext);
  if Name='' then
  begin
    IsFileName:=false;
    Exit;
  end;
  ok:=IsDirName(Dir);
  if ok then
  for i:=1 to length(Name) do
  begin
    ch:=Name[i];
    if not (ch in FileNameSet-[':']) then ok:=false;
  end;
  if ok then
  begin
    if (length(Ext)>0) and (Ext[length(Ext)]='.') then
    begin
      tmp:=Ext; Delete(tmp,length(tmp),1); Ext:=tmp;
    end;
    if Ext[1]='.' then
      for i:=2 to length(Ext) do
      begin
        ch:=Ext[i];
        if not (ch in FileNameSet-[':','.','\']) then ok:=false;
      end
    else if length(Ext)>0 then ok:=false;
  end;
  isfilename:=ok;
end;                                  { IsFileName }

function FileExist(FileName: string): Boolean;
Var
  tmpfile: Text;
  Attrib: Word;
begin                          { FileExist }
  if FileName='' then
  begin
    FileExist:=false; Exit;
  end;
  assign(tmpfile,FileName);
  GetFAttr(tmpfile,Attrib);
  FileExist:=(DosError=0);
end;                            { FileExist }

Function TextFileSize(FileName: String): LongInt;
var
  Attrib: Word;
  Sr: SearchRec;
begin
  if IsFileName(FileName) then
  begin
    FindFirst(FileName,AnyFile and (not (sysfile or Directory)),Sr);
    if DosError=0 then TextFileSize:=Sr.size
    else TextFileSize:=-1;
  end else TextFileSize:=-1;
end;

procedure Fdel(FileName: string; Var ErrCode: byte);
var
  reg: registers;
begin                                   { Fdel }
  FileName:=concat(FileName,#0);
  reg.ds:=Seg(FileName[1]); reg.dx:=Ofs(FileName[1]);
  reg.ah:=$41;
  MsDos(reg);
  ErrCode:=0;
  if (reg.flags AND FCarry)=1 then ErrCode:=reg.ax;
end;                                    { Fdel }

procedure Frename(SourceFile,TargetFile: string; Var ErrCode: byte);
var
  reg: registers;
begin                                   { Frename }
  SourceFile:=concat(SourceFile,#0);
  TargetFile:=concat(TargetFile,#0);
  reg.ds:=Seg(SourceFile[1]); reg.dx:=Ofs(SourceFile[1]);
  reg.es:=Seg(TargetFile[1]); reg.di:=Ofs(TargetFile[1]);
  reg.ah:=$56;
  MsDos(reg);
  ErrCode:=0;
  if (reg.flags AND FCarry)=1 then ErrCode:=reg.ax;
end;                                    { Frename }

Procedure Unique(Path: String; Var FileName: String);
Var
  reg: Registers;
  i: integer;
  ErrCode: Byte;
begin                                      { Unique }
  FileName:='';
  if Path='' then Exit;
  for i:=1 to 15 do Path:=concat(Path,#0);
  reg.ds:=Seg(Path[1]); reg.dx:=Ofs(Path[1]);
  reg.cx:=0;
  reg.ah:=$5A;
  MsDos(reg);
  ErrCode:=0;
  if (reg.flags AND FCarry)=1 then ErrCode:=reg.ax;
  if ErrCode=0 then
  begin
    FileName:=Path;
    i:=1;
    while (i<length(FileName)) and (FileName[i]<>#0) do Inc(i);
    if FileName[i]=#0 then Delete(FileName,i,length(FileName)-i+1);
    {
      Now delete the zero length file created by DOS
    }
    reg.ds:=Seg(Path[1]); reg.dx:=Ofs(Path[1]);
    reg.ah:=$3E;
    reg.bx:=reg.ax;
    MsDos(reg);
  end;
end;                                      { Unique }

begin
  FileNameSet:=['!','#'..')',#45,#46,'0'..':','@'..'Z','\','`'..#123,
                #125,'~','_'];
end.
