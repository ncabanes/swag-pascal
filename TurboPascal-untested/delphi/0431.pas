
A: Here is  WindowRestorer - a window size  and state restorer DESCRIPTION:
Ever notice  how professional programs  seem to remember  in what condition
and location  you left them and  their child windows? Ever  notice how most
RAD apps  don't? You can take  that ragged edge off  your program with this
unit. It  Allows apps to save  the location, size, and  state of windows so
that when the user reopens them, they will look as the user left them.

USE: Put  WINRSTOR in the  uses of clause  of your main  form and any forms
that will  be saving or restoring  their own state, size,  or location. (If
you will  be doing all the  saving and restoring using  WinSaveChildren and
WinRestoreChildren from  the main form, you  only need reference it  in the
main form's uses clause.)

In  MainForm.Create, initialize  the global  WinRestorer object  as follows
(it's already declared in this file, but needs to be allocated):


--------------------------------------------------------------------------------

        GlobalWinRestorer := TWinRestorer.create( Application, TRUE, WHATSAVE_ALL);

--------------------------------------------------------------------------------
Which is the same as:
--------------------------------------------------------------------------------

        GlobalWinRestorer := TWinRestorer.create( Application, TRUE, [location, size, state]);

--------------------------------------------------------------------------------
Then,  in MainForm.Destroy,  deallocate  the  global WinRestorer  object as
follows:

--------------------------------------------------------------------------------

GlobalWinRestorer.free;

--------------------------------------------------------------------------------
A good place  to save a  form's status is  in the queryclose  event or else
attached to  a button or  menu item. I  usually create an  item in the File
Menu captioned 'Save &Workspace' which does:

--------------------------------------------------------------------------------

        GlobalWinRestorer.SaveChildren(Self, [default]);

--------------------------------------------------------------------------------
And under main form's Close event I put:
--------------------------------------------------------------------------------

        GlobalWinRestorer.SaveWin(Self, [WHATSAVE_ALL]);

--------------------------------------------------------------------------------
I have tended  to restore the  children's status in  their own show  events
like this:

--------------------------------------------------------------------------------

        GlobalWinRestorer.RestoreWin(Self, [default]);

--------------------------------------------------------------------------------
though I am moving toward putting in the main form's show event:
--------------------------------------------------------------------------------

        GlobalWinRestorer.RestoreWin(Self, [default]);
        GlobalWinRestorer.RestoreChildren(Self, [default]);

--------------------------------------------------------------------------------
HINTS: If you set TForm.Position  to poScreenCenter or anything fancy, this
unit  won't do  what you  expect. poDesigned  seems to  work fairly well. I
could  have raised  an  exception  if you  try to  set top   and left  of a
poScreenCentere'd   form,  but   then  you   have  to   be  careful   using
WinRestoreChildren. I  opted not to  check the position  property and leave
that up to individual developers.


--------------------------------------------------------------------------------

unit WinRstor;

INTERFACE

USES SysUtils, Forms;

TYPE {=============================================================}


{------------------------------------------------------------------
Windows restorer object class and related types.
-------------------------------------------------------------------}
EWinRestorer = class( Exception);
TWhatSave = (default, size, location, state);
STWhatSave = set of TWhatSave;
TWinRestorer = class(TObject)
 protected
  mIniFile: string;
  mIniSect: string[80];
  mIsInitialized: boolean;
  mDefaultWhat: STWhatSave;
 public
  constructor Create( TheApp: TApplication;

    LocalDir: boolean; DefaultWhatSave: STWhatSave);
    {If localDir is true, ini dir is the app dir.  Else, ini dir is the windows dir.}
  procedure SaveWin(TheForm: TForm; What: STWhatSave);
  procedure SaveChildren(TheMDIForm: TForm; What: STWhatSave);
  procedure RestoreWin( TheForm: TForm; What: STWhatSave);
  procedure RestoreChildren(TheMDIForm: TForm; What: STWhatSave);
  property IniFileName: string  read mIniFile;
end;

CONST
  WHATSAVE_ALL = [size, location, state];


VAR
GlobalWinRestorer: TWinRestorer;

IMPLEMENTATION

Uses IniFiles;

constructor TWinRestorer.create;
var fname, path: string[100];
begin
  inherited create;
{Calculate ini file name}
  if default in DefaultWhatSave then
    raise EWinRestorer.create(
     'Attempt to initialize default window position paramaters with set ' +
     ' containing [default] item.  ' +
     'Default params may contain only members of [size, location, state].  ')
  else mDefaultWhat := DefaultWhatSave;

  fname := ChangeFileExt( ExtractFileName( TheApp.exeName), '.INI');
  if LocalDir then begin {parse out path and add to file name}
    path := ExtractFilePath(TheApp.exeName);
    if path[length(path)] <> '\' then
      path := path + '\';
    fname := path + fname;
  end;
{fill object fields}
  mIniFile := fname;
  mIniSect := 'WindowsRestorer';
{It'd be nice to write some notes to a section called [WinRestorer Notes]}
end;

procedure TWinRestorer.RestoreWin;

var FormNm, SectionNm: string[80];   ini: TIniFile;
  n,l,t,w,h: integer; {Left, Top Width, Height}
begin
  ini := TIniFile.create( mIniFile);
  TRY
    SectionNm := mIniSect;
    FormNm := TheForm.classname;
    if default in What then What := mDefaultWhat;
{Update Window State if Necessary}
    if state in What then
      n := ini.ReadInteger( SectionNm, FormNm + '_WindowState', 0);
      case  n of
        1:   TheForm.WindowState := wsMinimized;
        2:  TheForm.WindowState := wsNormal;

        3:   TheForm.WindowState := wsMaximized;
      end;
{Update Size and Location if necessary.}
    with TheForm do begin l:=left; t:=top; h:=height; w:=width; end; {Save current vals.}
    if size in What then begin
      w := ini.ReadInteger( SectionNm, FormNm + '_Width', w);
      h := ini.ReadInteger( SectionNm, FormNm + '_Height', h);
    end;
    if location in What then begin
      t := ini.ReadInteger( SectionNm, FormNm + '_Top', t);
      l := ini.ReadInteger( SectionNm, FormNm + '_Left', l);

    end;
    TheForm.SetBounds(l,t,w,h);
  FINALLY
    ini.free;
  END;
end;

procedure TWinRestorer.RestoreChildren;
var i: integer;
begin
  if TheMDIForm.formstyle <> fsMDIForm then
    raise EWinRestorer.create('Attempting to save window sizes of children for a non MDI parent window.')
  else
    for i := 0 to TheMDIForm.MDIChildCount - 1 do
      RestoreWin( TheMDIForm.MDIChildren[i], what);
end;

procedure TWinRestorer.SaveWin;
var FormNm, SectionNm: string[80];   w : STWhatsave; ini: TIniFile;

begin
  ini := TIniFile.create( mIniFile);
  TRY
    SectionNm := mIniSect;
    FormNm := TheForm.ClassName;
    if default in What then w := mDefaultWhat else w := mDefaultWhat;
    if size in w then begin
      ini.WriteInteger( SectionNm, FormNm + '_Width', TheForm.Width);
      ini.WriteInteger( SectionNm, FormNm + '_Height', TheForm.Height);
    end;
    if location in w then begin
      ini.WriteInteger( SectionNm, FormNm + '_Top', TheForm.Top);
      ini.WriteInteger( SectionNm, FormNm + '_Left', TheForm.Left);

    end;
    if state in w then
      case TheForm.WindowState of
        wsMinimized:   ini.WriteInteger( SectionNm, FormNm + '_WindowState', 1);
        wsNormal:     ini.WriteInteger( SectionNm, FormNm + '_WindowState', 2);
        wsMaximized:   ini.WriteInteger( SectionNm, FormNm + '_WindowState', 3);
      end;
  FINALLY
    ini.free;
  END;
end;

procedure TWinRestorer.SaveChildren;
var i: integer;
begin
  if TheMDIForm.formstyle <> fsMDIForm then
    raise EWinRestorer.create('Attempting to restore window sizes of children for a non MDI parent window.')

  else
    for i := 0 to TheMDIForm.MDIChildCount - 1 do
      SaveWin( TheMDIForm.MDIChildren[i], what);
end;

INITIALIZATION
END.
