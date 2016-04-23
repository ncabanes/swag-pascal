Procedure ReadS (Var NewIn : String; OldIn : String; X,Y,Colr,MaxLen : Byte;
                 ValidChars : ChSet; FChar : Char);

              (* NewIn      = String entered by user, or default string if
                              nothing new entered.  Self-modified.
                 OldIn      = Default or old data entered
                 X,Y        = Coordinates of beginning point to read
                 Colr       = Color of input
                 MaxLen     = Maximum length of input
                 ValidChars = A Set of Char that outlines which keys can be
                              used in entering string.  ie: ['A'..'Z','a'..'z']
                 FChar      = Filler character for End-of-String
              *)

  (* When called, prompt should be on screen.  NewIn var will be modified only
     at exit of ReadS, otherwise will return nothing.  If ESC is pressed, NewIn
     will again be blank, otherwise will contain the user input or default
     string.


  ** NOTE **  There are certain functions required to make this entire
              procedure work.  They are not necessary, but make it nicer to
              use.  These are:

                    GetCursor
                    SetCursor
                    WriteS (fast writes to screen, see next few posts)

  *)

  (* Standard disclaimer: I'm not liable for anything this procedure does
                          outside the original purpose of the procedure.  If
                          something bad happens, let me know, but that's all
                          I can do.
  *)

Var
   CurX, StLen                          : Byte;
   OldCursor                            : Word;

Begin
     NewIn := '';
     InsOn := True;
     InStr := OldIn;
     StLen := Length (OldIn);
     Colr := CheckColor (Colr);
     For I := StLen To MaxLen-1 Do
         WriteS (FChar,X+I,Y,Colr);
     WriteS (OldIn,X,Y,HiColr);
     CurX := Length (InStr)+X;
     ValidChars := ValidChars + [#8,#13,#210,#211] + HKeySet + FuncKeys;
{arrowk     OldCursor := GetCursor;
     Repeat
           If InsOn Then
              SetCursor (DefaultCursor)
           Else
               SetCursor (BlockCursor);
           GotoXY (CurX,Y);
           StLen := Length (InStr);
           For I := StLen To MaxLen-1 Do
               If Colr < 112 Then
                  WriteS (FChar,X+I,Y,HiColr)
               Else
                   WriteS (FChar,X+I,Y,Colr);
           Repeat
                 Repeat
                       Ch := ReadKey;
                 Until (Ch <> #13) Or ((Ch = #13) And (InStr <> ''));
           Until (Ch In ValidChars);
           Case Ch Of
                #8:
                Begin
                     If (CurX > X) And (Length (InStr) > 0) Then
                     Begin
                          Dec (CurX);
                          If InsOn Then
                             Delete (InStr,(CurX-X)+1,1)
                          Else
                              InStr[(CurX-X)+1] := #32;
                     End;
                End;
                #203: { Left arrow }
                      If CurX > X Then
                         Dec (CurX);
                #205: { Right arrow }
                      If CurX < X+Length (InStr) Then
                         Inc (CurX);
                #199: { Home }
                      CurX := X;
                #207: { End }
                      CurX := X+Length (InStr);
                #210: { Insert }
                      InsOn := InsOn XOr True;
                #211: { Delete }
                      Delete (InStr,(CurX-X)+1,1);
                #65..#90,
                #97..#122, { Alphabet }
                #48..#57,  { Numbers }
                #91..#96,
                #32..#47,
                #58..#64:  { Other chars }
                Begin
                     If (CurX-X < MaxLen) And (Length (InStr) < MaxLen) Then
                     Begin
                          InStr[0] := Chr (Ord (InStr[0])+1);
                          InStr[Length (InStr)] := #0;
                          If InsOn Then
                               Insert (Ch,InStr,(CurX-X)+1)
                          Else
                               InStr[(CurX-X)+1] := Ch;
                          Inc (CurX);
                     End;
                End;
           End;
           While Pos (#0,InStr) > 0 Do
                 Delete (InStr,Pos (#0,InStr),1);
           WriteS (InStr,X,Y,Colr);
     Until (Ch = #13) Or (Ch = #27);
     For I := Length (InStr) To MaxLen-1 Do
         WriteS (#32,I+X,Y,7);
     If Ch = #27 Then
        NewIn := ''
     Else
         NewIn := InStr;
     SetCursor (OldCursor);
End;
