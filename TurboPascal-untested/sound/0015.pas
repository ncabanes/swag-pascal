{ BILL BUCHANAN }

Uses
  Crt;

Procedure OpenWhistle;
Var
  Frequency : Integer;
begin
  For Frequency := 500 to 1000 do
  begin
    Delay(1);
    Sound(Frequency)
  end;
  NoSound
end;

Procedure CloseWhistle;
Var
  Frequency: Integer;
begin
  For Frequency := 1000 downto 500 do
  begin
    Delay(1);
    Sound(Frequency)
  end;
  NoSound
end;

begin
  OpenWhistle;
  Readln;
  CloseWhistle;
end.