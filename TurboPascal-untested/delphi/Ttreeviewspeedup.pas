(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0444.PAS
  Description: TTreeview-speedup
  Author: HAAKON EINES
  Date: 01-02-98  07:34
*)


Haakon Eines <haakon.eines@finale.no>

Here's a little TreeView-component that might be a little bit faster
than the default TTreeView from Borland. You also have the ability
to set the items text to bold (It's implemented as methods of the
treeview, but should have been a TTreeNode's property. Since
I can't release VCL source code - methods it is).

Some timings:
  TTreeView:
    128 sec. to load 1000 items (no sorting)*
    270 sec. to save 1000 items (4.5 minutes!!!)

  THETreeView:
    1.5 sec. to load 1000 items - about 850% faster!!! (2.3 seconds
				with  sorting = stText)*
    0.7 sec. to save 1000 items - about 3850% faster!!!
NOTES: 
All timings performed on a slow 486SX 33 MhZ, 20 Mb RAM. 
If the treeview is empty, loading takes 1.5 seconds, else add 1.5 seconds to clear 1000 items (a total loading time of 3 seconds). This is also the case for the TTreeView component (a total of 129.5 seconds). The process of clearing the items, is a call to SendMessage(hwnd, TVM_DELETEITEM, 0, Longint(TVI_ROOT)). 
Have fun playing with the component.
--------------------------------------------------------------------------------
 
unit HETreeView;
{$R-}

// Made by: Hσkon Eines
// EMail:   haakon.eines@finale.no
// Date: 21.01.1997
// Description: A Speedy TreeView?
(*
  TTREEVIEW:
    128 sec. to load 1000 items (no sorting)*
    270 sec. to save 1000 items (4.5 minutes!!!)

  THETREEVIEW:
    1.5 sec. to load 1000 items - about 850% faster!!! (2.3 seconds with sorting = stText)*
    0.7 sec. to save 1000 items - about 3850% faster!!!

  NOTES:
  - All timings performed on a slow 486SX 33 MhZ, 20 Mb RAM.

  - * If the treeview is empty, loading takes 1.5 seconds,
    else add 1.5 seconds to clear 1000 items (a total loading time of 3 seconds).
    This is also the case for the TTreeView component (a total of 129.5 seconds).
    The process of clearing the items, is a call to
    SendMessage(hwnd, TVM_DELETEITEM, 0, Longint(TVI_ROOT)).
*)

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls, CommCtrl, tree2vw;

type
  THETreeView = class(TTreeView)
  private
    FSortType: TSortType;
    procedure SetSortType(Value: TSortType);
  protected
    function GetItemText(ANode: TTreeNode): string;
  public
    constructor Create(AOwner: TComponent); override;
    function AlphaSort: Boolean;
    function CustomSort(SortProc: TTVCompare; Data: Longint): Boolean;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure GetItemList(AList: TStrings);
    procedure SetItemList(AList: TStrings);
    //'Bold' should have been a property of TTreeNode, but...
    function IsItemBold(ANode: TTreeNode): Boolean;
    procedure SetItemBold(ANode: TTreeNode; Value: Boolean);
  published
    property SortType: TSortType read FSortType write SetSortType default stNone;
  end;

  procedure Register;

implementation

function DefaultTreeViewSort(Node1, Node2: TTreeNode; lParam: Integer): Integer; stdcall;
begin
  {with Node1 do
    if Assigned(TreeView.OnCompare) then
      TreeView.OnCompare(Node1.TreeView, Node1, Node2, lParam, Result)
    else}
  Result := lstrcmp(PChar(Node1.Text), PChar(Node2.Text));
end;

constructor THETreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSortType := stNone;
end;

procedure THETreeView.SetItemBold(ANode: TTreeNode; Value: Boolean);
var
  Item: TTVItem;
  Template: Integer;
begin
  if ANode = nil then Exit;

  if Value then Template := -1
  else Template := 0;
  with Item do
  begin
    mask := TVIF_STATE;
    hItem := ANode.ItemId;
    stateMask := TVIS_BOLD;
    state := stateMask and Template;
  end;
  TreeView_SetItem(Handle, Item);
end;

function THETreeView.IsItemBold(ANode: TTreeNode): Boolean;
var
  Item: TTVItem;
begin
  Result := False;
  if ANode = nil then Exit;

  with Item do
  begin
    mask := TVIF_STATE;
    hItem := ANode.ItemId;
    if TreeView_GetItem(Handle, Item) then
      Result := (state and TVIS_BOLD) <> 0;
  end;
end;

procedure THETreeView.SetSortType(Value: TSortType);
begin
  if SortType <> Value then
  begin
    FSortType := Value;
    if ((SortType in [stData, stBoth]) and Assigned(OnCompare)) or
      (SortType in [stText, stBoth]) then
      AlphaSort;
  end;
end;

procedure THETreeView.LoadFromFile(const AFileName: string);
var
  AList: TStringList;
begin
  AList := TStringList.Create;
  Items.BeginUpdate;
  try
    AList.LoadFromFile(AFileName);
    SetItemList(AList);
  finally
    Items.EndUpdate;
    AList.Free;
  end;
end;

procedure THETreeView.SaveToFile(const AFileName: string);
var
  AList: TStringList;
begin
  AList := TStringList.Create;
  try
    GetItemList(AList);
    AList.SaveToFile(AFileName);
  finally
    AList.Free;
  end;
end;

procedure THETreeView.SetItemList(AList: TStrings);
var
  ALevel, AOldLevel, i, Cnt: Integer;
  S: string;
  ANewStr: string;
  AParentNode: TTreeNode;
  TmpSort: TSortType;

  function GetBufStart(Buffer: PChar; var ALevel: Integer): PChar;
  begin
    ALevel := 0;
    while Buffer^ in [' ', #9] do
    begin
      Inc(Buffer);
      Inc(ALevel);
    end;
    Result := Buffer;
  end;

begin
  //Delete all items - could have used Items.Clear (almost as fast)
  SendMessage(handle, TVM_DELETEITEM, 0, Longint(TVI_ROOT));
  AOldLevel := 0;
  AParentNode := nil;

  //Switch sorting off
  TmpSort := SortType;
  SortType := stNone;
  try
    for Cnt := 0 to AList.Count-1 do
    begin
      S := AList[Cnt];
      if (Length(S) = 1) and (S[1] = Chr($1A)) then Break;

      ANewStr := GetBufStart(PChar(S), ALevel);
      if (ALevel > AOldLevel) or (AParentNode = nil) then
      begin
        if ALevel - AOldLevel > 1 then raise Exception.Create('Invalid TreeNode Level');
      end
      else begin
        for i := AOldLevel downto ALevel do
        begin
          AParentNode := AParentNode.Parent;
          if (AParentNode = nil) and (i - ALevel > 0) then
            raise Exception.Create('Invalid TreeNode Level');
        end;
      end;
      AParentNode := Items.AddChild(AParentNode, ANewStr);
      AOldLevel := ALevel;
    end;
  finally
    //Switch sorting back to whatever it was...
    SortType := TmpSort;
  end;
end;

procedure THETreeView.GetItemList(AList: TStrings);
var
  i, Cnt: integer;
  ANode: TTreeNode;
begin
  AList.Clear;
  Cnt := Items.Count -1;
  ANode := Items.GetFirstNode;
  for i := 0 to Cnt do
  begin
    AList.Add(GetItemText(ANode));
    ANode := ANode.GetNext;
  end;
end;

function THETreeView.GetItemText(ANode: TTreeNode): string;
begin
  Result := StringOfChar(' ', ANode.Level) + ANode.Text;
end;

function THETreeView.AlphaSort: Boolean;
var
  I: Integer;
begin
  if HandleAllocated then
  begin
    Result := CustomSort(nil, 0);
  end
  else Result := False;
end;

function THETreeView.CustomSort(SortProc: TTVCompare; Data: Longint): Boolean;
var
  SortCB: TTVSortCB;
  I: Integer;
  Node: TTreeNode;
begin
  Result := False;
  if HandleAllocated then
  begin
    with SortCB do
    begin
      if not Assigned(SortProc) then lpfnCompare := @DefaultTreeViewSort
      else lpfnCompare := SortProc;
      hParent := TVI_ROOT;
      lParam := Data;
      Result := TreeView_SortChildrenCB(Handle, SortCB, 0);
    end;

    if Items.Count > 0 then
    begin
      Node := Items.GetFirstNode;
      while Node <> nil do
      begin
        if Node.HasChildren then Node.CustomSort(SortProc, Data);
        Node := Node.GetNext;
      end;
    end;
  end;
end;

//Component Registration
procedure Register;
begin
  RegisterComponents('Win95', [THETreeView]);
end;


end.


