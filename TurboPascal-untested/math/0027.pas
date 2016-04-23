{
MICHAEL M. BYRNE

> the way, it took about 20 mins. on my 386/40 to get prime numbers
> through  20000. I tried to come up With code to do the same With
> Turbo but it continues to elude me. Could anybody explain
> how to Write such a routine in Pascal?

Here is a simple Boolean Function For you to work With.
}

Function Prime(N : Integer) : Boolean;
{Returns True if N is a prime; otherwise returns False. Precondition: N > 0.}
Var
  I : Integer;
begin
  if N = 1 then
    Prime := False
  else
  if N = 2 then
    Prime := True
  else
  begin { N > 2 }
    Prime := True; {tentatively}
    For I := 2 to N - 1 do
      if (N mod I = 0) then
        Prime := False;
  end; { N > 2 }
end;
