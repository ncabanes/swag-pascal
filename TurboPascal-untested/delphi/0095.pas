unit MRUFList;

(*    Implements a Recently-Used Files List     *)

(*  Constructed by Robert R. Marsh, S.J., 1995  *)
(* Use freely, distribute widely, charge nothing*)
(* If you like it you could always give some    *)
(* money to your favorite charity.              *)

(*  Comments, bug-reports, praise and blame to: *)
(*              RobMarsh@AOL.COM                *)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, IniFiles;

type
  TRecentFileEvent = procedure(Sender: TObject; LatestFile: string) of object;

type
  TRecentFiles = class(TComponent)
  private
    FMenu       : TMenuItem;
    Divider     : TMenuItem;
    FMaxFiles   : integer;
    FIniFileName: string;
    FLatestFile : string;
    FOnClick    : TRecentFileEvent;
    procedure SetLatestFile(value: string);
    procedure SetMenu(value: TMenuItem);
    procedure SetMaxFiles(value: integer);
    procedure MenuOnClick(Sender: TObject);
    function DividerPlace: integer;
  protected
    procedure Click(RecentFile: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SaveToIniFile;
    procedure LoadFromIniFile;
    property LatestFile: string read FLatestFile write SetLatestFile;
  published
    property Menu       : TMenuItem read FMenu write SetMenu;
    property MaxFiles   : integer read FMaxFiles write SetMaxFiles;
    property IniFileName: string read FIniFileName write FIniFileName;
    property OnClick    : TRecentFileEvent read FOnClick write FOnClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Mine', [TRecentFiles]);
end;

{we frequently need to know both if the Divider}
{has been added and, if so, where it is}
function TRecentFiles.DividerPlace: integer;
begin
Result:=-1;
if FMenu <> nil then
  begin
  Result:=Menu.IndexOf(Divider);
  end;
end;

procedure TRecentFiles.SetMenu(value: TMenuItem);
begin
FMenu:=value;
end;

procedure TRecentFiles.SetMaxFiles(value: integer);
var
  n: integer;
begin
{the Max value of MaxFiles is 9}
if value <=9 then
  begin
  FMaxFiles:=value;
  end
else
  begin
  FMaxFiles:=9;
  end;
if (FMenu <> nil) and (DividerPlace <> -1) then
  begin
  {trim off any entries more MaxFiles}
  while Menu.Count > DividerPlace + FMaxFiles + 1 do
    begin
    Menu.Delete(Menu.Count-1);
    end;
  {if neccesary delete the divider too}
  if FMaxFiles = 0 then
    begin
    Menu.Delete(Menu.Count-1);
    end;
  end;
end;

procedure TRecentFiles.SetLatestFile(value: string);
var
  NewMenuItem: TMenuItem;
  n          : integer;
  Thiscaption: string;
  OldPlace   : integer;
  DividerPos : integer;
begin
FLatestFile:=value;
if (Menu <> nil) and (MaxFiles > 0) and
   (FLatestFile <> '') then
  begin
  {special case - the divider}
  if DividerPlace < 0 then
    begin
    Menu.Add(Divider);
    end;
  {is the new Name already there?}
  DividerPos:=DividerPlace;
  n:=DividerPos+1;
  while (n < Menu.Count) do
    begin
    if FLatestFile = Copy(Menu.Items[n].Caption,4,high(string)) then
      begin
      OldPlace:=n;
      Break;
      end
    else
      begin
      inc(n);
      end;
  end;
  if n >= Menu.Count then {we add}
    begin
    NewMenuItem:=TMenuItem.Create(Self);
    NewMenuItem.Caption:='&1 '+FLatestFile;
    {what happens if we click it}
    NewMenuItem.OnClick:=MenuOnClick;
    Menu.Insert(DividerPos+1,NewMenuItem);
    end
  else                 {we insert}
    begin
    NewMenuItem:=Menu.Items[OldPlace];
    Menu.Delete(OldPlace);
    Menu.Insert(DividerPos+1,NewMenuItem);
    end;
  {now change the 'hot' keys}
  for n:=DividerPos+1 to Menu.Count - 1 do
    begin
    ThisCaption:=Menu.Items[n].Caption;
    ThisCaption[2]:=Chr(n - DividerPos + Ord('1') -1);
    Menu.Items[n].Caption:=ThisCaption;
    end;
  {delete any excess items}
  if Menu.Count > DividerPos + MaxFiles + 1 then
    begin
    Menu.Delete(Menu.Count-1);
    end;
  end;
end;

procedure TRecentFiles.Click(RecentFile: string);
begin
if Assigned(FOnClick) then FOnClick(Self,RecentFile);
end;

procedure TRecentFiles.SaveToIniFile;
var
  IniFile   : TIniFile;
  n         : integer;
  DividerPos: integer;
begin
if Menu <> nil then
  begin
  {if this property is blank we use the default}
  if IniFileName = '' then
    begin
    IniFileName:=ChangeFileExt(ExtractFileName(Application.ExeName),'.INI')
    end;
  IniFile:=TIniFile.Create(IniFileName);
  IniFile.EraseSection('FileHistory');
  IniFile.WriteInteger('FileHistory','MaxFiles',MaxFiles);
  if (Menu <> nil) and (DividerPlace <> -1) then
    begin
    DividerPos:=DividerPlace;
    n:=DividerPos+1;
    while n < Menu.Count do
      begin
      IniFile.WriteString('FileHistory','File'+Chr(n+Ord('1')-1-DividerPos),Copy(Menu.Items[n].Caption,4,high(string)));
      inc(n);
      end;
    IniFile.Free;
    end;
  end;
end;

procedure TRecentFiles.LoadFromIniFile;
var
  IniFile: TIniFile;
  n      : integer;
  Name   : string;
begin
if Menu <> nil then
  begin
  if IniFileName = '' then
    begin
    IniFileName:=ChangeFileExt(ExtractFileName(Application.ExeName),'.INI')
    end;
  IniFile:=TIniFile.Create(IniFileName);
  MaxFiles:=0;
  MaxFiles:=IniFile.ReadInteger('FileHistory','MaxFiles',MaxFiles);
  n:=1;
  while true do
    begin
    Name:=IniFile.ReadString('FileHistory','File'+Chr(n+Ord('1')-1),'');
    if Name = '' then
      begin
      Break;
      end;
    LatestFile:=Name;
    inc(n);
    end;
  end;
end;

constructor TRecentFiles.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
FMaxFiles:=0;
FMenu:=nil;
Divider:=TMenuItem.Create(Self);
Divider.Caption:='-';
end;

procedure TRecentFiles.MenuOnClick(Sender: TObject);
var
  Name: string;
begin
  begin
  Name:=Copy(TMenuItem(Sender).Caption,4,high(string));
  Click(Name);
  end;
end;

end.
