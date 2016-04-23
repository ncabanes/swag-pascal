program FuncTest;
{
 An example of how to pass functions as parameters to
 another procedure (csc).

 This program comes with no guarrentees and no support.
}

                                    
type
  TBoolFunc = function: Boolean;
  TRealFunc = function(X: Real): Real;

var
  RealFunc: TRealFunc;
  BoolFunc: TBoolFunc;

function Con1: Boolean; Far;
begin
  Con1 := True;
end;

function Con2(X : Real): Real; far;
begin
  Con2 := X * X;
end;

procedure Sambo(AFunc: TRealFunc);
begin
  WriteLn(AFunc(4):2:2);
end;

begin
  BoolFunc := Con1;
  RealFunc := Con2;
  WriteLn(BoolFunc);
  Sambo(RealFunc);
end.