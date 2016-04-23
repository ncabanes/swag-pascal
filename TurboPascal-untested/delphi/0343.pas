
the code below is searching for delphi.exe. Attention, it's possible that you
need a bigger stacksize. With my HD 2,5 GByte / 1,2 GByte is used a stacksize of
16384 Byte is ok. It's dependent on the number of directories on your HD.

Regards
:) Jens
jensschumann@t.online.de
http://home.t-online.de/home/jensschumann
Germany/Gerdau

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure ListFiles(D,Name,SearchName : String);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  ListFiles('c:\','*.*','delphi.exe'); {Searching for delphi.exe}
end;

procedure TForm1.ListFiles(D,Name,SearchName : String);
var
    SR            : TSearchRec;
begin
  If D[Length(D)]<>'\' then
    D:=D+'\';
  If FindFirst(D+Name,faAnyFile,SR)=0then
    Repeat
      If (SR.Attr<>faDirectory) and (SR.Name[1]<>'.') then
        If AnsiUpperCase(SR.Name)=AnsiUpperCase(SearchName) then
          Label1.Caption:=D+SR.Name; {If found then set label1.caption}
    Until (FindNext(SR)<>0);
  FindClose(SR);
  If FindFirst(D+'*.*',faDirectory,SR)=0 then
    begin
      Repeat
        If ((Sr.Attr and faDirectory)=faDirectory) and
            (SR.Name[1]<>'.') then
          ListFiles(D+SR.Name+'\',Name,SearchName);
      Until (FindNext(SR)<>0);
    end;
  FindClose(SR);
end;
end.

