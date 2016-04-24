(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0021.PAS
  Description: Delphi DDE Linking
  Author: KERRY PODOLSKY
  Date: 11-22-95  13:28
*)


     unit Netscp1;
     
     interface
     
     uses
       SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
       Forms, Dialogs, StdCtrls, DdeMan;
     
     type
       TForm1 = class(TForm)
         DdeClientConv1: TDdeClientConv;
         Button1: TButton;
         Button2: TButton;
         Button3: TButton;
         LinkStatus: TEdit;
         Label1: TLabel;
         Label2: TLabel;
         URLName: TEdit;
         procedure Button1Click(Sender: TObject);
         procedure FormCreate(Sender: TObject);
         procedure Button2Click(Sender: TObject);
         procedure Button3Click(Sender: TObject);
       private
         { Private declarations }
       public
         { Public declarations }
       end;
     
     var
       Form1: TForm1;
       LinkOpened: Integer;
     
     implementation
     
     {$R *.DFM}
     
     procedure TForm1.Button1Click(Sender: TObject);
     begin
       If LinkOpened = 0 Then
       Begin
         DdeClientConv1.SetLink('Netscape', 'WWW_OpenURL');
         If DdeClientConv1.OpenLink Then
         begin
           LinkStatus.Text := 'Netscape Link has been opened';
           LinkOpened := 1;
         end
         else
           LinkStatus.Text := 'Unable to make Netscape Link';
       End;
     end;
     
     procedure TForm1.FormCreate(Sender: TObject);
     begin
       LinkOpened := 0;
     
     end;

     procedure TForm1.Button2Click(Sender: TObject);
     begin
       DdeClientConv1.CloseLink;
       LinkOpened := 0;
       LinkStatus.Text := 'Netscape Link has been closed';
     end;
     
     procedure TForm1.Button3Click(Sender: TObject);
     var
        ItemList: String;
     begin
       If LinkOpened <> 0 Then
       begin
         ItemList := URLName.Text + ',,0xFFFFFFFF,0x3,,,';
         DdeClientConv1.RequestData(ItemList);
       End;
     end;
     
     end.

