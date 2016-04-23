{   Arrrggghh. I hate Bubble sorts. Why don't you use Merge sort? It's a hell
 of a lot faster and if you have a large enough stack, there wouldn't be
 any problems. if you were not interested in doing a recursive sort, then
 here is an example fo the Shell sort which is one of the most efficient
 non recursive sorts around.
}


Const
    Max = 50;
Type
    ArrayType = Array[1..Max] of Integer;

Var
    Data, Temp    : ArrayType;
    Response      : Char;
    X, Iteration  : Integer;

Procedure ShellSort (Var Data : ArrayType;Var Iteration : Integer;
                                            NumberItems : Integer);

Procedure Sort (Var Data : ArrayType; Var Iteration : Integer;
                             NumberItems, Distance : Integer);

Var
   X, Y : Integer;

begin   {Sort}
   Iteration := 0;
   For Y := Distance + 1 to NumberItems Do
      begin  {For}
         X := Y - Distance;
         While X > 0 Do
            begin   {While}
               if Data[X+Distance] < Data[X] then
                  begin   {if}
                     Switch (Data[X+Distance], Data[X], Iteration);
                     X := X - Distance;
                     Iteration := Iteration + 1
                  end     {if}
               else
                  X := 0;
            end;    {While}
      end    {For}
end;    {Sort}

begin   {ShellSort}
   Distance := NumberItems div 2;
   While Distance > 0 do
      begin   {While}
         Sort (Data, Iteration, NumberItems, Distance);
         Distance := Distance div 2
      end;    {While}
end;    {ShellSort}
