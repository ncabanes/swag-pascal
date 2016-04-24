(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0090.PAS
  Description: TPanel component that allows Drag/Drop
  Author: IBOA
  Date: 02-21-96  21:03
*)

unit DropPnl;

{ (C) 1995, ingenieursbureau Office Automation
  All Rights Reserved

  Hereby the right to distribute this work electronically is granted,
  provided such is done for at most a nominal fee. Also the right is
  granted to store this work on a computer system.
  Finally the right is granted to incorporate this work into other
  work provided no fee is asked for this work.
  In all cases of distribution this work must be distributed in full,
  which specifically includes this notice.
  Liability is limited to the amount payed for this work. Legal
  jurisdiction is with the court of Leeuwarden, the Netherlands.

  Roelof Osinga, 29 december 1995
}

interface

uses
  WinTypes, WinProcs, Messages, Classes, Controls, Forms, Graphics,
  StdCtrls, ExtCtrls, Buttons, ShellApi, SysUtils;

type
  TDropActions = (daSimple, daRecursive, daEventOnly);

  TDropEvent = procedure(Sender : TObject; FileList : TStringList; X, Y: Integer) of object;

  TDropPanel = class(TPanel)
  protected
    FDroppedList : TStringList;
    FDroppedPoint : TPoint;
    FDropAction : TDropActions;
    FAtRunTime : boolean;
    FOnDrop : TDropEvent;
    function HandleDroppedGlyphs(aGlyph : TBitmap; const aStr : string) : integer;
    procedure HandleDroppedBitBtnGlyphs(aComp : TBitBtn; const aStr : string);
    procedure HandleDroppedSpeedButtonGlyphs(aComp : TSpeedButton; const aStr : string);
    procedure HandleDroppedFiles;
    function HandleDroppedFilesRec(aComp : TWinControl; dropAt : TPoint) : boolean;
    procedure CreateParams(var Params : TCreateParams); override;
    procedure WMDropFiles(var Message : TMessage); message WM_DROPFILES;
    destructor Destroy; override;
  public
    constructor Create(anOwner : TComponent); override;
  published
    property DropAction : TDropActions read FDropAction write FDropAction default daRecursive;
    property AtRunTime : boolean read FAtRunTime write FAtRunTime default true;
    property OnDrop : TDropEvent read FOnDrop write FOnDrop;
  end;

procedure Register;

implementation

constructor TDropPanel.Create(anOwner : TComponent);
begin
  inherited Create(anOwner);
  FDroppedList := TStringList.Create;
  FDroppedPoint := Point(0,0);
  FDropAction := daRecursive;
  FAtRunTime := true;
end;

destructor TDropPanel.Destroy;
begin
  FDroppedList.Free;
  inherited Destroy;
end;

procedure TDropPanel.CreateParams(var Params : TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_ACCEPTFILES;
  end;
end;

function TDropPanel.HandleDroppedGlyphs(aGlyph : TBitmap; const aStr : string) : integer;
var Glyphs : integer;
begin
  Result := 1;
  try
    aGlyph.LoadFromFile(aStr);
    if (aGlyph.Width mod aGlyph.Height) = 0
    then begin
      Glyphs := aGlyph.Width div aGlyph.Height;
      if Glyphs > 4
      then Glyphs := 1;
      Result := Glyphs;
    end;
  except
    ;
  end;
end;

procedure TDropPanel.HandleDroppedBitBtnGlyphs(aComp : TBitBtn; const aStr : string);
begin
  aComp.NumGlyphs := HandleDroppedGlyphs(aComp.Glyph, aStr); {FDroppedList[0]);}
end;

procedure TDropPanel.HandleDroppedSpeedButtonGlyphs(aComp : TSpeedButton; const aStr : string);
begin
  aComp.NumGlyphs := HandleDroppedGlyphs(aComp.Glyph, aStr); {FDroppedList[0]);}
end;

procedure TDropPanel.HandleDroppedFiles;
var
  i, j, nL, nC : integer;
  comp : TComponent;
begin
  nL := FDroppedList.Count - 1;
  if nL > -1
  then begin
    nC := ControlCount - 1;
    for i := 0 to nC do
    begin
      comp := Controls[i];
      if PtInRect(TControl(comp).BoundsRect, FDroppedPoint)
      then begin
         if comp is TImage
         then (comp as TImage).Picture.LoadFromFile(FDroppedList[0]);
         if comp is TMemo
         then (comp as TMemo).Lines.LoadFromFile(FDroppedList[0]);
         if (comp is TBitBtn)
         then HandleDroppedBitBtnGlyphs(TBitBtn(comp), FDroppedList[0]);
         if (comp is TSpeedButton)
         then HandleDroppedSpeedButtonGlyphs(TSpeedButton(comp), FDroppedList[0]);
       end;
    end;
  end;
end;

function TDropPanel.HandleDroppedFilesRec(aComp : TWinControl; dropAt : TPoint) : boolean;
var
  i, nL, nC : integer;
  done : boolean;
  aControl : TComponent;
begin
  done := false;
  nL := FDroppedList.Count - 1;
  if nL > -1
  then begin
    nC := aComp.ControlCount - 1;
    i := -1;
    while not done and (i < nC) do
    begin
      inc(i);
      aControl := aComp.Controls[i];
      if PtInRect(TControl(aControl).BoundsRect, dropAt)
      then begin
         if not done and (aControl is TImage)
         then begin
           try
             (aControl as TImage).Picture.LoadFromFile(FDroppedList[0]);
           except ;
           end;
           done := true;
         end;
         if not done and (aControl is TMemo)
         then begin
           (aControl as TMemo).Lines.LoadFromFile(FDroppedList[0]);
           done := true;
         end;
         if not done and (aControl is TBitBtn)
         then begin
           HandleDroppedBitBtnGlyphs(TBitBtn(aControl), FDroppedList[0]);
           done := true;
         end;
         if not done and (aControl is TSpeedButton)
         then begin
           HandleDroppedSpeedButtonGlyphs(TSpeedButton(aControl), FDroppedList[0]);
           done := true;
         end;
         if not done and (aControl is TWinControl) and
           not ((aControl is TMemo) or (aControl is TBitBtn))
         then begin
           done := HandleDroppedFilesRec(TWinControl(aControl),
                     TWinControl(aControl).ScreenToClient(aComp.ClientToScreen(dropAt)) );
         end;
       end;
    end;
  end;
  if not done and (aComp = Self)
  then MessageBeep(0);
  Result := done;
end;

procedure TDropPanel.WMDropFiles(var Message : TMessage);
var
  hDrop : THandle;
  nFiles, i, size : word;
  Pstr : PChar;
begin
  hDrop := Message.WParam;
  Pstr := StrAlloc(256);
  Message.Result := 0; {accept}
  try
    DragQueryPoint(hDrop, FDroppedPoint);
    nFiles := DragQueryFile(hDrop, $FFFF, Pstr, size);
    dec(nFiles);
    FDroppedList.Clear;
    for i := 0 to nFiles do
    begin
      {size := DragQueryFile(hDrop, i, nil, size);}
      size := 255;
      size := DragQueryFile(hDrop, i, Pstr, size+1);
      FDroppedList.Add(StrPas(Pstr));
    end;
  finally
    DragFinish(hDrop);
    StrDispose(Pstr);
  end;
  if Assigned(FOnDrop)
  then FOnDrop(Self, FDroppedList, FDroppedPoint.X, FDroppedPoint.Y);
  if FAtRunTime or (csDesigning in ComponentState)
  then
    case FDropAction of
      daSimple : HandleDroppedFiles;
      daRecursive : HandleDroppedFilesRec(Self, FDroppedPoint);
    end;
end;

procedure Register;
begin
  RegisterComponents('IBOA', [TDropPanel]);
end;

end.

