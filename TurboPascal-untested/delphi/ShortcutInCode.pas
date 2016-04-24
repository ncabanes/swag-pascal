(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0382.PAS
  Description: Shortcut in code
  Author: THANH QUACH
  Date: 01-02-98  07:34
*)


>How do you create a shortcut in code, given a program executable and its
path?


Try the following code to see if it helps.

implementation
{$R *.DFM}

uses  ShlObj, ActiveX, ComObj, Registry;

procedure TForm1.Button1Click(Sender: TObject);
var
  MyObject: IUnknown;   // IUnknown interface
  MySLink: IShellLink; {The IShellLink interface provides an interface to
                        allow an application to create and resolve shell
links}
  MyPFile: IPersistFile; {The IPersistFile interface provides methods for an
                          object to load and save itself in a disk file }
  FileName: String;
  Directory: String;
  WFileName: WideString;
  MyReg: TRegIniFile;
begin
  MyObject := CreateComObject(CLSID_ShellLink);
  MySLink := MyObject as IShellLink;    // See on line help for IShellLink
interface
  MyPFile := MyObject as IPersistFile; // See on line help for IPersistFile
interface
  FileName := 'NOTEPAD.EXE';
  with MySLink do
    begin
      SetArguments('C:\AUTOEXEC.BAT');
      SetPath(PChar(FileName));
      SetWorkingDirectory(PChar(ExtractFilePath(FileName)));
    end;
  MyReg :=
TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
  // Put the shortcut on your desktop
  Directory := MyReg.ReadString('Shell Folders','Desktop','');

  // put the shortcut on your start menu
  { Directory := MyReg.ReadString('Shell Folders','Start Menu','')+
    CreateDir(Directory); }

  WFileName := Directory + '\NotePad.lnk';
  MyPFile.Save(PWChar(WFileName),False);
  MyReg.Free;
end;

