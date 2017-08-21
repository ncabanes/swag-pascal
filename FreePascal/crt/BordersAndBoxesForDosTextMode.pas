(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0041.PAS
  Description: Borders and Boxes for DOS text mode
  Author: DANIEL DICKMAN
  Date: 08-30-96  09:36
*)


{Unit Boxes;

Interface
}
Uses
  Crt;  { in SWAG .. set CRT.SWG }

{
Procedure Box (X1, Y1, X2, Y2 : Byte; C : Char; At : Byte);
Procedure SingleFrame (X1, Y1, X2, Y2, At : Byte);
Procedure DoubleFrame (X1, Y1, X2, Y2, At : Byte);
Procedure FramedBox (X1, Y1, X2, Y2, At : Byte; Single : Boolean);
Procedure SpecialFrame (X1, Y1, X2, Y2, At : Byte; Title : String);
Procedure SpecialBox (X1, Y1, X2, Y2, At : Byte; Title : String);

Implementation
}

Procedure FWrite (X, Y : Byte; C : Char; At : Byte);
Begin
  GotoXy(X,Y);
  textattr := at;
  Write(c);
End;

Procedure FWrite (X, Y : Byte; S : String; At : Byte);
Begin
  GotoXy(X,Y);
  textattr := at;
  Write(S);
End;

Procedure Box (X1, Y1, X2, Y2 : Byte; C : Char; At : Byte);
Var
  A, B : Byte;
Begin
  For A := Y1 To Y2 Do
    Begin
      For B := X1 To X2 Do
        FWrite (B, A, C, At);
    End;
End;

Procedure SingleFrame (X1, Y1, X2, Y2, At : Byte);
Var
  A : Byte;
Begin
  FWrite (X1, Y1, '+', At);
  FWrite (X1, Y2, '+', At);
  FWrite (X2, Y1, '+', At);
  FWrite (X2, Y2, '+', At);
  For A := (X1 + 1) To (X2 - 1) Do
    Begin
      FWrite (A, Y1, '-', At);
      FWrite (A, Y2, '-', At);
    End;
  For A := (Y1 + 1) To (Y2 - 1) Do
    Begin
      FWrite (X1, A, '|', At);
      FWrite (X2, A, '|', At);
    End;
End;

Procedure DoubleFrame (X1, Y1, X2, Y2, At : Byte);
Var
  A : Byte;
Begin
  FWrite (X1, Y1, '#', At);
  FWrite (X1, Y2, '#', At);
  FWrite (X2, Y1, '#', At);
  FWrite (X2, Y2, '#', At);
  For A := (X1 + 1) To (X2 - 1) Do
    Begin
      FWrite (A, Y1, '=', At);
      FWrite (A, Y2, '=', At);
    End;
  For A := (Y1 + 1) To (Y2 - 1) Do
    Begin
      FWrite (X1, A, '|', At);
      FWrite (X2, A, '|', At);
    End;
End;

Procedure FramedBox (X1, Y1, X2, Y2, At : Byte; Single : Boolean);
Begin
  Box (X1 - 1, Y1, X2 + 1, Y2, #32, At);
  If Single Then
    SingleFrame (X1, Y1, X2, Y2, At)
  Else
    DoubleFrame (X1, Y1, X2, Y2, At);
End;

Procedure SpecialFrame (X1, Y1, X2, Y2, At : Byte; Title : String);
Var
  A : Byte;
Begin
  FWrite (X1, Y1, #218, At);
  FWrite (X1, Y2, #192, At);
  FWrite (X2, Y1, #191, At);
  FWrite (X2, Y2, #217, At);
  For A := (X1 + 1) To (X2 - 1) Do
    FWrite (A, Y2, #196, At);
  For A := (Y1 + 1) To (Y2 - 1) Do
    Begin
      FWrite (X1, A, #179, At);
      FWrite (X2, A, #179, At);
    End;
  FWrite (X1 + 1, Y1, #180, At);
  FWrite (X2 - 1, Y1, #195, At);
  For A := (X1 + 2) To (X2 - 2) Do
    FWrite (A, Y1, #32, $1F);
  FWrite ((X2 - X1 - Length(Title)) div 2 + X1, Y1, Title, $1F);
End;

Procedure SpecialBox (X1, Y1, X2, Y2, At : Byte; Title : String);
Begin
  Box (X1 - 1, Y1, X2 + 1, Y2, #32, At);
  SpecialFrame (X1, Y1, X2, Y2, At, Title);
End;

Begin
  Box(1, 1, 20, 5, 'x', 14);
  SingleFrame(10, 7, 60, 11, 13);
  DoubleFrame(62, 5, 77, 13, 12 + 16*2);
  FramedBox(2, 15, 40, 18, 11 + 16*1, true);
End.

