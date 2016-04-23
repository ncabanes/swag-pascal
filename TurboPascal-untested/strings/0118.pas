{ *** Handles string in/output and various conversion routines
  ***
}

Unit StrIO;



INTERFACE

Uses Vars;

     FUNCTION StatusBar(total, amt, barlength: longint): St80;
     {FUNCTION StatusBar(total, amt : longint): St80;}
     FUNCTION ITOA(i: longint): St40;
     FUNCTION ATOI(s: St40): LongInt;
     FUNCTION UpCase(c: Char): Char;
     FUNCTION UCase(s: String): String;
     FUNCTION RepStr(Times: Byte; Which: Char): String;
     FUNCTION Strip_Path(Fullfilename: String): String;
     FUNCTION Leading_Zero(Number: String; Digits: Byte): String;
     FUNCTION Read_Str(StrLen     : Byte;
                       InputFg,
                       InputBg    : Integer;
                       Hidden,
                       Spaces     : Char;
                       SpinWanted,
                       Display,
                       Upper,
                       OnlyNumbers,
                       AutoReturn : Boolean;
                       Default    : String): String;
     PROCEDURE Flush_Keyboard_Buffer;
     FUNCTION Right_Pad(s: String; MaxLength: Word): String;
     FUNCTION Right_Strip(s: String): String;
     FUNCTION Right_Justify(s: String; sl: Byte): String;
     FUNCTION CommaNum (I : LongInt): String;
     FUNCTION Strip_Filename(S: String): String;


CONST
     Str_Yes  : String = 'Yes';
     Str_No   : String = 'No';

IMPLEMENTATION

Uses Crt;

FUNCTION CharStr(HowMuch: Byte; WithWhatChar: Char): String;
{
 *** fills charStr with withwhatchar to the howmuch
 ***
}
         Var
            j       : Integer;
            TempStr : St80;

         Begin
              TempStr := '';
              For J := 1 To HowMuch Do
                  Insert(WithWhatChar, TempStr, J);
              CharStr := TempStr;
         End;




FUNCTION StatusBar(total, amt, barlength: longint): St80;
{         Const
              BarLength = 30;}

         Var
            a,
            b,
            c,
            d       : longint;
            sD      : String; {for conversion}
            percent : real;
            st      : string;

         Begin
              If (total = 0) OR (amt = 0) Then
                 Begin
                      StatusBar := '';
                      Exit;
                 End;
              If (Amt > Total) Then
                 amt := total;
              Percent := Amt / Total * (Barlength * 10);
              a := trunc(percent);
              b := a div 10;
              c := 1;
              percent := amt / total * 100;
              d := trunc(percent);
              Str(d, sD);
              st := ' (' + sD + '%)';
              StatusBar := CharStr(b * c, #219) + CharStr(Barlength - (b * c), #176) + st;
         End;




FUNCTION ITOA(i: longint): St40;
{
 *** Converts integers into alphanumericals or strings
 ***
}
         Var
            stTemp: St20;

         Begin
              Str(i, stTemp);
              ITOA := stTemp;
         End;


FUNCTION ATOI(s: St40): LongInt;
{
 *** Converts a string into a integer/real
 ***
}
         Var
            Code: Integer;
            lTemp: LongInt;
            rTemp: Real;

         Begin
              Val(s, rTemp, Code);
              If (Code <> 0) Then
                 rTemp := 0;
              lTemp := Trunc(rTemp);
              ATOI := lTemp;
         End;

FUNCTION UpCase(C: Char): Char; Assembler; { will replace TP's built-in upcase }
         ASM
            MOV DL, C
            MOV AX, $6520
            INT $21
            MOV AL, DL           { function result in AL                 }
         END;


FUNCTION UCase(s: String): String;
{
 *** Converts any string(s) into upper case letters
 ***
}
         Var
            J : Integer;

         Begin
              For J := 1 to Length(s) Do
                  s[J] := StrIo.UpCase(s[J]);
              UCase := S;
         End;


FUNCTION RepStr(Times: Byte; Which: Char): String;
         Var
            J        : Byte;
            tString  : String;

         Begin
              tString := '';
              For J := 1 To Times Do
                  tString := tString + Which;
              RepStr := tString;
         End;


FUNCTION Strip_Path(Fullfilename: String): String;
         Var
            tString: String;

         Begin
              tString := FullFilename;
              While (Pos('\', tString) <> 0) Do
                    Delete(tString, 1, Pos('\', tString));
              Strip_Path := tString;
         End;


{
 Makes sure that NUMBER is DIGITS digits.  Ie if DIGITS = 10 and NUMBER = 29
 the result is 0000000029, 10 DIGITS :) Simple hugh?
}
FUNCTION Leading_Zero(Number: String; Digits: Byte): String;
         Var
            tString   : String;             {temporary zero holding spot}
            NeedZeros : Integer;            {Number of zeros needed}
            J         : Byte;               {for the FOR-LOOP}

         Begin
              tString := '';
              NeedZeros := Digits - Length(Number);
              If (NeedZeros > 0) Then
                 Begin
                      for J := 1 TO NeedZeros Do
                          tString := tString + '0';
                      tString := tString + Number;
                 End
              Else
                  tString := Number;

              Leading_Zero := tString;
         End;


FUNCTION Read_Str(StrLen     : Byte;
                  InputFg,
                  InputBg    : Integer;
                  Hidden,
                  Spaces     : Char;
                  SpinWanted,
                  Display,
                  Upper,
                  OnlyNumbers,
                  AutoReturn : Boolean;
                  Default    : String): String;
{
 *** Gets string from local/remote
     StrLen - String length
     InputFg - Foreground for input
     InputBg - Background for input
     Hidden - character to display instead of entered characters or #0
     Spaces - Character to display where nothing is written.
     Display - Display output
     Upper - force upper case
     OnlyNumbers - Characters between 0-9 are allowed, nothing else
     AutoReturn - Wheter to hig enter automatically after STRLENth character
     SpinWanted - Wheter or not to spin a character
     Default - Text displayed as if user/modem typed it in.
 ***
}
         Var
            ChIn    : Char;         {character read in}
            StrCount: Integer;      {current location in string}
            J       : Integer;      {used in For-loop combo}
            TempStr : String;       {temporary string}
            OldX,
            OldY,
            OldFg,
            OldBg    : Word;         {save coordinates}
            SpinCount: Byte;

         Const
              Spin   : Array [1..4] Of Char = ('|', '/', '-', '\');

         Begin
              TempStr := '';
              ChIn := #0;
              StrCount := 0;
              SpinCount := 0;

              if Default <> #0 Then
                 Begin
                      TempStr := Default;
                      StrCount := Length(TempStr);
                 End;

              If Display Then
                Begin
                     OldX := WhereX;
                     OldY := WhereY;
                     OldFg := TextAttr MOD 16;
                     OldBg := TextAttr SHR 4;
                     TextColor(InputFg);  TextBackground(InputBg);
                     if (Spaces < #32) Then
                        Spaces := #32;
                     For J := 1 to StrLen Do
                         Write(Spaces);
                     GotoXY(OldX, OldY);
                     If (Default <> #0) Then
                        Begin
                             For J := 1 to Length(Default) Do
                                 If (Hidden <> #0) Then
                                    Write(Hidden)
                                 Else
                                     Write(Default[J]);
                        End
                End;
              Repeat
                    Repeat
                          If SpinWanted Then
                             Begin
                                  Inc(SpinCount);
                                  If (SpinCount > 4) Then
                                     SpinCount := 1;
                                  Write(Spin[SpinCount]);
                                  GotoXY(WhereX - 1, WhereY);
                                  Delay(30);
                                  Write(' ');
                                  GotoXY(WhereX - 1, WhereY);
                             End;
                    Until Keypressed;
                    ChIn := Readkey;

                    If (ChIn = #0) Then
                       Exit;

                    If Upper then
                       ChIn := Upcase(ChIn);

                    Case UpCase(ChIn) Of
                        #19: Begin {left arrow}
                                   If (StrCount > 1) Then
                                      Begin
                                           Dec(StrCount, 1);
                                           If Display Then
                                              GotoXY(WhereX - 1, WhereY);
                                      End;

                             End;
                         #4: Begin {right arrow}
                                   If (StrCount < StrLen) Then
                                      Begin
                                           Inc(StrCount, 1);
                                           Insert(#32, TempStr, StrCount);
                                           If Display Then
                                              GotoXY(WhereX + 1, WhereY);
                                      End;
                             End;
                         #8: Begin
                                  If (StrCount > 0) Then
                                     Begin
                                          Dec(StrCount, 1);
                                          If Display Then
                                            Begin
                                                 GotoXY(WhereX - 1, WhereY);
                                                 Write(Spaces);
                                                 GotoXY(WhereX - 1, WhereY);
                                            End;
                                          Delete(TempStr, Length(TempStr), 1);
                                     End;
                                  ChIn := #0;
                             End;
                         #13: Begin
                                   If Display Then
                                      GotoXY(1, WhereY + 1);
                              End;
                       #32..#255: Begin
                                       If (StrCount < StrLen) Then
                                          Begin
                                               If OnlyNumbers Then
                                                  Begin
                                                       Case ChIn Of
                                                       '0'..'9', '.': Begin
                                                                           Inc(StrCount);
                                                                           Insert(ChIn, TempStr, StrCount);
                                                                      End;
                                                       Else {anything except numbers}
                                                           ChIn := #0;
                                                       End;
                                                  End {if onlynumbers then}
                                               Else
                                                   Begin
                                                       Inc(StrCount);
                                                       Insert(ChIn, TempStr, StrCount);
                                                   End;
                                          End
                                       Else
                                           ChIn := #0;
                                  End;
                        Else
                            ChIn := #0;
                         End; {case}

                         If (StrCount = StrLen) Then
                            Begin
                                 If AutoReturn Then
                                    Begin
                                         ChIn := #13;
                                         GotoXY(1, WhereY + 1);
                                    End;
                            End;

                         If Display AND (ChIn <> #0) Then
                            if (Hidden > #32) Then {space or no pw}
                               Write(Hidden)
                            Else
                                Write(ChIn);
              Until (ChIn = #13) OR (ChIn = #27);

              If Display Then
                 Begin
                      TextColor(OldFg);
                      TextBackground(OldBg);
                 End;

              Read_Str := TempStr;
         End;



PROCEDURE Flush_Keyboard_Buffer;
          Var
             ChIn        : Char;        {for clearing the keyboard buffer}

          Begin
               While Keypressed Do
                     ChIn := ReadKey;
          End;


FUNCTION Right_Pad(s: String; MaxLength: Word): String;
         Const
              tString : String = '';
              HowMany : Byte = 0;
              J       : Byte = 0;

         Begin
              J := 0;
              HowMany := 0;
              tString := '';

              {check for greater then number strings}
              If (Length(s) > MaxLength) Then
                 Begin
                      tString := Copy(s, 1, MaxLength);
                      Exit;
                 End
              Else
                  Begin
                       HowMany := (MaxLength - Length(s));
                       Repeat
                             Inc(J);
                             tString := tString + #32;
                       Until J >= HowMany;
                       tString := s + tString;
                  End;

              Right_Pad := tString;
         End;

FUNCTION Right_Strip(s: String): String;
         Var
            StrLen,
            Count        : Byte;

         Begin
              StrLen := Length(s);
              Count  := StrLen + 1;
              Repeat
                    Dec(Count);
              Until (s[Count] <> #32);
              Delete(s, Count + 1, StrLen - Count);
              Right_Strip := S;
         End;

FUNCTION Right_Justify(s: String; sl: Byte): String;
         Var
            tString2,
            tString: String;
            Where,
            HowMuch: Byte;

         Begin
              tString := '';
              tString2 := '';
              tString := s;
              If Length(tString) > Sl Then
                 Begin
                      tString2 := Copy(tString, 1, Sl);
                      Right_Justify := tString2;
                      Exit;
                 End;

              Where := 1;
              Where := sl - Length(tString);

              FillChar(tString2, Where, #32);
              Insert(tString, tString2, Where);
              Delete(tString2, Where + Length(tString), Length(tString2) - (Where + Length(tString)) + 1);
              Right_Justify := tString2;
         End;

Function CommaNum (I : LongInt): String;
Var
    TmpString : String;
    Counter, Tester : Byte;
Begin
  TmpString := '';
  Counter   := 0;
  Tester    := 0;
  Str (i, TmpString);
  For Counter := Length (TmpString) Downto 1 Do
  Begin
    Inc (Tester);
    If Tester = 3 Then
    Begin
      Tester := 0;
      Dec (Counter);
      TmpString := Copy (TmpString, 1, Counter) + ','
                 + Copy (TmpString, Counter + 1, Length (TmpString) );
      Inc (Counter);
    End;
  End;
  If TmpString[1] = ',' THEN DELETE(TmpString,1,1);
  CommaNum := TmpString;
End;


{Returns the path from C:\BLOB\SHOOT\DIS.THD would give you C:\BLOB\SHOOT}
FUNCTION Strip_Filename(S: String): String;
         Var
            SlashPos  : Byte;
            tString   : String;

         Begin
              tString := '';

              SlashPos := Pos('\', S);
              If SlashPos = 0 Then
                 Begin
                      Strip_Filename := '';
                      Exit;
                 End;

              Repeat
                    SlashPos := Pos('\', S);
                    tString := tString + Copy(S, 1, SlashPos);
                    Delete(s, 1, SlashPos);
              Until SlashPos = 0;
              Strip_FIlename := tString;
         End;


BEGIN
END.