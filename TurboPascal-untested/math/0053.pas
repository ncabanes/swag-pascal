{
>Does anyone have any source for evaluating math expressions? I would like to
>find some source that can evaluate an expression like
>
> 5 * (3 + 4)  or B * 3 + C
}

Program Test;

Uses
  Strings; {You have to use your own unit}

Var
  x : Real;
  maxvar : Integer;
  s : String;

Const
  maxfun = 21;
  func : Array[1..maxfun] Of String[9] =
           ('LN', 'SINH', 'SIN', 'COSH', 'COS', 'TANH', 'TAN', 'COTH', 'COT',
            'SQRT', 'SQR', 'EXP', 'ARCSIN', 'ARSINH', 'ARCCOS', 'ARCOSH',
            'ARCTAN', 'ARTANH', 'ARCCOT', 'ARCOTH', 'NEG');

Var
  errnum : Integer;

Function Calculate(f : String) : Real;

Var
{  errnum : Integer;}
  eps : Real;

  Function Eval(l, r : Integer) : Real;

  Var
    i, j, k, wo, op : Integer;
    result, t1, t2 : real;

  Begin
    If errnum > 0 Then Exit;
    wo := 0; op := 6; k := 0;

    While (f[l] = '(') And (f[r] = ')') Do Begin
      Inc(l); Dec(r);
    End;

    If l > r Then Begin
      errnum := 1; eval := 0.0; Exit;
    End;

    For i := l To r Do Begin

       Case f[i] of
          '(':  Inc(k);
          ')':  Dec(k);
          Else If k = 0 Then
            Case f[i] of

              '+' : Begin
                wo := i; op := 1
              End;

              '-' : Begin
                wo := i; op := 2
              End;

              '*' : If op > 2 Then Begin
                wo := i; op := 3
              End;

              '/' : If op > 2 Then Begin
                wo := i; op := 4
              End;

              '^' : If op > 4 Then Begin
                wo := i; op := 5
              End;

          End;
       End;
    End;

    If k <> 0 Then Begin
      errnum := 2; eval := 0.0; Exit;
    End;

    If op < 6 Then Begin
       t1 := eval(l, wo-1); If errnum > 0 Then Exit;
       t2 := eval(wo+1, r); If errnum > 0 Then Exit;
    End;

    Case op of
       1 : Begin
         eval := t1 + t2;
       End;

       2 : Begin
         eval := t1 - t2;
       End;

       3 : Begin
         eval := t1 * t2;
       End;

       4 : Begin
         If Abs(t2) < eps Then Begin errnum := 4; eval := 0.0; Exit; End;
         eval := t1 / t2;
       End;

       5 : Begin
         If t1 < eps Then Begin errnum := 3; eval := 0.0; Exit; End;
         eval := exp(t2*ln(t1));
       End;

       6 : Begin

         i:=0;
         Repeat
           Inc(i);
         Until (i > maxfun) Or (Pos(func[i], f) = l);

         If i <= maxfun Then t1 := eval(l+length(func[i]), r);
         If errnum > 0 Then Exit;

         Case i Of
           1 : Begin
             eval := ln(t1);
           End;

           2 : Begin
             eval := (exp(t1)-exp(-t1))/2;
           End;

           3 : Begin
             eval := sin(t1);
           End;

           4 : Begin
             eval := (exp(t1)+exp(-t1))/2;
           End;

           5 : Begin
             eval := cos(t1);
           End;

           6 : Begin
             eval := exp(-t1)/(exp(t1)+exp(-t1))*2+1;
           End;

           7 : Begin
             eval := sin(t1)/cos(t1);
           End;

           8 : Begin
             eval := exp(-t1)/(exp(t1)-exp(-t1))*2+1;
           End;

           9 : Begin
             eval := cos(t1)/sin(t1);
           End;

          10 : Begin
            eval := sqrt(t1);
          End;

          11 : Begin
            eval := sqr(t1);
          End;

          12 : Begin
            eval := exp(t1);
          End;

          13 : Begin
            eval := arctan(t1/sqrt(1-sqr(t1)));
          End;

          14 : Begin
            eval := ln(t1+sqrt(sqr(t1+1)));
          End;

          15 : Begin
            eval := -arctan(t1/sqrt(1-sqr(t1)))+pi/2;
          End;

          16 : Begin
            eval := ln(t1+sqrt(sqr(t1-1)));
          End;

          17 : Begin
            eval := arctan(t1);
          End;

          18 : Begin
            eval := ln((1+t1)/(1-t1))/2;
          End;

          19 : Begin
            eval := arctan(t1)+pi/2;
          End;

          20 : Begin
            eval := ln((t1+1)/(t1-1))/2;
          End;

          21 : Begin
            eval := -t1;
          End;

          Else
            If copy(f, l, r-l+1) = 'PI' Then
              eval := Pi
            Else If copy(f, l, r-l+1) = 'E' Then
              eval := 2.718281828
            Else Begin
              Val(copy(f, l, r-l+1), result, j);
              If j = 0 Then Begin
                eval := result;
              End Else Begin
                {here you can handle other variables}
                errnum := 5; eval := 0.0; Exit;
              End;
            End;

         End
       End
    End
  End;

Begin
{  errnum := 0;} eps := 1.0E-9;

  f := StripBlanks(UpStr(f));
  Calculate := Eval(1, length(f));
End;

Begin
READLN(s);
While length(s) > 0 do Begin
  errnum := 0; x := calculate(s);
  writeln('Ergebnis : ',x:14:6, ' Fehlercode : ', errnum);
  readln(s);
End;
End.

{
You have to write your own function STRIPBLANKS, which eliminates ALL
blanks in a string. And the only variables supported are e and pi. But
it is not difficult to handle other variables.

}