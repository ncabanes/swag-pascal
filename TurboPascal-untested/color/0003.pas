{
> know a good, easy way to detect mono/color?
}

Program CheckDisplay;
Var
  Display: Byte Absolute $40:$10;

begin
  if ((Display and $30) = $30) then
    Writeln('Monochrome display')
  ELSE
    Writeln('Color display');
end.
