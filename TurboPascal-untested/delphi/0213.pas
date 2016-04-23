{
Hi Vit,

: Anybody tied d'n'd any object from Delphi App (for example TListView) to
: win Explorer, DeskTop?
: How my App can catch the path?

Here is a piece of code I had in my arhcives <g>
It shold work on D2 too --I havent checked.

HTH

Basri,
kanca@ibm.net

-------BEGIN CUT AND PASTE-------------------
{
This small app should answer some questions for you.  If has quite a
few nifty things it does too, such as shows you how to drag and drop
from the file manager, owner drawn list boxes, etc.  Run it and tell
me what you think.  Make sure you adjust your file manager when it
comes up so that it doesn't cover up this program.  When saving as a
bitmap, remember to enter in an extension.  I havn't figured out how
to find the value of the SAVE FILE AS TYPE combo box...<g>

This work was originally created by Freddy Enok Hansson (100572,2032)
to help me with some of my questions. I have modified and added to it
to suit my needs.  If you like what you see, drop him a note and tell
him thanks.

-Pat Buchanan   73072,2743-
}


unit Pat;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    ListBox1: TListBox;
    NumIcons: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
  procedure WMDropFiles (var Msg: TMessage); message wm_DropFiles;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses ShellAPI;

{$R *.DFM}

var
  Pic: TPicture;
  Fname : String;
  TempFile: array[0..255] of Char;
  Icon : TIcon;
  Drop : THandle; {Handle for Msg.wParam}




 procedure TForm1.WMDropFiles(var Msg: TMessage);
 var
   i,K,
   NumFiles, NameLength : integer;
   nIconsInFile : word;
   nTotal : word;

 begin

  try
   screen.cursor := crHourglass;

   ListBox1.clear;
   Drop := Msg.wParam;
   nTotal := 0;

   {Query how many files were dropped on the app}
   NumFiles := DragQueryFile(Msg.wParam, $FFFF, Nil, 0);

   for i := 0 to (NumFiles-1) do begin
     NameLength := DragQueryFile(Msg.wParam, i, Nil , 0);
     DragQueryFile(Msg.wParam, i, TempFile, NameLength+1);
     FName := StrPas(TempFile);

     {Query how many icons existin the file (-1)}
     nIconsInFile := ExtractIcon(HInstance, TempFile, $FFFF);
     nTotal := nTotal + nIconsInFile;

       for K := 0 to nIconsInFile-1 do begin
         {Extract the icon}
         Icon.Handle := ExtractIcon(HInstance, TempFile, K);

         {Create a TPicture instance}
         Pic := TPicture.Create;
         {Assign the icon.handle to the Pic.icon property}
         Pic.Icon := Icon;

         {Add the Filename and icon to the ListBox}
         ListBox1.Items.AddObject(ExtractFileName(FName), Pic);
       end;  {For K}

   end;  {For I}

       IF nTotal = 0 then
           NumIcons.Caption := 'None'
       ELSE
           NumIcons.Caption := IntToStr(nTotal);


   finally
     screen.cursor := crDefault;

   end; {main begin}
end;  {WMDropFiles}



procedure TForm1.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  Icon := TIcon.Create;
  WinExec('winfile.exe', SW_RESTORE);
end;



procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
begin
  DragFinish(Drop);
  for I := 0 to ListBox1.Items.Count - 1 do
    TPicture(ListBox1.Items.Objects[I]).Free;
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with ListBox1.Canvas do
  begin
    FillRect(Rect);
    Pic := TPicture(ListBox1.Items.Objects[Index]);
    Draw(Rect.Left, Rect.Top + 2, Pic.Graphic);
    TextOut(Rect.Left + 34, Rect.Top + 5,
      ListBox1.Items[Index]);
  end;

end;




procedure TForm1.ListBox1DblClick(Sender: TObject);
var oIcon : TPicture;
var oBitmap : TBitmap;

begin

 oIcon := TPicture.create;
 oBitmap := TBitMap.create;


 IF SaveDialog1.Execute then

  WITH (Sender as TListBox) DO
     begin

      oIcon.Assign(TPicture(Items.Objects[ItemIndex]));

       {---------Save as an icon---------}
       IF ExtractFileExt(SaveDialog1.FileName) = '.ICO' then
         begin

           {Save the icon to the specified file}
           oIcon.icon.SaveToFile(SaveDialog1.Filename);

           ShowMessage(ExtractFileName(SaveDialog1.Filename) + ' has been
saved as an ICON.');

         end;

       {---------Save as a bitmap---------}
       IF ExtractFileExt(SaveDialog1.FileName) = '.BMP' then
         begin

            {Setup the bitmap size, so that it matches the icon}
            oBitmap.Width := Icon.Width;
            oBitmap.Height := Icon.Height;

            { Draw Icon on Bitmap }
            oBitmap.Canvas.Draw( 0, 0, oIcon.Graphic );

            {Save the bitmap to the specified file}
            oBitmap.SaveToFile(SaveDialog1.Filename);

            ShowMessage(ExtractFileName(SaveDialog1.Filename) + ' has been
saved as a BITMAP.');

         end;

 end;

     {Clean up after yourself}
     oIcon.free;
     oBitmap.free;
     SaveDialog1.FileName := '';

end;
end.
