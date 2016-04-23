(*
From: RYAN THOMPSON
Subj: RE: MATH PARSING
*)

Function Evaluate(Equation : String) : String;
  Var
    Temp, Operand, Front, Rear : String;
    X, Y, Par1, Par2 : Integer;
    Value1, Value2, Valtemp : Real;
    OperOK,
    BadExp : Boolean;
  Begin
    If Equation = Error then begin
      Evaluate:= Error;
      Exit;
    end;
    While Pos(' ', Equation) > 0 do
      Delete(Equation, Pos(' ', Equation), 1);
    repeat
      X:= 1;
      Par1:= 0;
      Par2:= 0;
      repeat
          If Equation[X] = '(' then Par1:= X;
          If Equation[X] = ')' then Par2:= X;
          Inc(X);
      until (X = Length(Equation) + 1) or ((Par1 > 0) and (Par2 > 0));
      If (Par2 > 0) and (Par2+1 < Length(Equation)) and
           (Equation[Par2 + 1] = '(')
      then Insert('x', Equation, Par2 + 1);
      If (Par2 > Par1) then begin
          Temp:= Equation;
          Rear:= Copy(Temp, Par2 + 1, 255);
         Delete(Temp, Par2, 255);
         Front:= Copy(Temp, 1, Par1 - 1);
          Delete(Temp, 1, Par1);
        Temp:= Evaluate(Temp);
        Equation:= Front + Temp + Rear;
        While Pos(' ', Equation) > 0 do
          Delete(Equation, Pos(' ', Equation), 1);
      end
      else if Par2 < Par1 then begin
         Evaluate:= Error;
        Exit;
      end;
    until Par2 <= Par1;
    Value1:= 0;
    repeat
      If (Length(Equation) > 0) then begin
        Operand:= '';
      X:= 1;
      While ((Equation[X] < '0') or (Equation[X] > '9'))
            and (Equation[X] <> '.')
            and (X < Length(Equation) + 1)
      do begin
        Operand:= Operand + Equation[X];
        Inc(X);
      end;
         Delete(Equation, 1, X - 1);
    end;
    If Length(Equation) > 0 then begin
        Temp:= '0';
      X:= 1;
      while (((Equation[X] <= '9') and (Equation[X] >= '0'))
            or (Equation[X] = '.')) and (X < Length(Equation) + 1) do
      begin
          Temp:= Temp + Equation[X];
        Inc(X);
         end;
        If (X > 10) and (Pos('.', Equation) > 9) then begin
          Evaluate:= Error;
          Exit;
      end;
      Delete(Equation, 1, X - 1);
      Val(Temp, Value2, Y);
      If Y <> 0 then begin
        Evaluate:= Error;
        Exit;
      end;
    end;
    Temp:= '';
    If Length(Operand) > 1 then begin
      Temp:= Operand;
         Delete(Temp, Pos('+', Temp), 1);
        If Pos('-', Temp) <> Length(Temp)
      then Delete(Temp, Pos('-', Temp), 1);
      Delete(Temp, Pos('x', Temp), 1);
      Delete(Temp, Pos('/', Temp), 1);
      Delete(Temp, Pos('^', Temp), 1);
      If Pos('+', Operand) = 1 then Operand:= '+'
      else if Pos('-', Operand) = 1 then Operand:= '-'
      else if Pos('x', Operand) = 1 then Operand:= 'x'
        else if Pos('/', Operand) = 1 then Operand:= '/'
      else if Pos('^', Operand) = 1 then Operand:= '^'
      else Operand:= '';
    end;
    OperOK:= False;
    If Temp = 'SIN' then begin
      OperOK:= True;
      Value2:= Sin(Rad(Value2));
    end;
    If Temp = 'COS' then begin
        OperOK:= True;
        Value2:= Cos(Rad(Value2));
    end;
    If Temp = 'TAN' then if Cos(Rad(Value2)) <> 0 then begin
        OperOK:= True;
        Value2:= (Sin(Rad(Value2)) / Cos(Rad(Value2)));
    end
    else begin
        Evaluate:= Error;
        Exit;
    end;
    If Temp = 'SQR' then begin
        OperOK:= True;
        Value2:= Sqrt(Value2);
    end;
    If Temp = 'ASIN' then begin
        OperOK:= True;
        Valtemp:= 1 - Sqr(Value2);
         If Valtemp < 0 then begin
           Evaluate:= Error;
           Exit;
         end
         else If Sqrt(Valtemp) = 0 then Value2:= 90
         else Value2:= Deg(ArcTan(Value2 / Sqrt(Valtemp)));
    end;
    If Temp = 'ACOS' then begin
      OperOK:= True;
      Valtemp:= 1 - Sqr(Value2);
         If Valtemp < 0 then begin
           Evaluate:= Error;
        Exit;
         end
         else If Value2 = 0 then Value2:= 90
         else Value2:= Deg(Arctan(Sqrt(Valtemp) / Value2))
    end;
