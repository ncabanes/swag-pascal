(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0258.PAS
  Description: Graphic tetris game
  Author: SWAG SUPPORT TEAM
  Date: 05-30-97  18:17
*)


(****************************Graphic Tetris Game*
Programmer : an Italian Pascal programmer, his name has been forgotten
Sent to SWAG by : Peter Radics (pradics@bigfoot.com)
Tested on TP 6.0 - works correct
Public domain
***************************Hope you'll enjoy******)

Uses Crt, Graph;

Type Matriz = Array [0..21, 0..11] Of Integer;
Type Tipopeca = Array [0..3, 0..3] Of Integer;

Var Matela, Mat1Tela, Mat2Tela, Cima : Matriz;
  Next, Pecai, Pecal, Pecaf, Pecat,
  Pecao, Pecas, Peca2, Peca, Pecagira : Tipopeca;
  Prox, Aux, A, B, C, I, J, Num, Cont, Lin, Speed,
  Lines, Nivel, Graphdriver, Graphmode, Con, Bant, Numnex : Integer;
  Fim, Turn, Game, Dir, Esq, Giro, Novapeca : Boolean;
  Tecla : Char;
  Strin : String [6];
  Q : String;
  Ponto, Old : LongInt;

Procedure Botao (Col, Lin, Col1, Lin1: Integer);
Begin
  SetFillStyle (1, 7); Bar (Col, Lin, Col1, Lin1);
  SetColor (15); SetLineStyle (0, 1, 1);
  Line (Col, Lin, Col1, Lin); Line (Col, Lin, Col, Lin1);
  Line (Col, Lin+ 1, Col1, Lin+ 1); Line (Col+ 1, Lin, Col+ 1, Lin1);
  Line (Col, Lin+ 2, Col1, Lin+ 2); Line (Col+ 2, Lin, Col+ 2, Lin1);
  SetColor (8);
  Line (Col, Lin1, Col1, Lin1); Line (Col+ 1, Lin1- 1, Col1, Lin1- 1);
  Line (Col+ 2, Lin1- 2, Col1, Lin1- 2); Line (Col1, Lin, Col1, Lin1);
  Line (Col1- 1, Lin+ 1, Col1- 1, Lin1); Line (Col1- 2, Lin+ 2, Col1- 2, Lin1);
  SetColor (7);
  Line (Col, Lin, Col+ 2, Lin+ 2); Line (Col1, Lin1, Col1- 2, Lin1- 2);
End;

Procedure Destela;
Begin
  If Old<> Ponto Then Begin
    Old:= Ponto;
    Bar (1, 1, 100, 98);
    SetColor (White);
    OutTextXY (520, 85, 'Next');
    Str (Ponto, Strin); OutTextXY (5, 10, 'Score:'+ Strin);
    Str (Lines, Strin); OutTextXY (5, 30, 'Lines:'+ Strin);
    Str (Nivel, Strin); OutTextXY (5, 50, 'Level:'+ Strin);
  End;
  For I:= 1 To 20 Do
    For J:= 1 To 10 Do Begin
      If Matela [I, J] = 0 Then Begin
        SetFillStyle (1, Black);
        Bar ( (J- 1) * 20+ 215, (I- 1) * 20+ 25, (J- 1) * 20+ 19+ 215, (I- 1) * 20+ 19+ 25);
      End
      Else If Matela [I, J] <> Mat2Tela [I, J] Then Begin
        Botao ( (J- 1) * 20+ 215, (I- 1) * 20+ 25, (J- 1) * 20+ 19+ 215, (I- 1) * 20+ 19+ 25);
      End;
    End;
End;

Procedure Desnext;
Begin
  For I:= 0 To 3 Do
    For J:= 0 To 3 Do Begin
      If Next [I, J] = 0 Then Begin
        SetFillStyle (1, Black);
        Bar ( (J- 1) * 20+ 515, (I- 1) * 20+ 25, (J- 1) * 20+ 19+ 515, (I- 1) * 20+ 19+ 25);
      End
      Else Begin
        Botao ( (J- 1) * 20+ 515, (I- 1) * 20+ 25, (J- 1) * 20+ 19+ 515, (I- 1) * 20+ 19+ 25);
      End;
    End;
End;

Procedure Sorteia;
Begin
  Numnex:= Random (7);
  If Numnex= 0 Then Next:= Pecal
  Else If Numnex= 1 Then Next:= Pecaf
  Else If Numnex= 2 Then Next:= Pecai
  Else If Numnex= 3 Then Next:= Pecao
  Else If Numnex= 4 Then Next:= Pecas
  Else If Numnex= 5 Then Next:= Peca2
  Else If Numnex= 6 Then Next:= Pecat;
End;

Procedure Verlinha;
Begin
  Aux:= Lines;
  For A:= 1 To 4 Do
    For I:= 20 Downto 1 Do Begin
      Cont:= 0;
      For J:= 1 To 10 Do If Matela [I, J] = 1 Then Cont:= Cont+ 1;
      If Cont= 10 Then Begin
        For J:= 1 To 10 Do Begin
          Matela [I, J] := 0;
        End;
        Inc (Lines, 1);
        For Lin:= 1 To (I- 1) Do
          For J:= 1 To 10 Do Begin
            Cima [Lin, J] := Matela [Lin, J];
            Matela [Lin, J] := 0;
          End;
        For Lin:= 2 To I Do
          For J:= 1 To 10 Do
            Matela [Lin, J] := Cima [Lin- 1, J];
      End;
    End;
  Ponto:= Ponto+ ( (Lines- Aux) * (Lines- Aux) * 100);
End;

Procedure Verifica;
Begin
  If KeyPressed Then Begin
    Tecla:= ReadKey;
    If Ord (Tecla) = 077 Then Begin
      If Dir= True Then Begin
        Inc (C, 1);
        Inc (Con, 1);
        If Con< 4 Then Dec (B, 1);
        If Con>= 4 Then Begin
          Con:= 0;
          Dec (C, 1);
        End;
      End;
    End
    Else If Ord (Tecla) = 075 Then Begin
      If Esq= True Then Begin
        Dec (C, 1);
        Inc (Con, 1);
        If Con< 4 Then Dec (B, 1);
        If Con>= 4 Then Begin
          Con:= 0;
          Inc (C, 1);
        End;
      End;
    End
      Else If Ord (Tecla) = 072 Then Begin
        If Giro= True Then Begin
          Inc (Con, 1);
          If Con< 2 Then Dec (B, 1);
          If Con>= 2 Then Con:= 0;
          Pecagira:= Peca;
          If (Num= 0) Or (Num= 1) Or (Num= 6) Then Begin
            For I:= 1 To 3 Do Begin
              Peca [3, I] := Pecagira [I, 1];
              Peca [2, I] := Pecagira [I, 2];
              Peca [1, I] := Pecagira [I, 3];
            End;
          End
          Else If (Num= 4) Or (Num= 5) Then Begin
            If Turn= True Then Begin
              For I:= 0 To 3 Do Begin
                Peca [3, I] := Pecagira [I, 0];
                Peca [2, I] := Pecagira [I, 1];
                Peca [1, I] := Pecagira [I, 2];
                Peca [0, I] := Pecagira [I, 3];
                Turn:= False;
              End;
            End
            Else If Turn= False Then Begin
              If Num= 4 Then Peca:= Pecas;
              If Num= 5 Then Peca:= Peca2;
              Turn:= True;
            End;
          End
            Else If Num= 2 Then Begin
              For I:= 0 To 3 Do
                For J:= 0 To 3 Do
                  Peca [I, J] := Pecagira [J, I];
            End;
        End;
      End
        Else If Ord (Tecla) = 080 Then Speed:= 0;
  End;
End;

Begin
  DetectGraph (Graphdriver, Graphmode);
  InitGraph (Graphdriver, Graphmode, ''); {The path of your BGI driver goes here
                                           or your BGI must be in the current dir}
  Randomize;
  For I:= 0 To 3 Do
    For J:= 0 To 3 Do Begin
      Pecai [I, J] := 0;
      Pecao [I, J] := 0;
      Pecal [I, J] := 0;
      Pecaf [I, J] := 0;
      Pecat [I, J] := 0;
      Pecas [I, J] := 0;
      Peca2 [I, J] := 0;
    End;
  For I:= 0 To 3 Do Pecai [2, I] := 1;
  For I:= 1 To 3 Do Pecal [2, I] := 1;
  Pecal [1, 3] := 1;
  For I:= 1 To 3 Do Pecaf [2, I] := 1;
  Pecaf [1, 1] := 1;
  For I:= 0 To 1 Do Pecas [I, 1] := 1;
  For I:= 1 To 2 Do Pecas [I, 2] := 1;
  For I:= 0 To 1 Do Peca2 [I, 2] := 1;
  For I:= 1 To 2 Do Peca2 [I, 1] := 1;
  For I:= 1 To 3 Do Pecat [2, I] := 1;
  Pecat [1, 2] := 1;
  For I:= 1 To 2 Do Pecao [1, I] := 1;
  For I:= 1 To 2 Do Pecao [2, I] := 1;
  Sorteia;
  Old:= 0;
  Con:= 0;
  Ponto:= 0;
  Lines:= 0;
  Tecla:= '0';
  For I:= 1 To 20 Do
    For J:= 1 To 10 Do Matela [I, J] := 0;
  For I:= 1 To 21 Do Matela [I, 0] := 1;
  For I:= 1 To 21 Do Matela [I, 11] := 1;
  For J:= 0 To 11 Do Matela [21, J] := 1;
  SetBkColor (Black);
  SetColor (White);
  Line (214, 25, 214, 425);
  Line (415, 25, 415, 425);
  Line (215, 425, 414, 425);
  Fim:= False;
  Game:= True;
  Repeat
    Speed:= 3100;
    Nivel:= 1;
    Inc (Ponto, 10);
    Speed:= Speed- ( (Ponto Div 4000) * 10);
    Nivel:= Nivel+ (Ponto Div 4000);
    Novapeca:= False;
    Peca:= Next;
    Num:= Numnex;
    Sorteia;
    Turn:= True;
    C:= 4;
    B:= 0;
    Desnext;
    Repeat
      Verifica;
      Verifica;
      If B= Bant+ 1 Then Con:= 0;
      Esq:= True;
      Dir:= True;
      Giro:= True;
      Mat2Tela:= Matela;
      Verlinha;
      Mat1Tela:= Matela;
      For I:= 0 To 2 Do
        For J:= 0 To 2 Do Begin
          If (Num= 4) Or (Num= 5) Then
            If Matela [I+ B, J+ C] = 1 Then Giro:= False;
        End;
      For I:= 1 To 3 Do
        For J:= 1 To 3 Do Begin
          If (Num= 6) Or (Num= 0) Or (Num= 1) Then
            If Matela [I+ B, J+ C] = 1 Then Giro:= False;
        End;
      For I:= 0 To 3 Do
        For J:= 0 To 3 Do
          If Novapeca= False Then Begin
            If Num= 3 Then Giro:= False;
            If Num= 2 Then
              If Matela [I+ B, J+ C] = 1 Then Giro:= False;
            If Matela [I+ B, J+ C] <> 1 Then
            Begin
              Matela [I+ B, J+ C] := Peca [I, J];
              If (Matela [I+ B, J+ C+ 1] ) + (Peca [I, J] ) = 2 Then Dir:= False;
              If (Mat1Tela [I+ B, J+ C- 1] ) + (Peca [I, J] ) = 2 Then Esq:= False;
              If (Matela [I+ B+ 1, J+ C] ) + (Peca [I, J] ) = 2 Then
              Begin
                For I:= 0 To 3 Do
                  For J:= 0 To 3 Do
                    If Matela [I+ B, J+ C] <> 1 Then
                    Begin
                      Matela [I+ B, J+ C] := Peca [I, J];
                    End;
                Destela;
                Novapeca:= True;
              End;
            End;
          End;
      If Novapeca= False Then Begin
        Destela;
        For I:= 0 To 3 Do
          For J:= 0 To 3 Do
            If Mat1Tela [I+ B, J+ C] <> 1 Then
              Matela [I+ B, J+ C] := 0;
        Delay (Speed);
        Bant:= B;
        Inc (B, 1);
      End;
      If KeyPressed Then Tecla:= ReadKey;
      If Ord (Tecla) = 027 Then Fim:= True;
    Until (Novapeca= True) Or (Fim= True);
    For J:= 4 To 6 Do If Matela [1, J] = 1 Then Game:= False;
  Until (Game= False) Or (Fim= True);
  CloseGraph;
  ClrScr;
End.
