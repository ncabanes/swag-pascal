(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0127.PAS
  Description: Array of Buttons
  Author: D.F. HARTLEY
  Date: 02-21-96  21:04
*)

{

Here is a unit that creates a row of buttons and a label at run time and
displays which button is clicked on. Thanks go to a number of people who pushed
me in the right direction. Like all things in programing 'it's obvious when you
know how'!

All you need to do is start a new project, then paste all the code below
into Unit1.

-------------------------------------------------------------------------------------
}

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
  b = 4;  {Total number of buttons to create}

var
  ButtonArray : Array[0..b-1] of TButton; {Set up an array of buttons}
  MessageBox: TLabel;                     {...and a label!}

procedure TForm1.FormCreate(Sender: TObject);
  var
    loop : integer;
begin
  ClientWidth:=(b*60)+10;               {Size the form to fit all the}
  ClientHeight:=65;                     {components in.}

  MessageBox:=TLabel.Create(Self);      {Create a label...}
  MessageBox.Parent:=Self;
  MessageBox.Align:=alTop;              {...set up it's properties...}
  MessageBox.Alignment:=taCenter;
  MessageBox.Caption:='Press a Button';

  for loop:= 0 to b-1 do                {Now create all the buttons}
      begin
        ButtonArray[loop]:=TButton.Create(Self);
        with ButtonArray[loop] do       {Note the use of the with command.}
          begin	                        {This lets you leave out the first}
            Parent  :=self;             {bit of the description and}
            Caption :=IntToStr(loop);   {(I think) makes the code easier}
            Width   :=50;               {to read.}
            Height  :=25;
            Top	    :=30;
            Left    :=(loop*60)+10;
            Tag	    :=loop;     	{Used to tell which button is pressed}
            OnClick :=ButtonClick;	{The important bit!}
          end;
      end;
end;

procedure TForm1.ButtonClick(Sender: TObject);
  var
    t : Integer;
begin
  t:=(Sender as TButton).Tag;		{Get the button number}
  MessageBox.Caption:='You pressed Button '+IntToStr(t);
end;

end.


