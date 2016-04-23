Unit AnsiUnit;
{$Q-}
{$R-}
Interface

Uses  Dos, Crt;

Var
  Ansi                : Text;     { Ansi is the name of the device }
  Wrap                : Boolean;  { True if Cursor should wrap }
  ReportedX,
  ReportedY           : Word;     { X,Y reported }

  { Hook for handling control chars i.e. Ch < Space }
  WriteHook           : Procedure(Ch : Char);

  { hook for implementing Your own Device Status Report procedure }
  ReplyHook           : Procedure(St : String);

  { Hook for handling simultaneous writes to ComPort and Screen }
  BBsHook       : Procedure (Ch : Char);

Function In_Ansi    : Boolean;    { True if a sequence is pending }
Procedure WriteChar(Ch : Char);
Procedure AnsiWrite(S: String);

Procedure AssignAnsi(Var f : Text); { use like AssignCrt }

Implementation

Type
  States              = (Waiting, Bracket, Get_Args, Get_Param, Eat_Semi,
                         Get_String, In_Param, Get_Music);
Const
  St                  : String = '';
  ParamArr            : Array[1..10] Of Word = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  Params              : Word = 0; { number of parameters }
  NextState           : States = Waiting; { next state for the parser }
  Reverse             : Boolean = False; { true if text attributes are
reversed }
Var
  Quote               : Char;
  SavedX, SavedY      : Word;

  Function In_Ansi    : Boolean;  { True if a sequence is pending }
  Begin
    In_Ansi := (NextState <> Waiting) And (NextState <> Bracket);
  End {In_Ansi} ;

  Function ms(w: word): string;

    var s: string;

    begin
      str(w,s);
      Ms := s;
    end;


  {$F+}
  Procedure Report(St : String);
    {$F-}
  Begin
    {StuffString(St);}
  End;

  {$F+}
  Procedure WriteChar(Ch : Char);
    {$F-}
  Begin
    Case Ch Of
      #7 :
        Begin
          NoSound;
          Sound(500);
          Delay(50);
          NoSound;
          Delay(50);
        End;
      #8 : If (WhereX > 1) Then Write(#8' '#8);
      #9 : If (WhereX < 71) Then
           Repeat
             GotoXy(WhereX + 1, Wherey);
           Until (WhereX Mod 8 = 1);
      Else
        Write(Ch);
    End {Case} ;
  End {WriteChar} ;

  {$F+}
  Procedure Dummy(St : String);
    {$F-}
  Begin
  End;

  Procedure AnsiWrite(S: String);

  Var
    i                   : Word;
    j                   : Byte;
    Ch                  : Char;

  Label Command, Ending;

  Begin
    for j := 1 to length(S) do
    begin
      Ch := s[j];
      If Ch = #27 Then
      Begin
        NextState := Bracket;
        Goto Ending;
      End;
      Case NextState Of
        Waiting : If (Ch > ' ') Then Write(Ch)
                  Else WriteHook(Ch);
        Bracket :
          Begin
            If Ch <> '[' Then
            Begin
              NextState := Waiting;
              If (Ch > ' ') Then Write(Ch)
              Else WriteHook(Ch);
              Goto Ending;
            End;
            St := '';
            Params := 1;
            FillChar(ParamArr, 10, 0);
            NextState := Get_Args;
          End;
        Get_Args, Get_Param, Eat_Semi :
          Begin
            {$IFNDEF Music}
            If (NextState = Get_Args) And ((Ch = '=') Or (Ch = '?')) Then
            Begin
              NextState := Get_Param;
              Goto Ending;
            End;
            {$ELSE}
            If (NextState = Get_Args) Then
              Case Ch Of
                '=', '?' :
                  Begin
                    NextState := Get_Param;
                    Goto Ending;
                  End;
                'M' :
                  Begin
                    NextState := Get_Music;
                    Goto Ending;
                  End;
              End {Case} ;
            {$ENDIF}
            If (NextState = Eat_Semi) And (Ch = ';') Then
            Begin
              If Params < 10 Then Inc(Params);
              NextState := Get_Param;
              Exit;
            End;
            Case Ch Of
              '0'..'9' :
                Begin
                  ParamArr[Params] := Ord(Ch) - Ord('0');
                  NextState := In_Param;
                End;
              ';' :
                Begin
                  If Params < 10 Then Inc(Params);
                  NextState := Get_Param;
                End;
              '"', '''' :
                Begin
                  Quote := Ch;
                  St := St + Ch;
                  NextState := Get_String;
                End;
              Else
                GoTo Command;
            End {Case Ch} ;
          End;
        Get_String :
          Begin
            St := St + Ch;
            If Ch <> Quote
            Then NextState := Get_String
            Else NextState := Eat_Semi;
          End;
        In_Param :                  { last char was a digit }
          Begin
            { looking for more digits, a semicolon, or a command char }
            Case Ch Of
              '0'..'9' :
                Begin
                  ParamArr[Params] := ParamArr[Params] * 10 + Ord(Ch) -
Ord('0');                  NextState := In_Param;
                  Goto Ending;
                End;
              ';' :
                Begin
                  If Params < 10 Then Inc(Params);
                  NextState := Eat_Semi;
                  Goto Ending;
                End;
            End {Case Ch} ;
  Command:
            NextState := Waiting;
            Case Ch Of
              { Note: the order of commands is optimized for execution speed }
              'm' :                 {sgr}
                Begin
                  For i := 1 To Params Do
                  Begin
                    If Reverse Then TextAttr := TextAttr Shr 4 + TextAttr Shl
4;                    Case ParamArr[i] Of
                      0 :
                        Begin
                          Reverse := False;
                          TextAttr := 7;
                        End;
                      1 : TextAttr := TextAttr And $FF Or $08;
                      2 : TextAttr := TextAttr And $F7 Or $00;
                      4 : TextAttr := TextAttr And $F8 Or $01;
                      5 : TextAttr := TextAttr Or $80;
                      7 : If Not Reverse Then
                          Begin
                        {
                        TextAttr := TextAttr shr 4 + TextAttr shl 4;
                        }
                            Reverse := True;
                          End;
                      22 : TextAttr := TextAttr And $F7 Or $00;
                      24 : TextAttr := TextAttr And $F8 Or $04;
                      25 : TextAttr := TextAttr And $7F Or $00;
                      27 : If Reverse Then
                           Begin
                             Reverse := False;
                        {
                        TextAttr := TextAttr shr 4 + TextAttr shl 4;
                        }
                           End;
                      30 : TextAttr := TextAttr And $F8 Or $00;
                      31 : TextAttr := TextAttr And $F8 Or $04;
                      32 : TextAttr := TextAttr And $F8 Or $02;
                      33 : TextAttr := TextAttr And $F8 Or $06;
                      34 : TextAttr := TextAttr And $F8 Or $01;
                      35 : TextAttr := TextAttr And $F8 Or $05;
                      36 : TextAttr := TextAttr And $F8 Or $03;
                      37 : TextAttr := TextAttr And $F8 Or $07;
                      40 : TextAttr := TextAttr And $8F Or $00;
                      41 : TextAttr := TextAttr And $8F Or $40;
                      42 : TextAttr := TextAttr And $8F Or $20;
                      43 : TextAttr := TextAttr And $8F Or $60;
                      44 : TextAttr := TextAttr And $8F Or $10;
                      45 : TextAttr := TextAttr And $8F Or $50;
                      46 : TextAttr := TextAttr And $8F Or $30;
                      47 : TextAttr := TextAttr And $8F Or $70;
                    End {Case} ;
                    { fixup for reverse }
                    If Reverse Then TextAttr := TextAttr Shr 4 + TextAttr Shl
4;                  End;
                End;
              'A' :                 {cuu}
                Begin
                  If ParamArr[1] = 0 Then ParamArr[1] := 1;
                  If (Wherey - ParamArr[1] >= 1)
                  Then GotoXy(WhereX, Wherey - ParamArr[1])
                  Else GotoXy(WhereX, Hi(WindMax));
                End;
              'B' :                 {cud}
                Begin
                  If ParamArr[1] = 0 Then ParamArr[1] := 1;
                  If (Wherey + ParamArr[1] <= Hi(WindMax))
                  Then GotoXy(WhereX, Wherey + ParamArr[1])
                  Else GotoXy(WhereX, 1);
                End;
              'C' :                 {cuf}
                Begin
                  If ParamArr[1] = 0 Then ParamArr[1] := 1;
                  If WhereX + ParamArr[1] <= Lo(WindMax)
                  Then GotoXy(WhereX + ParamArr[1], Wherey)
                  Else GotoXy(Lo(WindMax), Wherey);
                End;
              'D' :                 {cub}
                Begin
                  If ParamArr[1] = 0 Then ParamArr[1] := 1;
                  If (WhereX - ParamArr[1] >= 1)
                  Then GotoXy(WhereX - ParamArr[1], Wherey)
                  Else GotoXy(1, Wherey);
                End;
              'H', 'f' :            {cup,hvp}
                Begin
                  If ParamArr[1] = 0 Then ParamArr[1] := 1;
                  If ParamArr[2] = 0 Then ParamArr[2] := 1;
                  GotoXy(ParamArr[2], ParamArr[1]);
                End;
              'J' :                 {EID}
                Case ParamArr[1] Of
                  2 : ClrScr;
               (*
                  0 :               {ClrEos}
                    Begin
                      ClrEol;
                      ScrollWindowDown(Lo(WindMin) + 1, Hi(WindMin) + Wherey +
1,                                       Lo(WindMax) + 1, Hi(WindMax) + 1, 0);
                    End;
                  1 :               {Clear from beginning of screen}
                    Begin
                      ScrollWindowDown(Lo(WindMin) + 1, Hi(WindMin) + Wherey,
                                       Lo(WindMin) + WhereX,
                                       Hi(WindMin) + Wherey, 0);
                      ScrollWindowDown(Lo(WindMin) + 1, Hi(WindMin) + 1,
                                       Lo(WindMax) + 1, Hi(WindMin) + Wherey -
1, 0);                    End;
                *)
                End {Case} ;
              'K' :                 {eil}
                Case ParamArr[1] Of
                  0 : ClrEol;
                (*
                  1 :               { clear from beginning of line to cursor }
                    ScrollWindowDown(Lo(WindMin) + 1, Hi(WindMin) + Wherey,
                                     Lo(WindMin) + WhereX - 1,
                                     Hi(WindMin) + Wherey, 0);
                  2 :               { clear entire line }
                    ScrollWindowDown(Lo(WindMin) + 1, Hi(WindMin) + Wherey,
                                     Lo(WindMax) + 1,
                                     Hi(WindMin) + Wherey, 0);
                 *)
                End {Case ParamArr} ;
              'L' : {il } For i := 1 To ParamArr[1] Do InsLine; { must not
move cursor }              'M' : {d_l} For i := 1 To ParamArr[1] Do DelLine; {
must not move cursor }              'P' :                 {dc }
                Begin
                End;
              'R' :                 {cpr}
                Begin
                  ReportedY := ParamArr[1];
                  ReportedX := ParamArr[2];
                End;
              '@' :                 {ic}
                Begin
                  { insert blank chars }
                End;
              'h', 'l' :            {sm/rm}
                Case ParamArr[1] Of
                  0 : TextMode(BW40);
                  1 : TextMode(CO40);
                  2 : TextMode(BW80);
                  3 : TextMode(CO80);
                  4 : {GraphMode(320x200 col)} ;
                  5 : {GraphMode(320x200 BW)} ;
                  6 : {GraphMode(640x200 BW)} ;
                  7 : Wrap := Ch = 'h';
                End {case} ;
              'n' :                 {dsr}
                If (ParamArr[1] = 6) Then
                  ReplyHook(#27'[' + ms(Wherey) + ';' +
                            ms(WhereX) + 'R');
              's' :                 {scp}
                Begin
                  SavedX := WhereX;
                  SavedY := Wherey;
                End;
              'u' : {rcp} GotoXy(SavedX, SavedY);
              Else
                Begin
                  If (Ch > ' ') Then Write(Ch)
                  Else WriteHook(Ch);
                  Goto Ending;
                End;
            End {Case Ch} ;
          End;
        {$IFDEF Music}
        Get_Music :
          Begin
            If Ch <> #3             {Ctrl-C}
            Then St := St + Ch
            Else
            Begin
              NextState := Waiting;
            End;
          End;
        {$ENDIF}
      End {Case NextState} ;
      Ending:
    End;
  End {AnsiWrite} ;

  {$IFNDEF Small}

  {$F+}                           { All Driver function must be far }

  Function Nothing(Var f : TextRec) : Integer;
  Begin
    Nothing := 0;
  End {Nothing} ;

  Procedure Null(Ch : Char);
  Begin
    {}
  End {Null} ;

  Function DevOutput(Var f : TextRec) : Integer;
  Var
    i                   : Integer;
  Begin
    With f Do
    Begin
      { f.BufPos contains the number of chars in the buffer }
      { f.BufPtr^ is your buffer                            }
      { Any variable conversion done by writeln is already  }
      { done by now.                                        }
      i := 0;
      While i < BufPos Do
      Begin
        AnsiWrite(BufPtr^[i]);
        {$IFDEF BBS}
        BBSHook(BufPtr^[i]);
        {$ENDIF}
        Inc(i);
      End;
      BufPos := 0;
    End;
    DevOutput := 0;               { return IOResult Error codes here }
  End {DevOutput} ;

  Function DevOpen(Var f : TextRec) : Integer;
  Begin
    With f Do
    Begin
      If Mode = FmInput Then
      Begin
        InOutFunc := @Nothing;
        FlushFunc := @Nothing;
      End
      Else
      Begin
        Mode := FmOutput;         { in case it was FmInOut }
        InOutFunc := @DevOutput;
        FlushFunc := @DevOutput;
      End;
      CloseFunc := @Nothing;
    End;
    DevOpen := 0;                 { return IOResult error codes here }
  End {DevOpen} ;

  Procedure AssignAnsi(Var f : Text);
  Begin
    FillChar(f, SizeOf(f), #0);   { init file var }
    With TextRec(f) Do
    Begin
      Handle := $ffff;
      Mode := FmClosed;
      BufSize := SizeOf(Buffer);
      BufPtr := @Buffer;
      OpenFunc := @DevOpen;
      Name[0] := #0;
    End;
  End {AssignAnsi} ;
  {$ENDIF}

Begin

  AssignAnsi(Ansi);               { set up the variable }
  Rewrite(Ansi);                  { open it for output  }

  Wrap := True;
  ReplyHook := Report;
  WriteHook := WriteChar;

End.
