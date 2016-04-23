
--------------------------------------------------------------------------------
It's easy enough to drag and drop your application to the Startup group to
make it run on Windows startup. But, if you wanted to do this
programmatically (at the end of your setup program for example), or if you
wanted to make your program run only the next time Windows start, following
function might come in handy:

procedure RunOnStartup(
  sProgTitle,
  sCmdLine    : string;
  bRunOnce    : boolean );
var
  sKey : string;
  reg  : TRegIniFile;
begin
  if( bRunOnce )then
    sKey := 'Once'
  else
    sKey := '';

  reg := TRegIniFile.Create( '' );
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.WriteString(
    'Software\Microsoft'
    + '\Windows\CurrentVersion\Run' 
    + sKey + #0,
    sProgTitle,
    sCmdLine );
  reg.Free;
end;


Usage:
sProgTitle
Name of your program. Generally speaking, this could be anything you want.
sCmdLine
This is the full path name to your executable program.
bRunOnce
Set this to True if you want to run your program just once. If this parameter
is False, your program will be executed every time Windows startsup.
Example:

RunOnStartup( 'Title of my program', 'MyProg.exe', False );
