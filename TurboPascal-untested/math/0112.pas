Program Sample_Trunc_Frac;

Var

    nNumber,
    nTrunc,
    nFrac : Real;

{ Number es xxxx.yyy }

Procedure Trunc_Frac(nIn : Real; Var nTruncOut,nFracOut : Real);
Var      cSt : String;
     nDummy  : Integer;
Begin
  Str(nIn:18:8,cSt);
  Val(Copy(cSt,1,10),nTruncOut,nDummy);
  Val('0'+Copy(cSt,10,5),nFracOut,nDummy);  { .xxx }
End;

Begin
  Writeln;
  nNumber := 1234567.891234;
  Trunc_frac(nNumber,nTrunc,nFrac);
  Writeln('Number : ',nNumber:18:8,
          ' Trunc : ',nTrunc:10:0,
          '  Frac : ',nFrac:18:8);

  nNumber := 5555.0;
  Trunc_frac(nNumber,nTrunc,nFrac);
  Writeln('Number : ',nNumber:18:8,
          ' Trunc : ',nTrunc:10:0,
          '  Frac : ',nFrac:18:8);

  nNumber := -10001.555;
  Trunc_frac(nNumber,nTrunc,nFrac);
  Writeln('Number : ',nNumber:18:8,
          ' Trunc : ',nTrunc:10:0,
          '  Frac : ',nFrac:18:8);

End.

