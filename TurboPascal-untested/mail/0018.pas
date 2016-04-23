{
TH> Apparently this contains the filepositions of the records (and also the
TH> conference numbers?) but the numbers are not in normal format. Can somebody
TH>  please explain the format of this file and how to convert these numbers to
TH> and from something TP can work with?

There is supposed to be at least two doc's explaining the QWK format. I have
here a unit that converts the integer to basicreal (i guess it's what you
need..) I'm sorry I can't remember the of the doc's..

------------------- 8<
}
Unit BasConv;

Interface
  Function BasicReal2Long(InValue: LongInt): LongInt;
                {Convert Basic Short Reals to LongInts}

  Function Long2BasicReal(InValue: LongInt): LongInt;
                {Convert LongInts to Basic Short Reals}

Implementation

Function BasicReal2Long(InValue: LongInt): LongInt;

  Var
  Temp: LongInt;
  Expon: Integer;

  Begin
  Expon := ((InValue shr 24) and $ff) - 152;
  Temp := (InValue and $007FFFFF) or $00800000;
  If Expon < 0 Then
    Temp := Temp shr Abs(Expon)
  Else
    Temp := Temp shl Expon;
  If (InValue and $00800000) <> 0 Then
    BasicReal2Long := -Temp
  Else
    BasicReal2Long := Temp;
  If Expon = 0 Then
    BasicReal2Long := 0;
  End;


Function Long2BasicReal(InValue: LongInt): LongInt;
  Var
  Negative: Boolean;
  Expon: LongInt;

  Begin
  If InValue = 0 Then
    Long2BasicReal := 0
  Else
    Begin
    If InValue < 0 Then
      Begin
      Negative := True;
      InValue := Abs(InValue);
      End
    Else
      Negative := False;
    Expon := 152;
    If InValue < $007FFFFF Then
      While ((InValue and $00800000) = 0) Do
        Begin
        InValue := InValue shl 1;
        Dec(Expon);
        End
    Else
      While ((InValue And $FF000000) <> 0) Do
        Begin
        InValue := InValue shr 1;
        Inc(Expon);
        End;
    InValue := InValue And $007FFFFF;
    If Negative Then
      InValue := InValue Or $00800000;
    Long2BasicReal := InValue + (Expon shl 24);
    End;
  End;

End.
