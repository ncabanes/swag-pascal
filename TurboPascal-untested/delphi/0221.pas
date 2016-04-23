{
>>        I'm trying to make a progam which can call WINWORD.EXE for =
example
>>when
>>you select a file with a ".DOC" extension.... I have look at the =
WIN.INI
>>file in the EXTENSION section but this solution was not very clean =
!!!!
>>
>>        Can somebody please help me?
>
>Use ShellExecute and set "Operation" to 'Open'.


        I have found a solution more easy to used.
        I use a TOleContainer object like this :
}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
Dialogs,
  StdCtrls, Buttons, OleCtnrs;

type
  TForm1 =3D class(TForm)
    OleContainer1: TOleContainer;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { D=E9clarations priv=E9es }
  public
    { D=E9clarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  OleContainer1.CreateLinkToFile('C:\TEST\TOTO.doc', False);      {
     You specify your file name            }
  OleContainer1.DoVerb(ovShow);                                 { Like that the application called
was open }
  OleContainer1.CreateLinkToFile('C:\TEST\TITI.doc', False);
  OleContainer1.DoVerb(ovShow);
  OleContainer1.CreateLinkToFile('C:\WINDOWS\WIN.INI', False);
  OleContainer1.DoVerb(ovShow);=09
end;

end.
