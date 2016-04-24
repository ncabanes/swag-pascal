(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0281.PAS
  Description: 3D stereogram maker
  Author: BOSTJAN GABROVSEK
  Date: 08-30-97  10:09
*)

{If you have any questions please send me mail at OleRom@hotmail.com}
{Example for 3d stereogram}
Program Stereogram;
Uses Graph;
Const Screen = 1;
Type Coord = (X, Y, Z);
     Direct = (Up, Down, Right, Left);
     Angle = (Mini, Maxi);
     EndPoint = Set of Direct;
     SType = Array[x..z] of Real;
     PSType = ^SType;
     PType = Array[x..y] of Real;
     PPType = ^PSType;
     Implicit = Function(S : sType): Real;
     ParamSurface = Procedure(U, V : Real; Var S : SType);
Procedure RayTrace(s0: sType; Var s1: sType; g : implicit); forward;
Procedure ProjectPoint(s0 : sType; Var s1 : Stype); forward;
Procedure MoveTo(S : SType); forward;
Procedure LineTo(S : sType; g : implicit); forward;
Procedure Line(s1, s2 : sType; g : implicit); forward;
Procedure Point(s : SType; Ch : Char; g : implicit); forward;
Procedure SetEyes(d, v, h : real); forward;
Procedure PlotSurface(f1 : implicit; f2 : ParamSurface;
                      u0, u1 : Real; m : integer;
                      v0, v1 : Real; n : integer); forward;
Procedure RandomDotSurface(N : Integer; Ch : Char; G : Implicit); forward;

Const ClipR : Array[Mini..Maxi, X..Y] of Real = ((0.05,0.05),(0.95,0.95));
      Curr : SType = (0,0,0);
Var Eyes : Array[0..1] of sType;
Function InSide(Var P : pType) : Boolean; forward;
Procedure SetEyes;
Begin
 Eyes[0][x] := (0.5 - d);
 Eyes[0][y] := (0.5 - v);
   Eyes[0][z] := h;
 Eyes[1][x] := (0.5 + d);
 Eyes[1][y] := (0.5 - v);
   Eyes[1][z] := h;
End;
Procedure EndPoints(P : PType; Var E : EndPoint);
Begin
 e := [];
 If P[y] > ClipR[maxi,y] then e := e + [up];
 If P[y] < ClipR[mini,y] then e := e + [down];
 If P[x] > ClipR[maxi,x] then e := e + [right];
 If P[x] < ClipR[mini,x] then e := e + [left];
End;
Function Clip(Var P1, P2 : PType) : Boolean;
Var E1, E2 : EndPoint;
 Procedure MXY(xy : Real; U : coord; Var P : PType);
 Var V : Coord;
 Begin
   V := Coord((ord(u)+1) mod 2);
   P[V] := (P2[v] - P1[v])*(xy - P1[u])/(P2[u] - P1[u]) + P1[v];
 End;
Begin
 EndPoints(P1,E1);
 EndPoints(P2,E2);
 If (E1 + E2) = [] then Begin Clip := True; exit; end;
 If (E1 * E2) <> [] then Begin Clip := False; exit; end;
 If Up in e1 then Begin mxy(ClipR[maxi,y],y,p1); EndPoints(P1,E1); end;
 If Down in e1 then Begin mxy(ClipR[mini,y],y,p1); EndPoints(P1,E1); end;
 If Right in e1 then Begin mxy(ClipR[maxi,x],x,p1); EndPoints(P1,E1); end;
 If Left in e1 then Begin mxy(ClipR[mini,x],x,p1); EndPoints(P1,E1); end;
 If Up in e2 then Begin mxy(ClipR[maxi,y],y,p2); EndPoints(P1,E2); end;
 If Down in e2 then Begin mxy(ClipR[mini,y],y,p2); EndPoints(P1,E2); end;
 If Right in e2 then Begin mxy(ClipR[maxi,x],x,p2); EndPoints(P1,E2); end;
 If Left in e2 then Begin mxy(ClipR[mini,x],x,p2); EndPoints(P1,E2); end;
 If (E1 + E2) = [] then Clip := True else Clip := False;
End;
Function Inside;
Begin
 Inside := (ClipR[mini,x] <= p[x]) and (p[x] <= ClipR[maxi,x]) and
           (ClipR[mini,y] <= p[y]) and (p[y] <= ClipR[maxi,y]);
End;
Procedure ProjectPoint(s0 : sType; Var s1 : Stype);
Var K : Real;
Begin
 K := (Screen - s0[z])/(s1[z] - s0[z]);
 S1[x] := S0[x] + k*(s1[x] - s0[x]);
 S1[y] := S0[y] + k*(s1[y] - s0[y]);
 S1[z] := Screen;
End;
Procedure RayTrace(s0: sType; Var s1: sType; g : implicit);
Var ds : SType;
    F, F1, DF, DF1, T0, T, T1, DT : Real;
    N : Integer;
    B : Boolean;
    I : Coord;
 Function ITRF(T : Real) : Real;
 Var I : Coord;
 Begin
  For I := x to z do s1[i] := s0[i] + t*ds[i];
  ITRF := G(s1);
 End;
Begin
 For I := x to z do DS[i] := S1[i] - s0[i];
 F := ITRF(0);
 T := 1;
 DT := -1;
 N := 0;
 B := False;
 Repeat
  Inc(N);
  F1 := ITRF(t);
  DF := (F -F1);
  F := F1;
  T1 := T - F*DT/DF;
  DT := T-T1;
  T := T1;
  If T1 > 10 then t1 := 10;
 Until (abs(F) < 0.001) or (N>100) or (DF = 0);
 For i := x to z do S1[i] := s0[i] + t1*ds[i];
End;
Procedure PLine(P1,P2 : PType);
Begin
 If Clip(P1,P2) then Graph.Line(Round(GetMaxX*P1[x]), Round(GetMaxY*(1-P1[y])),
 Round(GetMaxX*P2[x]), Round(GetMaxY*(1-P2[y])));
End;
Procedure PPoint(P : PType; Ch : Char);
Begin
 If Inside(P) then
  OutTextXY(Round(GetMaxX*p[x]),Round(GetMaxY*(1-p[y])),ch);
End;
Procedure MoveTo(S : SType);
 Begin Curr := S; End;
Procedure LineTo(S : sType; g : implicit);
Begin
 Line(Curr, s,g);
End;
Procedure Line;
Var St1, St2 : SType;
    PP1, PP2 : PType;
Begin
 If (S1[z] > Screen) or (S2[z] > Screen) then exit;
 St1 := s1;
 St2 := s2;
 ProjectPoint(Eyes[1],St1);
 ProjectPoint(Eyes[1],St2);
 Move(St1,PP1,SizeOF(PP1));
 Repeat
  Move(St1,PP1,SizeOF(PP1));
  Move(St2,PP2,SizeOF(PP1));
  PLine(pp1,pp2);
  RayTrace(Eyes[0],st1,g);
  RayTrace(Eyes[0],st2,g);
  ProjectPoint(Eyes[1],St1);
  ProjectPoint(Eyes[1],St2);
  Move(St1,PP1,SizeOf(PP1));
  Move(St2,PP2,SizeOf(PP1));
 Until not (Inside(PP1) or Inside(pp2));
St1 := s1;
St2 := s2;
ProjectPoint(Eyes[0],st1);ProjectPoint(Eyes[0],st2);
Repeat
  Move(St1,PP1,SizeOF(PP1));
  Move(St2,PP2,SizeOF(PP1));
  PLine(pp1,pp2);
  RayTrace(Eyes[1],st1,g);
  RayTrace(Eyes[1],st2,g);
  ProjectPoint(Eyes[0],St1);
  ProjectPoint(Eyes[0],St2);
  Move(St1,PP1,SizeOf(PP1));
  Move(St2,PP2,SizeOf(PP1));
Until not (Inside(PP1) or Inside(pp2));
End;
Procedure Point;
Var ST : SType;
    Pt : PType;
Begin
 If S[z] > Screen then exit;
 st := s;
 ProjectPoint(Eyes[1],st);
Repeat
 Move(St,Pt,SizeOF(Pt));
 PPoint(Pt,ch);
 RayTrace(Eyes[0],St,g);
 ProjectPoint(Eyes[1],st);
 Move(St,Pt,SizeOF(Pt));
Until not Inside(Pt);
St := s;
ProjectPoint(Eyes[0],st);
Repeat
 Move(St,Pt,SizeOF(Pt));
 PPoint(Pt,ch);
 RayTrace(Eyes[1],St,g);
 ProjectPoint(Eyes[0],st);
 Move(St,Pt,SizeOF(Pt));
Until not Inside(Pt);
End;
Procedure PlotSurface;
Var W : Coord;
i,j : integer;
u,du,v,dv : real;
p1 : sType;
Begin
 For W := x to z do p1[w] := 0;
 du := (u1-u0)/m;
 dv := (v1-v0)/n;
 u := u0;
 For I := 0 to m do
 Begin
  V := V0; F2(u,v,p1); MoveTo(p1);
 For J := 1 to N do begin
  V := V+dv; f2(u,v,p1); LineTo(P1,F1);
 end;
 u := u+du;
end;
v := v0;
for j := 0 to n do begin
 u := u0; f2(u,v,p1); MoveTo(p1);
   for i := 1 to m do begin
    u := u + du; f2(u,v,p1); LineTo(p1,f1);
   end;
   v := v + du;
end;
End;
Procedure RandomDotSurface(N : Integer; Ch : Char; G : Implicit);
Var I : Integer; S : Stype;
Begin
 Randomize;
 For I := 1 to N do
  Begin
   S[x] := Random;
   S[y] := Random; S[z] := Screen;
   SetColor(Random(15)); Point(S,Ch,g)
  End;
End;
Var Gm : Integer;
 g : implicit; s : sType;
Function F(S : SType) : Real; far;
Begin
 F := S[z] + 1 -sqr(0.5-s[x]) - sqr(0.5-s[y]);
End;
Procedure Sphere(u,v : real; var p : SType); far;
begin
 p[x] := 0.1+0.3*cos(u)*cos(v);
 p[y] := 0.5+0.3*sin(u)*cos(v);
 p[z] := 0.2*sin(v);
end;
Begin
 gm := 0;
 InitGraph(gm,gm,'');
 SetEyes(0.1,0,Screen+0.5);
 g := f;
 SetColor(Blue);
 RecTangle(Round(GetMaxX*ClipR[mini,x]),
           Round(GetMaxY*(1-ClipR[mini,y])),
           Round(GetMaxX*ClipR[maxi,x]),
           Round(GetMaxY*(1-ClipR[maxi,y])));
 RAndomDotSurface(50,'*',g);
 SetColor(Yellow);
{ PlotSurface(g,Sphere,0,2*pi,30,-pi/2,pi/2,15);}
 ReadLn;
 CloseGRaph;
End.

