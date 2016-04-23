{ see test program at the end of this unit !! }
{************************************************}
{                                                }
{   UNIT GRAFOBJ   OOP graphical objects         }
{   Copyright (c) 1994-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

(*
  Some few words on this unit:
  ----------------------------

   - This units works fine with Turbo Pascal 6 or higher. If you use
     TP/BP 7 you can use the "inherited" command as shown in the
     comment lines on each line where it is possible.

   - All INIT methods have at least the paramter VISIBLE. When calling
     an inhertied INIT this parameter is allways FALSE so only the
     inherited data fields will be updated, the inherited object will
     not be displayed. When using an instance of an object one can
     use VISIBLE TRUE to display the object on the screen.

   - The methode SHOW draws an object on the current position and the
     current color on the screen.

   - The methode HIDE deletes an object from the screen by redrawing it
     in the background color.

   - The methode MOVE moves an object on the screen by hiding it, changing
     the position and redrawing it.

   - The methode COPY copies an object to another position on the screen.
     The difference between COPY and MOVE is that COPY do not hide the
     object before changing the position. Note that from this point on
     you won't be able to access the "old" object since is only a copy
     and not the real object.

   - The methode CHANGECOLOR changes the color of an object by changing
     the field COLOR and calling SHOW.

   - The methode GETPOS returns the current coordinats X and Y of an
     object. If an object have more than one coordinate (e.g. rectangle)
     one have to calculate the otheres if they are of interest.

   - The methode GETCOLOR returns the current color of an object.

   - The methode ISINVIEW checks if an object is fully visible on the
     screen or has moved over one edge. It returns the following codes:

          0 = fully visible on screen
         -1 = passed across the left side of the screen
          1 = passed across the right side of the screen
         -2 = passed across the upper side of the screen
          2 = passed across the lower side of the screen

   - Some inheritances defining some specific methodes like
     CHANGERADIUS or CHANGELENGTH

*)



unit GrafObj;

interface

uses graph, objects;


type
   PPoint = ^TPoint;
   TPoint = object(TObject)
       x, y, color, background: integer;
     constructor Init(ax, ay, acolor: integer; visible: boolean);
     procedure Show; virtual;                          { draw point      }
     procedure Hide; virtual;                          { delete point    }
     procedure Move(ax, ay: integer); virtual;         { move point      }
     procedure Copy(ax, ay: integer); virtual;         { copy point      }
     procedure ChangeColor(acolor: integer); virtual;  { change color    }
     procedure GetPos(var ax, ay: integer); virtual;   { request X and Y }
     function  GetColor: integer; virtual;             { request color   }
     function  IsInView: integer; virtual;             { is on screen ?  }
   end;

   PCircle = ^TCircle;
   TCircle = object(TPoint)
       radius: word;
     constructor Init(ax, ay, aradius, acolor: integer; visible: boolean);
     procedure Show; virtual;
     procedure Hide; virtual;
     function  IsInView: integer; virtual;
     procedure ChangeRadius(aradius: integer); virtual; { change radius  }
   end;

   PLine = ^TLine;
   TLine = object(TPoint)
       x2, y2: word;
     constructor Init(ax1, ay1, ax2, ay2, acolor: integer; visible: boolean);
     procedure Show; virtual;
     procedure Hide; virtual;
     procedure Move(ax, ay: integer); virtual;
     procedure Copy(ax, ay: integer); virtual;
     function  IsInView: integer; virtual;
     procedure ChangeLength(ax2, ay2: integer); virtual; { change length }
   end;

   PRectangle = ^TRectangle;
   TRectangle = object(TLine)
     procedure Show; virtual;
     procedure Hide; virtual;
   end;

   PTriangle = ^TTriangle;
   TTriangle = object(TLine)
       x3, y3: integer;
     constructor Init(ax1, ay1, ax2, ay2, ax3, ay3, acolor: integer;
                      visible: boolean);
     procedure Show; virtual;
     procedure Hide; virtual;
     procedure Move(ax, ay: integer); virtual;
     procedure Copy(ax, ay: integer); virtual;
     function  IsInView: integer; virtual;
   end;


implementation

(********************************************************************)
(**                            TPoint                              **)
(********************************************************************)

constructor TPoint.Init(ax, ay, acolor: integer; visible: boolean);
begin
  { TP/BP7: inherited Init; }
  TObject.Init;
  x:= ax;
  y:= ay;
  color:= acolor;
  background:= GetPixel(x, y);
  if visible then Show;
end;

procedure TPoint.Show;
begin
  PutPixel(x, y, GetColor);
end;

procedure TPoint.Hide;
begin
  PutPixel(x, y, background);
end;

procedure TPoint.Move(ax, ay: integer);
begin
  Hide;
  x:= ax;
  y:= ay;
  Show;
end;

procedure TPoint.Copy(ax, ay: integer);
begin
  x:= ax;
  y:= ay;
  Show;
end;

procedure TPoint.ChangeColor(acolor: integer);
begin
  color:= acolor;
  Show;
end;

procedure TPoint.GetPos(var ax, ay: integer);
begin
  ax:= x;
  ay:= y;
end;

function TPoint.GetColor: integer;
begin
  GetColor:= color;
end;

function TPoint.IsInView: integer;
begin
  if x < 1 then IsInView:= -1 else
    if x > GetMaxX then IsInView:= 1 else
      if y < 1 then IsInView:= -2 else
        if y > GetMaxY then IsInView:= 2 else
          IsInView:= 0;
end;



(********************************************************************)
(**                            TCircle                             **)
(********************************************************************)

constructor TCircle.Init(ax, ay, aradius, acolor: integer;
                         visible: boolean);
begin
  { TP/BP7: inherited Init(ax, ay, acolor, false); }
  TPoint.Init(ax, ay, acolor, false);
  radius:= aradius;
  if visible then Show;
end;

procedure TCircle.Show;
begin
  SetColor(GetColor);
  Circle(x, y, radius);
end;

procedure TCircle.Hide;
begin
  SetColor(background);
  Circle(x, y, radius);
end;

function TCircle.IsInView: integer;
begin
  if x - radius < 0 then IsInView:= -1 else
    if x + radius > GetMaxX then IsInView:= 1 else
      if y - radius < 0 then IsInView:= -2 else
        if y + radius > GetMaxY then IsInView:= 2 else
          IsInView:= 0;
end;

procedure TCircle.ChangeRadius(aradius: integer);
begin
  Hide;
  radius:= aradius;
  Show;
end;


(********************************************************************)
(**                            TLine                               **)
(********************************************************************)

constructor TLine.Init(ax1, ay1, ax2, ay2, acolor: integer;
                       visible: boolean);
begin
  { TP/BP7: inherited Init(ax1, ay1, acolor, false); }
  TPoint.Init(ax1, ay1, acolor, false);
  x2:= ax2;
  y2:= ay2;
  if visible then Show;
end;

procedure TLine.Show;
begin
  SetColor(GetColor);
  Line(x, y, x2, y2);
end;

procedure TLine.Hide;
begin
  SetColor(background);
  Line(x, y, x2, y2);
end;

procedure TLine.Move(ax, ay: integer);
begin
  Hide;
  x2:= ax + (x2 - x);
  y2:= ay + (y2 - y);
  { TP/BP7: inherited Move(ax, ay); }
  TPoint.Move(ax, ay);
end;

procedure TLine.Copy(ax, ay: integer);
begin
  x2:= ax + (x2 - x);
  y2:= ay + (y2 - y);
  { TP/BP7: inherited Copy(ax, ay); }
  TPoint.Copy(ax, ay);
end;

function TLine.IsInView: integer;
begin
  if (x < 1) or (x2 < 1) then IsInView:= -1 else
    if (x > GetMaxX) or (x2 > GetMaxX) then IsInView:= 1 else
      if (y < 1) or (y2 < 1) then IsInView:= -2 else
        if (y > GetMaxY) or (y2 > GetMaxY) then IsInView:= 2 else
          IsInView:= 0;
end;

procedure TLine.ChangeLength(ax2, ay2: integer);
begin
  Hide;
  x2:= ax2;
  y2:= ay2;
  Show;
end;


(********************************************************************)
(**                           TRectangle                           **)
(********************************************************************)

procedure TRectangle.Show;
begin
  SetColor(GetColor);
  Rectangle(x, y, x2, y2);
end;

procedure TRectangle.Hide;
begin
  SetColor(background);
  Rectangle(x, y, x2, y2);
end;



(********************************************************************)
(**                           TTriangle                            **)
(********************************************************************)

constructor TTriangle.Init(ax1, ay1, ax2, ay2, ax3, ay3, acolor: integer;
                           visible: boolean);
begin
  { TP/BP7: inherited Init(ax1, ay1, ax2, ay2, acolor, false); }
  TLine.Init(ax1, ay1, ax2, ay2, acolor, false);
  x3:= ax3;
  y3:= ay3;
  if visible then Show;
end;

procedure TTriangle.Show;
begin
  SetColor(GetColor);
  Line(x,y,   x2,y2);
  Line(x,y,   x3,y3);
  Line(x2,y2, x3,y3);
end;

procedure TTriangle.Hide;
begin
  SetColor(background);
  Line(x,y,   x2,y2);
  Line(x,y,   x3,y3);
  Line(x2,y2, x3,y3);
end;

procedure TTriangle.Move(ax, ay: integer);
var dx, dy: integer;
begin
  Hide;
  dx:= x3 - x; x3:= ax + dx;
  dy:= y3 - y; y3:= ay + dy;
  dx:= x2 - x; x2:= ax + dx;
  dy:= y2 - y; y2:= ay + dy;
  x := ax;     y := ay;
  Show;
end;

procedure TTriangle.Copy(ax, ay: integer);
var dx, dy: integer;
begin
  dx:= x3 - x; x3:= ax + dx;
  dy:= y3 - y; y3:= ay + dy;
  dx:= x2 - x; x2:= ax + dx;
  dy:= y2 - y; y2:= ay + dy;
  x := ax;     y := ay;
  Show;
end;

function TTriangle.IsInView: integer;
begin
  if (x < 1) or (x2 < 1) or (x3 < 1) then IsInView:= -1 else
    if (x > GetMaxX) or (x2 > GetMaxX) or (x3 > GetMaxX) then IsInView:= 1 else
      if (y < 1) or (y2 < 1) or (y3 < 1) then IsInView:= -2 else
        if (y > GetMaxY) or (y2 > GetMaxY) or (y3 > GetMaxY) then IsInView:= 2 else
          IsInView:= 0;
end;

end.

{************************************************}
{                                                }
{   PROGRAM GRAFDEMO   Testapp for GRAFOBJ Unit  }
{   Copyright (c) 1994-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

program grafdemo;

uses crt, graph, grafobj;


procedure DoGraphics;
var
  xC, yC, cC, dCx, dCy: integer;
  xR, yR, cR, dRx, dRy: integer;
  xT, yT, cT, dTx, dTy: integer;
  C: TCircle;
  R: TRectangle;
  T: TTriangle;
begin
  { Setting the coordinates of the first position and define the
    size of the "steps" the object makes on the screen. }
  xC:= 60; yC:= 60; cC:= 12; dCx:= 1; dCy:= 1;
  C.Init(xC, yC, 50, cC, true);

  xR:= 10; yR:= 160; cR:= 10; dRx:= -2; dRy:= 2;
  R.Init(xR, yR, xR+70, yR+50, cR, true);

  xT:= 200; yT:= 200; cT:= 14; dTx:= 1; dTy:= -1;
  T.Init(xT, yT, xT-30, yT+50, xT+30, yT+50, cT, true);

  repeat
    { Is object still fully visible on screen. If not change direction
      of moving. }
    case C.IsInView of
      -1: dCx:=  1;
       1: dCx:= -1;
      -2: dCy:=  1;
       2: dCy:= -1;
    end;

    case R.IsInView of
      -1: dRx:=  2;
       1: dRx:= -2;
      -2: dRy:=  2;
       2: dRy:= -2;
    end;

    case T.IsInView of
      -1: dTx:=  1;
       1: dTx:= -1;
      -2: dTy:=  1;
       2: dTy:= -1;
    end;

    { Calculate the new position and MOVE each object. One can also
      try COPY. }
    xC:= xC + dCx; yC:= yC + dCy;
    { C.Copy(xC, yC); }
    C.Move(xC, yC);

    xR:= xR + dRx; yR:= yR + dRy;
    { R.Copy(xR, yR); }
    R.Move(xR, yR);

    xT:= xT + dTx; yT:= yT + dTy;
    { T.Copy(xT, yT); }
    T.Move(xT, yT);

    delay(5);
  until keypressed;
  readkey;
end;


const
  PathToDriver = 'c:\bp\bgi';       (* change if necessary !!! *)

var
  grDriver: Integer;
  grMode  : Integer;
  ErrCode : Integer;

begin
  grDriver:= Detect;
  InitGraph(grDriver, grMode, PathToDriver);
  ErrCode:= GraphResult;
  if ErrCode <> grOk then
    Writeln('Graphics error:', GraphErrorMsg(ErrCode)) else
  begin
    DoGraphics;
    CloseGraph;
  end;
end.

