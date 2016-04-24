(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0188.PAS
  Description: Making Your Delphi 2.0 Applications 
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)


(*
This TI demonstrates how to make your Delphi 2.0
application "sing" by loading and playing a wave file
four different ways:

1) Use the sndPlaySound() function to directly
play a wave file.

2) Read the wave file into memory, then use the
sndPlaySound() to play the wave file

3) Use sndPlaySound to directly play a wave
file thats embedded in a resource file attached
to your application.

4) Read a wave file thats embedded in a resource
 file attached to your application into memory,
 then use the sndPlaySound() to play the wave file.

 To build the project you will need to:

1) Create a wave file called 'hello.wav'
in the project's directory.

2) Create a text file called 'snddata.rc'
in the project's directory.

3) Add the following line to the file 'snddata.rc':
HELLO WAVE hello.wav

4) At a dos prompt, go to your project directory
and compile the .rc file using the Borland Resource
compiler (brcc32.exe) by typing the path to brcc32.exe
and giving 'snddata.rc' as a parameter.

Example:

bin\brcc32 snddata.rc

This will create the file 'snddata.res' that
Delphi will link with your application's .exe
file.

Final Note: Keep on Jamm'n!

*)

unit PlaySnd1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    PlaySndFromFile: TButton;
    PlaySndFromMemory: TButton;
    PlaySndbyLoadRes: TButton;
    PlaySndFromRes: TButton;
    procedure PlaySndFromFileClick(Sender: TObject);
    procedure PlaySndFromMemoryClick(Sender: TObject);
    procedure PlaySndFromResClick(Sender: TObject);
    procedure PlaySndbyLoadResClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{$R snddata.res}

uses MMSystem;

procedure TForm1.PlaySndFromFileClick(Sender: TObject);
begin
  sndPlaySound('hello.wav',
                SND_FILENAME or SND_SYNC);
end;

procedure TForm1.PlaySndFromMemoryClick(Sender: TObject);
var
  f: file;
  p: pointer;
  fs: integer;
begin
  AssignFile(f, 'hello.wav');
  Reset(f,1);
  fs := FileSize(f);
  GetMem(p, fs);
  BlockRead(f, p^, fs);
  CloseFile(f);
  sndPlaySound(p,
               SND_MEMORY or SND_SYNC);
  FreeMem(p, fs);
end;

procedure TForm1.PlaySndFromResClick(Sender: TObject);
begin
  PlaySound('HELLO',
            hInstance,
            SND_RESOURCE or SND_SYNC);
end;

procedure TForm1.PlaySndbyLoadResClick(Sender: TObject);
var
  h: THandle;
  p: pointer;
begin
  h := FindResource(hInstance,
                    'HELLO',
                    'WAVE');
  h := LoadResource(hInstance, h);
  p := LockResource(h);
  sndPlaySound(p,
               SND_MEMORY or SND_SYNC);
  UnLockResource(h);
  FreeResource(h);
end;


end.

