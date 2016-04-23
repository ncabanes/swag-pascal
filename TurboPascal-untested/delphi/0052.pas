
{Here's a TDBGrid derivative that exposes the Col, Row and Canvas properties
as well as the CellRect method.  This is extremely useful if you would like
to, for example, pop a dropdown list over a cell when the user enters.
}

unit VUBComps;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DBGrids, DB, Menus;

type
  TDBGridVUB = class(TDBGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    property Canvas;
    function CellRect(ACol, ARow: Longint): TRect;
    property Col;
    property Row;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('VUBudget', [TDBGridVUB]);
end;

function TDBGridVUB.CellRect(ACol, ARow: Longint): TRect;
begin
  Result := inherited CellRect(ACol, ARow);
end;

end.
