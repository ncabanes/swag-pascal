(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0332.PAS
  Description: TMemo Component with ChgPos Property
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:09
*)

unit Msgmemo;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;
type
  TPosChangeEvent=procedure(var row,col:integer) of object;

  TMessageMemo = class(TMemo)
  private
    FHandled:boolean;
    FPosChange:TposChangeEvent;
  protected
    procedure PosChange;
  public
    constructor create(Aowner:Tcomponent);override;
    procedure KeyDown(var key:word;shift:TShiftState);override;
    procedure KeyPress(var key:char);override;
    procedure MouseDown(button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
  published
    property OnPosChange:TPosChangeEvent read FPosChange write FposChange;
    property OnKeypress;
    property OnMouseDown;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TMessageMemo]);
end;

constructor Tmessagememo.create;
begin
  inherited create(aowner);
  wordwrap:=false;
  Fhandled:=true;
end;

procedure TmessageMemo.KeyDown(var key:word;shift:TShiftState);
begin
  PosChange;
  FHandled:=true;
  inherited keydown(key,shift);
end;

procedure TmessageMemo.KeyPress(var key:char);
begin
  if not FHandled then exit;
  if key<>#0 then
  begin
    PosChange;
    FHandled:=false;
  end;
  inherited keypress(key);
end;

procedure TMessageMemo.mousedown(button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PosChange;
  inherited mousedown(button,shift,x,y);
end;

procedure TMessageMemo.PosChange;
var x,x2,y:integer;
begin
  y:=SendMessage(Handle, EM_LINEFROMCHAR, $FFFF, 0);
  x2:=SendMessage(Handle, EM_LINEINDEX, $FFFF, 0);
  x:=selStart - x2;
  if assigned(FposChange) then FposChange(y,x);
end;

end.

