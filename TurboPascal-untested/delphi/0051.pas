
{
// DBPICGRD.PAS (C) 1995 W. Raike
//              ALL RIGHTS RESERVED.
//
//    DESCRIPTION:
//      Data-aware grid that can display graphic fields.
//    REVISION HISTORY:
//      15/04/95  Created.    W. Raike
}

unit DBPicGrd;

interface

uses
  DBGrids, DB, DBTables, Grids, WinTypes, Classes, Graphics;

type
  TDBPicGrid = class(TDBGrid)
  protected
    procedure DrawDataCell(const Rect: TRect;
      Field: TField; State: TGridDrawState); override;
  public
    constructor Create(AOwner : TComponent); override;
  published
    property DefaultDrawing default False;
  end;

procedure Register;

implementation

constructor TDBPicGrid.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  DefaultDrawing := False;
end;

procedure TDBPicGrid.DrawDataCell(const Rect: TRect; Field: TField;
State: TGridDrawState);
var
  bmp : TBitmap;
begin
  with Canvas do
  begin
    FillRect(Rect);
    if Field is TGraphicField then
        try
          bmp := TBitmap.Create;
          bmp.Assign(Field);
          Draw(Rect.Left, Rect.Top, bmp);
        finally
          bmp.Free;
        end
    else
      TextOut(Rect.Left, Rect.Top, Field.Text);
  end;
end;

procedure Register;
begin
  RegisterComponents('Custom', [TDBPicGrid]);
end;

end.
