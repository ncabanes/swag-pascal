(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0041.PAS
  Description: TSizer unit for DELPHI forms
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  15:50
*)

unit Sizer;

interface

uses
	Messages, WinTypes, Classes, WinProcs, Controls, Forms, SysUtils;

type ENonWindowOwner=class(Exception);

{------------------------------------------------------------------}
{--- Message Grabber ----------------------------------------------}
{------------------------------------------------------------------}
{Provides a component basis from which to trap messages sent to the form.
To override specific messages, descend from TMessageGrabber and either
add a message response method (such as WMGetMinMaxInfo), or override
the virtual method WndProc}

type TMessageGrabber = class(TComponent)
		private
			OwnerWndProc:TFarProc;
			MyWndProc:TFarProc;
			OwnerProcGrabbedQ:Boolean;
		protected
			procedure WndProc(var Msg:TMessage); virtual;
			procedure DefaultHandler(var Msg); override;
			procedure WMDestroy(var Msg:TWMDestroy); message WM_Destroy;
		public
			constructor Create(AOwner:TComponent); override;
			destructor  Destroy; override;
		end;

{------------------------------------------------------------------}
{--- Sizer --------------------------------------------------------}
{------------------------------------------------------------------}
{An example TMessageGrabber.
Traps WMGetMinMaxInfo to give a specified maximum dimensions.
Also resizes itself to give a specified Client area, regardless of
how many lines the menu bar wraps onto}

type
	TSizer = class(TMessageGrabber)
	private
		Resizing,SizeSet:boolean;
		DesiredWidth,DesiredHeight:longint;
		DeskSize:TPoint;
		MinW,MinH,FullW,FullH:longint;
		procedure SetDesiredWidth(NewWidth:longint);
		procedure SetDesiredHeight(NewHeight:longint);
	protected
		procedure WMGetMinMaxInfo(var Msg:TMessage); message WM_GetMinMaxInfo;
	public
		constructor Create(AOwner:TComponent); override;
		procedure Resize;
		procedure SetSurfaceBounds(Width,Height:longint);
	published
		property SurfaceWidth:longint read DesiredWidth write SetDesiredWidth;
		property SurfaceHeight:longint read DesiredHeight write SetDesiredHeight;
	end;

procedure Register;

implementation

{------------------------------------------------------------------}
{--- Message Grabber ----------------------------------------------}
{------------------------------------------------------------------}

{Create:
Override the WndProc of the owner window.
Note that it will be a very bad idea to have several MessageGrabber
components active at the same time, unless they are added and removed
carefully in order}

constructor TMessageGrabber.Create(AOwner:TComponent);
begin
if not(AOwner is TWinControl) then
	raise ENonWindowOwner.Create('Owner must be a windowed control');
inherited Create(AOwner);
OwnerWndProc:=TFarProc(GetWindowLong((Owner as TWinControl).Handle,gwl_WndProc));
MyWndProc:=MakeObjectInstance(WndProc);
SetWindowLong((Owner as TWinControl).Handle,gwl_WndProc,LongInt(MyWndProc));
OwnerProcGrabbedQ:=True;
end;

{Destroy:
Removes the overriding window handler}

destructor TMessageGrabber.Destroy;
begin
if OwnerProcGrabbedQ then
	SetWindowLong((Owner as TWinControl).Handle,gwl_WndProc,LongInt(OwnerWndProc));
FreeObjectInstance(MyWndProc);
inherited Destroy;
end;

{WMDestroy:
If WM_Destroy is sent to the owner, then when we get around to calling
the Destroy method here, Owner will no longer be valid. So, there are
two cases: Destroy is called without WMDestroy (ie component is removed
at design-time) and WMDestroy is called first (ie owner is about to be
destroyed)}

procedure TMessageGrabber.WMDestroy(var Msg:TWMDestroy);
begin
SetWindowLong((Owner as TWinControl).Handle,gwl_WndProc,LongInt(OwnerWndProc));
OwnerProcGrabbedQ:=False;
end;

{WndProc:
For windowed controls, standard message handling is:
the message is sent to WndProc, which calls Dispatch.
Only windows controls have a WndProc. But Dispatch is a method
of TObject, used for dispatching all message-based methods, not
just Windows ones. This WndProc mimics that of a windowed control}

procedure TMessageGrabber.WndProc(var Msg:TMessage);
begin
Dispatch(Msg);
end;

{DefaultHandler:
The Dispatch method will attempt to dispatch the method, and failing
will call DefaultHandler. If a message-response method calls
its inherited method, where the inherited method is undefined, the
message is also sent to the DefaultHandler.
For a TMessageGrabber, DefaultHandler should pass any unhandled
messages back to the owner}

procedure TMessageGrabber.DefaultHandler(var Msg);
begin
with TMessage(Msg) do
	Result:=CallWindowProc(OwnerWndProc,(Owner as TWinControl).Handle,Msg,wParam,lParam);
end;

{------------------------------------------------------------------}
{--- Sizer --------------------------------------------------------}
{------------------------------------------------------------------}

constructor TSizer.Create(AOwner:TComponent);
var DeskRect:TRect;
begin
SizeSet:=false;
inherited Create(AOwner);
with Owner as TControl do
	begin
	SetSurfaceBounds(ClientWidth,ClientHeight);
	FullW:=Width;
	FullH:=Height;
	end;
Winprocs.GetClientRect(GetDesktopWindow,DeskRect);
DeskSize.X:=DeskRect.Right-DeskRect.Left;
DeskSize.Y:=DeskRect.Bottom-DeskRect.Top;
SizeSet:=true;
end;

procedure TSizer.SetSurfaceBounds(Width,Height:longint);
begin
DesiredWidth:=Width;
DesiredHeight:=Height;
with Owner as TForm do
	begin
	HorzScrollBar.Range:=DesiredWidth;
	VertScrollBar.Range:=DesiredHeight;
	end;
end;

procedure TSizer.Resize;
	procedure ShiftBounds(OldL,MaxW,Size:longint; var NewL,NewW:longint);
	begin
	if OldL>0 then begin
		NewL:=Size-NewW;
		if NewL<0 then begin
			NewW:=NewW+NewL; NewL:=0; end; end;
	end;
var Desk:TRect;
		MaxW,MaxH,OldW,OldH,NewL,NewT,NewW,NewH:longint;
begin
Resizing:=true;
NewW:=0;   NewH:=0;
with Owner as TControl do
	begin

repeat
	MaxW:=DeskSize.X-Left;
	OldW:=NewW;
	NewL:=Left;
	NewW:=Width+(DesiredWidth-ClientWidth);
	if NewW<MinW then NewW:=MinW;
	if NewW>MaxW then ShiftBounds(Left,MaxW,DeskSize.X,NewL,NewW);

	repeat
		MaxH:=DeskSize.Y-Top;
		OldH:=NewH;
		NewT:=Top;
		NewH:=Height+(DesiredHeight-ClientHeight);
		if NewH<MinH then NewH:=MinH;
		if NewH>MaxH then ShiftBounds(Top,MaxH,DeskSize.Y,NewT,NewH);

		SetBounds(NewL,NewT,NewW,NewH);

	until OldH=NewH;
until OldW=NewW;

FullW:=DesiredWidth+Width-ClientWidth;
FullH:=DesiredHeight+Height-ClientHeight;
if FullW<MinW then FullW:=MinW;
if FullH<MinH then FullH:=MinH;

Resizing:=false;
end;
end;

procedure TSizer.WMGetMinMaxInfo(var Msg:TMessage);
begin
with PMinMaxInfo(Msg.lParam)^ do
	begin
	if (not SizeSet) then
		begin
		MinW:=ptMinTrackSize.X;
		MinH:=ptMinTrackSize.Y;
		end
	else if (not Resizing) then
		begin
		ptMaxTrackSize.X:=FullW;
		ptMaxTrackSize.Y:=FullH;
		end;
	end;
end;

procedure TSizer.SetDesiredWidth(NewWidth:longint);
begin
SetSurfaceBounds(NewWidth,DesiredHeight);
Resize;
end;

procedure TSizer.SetDesiredHeight(NewHeight:longint);
begin
SetSurfaceBounds(DesiredWidth,NewHeight);
Resize;
end;

procedure Register;
begin
RegisterComponents('Additional', [TSizer]);
end;

end.

