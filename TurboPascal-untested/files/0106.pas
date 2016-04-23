
Unit WildChck;
{$O+}

Interface
Function MatchWC(WC,S : String):Boolean;
Implementation

Type BooleanRA = Array[Boolean] Of String[5];
Const TorF_Str : BooleanRA = ('False','True ');

Procedure Upper(Var S : String);
  Var i : Byte;
  Begin
    For i := 1 To Length(S) Do S[i] := UpCase(S[i]);
  End;

Function MatchWC(WC,S : String):Boolean;
  Var
    WCLen : Byte ABSOLUTE WC;
    SLen  : Byte ABSOLUTE S;
    is,iw : Byte;
    Match : Boolean;
  Begin
    Match := True; is := 1; iw := 1;Upper(WC);Upper(S);
    While (iw <= WCLen) AND (is <= SLen) AND (Match) Do Begin
      Case WC[iw] Of
        '?' : Begin Inc(is); Inc(iw);
              End; {'?'}
        '*' : Begin
                While ((WC[iw] = '?') OR (WC[iw] = '*')) AND
                      (iw <= WCLen) Do Inc(iw);
                If iw <= WCLen Then Begin
                  While (WC[iw] <> S[is]) AND (is <= SLen) Do
                    Inc(is);
                  If (is <= Slen) AND (WC[iw] = S[is]) Then Begin
                    Inc(is); Inc(iw); End
                  Else Match := False;
                End;
              End; {'*'}
        Else  {Else for Case}
          If WC[iw] = S[is] Then Begin
            Inc(iw); Inc(is); End
          Else Match := False;
      End;  {Case}
    End;  {While}
    MatchWC := Match;
  End;
end.
