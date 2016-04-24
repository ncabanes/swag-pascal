(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0246.PAS
  Description: Detect Windows System Version
  Author: LEONARDO HUMBERTO LIPORATI
  Date: 05-30-97  18:17
*)


>
> Hello !
>
> Does anyone know, how can I detect the Windows System Version information?
>
> Thanks!

Hello!

If you want to know in what operating system your program is running and its
version (eg. Windows 95, Windows NT 3.51, Windows NT 4.0), try the code
below which I adapted from MSDN to work with Delphi.

unit winversion;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormShow(Sender: TObject);
var Version : DWORD;
    Build : WORD;
    MajorVersion, MinorVersion : BYTE;
begin
  Version := GetVersion();
  { Get major and minor version numbers of Windows }
  MajorVersion := LOBYTE(LOWORD(Version));
  MinorVersion := HIBYTE(LOWORD(Version));
  { Get build numbers for Windows NT or Win32s }
  if (Version and $80000000) = 0 then begin { Windows NT }
    Memo1.Lines.Add('Windows NT');
    Build := HIWORD(Version);
  end
  else if (MajorVersion < 4) then begin { Win32s }
    Memo1.Lines.Add('Win32s');
    Build := HIWORD(Version) and $7FFF;
  end
  else begin
    Memo1.Lines.Add('Windows 95'); { Windows 95 -- No build numbers provided }
    Build := 0;
  end;
  Memo1.Lines.Add('Version '+IntToStr(MajorVersion)+'.'+IntToStr(MinorVersion));
  Memo1.Lines.Add('Build '+IntToStr(Build));
end;

end.

