This is legal syntax For Turbo/Borland Pascal v.6 and above:

Type
  MathFunc = Function (x:Real):Real;

  Function MyFunc(x:Real):Real;
  begin
    MyFunc:=2 * Sin(x) + Cos(x);
  end;

  Function YetAnother(x:Real):Real;
  begin
    YetAnother:=Sqr(x) + x/2 + 1;
  end;

  Function AreaUnder(f:MathFunc; Lo, Hi:Real; Steps:Integer):Real;
  Var
    sum,
    x,
    dx  : Real;
    i   : Integer;
  begin
    dx:=(Hi-Lo)/Steps;
    sum:=0;
    x:=Lo;
    For i:=1 to Steps
    do begin
      sum:=sum + f(x);
      x:=x + dx;
    end;
  end;

  begin
    Writeln(AreaUnder(MyFunc, 0, 2*PI, 360));
    Writeln(AreaUnder(YetAnother, -1,1, 100));
  end.

