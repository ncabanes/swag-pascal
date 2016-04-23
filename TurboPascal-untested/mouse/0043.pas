Program MouseEdit;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██          Mouse Cursor Editor         ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1996. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

     This program creates file MOUSEDIT.DAT file on disk. You can insert
this file directly in pascal program/unit or you can rename it and include
it with $I directive. Examples of both techniques can be founded in MOUSE.PAS
unit, written by same author.

      Also, this program demonstrates how to use mentioned MOUSE unit.

}
  Uses Mouse, Graph;

  Procedure Initialize;
    Var Gd, Gm : integer;
      Begin
        If not MouseOK then
          Begin
            Writeln ('Mouse driver not loaded.');
            Halt
          End;
        DetectGraph (Gd,Gm);
        InitGraph (Gd,Gm,'')
      End;

  Function InBox (X,Y,X1,Y1,X2,Y2:integer) : Boolean;
    Begin
      InBox:=(X>=X1) and (X<=X2) and (Y>=Y1) and (Y<=Y2)
    End;

  Procedure EditCursor;
    Var I, J, X, Y : integer;
        M          : word;
        Button     : byte;
        Error      : Boolean;
        Temp, Mask : CursorMask;

    Procedure DrawCursor (X,Y:integer);
      Var I, J : integer;
          M    : word;
        Begin
          For J:=1 to 16 do
            Begin
              M:=Mask.Mask [J];
              For I:=1 to 16 do
                Begin
                  If (M and 1=1) and (GetPixel (X+16-I,Y+J-1)>0) then
                    PutPixel (X+16-I,Y+J-1,White)
                               else
                    PutPixel (X+16-I,Y+J-1,Black);
                  M:=M shr 1
                End
            End;
          For J:=1 to 16 do
            Begin
              M:=Mask.Mask [16+J];
              For I:=1 to 16 do
                Begin
                  If (M and 1=1) XOR (GetPixel (X+16-I,Y+J-1)>0) then
                    PutPixel (X+16-I,Y+J-1,White)
                               else
                    PutPixel (X+16-I,Y+J-1,Black);
                  M:=M shr 1
                End
            End
        End;

    Procedure DrawTest;
      Begin
        SetColor (White);
        SetFillStyle (SolidFill,White);
        Bar (240,310,320,390);
        SetFillStyle (SolidFill,Black);
        Bar (320,310,400,390);
        Rectangle (240,310,400,390);
        DrawCursor (272,342);
        DrawCursor (352,342)
      End;

    Procedure DrawMasks;
      Var I, J : integer;
          M    : word;
        Begin
          For J:=1 to 16 do
            Begin
              M:=Mask.Mask [J];
              For I:=1 to 16 do
                Begin
                  If M and 1=1 then
                    SetFillStyle (SolidFill,White)
                               else
                    SetFillStyle (SolidFill,Black);
                  Bar (281-I*15,41+(J-1)*15,279-(I-1)*15,39+J*15);
                  M:=M shr 1
                End
            End;
          For J:=1 to 16 do
            Begin
              M:=Mask.Mask [16+J];
              For I:=1 to 16 do
                Begin
                  If M and 1=1 then
                    SetFillStyle (SolidFill,White)
                               else
                    SetFillStyle (SolidFill,Black);
                  Bar (601-I*15,41+(J-1)*15,599-(I-1)*15,39+J*15);
                  M:=M shr 1
                End
            End
        End;

    Procedure Load;
      Var I, J, Code : integer;
          S          : string;
          F          : text;
        Begin
          Error:=True;
{$I-}
          Assign (F,'MOUSEDIT.DAT');
          Reset (F);
          For J:=1 to 2 do
            Begin
              Readln (F,S);
              If Pos (')',S)>0 then
                S [Pos (')',S)]:=',';
              For I:=1 to 16 do
                Begin
                  While not (S [1] in ['0'..'9']) and (S>'') do
                    S:=Copy (S,2,Length (S)-1);
                  If (S='') or (Pos (',',S)=0) then Exit;
                  Val (Copy (S,1,Pos (',',S)-1),Temp.Mask [(J-1)*16+I],Code);
                  If Code<>0 then Exit;
                  S:=Copy (S,Pos (',',S)+1,Length (S)-Pos (',',S))
                End
            End;
          Close (F);
{$I+}
          Error:=False
        End;

    Procedure Save;
      Var I, J : integer;
          F    : text;
        Begin
{$I-}
          Assign (F,'MOUSEDIT.DAT');
          Rewrite (F);
          Write (F,'(');
          For J:=1 to 2 do
            For I:=1 to 16 do
              If I=16 then
                If J=2 then
                  Writeln (F,Mask.Mask [(J-1)*16+I],');')
                       else
                  Writeln (F,Mask.Mask [(J-1)*16+I],',')
                     else
                Write (F,Mask.Mask [(J-1)*16+I],',');
          Close (F)
{$I+}
        End;

      Begin
        SetTextJustify (CenterText,CenterText);
        OutTextXY (GetMaxX div 2,GetMaxY-10,'(C) 1996. Aleksandar Dlabac');
        SetColor (LightGray);
        For I:=0 to 16 do
          Line (40+I*15,40,40+I*15,280);
        For I:=0 to 16 do
          Line (40,40+I*15,280,40+I*15);
        For I:=0 to 16 do
          Line (360+I*15,40,360+I*15,280);
        For I:=0 to 16 do
          Line (360,40+I*15,600,40+I*15);
        SetColor (White);
        OutTextXY (160,25,'Screen (AND) mask');
        OutTextXY (480,25,'Cursor (XOR) mask');
        Rectangle (100,430,200,450);
        OutTextXY (150,440,'Load');
        Rectangle (270,430,370,450);
        OutTextXY (320,440,'Save');
        Rectangle (440,430,540,450);
        OutTextXY (490,440,'Exit');
        OutTextXY (320,300,'Test');
        ResetMouse;
        For I:=1 to 16 do
          Mask.Mask [I]:=$FFFF;
        For I:=17 to 32 do
          Mask.Mask [I]:=0;
          Repeat
            DrawTest;
            DrawMasks;
            Button:=0;
            ShowCursor;
            Repeat Until LeftButton;
            X:=GetMouseX;
            Y:=GetMouseY;
            Repeat Until not LeftButton;
            HideCursor;
            For J:=1 to 16 do
              Begin
                M:=1;
                For I:=1 to 16 do
                  Begin
                    If InBox (X,Y,281-I*15,41+(J-1)*15,279-(I-1)*15,39+J*15) then
                      Mask.Mask [J]:=Mask.Mask [J] XOR M;
                    M:=M shl 1
                  End
              End;
            For J:=1 to 16 do
              Begin
                M:=1;
                For I:=1 to 16 do
                  Begin
                    If InBox (X,Y,601-I*15,41+(J-1)*15,599-(I-1)*15,39+J*15) then
                      Mask.Mask [16+J]:=Mask.Mask [16+J] XOR M;
                    M:=M shl 1
                  End
              End;
            For I:=1 to 3 do
              If InBox (X,Y,I*170-70,430,I*170+30,450) then
                Button:=I;
              Case Button of
                1 : Begin
                      Load;
                      If (IOResult<>0) or Error then
                        Write (#7)
                                                else
                        Mask:=Temp
                    End;
                2 : Begin
                      Save;
                      If IOResult<>0 then
                        Write (#7)
                    End
              End
          Until Button=3;
        HideCursor
      End;

    Begin
      Initialize;
      EditCursor;
      CloseGraph
    End.