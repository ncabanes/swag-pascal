{
> It Word wrapped one line but you get the idea.  Is there an easier or
> faster way to do this?
}
Var
  Num, Code : Integer;
  Par : String;

For F := 2 To ParamCount Do
 begin
 If Pos('/', ParamStr(F)) = 1 Then
   P := Copy(ParamStr(F), 2, 2);

 If (Pos('A', P) = 1) Or (Pos('a', P) = 1) Then
 begin
   Val(Copy(P, 2, 1), Num, Code);
   If Num In [1..5] Then
     ReadString(Num);
 end;
 If (Pos('O',P) = 1) Or (Pos('o',P) = 1) Then Overide := False;
 If (Pos('S',P) = 1) Or (Pos('s',P) = 1) Then Spin := False;
 If (Pos('F',P) = 1) Or (Pos('f',P) = 1) Then ComLine(1,200);
 If (Pos('C',P) = 1) Or (Pos('c',P) = 1) Then ComLine(2,200);
 If (Pos('R',P) = 1) Or (Pos('r',P) = 1) Then
 begin
   Val(Copy(P, 2, 1), Num, Code);
   If Num In [0..10] Then
     Comline(3, Num);
 end;
 If (Pos('L',P) = 1) Or (Pos('l',P) = 1) Then ComLine(4,200);
 If (Pos('M',P) = 1) Or (Pos('m',P) = 1) Then ComLine(Random(4)+1,0);
 If (Pos('B',P) = 1) Or (Pos('b',P) = 1) Then DirectVideo := False;
 If (Pos('P',P) = 1) Or (Pos('p',P) = 1) Then
 begin
   Val(Copy(P, 2, 1), Num, Code);
   If Num In [0..3] Then
     Comline(5,200+Num);
 end;
 If (Pos('E',P) = 1) Or (Pos('p',P) = 1) Then ReturnLevel := True;
 If (Pos('?',P) = 1) Then Error;
end;

{
Some Notes:
   I am not sure if it will return a 0 when the it asks For Val(Copy(P, 2, 1),
Num, Code) and the P Variable isn't R1, R2, R3, etc (when it is just R from a
/R) so you may have to trap that one differently or change the Program so they
have to say /R0 instead of /R.  I hope you follow the rest of the code and I
hope it works.  I have no idea what your Program is For so I couldn't test it
either (too lazy am I?  I think not... The above wasn't too easy to do!) So I
hope it works and good luck...
}
