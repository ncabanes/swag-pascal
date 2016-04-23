
unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
     procedure winmsg(var msg:tmsg;var handled:boolean);
     {This is what handles the messages}

     procedure DOWHATEVER;{procedure to do whatever}
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
const ItemID=99;{the ID number for your menu item--can be anything}

procedure tform1.winmsg(var msg:tmsg;var handled:boolean);
begin
  if msg.message=wm_syscommand then{if the message is a system one...}
   if msg.wparam = ItemID then DOWHATEVER;{then check if its parameter
                                           is your Menu items ID,}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  application.onmessage:=winmsg;
  {tell your app that 'winmsg' is the application message handler}

  AppendMenu(GetSystemMenu(form1.handle,false),mf_separator,0,'');
  {Add a seperator bar to form1}
  
AppendMenu(GetSystemMenu(form1.handle,false),mf_byposition,ItemID,
  '&New Item');
{add your menu item to form1}

  
AppendMenu(GetSystemMenu(application.handle,false),mf_separator,0,'');
{Add a seperator bar to the application system menu(used when app 
 is minimized)}
  
AppendMenu(GetSystemMenu(application.handle,false),mf_byposition,
ItemID,'&New Item'
{add your menu itemto the application system menu(used when app is 
 minimized)}

{for more information on the AppendMenu and GetSystemMenu see online
 help}

end;

procdure TForm2.DOWHATEVER;
begin
 {add whatever you want to this procedure}
end;

end.
