Program HiBack; {Demonstrate use of "High-Intensity" bgd colors}

Uses Crt, Dos;

Var
  Fgd,Bgd : Integer;
  Regs : Registers;

Procedure EnableHighBgd;
begin
  Regs.ax:=$1003;
  Regs.bx:=0;
  Intr($10,Regs);
end; {Procedure EnableHighBgd}

Procedure DisableHighBgd;
begin
  Regs.ax:=$1003;
  Regs.bx:=1;
  Intr($10,Regs);
end; {Procedure DisableHighBgd}

Procedure ShowAllCombos;
begin
  TextMode(CO80);
  For Fgd := 0 to 15 DO
  begin
   TextColor(Fgd);
    For Bgd := 0 to 15 DO
    begin
      TextAttr := Fgd + (16 * Bgd);
      Write(' Hi ');
    end;
    Writeln;
  end;
  TextAttr := 15;
end; {Procedure ShowAllCombos}

begin
  ShowAllCombos;
  Writeln; Write('Press return...'); Readln;
  EnableHighBgd;
  Writeln; Write('Press it again...'); Readln;
  DisableHighBgd;
  Writeln; Write('One last time...'); Readln;
end.
