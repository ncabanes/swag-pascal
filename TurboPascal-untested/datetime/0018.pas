{ DAVID DRZYZGA }

Program timetest;
Uses
  Dos;

Function time : String;
Var
  reg     : Registers;
  h, m, s : String[2];

  Function tch(s : String) : String;
  Var
    temp : String[2];
  begin
    temp := s;
    if length(s) < 2 then
      tch := '0' + temp
    else
      tch := temp;
  end;

begin
  reg.ax := $2c00;
  intr($21, reg);
  str(reg.cx shr 8, h);
  str(reg.cx mod 256, m);
  str(reg.dx shr 8, s);
  time := tch(h) + ':' + tch(m) + ':' + tch(s);
end;

begin
  Writeln(time);
end.
