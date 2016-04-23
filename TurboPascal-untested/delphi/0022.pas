
I have seen the question "how do you add controls to TTabbedNotebook
or TNotebook at run-time?" several times here and elsewhere.
Well, after finally getting a few spare minutes to check into
it, I have stumbled across the solution:


TTabbedNotebook
---------------
Adding controls to a TTabbedNotebook during design time is
a pretty simple task.  All you need to do is set the PageIndex
or ActivePage property to the page you want to add controls
to, and begin dropping the controls onto the TTabbedNotebook.

Adding controls to a TTabbedNotebook during run-time is also
very simple.  However, there is no mention what-so-ever in
the Delphi documentation on how to do this.  To make matters
worse, the TTabbedNotebook source code is not included when
you purchase the Delphi VCL source.  Thus, we are left with
a mystery.  Fortunately, I have stumbled across the solution.

The first step to solving this mystery was to take a look
at \DELPHI\DOC\TABNOTBK.INT, the interface section of the
TABNOTBK.PAS unit where TTabbedNotebook is defined.  A quick
examination will reveal the TTabPage class, which is described
as holding the controls for a given page of the TTabbedNotebook.

The second clue to solving this case comes from observation
that the Pages property of TTabbedNotebook has a type of TStrings.
It just so happens that Delphi's TStrings and TStringList classes
provide both Strings and Objects property pairs.  In other words,
for every string in TStrings, there is a corresponding Objects
pointer.  In many cases, this extra pointer is ignored, but if
you're like me, you're thinking "Ah-hah!"

After a quick little test in code, sure enough, the Objects property
points to a TTabPage instance -- the one that corresponds to the
page name in the Strings property.  Bingo!  Just what we were looking
for.  Now see what we can do:

{ This procedure adds places a button at a random location on the }
{ current page of the given TTabbedNotebook.                      }

procedure AddButton(tabNotebook : TTabbedNotebook);
var
  tabpage : TTabPage;
  button  : TButton;
begin
  with tabNotebook do
    tabpage := TTabPage(Pages.Objects[PageIndex]);
  button := TButton.Create(tabpage);
  try
    with button do begin
      Parent := tabpage;
      Left   := Random(tabpage.ClientWidth - Width);
      Top    := Random(tabpage.ClientHeight - Height);
    end;
  except
    button.Free;
  end;
end;


TNotebook
---------
The process of adding controls to a TNotebook is almost exactly
the same as that for TTabbedNotebook -- only the page class type
is TPage instead of TTabPage.  However, if you look in
DELPHI\DOC\EXTCTRLS.INT for the type declaration for TPage,
you won't find it.  For some reason, Borland did not include the
TPage definition in the DOC files that shipped with Delphi.
The TPage declaration *IS* in the EXTCTRLS.PAS unit that you
get when you order the VCL source, right where it should be
in the interface section of the unit.  Here's the TPage information
they left out:

  TPage = class(TCustomControl)
  private
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure ReadState(Reader: TReader); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Height stored False;
    property TabOrder stored False;
    property Visible stored False;
    property Width stored False;
  end;

Now, to make the above procedure work for adding a button to
a TNotebook, all we have to do is replace "TTabbedNotebook" with
"TNotebook" and "TTabPage" with "TPage", as follows:

{ This procedure adds places a button at a random location on the }
{ current page of the given TNotebook.                            }

procedure AddButton(Notebook1 : TNotebook);
var
  page    : TPage;
  button  : TButton;
begin
  with Notebook1 do
    page := TPage(Pages.Objects[PageIndex]);
  button := TButton.Create(page);
  try
    with button do begin
      Parent := page;
      Left   := Random(page.ClientWidth - Width);
      Top    := Random(page.ClientHeight - Height);
    end;
  except
    button.Free;
  end;
end;
