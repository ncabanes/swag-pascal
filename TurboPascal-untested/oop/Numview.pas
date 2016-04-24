(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0006.PAS
  Description: NUMVIEW.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

Unit NumView;

Interface

Uses
  Views, Objects, Drivers;

Type
  PNumView = ^TNumView;
  TNumView = Object(TView)
  Number : LongInt;

  Constructor init(Var Bounds: Trect);
  Procedure update(num:LongInt);
  Procedure draw; Virtual;
  Destructor done; Virtual;
  end;

Implementation

{---------------------------}
{                           }
{     TNumView  Methods     }
{                           }
{---------------------------}
Constructor TNumView.Init(Var Bounds: Trect);
begin
  inherited init(Bounds);
end;

Procedure TNumView.Update(num:LongInt);
begin
  Number := num; Draw;
end;

Procedure TNumView.Draw; Var
  B: TDrawBuffer;
  C: Word;
  Display : String;
begin
  C := GetColor(6);
  MoveChar(B, ' ', C, Size.X);
  Str(Number,Display);
  MoveStr(B, Display,C);
  WriteLine(0, 0, Size.X,Length(Display), B);
end;

Destructor TNumView.Done;
begin
  inherited done;
end;

end.


