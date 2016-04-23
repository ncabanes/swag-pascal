{
To shift a LongInt or Pointer into another Word do this..

The HoBitsToShift is the number of Bits you want to move
the way i did it you get the upper half of the LongInt first...
}

Function Shitftit(Var MyLongInt : LongInt) : Word;
Var
  Count  : Byte;
  TShift : Word;
Begin
  TShift := 0;
  For Count := 1 to HowBitsToShift Do
  Begin
    Tshit := (Tshit Shl 1);
    If MyLongInt and $80000000 <> 0 Then
      TShift := (TShift or $01);
    MyLongInt := (MyLongInt Shl 1);
  End;
  ShiftIt := TShift;
End;

