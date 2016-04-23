
unit HomeBase;
{ 
  After unit initialization, the variable 
  Dir contains the path to the directory 
  where the executable is located. 
} 
interface 
uses 
  DOS; 
const 
  AppName = 'MyProg'; 
function IniFileName: PathStr; 
function LogFileName: PathStr; 
{ 
  etc.  All name conventions reside in 
  this unit. 
} 
var 
  Dir : DirStr; 
  Name: NameStr; 
  Ext : ExtStr; 
implementation 
function IniFileName: PathStr; 
  begin 
    IniFileName := Dir + AppName + '.INI'; 
  end; 
function LogFileName: PathStr; 
  begin 
    LogFileName := Dir + AppName + '.LOG'; 
  end; 
begin {unit init} 
{ 
  ParamStr(0) returns the path and file 
  name of the executing program 
  (for example, C:\BP\MYPROG.EXE). 
} 
  fSplit(ParamStr(0), Dir, Name, Ext); 
{ 
  Just in case execution is from the 
  current directory and ChDir(Elsewhere) 
  is used later. 
} 
  if Dir = '' then 
  begin 
    GetDir(0, Dir); 
    Dir := Dir + '\'; 
  end; 
end.

{ ---------------------------    DEMO  ------------------------------ }

program HomeDemo;
uses
  HomeBase;
begin
  WriteLn(HomeBase.Dir);
  WriteLn(HomeBase.IniFileName);
  WriteLn(HomeBase.LogFileName);
end.