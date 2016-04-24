(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0004.PAS
  Description: Get Command Line #3
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

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
