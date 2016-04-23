
Solution 1
The following code comes from Loyds Help File (it can be found on
most delphi web pages). I haven't tried it but I will use it in one
of my apps as soon as I get the bitmap from the client. let me know
if it works for you.


--------------------------------------------------------------------------------

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Bitmap: TBitmap;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile('C:\WINDOWS\cars.BMP');
end;

procedure TForm1.FormPaint(Sender: TObject);
var
  X, Y, W, H: LongInt;
begin
  with Bitmap do begin
    W := Width;
    H := Height;
  end;
  Y := 0;
  while Y < Height do begin
    X := 0;
    while X < Width do begin
      Canvas.Draw(X, Y, Bitmap);
      Inc(X, W);
    end;
    Inc(Y, H);
  end;
end;

end.

--------------------------------------------------------------------------------

Solution 2 
From: "Dirk Faber " <d.j.faber@student.utwente.nl>

Rob Wilson <wilson@pelops.compd.com> wrote
> Does anyone know how I can change the wallpaper at runtime using a
> filename that I specifiy?

--------------------------------------------------------------------------------

procedure ChangeWallpaper(bitmap: string);       {bitmap contains filename: *.bmp}

var pBitmap : pchar;

begin
 bitmap:=bitmap+#0;
 pBitmap:=@bitmap[1];
 SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, pBitmap, SPIF_UPDATEINIFILE);
end;

--------------------------------------------------------------------------------

> Also, is there a way of saving it to the INI file for next session?
add inifiles to the uses list. 
create an inifile with a texteditor like this:
--------------------------------------------------------------------------------
 
[LastUsedBitmap]
LUBitmap= c:\mybitmap.bmp

--------------------------------------------------------------------------------

use a procedure like this: (supposed the inifile is like above, and is named c:\Bitmap.ini)
--------------------------------------------------------------------------------
 
procedure WriteToIniFile(bitmap : string);

var MyIniFile : TInifile;

begin
 MyIniFile := Tinifile.Create( 'c:\Bitmap.ini' );
 MyIniFile.WriteString( 'LastUsedBitmap', 'LUBitmap', bitmap);
 MyIniFile.Free;
end;

procedure ReadFromIniFile(var bitmap: string);

var MyIniFile : TInifile;

begin
  MyIniFile := Tinifile.Create( 'c:\Bitmap.ini' );
  bitmap:= MyIniFile.ReadString('LastUsedBitmap', 'LUBitmap');
  MyIniFile.Free;
end;
