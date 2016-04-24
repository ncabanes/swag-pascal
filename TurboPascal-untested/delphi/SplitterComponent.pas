(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0138.PAS
  Description: Re: Splitter Component
  Author: R.VENKATESH
  Date: 05-31-96  09:17
*)


*****************************************************************************
The following component might help you.
This is derived from TCustomPanel
To install:
        Put this source in a unit.
        Compile to a DCU
        Install it on a component palette
To use:
        To use as vertical split.
                1. Put a panel in the form. Align it to the top 
                    Let us call it DynamicPanel
                    Set Align property to alTop
                2. Add the TSplitBar component,
                    Set the SplitStyle property to splitVertical
                    Set Align property to alTop
                     Set the AdjucentControl to DynamicPanel
               3. Add a third panel and set Align property to alClient
                 4. Run the application. Click and drag the splitbar 
                5. Is this what you wanted.

You can make horizontal or vertical split, combination of both, any no
of splits in a single form. Just use the TPanel, TSplitBar and Align
properties with imaginations.

**** BUG ****
If you assign a control as the AdjuscentControl and later delete it,
this won't be reflected in the SplitBar component. This might generate
faults.
There are few more improvements that can be made. Correct it and
enjoy.
***************

kind regards
R.Venkatesh

{ ************* The source starts here ****************** }
unit Splitbar;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TSplitStyles = ( splitVertical, splitHorizontal );

  TSplitBar = class(TCustomPanel)
  private
     FSplitStyle : TSplitStyles;
     InResize    : Boolean;
     FAdjControl : TWinControl;
     OldX, OldY  : Integer;

     procedure SetSplitStyle(TheStyle : TSplitStyles);

  protected
     procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
                                 X, Y: Integer); Override;

     procedure MouseMove( Shift: TShiftState; X,Y : Integer);
Override;
     procedure MouseUp( Button: TMouseButton; Shift: TShiftState;
                                 X, Y: Integer); Override;
  public
     constructor Create( AOwner : TComponent); override;
     destructor Destroy; override;
  published
     property Align;
     property AdjucentControl : TWinControl read FAdjControl write
FAdjControl;
     property Enabled;
     property ShowHint;
     property SplitStyle : TSplitStyles read FSplitStyle write
SetSplitStyle;
  end;

procedure Register;

implementation

{*****************************************************************************}
procedure Register;
begin
  RegisterComponents('Samples', [TSplitBar]);
end;
{.........................................................................}
constructor TSplitBar.Create( AOwner : TComponent );
begin
   inherited Create(AOwner);
   Caption     := ' ';
   InResize    := False;
end;
{.........................................................................}
destructor TSplitBar.Destroy;
begin
   inherited Destroy;
end;
{.........................................................................}
procedure TSplitBar.SetSplitStyle(TheStyle : TSplitStyles);
begin
   FSplitStyle := TheStyle;
   { The following code is unncessory. 
      You can do this in design time itself }
   if TheStyle = splitVertical then
   begin
      Align := alTop;
      Cursor := crVSplit;
   end
   else
   begin
      Align := alLeft;
      Cursor := crHSplit;
   end;
end;
{.........................................................................}
procedure TSplitBar.MouseDown( Button: TMouseButton; Shift:
                                TShiftState;   X, Y: Integer);
begin
   inherited MouseDown(Button, Shift, X, Y);
   If NOT Enabled Then Exit;
   if FAdjControl = Nil then Exit;
   InResize := True;
   OldX := X;
   OldY := Y;
end;
{.........................................................................}
procedure TSplitBar.MouseMove( Shift: TShiftState; X,Y: Integer);
begin
   inherited MouseMove( Shift, X, Y);
   if InResize then
   begin
      if FSplitStyle = splitHorizontal then
         FAdjControl.Width := FAdjControl.Width + (X - OldX)
      else
         FAdjControl.Height := FAdjControl.Height + (Y - OldY)
   end;
end;
{.........................................................................}
procedure TSplitBar.MouseUp( Button: TMouseButton; Shift: TShiftState;
                             X, Y: Integer);
begin
   inherited MouseUp( Button, Shift, X, Y);
   InResize := False;
end;

{.........................................................................}

end.

{ ********** End of source ********************** }

