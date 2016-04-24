(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0102.PAS
  Description: 3D Rotation Objects
  Author: DAVID ROZENBERG
  Date: 08-24-94  12:55
*)


{ Here is a program to rotate any object in 3D. }

(********************************************************
 * This program was written by David Rozenberg          *
 *                                                      *
 * The program show how to convert a 3D point into a 2D *
 * plane like the computer screen. So it will give you  *
 * the illusion of 3D shape.                            *
 *                                                      *
 * You can rotate it by the keyboard arrows, for nonstop*
 * rotate press Shift+Arrow                             *
 *                                                      *
 * Please use the program as it is without changing it. *
 *                                                      *
 * Usage:                                               *
 *   3D FileName.Ext                                    *
 *                                                      *
 * There are some files for example how to build them   *
 * the header " ; 3D by David Rozenberg " must be at the*
 * beging of the file.                                  *
 *                                                      *
 ********************************************************)

Program G3d;
{$E+,N+}
Uses
 Crt,Graph;

Type
  Coordinate = Array[1..7] of Real;
  Point = Record
            X,Y,Z : Real;
          End;
  LineRec = ^LineType;
  LineType = Record
               FPoint,TPoint : Point;
               Color : Byte;
               Next  : LineRec;
             End;


Var
  FirstLine : LineRec;
  Last      : LineRec;

Procedure Init;
Var
  GraphDriver,GraphMode,GraphError : Integer;

Begin
  GraphDriver:=Detect;
  initGraph(GraphDriver,GraphMode,'\turbo\tp');  { your BGI driver address }
  GraphError:=GraphResult;
  if GraphError<>GrOk then begin
    clrscr;
    writeln('Error while turning to graphics mode.');
    writeln;
    halt(2);
  end;
End;


Function DegTRad(Deg : Real) : real;
Begin
  DegTRad:=Deg/180*Pi;
End;

Procedure ConvertPoint (P : Point;Var X,Y : Integer);
Var
  Dx,Dy : Real;

Begin
  X:=GetMaxX Div 2;
  Y:=GetMaxY Div 2;
  Dx:=(P.Y)*cos(pi/6);
  Dy:=-(P.Y)*Sin(Pi/6);
  Dx:=Dx+(P.X)*Cos(pi/3);
  Dy:=Dy+(P.X)*Sin(Pi/3);
  Dy:=Dy-P.Z;
  X:=X+Round(Dx);
  Y:=Y+Round(Dy);
End;

Procedure DrawLine(Lrec : LineRec);
Var
  Fx,Fy,Tx,Ty : Integer;

Begin
  SetColor(Lrec^.Color);
  ConvertPoint(LRec^.FPoint,Fx,Fy);
  ConvertPoint(LRec^.TPoint,Tx,Ty);
  Line(Fx,Fy,Tx,Ty);
End;

Procedure ShowLines;
Var
  Lp : LineRec;

Begin
  ClearDevice;
  Lp:=FirstLine;
  While Lp<>Nil do Begin
    DrawLine(Lp);
    Lp:=Lp^.Next;
  end;
End;

Procedure Error(Err : Byte;S : String);
Begin
  Clrscr;
  Writeln;
  Case Err of
    1 : Writeln('File : ',S,' not found!');
    2 : Writeln(S,' isn''t a 3d file!');
    3 : Writeln('Error in line :',S);
    4 : Writeln('No file was indicated');
  End;
  Writeln;
  Halt(Err);
End;

Procedure AddLine(Coord : Coordinate);
Var
  Lp : LineRec;

Begin
  New(Lp);
  Lp^.Color:=Round(Coord[7]);
  Lp^.FPoint.X:=Coord[1];
  Lp^.FPoint.Y:=Coord[2];
  Lp^.FPoint.Z:=Coord[3];
  Lp^.TPoint.X:=Coord[4];
  Lp^.TPoint.Y:=Coord[5];
  Lp^.TPoint.Z:=Coord[6];
  Lp^.Next:=Nil;
  If Last=Nil then FirstLine:=Lp else Last^.Next:=Lp;
  Last:=Lp;
end;

Procedure LoadFile(Name : String);
Var
  F : Text;
  Coord : Coordinate;
  S,S1 : String;
  I : Byte;
  LineNum : Word;
  Comma : Integer;

Begin
  FirstLine:=Nil;
  Last:=Nil;
  Assign(F,Name);
  {$I-}
  Reset(f);
  {$I+}
  If IoResult<>0 then Error(1,Name);
  Readln(F,S);
  If S<>'; 3D by David Rozenberg' then Error(2,Name);
  LineNum:=1;
  While Not Eof(F) do Begin
    Inc(LineNum);
    Readln(F,S);
    while Pos(' ',S)<>0 do Delete(S,Pos(' ',S),1);
    If (S<>'') and (S[1]<>';') then begin
      For I:=1 to 6 do Begin
        Comma:=Pos(',',S);
        If Comma=0 then Begin
          Close(F);
          Str(LineNum:4,S);
          Error(3,S);
        End;
        S1:=Copy(S,1,Comma-1);
        Delete(S,1,Comma);
        Val(S1,Coord[i],Comma);
        If Comma<>0 then Begin
          Close(F);
          Str(LineNum:4,S);
          Error(3,S);
        End;
      End;
      Val(S,Coord[7],Comma);
      If Comma<>0 then Begin
        Close(F);
        Str(LineNum:4,S);
        Error(3,S);
      End;
      AddLine(Coord);
    End;
  End;
  Close(F);
End;

Procedure RotateZ(Deg : Real);
Var
  Lp : LineRec;
  Rad : Real;
  Tx,Ty : Real;

Begin
  Rad:=DegTRad(Deg);
  Lp:=FirstLine;
  While Lp<>Nil do Begin
    With Lp^.Fpoint Do Begin
      TX:=(X*Cos(Rad)-Y*Sin(Rad));
      TY:=(X*Sin(Rad)+Y*Cos(Rad));
      X:=Tx;
      Y:=Ty;
    End;
    With Lp^.Tpoint Do Begin
      TX:=(X*Cos(Rad)-Y*Sin(Rad));
      TY:=(X*Sin(Rad)+Y*Cos(Rad));
      X:=Tx;
      Y:=Ty;
    End;
    Lp:=Lp^.Next;
  end;
End;

Procedure RotateY(Deg : Real);
Var
  Lp : LineRec;
  Rad : Real;
  Tx,Tz : Real;

Begin
  Rad:=DegTRad(Deg);
  Lp:=FirstLine;
  While Lp<>Nil do Begin
    With Lp^.Fpoint Do Begin
      TX:=(X*Cos(Rad)-Z*Sin(Rad));
      TZ:=(X*Sin(Rad)+Z*Cos(Rad));
      X:=Tx;
      Z:=Tz;
    End;
    With Lp^.Tpoint Do Begin
      TX:=(X*Cos(Rad)-Z*Sin(Rad));
      TZ:=(X*Sin(Rad)+Z*Cos(Rad));
      X:=Tx;
      Z:=Tz;
    End;
    Lp:=Lp^.Next;
  end;
End;

Procedure Rotate;
Var
  Ch : Char;

Begin
  Repeat
    Repeat
      Ch:=Readkey;
      If ch=#0 then Ch:=Readkey;
    Until Ch in [#27,#72,#75,#77,#80,#50,#52,#54,#56];
    Case ch of
      #54 :Begin
              While Not keypressed do begin
                RotateZ(10);
                ShowLines;
                Delay(100);
              End;
              Ch:=Readkey;
              If Ch=#0 then Ch:=ReadKey;
            End;
      #52:Begin
              While Not keypressed do begin
                RotateZ(-10);
                ShowLines;
                Delay(100);
              End;
              Ch:=Readkey;
              If Ch=#0 then Ch:=ReadKey;
            End;
      #56:Begin
              While Not keypressed do begin
                RotateY(10);
                ShowLines;
                Delay(100);
              End;
              Ch:=Readkey;
              If Ch=#0 then Ch:=ReadKey;
            End;
      #50:Begin
              While Not keypressed do begin
                RotateY(-10);
                ShowLines;
                Delay(100);
              End;
              Ch:=Readkey;
              If Ch=#0 then Ch:=ReadKey;
            End;
      #72 : Begin
              RotateY(10);
              ShowLines;
            End;
      #75 : Begin
              RotateZ(-10);
              ShowLines;
            End;
      #77 : Begin
              RotateZ(10);
              ShowLines;
            End;
      #80 : Begin
              RotateY(-10);
              ShowLines;
            End;
    End;
  Until Ch=#27;
End;

Begin
  If ParamCount<1 then Error(4,'');
  LoadFile(ParamStr(1));
  Init;
  ShowLines;
  Rotate;
  CloseGraph;
  ClrScr;
  Writeln;
  Writeln('Thanks for using 3D');
  Writeln;
End.

There is sample of some files that can be rotated:
cut out and save in specified file name
Cube.3D:

; 3D by David Rozenberg
; Base of cube
-70,70,-70,70,70,-70,15
70,70,-70,70,-70,-70,15
70,-70,-70,-70,-70,-70,15
-70,-70,-70,-70,70,-70,15
; Top of cube
-70,70,70,70,70,70,15
70,70,70,70,-70,70,15
70,-70,70,-70,-70,70,15
-70,-70,70,-70,70,70,15
; Side of cube
-70,70,-70,-70,70,70,13
70,70,-70,70,70,70,13
70,-70,-70,70,-70,70,13
-70,-70,-70,-70,-70,70,13

David.3D:

; 3D by David Rozenberg
0,-120,45,0,-30,45,15
0,-60,45,0,-60,-45,15
; 
0,-15,45,0,15,45,12
0,15,45,0,15,-45,12
;
0,30,45,0,120,45,11
0,90,45,0,90,-45,11
;
50,-45,-75,50,45,-75,10
50,45,-75,50,45,-165,10


