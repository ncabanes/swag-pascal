{
>The problem is to Write a recursive Program to calculate Fibonacci numbers.
>The rules For the Fibonacci numbers are:
>
>    The Nth Fib number is:
>
>    1 if N = 1 or 2
>    The sum of the previous two numbers in the series if N > 2
>    N must always be > 0.
}

Function fib(n : LongInt) : LongInt;
begin
  if n < 2 then
    fib := n
  else
    fib := fib(n - 1) + fib(n - 2);
end;

Var
  Count : Integer;

begin
  Writeln('Fib: ');
  For Count := 1 to 15 do
    Write(Fib(Count),', ');
end.