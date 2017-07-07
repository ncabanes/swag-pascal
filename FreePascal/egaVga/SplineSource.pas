(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0131.PAS
  Description: CatMull-Rom spline source
  Author: LEON DEBOER
  Date: 08-25-94  09:11
*)

{
From: ldeboer@cougar.multiline.com.au (Leon DeBoer) }

{------------------------------------------------------------------------}
{          Catmull_Rom and BSpline Parametric Spline Program             }
{                                                                        }
{       All source written and devised by Leon de Boer, (c)1994          }
{       E-Mail:   ldeboer@cougar.multiline.com.au                        }
{                                                                        }
{       After many request and talk about spline techniques on the       }
{   internet I decided to break out my favourite spline programs and     }
{   donate to the discussion.                                            }
{                                                                        }
{     Each of splines is produced using it's parametric basis matrix     }
{                                                                        }
{   B-Spline:                                                            }
{              -1   3  -3   1           /                                }
{               3  -6   3   0          /                                 }
{              -3   0   3   0         /  6                               }
{               1   4   1   0        /                                   }
{                                                                        }
{   CatMull-Rom:                                                         }
{              -1   3  -3   1           /                                }
{               2  -5   4  -1          /                                 }
{              -1   0   1   0         /   2                              }
{               0   2   0   0        /                                   }
{                                                                        }
{    The basic differences between the splines:                          }
{                                                                        }
{       B-Splines only passes through the first and last point in the    }
{   list of control points, the other points merely provide degrees of   }
{   influence over parts of the curve (BSpline in green shows this).     }
{                                                                        }
{       Catmull-Rom splines is one of a few splines that actually pass   }
{   through each and every control point the tangent of the curve as     }
{   it passes P1 is the tangent of the slope between P0 and P2 (The      }
{   curve is shown in red)                                               }
{                                                                        }
{       There is another spline type that passes through all the         }
{   control points which was developed by Kochanek and Bartels and if    }
{   anybody knows the basis matrix could they E-Mail to me ASAP.         }
{                                                                        }
{      In the example shown the program produces 5 random points and     }
{   displays the 2 spline as well as the control points. You can alter   }
{   the number of points as well as the drawing resolution via the       }
{   appropriate parameters.                                              }
{------------------------------------------------------------------------}

PROGRAM Spline;

USES Graph;

TYPE
   Point3D = Record
     X, Y, Z: Real;
   End;

VAR  CtrlPt: Array [-1..80] Of Point3D;

PROCEDURE Spline_Calc (Ap, Bp, Cp, Dp: Point3D; T, D: Real; Var X, Y: Real);
VAR T2, T3: Real;
BEGIN
   T2 := T * T;                                       { Square of t }
   T3 := T2 * T;                                      { Cube of t }
   X := ((Ap.X*T3) + (Bp.X*T2) + (Cp.X*T) + Dp.X)/D;  { Calc x value }
   Y := ((Ap.Y*T3) + (Bp.Y*T2) + (Cp.Y*T) + Dp.Y)/D;  { Calc y value }
END;

PROCEDURE BSpline_ComputeCoeffs (N: Integer; Var Ap, Bp, Cp, Dp: Point3D);
BEGIN
   Ap.X := -CtrlPt[N-1].X + 3*CtrlPt[N].X - 3*CtrlPt[N+1].X + CtrlPt[N+2].X;
   Bp.X := 3*CtrlPt[N-1].X - 6*CtrlPt[N].X + 3*CtrlPt[N+1].X;
   Cp.X := -3*CtrlPt[N-1].X + 3*CtrlPt[N+1].X;
   Dp.X := CtrlPt[N-1].X + 4*CtrlPt[N].X + CtrlPt[N+1].X;
   Ap.Y := -CtrlPt[N-1].Y + 3*CtrlPt[N].Y - 3*CtrlPt[N+1].Y + CtrlPt[N+2].Y;
   Bp.Y := 3*CtrlPt[N-1].Y - 6*CtrlPt[N].Y + 3*CtrlPt[N+1].Y;
   Cp.Y := -3*CtrlPt[N-1].Y + 3*CtrlPt[N+1].Y;
   Dp.Y := CtrlPt[N-1].Y + 4*CtrlPt[N].Y + CtrlPt[N+1].Y;
END;

PROCEDURE Catmull_Rom_ComputeCoeffs (N: Integer; Var Ap, Bp, Cp, Dp: Point3D);
BEGIN
   Ap.X := -CtrlPt[N-1].X + 3*CtrlPt[N].X - 3*CtrlPt[N+1].X + CtrlPt[N+2].X;
   Bp.X := 2*CtrlPt[N-1].X - 5*CtrlPt[N].X + 4*CtrlPt[N+1].X - CtrlPt[N+2].X;
   Cp.X := -CtrlPt[N-1].X + CtrlPt[N+1].X;
   Dp.X := 2*CtrlPt[N].X;
   Ap.Y := -CtrlPt[N-1].Y + 3*CtrlPt[N].Y - 3*CtrlPt[N+1].Y + CtrlPt[N+2].Y;
   Bp.Y := 2*CtrlPt[N-1].Y - 5*CtrlPt[N].Y + 4*CtrlPt[N+1].Y - CtrlPt[N+2].Y;
   Cp.Y := -CtrlPt[N-1].Y + CtrlPt[N+1].Y;
   Dp.Y := 2*CtrlPt[N].Y;
END;

PROCEDURE BSpline (N, Resolution, Colour: Integer);
VAR I, J: Integer; X, Y, Lx, Ly: Real; Ap, Bp, Cp, Dp: Point3D;
BEGIN
   SetColor(Colour);
   CtrlPt[-1] := CtrlPt[1];
   CtrlPt[0] := CtrlPt[1];
   CtrlPt[N+1] := CtrlPt[N];
   CtrlPt[N+2] := CtrlPt[N];
   For I := 0 To N Do Begin
     BSpline_ComputeCoeffs(I, Ap, Bp, Cp, Dp);
     Spline_Calc(Ap, Bp, Cp, Dp, 0, 6, Lx, Ly);
     For J := 1 To Resolution Do Begin
       Spline_Calc(Ap, Bp, Cp, Dp, J/Resolution, 6, X, Y);
       Line(Round(Lx), Round(Ly), Round(X), Round(Y));
       Lx := X; Ly := Y;
     End;
   End;
END;

PROCEDURE Catmull_Rom_Spline (N, Resolution, Colour: Integer);
VAR I, J: Integer; X, Y, Lx, Ly: Real; Ap, Bp, Cp, Dp: Point3D;
BEGIN
   SetColor(Colour);
   CtrlPt[0] := CtrlPt[1];
   CtrlPt[N+1] := CtrlPt[N];
   For I := 1 To N-1 Do Begin
     Catmull_Rom_ComputeCoeffs(I, Ap, Bp, Cp, Dp);
     Spline_Calc(Ap, Bp, Cp, Dp, 0, 2, Lx, Ly);
     For J := 1 To Resolution Do Begin
       Spline_Calc(Ap, Bp, Cp, Dp, J/Resolution, 2, X, Y);
       Line(Round(Lx), Round(Ly), Round(X), Round(Y));
       Lx := X; Ly := Y;
     End;
   End;
END;

VAR I, J, Res, NumPts: Integer;
BEGIN
   I := Detect;
   InitGraph(I, J, 'e:\bp\bgi');
   I := GetMaxX; J := GetMaxY;
   Randomize;
   CtrlPt[1].X := Random(I); CtrlPt[1].Y := Random(J);
   CtrlPt[2].X := Random(I); CtrlPt[2].Y := Random(J);
   CtrlPt[3].X := Random(I); CtrlPt[3].Y := Random(J);
   CtrlPt[4].X := Random(I); CtrlPt[4].Y := Random(J);
   CtrlPt[5].X := Random(I); CtrlPt[5].Y := Random(J);
   Res := 20;
   NumPts := 5;
   BSpline(NumPts, Res, LightGreen);
   CatMull_Rom_Spline(NumPts, Res, LightRed);
   SetColor(Yellow);
   For I := 1 To NumPts Do Begin
     Line(Round(CtrlPt[I].X-3), Round(CtrlPt[I].Y),
       Round(CtrlPt[I].X+3), Round(CtrlPt[I].Y));
     Line(Round(CtrlPt[I].X), Round(CtrlPt[I].Y-3),
       Round(CtrlPt[I].X), Round(CtrlPt[I].Y+3));
   End;
   ReadLn;
   CloseGraph;
END.

