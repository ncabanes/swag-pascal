{
> Does anyone have an idea to perForm permutations With pascal 7.0 ?
> As an example finding the number of 5 card hands from a total of 52 car
> Any help would be greatly appreciated.

}

Function Permutation(things, atatime : Word) : LongInt;
Var
  i : Word;
  temp : LongInt;
begin
  temp := 1;
  For i := 1 to atatime do
  begin
    temp := temp * things;
    dec(things);
  end;
  Permutation := temp;
end;

begin
  Writeln('7p7 = ',Permutation(7,7));
end.