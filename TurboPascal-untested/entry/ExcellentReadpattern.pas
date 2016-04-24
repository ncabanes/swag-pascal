(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0022.PAS
  Description: Excellent ReadPattern
  Author: STERLING BATES
  Date: 02-28-95  10:06
*)

Procedure ReadP (Var NewIn : String; OldIn : String; X,Y,Colr : Byte;
                 FChar : Char; ValidChars : ChSet; Patrn : String);

              (* NewIn         = Variable containing data entered by user
                 OldIn         = Default input string
                 X,Y           = Coordinates to begin reading
                 FChar         = Fill character at End-of-String
                 ValidChars    = Set of Char of characters valid for input
                                 (in some cases is redundant)
                 Patrn         = String containing three different chars:
                                        'X's for blank space (no data)
                                        '#'s for numbers only
                                        '@'s for alpha characters only
                                        '%'s for both alpha & numeric
characters              *)

  (* When calling ReadP, the prompt should already be on-screen.  X,Y locates
     the point to begin the reading.  When ReadP returns a value in NewIn,
     please note that a pattern of '###X###X####' will be returned looking like
     '##########'.  The X's do not denote a space in the final string.  ie:

                    Please Enter Your Phone Number: (403) 123-4567

     will be returned in NewIn as 4031234567.  The pattern would have resembled
     the example above.

     ** NOTE **  There are functions/procedures required to run this procedure.
                 They are:
                                GetCursor (not necessary)
                                SetCursor (not necessary)
                                WriteP (pattern-writing routine, see next few
                                        posts, is necessary)

     A demo program is included at the bottom of the message.

  *)

  (* Standard disclaimer: I'm not liable for anything this procedure does
                          outside the original purpose of the procedure.  If
                          something bad happens, let me know, but that's all
                          I can do.
  *)

Var
   CurX, StLen, PatX, NumXs, MaxLen,
   Tmp                                  : Byte;
   DefChars                             : Set Of Char;
   OldCursor                            : Word;

Begin
     Tmp := 0;
     For I := 1 To Length (Patrn) Do
         If Patrn[I] = 'X' Then
            Inc (Tmp);
     If Length (OldIn) > Length (Patrn)-Tmp Then
        OldIn := Copy (OldIn,1,Length (Patrn)-Tmp);
     WriteP (OldIn,X,Y,HiColr,FChar,Patrn);
     InStr := OldIn;
     StLen := Length (OldIn);
     NumXs := 0;
     For I := 1 To StLen Do
         If Patrn[I] = 'X' Then
            Inc (NumXs);
     CurX := StLen+X+NumXs;
     PatX := StLen+NumXs+1;
     If PatX = 0 Then
     Begin
          PatX := 1;
          CurX := X;
     End;
     DefChars := ValidChars;
     MaxLen := Length (Patrn);
     OldCursor := GetCursor;
     Repeat
           If PatX = 0 Then
           Begin
                PatX := 1;
                CurX := X;
           End;
           While Patrn[PatX] = 'X' Do
           Begin
                Inc (PatX);
                Inc (CurX);
           End;
           NumXs := 0;
           For I := 1 To PatX Do
               If Patrn[I] = 'X' Then
                  Inc (NumXs);
           If InsOn Then
              SetCursor (DefaultCursor)
           Else
               SetCursor (BlockCursor);
           GotoXY (CurX,Y);
           Case Patrn[PatX] Of
                '#': ValidChars := NumChars;
                '@': ValidChars := AlphaChars;
                '%': ValidChars := NumChars + AlphaChars;
           End;
           ValidChars := ValidChars + [#8,#13,#210,#211] + HKeySet + FuncKeys +
                                      MenuKeys + ArrowKeys;
           Repeat
                 Ch := ReadKey;
           Until Ch In ValidChars;
           SetCursor (OldCursor);
           Case Ch Of
                #8:
                Begin
                     If PatX >= 2 Then
                     Begin
                          If Patrn[PatX-1] = 'X' Then
                          Begin
                               While (Patrn[PatX-1] = 'X') And (PatX > 1) Do
                               Begin
                                    Dec (PatX);
                                    Dec (CurX);
                               End;
                               Dec (PatX);
                               Dec (CurX);
                          End
                          Else
                          Begin
                               Dec (CurX);
                               Dec (PatX);
                          End;
                          If (CurX >= X) And (Length (InStr) > 0) Then
                          Begin
                               NumXs := 0;
                               For I := 1 To PatX Do
                                   If Patrn[I] = 'X' Then
                                      Inc (NumXs);
                               Delete (InStr,PatX-NumXs,1);
                          End;
                     End;
                End;
                #203: { Left arrow }
                Begin
                     If CurX > X Then
                        If Patrn[PatX-1] <> 'X' Then
                        Begin
                             Dec (CurX);
                             Dec (PatX);
                        End
                        Else
                        Begin
                             While Patrn[PatX-1] = 'X' Do
                             Begin
                                  Dec (CurX);
                                  Dec (PatX);
                             End;
                             Dec (CurX);
                             Dec (PatX);
                        End;
                     If PatX < 1 Then
                     Begin
                          CurX := X;
                          PatX := 1;
                     End;
                End;
                #205: { Right arrow }
                      If PatX-NumXs <= Length (InStr) Then
                         If Patrn[PatX+1] <> 'X' Then
                         Begin
                              Inc (CurX);
                              Inc (PatX);
                         End
                         Else
                         Begin
                              Inc (CurX);
                              Inc (PatX);
                              While Patrn[PatX] = 'X' Do
                              Begin
                                   Inc (CurX);
                                   Inc (PatX);
                              End;
                         End;
                #199: { Home }
                Begin
                     CurX := X;
                     PatX := 1;
                End;
                #207: { End }
                Begin
                     PatX := Length (InStr)+1;
                     For I := 1 To PatX Do
                         If Patrn[I] = 'X' Then
                            Inc (PatX);
                     CurX := PatX+X-1;
                End;
                #210: { Insert }
                      InsOn := InsOn XOr True;
                #211: { Delete }
                      Delete (InStr,PatX-NumXs,1);
                #65..#90,
                #97..#122, { Alphabet }
                #48..#57,  { Numbers }
                #91..#96,
                #32..#47,
                #58..#64:  { Other chars }
                Begin
                     If (CurX-X < MaxLen) And (((Length (InStr) < MaxLen) And
                        (InsOn)) Or ((Not InsOn))) Then
                     Begin
                          If InsOn Then
                               Insert (Ch,InStr,PatX-NumXs)
                          Else
                          Begin
                               If PatX-NumXs > Length (InStr) Then
                                  Insert (Ch,InStr,PatX-NumXs)
                               Else
                                   InStr[PatX-NumXs] := Ch;
                          End;
                          Inc (CurX);
                          Inc (PatX);
                     End;
                End;
           End;
           If Length (InStr) > Length (Patrn) Then
              InStr[0] := Chr (Length (Patrn));
           WriteP (InStr,X,Y,Colr,FChar,Patrn);
     Until (Ch = #13) Or (Ch = #27);
     If Ch = #27 Then
        NewIn := '';
     If Ch = #13 Then
        NewIn := InStr;
End;

