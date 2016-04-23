Program CommandLine;    { CL.PAS }
Var
  CharCount,
  i         :Word;
begin
  CharCount := Mem[PrefixSeg:$80];  { number of input Characters}
  WriteLn('Input Characters: ', CharCount );
  For i := 1 to CharCount do Write( CHR( Mem[PrefixSeg:$80+i] ));
    WriteLn;
end.




