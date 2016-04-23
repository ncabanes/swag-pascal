
program HorizontalListBox;

uses
    WinTypes, WinProcs, OWindows, ODialogs, Strings;

const
  id_ListBox1 = 101;


type
  ListBoxApp = Object (TApplication)
    procedure InitMainWindow; Virtual;
  end;

  PHListBox = ^THListBox;
  THListBox = object(TListBox)
      procedure SetupWindow; virtual;
  end;

  PMainWindow = ^TMainWindow;
  TMainWindow = Object(TWindow)
    ListBox1: PHListBox;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure SetupWindow; virtual;
  end;

procedure TMainWindow.SetupWindow;
var
  dc: Hdc;
  StringLength, Count, I: Byte;

  Tmp, StringSize: LongInt;
  lbString: PChar;

begin
  inherited SetupWindow;
  dc := GetDC(hWindow);
  StringLength := 0;
  {Add strings to the list box.}
  ListBox1^.AddString('This is line 1');
  ListBox1^.AddString('This is line 2, which is really long');
  ListBox1^.AddString('This is line 3');
  ListBox1^.AddString('This is line 4');
  ListBox1^.AddString('This is line 5');
  ListBox1^.AddString('This is line 6');
  ListBox1^.AddString('This is line 7');

  ListBox1^.AddString('This is line 8');
  ListBox1^.AddString('This is line 9');
  {Count the number of strings inside the list box.}
  Count := ListBox1^.GetCount;
  if Count > 0 then
  begin
    GetMem(lbString, 255);
    {Look at each string in the list box and determine
     the size of the largest one.}
    for I := 0 to Count - 1 do
    begin
      StringSize := ListBox1^.GetString(lbString, I);
      if StringSize <= 0 then
      begin
        MessageBox(HWindow, 'An error occured extracting string',

        'ERROR',mb_Ok or mb_IconExclamation);
        Break;
      end
      else
      begin
        {The lo word return from GetTextExtent holds the width
         in pixels of the string.}
        Tmp := loWord(GetTextExtent(dc, lbString, StringSize));
        if Tmp > StringLength then
          StringLength := Tmp;
      end;
    end;
    FreeMem(lbString, 255);
    {Add one upper case character length to the total length of
    the largest string length .  This allows the list box to

    scroll just beyond the last character in the larges string.}
    inc(StringLength, LoWord(GetTextExtent(dc, 'X', 1)));
    {Send a lb_SetHorizontalExtent to the list box.}
    SendMessage(ListBox1^.HWindow, lb_SetHorizontalExtent,
                StringLength, 0);
  end
  else
    MessageBox(HWindow, 'An error occured.  The list box
     has no strings in it.','ERROR', mb_Ok or mb_IconExclamation);
  ReleaseDC(hWindow, dc);
end;

procedure THListBox.SetupWindow;

begin
    inherited SetupWindow;
    Attr.Style := Attr.Style or WS_HSCROLL;
end;

constructor TMainWindow.Init (AParent: PWindowsObject; ATitle: PChar);
begin
  Inherited Init (AParent, ATitle);
  ListBox1 := New(PHListBox, Init(@Self, id_ListBox1,
                   15, 15, 120, 100));
end;

procedure ListBoxApp.InitMainWindow;
begin
  MainWindow := New(PMainWindow, Init(nil,
                    'Example of a Horizontal Scrolling List Box'));
end;

var

  MyApplication: ListBoxApp;

begin
  MyApplication.Init('Min');
  MyApplication.Run;
  MyApplication.Done;
end.
