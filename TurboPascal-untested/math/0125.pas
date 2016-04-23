 Program MatrixInversionExample;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Matrix inversion           ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1995. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}

   {   Gausian algorithm for matrix inversion  }

   Const MaxN = 10;

   Type Row    = array [1..MaxN] of real;
        Matrix = array [1..MaxN] of Row;

   Var I, J        : integer;
       InversionOK : Boolean;
       A           : Matrix;

   { A is matrix to be inverted, and N is dimension of matrix. }
   { Result is return in A.                                    }

   Procedure MatrixInversion (Var A:Matrix; N:integer);
     Var I, J, K : integer;
         Factor  : real;
         Temp    : Row;
         B       : Matrix;
       Begin
         InversionOK:=False;
         For I:=1 to N do
           For J:=1 to N do
             If I=J then
               B [I,J]:=1
                    else
               B [I,J]:=0;
         For I:=1 to N do
           Begin
             For J:=I+1 to N do
               If Abs (A [I,I])<Abs (A [J,I]) then
                 Begin
                   Temp:=A [I];
                   A [I]:=A [J];
                   A [J]:=Temp;
                   Temp:=B [I];
                   B [I]:=B [J];
                   B [J]:=Temp
                 End;
             If A [I,I]=0 then Exit;
             Factor:=A [I,I];
             For J:=N downto 1 do
               Begin
                 B [I,J]:=B [I,J]/Factor;
                 A [I,J]:=A [I,J]/Factor
               End;
             For J:=I+1 to N do
               Begin
                 Factor:=-A [J,I];
                 For K:=1 to N do
                   Begin
                     A [J,K]:=A [J,K]+A [I,K]*Factor;
                     B [J,K]:=B [J,K]+B [I,K]*Factor
                   End
               End
           End;
         For I:=N downto 2 do
           Begin
             For J:=I-1 downto 1 do
               Begin
                 Factor:=-A [J,I];
                 For K:=1 to N do
                   Begin
                     A [J,K]:=A [J,K]+A [I,K]*Factor;
                     B [J,K]:=B [J,K]+B [I,K]*Factor
                   End
               End
           End;
         A:=B;
         InversionOK:=True
       End;

   Begin
     A [1,1]:=3; A [1,2]:=-2; A [1,3]:=0;
     A [2,1]:=1; A [2,2]:=4;  A [2,3]:=-1;
     A [3,1]:=7; A [3,2]:=5;  A [3,3]:=-3;
     Writeln ('Matrix A is: ');
     For I:=1 to 3 do
       Begin
         For J:=1 to 3 do
           Write (A [I,J]:6:2);
         Writeln
       End;
     MatrixInversion (A,3);
     If not InversionOK then
       Writeln ('Matrix cannot be inverted.')
                        else
       Begin
         Writeln ('Inverse matrix of A, i.e. (A^(-1)), is: ');
         For I:=1 to 3 do
           Begin
             For J:=1 to 3 do
               Write (A [I,J]:6:2);
             Writeln
           End
       End
   End.