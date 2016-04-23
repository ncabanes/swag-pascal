{
Or better yet, the BIOS stores the addresses of the parallel Interfaces
on the system at memory location $0040:$0008.  There are four Words
here, allowing up to 4 parallel devices.
-Brian Pape
}
Var
  i : Byte;
  par : Array[1..4] of Word;
begin
  For i := 1 to 4 do
  begin
    par[i] := Word(ptr($0040, $0008 + (i - 1) * 2)^);
    If Par[i] = 0 then
      Writeln('Not Found')
    else
      Writeln(Par[i]);
  end;
end.


