(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0193.PAS
  Description: New Styles in COMCTL32.DLL
  Author: COLIN WILSON
  Date: 11-29-96  08:17
*)

(*============================================================================*
 | The Internet Explorer release of COMCTL32.DLL introduced a number of new   |
 | styles.  These aren't documented anywhere yet by Microsoft, although they  |
 | do appear in the latest COMMCTRL.H supplied with VC4.2.  The styles mostly |
 | only work when the ViewStyle property is set to vsReport.                  |
 |                                                                            |
 | The new styles are:                                                        |
 |   GridLines        Displays thin, gray, horizontal and vertical lines      |
 |                    separating rows and columns.                            |
 |                                                                            |
 |   SubItemImages    Displays images against sub-items as well as items.     |
 |                                                                            |
 |   CheckBoxes       Displays a check box at the start of each row.          |
 |                                                                            |
 |   TrackSelect      Colours the item as you drag the mouse over it.         |
 |                    Automatically selects the item if you leave the mouse   |
 |                    on it.                                                  |
 |                                                                            |
 |   HeaderDragDrop   Enables drag/drop from the report header.               |
 |                                                                            |
 |   FullRowSelect    Highlights the entire row when you select it instead of |
 |                    just the first column data.                             |
 |                                                                            |
 |   OneClickActivate ??                                                      |
 |   TwoClickActivate ??                                                      |
 |                                                                            |
 | Note that this component doesn't do anything except set the appropriate    |
 | styles - so some styles may not be particularly useful.                    |
 |                                                                            |
 | Colin Wilson.  colin@wilsonc.demon.co.uk, or 100114.3641@compuserve.com    |
 *============================================================================*)

unit cmpExtendedListView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

const
  LVM_FIRST = $1000;
  LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54;

type
  TExtendedStyles = (lvexGridLines, lvexSubItemImages, lvexCheckBoxes, lvexTrackSelect,
                     lvexHeaderDragDrop, lvexFullRowSelect, lvexOneClickActivate, lvexTwoClickActivate);
  TExtendedStyleRange = lvexGridLines..lvexTwoClickActivate;
  TExtendedStyleSet = set of TExtendedStyleRange;

const
  LVS_EX_Styles : array [TExtendedStyleRange] of Integer = (
    $00000001, $00000002, $00000004, $00000008,
    $00000010, $00000020, $00000040, $00000080);

type
  TExtendedListView = class(TListView)
  private
    fExtendedStyle : TExtendedStyleSet;
    procedure SetExtendedStyle (value : TExtendedStyleSet);

  protected
    procedure CreateWnd; override;

  published
    property ExtendedStyle : TExtendedStyleSet read fExtendedStyle write SetExtendedStyle;
  end;

procedure Register;

implementation

procedure TExtendedListView.SetExtendedStyle (value : TExtendedStyleSet);
var
  exStyle : Integer;
  i : TExtendedStyleRange;
begin
  if HandleAllocated then
  begin
    exStyle := 0;
    for i := Low (TExtendedStyleRange) to High (TExtendedStyleRange) do
      if i in value then exStyle := exStyle or LVS_EX_STYLES [i];

    SendMessage(Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)
  end;
  fExtendedStyle := value;
  Refresh
end;

procedure TExtendedListView.CreateWnd;

begin
  inherited CreateWnd;
  SetExtendedStyle (fExtendedStyle);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TExtendedListView]);
end;

end.

