unit OnlyOne;

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	OnlyOne, version 1.00, Freeware
	 A Delphi 2.0 component
	composed by Gary Nielsen, 3/26/96
	 70323.2610@compuserve.com
	
	Drop the OnlyOne component onto a form and only one
	instance of that window will occur.  Any attempt to make
	a second instance will restore the previous window.
	
	caveat artifex:
	 Use this component at your own risk.  OnlyOne may not
	work with applications that change their title bar, or
	with applications that have names longer than 20 chars.
	I have only tested this component on a limited number
	of programs, so treat it as 'alpha'-ware.
	
	Acknowledgements:
	 To make this into a component, I used Steven L. Keyser's
	JustOne component as a template.  I also derived some code
	from PC Mag's Michael J. Mefford's PicAlbum utility,
	in which hPrevInst is used, but, according to the
	documentation, hPrevInst always equals NULL	with Delphi 2
	and Win95.
	
	Please, if you modify or enhance this code,	drop me a
	note so that I can learn from your work. 

  * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TOnlyOne = class(TComponent)
    private
    public
      constructor Create(AOwner:TComponent); override;
      destructor Destroy; override;
    published
  end;

procedure Register;
procedure LookForPreviousInstance;

var
  AtomText: array[0..31] of Char;
  
implementation

procedure Register;
begin
  RegisterComponents('Win95', [TOnlyOne]);
end;

procedure LookForPreviousInstance;
var
  PreviousInstanceWindow : hWnd;
  AppName : array[0..30] of char;
  FoundAtom : TAtom;
begin
    {put the app name into AtomText}
  StrFmt(AtomText, 'OnlyOne%s', [Copy(Application.Title,1,20)]);
    {check to see if there's a global atom based on the app name }
  FoundAtom := GlobalFindAtom(AtomText);
  if FoundAtom <> 0 then      {another instance exists}
    begin
        {get the app name into a pointer string }
	  StrFmt(AppName,'%s', [Application.Title]);
        {change current title so that FindWindow doesn't see it }
      Application.Title := 'destroy me';
        {locate the previous instance of the app }
      PreviousInstanceWindow := FindWindow(nil,AppName);
	    {give focus to the previous instance of the app }
      if PreviousInstanceWindow <> 0 then
        if IsIconic(PreviousInstanceWindow) then
          ShowWindow(PreviousInstanceWindow,SW_RESTORE)
        else
          BringWindowToTop(PreviousInstanceWindow);
        {stop the current instance of the application }
      Application.Terminate;
    end;
  { make the global atom so no other instances can occur }
  FoundAtom := GlobalAddAtom(AtomText);
end;	  

constructor TOnlyOne.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  LookForPreviousInstance;
end;

destructor TOnlyOne.Destroy;
var
  FoundAtom : TAtom;
  ValueReturned : word;
begin
  { must not forget to remove the global atom, so first
    check to see if there's a global atom already }
  FoundAtom := GlobalFindAtom(AtomText);
  if FoundAtom <> 0 then          {and now remove that atom}
    ValueReturned := GlobalDeleteAtom(FoundAtom);
  inherited Destroy;
end;

end.
